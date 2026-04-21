<?php
/**
 * Plan Controller
 */

require_once __DIR__ . '/SubscriptionController.php';

class PlanController {
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    public function index($input) {
        $category = $input['category'] ?? null;
        $propertyType = $input['property_type'] ?? null;
        $propertyTypeId = $input['property_type_id'] ?? null;
        $carUsageType = $input['car_usage_type'] ?? null;
        $carTypeId = $input['car_type_id'] ?? null;
        
        $where = "is_active = 1 AND (is_welcome_bonus = 0 OR is_welcome_bonus IS NULL)";
        $params = [];
        
        if ($category && in_array($category, ['properties', 'cars'])) {
            $where .= " AND category = ?";
            $params[] = $category;
        }
        
        // Filter by specific type: show matching plans OR general plans (null type)
        if ($propertyTypeId && $category === 'properties') {
            $where .= " AND (property_type_id = ? OR property_type_id IS NULL)";
            $params[] = $propertyTypeId;
        } elseif ($propertyType && $category === 'properties') {
            // Resolve slug to type IDs (e.g. 'villa_chalet' → [4], 'shop_office' → [6,7])
            $typeIds = SubscriptionController::resolveTypeIds('properties', $propertyType);
            if (!empty($typeIds)) {
                $placeholders = implode(',', array_fill(0, count($typeIds), '?'));
                $where .= " AND (property_type_id IN ($placeholders) OR property_type_id IS NULL)";
                $params = array_merge($params, $typeIds);
            }
        }
        
        if ($carTypeId && $category === 'cars') {
            $where .= " AND (car_type_id = ? OR car_type_id IS NULL)";
            $params[] = $carTypeId;
        } elseif ($carUsageType && $category === 'cars') {
            // Resolve slug to type IDs (e.g. 'wedding' → [2])
            $typeIds = SubscriptionController::resolveTypeIds('cars', $carUsageType);
            if (!empty($typeIds)) {
                $placeholders = implode(',', array_fill(0, count($typeIds), '?'));
                $where .= " AND (car_type_id IN ($placeholders) OR car_type_id IS NULL)";
                $params = array_merge($params, $typeIds);
            }
        }
        
        $sql = "SELECT * FROM plans WHERE $where ORDER BY category, sort_order, price";
        $plans = $this->db->fetchAll($sql, $params);
        
        // Group by category and type (specific vs general)
        $grouped = [
            'properties' => ['specific' => [], 'general' => []],
            'cars' => ['specific' => [], 'general' => []]
        ];
        
        foreach ($plans as $plan) {
            $plan['has_discount'] = !empty($plan['original_price']) && $plan['original_price'] > $plan['price'];
            $cat = $plan['category'];
            
            // Check if plan is specific to a type or general
            $isSpecific = false;
            if ($cat === 'properties' && (!empty($plan['property_type_id']) || !empty($plan['property_type']))) {
                $isSpecific = true;
            } elseif ($cat === 'cars' && (!empty($plan['car_type_id']) || !empty($plan['car_usage_type']))) {
                $isSpecific = true;
            }
            
            if ($isSpecific) {
                $grouped[$cat]['specific'][] = $plan;
            } else {
                $grouped[$cat]['general'][] = $plan;
            }
        }
        
        if ($category) {
            Response::success($grouped[$category]);
        } else {
            Response::success($grouped);
        }
    }
    
    public function show($id) {
        $plan = $this->db->fetch("SELECT * FROM plans WHERE id = ? AND is_active = 1", [$id]);
        
        if (!$plan) {
            Response::notFound('Plan not found');
        }
        
        $plan['has_discount'] = !empty($plan['original_price']) && $plan['original_price'] > $plan['price'];
        
        Response::success($plan);
    }
}
