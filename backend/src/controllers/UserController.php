<?php

require_once __DIR__ . '/../helpers/Request.php';
require_once __DIR__ . '/../helpers/Response.php';

class UserController
{
    public static function profile(PDO $pdo, array $authUser): void
    {
        $stmt = $pdo->prepare('SELECT id, name, email, subscription_status, plan_id FROM users WHERE id = :id');
        $stmt->execute(['id' => (int)$authUser['id']]);
        $user = $stmt->fetch();
        Response::ok($user ?: [], 'Profile fetched');
    }

    public static function updateProfile(PDO $pdo, array $authUser): void
    {
        $body = Request::jsonBody();
        $name = trim((string)($body['name'] ?? ''));

        if ($name === '') {
            Response::error(422, 'Name is required');
        }

        $stmt = $pdo->prepare('UPDATE users SET name = :name, updated_at = NOW() WHERE id = :id');
        $stmt->execute([
            'name' => $name,
            'id' => (int)$authUser['id'],
        ]);

        self::profile($pdo, $authUser);
    }
}
