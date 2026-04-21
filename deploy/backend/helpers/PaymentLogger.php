<?php
/**
 * PaymentLogger - Helper class for logging payments and creating invoices
 */

class PaymentLogger {
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    /**
     * Generate unique invoice number
     */
    public function generateInvoiceNumber() {
        $prefix = 'INV';
        $year = date('Y');
        $month = date('m');
        
        // Get last invoice number for this month
        $last = $this->db->fetch(
            "SELECT invoice_number FROM invoices WHERE invoice_number LIKE ? ORDER BY id DESC LIMIT 1",
            [$prefix . $year . $month . '%']
        );
        
        if ($last) {
            $lastNum = (int)substr($last['invoice_number'], -5);
            $newNum = $lastNum + 1;
        } else {
            $newNum = 1;
        }
        
        return $prefix . $year . $month . str_pad($newNum, 5, '0', STR_PAD_LEFT);
    }
    
    /**
     * Calculate fee based on payment method
     */
    public function calculateFee($amount, $paymentMethod) {
        $feeRates = [
            'apple_iap' => 0.15,      // 15% Apple fee (first $1M)
            'google_iap' => 0.15,     // 15% Google fee (first $1M)
            'bank_transfer' => 0,      // No fee
            'test' => 0                // No fee
        ];
        
        $rate = $feeRates[$paymentMethod] ?? 0;
        return round($amount * $rate, 2);
    }
    
    /**
     * Log payment with full details
     */
    public function logPayment($data) {
        $amount = $data['amount'] ?? 0;
        $paymentMethod = $data['payment_method'] ?? 'unknown';
        $feeAmount = $this->calculateFee($amount, $paymentMethod);
        $netAmount = $amount - $feeAmount;
        $invoiceNumber = $this->generateInvoiceNumber();
        
        $paymentData = [
            'invoice_number' => $invoiceNumber,
            'user_id' => $data['user_id'],
            'plan_id' => $data['plan_id'],
            'subscription_id' => $data['subscription_id'] ?? null,
            'amount' => $amount,
            'fee_amount' => $feeAmount,
            'net_amount' => $netAmount,
            'currency' => $data['currency'] ?? 'ILS',
            'platform' => $data['platform'] ?? 'android',
            'ip_address' => $this->getClientIP(),
            'user_agent' => $_SERVER['HTTP_USER_AGENT'] ?? null,
            'payment_method' => $paymentMethod,
            'environment' => $data['environment'] ?? 'production',
            'transaction_id' => $data['transaction_id'] ?? null,
            'store_transaction_id' => $data['store_transaction_id'] ?? null,
            'product_id' => $data['product_id'] ?? null,
            'receipt_data' => $data['receipt_data'] ?? null,
            'status' => $data['status'] ?? 'pending',
            'error_code' => $data['error_code'] ?? null,
            'error_message' => $data['error_message'] ?? null,
            'notes' => $data['notes'] ?? null
        ];
        
        $paymentId = $this->db->insert('payments', $paymentData);
        
        // Log the action
        $this->logAction($paymentId, 'created', null, $data['status'] ?? 'pending', $amount, 'Payment created');
        
        return [
            'payment_id' => $paymentId,
            'invoice_number' => $invoiceNumber,
            'fee_amount' => $feeAmount,
            'net_amount' => $netAmount
        ];
    }
    
    /**
     * Update payment status
     */
    public function updatePaymentStatus($paymentId, $newStatus, $data = []) {
        $payment = $this->db->fetch("SELECT * FROM payments WHERE id = ?", [$paymentId]);
        if (!$payment) return false;
        
        $oldStatus = $payment['status'];
        
        $updateData = ['status' => $newStatus];
        
        if (isset($data['error_code'])) $updateData['error_code'] = $data['error_code'];
        if (isset($data['error_message'])) $updateData['error_message'] = $data['error_message'];
        if (isset($data['verified_at'])) $updateData['verified_at'] = $data['verified_at'];
        if (isset($data['verified_by'])) $updateData['verified_by'] = $data['verified_by'];
        if (isset($data['notes'])) $updateData['notes'] = $data['notes'];
        
        // Handle refund
        if ($newStatus === 'refunded') {
            $updateData['refunded_at'] = date('Y-m-d H:i:s');
            $updateData['refunded_amount'] = $data['refunded_amount'] ?? $payment['amount'];
            $updateData['refund_reason'] = $data['refund_reason'] ?? null;
        }
        
        $this->db->update('payments', $updateData, ['id' => $paymentId]);
        
        // Log the action
        $action = $newStatus === 'completed' ? 'completed' : 
                 ($newStatus === 'failed' ? 'failed' : 
                 ($newStatus === 'refunded' ? 'refunded' : 'processing'));
        
        $this->logAction(
            $paymentId, 
            $action, 
            $oldStatus, 
            $newStatus, 
            $payment['amount'],
            $data['message'] ?? "Status changed from $oldStatus to $newStatus",
            $data['raw_response'] ?? null,
            $data['performed_by'] ?? null
        );
        
        return true;
    }
    
    /**
     * Log payment action for audit trail
     */
    public function logAction($paymentId, $action, $statusFrom, $statusTo, $amount = null, $message = null, $rawResponse = null, $performedBy = null) {
        $this->db->insert('payment_logs', [
            'payment_id' => $paymentId,
            'action' => $action,
            'status_from' => $statusFrom,
            'status_to' => $statusTo,
            'amount' => $amount,
            'message' => $message,
            'raw_response' => $rawResponse ? json_encode($rawResponse) : null,
            'ip_address' => $this->getClientIP(),
            'performed_by' => $performedBy
        ]);
    }
    
    /**
     * Create invoice for a payment
     */
    public function createInvoice($paymentId, $billingInfo = []) {
        $payment = $this->db->fetch(
            "SELECT p.*, pl.name_ar as plan_name, pl.name_en as plan_name_en, u.name as user_name, u.email, u.phone
             FROM payments p 
             JOIN plans pl ON p.plan_id = pl.id 
             JOIN users u ON p.user_id = u.id 
             WHERE p.id = ?",
            [$paymentId]
        );
        
        if (!$payment) return null;
        
        $invoiceNumber = $payment['invoice_number'] ?? $this->generateInvoiceNumber();
        
        // Create invoice
        $invoiceId = $this->db->insert('invoices', [
            'invoice_number' => $invoiceNumber,
            'user_id' => $payment['user_id'],
            'payment_id' => $paymentId,
            'subscription_id' => $payment['subscription_id'],
            'type' => 'purchase',
            'subtotal' => $payment['amount'],
            'tax_rate' => 0,
            'tax_amount' => 0,
            'discount_amount' => 0,
            'total' => $payment['amount'],
            'currency' => $payment['currency'],
            'status' => $payment['status'] === 'completed' ? 'paid' : 'issued',
            'issued_at' => date('Y-m-d H:i:s'),
            'paid_at' => $payment['status'] === 'completed' ? date('Y-m-d H:i:s') : null,
            'billing_name' => $billingInfo['name'] ?? $payment['user_name'],
            'billing_email' => $billingInfo['email'] ?? $payment['email'],
            'billing_phone' => $billingInfo['phone'] ?? $payment['phone'],
            'billing_address' => $billingInfo['address'] ?? null
        ]);
        
        // Create invoice item
        $this->db->insert('invoice_items', [
            'invoice_id' => $invoiceId,
            'description' => $payment['plan_name'] ?? 'Subscription',
            'quantity' => 1,
            'unit_price' => $payment['amount'],
            'total' => $payment['amount'],
            'plan_id' => $payment['plan_id']
        ]);
        
        return $invoiceId;
    }
    
    /**
     * Get payment statistics
     */
    public function getStats($startDate = null, $endDate = null) {
        $where = "1=1";
        $params = [];
        
        if ($startDate) {
            $where .= " AND created_at >= ?";
            $params[] = $startDate;
        }
        if ($endDate) {
            $where .= " AND created_at <= ?";
            $params[] = $endDate;
        }
        
        $stats = $this->db->fetch("
            SELECT 
                COUNT(*) as total_transactions,
                COUNT(CASE WHEN status = 'completed' THEN 1 END) as successful,
                COUNT(CASE WHEN status = 'failed' THEN 1 END) as failed,
                COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending,
                COUNT(CASE WHEN status = 'refunded' THEN 1 END) as refunded,
                SUM(CASE WHEN status = 'completed' THEN amount ELSE 0 END) as gross_revenue,
                SUM(CASE WHEN status = 'completed' THEN fee_amount ELSE 0 END) as total_fees,
                SUM(CASE WHEN status = 'completed' THEN net_amount ELSE 0 END) as net_revenue,
                SUM(CASE WHEN status = 'refunded' THEN refunded_amount ELSE 0 END) as total_refunds
            FROM payments WHERE $where
        ", $params);
        
        // By payment method
        $byMethod = $this->db->fetchAll("
            SELECT 
                payment_method,
                COUNT(*) as count,
                SUM(CASE WHEN status = 'completed' THEN amount ELSE 0 END) as revenue
            FROM payments WHERE $where
            GROUP BY payment_method
        ", $params);
        
        return [
            'summary' => $stats,
            'by_method' => $byMethod
        ];
    }
    
    /**
     * Get client IP address
     */
    private function getClientIP() {
        $headers = ['HTTP_CF_CONNECTING_IP', 'HTTP_X_FORWARDED_FOR', 'HTTP_X_REAL_IP', 'REMOTE_ADDR'];
        foreach ($headers as $header) {
            if (!empty($_SERVER[$header])) {
                $ips = explode(',', $_SERVER[$header]);
                return trim($ips[0]);
            }
        }
        return 'unknown';
    }
}
