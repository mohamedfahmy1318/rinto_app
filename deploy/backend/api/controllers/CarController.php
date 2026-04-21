<?php
/**
 * Car Controller
 */

class CarController {
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    public function index($input) {
        $page = max(1, (int)($input['page'] ?? 1));
        $perPage = min(MAX_PAGE_SIZE, max(1, (int)($input['per_page'] ?? DEFAULT_PAGE_SIZE)));
        $offset = ($page - 1) * $perPage;
        
        $where = "c.status = 'active' AND (c.expires_at IS NULL OR c.expires_at > NOW())";
        $params = [];
        
        // Filters
        if (!empty($input['region_id'])) {
            $where .= " AND c.region_id = ?";
            $params[] = $input['region_id'];
        }
        
        if (!empty($input['city_id'])) {
            $where .= " AND c.city_id = ?";
            $params[] = $input['city_id'];
        }
        
        if (!empty($input['usage_type'])) {
            $where .= " AND c.usage_type = ?";
            $params[] = $input['usage_type'];
        }
        
        if (!empty($input['gearbox'])) {
            $where .= " AND c.gearbox = ?";
            $params[] = $input['gearbox'];
        }
        
        if (isset($input['with_driver'])) {
            $where .= " AND c.with_driver = ?";
            $params[] = $input['with_driver'] ? 1 : 0;
        }
        
        if (!empty($input['plate_color'])) {
            $where .= " AND c.plate_color = ?";
            $params[] = $input['plate_color'];
        }
        
        if (!empty($input['price_min'])) {
            $where .= " AND (c.price >= ? OR c.price_from >= ? OR c.price_daily >= ? OR c.price_weekly >= ? OR c.price_monthly >= ?)";
            $params[] = $input['price_min'];
            $params[] = $input['price_min'];
            $params[] = $input['price_min'];
            $params[] = $input['price_min'];
            $params[] = $input['price_min'];
        }
        
        if (!empty($input['price_max'])) {
            $where .= " AND (c.price <= ? OR c.price_to <= ? OR c.price_daily <= ? OR c.price_weekly <= ? OR c.price_monthly <= ?)";
            $params[] = $input['price_max'];
            $params[] = $input['price_max'];
            $params[] = $input['price_max'];
            $params[] = $input['price_max'];
            $params[] = $input['price_max'];
        }
        
        if (!empty($input['search'])) {
            $search = '%' . $input['search'] . '%';
            $where .= " AND (c.title LIKE ? OR c.model LIKE ? OR c.bio LIKE ?)";
            $params[] = $search;
            $params[] = $search;
            $params[] = $search;
        }
        
        $countSql = "SELECT COUNT(*) as total FROM cars c WHERE $where";
        $total = (int)$this->db->fetch($countSql, $params)['total'];
        
        $sql = "SELECT c.*, 
                       r.name_ar as region_name_ar, r.name_en as region_name_en, r.name_he as region_name_he,
                       ci.name_ar as city_name_ar, ci.name_en as city_name_en, ci.name_he as city_name_he,
                       u.name as owner_name, u.is_trusted as owner_is_trusted,
                       pl.badge as badge,
                       COALESCE(c.is_trusted, pl.is_trusted_advertiser, 0) as is_trusted
                FROM cars c
                LEFT JOIN regions r ON c.region_id = r.id
                LEFT JOIN cities ci ON c.city_id = ci.id
                LEFT JOIN users u ON c.user_id = u.id
                LEFT JOIN subscriptions s ON c.subscription_id = s.id
                LEFT JOIN plans pl ON s.plan_id = pl.id
                WHERE $where
                ORDER BY 
                    CASE WHEN COALESCE(c.is_trusted, pl.is_trusted_advertiser, 0) = 1 THEN 0 ELSE 1 END,
                    CASE WHEN pl.badge = 'gold' THEN 0 
                         WHEN pl.badge = 'silver' THEN 1 
                         WHEN pl.badge = 'bronze' THEN 2 
                         ELSE 3 END,
                    c.created_at DESC,
                    c.id DESC
                LIMIT $perPage OFFSET $offset";
        
        $cars = $this->db->fetchAll($sql, $params);
        
        // Get user language preference from request
        $userLang = $input['lang'] ?? 'ar';
        
        // Get first image for each car
        foreach ($cars as &$car) {
            $media = $this->db->fetch(
                "SELECT file_path FROM car_media WHERE car_id = ? AND media_type = 'image' ORDER BY sort_order LIMIT 1",
                [$car['id']]
            );
            $car['thumbnail'] = $media ? UPLOAD_URL . $media['file_path'] : null;
            $car['type'] = 'car';
            
            // Return localized title and bio based on user language
            $car['title_localized'] = $car["title_{$userLang}"] ?? $car['title_ar'] ?? $car['title'];
            $car['bio_localized'] = $car["bio_{$userLang}"] ?? $car['bio_ar'] ?? $car['bio'];
        }
        
        // Check favorites if user is authenticated
        $auth = JWT::authenticate();
        if ($auth) {
            $favoriteIds = $this->db->fetchAll(
                "SELECT listing_id FROM favorites WHERE user_id = ? AND listing_type = 'car'",
                [$auth['user_id']]
            );
            $favoriteIds = array_column($favoriteIds, 'listing_id');
            
            foreach ($cars as &$car) {
                $car['is_favorite'] = in_array($car['id'], $favoriteIds);
            }
        }
        
        Response::paginated($cars, $total, $page, $perPage);
    }
    
    public function show($id) {
        $sql = "SELECT c.*, 
                       r.name_ar as region_name_ar, r.name_en as region_name_en, r.name_he as region_name_he,
                       ci.name_ar as city_name_ar, ci.name_en as city_name_en, ci.name_he as city_name_he,
                       u.id as owner_id, u.name as owner_name, u.company_name as owner_company,
                       u.phone as owner_phone, u.is_trusted as owner_is_trusted, u.profile_image as owner_image
                FROM cars c
                LEFT JOIN regions r ON c.region_id = r.id
                LEFT JOIN cities ci ON c.city_id = ci.id
                LEFT JOIN users u ON c.user_id = u.id
                WHERE c.id = ?";
        
        $car = $this->db->fetch($sql, [$id]);
        
        if (!$car) {
            Response::notFound('Car not found');
        }
        
        // Only show active (non-expired) cars or own cars
        $auth = JWT::authenticate();
        $isExpired = !empty($car['expires_at']) && strtotime($car['expires_at']) < time();
        $isOwner = $auth && $car['user_id'] == $auth['user_id'];
        
        if ($car['status'] !== 'active' || $isExpired) {
            if (!$isOwner) {
                Response::notFound('Car not found');
            }
        }
        
        // Get all media
        $car['media'] = $this->db->fetchAll(
            "SELECT id, media_type, file_path, sort_order FROM car_media WHERE car_id = ? ORDER BY sort_order",
            [$id]
        );
        
        foreach ($car['media'] as &$media) {
            $media['url'] = UPLOAD_URL . $media['file_path'];
        }
        
        // Check favorite
        if ($auth) {
            $favorite = $this->db->fetch(
                "SELECT id FROM favorites WHERE user_id = ? AND listing_type = 'car' AND listing_id = ?",
                [$auth['user_id'], $id]
            );
            $car['is_favorite'] = (bool)$favorite;
        } else {
            $car['is_favorite'] = false;
        }
        
        // Increment views
        $this->db->query("UPDATE cars SET views_count = views_count + 1 WHERE id = ?", [$id]);
        
        $car['type'] = 'car';
        
        Response::success($car);
    }
    
    public function store($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        // Any registered user can create a listing (subscription required for activation)
        
        // Get valid car usage types from database
        $validCarTypes = $this->db->fetchAll("SELECT slug FROM car_types WHERE is_active = 1");
        $validSlugs = array_column($validCarTypes, 'slug');
        
        // Validate usage_type first
        $validator = new Validator($input);
        $validator
            ->required('usage_type')->in('usage_type', $validSlugs)
            ->required('model')
            ->required('region_id')
            ->required('city_id')
            ->required('contact_phone')->phone('contact_phone')
            ->maxLength('bio', MAX_BIO_LENGTH)
            ->validate();
        
        // Check if user has active subscription for this car usage type
        require_once __DIR__ . '/SubscriptionController.php';
        $subscriptionCheck = SubscriptionController::checkUserCanAddListing(
            $auth['user_id'], 
            'cars', 
            $input['usage_type']
        );
        
        if (!$subscriptionCheck['can_add']) {
            Response::error($subscriptionCheck['message_en'], 403, [
                'reason' => $subscriptionCheck['reason'],
                'message_ar' => $subscriptionCheck['message_ar'],
                'message_he' => $subscriptionCheck['message_he']
            ]);
        }
        
        $activeSubscription = $subscriptionCheck['subscription'];
        
        // Validate price
        $priceType = $input['price_type'] ?? 'fixed';
        if ($priceType === 'fixed' && empty($input['price'])) {
            Response::validationError(['price' => 'Price is required for fixed price type']);
        }
        if ($priceType === 'range' && (empty($input['price_from']) || empty($input['price_to']))) {
            Response::validationError(['price_range' => 'Price range is required']);
        }
        
        // Helper to convert empty strings to null for numeric fields
        $toIntOrNull = function($val) { return ($val !== '' && $val !== null) ? (int)$val : null; };
        $toFloatOrNull = function($val) { return ($val !== '' && $val !== null) ? (float)$val : null; };
        
        // Translate title, bio, and model to all languages
        $title = !empty($input['title']) ? $input['title'] : null;
        $bio = !empty($input['bio']) ? $input['bio'] : null;
        $model = !empty($input['model']) ? $input['model'] : null;
        $sourceLang = $input['language'] ?? 'ar';
        
        $translations = [
            'title_ar' => null, 'title_en' => null, 'title_he' => null,
            'bio_ar' => null, 'bio_en' => null, 'bio_he' => null,
            'model_ar' => null, 'model_en' => null, 'model_he' => null
        ];
        
        if ($title || $bio || $model) {
            require_once __DIR__ . '/../../services/TranslationService.php';
            $translations = TranslationService::translateListing(
                $title ?? '',
                $bio ?? '',
                $sourceLang,
                $model
            );
        }
        
        // Calculate listing expiry based on plan duration
        $durationDays = $activeSubscription['plan_duration_days'] ?? 30;
        $listingExpiresAt = date('Y-m-d H:i:s', strtotime("+$durationDays days"));
        
        $carId = $this->db->insert('cars', [
            'user_id' => $auth['user_id'],
            'subscription_id' => $activeSubscription['id'],
            'title' => $title,
            'title_ar' => $translations['title_ar'] ?? $title,
            'title_en' => $translations['title_en'] ?? null,
            'title_he' => $translations['title_he'] ?? null,
            'usage_type' => $input['usage_type'],
            'model' => $model,
            'model_ar' => $translations['model_ar'] ?? $model,
            'model_en' => $translations['model_en'] ?? null,
            'model_he' => $translations['model_he'] ?? null,
            'year' => $toIntOrNull($input['year'] ?? null),
            'gearbox' => $input['gearbox'] ?? 'automatic',
            'with_driver' => isset($input['with_driver']) ? ($input['with_driver'] ? 1 : 0) : 0,
            'duration_type' => $input['duration_type'] ?? 'daily',
            'plate_color' => $input['plate_color'] ?? 'yellow',
            'region_id' => $input['region_id'],
            'city_id' => $input['city_id'],
            'address_text' => !empty($input['address_text']) ? $input['address_text'] : null,
            'price_type' => $priceType,
            'price' => $toFloatOrNull($input['price'] ?? null),
            'price_from' => $toFloatOrNull($input['price_from'] ?? null),
            'price_to' => $toFloatOrNull($input['price_to'] ?? null),
            'price_daily' => $toFloatOrNull($input['price_daily'] ?? null),
            'price_weekly' => $toFloatOrNull($input['price_weekly'] ?? null),
            'price_monthly' => $toFloatOrNull($input['price_monthly'] ?? null),
            'currency' => $input['currency'] ?? DEFAULT_CURRENCY,
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
        
        $car = $this->db->fetch("SELECT * FROM cars WHERE id = ?", [$carId]);
        
        Response::success($car, 'Car listing created successfully. Pending admin review.', 201);
    }
    
    public function update($id, $input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $car = $this->db->fetch("SELECT * FROM cars WHERE id = ?", [$id]);
        if (!$car) {
            Response::notFound('Car not found');
        }
        
        if ($car['user_id'] != $auth['user_id']) {
            Response::forbidden('You can only edit your own cars');
        }
        
        // Can only edit draft, rejected, or pending cars (NOT active/published)
        if (!in_array($car['status'], ['draft', 'rejected', 'pending_admin_review'])) {
            Response::error('لا يمكن تعديل الإعلان بعد الموافقة عليه', 400);
        }
        
        $allowedFields = [
            'title', 'usage_type', 'model', 'year', 'gearbox', 'with_driver',
            'duration_type', 'plate_color', 'region_id', 'city_id', 'address_text',
            'price_type', 'price', 'price_from', 'price_to', 'currency', 'bio', 'language',
            'contact_phone', 'whatsapp'
        ];
        
        $updateData = [];
        foreach ($allowedFields as $field) {
            if (isset($input[$field])) {
                if ($field === 'with_driver') {
                    $updateData[$field] = $input[$field] ? 1 : 0;
                } else {
                    $updateData[$field] = $input[$field];
                }
            }
        }
        
        // If rejected, set back to pending review after edit
        if ($car['status'] === 'rejected' && !empty($updateData)) {
            $updateData['status'] = 'pending_admin_review';
            $updateData['reject_reason'] = null;
        }
        
        if (!empty($updateData)) {
            $this->db->update('cars', $updateData, 'id = ?', [$id]);
        }
        
        $car = $this->db->fetch("SELECT * FROM cars WHERE id = ?", [$id]);
        
        Response::success($car, 'Car updated');
    }
    
    public function delete($id) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $car = $this->db->fetch("SELECT * FROM cars WHERE id = ?", [$id]);
        if (!$car) {
            Response::notFound('Car not found');
        }
        
        if ($car['user_id'] != $auth['user_id']) {
            Response::forbidden('You can only delete your own cars');
        }
        
        // Delete media files
        $media = $this->db->fetchAll("SELECT file_path FROM car_media WHERE car_id = ?", [$id]);
        foreach ($media as $m) {
            Upload::delete($m['file_path']);
        }
        
        $this->db->delete('cars', 'id = ?', [$id]);
        
        Response::success(null, 'Car deleted. Note: No refund for active subscriptions.');
    }
}
