<?php
/**
 * Favorite Controller
 */

require_once __DIR__ . '/NotificationController.php';

class FavoriteController {
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    public function index($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $page = max(1, (int)($input['page'] ?? 1));
        $perPage = min(MAX_PAGE_SIZE, max(1, (int)($input['per_page'] ?? DEFAULT_PAGE_SIZE)));
        $offset = ($page - 1) * $perPage;
        $type = $input['type'] ?? null; // 'property', 'car', or null for all
        
        $where = "f.user_id = ?";
        $params = [$auth['user_id']];
        
        if ($type) {
            $where .= " AND f.listing_type = ?";
            $params[] = $type;
        }
        
        $countSql = "SELECT COUNT(*) as total FROM favorites f WHERE $where";
        $total = (int)$this->db->fetch($countSql, $params)['total'];
        
        // Get favorites
        $sql = "SELECT f.*, f.listing_type, f.listing_id, f.created_at as favorited_at FROM favorites f WHERE $where ORDER BY f.created_at DESC LIMIT $perPage OFFSET $offset";
        $favorites = $this->db->fetchAll($sql, $params);
        
        $results = [];
        
        foreach ($favorites as $fav) {
            $listing = null;
            
            if ($fav['listing_type'] === 'property') {
                $listing = $this->db->fetch(
                    "SELECT p.id, p.title, p.title_ar, p.title_en, p.title_he,
                            p.property_type as type, p.price_type, p.price, p.price_from, p.price_to,
                            p.currency, p.bedrooms, p.area_m2, p.status,
                            r.name_ar as region_name_ar, r.name_en as region_name_en, r.name_he as region_name_he,
                            c.name_ar as city_name_ar, c.name_en as city_name_en, c.name_he as city_name_he
                     FROM properties p
                     LEFT JOIN regions r ON p.region_id = r.id
                     LEFT JOIN cities c ON p.city_id = c.id
                     WHERE p.id = ?",
                    [$fav['listing_id']]
                );
                
                if ($listing) {
                    $media = $this->db->fetch(
                        "SELECT file_path FROM property_media WHERE property_id = ? AND media_type = 'image' ORDER BY sort_order LIMIT 1",
                        [$fav['listing_id']]
                    );
                    $listing['thumbnail'] = $media ? UPLOAD_URL . $media['file_path'] : null;
                    $listing['listing_type'] = 'property';
                }
            } else {
                $listing = $this->db->fetch(
                    "SELECT c.id, c.title, c.title_ar, c.title_en, c.title_he,
                            c.usage_type as type, c.model, c.model_ar, c.model_en, c.model_he,
                            c.price_type, c.price, c.price_from, c.price_to,
                            c.currency, c.gearbox, c.with_driver, c.status,
                            r.name_ar as region_name_ar, r.name_en as region_name_en, r.name_he as region_name_he,
                            ci.name_ar as city_name_ar, ci.name_en as city_name_en, ci.name_he as city_name_he
                     FROM cars c
                     LEFT JOIN regions r ON c.region_id = r.id
                     LEFT JOIN cities ci ON c.city_id = ci.id
                     WHERE c.id = ?",
                    [$fav['listing_id']]
                );
                
                if ($listing) {
                    $media = $this->db->fetch(
                        "SELECT file_path FROM car_media WHERE car_id = ? AND media_type = 'image' ORDER BY sort_order LIMIT 1",
                        [$fav['listing_id']]
                    );
                    $listing['thumbnail'] = $media ? UPLOAD_URL . $media['file_path'] : null;
                    $listing['listing_type'] = 'car';
                }
            }
            
            if ($listing) {
                $listing['is_favorite'] = true;
                $listing['favorited_at'] = $fav['favorited_at'];
                $results[] = $listing;
            }
        }
        
        Response::paginated($results, $total, $page, $perPage);
    }
    
    public function add($listingId, $input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $type = $input['type'] ?? 'property';
        if (!in_array($type, ['property', 'car'])) {
            Response::error('Invalid listing type', 400);
        }
        
        // Verify listing exists
        $table = $type === 'car' ? 'cars' : 'properties';
        $listing = $this->db->fetch("SELECT id FROM $table WHERE id = ?", [$listingId]);
        if (!$listing) {
            Response::notFound('Listing not found');
        }
        
        // Check if already favorited
        $existing = $this->db->fetch(
            "SELECT id FROM favorites WHERE user_id = ? AND listing_type = ? AND listing_id = ?",
            [$auth['user_id'], $type, $listingId]
        );
        
        if ($existing) {
            Response::success(null, 'Already in favorites');
            return;
        }
        
        $this->db->insert('favorites', [
            'user_id' => $auth['user_id'],
            'listing_type' => $type,
            'listing_id' => $listingId
        ]);
        
        // Send notification to listing owner
        $this->notifyListingOwner($type, $listingId, $auth['user_id']);
        
        Response::success(null, 'Added to favorites', 201);
    }
    
    /**
     * Notify listing owner when someone favorites their listing
     */
    private function notifyListingOwner($type, $listingId, $favoritedByUserId) {
        // Get listing details and owner
        $table = $type === 'car' ? 'cars' : 'properties';
        $listing = $this->db->fetch(
            "SELECT user_id, title FROM $table WHERE id = ?",
            [$listingId]
        );
        
        if (!$listing || $listing['user_id'] == $favoritedByUserId) {
            // Don't notify if listing not found or user favorited their own listing
            return;
        }
        
        $ownerId = $listing['user_id'];
        $listingTitle = $listing['title'] ?? '';
        
        // Send notification
        NotificationController::send($ownerId, 'listing_favorited', [
            'listing_type' => $type,
            'listing_id' => $listingId,
            'listing_title' => $listingTitle
        ]);
    }
    
    public function remove($listingId, $input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $type = $input['type'] ?? 'property';
        
        $this->db->delete(
            'favorites',
            'user_id = ? AND listing_type = ? AND listing_id = ?',
            [$auth['user_id'], $type, $listingId]
        );
        
        Response::success(null, 'Removed from favorites');
    }
}
