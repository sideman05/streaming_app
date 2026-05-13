<?php

require_once __DIR__ . '/../helpers/Request.php';
require_once __DIR__ . '/../helpers/Response.php';

class ChannelController
{
    public static function index(PDO $pdo): void
    {
        $page = max(1, (int)(Request::query('page', '1') ?? '1'));
        $limit = 20;
        $offset = ($page - 1) * $limit;
        $q = Request::query('q');
        $category = Request::query('category');

        $where = ['c.status = 1'];
        $params = [];

        if ($q !== null && $q !== '') {
            $where[] = '(c.name LIKE :q OR cat.name LIKE :q)';
            $params['q'] = '%' . $q . '%';
        }

        if ($category !== null && $category !== '') {
            $where[] = 'cat.name = :category';
            $params['category'] = $category;
        }

        $whereSql = implode(' AND ', $where);
        $countSql = 'SELECT COUNT(*) AS total FROM channels c JOIN categories cat ON cat.id = c.category_id WHERE ' . $whereSql;
        $countStmt = $pdo->prepare($countSql);
        $countStmt->execute($params);
        $total = (int)$countStmt->fetch()['total'];

        $sql = 'SELECT c.id, c.name, c.logo_url, c.stream_url, c.description, c.is_premium, cat.name AS category_name,
                (SELECT title FROM epg_programs ep WHERE ep.channel_id = c.id AND NOW() BETWEEN ep.start_time AND ep.end_time LIMIT 1) AS current_program
                FROM channels c
                JOIN categories cat ON cat.id = c.category_id
                WHERE ' . $whereSql . '
                ORDER BY c.id DESC
                LIMIT :limit OFFSET :offset';

        $stmt = $pdo->prepare($sql);
        foreach ($params as $k => $v) {
            $stmt->bindValue(':' . $k, $v);
        }
        $stmt->bindValue(':limit', $limit, PDO::PARAM_INT);
        $stmt->bindValue(':offset', $offset, PDO::PARAM_INT);
        $stmt->execute();

        Response::ok([
            'items' => $stmt->fetchAll(),
            'pagination' => [
                'page' => $page,
                'limit' => $limit,
                'total' => $total,
            ],
        ], 'Channels fetched');
    }

    public static function show(PDO $pdo, int $id, array $authUser): void
    {
        $stmt = $pdo->prepare('SELECT c.id, c.name, c.logo_url, c.stream_url, c.description, c.is_premium, cat.name AS category_name
                               FROM channels c
                               JOIN categories cat ON cat.id = c.category_id
                               WHERE c.id = :id AND c.status = 1 LIMIT 1');
        $stmt->execute(['id' => $id]);
        $channel = $stmt->fetch();

        if (!$channel) {
            Response::error(404, 'Channel not found');
        }

        if ((int)$channel['is_premium'] === 1 && ($authUser['subscription_status'] ?? 'free') !== 'premium') {
            Response::error(403, 'Subscription required');
        }

        Response::ok($channel, 'Channel details fetched');
    }

    public static function adminCreate(PDO $pdo, array $authUser): void
    {
        if (($authUser['role'] ?? 'user') !== 'admin') {
            Response::error(403, 'Admin only endpoint');
        }

        $body = Request::jsonBody();
        $required = ['name', 'logo_url', 'stream_url', 'category_id'];
        foreach ($required as $field) {
            if (empty($body[$field])) {
                Response::error(422, "$field is required");
            }
        }

        $stmt = $pdo->prepare('INSERT INTO channels (name, logo_url, stream_url, category_id, description, is_premium, status) VALUES (:name, :logo_url, :stream_url, :category_id, :description, :is_premium, :status)');
        $stmt->execute([
            'name' => trim((string)$body['name']),
            'logo_url' => trim((string)$body['logo_url']),
            'stream_url' => trim((string)$body['stream_url']),
            'category_id' => (int)$body['category_id'],
            'description' => trim((string)($body['description'] ?? '')),
            'is_premium' => !empty($body['is_premium']) ? 1 : 0,
            'status' => !isset($body['status']) || (int)$body['status'] === 1 ? 1 : 0,
        ]);

        Response::created(['id' => (int)$pdo->lastInsertId()], 'Channel created');
    }
}
