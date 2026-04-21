<?php
/**
 * Property Controller
 */

class PropertyController {
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    public function index($input) {
        $page = max(1, (int)($input['page'] ?? 1));
        $perPage = min(MAX_PAGE_SIZE, max(1, (int)($input['per_page'] ?? DEFAULT_PAGE_SIZE)));
        $offset = ($page - 1) * $perPage;
        
        $where = "p.status = 'active' AND (p.expires_at IS NULL OR p.expires_at > NOW())";
        $params = [];
        
        // Filters
        if (!empty($input['region_id'])) {
            $where .= " AND p.region_id = ?";
            $params[] = $input['region_id'];
        }
        
        if (!empty($input['city_id'])) {
            $where .= " AND p.city_id = ?";
            $params[] = $input['city_id'];
        }
        
        if (!empty($input['property_type'])) {
            $where .= " AND p.property_type = ?";
            $params[] = $input['property_type'];
        }
        
        if (!empty($input['price_min'])) {
            $where .= " AND (p.price >= ? OR p.price_from >= ? OR p.price_daily >= ? OR p.price_weekly >= ? OR p.price_monthly >= ?)";
            $params[] = $input['price_min'];
            $params[] = $input['price_min'];
            $params[] = $input['price_min'];
            $params[] = $input['price_min'];
            $params[] = $input['price_min'];
        }
        
        if (!empty($input['price_max'])) {
            $where .= " AND (p.price <= ? OR p.price_to <= ? OR p.price_daily <= ? OR p.price_weekly <= ? OR p.price_monthly <= ?)";
            $params[] = $input['price_max'];
            $params[] = $input['price_max'];
            $params[] = $input['price_max'];
            $params[] = $input['price_max'];
            $params[] = $input['price_max'];
        }
        
        if (!empty($input['bedrooms'])) {
            $where .= " AND p.bedrooms >= ?";
            $params[] = $input['bedrooms'];
        }
        
        if (!empty($input['search'])) {
            $search = '%' . $input['search'] . '%';
            $where .= " AND (p.title LIKE ? OR p.address_text LIKE ? OR p.bio LIKE ?)";
            $params[] = $search;
            $params[] = $search;
            $params[] = $search;
        }
        
        $countSql = "SELECT COUNT(*) as total FROM properties p WHERE $where";
        $total = (int)$this->db->fetch($countSql, $params)['total'];
        
        $sql = "SELECT p.*, 
                       r.name_ar as region_name_ar, r.name_en as region_name_en, r.name_he as region_name_he,
                       c.name_ar as city_name_ar, c.name_en as city_name_en, c.name_he as city_name_he,
                       u.name as owner_name, u.is_trusted as owner_is_trusted,
                       pl.badge as badge,
                       COALESCE(p.is_trusted, pl.is_trusted_advertiser, 0) as is_trusted
                FROM properties p
                LEFT JOIN regions r ON p.region_id = r.id
                LEFT JOIN cities c ON p.city_id = c.id
                LEFT JOIN users u ON p.user_id = u.id
                LEFT JOIN subscriptions s ON p.subscription_id = s.id
                LEFT JOIN plans pl ON s.plan_id = pl.id
                WHERE $where
                ORDER BY 
                    CASE WHEN COALESCE(p.is_trusted, pl.is_trusted_advertiser, 0) = 1 THEN 0 ELSE 1 END,
                    CASE WHEN pl.badge = 'gold' THEN 0 
                         WHEN pl.badge = 'silver' THEN 1 
                         WHEN pl.badge = 'bronze' THEN 2 
                         ELSE 3 END,
                    p.created_at DESC,
                    p.id DESC
                LIMIT $perPage OFFSET $offset";
        
        $properties = $this->db->fetchAll($sql, $params);
        
        // Get user language preference from request
        $userLang = $input['lang'] ?? 'ar';
        
        // Get first image for each property
        foreach ($properties as &$property) {
            $media = $this->db->fetch(
                "SELECT file_path FROM property_media WHERE property_id = ? AND media_type = 'image' ORDER BY sort_order LIMIT 1",
                [$property['id']]
            );
            $property['thumbnail'] = $media ? UPLOAD_URL . $media['file_path'] : null;
            $property['type'] = 'property';
            
            // Return localized title and bio based on user language
            $property['title_localized'] = $property["title_{$userLang}"] ?? $property['title_ar'] ?? $property['title'];
            $property['bio_localized'] = $property["bio_{$userLang}"] ?? $property['bio_ar'] ?? $property['bio'];
        }
        
        // Check favorites if user is authenticated
        $auth = JWT::authenticate();
        if ($auth) {
            $favoriteIds = $this->db->fetchAll(
                "SELECT listing_id FROM favorites WHERE user_id = ? AND listing_type = 'property'",
                [$auth['user_id']]
            );
            $favoriteIds = array_column($favoriteIds, 'listing_id');
            
            foreach ($properties as &$property) {
                $property['is_favorite'] = in_array($property['id'], $favoriteIds);
            }
        }
        
        Response::paginated($properties, $total, $page, $perPage);
    }
    
    public function show($id) {
        $sql = "SELECT p.*, 
                       r.name_ar as region_name_ar, r.name_en as region_name_en, r.name_he as region_name_he,
                       c.name_ar as city_name_ar, c.name_en as city_name_en, c.name_he as city_name_he,
                       u.id as owner_id, u.name as owner_name, u.company_name as owner_company,
                       u.phone as owner_phone, u.is_trusted as owner_is_trusted, u.profile_image as owner_image
                FROM properties p
                LEFT JOIN regions r ON p.region_id = r.id
                LEFT JOIN cities c ON p.city_id = c.id
                LEFT JOIN users u ON p.user_id = u.id
                WHERE p.id = ?";
        
        $property = $this->db->fetch($sql, [$id]);
        
        if (!$property) {
            Response::notFound('Property not found');
        }
        
        // Only show active (non-expired) properties or own properties
        $auth = JWT::authenticate();
        $isExpired = !empty($property['expires_at']) && strtotime($property['expires_at']) < time();
        $isOwner = $auth && $property['user_id'] == $auth['user_id'];
        
        if ($property['status'] !== 'active' || $isExpired) {
            if (!$isOwner) {
                Response::notFound('Property not found');
            }
        }
        
        // Get all media
        $property['media'] = $this->db->fetchAll(
            "SELECT id, media_type, file_path, sort_order FROM property_media WHERE property_id = ? ORDER BY sort_order",
            [$id]
        );
        
        foreach ($property['media'] as &$media) {
            $media['url'] = UPLOAD_URL . $media['file_path'];
        }
        
        // Check favorite
        if ($auth) {
            $favorite = $this->db->fetch(
                "SELECT id FROM favorites WHERE user_id = ? AND listing_type = 'property' AND listing_id = ?",
                [$auth['user_id'], $id]
            );
            $property['is_favorite'] = (bool)$favorite;
        } else {
            $property['is_favorite'] = false;
        }
        
        // Increment views
        $this->db->query("UPDATE properties SET views_count = views_count + 1 WHERE id = ?", [$id]);
        
        $property['type'] = 'property';
        
        Response::success($property);
    }
    
    public function store($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        // Any registered user can create a listing (subscription required for activation)
        
        // Get valid property types from database
        $validPropertyTypes = $this->db->fetchAll("SELECT slug FROM property_types WHERE is_active = 1");
        $validSlugs = array_column($validPropertyTypes, 'slug');
        
        // Validate property_type first
        $validator = new Validator($input);
        $validator
            ->required('property_type')->in('property_type', $validSlugs)
            ->required('region_id')
            ->required('city_id')
            ->required('contact_phone')->phone('contact_phone')
            ->maxLength('bio', MAX_BIO_LENGTH)
            ->validate();
        
        // Check if user has active subscription for this property type
        require_once __DIR__ . '/SubscriptionController.php';
        $subscriptionCheck = SubscriptionController::checkUserCanAddListing(
            $auth['user_id'], 
            'properties', 
            $input['property_type']
        );
        
        if (!$subscriptionCheck['can_add']) {
            Response::error($subscriptionCheck['message_en'], 403, [
                'reason' => $subscriptionCheck['reason'],
                'message_ar' => $subscriptionCheck['message_ar'],
                'message_he' => $subscriptionCheck['message_he']
            ]);
        }
        
        $activeSubscription = $subscriptionCheck['subscription'];
        
        // Validate price - at least one price field required
        $priceType = $input['price_type'] ?? 'fixed';
        $hasAnyPrice = !empty($input['price']) || !empty($input['price_daily']) || !empty($input['price_weekly']) || !empty($input['price_monthly']);
        if ($priceType === 'fixed' && !$hasAnyPrice) {
            Response::validationError(['price' => 'At least one price (daily/weekly/monthly) is required']);
        }
        if ($priceType === 'range' && (empty($input['price_from']) || empty($input['price_to']))) {
            Response::validationError(['price_range' => 'Price range is required']);
        }
        
        // Helper to convert empty strings to null for numeric fields
        $toIntOrNull = function($val) { return ($val !== '' && $val !== null) ? (int)$val : null; };
        $toFloatOrNull = function($val) { return ($val !== '' && $val !== null) ? (float)$val : null; };
        
        // Translate title and bio to all languages
        $title = !empty($input['title']) ? $input['title'] : null;
        $bio = !empty($input['bio']) ? $input['bio'] : null;
        $sourceLang = $input['language'] ?? 'ar';
        
        $translations = [
            'title_ar' => null, 'title_en' => null, 'title_he' => null,
            'bio_ar' => null, 'bio_en' => null, 'bio_he' => null
        ];
        
        if ($title || $bio) {
            require_once __DIR__ . '/../../services/TranslationService.php';
            $translations = TranslationService::translateListing(
                $title ?? '',
                $bio ?? '',
                $sourceLang
            );
        }
        
        // Calculate listing expiry based on plan duration
        $durationDays = $activeSubscription['plan_duration_days'] ?? 30;
        $listingExpiresAt = date('Y-m-d H:i:s', strtotime("+$durationDays days"));
        
        $propertyId = $this->db->insert('properties', [
            'user_id' => $auth['user_id'],
            'subscription_id' => $activeSubscription['id'],
            'title' => $title,
            'title_ar' => $translations['title_ar'] ?? $title,
            'title_en' => $translations['title_en'] ?? null,
            'title_he' => $translations['title_he'] ?? null,
            'property_type' => $input['property_type'],
            'region_id' => $input['region_id'],
            'city_id' => $input['city_id'],
            'address_text' => !empty($input['address_text']) ? $input['address_text'] : null,
            'price_type' => $priceType,
            'price' => $toFloatOrNull($input['price'] ?? $input['price_monthly'] ?? $input['price_daily'] ?? null),
            'price_from' => $toFloatOrNull($input['price_from'] ?? null),
            'price_to' => $toFloatOrNull($input['price_to'] ?? null),
            'price_daily' => $toFloatOrNull($input['price_daily'] ?? null),
            'price_weekly' => $toFloatOrNull($input['price_weekly'] ?? null),
            'price_monthly' => $toFloatOrNull($input['price_monthly'] ?? null),
            'currency' => $input['currency'] ?? DEFAULT_CURRENCY,
            'bedrooms' => $toIntOrNull($input['bedrooms'] ?? null),
            'bathrooms' => $toIntOrNull($input['bathrooms'] ?? null),
            'floor' => $toIntOrNull($input['floor'] ?? null),
            'area_m2' => $toFloatOrNull($input['area_m2'] ?? null),
            'bio' => $bio,
            'bio_ar' => $translations['bio_ar'] ?? $bio,
            'bio_en' => $translations['bio_en'] ?? null,
            'bio_he' => $translations['bio_he'] ?? null,
            'language' => $sourceLang,
            'contact_phone' => $input['contact_phone'],
            'whatsapp' => !empty($input['whatsapp']) ? $input['whatsapp'] : $input['contact_phone'],
            'status' => 'pending_admin_review',
            'expires_at' => $listingExpiresAt
        ]);
        
        // Increment listings used in subscription
        SubscriptionController::incrementListingsUsed($activeSubscription['id']);
        
        $property = $this->db->fetch("SELECT * FROM properties WHERE id = ?", [$propertyId]);
        
        Response::success($property, 'Property created successfully. Pending admin review.', 201);
    }
    
    public function update($id, $input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $property = $this->db->fetch("SELECT * FROM properties WHERE id = ?", [$id]);
        if (!$property) {
            Response::notFound('Property not found');
        }
        
        if ($property['user_id'] != $auth['user_id']) {
            Response::forbidden('You can only edit your own properties');
        }
        
        // Can only edit draft, rejected, or pending properties (NOT active/published)
        if (!in_array($property['status'], ['draft', 'rejected', 'pending_admin_review'])) {
            Response::error('لا يمكن تعديل الإعلان بعد الموافقة عليه', 400);
        }
        
        $allowedFields = [
            'title', 'property_type', 'region_id', 'city_id', 'address_text',
            'price_type', 'price', 'price_from', 'price_to',
            'price_daily', 'price_weekly', 'price_monthly', 'currency',
            'bedrooms', 'bathrooms', 'floor', 'area_m2', 'bio', 'language',
            'contact_phone', 'whatsapp'
        ];
        
        $updateData = [];
        foreach ($allowedFields as $field) {
            if (isset($input[$field])) {
                $updateData[$field] = $input[$field];
            }
        }
        
        // If rejected, set back to pending review after edit
        if ($property['status'] === 'rejected' && !empty($updateData)) {
            $updateData['status'] = 'pending_admin_review';
            $updateData['reject_reason'] = null;
        }
        
        if (!empty($updateData)) {
            $this->db->update('properties', $updateData, 'id = ?', [$id]);
        }
        
        $property = $this->db->fetch("SELECT * FROM properties WHERE id = ?", [$id]);
        
        Response::success($property, 'Property updated');
    }
    
    public function delete($id) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $property = $this->db->fetch("SELECT * FROM properties WHERE id = ?", [$id]);
        if (!$property) {
            Response::notFound('Property not found');
        }
        
        if ($property['user_id'] != $auth['user_id']) {
            Response::forbidden('You can only delete your own properties');
        }
        
        // Delete media files
        $media = $this->db->fetchAll("SELECT file_path FROM property_media WHERE property_id = ?", [$id]);
        foreach ($media as $m) {
            Upload::delete($m['file_path']);
        }
        
        $this->db->delete('properties', 'id = ?', [$id]);
        
        Response::success(null, 'Property deleted. Note: No refund for active subscriptions.');
    }
}
