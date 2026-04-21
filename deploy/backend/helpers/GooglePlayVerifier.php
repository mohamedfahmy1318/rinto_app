<?php
/**
 * Google Play Purchase Verifier
 * Verifies Google Play purchases using the Android Publisher API
 */

class GooglePlayVerifier {
    private $packageName;
    private $serviceAccountJson;
    private $useSandbox;
    private $accessToken;
    
    public function __construct() {
        // Load settings from database
        $db = Database::getInstance();
        
        $this->packageName = 'com.rentogo.app'; // Your app's package name
        $this->serviceAccountJson = '';
        $this->useSandbox = true;
        
        // Get settings from DB
        $allSettings = $db->fetchAll("SELECT setting_key, setting_value FROM settings WHERE setting_key IN ('google_play_service_account', 'google_iap_sandbox')");
        foreach ($allSettings as $setting) {
            if ($setting['setting_key'] === 'google_play_service_account') {
                $this->serviceAccountJson = $setting['setting_value'] ?? '';
            }
            if ($setting['setting_key'] === 'google_iap_sandbox') {
                $this->useSandbox = ($setting['setting_value'] ?? '1') === '1';
            }
        }
    }
    
    /**
     * Verify a purchase with Google Play
     * 
     * @param string $productId The product ID
     * @param string $purchaseToken The purchase token from the app
     * @return array ['success' => bool, 'data' => array|null, 'error' => string|null]
     */
    public function verifyPurchase($productId, $purchaseToken) {
        if (empty($purchaseToken)) {
            return [
                'success' => false,
                'error' => 'Purchase token is empty',
                'data' => null
            ];
        }
        
        // For sandbox/testing mode, accept all purchases
        if ($this->useSandbox) {
            return [
                'success' => true,
                'error' => null,
                'data' => [
                    'product_id' => $productId,
                    'purchase_token' => $purchaseToken,
                    'purchase_state' => 0, // 0 = Purchased
                    'consumption_state' => 0, // 0 = Not consumed
                    'acknowledged' => false,
                    'environment' => 'sandbox'
                ]
            ];
        }
        
        // For production, verify with Google API
        if (empty($this->serviceAccountJson)) {
            return [
                'success' => false,
                'error' => 'Google Play service account not configured',
                'data' => null
            ];
        }
        
        try {
            // Get access token
            $accessToken = $this->getAccessToken();
            if (!$accessToken) {
                return [
                    'success' => false,
                    'error' => 'Failed to get access token',
                    'data' => null
                ];
            }
            
            // Verify purchase with Google API
            $url = "https://androidpublisher.googleapis.com/androidpublisher/v3/applications/{$this->packageName}/purchases/products/{$productId}/tokens/{$purchaseToken}";
            
            $response = $this->sendRequest($url, $accessToken);
            
            if ($response === null) {
                return [
                    'success' => false,
                    'error' => 'Failed to verify purchase with Google',
                    'data' => null
                ];
            }
            
            return $this->parseResponse($response, $productId, $purchaseToken);
            
        } catch (Exception $e) {
            error_log("GooglePlayVerifier: Exception - " . $e->getMessage());
            return [
                'success' => false,
                'error' => $e->getMessage(),
                'data' => null
            ];
        }
    }
    
    /**
     * Get OAuth2 access token using service account
     */
    private function getAccessToken() {
        if ($this->accessToken) {
            return $this->accessToken;
        }
        
        $serviceAccount = json_decode($this->serviceAccountJson, true);
        if (!$serviceAccount) {
            error_log("GooglePlayVerifier: Invalid service account JSON");
            return null;
        }
        
        // Create JWT
        $header = base64_encode(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
        
        $now = time();
        $claims = [
            'iss' => $serviceAccount['client_email'],
            'scope' => 'https://www.googleapis.com/auth/androidpublisher',
            'aud' => 'https://oauth2.googleapis.com/token',
            'iat' => $now,
            'exp' => $now + 3600
        ];
        $payload = base64_encode(json_encode($claims));
        
        // Sign with private key
        $privateKey = openssl_pkey_get_private($serviceAccount['private_key']);
        if (!$privateKey) {
            error_log("GooglePlayVerifier: Invalid private key");
            return null;
        }
        
        $signature = '';
        openssl_sign("$header.$payload", $signature, $privateKey, OPENSSL_ALGO_SHA256);
        $signature = base64_encode($signature);
        
        $jwt = "$header.$payload.$signature";
        
        // Exchange JWT for access token
        $ch = curl_init('https://oauth2.googleapis.com/token');
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => http_build_query([
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion' => $jwt
            ]),
            CURLOPT_HTTPHEADER => ['Content-Type: application/x-www-form-urlencoded'],
            CURLOPT_TIMEOUT => 30
        ]);
        
        $result = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($httpCode !== 200) {
            error_log("GooglePlayVerifier: Failed to get access token - HTTP $httpCode");
            return null;
        }
        
        $data = json_decode($result, true);
        $this->accessToken = $data['access_token'] ?? null;
        
        return $this->accessToken;
    }
    
    /**
     * Send request to Google API
     */
    private function sendRequest($url, $accessToken) {
        $ch = curl_init($url);
        
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => [
                'Authorization: Bearer ' . $accessToken,
                'Accept: application/json'
            ],
            CURLOPT_TIMEOUT => 30,
            CURLOPT_SSL_VERIFYPEER => true
        ]);
        
        $result = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);
        
        if ($error) {
            error_log("GooglePlayVerifier: CURL error - $error");
            return null;
        }
        
        if ($httpCode !== 200) {
            error_log("GooglePlayVerifier: HTTP error - $httpCode, Response: $result");
            return null;
        }
        
        return json_decode($result, true);
    }
    
    /**
     * Parse Google's response
     */
    private function parseResponse($response, $productId, $purchaseToken) {
        // purchaseState: 0 = Purchased, 1 = Canceled, 2 = Pending
        $purchaseState = $response['purchaseState'] ?? -1;
        
        if ($purchaseState !== 0) {
            $stateMessages = [
                1 => 'Purchase was canceled',
                2 => 'Purchase is pending'
            ];
            return [
                'success' => false,
                'error' => $stateMessages[$purchaseState] ?? "Invalid purchase state: $purchaseState",
                'data' => null
            ];
        }
        
        return [
            'success' => true,
            'error' => null,
            'data' => [
                'product_id' => $productId,
                'purchase_token' => $purchaseToken,
                'purchase_state' => $purchaseState,
                'consumption_state' => $response['consumptionState'] ?? 0,
                'acknowledged' => $response['acknowledgementState'] ?? 0,
                'purchase_time_millis' => $response['purchaseTimeMillis'] ?? null,
                'order_id' => $response['orderId'] ?? null,
                'environment' => 'production'
            ]
        ];
    }
    
    /**
     * Acknowledge a purchase (required for Google Play)
     */
    public function acknowledgePurchase($productId, $purchaseToken) {
        if ($this->useSandbox || empty($this->serviceAccountJson)) {
            return true;
        }
        
        $accessToken = $this->getAccessToken();
        if (!$accessToken) {
            return false;
        }
        
        $url = "https://androidpublisher.googleapis.com/androidpublisher/v3/applications/{$this->packageName}/purchases/products/{$productId}/tokens/{$purchaseToken}:acknowledge";
        
        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_HTTPHEADER => [
                'Authorization: Bearer ' . $accessToken,
                'Content-Type: application/json'
            ],
            CURLOPT_TIMEOUT => 30
        ]);
        
        curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        return $httpCode === 204 || $httpCode === 200;
    }
}
