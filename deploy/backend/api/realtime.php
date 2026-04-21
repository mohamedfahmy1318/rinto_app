<?php
/**
 * ================================================
 * Real-time Polling API - بديل WebSocket
 * ================================================
 * 
 * يوفر تحديثات شبه فورية للشات بدون WebSocket
 * التطبيق يسأل كل 3-5 ثوانٍ عن الرسائل الجديدة
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    exit(0);
}

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/helpers/JWT.php';

$db = Database::getInstance();
$action = $_GET['action'] ?? $_POST['action'] ?? '';

try {
    switch ($action) {
        
        /**
         * إعدادات الـ Polling
         */
        case 'config':
            echo json_encode([
                'success' => true,
                'data' => [
                    'polling_interval' => 3000, // 3 ثوانٍ
                    'max_messages_per_poll' => 50,
                    'message_types' => [
                        'new_chat_message',
                        'typing',
                        'read_receipt',
                        'new_listing_nearby',
                        'listing_update'
                    ]
                ]
            ]);
            break;
            
        /**
         * جلب الرسائل الجديدة للمستخدم
         */
        case 'poll':
            $auth = JWT::authenticate();
            if (!$auth) {
                http_response_code(401);
                echo json_encode(['success' => false, 'message' => 'Unauthorized']);
                exit;
            }
            
            $userId = $auth['user_id'];
            $lastId = intval($_GET['last_id'] ?? 0);
            $types = $_GET['types'] ?? null; // فلتر حسب النوع (اختياري)
            
            $where = "user_id = ? AND id > ?";
            $params = [$userId, $lastId];
            
            if ($types) {
                $typeList = explode(',', $types);
                $placeholders = implode(',', array_fill(0, count($typeList), '?'));
                $where .= " AND message_type IN ($placeholders)";
                $params = array_merge($params, $typeList);
            }
            
            $sql = "SELECT id, message_type, message_data, created_at
                    FROM realtime_messages
                    WHERE $where
                    ORDER BY id ASC
                    LIMIT 50";
            
            $messages = $db->fetchAll($sql, $params);
            
            // تحويل JSON
            foreach ($messages as &$msg) {
                $msg['message_data'] = json_decode($msg['message_data'], true);
            }
            
            // تحديث كـ delivered
            if (!empty($messages)) {
                $ids = array_column($messages, 'id');
                $placeholders = implode(',', array_fill(0, count($ids), '?'));
                $db->query("UPDATE realtime_messages SET is_delivered = 1 WHERE id IN ($placeholders)", $ids);
            }
            
            $newLastId = count($messages) > 0 ? $messages[count($messages) - 1]['id'] : $lastId;
            
            echo json_encode([
                'success' => true,
                'messages' => $messages,
                'last_id' => $newLastId,
                'timestamp' => time()
            ]);
            break;
            
        /**
         * بث رسالة لمستخدم (يُستدعى من ChatController)
         */
        case 'broadcast':
            // للاستخدام الداخلي فقط
            $input = json_decode(file_get_contents('php://input'), true);
            
            $userId = $input['user_id'] ?? 0;
            $messageType = $input['message_type'] ?? '';
            $messageData = $input['message_data'] ?? [];
            
            if (!$userId || !$messageType) {
                echo json_encode(['success' => false, 'message' => 'user_id and message_type required']);
                exit;
            }
            
            $db->insert('realtime_messages', [
                'user_id' => $userId,
                'message_type' => $messageType,
                'message_data' => json_encode($messageData)
            ]);
            
            echo json_encode(['success' => true, 'id' => $db->lastInsertId()]);
            break;
            
        /**
         * تنظيف الرسائل القديمة (Cron Job)
         */
        case 'cleanup':
            $deleted = $db->query(
                "DELETE FROM realtime_messages WHERE created_at < DATE_SUB(NOW(), INTERVAL 1 HOUR)"
            );
            
            echo json_encode(['success' => true, 'deleted' => $deleted->rowCount()]);
            break;
            
        /**
         * عدد الرسائل غير المستلمة
         */
        case 'pending_count':
            $auth = JWT::authenticate();
            if (!$auth) {
                http_response_code(401);
                echo json_encode(['success' => false, 'message' => 'Unauthorized']);
                exit;
            }
            
            $count = $db->fetch(
                "SELECT COUNT(*) as count FROM realtime_messages WHERE user_id = ? AND is_delivered = 0",
                [$auth['user_id']]
            );
            
            echo json_encode(['success' => true, 'count' => (int)$count['count']]);
            break;
            
        default:
            echo json_encode([
                'success' => false,
                'message' => 'Unknown action',
                'available_actions' => ['config', 'poll', 'broadcast', 'cleanup', 'pending_count']
            ]);
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Error: ' . $e->getMessage()
    ]);
}
