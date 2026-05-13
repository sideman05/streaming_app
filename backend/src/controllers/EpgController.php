<?php

require_once __DIR__ . '/../helpers/Request.php';
require_once __DIR__ . '/../helpers/Response.php';

class EpgController
{
    public static function byChannel(PDO $pdo): void
    {
        $channelId = (int)(Request::query('channel_id', '0') ?? '0');
        if ($channelId <= 0) {
            Response::error(422, 'channel_id is required');
        }

        $stmt = $pdo->prepare('SELECT id, channel_id, title, description, start_time, end_time
                               FROM epg_programs
                               WHERE channel_id = :channel_id AND end_time >= DATE_SUB(NOW(), INTERVAL 2 HOUR)
                               ORDER BY start_time ASC
                               LIMIT 12');
        $stmt->execute(['channel_id' => $channelId]);
        Response::ok($stmt->fetchAll(), 'EPG fetched');
    }
}
