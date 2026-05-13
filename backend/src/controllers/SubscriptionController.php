<?php

require_once __DIR__ . '/../helpers/Request.php';
require_once __DIR__ . '/../helpers/Response.php';

class SubscriptionController
{
    public static function plans(PDO $pdo): void
    {
        $stmt = $pdo->query('SELECT id, name, description, price, duration_days FROM plans WHERE status = 1 ORDER BY price ASC');
        Response::ok($stmt->fetchAll(), 'Plans fetched');
    }

    public static function assignPlan(PDO $pdo, array $authUser): void
    {
        $body = Request::jsonBody();
        $planId = (int)($body['plan_id'] ?? 0);
        if ($planId <= 0) {
            Response::error(422, 'plan_id is required');
        }

        $planStmt = $pdo->prepare('SELECT id, name, duration_days FROM plans WHERE id = :id AND status = 1 LIMIT 1');
        $planStmt->execute(['id' => $planId]);
        $plan = $planStmt->fetch();
        if (!$plan) {
            Response::error(404, 'Plan not found');
        }

        $start = date('Y-m-d H:i:s');
        $end = date('Y-m-d H:i:s', strtotime('+' . (int)$plan['duration_days'] . ' days'));

        $ins = $pdo->prepare('INSERT INTO subscriptions (user_id, plan_id, start_date, end_date, status) VALUES (:user_id, :plan_id, :start_date, :end_date, :status)');
        $ins->execute([
            'user_id' => (int)$authUser['id'],
            'plan_id' => $planId,
            'start_date' => $start,
            'end_date' => $end,
            'status' => 'active',
        ]);

        $up = $pdo->prepare('UPDATE users SET plan_id = :plan_id, subscription_status = :subscription_status, updated_at = NOW() WHERE id = :id');
        $up->execute([
            'plan_id' => $planId,
            'subscription_status' => 'premium',
            'id' => (int)$authUser['id'],
        ]);

        Response::ok([
            'plan_id' => $planId,
            'status' => 'premium',
            'end_date' => $end,
        ], 'Subscription activated');
    }
}
