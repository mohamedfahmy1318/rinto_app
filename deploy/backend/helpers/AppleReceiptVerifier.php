<?php
/**
 * Apple Receipt Verifier
 * Verifies App Store receipts for In-App Purchases
 */

class AppleReceiptVerifier {
    private $sandboxUrl = 'https://sandbox.itunes.apple.com/verifyReceipt';
    private $productionUrl = 'https://buy.itunes.apple.com/verifyReceipt';
    private $sharedSecret;
    private $useSandbox;
    
    public function __construct() {
        // Load settings from database
        $db = Database::getInstance();
        $settings = $db->fetch("SELECT * FROM settings WHERE setting_key IN ('apple_shared_secret', 'apple_iap_sandbox') ORDER BY setting_key");
        
        // Default values
        $this->sharedSecret = '';
        $this->useSandbox = true;
        
        // Get settings from DB
        $allSettings = $db->fetchAll("SELECT setting_key, setting_value FROM settings WHERE setting_key IN ('apple_shared_secret', 'apple_iap_sandbox')");
        foreach ($allSettings as $setting) {
            if ($setting['setting_key'] === 'apple_shared_secret') {
                $this->sharedSecret = $setting['setting_value'] ?? '';
            }
            if ($setting['setting_key'] === 'apple_iap_sandbox') {
                $this->useSandbox = ($setting['setting_value'] ?? '1') === '1';
            }
        }
    }
    
    /**
     * Verify a receipt with Apple
     * 
     * @param string $receiptData Base64 encoded receipt data
     * @return array ['success' => bool, 'data' => array|null, 'error' => string|null]
     */
    public function verifyReceipt($receiptData) {
        if (empty($receiptData)) {
            return [
                'success' => false,
                'error' => 'Receipt data is empty',
                'data' => null
            ];
        }
        
        // Build request payload
        $payload = [
            'receipt-data' => $receiptData,
            'exclude-old-transactions' => true
        ];
        
        if (!empty($this->sharedSecret)) {
            $payload['password'] = $this->sharedSecret;
        }
        
        // Try production first, then sandbox if needed
        $url = $this->useSandbox ? $this->sandboxUrl : $this->productionUrl;
        $response = $this->sendRequest($url, $payload);
        
        if ($response === null) {
            return [
                'success' => false,
                'error' => 'Failed to connect to Apple servers',
                'data' => null
            ];
        }
        
        // Status 21007 means receipt is from sandbox but sent to production
        if (isset($response['status']) && $response['status'] === 21007) {
            $response = $this->sendRequest($this->sandboxUrl, $payload);
        }
        
        // Status 21008 means receipt is from production but sent to sandbox
        if (isset($response['status']) && $response['status'] === 21008) {
            $response = $this->sendRequest($this->productionUrl, $payload);
        }
        
        if ($response === null) {
            return [
                'success' => false,
                'error' => 'Failed to verify receipt',
                'data' => null
            ];
        }
        
        return $this->parseResponse($response);
    }
    
    /**
     * Send request to Apple
     */
    private function sendRequest($url, $payload) {
        $ch = curl_init($url);
        
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => json_encode($payload),
            CURLOPT_HTTPHEADER => [
                'Content-Type: application/json',
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
            error_log("AppleReceiptVerifier: CURL error - $error");
            return null;
        }
        
        if ($httpCode !== 200) {
            error_log("AppleReceiptVerifier: HTTP error - $httpCode");
            return null;
        }
        
        return json_decode($result, true);
    }
    
    /**
     * Parse Apple's response
     */
    private function parseResponse($response) {
        $status = $response['status'] ?? -1;
        
        // Status codes: https://developer.apple.com/documentation/appstorereceipts/status
        $statusMessages = [
            0 => 'Valid receipt',
            21000 => 'The App Store could not read the receipt',
            21002 => 'The receipt data is malformed',
            21003 => 'The receipt could not be authenticated',
            21004 => 'The shared secret does not match',
            21005 => 'The receipt server is not available',
            21006 => 'This receipt is valid but the subscription has expired',
            21007 => 'This receipt is from the sandbox environment',
            21008 => 'This receipt is from the production environment',
            21010 => 'This receipt could not be authorized',
        ];
        
        if ($status !== 0) {
            return [
                'success' => false,
                'error' => $statusMessages[$status] ?? "Unknown error (status: $status)",
                'data' => null,
                'status_code' => $status
            ];
        }
        
        // Extract latest receipt info
        $receipt = $response['receipt'] ?? null;
        $latestReceiptInfo = $response['latest_receipt_info'] ?? [];
        $inAppPurchases = $receipt['in_app'] ?? [];
        
        // Get the most recent transaction
        $latestTransaction = null;
        $allTransactions = array_merge($inAppPurchases, $latestReceiptInfo);
        
        foreach ($allTransactions as $transaction) {
            if ($latestTransaction === null) {
                $latestTransaction = $transaction;
            } else {
                $currentDate = $transaction['purchase_date_ms'] ?? 0;
                $latestDate = $latestTransaction['purchase_date_ms'] ?? 0;
                if ($currentDate > $latestDate) {
                    $latestTransaction = $transaction;
                }
            }
        }
        
        return [
            'success' => true,
            'error' => null,
            'data' => [
                'bundle_id' => $receipt['bundle_id'] ?? null,
                'application_version' => $receipt['application_version'] ?? null,
                'environment' => $response['environment'] ?? 'unknown',
                'latest_transaction' => $latestTransaction,
                'all_transactions' => $allTransactions,
                'receipt' => $receipt
            ]
        ];
    }
    
    /**
     * Validate a specific product purchase
     * 
     * @param string $receiptData Base64 encoded receipt
     * @param string $expectedProductId The product ID we expect to find
     * @param string|null $transactionId Optional transaction ID to match
     * @return array
     */
    public function validatePurchase($receiptData, $expectedProductId, $transactionId = null) {
        $result = $this->verifyReceipt($receiptData);
        
        if (!$result['success']) {
            return $result;
        }
        
        $data = $result['data'];
        $transactions = $data['all_transactions'] ?? [];
        
        // Find matching transaction
        foreach ($transactions as $transaction) {
            $productId = $transaction['product_id'] ?? '';
            $txnId = $transaction['transaction_id'] ?? '';
            
            if ($productId === $expectedProductId) {
                // If transaction ID provided, verify it matches
                if ($transactionId !== null && $txnId !== $transactionId) {
                    continue;
                }
                
                return [
                    'success' => true,
                    'error' => null,
                    'data' => [
                        'product_id' => $productId,
                        'transaction_id' => $txnId,
                        'original_transaction_id' => $transaction['original_transaction_id'] ?? $txnId,
                        'purchase_date' => $transaction['purchase_date'] ?? null,
                        'purchase_date_ms' => $transaction['purchase_date_ms'] ?? null,
                        'quantity' => $transaction['quantity'] ?? 1,
                        'environment' => $data['environment'],
                        'bundle_id' => $data['bundle_id']
                    ]
                ];
            }
        }
        
        return [
            'success' => false,
            'error' => "Product '$expectedProductId' not found in receipt",
            'data' => null
        ];
    }
}
