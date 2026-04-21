<?php
/**
 * Region Controller
 */

class RegionController {
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    public function index($input) {
        $sql = "SELECT id, name_ar, name_en, name_he, slug FROM regions WHERE is_active = 1 ORDER BY sort_order, name_en";
        $regions = $this->db->fetchAll($sql);
        
        // Optionally include cities
        if (!empty($input['with_cities'])) {
            foreach ($regions as &$region) {
                $region['cities'] = $this->db->fetchAll(
                    "SELECT id, name_ar, name_en, name_he, slug FROM cities WHERE region_id = ? AND is_active = 1 ORDER BY sort_order, name_en",
                    [$region['id']]
                );
            }
        }
        
        Response::success($regions);
    }
    
    public function show($id) {
        $region = $this->db->fetch(
            "SELECT id, name_ar, name_en, name_he, slug FROM regions WHERE id = ? AND is_active = 1",
            [$id]
        );
        
        if (!$region) {
            Response::notFound('Region not found');
        }
        
        $region['cities'] = $this->db->fetchAll(
            "SELECT id, name_ar, name_en, name_he, slug FROM cities WHERE region_id = ? AND is_active = 1 ORDER BY sort_order, name_en",
            [$id]
        );
        
        Response::success($region);
    }
    
    public function cities($regionId, $input) {
        $region = $this->db->fetch("SELECT id FROM regions WHERE id = ? AND is_active = 1", [$regionId]);
        
        if (!$region) {
            Response::notFound('Region not found');
        }
        
        $cities = $this->db->fetchAll(
            "SELECT id, name_ar, name_en, name_he, slug FROM cities WHERE region_id = ? AND is_active = 1 ORDER BY sort_order, name_en",
            [$regionId]
        );
        
        Response::success($cities);
    }
    
    public function allCities($input) {
        $where = "is_active = 1";
        $params = [];
        
        if (!empty($input['region_id'])) {
            $where .= " AND region_id = ?";
            $params[] = $input['region_id'];
        }
        
        $cities = $this->db->fetchAll(
            "SELECT id, region_id, name_ar, name_en, name_he, slug FROM cities WHERE $where ORDER BY region_id, sort_order, name_en",
            $params
        );
        
        Response::success($cities);
    }
}
