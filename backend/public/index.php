<?php

$config = require __DIR__ . '/../src/config/config.php';
require_once __DIR__ . '/../src/config/Database.php';
require_once __DIR__ . '/../src/helpers/Response.php';
require_once __DIR__ . '/../src/middleware/AuthMiddleware.php';
require_once __DIR__ . '/../src/controllers/AuthController.php';
require_once __DIR__ . '/../src/controllers/UserController.php';
require_once __DIR__ . '/../src/controllers/CategoryController.php';
require_once __DIR__ . '/../src/controllers/ChannelController.php';
require_once __DIR__ . '/../src/controllers/FavoriteController.php';
require_once __DIR__ . '/../src/controllers/EpgController.php';
require_once __DIR__ . '/../src/controllers/SubscriptionController.php';

header('Access-Control-Allow-Origin: ' . $config['cors_origin']);
header('Access-Control-Allow-Headers: Content-Type, Authorization');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

$database = new Database($config);
$pdo = $database->pdo();
$method = $_SERVER['REQUEST_METHOD'];
$routeParam = isset($_GET['route']) ? trim((string)$_GET['route']) : '';
if ($routeParam !== '') {
    $path = '/' . ltrim($routeParam, '/');
    $path = rtrim($path, '/') ?: '/';
} else {
    $uriPath = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?: '/';
    $base = rtrim(str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'])), '/');
    $path = '/' . ltrim(substr($uriPath, strlen($base)), '/');
    $path = rtrim($path, '/') ?: '/';
}

try {
    if ($method === 'GET' && ($path === '/' || $path === '/health')) {
        Response::ok(['status' => 'up'], 'API running');
    }

    if ($method === 'POST' && $path === '/auth/register') {
        AuthController::register($pdo, $config);
    }

    if ($method === 'POST' && $path === '/auth/login') {
        AuthController::login($pdo, $config);
    }

    if ($method === 'POST' && $path === '/auth/logout') {
        $authUser = AuthMiddleware::user($pdo, $config['jwt_secret']);
        AuthController::logout($pdo);
    }

    if ($method === 'GET' && $path === '/user/profile') {
        $authUser = AuthMiddleware::user($pdo, $config['jwt_secret']);
        UserController::profile($pdo, $authUser);
    }

    if ($method === 'PUT' && $path === '/user/profile') {
        $authUser = AuthMiddleware::user($pdo, $config['jwt_secret']);
        UserController::updateProfile($pdo, $authUser);
    }

    if ($method === 'GET' && $path === '/channels') {
        ChannelController::index($pdo);
    }

    if ($method === 'GET' && preg_match('#^/channels/(\d+)$#', $path, $m)) {
        $authUser = AuthMiddleware::user($pdo, $config['jwt_secret']);
        ChannelController::show($pdo, (int)$m[1], $authUser);
    }

    if ($method === 'POST' && $path === '/admin/channels') {
        $authUser = AuthMiddleware::user($pdo, $config['jwt_secret']);
        ChannelController::adminCreate($pdo, $authUser);
    }

    if ($method === 'GET' && $path === '/categories') {
        CategoryController::index($pdo);
    }

    if ($method === 'GET' && $path === '/favorites') {
        $authUser = AuthMiddleware::user($pdo, $config['jwt_secret']);
        FavoriteController::index($pdo, $authUser);
    }

    if ($method === 'POST' && $path === '/favorites') {
        $authUser = AuthMiddleware::user($pdo, $config['jwt_secret']);
        FavoriteController::add($pdo, $authUser);
    }

    if ($method === 'DELETE' && preg_match('#^/favorites/(\d+)$#', $path, $m)) {
        $authUser = AuthMiddleware::user($pdo, $config['jwt_secret']);
        FavoriteController::remove($pdo, $authUser, (int)$m[1]);
    }

    if ($method === 'GET' && $path === '/epg') {
        EpgController::byChannel($pdo);
    }

    if ($method === 'GET' && $path === '/subscription/plans') {
        SubscriptionController::plans($pdo);
    }

    if ($method === 'POST' && $path === '/subscription/assign') {
        $authUser = AuthMiddleware::user($pdo, $config['jwt_secret']);
        SubscriptionController::assignPlan($pdo, $authUser);
    }

    Response::error(404, 'Endpoint not found');
} catch (PDOException $e) {
    Response::error(500, 'Database error', ['details' => $e->getMessage()]);
} catch (Throwable $e) {
    Response::error(500, 'Server error', ['details' => $e->getMessage()]);
}
