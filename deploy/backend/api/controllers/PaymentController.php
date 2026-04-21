<?php
/**
 * Payment Controller
 */

class PaymentController {
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    public function verifyReceipt($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $validator = new Validator($input);
        $validator
            ->required('plan_id')
            ->required('platform')->in('platform', ['ios', 'android'])
            ->required('receipt_data')
            ->validate();
        
        // Get plan
        $plan = $this->db->fetch("SELECT * FROM plans WHERE id = ? AND is_active = 1", [$input['plan_id']]);
        if (!$plan) {
            Response::notFound('Plan not found');
        }
        
        // In production, verify receipt with Apple/Google
        // For now, we'll simulate verification
        $verified = $this->verifyWithStore($input['platform'], $input['receipt_data']);
        
        if (!$verified) {
            Response::error('Payment verification failed', 400);
        }
        
        // Create payment record
        $paymentId = $this->db->insert('payments', [
            'user_id' => $auth['user_id'],
            'plan_id' => $plan['id'],
            'amount' => $plan['price'],
            'currency' => $plan['currency'],
            'platform' => $input['platform'],
            'transaction_id' => $input['transaction_id'] ?? uniqid('txn_'),
            'receipt_data' => $input['receipt_data'],
            'status' => 'completed',
            'verified_at' => date('Y-m-d H:i:s')
        ]);
        
        // Create subscription
        $expiresAt = date('Y-m-d H:i:s', strtotime('+' . $plan['duration_days'] . ' days'));
        
        $subscriptionId = $this->db->insert('subscriptions', [
            'user_id' => $auth['user_id'],
            'plan_id' => $plan['id'],
            'listings_limit' => $plan['is_unlimited'] ? null : $plan['listings_count'],
            'is_unlimited' => $plan['is_unlimited'],
            'status' => 'active',
            'expires_at' => $expiresAt
        ]);
        
        // Update payment with subscription ID
        $this->db->update('payments', ['subscription_id' => $subscriptionId], 'id = ?', [$paymentId]);
        
        // If there's a listing_id, update the listing status
        if (!empty($input['listing_id']) && !empty($input['listing_type'])) {
            $table = $input['listing_type'] === 'car' ? 'cars' : 'properties';
            $listing = $this->db->fetch(
                "SELECT * FROM $table WHERE id = ? AND user_id = ?",
                [$input['listing_id'], $auth['user_id']]
            );
            
            if ($listing && in_array($listing['status'], ['draft', 'pending_payment', 'expired'])) {
                $this->db->update($table, [
                    'status' => 'pending_admin_review',
                    'subscription_id' => $subscriptionId,
                    'expires_at' => $expiresAt
                ], 'id = ?', [$input['listing_id']]);
            }
        }
        
        $subscription = $this->db->fetch("SELECT * FROM subscriptions WHERE id = ?", [$subscriptionId]);
        
        Response::success([
            'payment_id' => $paymentId,
            'subscription' => $subscription,
            'message' => 'Payment successful. Your listing will be reviewed by admin.'
        ], 'Payment verified successfully');
    }
    
    private function verifyWithStore($platform, $receiptData) {
        // In production, implement actual verification:
        // iOS: Send receipt to Apple's verifyReceipt endpoint
        // Android: Use Google Play Developer API
        
        // For development, accept all receipts
        return true;
    }
    
    public function history($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $page = max(1, (int)($input['page'] ?? 1));
        $perPage = min(MAX_PAGE_SIZE, max(1, (int)($input['per_page'] ?? DEFAULT_PAGE_SIZE)));
        $offset = ($page - 1) * $perPage;
        
        $countSql = "SELECT COUNT(*) as total FROM payments WHERE user_id = ?";
        $total = (int)$this->db->fetch($countSql, [$auth['user_id']])['total'];
        
        $sql = "SELECT p.*, pl.name_ar as plan_name_ar, pl.name_en as plan_name_en, pl.name_he as plan_name_he,
                       pl.category as plan_category
                FROM payments p
                LEFT JOIN plans pl ON p.plan_id = pl.id
                WHERE p.user_id = ?
                ORDER BY p.created_at DESC
                LIMIT $perPage OFFSET $offset";
        
        $payments = $this->db->fetchAll($sql, [$auth['user_id']]);
        
        Response::paginated($payments, $total, $page, $perPage);
    }
}
