<?php
/**
 * ================================================
 * WebSocket Server Endpoint - نقطة نهاية WebSocket
 * ================================================
 * 
 * ملاحظة: هذا ملف مساعد للتكامل مع خادم WebSocket خارجي
 * PHP لا يدعم WebSocket بشكل أصلي، يمكن استخدام:
 * - Ratchet (PHP WebSocket library)
 * - Node.js WebSocket server
 * - Pusher/Ably (خدمات خارجية)
 * 
 * هذا الملف يوفر API للتكامل مع أي خادم WebSocket
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

session_start();
require_once '../config/db.php';

$pdo = getDBConnection();
$action = $_GET['action'] ?? $_POST['action'] ?? '';

try {
    switch ($action) {
        
        /**
         * الحصول على إعدادات الاتصال
         */
        case 'config':
            echo json_encode([
                'success' => true,
                'data' => [
                    'polling_interval' => 5000, // 5 ثوانٍ
                    'use_websocket' => false, // تعطيل WebSocket حتى يتم إعداد الخادم
                    'websocket_url' => null,
                    'features' => [
                        'real_time_tracking' => true,
                        'push_notifications' => true,
                        'background_location' => true
                    ]
                ]
            ]);
            break;
            
        /**
         * بث رسالة لمستخدم معين (للاستخدام من الخادم)
         */
        case 'broadcast':
            $data = json_decode(file_get_contents('php://input'), true);
            
            $userType = $data['user_type'] ?? '';
            $userId = $data['user_id'] ?? 0;
            $messageType = $data['message_type'] ?? '';
            $messageData = $data['message_data'] ?? [];
            
            if (!$userType || !$userId || !$messageType) {
                echo json_encode(['success' => false, 'message' => 'بيانات ناقصة']);
                exit;
            }
            
            // حفظ الرسالة في جدول الرسائل المعلقة
            $stmt = $pdo->prepare("
                INSERT INTO pending_messages (user_type, user_id, message_type, message_data, created_at)
                VALUES (?, ?, ?, ?, NOW())
            ");
            $result = $stmt->execute([$userType, $userId, $messageType, json_encode($messageData)]);
            
            echo json_encode(['success' => $result]);
            break;
            
        /**
         * جلب الرسائل المعلقة للمستخدم
         */
        case 'poll':
            $userType = $_GET['user_type'] ?? '';
            $userId = intval($_GET['user_id'] ?? 0);
            $lastId = intval($_GET['last_id'] ?? 0);
            
            if (!$userType || !$userId) {
                echo json_encode(['success' => false, 'message' => 'بيانات ناقصة']);
                exit;
            }
            
            // جلب الرسائل الجديدة
            $stmt = $pdo->prepare("
                SELECT id, message_type, message_data, created_at
                FROM pending_messages
                WHERE user_type = ? AND user_id = ? AND id > ?
                ORDER BY id ASC
                LIMIT 50
            ");
            $stmt->execute([$userType, $userId, $lastId]);
            $messages = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // تحويل message_data من JSON
            foreach ($messages as &$msg) {
                $msg['message_data'] = json_decode($msg['message_data'], true);
            }
            
            echo json_encode([
                'success' => true,
                'messages' => $messages,
                'last_id' => count($messages) > 0 ? $messages[count($messages) - 1]['id'] : $lastId
            ]);
            break;
            
        /**
         * تنظيف الرسائل القديمة
         */
        case 'cleanup':
            // حذف الرسائل الأقدم من ساعة
            $stmt = $pdo->prepare("
                DELETE FROM pending_messages 
                WHERE created_at < DATE_SUB(NOW(), INTERVAL 1 HOUR)
            ");
            $stmt->execute();
            
            echo json_encode(['success' => true, 'deleted' => $stmt->rowCount()]);
            break;
            
        default:
            echo json_encode([
                'success' => false,
                'message' => 'إجراء غير معروف',
                'available_actions' => ['config', 'broadcast', 'poll', 'cleanup']
            ]);
    }
    
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'خطأ: ' . $e->getMessage()
    ]);
}
