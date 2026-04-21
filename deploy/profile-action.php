<?php
/**
 * Profile Action Handler
 * Handles profile updates, password changes, and settings
 */

require_once __DIR__ . '/config.php';

header('Content-Type: application/json');

// Check if logged in
if (!isset($_SESSION['user']) || !isset($_SESSION['token'])) {
    echo json_encode(['success' => false, 'message' => 'يرجى تسجيل الدخول أولاً']);
    exit;
}

// Get input
$input = json_decode(file_get_contents('php://input'), true);
$action = $input['action'] ?? '';
$token = $_SESSION['token'];

switch ($action) {
    case 'update_profile':
        $name = trim($input['name'] ?? '');
        $email = trim($input['email'] ?? '');
        $companyName = trim($input['company_name'] ?? '');
        
        if (empty($name)) {
            echo json_encode(['success' => false, 'message' => 'الاسم مطلوب']);
            exit;
        }
        
        // Call API to update profile
        $response = apiCall('me/update', 'POST', [
            'name' => $name,
            'email' => $email,
            'company_name' => $companyName
        ], $token);
        
        if ($response['success'] ?? false) {
            // Update session
            $_SESSION['user']['name'] = $name;
            $_SESSION['user']['email'] = $email;
            $_SESSION['user']['company_name'] = $companyName;
            
            echo json_encode(['success' => true, 'message' => 'تم حفظ التغييرات']);
        } else {
            echo json_encode(['success' => false, 'message' => $response['message'] ?? 'حدث خطأ']);
        }
        break;
        
    case 'change_password':
        $currentPassword = $input['current_password'] ?? '';
        $newPassword = $input['new_password'] ?? '';
        
        if (empty($currentPassword) || empty($newPassword)) {
            echo json_encode(['success' => false, 'message' => 'جميع الحقول مطلوبة']);
            exit;
        }
        
        if (strlen($newPassword) < 6) {
            echo json_encode(['success' => false, 'message' => 'كلمة المرور يجب أن تكون 6 أحرف على الأقل']);
            exit;
        }
        
        // Call API to change password
        $response = apiCall('me/change-password', 'POST', [
            'current_password' => $currentPassword,
            'new_password' => $newPassword
        ], $token);
        
        if ($response['success'] ?? false) {
            echo json_encode(['success' => true, 'message' => 'تم تغيير كلمة المرور']);
        } else {
            echo json_encode(['success' => false, 'message' => $response['message'] ?? 'كلمة المرور الحالية غير صحيحة']);
        }
        break;
        
    case 'toggle_notifications':
        $enabled = $input['enabled'] ?? true;
        
        // Call API to update notification settings
        $response = apiCall('me/notifications', 'POST', [
            'enabled' => $enabled
        ], $token);
        
        echo json_encode(['success' => true]);
        break;
        
    default:
        echo json_encode(['success' => false, 'message' => 'إجراء غير صالح']);
}
