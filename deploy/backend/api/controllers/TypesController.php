<?php
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/Response.php';

class TypesController {
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    public function propertyTypes() {
        $types = $this->db->fetchAll(
            "SELECT id, name_ar, name_en, name_he, slug, icon 
             FROM property_types 
             WHERE is_active = 1 
             ORDER BY sort_order, id"
        );
        
        Response::success($types ?: []);
    }
    
    public function carTypes() {
        $types = $this->db->fetchAll(
            "SELECT id, name_ar, name_en, name_he, slug, icon 
             FROM car_types 
             WHERE is_active = 1 
             ORDER BY sort_order, id"
        );
        
        Response::success($types ?: []);
    }
    
    public function allTypes() {
        $propertyTypes = $this->db->fetchAll(
            "SELECT id, name_ar, name_en, name_he, slug, icon 
             FROM property_types 
             WHERE is_active = 1 
             ORDER BY sort_order, id"
        ) ?: [];
        
        $carTypes = $this->db->fetchAll(
            "SELECT id, name_ar, name_en, name_he, slug, icon 
             FROM car_types 
             WHERE is_active = 1 
             ORDER BY sort_order, id"
        ) ?: [];
        
        Response::success([
            'property_types' => $propertyTypes,
            'car_types' => $carTypes
        ]);
    }
}
