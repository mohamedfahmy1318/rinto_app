<?php
/**
 * Chat Controller - Handles conversations and messages
 */

class ChatController {
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    /**
     * Get all conversations for the authenticated user
     */
    public function index($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $userId = $auth['user_id'];
        
        $sql = "SELECT c.*, 
                       CASE WHEN c.user1_id = ? THEN u2.name ELSE u1.name END as other_user_name,
                       CASE WHEN c.user1_id = ? THEN u2.id ELSE u1.id END as other_user_id,
                       CASE WHEN c.user1_id = ? THEN u2.profile_image ELSE u1.profile_image END as other_user_image,
                       m.message as last_message,
                       m.sender_id as last_message_sender_id,
                       m.created_at as last_message_time,
                       (SELECT COUNT(*) FROM messages WHERE conversation_id = c.id AND sender_id != ? AND is_read = 0) as unread_count,
                       CASE 
                           WHEN c.listing_type = 'property' THEN p.title
                           WHEN c.listing_type = 'car' THEN COALESCE(car.title, car.model)
                       END as listing_title,
                       CASE 
                          WHEN c.listing_type = 'property' THEN (SELECT file_path FROM property_media WHERE property_id = c.listing_id AND media_type = 'image' ORDER BY sort_order ASC, id ASC LIMIT 1)
                          WHEN c.listing_type = 'car' THEN (SELECT file_path FROM car_media WHERE car_id = c.listing_id AND media_type = 'image' ORDER BY sort_order ASC, id ASC LIMIT 1)
                      END as listing_image
                FROM conversations c
                LEFT JOIN users u1 ON c.user1_id = u1.id
                LEFT JOIN users u2 ON c.user2_id = u2.id
                LEFT JOIN messages m ON m.id = (SELECT id FROM messages WHERE conversation_id = c.id ORDER BY created_at DESC LIMIT 1)
                LEFT JOIN properties p ON c.listing_type = 'property' AND c.listing_id = p.id
                LEFT JOIN cars car ON c.listing_type = 'car' AND c.listing_id = car.id
                WHERE c.user1_id = ? OR c.user2_id = ?
                ORDER BY COALESCE(c.last_message_at, c.created_at) DESC";
        
        $conversations = $this->db->fetchAll($sql, [$userId, $userId, $userId, $userId, $userId, $userId]);
        
        // Get total unread count
        $unreadSql = "SELECT COUNT(*) as count FROM messages m 
                      JOIN conversations c ON m.conversation_id = c.id 
                      WHERE (c.user1_id = ? OR c.user2_id = ?) 
                      AND m.sender_id != ? AND m.is_read = 0";
        $totalUnread = $this->db->fetch($unreadSql, [$userId, $userId, $userId])['count'];
        
        Response::success([
            'conversations' => $conversations,
            'total_unread' => (int)$totalUnread
        ]);
    }
    
    /**
     * Get or create a conversation for a listing
     */
    public function getOrCreate($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $listingType = $input['listing_type'] ?? null;
        $listingId = (int)($input['listing_id'] ?? 0);
        
        if (!$listingType || !$listingId) {
            Response::error('listing_type and listing_id are required');
        }
        
        // Get listing owner
        $table = $listingType === 'car' ? 'cars' : 'properties';
        $listing = $this->db->fetch("SELECT user_id, title FROM $table WHERE id = ?", [$listingId]);
        
        if (!$listing) {
            Response::notFound('Listing not found');
        }
        
        $ownerId = $listing['user_id'];
        $userId = $auth['user_id'];
        
        // Can't chat with yourself
        if ($ownerId == $userId) {
            Response::error('You cannot chat with yourself');
        }
        
        // Check if conversation exists
        $conversation = $this->db->fetch(
            "SELECT * FROM conversations 
             WHERE listing_type = ? AND listing_id = ? 
             AND ((user1_id = ? AND user2_id = ?) OR (user1_id = ? AND user2_id = ?))",
            [$listingType, $listingId, $userId, $ownerId, $ownerId, $userId]
        );
        
        if (!$conversation) {
            // Create new conversation
            $this->db->insert('conversations', [
                'listing_type' => $listingType,
                'listing_id' => $listingId,
                'user1_id' => $userId,
                'user2_id' => $ownerId
            ]);
            $conversationId = $this->db->lastInsertId();
            
            $conversation = $this->db->fetch("SELECT * FROM conversations WHERE id = ?", [$conversationId]);
        }
        
        Response::success($conversation);
    }
    
    /**
     * Get messages for a conversation
     */
    public function messages($conversationId, $input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $userId = $auth['user_id'];
        
        // Verify user is part of conversation
        $conversation = $this->db->fetch(
            "SELECT * FROM conversations WHERE id = ? AND (user1_id = ? OR user2_id = ?)",
            [$conversationId, $userId, $userId]
        );
        
        if (!$conversation) {
            Response::notFound('Conversation not found');
        }
        
        $page = max(1, (int)($input['page'] ?? 1));
        $perPage = min(50, max(1, (int)($input['per_page'] ?? 30)));
        $offset = ($page - 1) * $perPage;
        
        // Get messages
        $sql = "SELECT m.*, u.name as sender_name, u.profile_image as sender_image
                FROM messages m
                LEFT JOIN users u ON m.sender_id = u.id
                WHERE m.conversation_id = ?
                ORDER BY m.created_at DESC
                LIMIT $perPage OFFSET $offset";
        
        $messages = $this->db->fetchAll($sql, [$conversationId]);
        
        // Mark messages as read
        $this->db->query(
            "UPDATE messages SET is_read = 1 WHERE conversation_id = ? AND sender_id != ? AND is_read = 0",
            [$conversationId, $userId]
        );
        
        // Get conversation details
        $otherUserId = $conversation['user1_id'] == $userId ? $conversation['user2_id'] : $conversation['user1_id'];
        $otherUser = $this->db->fetch("SELECT id, name, profile_image FROM users WHERE id = ?", [$otherUserId]);
        
        // Get listing info
        $table = $conversation['listing_type'] === 'car' ? 'cars' : 'properties';
        $listing = $this->db->fetch("SELECT * FROM $table WHERE id = ?", [$conversation['listing_id']]);
        
        // Get chat instructions from settings
        $instructions = $this->db->fetch(
            "SELECT value_ar, value_en, value_he FROM app_settings WHERE setting_key = 'chat_instructions'"
        );
        
        Response::success([
            'messages' => array_reverse($messages),
            'conversation' => $conversation,
            'other_user' => $otherUser,
            'listing' => $listing,
            'instructions' => $instructions ?: null
        ]);
    }
    
    /**
     * Send a message
     */
    public function send($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $conversationId = (int)($input['conversation_id'] ?? 0);
        $message = trim($input['message'] ?? '');
        
        if (!$conversationId || empty($message)) {
            Response::error('conversation_id and message are required');
        }
        
        $userId = $auth['user_id'];
        
        // Verify user is part of conversation
        $conversation = $this->db->fetch(
            "SELECT * FROM conversations WHERE id = ? AND (user1_id = ? OR user2_id = ?)",
            [$conversationId, $userId, $userId]
        );
        
        if (!$conversation) {
            Response::notFound('Conversation not found');
        }
        
        // Insert message
        $this->db->insert('messages', [
            'conversation_id' => $conversationId,
            'sender_id' => $userId,
            'message' => $message
        ]);
        
        $messageId = $this->db->lastInsertId();
        
        // Update conversation last_message_at
        $this->db->update('conversations', 
            ['last_message_at' => date('Y-m-d H:i:s')], 
            'id = ?', 
            [$conversationId]
        );
        
        // Get the inserted message
        $newMessage = $this->db->fetch(
            "SELECT m.*, u.name as sender_name, u.profile_image as sender_image
             FROM messages m
             LEFT JOIN users u ON m.sender_id = u.id
             WHERE m.id = ?",
            [$messageId]
        );
        
        // Send push notification to the other user
        $otherUserId = $conversation['user1_id'] == $userId ? $conversation['user2_id'] : $conversation['user1_id'];
        $this->sendChatNotification($otherUserId, $userId, $message, $conversation);
        
        // Broadcast to realtime polling
        $this->broadcastRealtimeMessage($otherUserId, 'new_chat_message', [
            'conversation_id' => $conversationId,
            'message' => $newMessage
        ]);
        
        Response::success($newMessage);
    }
    
    /**
     * Send chat notification
     */
    private function sendChatNotification($toUserId, $fromUserId, $message, $conversation) {
        // Get sender info
        $sender = $this->db->fetch("SELECT name FROM users WHERE id = ?", [$fromUserId]);
        $senderName = $sender['name'] ?? 'مستخدم';
        
        // Get listing title
        $table = $conversation['listing_type'] === 'car' ? 'cars' : 'properties';
        if ($conversation['listing_type'] === 'car') {
            $listing = $this->db->fetch("SELECT title, model FROM $table WHERE id = ?", [$conversation['listing_id']]);
            $listingTitle = $listing['title'] ?? ($listing['model'] ?? 'سيارة');
        } else {
            $listing = $this->db->fetch("SELECT title FROM $table WHERE id = ?", [$conversation['listing_id']]);
            $listingTitle = $listing['title'] ?? 'عقار';
        }
        
        // Truncate message
        $shortMessage = mb_strlen($message) > 50 ? mb_substr($message, 0, 50) . '...' : $message;
        
        $titles = [
            'ar' => 'رسالة جديدة من ' . $senderName,
            'en' => 'New message from ' . $senderName,
            'he' => 'הודעה חדשה מ' . $senderName
        ];
        
        $bodies = [
            'ar' => 'بخصوص: ' . $listingTitle . "\n" . $shortMessage,
            'en' => 'About: ' . $listingTitle . "\n" . $shortMessage,
            'he' => 'בנוגע ל: ' . $listingTitle . "\n" . $shortMessage
        ];
        
        // Save notification to database
        $this->db->insert('notifications', [
            'user_id' => $toUserId,
            'title_ar' => $titles['ar'],
            'title_en' => $titles['en'],
            'title_he' => $titles['he'],
            'body_ar' => $bodies['ar'],
            'body_en' => $bodies['en'],
            'body_he' => $bodies['he'],
            'type' => 'new_message',
            'data' => json_encode([
                'conversation_id' => $conversation['id'],
                'listing_type' => $conversation['listing_type'],
                'listing_id' => $conversation['listing_id'],
                'sender_id' => $fromUserId
            ])
        ]);
        
        // Send push notification via FCM
        require_once __DIR__ . '/../../helpers/FCM.php';
        
        // Get user's FCM token and preferred language
        $user = $this->db->fetch("SELECT fcm_token, preferred_language FROM users WHERE id = ?", [$toUserId]);
        if ($user && !empty($user['fcm_token'])) {
            $lang = $user['preferred_language'] ?? 'ar';
            FCM::sendToToken(
                $user['fcm_token'],
                $titles[$lang] ?? $titles['ar'],
                $bodies[$lang] ?? $shortMessage,
                [
                    'type' => 'new_message',
                    'conversation_id' => (string)$conversation['id'],
                    'listing_type' => $conversation['listing_type'],
                    'listing_id' => (string)$conversation['listing_id']
                ]
            );
        }
        
        // Also send to user topic
        $lang = ($user['preferred_language'] ?? 'ar');
        FCM::sendToTopic(
            'user_' . $toUserId,
            $titles[$lang] ?? $titles['ar'],
            $bodies[$lang] ?? $shortMessage,
            [
                'type' => 'new_message',
                'conversation_id' => (string)$conversation['id'],
                'listing_type' => $conversation['listing_type'],
                'listing_id' => (string)$conversation['listing_id']
            ]
        );
    }
    
    /**
     * Broadcast message to realtime polling system
     */
    private function broadcastRealtimeMessage($userId, $messageType, $data) {
        try {
            $this->db->insert('realtime_messages', [
                'user_id' => $userId,
                'message_type' => $messageType,
                'message_data' => json_encode($data)
            ]);
        } catch (Exception $e) {
            // Silently fail - realtime is optional
            error_log("Realtime broadcast failed: " . $e->getMessage());
        }
    }
    
    /**
     * Get unread count
     */
    public function unreadCount() {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $userId = $auth['user_id'];
        
        $sql = "SELECT COUNT(*) as count FROM messages m 
                JOIN conversations c ON m.conversation_id = c.id 
                WHERE (c.user1_id = ? OR c.user2_id = ?) 
                AND m.sender_id != ? AND m.is_read = 0";
        
        $result = $this->db->fetch($sql, [$userId, $userId, $userId]);
        
        Response::success(['unread_count' => (int)$result['count']]);
    }
}
