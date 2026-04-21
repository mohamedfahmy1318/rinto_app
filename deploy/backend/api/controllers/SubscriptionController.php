<?php
/**
 * Subscription Controller
 */

class SubscriptionController {
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    /**
     * Resolve a sub_type slug to property_type_id(s) or car_type_id(s)
     * e.g. 'villa_chalet' → [4], 'shop_office' → [6,7], 'wedding' → [2]
     */
    public static function resolveTypeIds($category, $subType) {
        if (!$subType) return [];
        $db = Database::getInstance();
        
        $table = ($category === 'properties') ? 'property_types' : 'car_types';
        
        // 1. Direct slug match
        $types = $db->fetchAll(
            "SELECT id FROM $table WHERE slug = ? AND is_active = 1",
            [$subType]
        );
        if (!empty($types)) {
            return array_column($types, 'id');
        }
        
        // 2. Compound slug: split by _ and match individual parts (e.g. shop_office → shop + office)
        $parts = explode('_', $subType);
        if (count($parts) > 1) {
            $placeholders = implode(',', array_fill(0, count($parts), '?'));
            $types = $db->fetchAll(
                "SELECT id FROM $table WHERE slug IN ($placeholders) AND is_active = 1",
                $parts
            );
            if (!empty($types)) {
                return array_column($types, 'id');
            }
        }
        
        return [];
    }
    
    /**
     * Build SQL condition for type_id matching
     * Returns [conditionString, paramsArray]
     */
    private static function buildTypeIdCondition($category, $subType, $prefix = 'p') {
        $typeIds = self::resolveTypeIds($category, $subType);
        $idColumn = ($category === 'properties') ? 'property_type_id' : 'car_type_id';
        
        if (!empty($typeIds)) {
            $placeholders = implode(',', array_fill(0, count($typeIds), '?'));
            $condition = " AND ({$prefix}.{$idColumn} IN ($placeholders) OR {$prefix}.{$idColumn} IS NULL)";
            return [$condition, $typeIds];
        }
        
        return ['', []];
    }
    
    public function mySubscriptions($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $status = $input['status'] ?? 'active';
        
        $where = "s.user_id = ?";
        $params = [$auth['user_id']];
        
        if ($status !== 'all') {
            if ($status === 'active') {
                $where .= " AND s.status = 'active' AND s.expires_at > NOW()";
            } else {
                $where .= " AND (s.status = ? OR s.expires_at <= NOW())";
                $params[] = $status;
            }
        }
        
        $sql = "SELECT s.*, 
                       p.name_ar as plan_name_ar, p.name_en as plan_name_en, p.name_he as plan_name_he,
                       p.category, p.plan_type, p.badge,
                       (SELECT COUNT(*) FROM properties WHERE subscription_id = s.id) as properties_count,
                       (SELECT COUNT(*) FROM cars WHERE subscription_id = s.id) as cars_count
                FROM subscriptions s
                LEFT JOIN plans p ON s.plan_id = p.id
                WHERE $where
                ORDER BY s.created_at DESC";
        
        $subscriptions = $this->db->fetchAll($sql, $params);
        
        foreach ($subscriptions as &$sub) {
            $sub['is_expired'] = strtotime($sub['expires_at']) < time();
            $sub['days_remaining'] = max(0, (int)((strtotime($sub['expires_at']) - time()) / 86400));
            
            if ($sub['is_unlimited']) {
                $sub['listings_remaining'] = 'unlimited';
            } else {
                $sub['listings_remaining'] = max(0, ($sub['listings_limit'] ?? 0) - ($sub['listings_used'] ?? 0));
            }
        }
        
        Response::success($subscriptions);
    }
    
    public function index($input) {
        return $this->mySubscriptions($input);
    }
    
    /**
     * Request a subscription plan (user requests, admin approves)
     */
    public function requestPlan($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $planId = $input['plan_id'] ?? null;
        if (!$planId) {
            Response::error('Plan ID is required', 400);
        }
        
        // Check if plan exists and is active
        $plan = $this->db->fetch("SELECT * FROM plans WHERE id = ? AND is_active = 1", [$planId]);
        if (!$plan) {
            Response::notFound('Plan not found');
        }
        
        // Check if user already has a pending request for this exact plan
        $existingRequest = $this->db->fetch(
            "SELECT sr.* FROM subscription_requests sr 
             WHERE sr.user_id = ? AND sr.status = 'pending' AND sr.plan_id = ?",
            [$auth['user_id'], $planId]
        );
        
        if ($existingRequest) {
            Response::error('You already have a pending request for this plan', 400);
        }
        
        // Create subscription request
        $requestId = $this->db->insert('subscription_requests', [
            'user_id' => $auth['user_id'],
            'plan_id' => $planId
        ]);
        
        Response::success([
            'id' => $requestId,
            'message' => 'Subscription request submitted successfully. Waiting for admin approval.'
        ], 201);
    }
    
    /**
     * Get user's subscription requests
     */
    public function myRequests($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $sql = "SELECT sr.*, 
                       p.name_ar as plan_name_ar, p.name_en as plan_name_en, p.name_he as plan_name_he,
                       p.category, p.plan_type, p.price, p.listings_count, p.is_unlimited, p.duration_days, p.badge
                FROM subscription_requests sr
                JOIN plans p ON sr.plan_id = p.id
                WHERE sr.user_id = ?
                ORDER BY sr.created_at DESC";
        
        $requests = $this->db->fetchAll($sql, [$auth['user_id']]);
        
        Response::success($requests);
    }
    
    /**
     * Cancel a pending subscription request
     */
    public function cancelRequest($id) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $request = $this->db->fetch(
            "SELECT * FROM subscription_requests WHERE id = ? AND user_id = ?",
            [$id, $auth['user_id']]
        );
        
        if (!$request) {
            Response::notFound('Request not found');
        }
        
        if ($request['status'] !== 'pending') {
            Response::error('Only pending requests can be cancelled', 400);
        }
        
        $this->db->delete('subscription_requests', 'id = ?', [$id]);
        
        Response::success(['message' => 'Request cancelled successfully']);
    }
    
    /**
     * Check if user can add a listing (has active subscription with remaining slots)
     */
    public function canAddListing($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $category = $input['category'] ?? null;
        if (!$category || !in_array($category, ['properties', 'cars'])) {
            Response::error('Valid category (properties/cars) is required', 400);
        }
        
        $result = $this->checkUserCanAddListing($auth['user_id'], $category);
        
        Response::success($result);
    }
    
    /**
     * Get active subscription for a category
     */
    public function getActiveSubscription($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $category = $input['category'] ?? null;
        if (!$category || !in_array($category, ['properties', 'cars'])) {
            Response::error('Valid category (properties/cars) is required', 400);
        }
        
        $subscription = $this->getActiveSubscriptionForUser($auth['user_id'], $category);
        
        if ($subscription) {
            Response::success($subscription);
        } else {
            Response::success(null);
        }
    }
    
    /**
     * Helper: Check if user can add listing
     */
    public static function checkUserCanAddListing($userId, $category, $subType = null) {
        $db = Database::getInstance();
        
        // Resolve sub_type slug to type IDs (e.g. 'villa_chalet' → [4], 'wedding' → [2])
        $typeIds = self::resolveTypeIds($category, $subType);
        $idColumn = ($category === 'properties') ? 'property_type_id' : 'car_type_id';
        
        // Build type condition for SQL
        $typeCondition = '';
        $typeParams = [];
        if (!empty($typeIds)) {
            $placeholders = implode(',', array_fill(0, count($typeIds), '?'));
            // Priority: exact type match first, then general (NULL type_id)
            $typeCondition = "CASE WHEN p.$idColumn IN ($placeholders) THEN 0 WHEN p.$idColumn IS NULL THEN 1 ELSE 2 END";
            $typeParams = $typeIds;
        } else {
            $typeCondition = "CASE WHEN p.$idColumn IS NULL THEN 0 ELSE 1 END";
        }
        
        $params = array_merge([$userId, $category, $category, $category], $typeParams);
        
        $subscription = $db->fetch(
            "SELECT s.*, p.name_ar, p.name_en, p.name_he, p.category as plan_category, p.badge,
                    p.property_type, p.car_usage_type, p.property_type_id, p.car_type_id,
                    p.duration_days as plan_duration_days
             FROM subscriptions s
             JOIN plans p ON s.plan_id = p.id
             WHERE s.user_id = ? 
               AND (p.category = ? OR p.category IS NULL OR s.category = ? OR s.category IS NULL)
               AND s.status = 'active' 
               AND s.expires_at > NOW()
               AND (s.is_unlimited = 1 OR s.listings_used < s.listings_limit)
             ORDER BY 
                $typeCondition,
                CASE WHEN p.category = ? THEN 0 ELSE 1 END,
                s.created_at DESC
             LIMIT 1",
            $params
        );
        
        // If subscription has specific type_id, verify it matches
        if ($subscription && !empty($typeIds)) {
            $planTypeId = $subscription[$idColumn] ?? null;
            if ($planTypeId !== null && !in_array($planTypeId, $typeIds)) {
                // This subscription is for a different type, look for a general one
                $generalSub = $db->fetch(
                    "SELECT s.*, p.name_ar, p.name_en, p.name_he, p.category as plan_category, p.badge,
                            p.property_type, p.car_usage_type, p.property_type_id, p.car_type_id
                     FROM subscriptions s
                     JOIN plans p ON s.plan_id = p.id
                     WHERE s.user_id = ? 
                       AND p.category = ?
                       AND p.$idColumn IS NULL
                       AND s.status = 'active' 
                       AND s.expires_at > NOW()
                       AND (s.is_unlimited = 1 OR s.listings_used < s.listings_limit)
                     ORDER BY s.created_at DESC
                     LIMIT 1",
                    [$userId, $category]
                );
                if ($generalSub) {
                    $subscription = $generalSub;
                } else {
                    return [
                        'can_add' => false,
                        'reason' => 'wrong_type',
                        'message_ar' => 'باقتك الحالية لا تشمل هذا النوع من الإعلانات.',
                        'message_en' => 'Your current subscription does not cover this listing type.',
                        'message_he' => 'המנוי הנוכחי שלך אינו מכסה סוג מודעה זה.',
                        'subscription' => null
                    ];
                }
            }
        }
        
        if (!$subscription) {
            return [
                'can_add' => false,
                'reason' => 'no_subscription',
                'message_ar' => 'ليس لديك اشتراك فعال. يرجى طلب باقة أولاً.',
                'message_en' => 'You do not have an active subscription. Please request a package first.',
                'message_he' => 'אין לך מנוי פעיל. אנא בקש חבילה קודם.',
                'subscription' => null
            ];
        }
        
        // Check if unlimited
        if ($subscription['is_unlimited']) {
            return [
                'can_add' => true,
                'reason' => 'unlimited',
                'listings_remaining' => 'unlimited',
                'subscription' => $subscription
            ];
        }
        
        // Check remaining listings
        $remaining = ($subscription['listings_limit'] ?? 0) - ($subscription['listings_used'] ?? 0);
        
        if ($remaining <= 0) {
            return [
                'can_add' => false,
                'reason' => 'limit_reached',
                'message_ar' => 'لقد استنفدت عدد الإعلانات المسموح في باقتك.',
                'message_en' => 'You have reached your listing limit.',
                'message_he' => 'הגעת למגבלת המודעות שלך.',
                'listings_remaining' => 0,
                'subscription' => $subscription
            ];
        }
        
        return [
            'can_add' => true,
            'reason' => 'has_slots',
            'listings_remaining' => $remaining,
            'subscription' => $subscription
        ];
    }
    
    /**
     * Helper: Get active subscription for user
     */
    public static function getActiveSubscriptionForUser($userId, $category) {
        $db = Database::getInstance();
        
        return $db->fetch(
            "SELECT s.*, p.name_ar, p.name_en, p.name_he, p.category as plan_category, p.badge, p.listings_count, p.is_unlimited as plan_unlimited
             FROM subscriptions s
             JOIN plans p ON s.plan_id = p.id
             WHERE s.user_id = ? 
               AND (p.category = ? OR p.category IS NULL OR s.category = ? OR s.category IS NULL)
               AND s.status = 'active' 
               AND s.expires_at > NOW()
             ORDER BY 
                CASE WHEN p.category = ? THEN 0 ELSE 1 END,
                s.created_at DESC
             LIMIT 1",
            [$userId, $category, $category, $category]
        );
    }
    
    /**
     * Helper: Increment listings used count
     */
    public static function incrementListingsUsed($subscriptionId) {
        $db = Database::getInstance();
        $db->query("UPDATE subscriptions SET listings_used = listings_used + 1 WHERE id = ?", [$subscriptionId]);
    }
    
    /**
     * Purchase a subscription (direct payment - Google Pay / Apple Pay)
     * TODO: Integrate real payment gateways
     */
    public function purchase($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $planId = $input['plan_id'] ?? null;
        $paymentMethod = $input['payment_method'] ?? 'test_payment';
        $status = $input['status'] ?? 'active';
        
        // Bank transfer details
        $senderName = $input['sender_name'] ?? null;
        $transferDate = $input['transfer_date'] ?? null;
        $transferReference = $input['transfer_reference'] ?? null;
        
        if (!$planId) {
            Response::error('Plan ID is required', 400);
        }
        
        // Check if plan exists and is active
        $plan = $this->db->fetch("SELECT * FROM plans WHERE id = ? AND is_active = 1", [$planId]);
        if (!$plan) {
            Response::notFound('Plan not found');
        }
        
        // Prevent purchasing welcome bonus plans
        if (!empty($plan['is_welcome_bonus'])) {
            Response::error('This plan is not available for purchase', 400);
        }
        
        // All purchases require admin approval
        $subscriptionStatus = 'pending_verification';
        $paymentStatus = 'pending';
        
        // Calculate expiry date
        $durationDays = $plan['duration_days'] ?? 30;
        $expiresAt = date('Y-m-d H:i:s', strtotime("+$durationDays days"));
        
        // Always create a new subscription for paid plans (don't extend welcome bonus)
        $subscriptionId = $this->db->insert('subscriptions', [
            'user_id' => $auth['user_id'],
            'plan_id' => $planId,
            'category' => $plan['category'],
            'status' => $subscriptionStatus,
            'listings_limit' => $plan['is_unlimited'] ? 999999 : ($plan['listings_count'] ?? 1),
            'listings_used' => 0,
            'is_unlimited' => $plan['is_unlimited'] ? 1 : 0,
            'expires_at' => $expiresAt,
            'payment_method' => $paymentMethod,
            'payment_reference' => $transferReference ?: (strtoupper($paymentMethod) . '_' . time() . '_' . $auth['user_id'])
        ]);
        
        // Log the payment
        $platform = $input['platform'] ?? 'web';
        $transactionId = $input['transaction_id'] ?? (strtoupper($paymentMethod) . '_' . uniqid());
        
        $paymentData = [
            'user_id' => $auth['user_id'],
            'subscription_id' => $subscriptionId,
            'plan_id' => $planId,
            'amount' => $plan['price'] ?? 0,
            'currency' => 'ILS',
            'platform' => $platform,
            'payment_method' => $paymentMethod,
            'status' => $paymentStatus,
            'transaction_id' => $transactionId
        ];
        
        // Add bank transfer details if applicable
        if ($paymentMethod === 'bank_transfer') {
            $paymentData['sender_name'] = $senderName;
            $paymentData['transfer_date'] = $transferDate;
            $paymentData['notes'] = $transferReference ? "Reference: $transferReference" : null;
        }
        
        $this->db->insert('payments', $paymentData);
        
        $message = ($paymentMethod === 'bank_transfer') 
            ? 'Bank transfer submitted. Pending verification.'
            : 'Subscription activated successfully';
        
        Response::success([
            'subscription_id' => $subscriptionId,
            'message' => $message,
            'status' => $subscriptionStatus,
            'expires_at' => $expiresAt
        ], 201);
    }
    
    /**
     * Get available subscriptions for adding a listing
     * Returns: free bonus (if unused), active subscriptions matching the listing type, and available plans to buy
     */
    public function availableForListing($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $category = $input['category'] ?? null; // properties or cars
        $subType = $input['sub_type'] ?? null; // property_type or car_usage_type
        
        if (!$category || !in_array($category, ['properties', 'cars'])) {
            Response::error('Category is required (properties or cars)', 400);
        }
        
        // Resolve sub_type slug to type IDs (e.g. 'villa_chalet' → [4], 'shop_office' → [6,7])
        $typeIds = self::resolveTypeIds($category, $subType);
        $idColumn = ($category === 'properties') ? 'property_type_id' : 'car_type_id';
        
        $result = [
            'free_bonus' => null,
            'active_subscriptions' => [],
            'available_plans' => []
        ];
        
        // 1. Check for unused free welcome bonus
        $freeBonus = $this->db->fetch(
            "SELECT s.*, p.name_ar, p.name_en, p.name_he, p.category, p.property_type, p.car_usage_type, p.property_type_id, p.car_type_id
             FROM subscriptions s
             JOIN plans p ON s.plan_id = p.id
             WHERE s.user_id = ? 
               AND p.is_welcome_bonus = 1
               AND s.status = 'active'
               AND s.expires_at > NOW()
               AND (s.is_unlimited = 1 OR s.listings_used < s.listings_limit)
               AND (p.category = ? OR p.category IS NULL)
             LIMIT 1",
            [$auth['user_id'], $category]
        );
        
        if ($freeBonus) {
            // Check if subtype matches via type_id (if specified in plan)
            $planTypeId = $freeBonus[$idColumn] ?? null;
            
            if ($planTypeId === null || empty($typeIds) || in_array($planTypeId, $typeIds)) {
                $freeBonus['listings_remaining'] = $freeBonus['is_unlimited'] 
                    ? 'unlimited' 
                    : max(0, ($freeBonus['listings_limit'] ?? 0) - ($freeBonus['listings_used'] ?? 0));
                $result['free_bonus'] = $freeBonus;
            }
        }
        
        // 2. Get active subscriptions matching category and type (excluding free bonus)
        list($typeCondition, $typeParams) = self::buildTypeIdCondition($category, $subType, 'p');
        $params = array_merge([$auth['user_id'], $category], $typeParams);
        
        $activeSubscriptions = $this->db->fetchAll(
            "SELECT s.*, p.name_ar, p.name_en, p.name_he, p.category, p.property_type, p.car_usage_type, p.property_type_id, p.car_type_id, p.badge
             FROM subscriptions s
             JOIN plans p ON s.plan_id = p.id
             WHERE s.user_id = ? 
               AND p.category = ?
               AND (p.is_welcome_bonus = 0 OR p.is_welcome_bonus IS NULL)
               AND s.status = 'active'
               AND s.expires_at > NOW()
               AND (s.is_unlimited = 1 OR s.listings_used < s.listings_limit)
               $typeCondition
             ORDER BY s.created_at DESC",
            $params
        );
        
        foreach ($activeSubscriptions as &$sub) {
            $sub['listings_remaining'] = $sub['is_unlimited'] 
                ? 'unlimited' 
                : max(0, ($sub['listings_limit'] ?? 0) - ($sub['listings_used'] ?? 0));
        }
        $result['active_subscriptions'] = $activeSubscriptions;
        
        // 3. Get available plans to purchase (matching category and type)
        $planParams = [$category];
        $planTypeCondition = "";
        
        if (!empty($typeIds)) {
            $placeholders = implode(',', array_fill(0, count($typeIds), '?'));
            $planTypeCondition = " AND ($idColumn IN ($placeholders) OR $idColumn IS NULL)";
            $planParams = array_merge($planParams, $typeIds);
        }
        
        $availablePlans = $this->db->fetchAll(
            "SELECT * FROM plans 
             WHERE is_active = 1 
               AND (is_welcome_bonus = 0 OR is_welcome_bonus IS NULL)
               AND category = ?
               $planTypeCondition
             ORDER BY sort_order, price",
            $planParams
        );
        
        $result['available_plans'] = $availablePlans;
        
        Response::success($result);
    }
    
    /**
     * Get subscription warnings (expiring soon or low listings)
     */
    public function warnings() {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $warnings = [];
        $daysThreshold = 3; // Warn if less than 3 days remaining
        $listingsThreshold = 2; // Warn if 2 or less listings remaining
        
        // Get active subscriptions
        $sql = "SELECT s.*, 
                       p.name_ar as plan_name_ar, p.name_en as plan_name_en, p.name_he as plan_name_he,
                       p.category, p.plan_type
                FROM subscriptions s
                LEFT JOIN plans p ON s.plan_id = p.id
                WHERE s.user_id = ? AND s.status = 'active' AND s.expires_at > NOW()";
        
        $subscriptions = $this->db->fetchAll($sql, [$auth['user_id']]);
        
        foreach ($subscriptions as $sub) {
            $daysRemaining = max(0, (int)((strtotime($sub['expires_at']) - time()) / 86400));
            $listingsRemaining = $sub['is_unlimited'] ? 999999 : max(0, ($sub['listings_limit'] ?? 0) - ($sub['listings_used'] ?? 0));
            
            // Check for time warning
            if ($daysRemaining <= $daysThreshold && $daysRemaining > 0) {
                $warnings[] = [
                    'type' => 'expiring_soon',
                    'subscription_id' => $sub['id'],
                    'plan_name_ar' => $sub['plan_name_ar'],
                    'plan_name_en' => $sub['plan_name_en'],
                    'plan_name_he' => $sub['plan_name_he'],
                    'category' => $sub['category'],
                    'days_remaining' => $daysRemaining,
                    'expires_at' => $sub['expires_at'],
                    'severity' => $daysRemaining <= 1 ? 'high' : 'medium'
                ];
            }
            
            // Check for listings warning (only for non-unlimited)
            if (!$sub['is_unlimited'] && $listingsRemaining <= $listingsThreshold && $listingsRemaining >= 0) {
                $warnings[] = [
                    'type' => 'low_listings',
                    'subscription_id' => $sub['id'],
                    'plan_name_ar' => $sub['plan_name_ar'],
                    'plan_name_en' => $sub['plan_name_en'],
                    'plan_name_he' => $sub['plan_name_he'],
                    'category' => $sub['category'],
                    'listings_remaining' => $listingsRemaining,
                    'listings_limit' => $sub['listings_limit'],
                    'severity' => $listingsRemaining <= 1 ? 'high' : 'medium'
                ];
            }
        }
        
        Response::success([
            'has_warnings' => !empty($warnings),
            'warnings' => $warnings
        ]);
    }
    
    /**
     * Verify Apple In-App Purchase
     * Validates receipt with Apple and activates subscription
     */
    public function verifyApplePurchase($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $receiptData = $input['receipt_data'] ?? null;
        $productId = $input['product_id'] ?? null;
        $transactionId = $input['transaction_id'] ?? null;
        $planId = $input['plan_id'] ?? null;
        
        if (!$receiptData) {
            Response::error('Receipt data is required', 400);
        }
        
        if (!$productId) {
            Response::error('Product ID is required', 400);
        }
        
        // Find plan by iOS product ID
        $plan = null;
        if ($planId) {
            $plan = $this->db->fetch(
                "SELECT * FROM plans WHERE id = ? AND is_active = 1",
                [$planId]
            );
        }
        
        if (!$plan) {
            $plan = $this->db->fetch(
                "SELECT * FROM plans WHERE ios_product_id = ? AND is_active = 1",
                [$productId]
            );
        }
        
        if (!$plan) {
            Response::error('Plan not found for product: ' . $productId, 404);
        }
        
        // Check for duplicate transaction
        $existingPayment = $this->db->fetch(
            "SELECT * FROM payments WHERE transaction_id = ? AND status = 'completed'",
            [$transactionId]
        );
        
        if ($existingPayment) {
            Response::error('This transaction has already been processed', 400);
        }
        
        // Verify with Apple
        require_once __DIR__ . '/../../helpers/AppleReceiptVerifier.php';
        $verifier = new AppleReceiptVerifier();
        $result = $verifier->validatePurchase($receiptData, $productId, $transactionId);
        
        // Initialize PaymentLogger
        require_once __DIR__ . '/../../helpers/PaymentLogger.php';
        $paymentLogger = new PaymentLogger();
        
        if (!$result['success']) {
            // Log failed verification with full details
            $paymentLogger->logPayment([
                'user_id' => $auth['user_id'],
                'plan_id' => $plan['id'],
                'amount' => $plan['price'] ?? 0,
                'currency' => 'ILS',
                'platform' => 'ios',
                'payment_method' => 'apple_iap',
                'environment' => 'production',
                'status' => 'failed',
                'transaction_id' => $transactionId,
                'product_id' => $productId,
                'receipt_data' => $receiptData,
                'error_code' => $result['error_code'] ?? 'VERIFICATION_FAILED',
                'error_message' => $result['error'] ?? 'Unknown error',
                'notes' => 'Apple receipt verification failed'
            ]);
            
            Response::error('Receipt verification failed: ' . ($result['error'] ?? 'Unknown error'), 400);
        }
        
        $verificationData = $result['data'];
        $isSandbox = ($verificationData['environment'] ?? '') === 'Sandbox';
        
        // Calculate expiry date
        $durationDays = $plan['duration_days'] ?? 30;
        $expiresAt = date('Y-m-d H:i:s', strtotime("+$durationDays days"));
        
        // Create subscription
        $subscriptionId = $this->db->insert('subscriptions', [
            'user_id' => $auth['user_id'],
            'plan_id' => $plan['id'],
            'category' => $plan['category'],
            'status' => 'active',
            'listings_limit' => $plan['is_unlimited'] ? 999999 : ($plan['listings_count'] ?? 1),
            'listings_used' => 0,
            'is_unlimited' => $plan['is_unlimited'] ? 1 : 0,
            'expires_at' => $expiresAt,
            'payment_method' => 'apple_iap',
            'payment_reference' => $verificationData['transaction_id'] ?? $transactionId
        ]);
        
        // Log successful payment with full details
        $paymentResult = $paymentLogger->logPayment([
            'user_id' => $auth['user_id'],
            'subscription_id' => $subscriptionId,
            'plan_id' => $plan['id'],
            'amount' => $plan['price'] ?? 0,
            'currency' => 'ILS',
            'platform' => 'ios',
            'payment_method' => 'apple_iap',
            'environment' => $isSandbox ? 'sandbox' : 'production',
            'status' => 'completed',
            'transaction_id' => $verificationData['transaction_id'] ?? $transactionId,
            'store_transaction_id' => $verificationData['original_transaction_id'] ?? null,
            'product_id' => $productId,
            'receipt_data' => $receiptData,
            'notes' => $isSandbox ? 'Sandbox purchase' : 'Production purchase'
        ]);
        
        // Create invoice
        $paymentLogger->createInvoice($paymentResult['payment_id']);
        
        // Send notification
        require_once __DIR__ . '/NotificationController.php';
        NotificationController::send($auth['user_id'], 'subscription_approved', [
            'plan_name' => $plan['name_ar'] ?? ''
        ]);
        
        Response::success([
            'subscription_id' => $subscriptionId,
            'invoice_number' => $paymentResult['invoice_number'],
            'message' => 'Purchase verified and subscription activated',
            'status' => 'active',
            'expires_at' => $expiresAt,
            'is_sandbox' => $isSandbox
        ], 201);
    }
    
    /**
     * Verify Google Play In-App Purchase
     * Validates purchase with Google and activates subscription
     */
    public function verifyGooglePurchase($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $purchaseToken = $input['purchase_token'] ?? null;
        $productId = $input['product_id'] ?? null;
        $transactionId = $input['transaction_id'] ?? null;
        $planId = $input['plan_id'] ?? null;
        
        if (!$purchaseToken) {
            Response::error('Purchase token is required', 400);
        }
        
        if (!$productId) {
            Response::error('Product ID is required', 400);
        }
        
        // Find plan by Android product ID
        $plan = null;
        if ($planId) {
            $plan = $this->db->fetch(
                "SELECT * FROM plans WHERE id = ? AND is_active = 1",
                [$planId]
            );
        }
        
        if (!$plan) {
            $plan = $this->db->fetch(
                "SELECT * FROM plans WHERE android_product_id = ? AND is_active = 1",
                [$productId]
            );
        }
        
        if (!$plan) {
            Response::error('Plan not found for product: ' . $productId, 404);
        }
        
        // Check for duplicate transaction
        $existingPayment = $this->db->fetch(
            "SELECT * FROM payments WHERE transaction_id = ? AND status = 'completed'",
            [$transactionId]
        );
        
        if ($existingPayment) {
            Response::error('This transaction has already been processed', 400);
        }
        
        // Verify with Google
        require_once __DIR__ . '/../../helpers/GooglePlayVerifier.php';
        $verifier = new GooglePlayVerifier();
        $result = $verifier->verifyPurchase($productId, $purchaseToken);
        
        // Initialize PaymentLogger
        require_once __DIR__ . '/../../helpers/PaymentLogger.php';
        $paymentLogger = new PaymentLogger();
        
        if (!$result['success']) {
            // Log failed verification with full details
            $paymentLogger->logPayment([
                'user_id' => $auth['user_id'],
                'plan_id' => $plan['id'],
                'amount' => $plan['price'] ?? 0,
                'currency' => 'ILS',
                'platform' => 'android',
                'payment_method' => 'google_iap',
                'environment' => 'production',
                'status' => 'failed',
                'transaction_id' => $transactionId,
                'product_id' => $productId,
                'error_code' => $result['error_code'] ?? 'VERIFICATION_FAILED',
                'error_message' => $result['error'] ?? 'Unknown error',
                'notes' => 'Google Play verification failed'
            ]);
            
            Response::error('Purchase verification failed: ' . ($result['error'] ?? 'Unknown error'), 400);
        }
        
        $verificationData = $result['data'];
        $isSandbox = ($verificationData['environment'] ?? '') === 'sandbox';
        
        // Calculate expiry date
        $durationDays = $plan['duration_days'] ?? 30;
        $expiresAt = date('Y-m-d H:i:s', strtotime("+$durationDays days"));
        
        // Create subscription
        $subscriptionId = $this->db->insert('subscriptions', [
            'user_id' => $auth['user_id'],
            'plan_id' => $plan['id'],
            'category' => $plan['category'],
            'status' => 'active',
            'listings_limit' => $plan['is_unlimited'] ? 999999 : ($plan['listings_count'] ?? 1),
            'listings_used' => 0,
            'is_unlimited' => $plan['is_unlimited'] ? 1 : 0,
            'expires_at' => $expiresAt,
            'payment_method' => 'google_iap',
            'payment_reference' => $verificationData['order_id'] ?? $transactionId
        ]);
        
        // Log successful payment with full details
        $paymentResult = $paymentLogger->logPayment([
            'user_id' => $auth['user_id'],
            'subscription_id' => $subscriptionId,
            'plan_id' => $plan['id'],
            'amount' => $plan['price'] ?? 0,
            'currency' => 'ILS',
            'platform' => 'android',
            'payment_method' => 'google_iap',
            'environment' => $isSandbox ? 'sandbox' : 'production',
            'status' => 'completed',
            'transaction_id' => $verificationData['order_id'] ?? $transactionId,
            'store_transaction_id' => $purchaseToken,
            'product_id' => $productId,
            'notes' => $isSandbox ? 'Sandbox purchase' : 'Production purchase'
        ]);
        
        // Create invoice
        $paymentLogger->createInvoice($paymentResult['payment_id']);
        
        // Acknowledge the purchase with Google
        $verifier->acknowledgePurchase($productId, $purchaseToken);
        
        // Send notification
        require_once __DIR__ . '/NotificationController.php';
        NotificationController::send($auth['user_id'], 'subscription_approved', [
            'plan_name' => $plan['name_ar'] ?? ''
        ]);
        
        Response::success([
            'subscription_id' => $subscriptionId,
            'invoice_number' => $paymentResult['invoice_number'],
            'message' => 'Purchase verified and subscription activated',
            'status' => 'active',
            'expires_at' => $expiresAt,
            'is_sandbox' => $isSandbox
        ], 201);
    }
}
