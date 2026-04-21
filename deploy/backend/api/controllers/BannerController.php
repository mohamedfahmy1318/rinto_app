<?php
/**
 * Banner Controller - For admin promotional banners
 */

class BannerController {
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    /**
     * Get active banners for display
     */
    public function index($input) {
        $type = $input['type'] ?? null; // property, car, or null for all
        
        // Use Palestine timezone for date comparisons
        $nowPalestine = (new DateTime('now', new DateTimeZone('Asia/Hebron')))->format('Y-m-d H:i:s');
        
        $where = "b.is_active = 1 AND (b.starts_at IS NULL OR b.starts_at <= ?) AND (b.ends_at IS NULL OR b.ends_at >= ?)";
        $params = [$nowPalestine, $nowPalestine];
        
        if ($type) {
            $where .= " AND (b.banner_type = ? OR b.banner_type = 'general')";
            $params[] = $type;
        }
        
        $sql = "SELECT b.id, b.title, b.title_ar, b.title_en, b.title_he,
                       b.description, b.description_ar, b.description_en, b.description_he,
                       b.banner_type, b.thumbnail, b.region_id, b.city_id, b.address_text,
                       b.price, b.price_text, b.currency, b.property_type, b.bedrooms, b.bathrooms,
                       b.area_m2, b.floor, b.car_model, b.car_year, b.gearbox, b.contact_phone,
                       b.whatsapp, b.views_count, b.created_at,
                       r.name_ar as region_name_ar, r.name_en as region_name_en, r.name_he as region_name_he,
                       c.name_ar as city_name_ar, c.name_en as city_name_en, c.name_he as city_name_he
                FROM admin_banners b
                LEFT JOIN regions r ON b.region_id = r.id
                LEFT JOIN cities c ON b.city_id = c.id
                WHERE $where
                ORDER BY b.display_order ASC, b.created_at DESC
                LIMIT 10";
        
        $banners = $this->db->fetchAll($sql, $params);
        
        // Get media for each banner
        foreach ($banners as &$banner) {
            $media = $this->db->fetchAll(
                "SELECT id, media_type, file_path, sort_order FROM admin_banner_media WHERE banner_id = ? ORDER BY sort_order",
                [$banner['id']]
            );
            
            foreach ($media as &$m) {
                $m['url'] = UPLOAD_URL . $m['file_path'];
            }
            
            $banner['media'] = $media;
            
            // Set thumbnail
            if (empty($banner['thumbnail']) && !empty($media)) {
                $banner['thumbnail'] = UPLOAD_URL . $media[0]['file_path'];
            } elseif (!empty($banner['thumbnail'])) {
                $banner['thumbnail'] = UPLOAD_URL . $banner['thumbnail'];
            }
        }
        
        Response::success($banners);
    }
    
    /**
     * Get single banner details
     */
    public function show($id) {
        $sql = "SELECT b.id, b.title, b.title_ar, b.title_en, b.title_he,
                       b.description, b.description_ar, b.description_en, b.description_he,
                       b.banner_type, b.thumbnail, b.region_id, b.city_id, b.address_text,
                       b.price, b.price_text, b.currency, b.property_type, b.bedrooms, b.bathrooms,
                       b.area_m2, b.floor, b.car_model, b.car_year, b.gearbox, b.contact_phone,
                       b.whatsapp, b.views_count, b.created_at,
                       r.name_ar as region_name_ar, r.name_en as region_name_en, r.name_he as region_name_he,
                       c.name_ar as city_name_ar, c.name_en as city_name_en, c.name_he as city_name_he
                FROM admin_banners b
                LEFT JOIN regions r ON b.region_id = r.id
                LEFT JOIN cities c ON b.city_id = c.id
                WHERE b.id = ?";
        
        $banner = $this->db->fetch($sql, [$id]);
        
        if (!$banner) {
            Response::notFound('Banner not found');
        }
        
        // Get media
        $media = $this->db->fetchAll(
            "SELECT id, media_type, file_path, sort_order FROM admin_banner_media WHERE banner_id = ? ORDER BY sort_order",
            [$id]
        );
        
        foreach ($media as &$m) {
            $m['url'] = UPLOAD_URL . $m['file_path'];
        }
        
        $banner['media'] = $media;
        
        // Set thumbnail
        if (empty($banner['thumbnail']) && !empty($media)) {
            $banner['thumbnail'] = UPLOAD_URL . $media[0]['file_path'];
        } elseif (!empty($banner['thumbnail'])) {
            $banner['thumbnail'] = UPLOAD_URL . $banner['thumbnail'];
        }
        
        // Increment views
        $this->db->query("UPDATE admin_banners SET views_count = views_count + 1 WHERE id = ?", [$id]);
        
        Response::success($banner);
    }
}
