<?php

require_once __DIR__ . '/../helpers/Request.php';
require_once __DIR__ . '/../helpers/Response.php';

class FavoriteController
{
    public static function index(PDO $pdo, array $authUser): void
    {
        $stmt = $pdo->prepare('SELECT c.id, c.name, c.logo_url, c.stream_url, c.description, c.is_premium, cat.name AS category_name
                               FROM favorites f
                               JOIN channels c ON c.id = f.channel_id
                               JOIN categories cat ON cat.id = c.category_id
                               WHERE f.user_id = :user_id
                               ORDER BY f.id DESC');
        $stmt->execute(['user_id' => (int)$authUser['id']]);
        Response::ok($stmt->fetchAll(), 'Favorites fetched');
    }

    public static function add(PDO $pdo, array $authUser): void
    {
        $body = Request::jsonBody();
        $channelId = (int)($body['channel_id'] ?? 0);
        if ($channelId <= 0) {
            Response::error(422, 'channel_id is required');
        }

        $stmt = $pdo->prepare('INSERT IGNORE INTO favorites (user_id, channel_id) VALUES (:user_id, :channel_id)');
        $stmt->execute([
            'user_id' => (int)$authUser['id'],
            'channel_id' => $channelId,
        ]);

        Response::created([], 'Added to favorites');
    }

    public static function remove(PDO $pdo, array $authUser, int $channelId): void
    {
        $stmt = $pdo->prepare('DELETE FROM favorites WHERE user_id = :user_id AND channel_id = :channel_id');
        $stmt->execute([
            'user_id' => (int)$authUser['id'],
            'channel_id' => $channelId,
        ]);
        Response::ok([], 'Removed from favorites');
    }
}
