<?php

require_once __DIR__ . '/../helpers/Response.php';

class CategoryController
{
    public static function index(PDO $pdo): void
    {
        $stmt = $pdo->query('SELECT id, name FROM categories WHERE status = 1 ORDER BY name');
        Response::ok($stmt->fetchAll(), 'Categories fetched');
    }
}
