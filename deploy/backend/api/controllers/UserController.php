<?php
/**
 * User Controller
 */

class UserController {
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    public function me() {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $user = $this->db->fetch(
            "SELECT id, name, company_name, email, phone, user_type, profile_image, 
                    is_verified_phone, is_verified_email, is_trusted, trusted_until,
                    preferred_language, created_at 
             FROM users WHERE id = ?",
            [$auth['user_id']]
        );
        
        if (!$user) {
            Response::notFound('User not found');
        }
        
        // Get active subscriptions count
        $subscriptions = $this->db->fetch(
            "SELECT COUNT(*) as count FROM subscriptions WHERE user_id = ? AND status = 'active' AND expires_at > NOW()",
            [$auth['user_id']]
        );
        $user['active_subscriptions'] = (int)$subscriptions['count'];
        
        // Get listings count
        $listings = $this->db->fetch(
            "SELECT 
                (SELECT COUNT(*) FROM properties WHERE user_id = ?) as properties_count,
                (SELECT COUNT(*) FROM cars WHERE user_id = ?) as cars_count",
            [$auth['user_id'], $auth['user_id']]
        );
        $user['properties_count'] = (int)$listings['properties_count'];
        $user['cars_count'] = (int)$listings['cars_count'];
        
        Response::success($user);
    }
    
    public function update($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $allowedFields = ['name', 'company_name', 'preferred_language'];
        $updateData = [];
        
        foreach ($allowedFields as $field) {
            if (isset($input[$field])) {
                $updateData[$field] = $input[$field];
            }
        }
        
        if (empty($updateData)) {
            Response::error('No valid fields to update', 400);
        }
        
        if (isset($updateData['preferred_language'])) {
            $validator = new Validator($updateData);
            $validator->in('preferred_language', SUPPORTED_LANGUAGES)->validate();
        }
        
        $this->db->update('users', $updateData, 'id = ?', [$auth['user_id']]);
        
        $user = $this->db->fetch(
            "SELECT id, name, company_name, email, phone, user_type, profile_image, 
                    is_verified_phone, is_verified_email, is_trusted, preferred_language 
             FROM users WHERE id = ?",
            [$auth['user_id']]
        );
        
        Response::success($user, 'Profile updated successfully');
    }
    
    public function updateProfileImage() {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        if (!isset($_FILES['image'])) {
            Response::error('No image uploaded', 400);
        }
        
        $result = Upload::image($_FILES['image'], 'images/users');
        
        if (isset($result['error'])) {
            Response::error($result['error'], 400);
        }
        
        // Delete old image
        $user = $this->db->fetch("SELECT profile_image FROM users WHERE id = ?", [$auth['user_id']]);
        if ($user['profile_image']) {
            Upload::delete($user['profile_image']);
        }
        
        $this->db->update('users', ['profile_image' => $result['path']], 'id = ?', [$auth['user_id']]);
        
        Response::success(['image_url' => $result['url']], 'Profile image updated');
    }
    
    public function updateFcmToken($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        if (empty($input['fcm_token'])) {
            Response::error('FCM token is required', 400);
        }
        
        $this->db->update('users', ['fcm_token' => $input['fcm_token']], 'id = ?', [$auth['user_id']]);
        
        Response::success(null, 'FCM token updated');
    }
    
    public function updateProfile($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $updateData = [];
        
        // Update name if provided
        if (isset($input['name']) && !empty(trim($input['name']))) {
            $name = trim($input['name']);
            if (mb_strlen($name) < 2) {
                Response::error('الاسم يجب أن يكون حرفين على الأقل', 400);
            }
            $updateData['name'] = $name;
        }
        
        // Update company_name if provided
        if (isset($input['company_name'])) {
            $updateData['company_name'] = trim($input['company_name']) ?: null;
        }
        
        // Update region_id if provided
        if (isset($input['region_id'])) {
            $regionId = (int)$input['region_id'];
            if ($regionId > 0) {
                // Verify region exists
                $region = $this->db->fetch("SELECT id FROM regions WHERE id = ?", [$regionId]);
                if (!$region) {
                    Response::error('المنطقة غير موجودة', 400);
                }
                $updateData['region_id'] = $regionId;
            } else {
                $updateData['region_id'] = null;
            }
        }
        
        // Update city_id if provided
        if (isset($input['city_id'])) {
            $cityId = (int)$input['city_id'];
            if ($cityId > 0) {
                // Verify city exists and belongs to selected region
                $regionId = $updateData['region_id'] ?? $input['region_id'] ?? null;
                if ($regionId) {
                    $city = $this->db->fetch("SELECT id FROM cities WHERE id = ? AND region_id = ?", [$cityId, $regionId]);
                } else {
                    $city = $this->db->fetch("SELECT id FROM cities WHERE id = ?", [$cityId]);
                }
                if (!$city) {
                    Response::error('المدينة غير موجودة', 400);
                }
                $updateData['city_id'] = $cityId;
            } else {
                $updateData['city_id'] = null;
            }
        }
        
        if (empty($updateData)) {
            Response::error('لا توجد بيانات للتحديث', 400);
        }
        
        $this->db->update('users', $updateData, 'id = ?', [$auth['user_id']]);
        
        // Return updated user data
        $user = $this->db->fetch(
            "SELECT id, name, company_name, email, phone, user_type, profile_image, 
                    is_verified_phone, is_verified_email, is_trusted, preferred_language, 
                    region_id, city_id, created_at 
             FROM users WHERE id = ?",
            [$auth['user_id']]
        );
        
        Response::success($user, 'تم تحديث الملف الشخصي بنجاح');
    }
    
    public function changePassword($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        if (empty($input['current_password']) || empty($input['new_password'])) {
            Response::error('كلمة المرور الحالية والجديدة مطلوبتان', 400);
        }
        
        if (strlen($input['new_password']) < 6) {
            Response::error('كلمة المرور الجديدة يجب أن تكون 6 أحرف على الأقل', 400);
        }
        
        // Get current user
        $user = $this->db->fetch("SELECT password FROM users WHERE id = ?", [$auth['user_id']]);
        
        if (!password_verify($input['current_password'], $user['password'])) {
            Response::error('كلمة المرور الحالية غير صحيحة', 400);
        }
        
        $hashedPassword = password_hash($input['new_password'], PASSWORD_DEFAULT);
        $this->db->update('users', ['password' => $hashedPassword], 'id = ?', [$auth['user_id']]);
        
        Response::success(null, 'تم تغيير كلمة المرور بنجاح');
    }
    
    public function changeEmail($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        if (empty($input['new_email']) || empty($input['password'])) {
            Response::error('البريد الإلكتروني الجديد وكلمة المرور مطلوبان', 400);
        }
        
        $newEmail = trim($input['new_email']);
        if (!filter_var($newEmail, FILTER_VALIDATE_EMAIL)) {
            Response::error('البريد الإلكتروني غير صالح', 400);
        }
        
        // Check if email already exists
        $existing = $this->db->fetch("SELECT id FROM users WHERE email = ? AND id != ?", [$newEmail, $auth['user_id']]);
        if ($existing) {
            Response::error('البريد الإلكتروني مستخدم بالفعل', 400);
        }
        
        // Verify password
        $user = $this->db->fetch("SELECT password FROM users WHERE id = ?", [$auth['user_id']]);
        if (!password_verify($input['password'], $user['password'])) {
            Response::error('كلمة المرور غير صحيحة', 400);
        }
        
        $this->db->update('users', [
            'email' => $newEmail,
            'is_verified_email' => 0
        ], 'id = ?', [$auth['user_id']]);
        
        Response::success(['email' => $newEmail], 'تم تغيير البريد الإلكتروني بنجاح');
    }
    
    public function changePhone($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        if (empty($input['new_phone']) || empty($input['password'])) {
            Response::error('رقم الهاتف الجديد وكلمة المرور مطلوبان', 400);
        }
        
        $newPhone = trim($input['new_phone']);
        if (strlen($newPhone) < 9) {
            Response::error('رقم الهاتف غير صالح', 400);
        }
        
        // Check if phone already exists
        $existing = $this->db->fetch("SELECT id FROM users WHERE phone = ? AND id != ?", [$newPhone, $auth['user_id']]);
        if ($existing) {
            Response::error('رقم الهاتف مستخدم بالفعل', 400);
        }
        
        // Verify password
        $user = $this->db->fetch("SELECT password FROM users WHERE id = ?", [$auth['user_id']]);
        if (!password_verify($input['password'], $user['password'])) {
            Response::error('كلمة المرور غير صحيحة', 400);
        }
        
        $this->db->update('users', [
            'phone' => $newPhone,
            'is_verified_phone' => 0
        ], 'id = ?', [$auth['user_id']]);
        
        Response::success(['phone' => $newPhone], 'تم تغيير رقم الهاتف بنجاح');
    }
    
    public function myListings($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $allListings = [];
        
        // Fetch properties
        $propertiesSql = "SELECT p.*, 'property' as listing_type,
                                r.name_ar as region_name_ar, r.name_en as region_name_en, r.name_he as region_name_he,
                                c.name_ar as city_name_ar, c.name_en as city_name_en, c.name_he as city_name_he
                         FROM properties p
                         LEFT JOIN regions r ON p.region_id = r.id
                         LEFT JOIN cities c ON p.city_id = c.id
                         WHERE p.user_id = ?
                         ORDER BY p.created_at DESC";
        
        $properties = $this->db->fetchAll($propertiesSql, [$auth['user_id']]);
        
        foreach ($properties as &$prop) {
            $prop['media'] = $this->db->fetchAll(
                "SELECT * FROM property_media WHERE property_id = ? ORDER BY sort_order",
                [$prop['id']]
            );
            if (!empty($prop['media'])) {
                $filePath = $prop['media'][0]['file_path'] ?? null;
                $prop['thumbnail'] = $filePath ? UPLOAD_URL . $filePath : null;
            }
        }
        $allListings = array_merge($allListings, $properties);
        
        // Fetch cars
        $carsSql = "SELECT c.*, 'car' as listing_type,
                          r.name_ar as region_name_ar, r.name_en as region_name_en, r.name_he as region_name_he,
                          ci.name_ar as city_name_ar, ci.name_en as city_name_en, ci.name_he as city_name_he
                   FROM cars c
                   LEFT JOIN regions r ON c.region_id = r.id
                   LEFT JOIN cities ci ON c.city_id = ci.id
                   WHERE c.user_id = ?
                   ORDER BY c.created_at DESC";
        
        $cars = $this->db->fetchAll($carsSql, [$auth['user_id']]);
        
        foreach ($cars as &$car) {
            $car['media'] = $this->db->fetchAll(
                "SELECT * FROM car_media WHERE car_id = ? ORDER BY sort_order",
                [$car['id']]
            );
            if (!empty($car['media'])) {
                $filePath = $car['media'][0]['file_path'] ?? null;
                $car['thumbnail'] = $filePath ? UPLOAD_URL . $filePath : null;
            }
            // Create title for car
            $car['title'] = ($car['brand'] ?? '') . ' ' . ($car['model'] ?? '') . ' ' . ($car['year'] ?? '');
        }
        $allListings = array_merge($allListings, $cars);
        
        // Sort by created_at DESC
        usort($allListings, function($a, $b) {
            return strtotime($b['created_at']) - strtotime($a['created_at']);
        });
        
        Response::success($allListings);
    }
    
    /**
     * Save FCM token for push notifications
     */
    public function saveFcmToken() {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $data = json_decode(file_get_contents('php://input'), true);
        $fcmToken = $data['fcm_token'] ?? null;
        
        if (!$fcmToken) {
            Response::error('FCM token is required');
        }
        
        // Update user's FCM token
        $this->db->query(
            "UPDATE users SET fcm_token = ? WHERE id = ?",
            [$fcmToken, $auth['user_id']]
        );
        
        Response::success(['message' => 'FCM token saved successfully']);
    }
}
