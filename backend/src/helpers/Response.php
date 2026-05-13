<?php

class Response
{
    public static function json(int $statusCode, array $payload): void
    {
        http_response_code($statusCode);
        header('Content-Type: application/json');
        echo json_encode($payload);
        exit;
    }

    public static function ok(array $data = [], string $message = 'OK'): void
    {
        self::json(200, [
            'success' => true,
            'message' => $message,
            'data' => $data,
        ]);
    }

    public static function created(array $data = [], string $message = 'Created'): void
    {
        self::json(201, [
            'success' => true,
            'message' => $message,
            'data' => $data,
        ]);
    }

    public static function error(int $statusCode, string $message, array $errors = []): void
    {
        self::json($statusCode, [
            'success' => false,
            'message' => $message,
            'errors' => $errors,
        ]);
    }
}
