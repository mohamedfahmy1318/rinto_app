<?php
/**
 * Combined Listing Controller (Properties + Cars)
 */

class ListingController {
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    public function index($input) {
        $tab = $input['tab'] ?? 'properties';
        $page = max(1, (int)($input['page'] ?? 1));
        $perPage = min(MAX_PAGE_SIZE, max(1, (int)($input['per_page'] ?? DEFAULT_PAGE_SIZE)));
        $offset = ($page - 1) * $perPage;
        
        if ($tab === 'cars') {
            return $this->getCars($input, $page, $perPage, $offset);
        }
        
        return $this->getProperties($input, $page, $perPage, $offset);
    }
    
    private function getProperties($input, $page, $perPage, $offset) {
        $where = "p.status = 'active' AND (p.expires_at IS NULL OR p.expires_at > NOW())";
        $params = [];
        
        if (!empty($input['region_id'])) {
            $where .= " AND p.region_id = ?";
            $params[] = $input['region_id'];
        }
        
        if (!empty($input['city_id'])) {
            $where .= " AND p.city_id = ?";
            $params[] = $input['city_id'];
        }
        
        if (!empty($input['type'])) {
            $where .= " AND p.property_type = ?";
            $params[] = $input['type'];
        }
        
        if (!empty($input['price_min'])) {
            $where .= " AND (p.price >= ? OR p.price_from >= ?)";
            $params[] = $input['price_min'];
            $params[] = $input['price_min'];
        }
        
        if (!empty($input['price_max'])) {
            $where .= " AND (p.price <= ? OR p.price_to <= ?)";
            $params[] = $input['price_max'];
            $params[] = $input['price_max'];
        }
        
        if (!empty($input['search'])) {
            $search = '%' . $input['search'] . '%';
            $where .= " AND (p.title LIKE ? OR p.address_text LIKE ?)";
            $params[] = $search;
            $params[] = $search;
        }
        
        $countSql = "SELECT COUNT(*) as total FROM properties p WHERE $where";
        $total = (int)$this->db->fetch($countSql, $params)['total'];
        
        $sql = "SELECT p.id, p.title, p.title_ar, p.title_en, p.title_he,
                       p.property_type, p.price_type, p.price, p.price_from, p.price_to,
                       p.currency, p.bedrooms, p.area_m2, p.created_at, p.user_id,
                       p.status, p.is_rented,
                       r.name_ar as region_name_ar, r.name_en as region_name_en, r.name_he as region_name_he,
                       c.name_ar as city_name_ar, c.name_en as city_name_en, c.name_he as city_name_he,
                       'property' as listing_type,
                       pl.badge as badge
                FROM properties p
                LEFT JOIN regions r ON p.region_id = r.id
                LEFT JOIN cities c ON p.city_id = c.id
                LEFT JOIN subscriptions s ON p.subscription_id = s.id
                LEFT JOIN plans pl ON s.plan_id = pl.id
                WHERE $where
                ORDER BY 
                    CASE WHEN pl.badge = 'gold' THEN 0 
                         WHEN pl.badge = 'silver' THEN 1 
                         WHEN pl.badge = 'bronze' THEN 2 
                         ELSE 3 END,
                    RAND(),
                    p.created_at DESC
                LIMIT $perPage OFFSET $offset";
        
        $listings = $this->db->fetchAll($sql, $params);
        
        // Apply fair distribution algorithm for featured listings
        $listings = $this->applyFairFeaturedDistribution($listings, 5);
        
        foreach ($listings as &$listing) {
            $media = $this->db->fetch(
                "SELECT file_path FROM property_media WHERE property_id = ? AND media_type = 'image' ORDER BY sort_order LIMIT 1",
                [$listing['id']]
            );
            $listing['thumbnail'] = $media ? UPLOAD_URL . $media['file_path'] : null;
            $listing['is_featured'] = !empty($listing['badge']);
            unset($listing['user_id']); // Don't expose user_id
        }
        
        $this->addFavoriteStatus($listings, 'property');
        
        Response::paginated($listings, $total, $page, $perPage);
    }
    
    private function getCars($input, $page, $perPage, $offset) {
        $where = "c.status = 'active' AND (c.expires_at IS NULL OR c.expires_at > NOW())";
        $params = [];
        
        if (!empty($input['region_id'])) {
            $where .= " AND c.region_id = ?";
            $params[] = $input['region_id'];
        }
        
        if (!empty($input['city_id'])) {
            $where .= " AND c.city_id = ?";
            $params[] = $input['city_id'];
        }
        
        if (!empty($input['type'])) {
            $where .= " AND c.usage_type = ?";
            $params[] = $input['type'];
        }
        
        if (!empty($input['price_min'])) {
            $where .= " AND (c.price >= ? OR c.price_from >= ?)";
            $params[] = $input['price_min'];
            $params[] = $input['price_min'];
        }
        
        if (!empty($input['price_max'])) {
            $where .= " AND (c.price <= ? OR c.price_to <= ?)";
            $params[] = $input['price_max'];
            $params[] = $input['price_max'];
        }
        
        if (!empty($input['search'])) {
            $search = '%' . $input['search'] . '%';
            $where .= " AND (c.title LIKE ? OR c.model LIKE ?)";
            $params[] = $search;
            $params[] = $search;
        }
        
        $countSql = "SELECT COUNT(*) as total FROM cars c WHERE $where";
        $total = (int)$this->db->fetch($countSql, $params)['total'];
        
        $sql = "SELECT c.id, c.title, c.title_ar, c.title_en, c.title_he,
                       c.usage_type, c.model, c.model_ar, c.model_en, c.model_he,
                       c.price_type, c.price, c.price_from, c.price_to,
                       c.currency, c.gearbox, c.with_driver, c.created_at, c.user_id,
                       c.status, c.is_rented,
                       r.name_ar as region_name_ar, r.name_en as region_name_en, r.name_he as region_name_he,
                       ci.name_ar as city_name_ar, ci.name_en as city_name_en, ci.name_he as city_name_he,
                       'car' as listing_type,
                       pl.badge as badge
                FROM cars c
                LEFT JOIN regions r ON c.region_id = r.id
                LEFT JOIN cities ci ON c.city_id = ci.id
                LEFT JOIN subscriptions s ON c.subscription_id = s.id
                LEFT JOIN plans pl ON s.plan_id = pl.id
                WHERE $where
                ORDER BY 
                    CASE WHEN pl.badge = 'gold' THEN 0 
                         WHEN pl.badge = 'silver' THEN 1 
                         WHEN pl.badge = 'bronze' THEN 2 
                         ELSE 3 END,
                    RAND(),
                    c.created_at DESC
                LIMIT $perPage OFFSET $offset";
        
        $listings = $this->db->fetchAll($sql, $params);
        
        // Apply fair distribution algorithm for featured listings
        $listings = $this->applyFairFeaturedDistribution($listings, 5);
        
        foreach ($listings as &$listing) {
            $media = $this->db->fetch(
                "SELECT file_path FROM car_media WHERE car_id = ? AND media_type = 'image' ORDER BY sort_order LIMIT 1",
                [$listing['id']]
            );
            $listing['thumbnail'] = $media ? UPLOAD_URL . $media['file_path'] : null;
            $listing['is_featured'] = !empty($listing['badge']);
            unset($listing['user_id']); // Don't expose user_id
        }
        
        $this->addFavoriteStatus($listings, 'car');
        
        Response::paginated($listings, $total, $page, $perPage);
    }
    
    private function addFavoriteStatus(&$listings, $type) {
        $auth = JWT::authenticate();
        if ($auth) {
            $favoriteIds = $this->db->fetchAll(
                "SELECT listing_id FROM favorites WHERE user_id = ? AND listing_type = ?",
                [$auth['user_id'], $type]
            );
            $favoriteIds = array_column($favoriteIds, 'listing_id');
            
            foreach ($listings as &$listing) {
                $listing['is_favorite'] = in_array($listing['id'], $favoriteIds);
            }
        }
    }
    
    /**
     * Apply fair distribution algorithm for featured listings
     * - Max 5 featured listings per user
     * - Round-robin distribution between advertisers
     * - Featured listings appear first, then regular ones
     */
    private function applyFairFeaturedDistribution($listings, $maxPerUser = 5) {
        if (empty($listings)) {
            return $listings;
        }
        
        // Separate featured and regular listings
        $featured = [];
        $regular = [];
        
        foreach ($listings as $listing) {
            if (!empty($listing['badge'])) {
                $featured[] = $listing;
            } else {
                $regular[] = $listing;
            }
        }
        
        if (empty($featured)) {
            return $listings;
        }
        
        // Group featured by user_id
        $byUser = [];
        foreach ($featured as $listing) {
            $userId = $listing['user_id'] ?? 0;
            if (!isset($byUser[$userId])) {
                $byUser[$userId] = [];
            }
            $byUser[$userId][] = $listing;
        }
        
        // Apply max per user limit and shuffle each user's listings
        foreach ($byUser as $userId => &$userListings) {
            shuffle($userListings);
            $byUser[$userId] = array_slice($userListings, 0, $maxPerUser);
        }
        
        // Round-robin distribution: take one from each user alternately
        $fairFeatured = [];
        $hasMore = true;
        $index = 0;
        
        while ($hasMore) {
            $hasMore = false;
            foreach ($byUser as $userId => &$userListings) {
                if (isset($userListings[$index])) {
                    $fairFeatured[] = $userListings[$index];
                    $hasMore = true;
                }
            }
            $index++;
        }
        
        // Combine: fair featured first, then regular
        return array_merge($fairFeatured, $regular);
    }
    
    public function show($id) {
        // This is handled by PropertyController or CarController based on type parameter
        Response::notFound('Please use /properties/{id} or /cars/{id}');
    }
    
    public function pause($id) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
        $type = $input['type'] ?? 'property';
        $table = $type === 'car' ? 'cars' : 'properties';
        
        $listing = $this->db->fetch("SELECT * FROM $table WHERE id = ?", [$id]);
        if (!$listing) {
            Response::notFound('Listing not found');
        }
        
        if ($listing['user_id'] != $auth['user_id']) {
            Response::forbidden();
        }
        
        if ($listing['status'] !== 'active') {
            Response::error('Can only pause active listings', 400);
        }
        
        $this->db->update($table, ['status' => 'paused'], 'id = ?', [$id]);
        
        Response::success(null, 'Listing paused');
    }
    
    public function resume($id) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
        $type = $input['type'] ?? 'property';
        $table = $type === 'car' ? 'cars' : 'properties';
        
        $listing = $this->db->fetch("SELECT * FROM $table WHERE id = ?", [$id]);
        if (!$listing) {
            Response::notFound('Listing not found');
        }
        
        if ($listing['user_id'] != $auth['user_id']) {
            Response::forbidden();
        }
        
        if ($listing['status'] !== 'paused') {
            Response::error('Can only resume paused listings', 400);
        }
        
        // Check if not expired
        if ($listing['expires_at'] && strtotime($listing['expires_at']) < time()) {
            Response::error('Listing has expired. Please renew.', 400);
        }
        
        $this->db->update($table, ['status' => 'active'], 'id = ?', [$id]);
        
        Response::success(null, 'Listing resumed');
    }
    
    public function renew($id, $input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $type = $input['type'] ?? 'property';
        $table = $type === 'car' ? 'cars' : 'properties';
        
        $listing = $this->db->fetch("SELECT * FROM $table WHERE id = ?", [$id]);
        if (!$listing) {
            Response::notFound('Listing not found');
        }
        
        if ($listing['user_id'] != $auth['user_id']) {
            Response::forbidden();
        }
        
        if (!in_array($listing['status'], ['expired', 'paused'])) {
            Response::error('Can only renew expired or paused listings', 400);
        }
        
        // Need to select a new plan and pay
        Response::success([
            'listing_id' => $id,
            'type' => $type,
            'requires_payment' => true,
            'message' => 'Please select a plan to renew this listing'
        ]);
    }
    
    /**
     * Republish an expired listing using active subscription
     */
    public function republish($id, $input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $type = $input['type'] ?? 'property';
        $table = $type === 'car' ? 'cars' : 'properties';
        $category = $type === 'car' ? 'cars' : 'properties';
        
        $listing = $this->db->fetch("SELECT * FROM $table WHERE id = ?", [$id]);
        if (!$listing) {
            Response::notFound('Listing not found');
        }
        
        if ($listing['user_id'] != $auth['user_id']) {
            Response::forbidden();
        }
        
        // Check if listing is expired (by date, not status)
        $isExpired = $listing['expires_at'] && strtotime($listing['expires_at']) < time();
        if (!$isExpired && $listing['status'] === 'active') {
            Response::error('Listing is still active', 400);
        }
        
        // Check if user has active subscription with available slots
        require_once __DIR__ . '/SubscriptionController.php';
        $subType = ($type === 'car') ? ($listing['usage_type'] ?? null) : ($listing['property_type'] ?? null);
        $subscriptionCheck = SubscriptionController::checkUserCanAddListing($auth['user_id'], $category, $subType);
        
        if (!$subscriptionCheck['can_add']) {
            Response::error($subscriptionCheck['message_en'], 403, [
                'reason' => $subscriptionCheck['reason'],
                'message_ar' => $subscriptionCheck['message_ar'],
                'message_he' => $subscriptionCheck['message_he']
            ]);
        }
        
        $activeSubscription = $subscriptionCheck['subscription'];
        
        // Calculate new expiry based on subscription's expiry date
        $newExpiresAt = $activeSubscription['expires_at'];
        
        // Update listing
        $this->db->update($table, [
            'status' => 'active',
            'subscription_id' => $activeSubscription['id'],
            'expires_at' => $newExpiresAt
        ], 'id = ?', [$id]);
        
        // Increment listings used in subscription
        SubscriptionController::incrementListingsUsed($activeSubscription['id']);
        
        $updatedListing = $this->db->fetch("SELECT * FROM $table WHERE id = ?", [$id]);
        
        Response::success([
            'listing' => $updatedListing,
            'new_expires_at' => $newExpiresAt,
            'message_ar' => 'تم إعادة نشر الإعلان بنجاح',
            'message_en' => 'Listing republished successfully',
            'message_he' => 'המודעה פורסמה מחדש בהצלחה'
        ]);
    }
    
    public function delete($id) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
        $type = $input['type'] ?? 'property';
        
        if ($type === 'car') {
            require_once __DIR__ . '/CarController.php';
            $controller = new CarController();
            $controller->delete($id);
        } else {
            require_once __DIR__ . '/PropertyController.php';
            $controller = new PropertyController();
            $controller->delete($id);
        }
    }
    
    /**
     * Toggle rental status (mark as rented/available)
     */
    public function toggleRented($id, $input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $type = $input['type'] ?? 'property';
        $table = $type === 'car' ? 'cars' : 'properties';
        
        $listing = $this->db->fetch("SELECT * FROM $table WHERE id = ?", [$id]);
        if (!$listing) {
            Response::notFound('Listing not found');
        }
        
        if ($listing['user_id'] != $auth['user_id']) {
            Response::forbidden();
        }
        
        // Only active listings can be marked as rented
        if ($listing['status'] !== 'active') {
            Response::error('Only active listings can be marked as rented', 400);
        }
        
        $isRented = isset($input['is_rented']) ? ($input['is_rented'] ? 1 : 0) : (($listing['is_rented'] ?? 0) ? 0 : 1);
        
        $this->db->update($table, ['is_rented' => $isRented], 'id = ?', [$id]);
        
        $statusText = $isRented ? 'rented' : 'available';
        
        Response::success([
            'is_rented' => (bool)$isRented,
            'message_ar' => $isRented ? 'تم تحديد الإعلان كمؤجر' : 'تم تحديد الإعلان كمتاح',
            'message_en' => $isRented ? 'Listing marked as rented' : 'Listing marked as available',
            'message_he' => $isRented ? 'המודעה סומנה כמושכרת' : 'המודעה סומנה כזמינה'
        ]);
    }
}
