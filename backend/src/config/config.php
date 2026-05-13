<?php

function envOr(string $key, mixed $default): mixed
{
    $value = getenv($key);
    if ($value === false || $value === '') {
        return $default;
    }
    return $value;
}

return [
    'db_host' => (string)envOr('DB_HOST', '127.0.0.1'),
    'db_port' => (int)envOr('DB_PORT', 3306),
    'db_name' => (string)envOr('DB_NAME', 'iptv_app'),
    'db_user' => (string)envOr('DB_USER', 'root'),
    'db_pass' => (string)envOr('DB_PASS', ''),
    'jwt_secret' => (string)envOr('JWT_SECRET', 'CHANGE_THIS_LONG_RANDOM_SECRET'),
    'token_ttl_seconds' => (int)envOr('TOKEN_TTL_SECONDS', 60 * 60 * 24 * 30),
    'cors_origin' => (string)envOr('CORS_ORIGIN', '*')
];
