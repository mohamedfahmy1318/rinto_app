<?php
/**
 * Firebase Cloud Messaging Helper
 * Uses FCM HTTP v1 API
 */

class FCM {
    
    private static $projectId = 'rentogo-3fa22';
    private static $apiUrl = 'https://fcm.googleapis.com/v1/projects/rentogo-3fa22/messages:send';
    private static $accessToken = null;
    
    /**
     * Get access token using Service Account
     */
    private static function getAccessToken() {
        if (self::$accessToken !== null) {
            return self::$accessToken;
        }
        
        $serviceAccountPath = __DIR__ . '/../config/firebase-service-account.json';
        
        if (!file_exists($serviceAccountPath)) {
            error_log('FCM: Service account file not found');
            return null;
        }
        
        $serviceAccount = json_decode(file_get_contents($serviceAccountPath), true);
        
        // Create JWT
        $header = base64_encode(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
        
        $now = time();
        $payload = base64_encode(json_encode([
            'iss' => $serviceAccount['client_email'],
            'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
            'aud' => 'https://oauth2.googleapis.com/token',
            'iat' => $now,
            'exp' => $now + 3600
        ]));
        
        $signature = '';
        $privateKey = openssl_pkey_get_private($serviceAccount['private_key']);
        openssl_sign("$header.$payload", $signature, $privateKey, 'SHA256');
        $signature = base64_encode($signature);
        
        $jwt = "$header.$payload.$signature";
        
        // Exchange JWT for access token
        $ch = curl_init();
        curl_setopt_array($ch, [
            CURLOPT_URL => 'https://oauth2.googleapis.com/token',
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => http_build_query([
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion' => $jwt
            ])
        ]);
        
        $response = curl_exec($ch);
        curl_close($ch);
        
        $data = json_decode($response, true);
        if (isset($data['access_token'])) {
            self::$accessToken = $data['access_token'];
            return self::$accessToken;
        }
        
        error_log('FCM: Failed to get access token: ' . $response);
        return null;
    }
    
    /**
     * Send notification to a specific device token
     */
    public static function sendToToken($token, $title, $body, $data = []) {
        $message = [
            'message' => [
                'token' => $token,
                'notification' => [
                    'title' => $title,
                    'body' => $body
                ],
                'data' => array_map('strval', $data),
                'android' => [
                    'priority' => 'high',
                    'notification' => [
                        'sound' => 'default',
                        'channel_id' => 'high_importance_channel'
                    ]
                ],
                'apns' => [
                    'headers' => [
                        'apns-priority' => '10'
                    ],
                    'payload' => [
                        'aps' => [
                            'alert' => [
                                'title' => $title,
                                'body' => $body
                            ],
                            'badge' => 1,
                            'sound' => 'default'
                        ]
                    ]
                ]
            ]
        ];
        
        return self::send($message);
    }
    
    /**
     * Send notification to multiple device tokens
     */
    public static function sendToTokens($tokens, $title, $body, $data = []) {
        $results = [];
        foreach ($tokens as $token) {
            $results[] = self::sendToToken($token, $title, $body, $data);
        }
        return $results;
    }
    
    /**
     * Send notification to a topic
     */
    public static function sendToTopic($topic, $title, $body, $data = []) {
        $message = [
            'message' => [
                'topic' => $topic,
                'notification' => [
                    'title' => $title,
                    'body' => $body
                ],
                'data' => array_map('strval', $data),
                'android' => [
                    'priority' => 'high',
                    'notification' => [
                        'sound' => 'default',
                        'channel_id' => 'high_importance_channel'
                    ]
                ],
                'apns' => [
                    'headers' => [
                        'apns-priority' => '10'
                    ],
                    'payload' => [
                        'aps' => [
                            'alert' => [
                                'title' => $title,
                                'body' => $body
                            ],
                            'badge' => 1,
                            'sound' => 'default'
                        ]
                    ]
                ]
            ]
        ];
        
        return self::send($message);
    }
    
    /**
     * Send notification to all users (broadcast)
     */
    public static function sendToAll($title, $body, $data = []) {
        return self::sendToTopic('all_users', $title, $body, $data);
    }
    
    /**
     * Send notification to users by type
     */
    public static function sendToUserType($userType, $title, $body, $data = []) {
        return self::sendToTopic('user_type_' . $userType, $title, $body, $data);
    }
    
    /**
     * Send the FCM message
     */
    private static function send($message) {
        $accessToken = self::getAccessToken();
        
        if (!$accessToken) {
            return ['success' => false, 'error' => 'Failed to get access token'];
        }
        
        $ch = curl_init();
        
        curl_setopt_array($ch, [
            CURLOPT_URL => self::$apiUrl,
            CURLOPT_HTTPHEADER => [
                'Authorization: Bearer ' . $accessToken,
                'Content-Type: application/json'
            ],
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => json_encode($message),
            CURLOPT_SSL_VERIFYPEER => false
        ]);
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);
        
        if ($error) {
            error_log("FCM Error: $error");
            return ['success' => false, 'error' => $error];
        }
        
        $data = json_decode($response, true);
        
        // Log full response for debugging
        error_log("FCM Response ($httpCode): $response");
        
        if ($httpCode === 200) {
            return ['success' => true, 'data' => $data];
        }
        
        error_log("FCM Error ($httpCode): $response");
        $errorMessage = $data['error']['message'] ?? ($data['error']['status'] ?? 'Unknown error');
        return ['success' => false, 'error' => $errorMessage, 'code' => $httpCode, 'raw' => $response];
    }
}
