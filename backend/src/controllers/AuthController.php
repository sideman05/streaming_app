<?php

require_once __DIR__ . '/../helpers/Request.php';
require_once __DIR__ . '/../helpers/Response.php';
require_once __DIR__ . '/../helpers/Auth.php';

class AuthController
{
    public static function register(PDO $pdo, array $config): void
    {
        $body = Request::jsonBody();
        $name = trim((string)($body['name'] ?? ''));
        $email = strtolower(trim((string)($body['email'] ?? '')));
        $password = (string)($body['password'] ?? '');

        if ($name === '' || !filter_var($email, FILTER_VALIDATE_EMAIL) || strlen($password) < 6) {
            Response::error(422, 'Validation failed', [
                'name' => 'Name is required',
                'email' => 'Valid email is required',
                'password' => 'Password must be at least 6 characters',
            ]);
        }

        $check = $pdo->prepare('SELECT id FROM users WHERE email = :email LIMIT 1');
        $check->execute(['email' => $email]);
        if ($check->fetch()) {
            Response::error(409, 'Email already exists');
        }

        $stmt = $pdo->prepare('INSERT INTO users (name, email, password_hash, subscription_status, role, status) VALUES (:name, :email, :password_hash, :subscription_status, :role, :status)');
        $stmt->execute([
            'name' => $name,
            'email' => $email,
            'password_hash' => password_hash($password, PASSWORD_BCRYPT),
            'subscription_status' => 'free',
            'role' => 'user',
            'status' => 1,
        ]);

        $userId = (int)$pdo->lastInsertId();
        self::issueTokenResponse($pdo, $config, [
            'id' => $userId,
            'name' => $name,
            'email' => $email,
            'subscription_status' => 'free',
            'plan_id' => null,
        ], 201, 'User registered');
    }

    public static function login(PDO $pdo, array $config): void
    {
        $body = Request::jsonBody();
        $email = strtolower(trim((string)($body['email'] ?? '')));
        $password = (string)($body['password'] ?? '');

        if (!filter_var($email, FILTER_VALIDATE_EMAIL) || $password === '') {
            Response::error(422, 'Email and password are required');
        }

        $stmt = $pdo->prepare('SELECT id, name, email, password_hash, subscription_status, plan_id, status FROM users WHERE email = :email LIMIT 1');
        $stmt->execute(['email' => $email]);
        $user = $stmt->fetch();

        if (!$user || (int)$user['status'] !== 1 || !password_verify($password, $user['password_hash'])) {
            Response::error(401, 'Invalid credentials');
        }

        self::issueTokenResponse($pdo, $config, [
            'id' => (int)$user['id'],
            'name' => $user['name'],
            'email' => $user['email'],
            'subscription_status' => $user['subscription_status'],
            'plan_id' => $user['plan_id'] !== null ? (int)$user['plan_id'] : null,
        ]);
    }

    public static function logout(PDO $pdo): void
    {
        $token = Request::bearerToken();
        if ($token) {
            $hash = hash('sha256', $token);
            $stmt = $pdo->prepare('UPDATE auth_tokens SET revoked = 1 WHERE token_hash = :token_hash');
            $stmt->execute(['token_hash' => $hash]);
        }
        Response::ok([], 'Logged out');
    }

    private static function issueTokenResponse(PDO $pdo, array $config, array $user, int $statusCode = 200, string $message = 'Login successful'): void
    {
        $token = Auth::generateToken(['sub' => $user['id']], $config['jwt_secret'], (int)$config['token_ttl_seconds']);
        $hash = hash('sha256', $token);

        $insert = $pdo->prepare('INSERT INTO auth_tokens (user_id, token_hash, expires_at, revoked) VALUES (:user_id, :token_hash, :expires_at, :revoked)');
        $insert->execute([
            'user_id' => $user['id'],
            'token_hash' => $hash,
            'expires_at' => date('Y-m-d H:i:s', time() + (int)$config['token_ttl_seconds']),
            'revoked' => 0,
        ]);

        if ($statusCode === 201) {
            Response::created(['token' => $token, 'user' => $user], $message);
        }
        Response::ok(['token' => $token, 'user' => $user], $message);
    }
}
