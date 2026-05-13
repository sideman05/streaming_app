<?php

require_once __DIR__ . '/../helpers/Request.php';
require_once __DIR__ . '/../helpers/Response.php';
require_once __DIR__ . '/../helpers/Auth.php';

class AuthMiddleware
{
    public static function user(PDO $pdo, string $secret): array
    {
        $token = Request::bearerToken();
        if (!$token) {
            Response::error(401, 'Missing bearer token');
        }

        $claims = Auth::validateToken($token, $secret);
        if (!$claims || !isset($claims['sub'])) {
            Response::error(401, 'Invalid or expired token');
        }

        $tokenCheck = $pdo->prepare('SELECT id FROM auth_tokens WHERE token_hash = :token_hash AND revoked = 0 AND expires_at > NOW() LIMIT 1');
        $tokenCheck->execute(['token_hash' => hash('sha256', $token)]);
        if (!$tokenCheck->fetch()) {
            Response::error(401, 'Session expired. Please log in again');
        }

        $stmt = $pdo->prepare('SELECT id, name, email, role, subscription_status, plan_id FROM users WHERE id = :id AND status = 1');
        $stmt->execute(['id' => (int)$claims['sub']]);
        $user = $stmt->fetch();

        if (!$user) {
            Response::error(401, 'User not found');
        }

        return $user;
    }
}
