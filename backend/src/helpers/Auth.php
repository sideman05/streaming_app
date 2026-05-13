<?php

class Auth
{
    public static function generateToken(array $claims, string $secret, int $ttlSeconds): string
    {
        $header = ['alg' => 'HS256', 'typ' => 'JWT'];
        $now = time();
        $payload = array_merge($claims, [
            'iat' => $now,
            'exp' => $now + $ttlSeconds,
        ]);

        $headerEnc = self::b64(json_encode($header));
        $payloadEnc = self::b64(json_encode($payload));
        $signature = hash_hmac('sha256', $headerEnc . '.' . $payloadEnc, $secret, true);
        return $headerEnc . '.' . $payloadEnc . '.' . self::b64($signature);
    }

    public static function validateToken(string $token, string $secret): ?array
    {
        $parts = explode('.', $token);
        if (count($parts) !== 3) {
            return null;
        }

        [$headerEnc, $payloadEnc, $sigEnc] = $parts;
        $expectedSig = self::b64(hash_hmac('sha256', $headerEnc . '.' . $payloadEnc, $secret, true));
        if (!hash_equals($expectedSig, $sigEnc)) {
            return null;
        }

        $payload = json_decode(self::b64Decode($payloadEnc), true);
        if (!is_array($payload)) {
            return null;
        }

        if (($payload['exp'] ?? 0) < time()) {
            return null;
        }

        return $payload;
    }

    private static function b64(string $data): string
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    private static function b64Decode(string $data): string
    {
        return base64_decode(strtr($data, '-_', '+/')) ?: '';
    }
}
