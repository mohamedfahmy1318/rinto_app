<?php
/**
 * Notification Controller
 */

class NotificationController {
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
        
        $countSql = "SELECT COUNT(*) as total FROM notifications WHERE user_id = ?";
        $total = (int)$this->db->fetch($countSql, [$auth['user_id']])['total'];
        
        $sql = "SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT $perPage OFFSET $offset";
        $notifications = $this->db->fetchAll($sql, [$auth['user_id']]);
        
        // Get unread count
        $unreadCount = $this->db->fetch(
            "SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND is_read = 0",
            [$auth['user_id']]
        )['count'];
        
        Response::json([
            'success' => true,
            'data' => $notifications,
            'unread_count' => (int)$unreadCount,
            'pagination' => [
                'total' => $total,
                'per_page' => $perPage,
                'current_page' => $page,
                'total_pages' => ceil($total / $perPage)
            ]
        ]);
    }
    
    public function markAsRead($id) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        if ($id === 'all') {
            $this->db->update('notifications', ['is_read' => 1], 'user_id = ?', [$auth['user_id']]);
            Response::success(null, 'All notifications marked as read');
        } else {
            $notification = $this->db->fetch(
                "SELECT * FROM notifications WHERE id = ? AND user_id = ?",
                [$id, $auth['user_id']]
            );
            
            if (!$notification) {
                Response::notFound('Notification not found');
            }
            
            $this->db->update('notifications', ['is_read' => 1], 'id = ?', [$id]);
            Response::success(null, 'Notification marked as read');
        }
    }
    
    public static function send($userId, $type, $data = []) {
        $db = Database::getInstance();
        
        $titles = [
            'listing_approved' => [
                'ar' => 'تم قبول إعلانك',
                'en' => 'Listing Approved',
                'he' => 'המודעה אושרה'
            ],
            'listing_rejected' => [
                'ar' => 'تم رفض إعلانك',
                'en' => 'Listing Rejected',
                'he' => 'המודעה נדחתה'
            ],
            'subscription_approved' => [
                'ar' => 'تم تفعيل اشتراكك',
                'en' => 'Subscription Activated',
                'he' => 'המנוי שלך הופעל'
            ],
            'subscription_expiring' => [
                'ar' => 'اشتراكك ينتهي قريباً',
                'en' => 'Subscription Expiring Soon',
                'he' => 'המנוי עומד לפוג בקרוב'
            ],
            'subscription_expired' => [
                'ar' => 'انتهى اشتراكك',
                'en' => 'Subscription Expired',
                'he' => 'המנוי פג'
            ],
            'account_approved' => [
                'ar' => 'تم تفعيل حسابك',
                'en' => 'Account Approved',
                'he' => 'החשבון שלך אושר'
            ],
            'listing_favorited' => [
                'ar' => 'إعلانك في المفضلة ❤️',
                'en' => 'Your Listing Was Favorited ❤️',
                'he' => 'המודעה שלך נוספה למועדפים ❤️'
            ]
        ];
        
        $bodies = [
            'listing_approved' => [
                'ar' => 'إعلانك الآن متاح للجميع',
                'en' => 'Your listing is now live',
                'he' => 'המודעה שלך זמינה כעת'
            ],
            'listing_rejected' => [
                'ar' => 'يرجى مراجعة سبب الرفض وتعديل الإعلان',
                'en' => 'Please review the rejection reason and update your listing',
                'he' => 'אנא עיין בסיבת הדחייה ועדכן את המודעה'
            ],
            'subscription_approved' => [
                'ar' => 'تم تفعيل اشتراكك بنجاح. يمكنك الآن إضافة إعلاناتك',
                'en' => 'Your subscription is now active. You can now add your listings',
                'he' => 'המנוי שלך פעיל כעת. כעת תוכל להוסיף מודעות'
            ],
            'subscription_expiring' => [
                'ar' => 'سينتهي اشتراكك خلال 3 أيام',
                'en' => 'Your subscription will expire in 3 days',
                'he' => 'המנוי שלך יפוג בעוד 3 ימים'
            ],
            'subscription_expired' => [
                'ar' => 'انتهى اشتراكك. جدد الآن للحفاظ على إعلاناتك',
                'en' => 'Your subscription has expired. Renew now to keep your listings active',
                'he' => 'המנוי שלך פג. חדש עכשיו כדי לשמור על המודעות שלך'
            ],
            'account_approved' => [
                'ar' => 'تم تفعيل حسابك بنجاح. يمكنك الآن تسجيل الدخول',
                'en' => 'Your account has been approved. You can now login',
                'he' => 'החשבון שלך אושר. כעת תוכל להתחבר'
            ],
            'listing_favorited' => [
                'ar' => 'قام شخص ما بإضافة إعلانك إلى المفضلة',
                'en' => 'Someone added your listing to their favorites',
                'he' => 'מישהו הוסיף את המודעה שלך למועדפים'
            ]
        ];
        
        $title = $titles[$type] ?? ['ar' => '', 'en' => '', 'he' => ''];
        $body = $bodies[$type] ?? ['ar' => '', 'en' => '', 'he' => ''];
        
        // Customize body with data
        if ($type === 'listing_rejected' && !empty($data['reason'])) {
            $body['ar'] = 'سبب الرفض: ' . $data['reason'];
            $body['en'] = 'Rejection reason: ' . $data['reason'];
            $body['he'] = 'סיבת הדחייה: ' . $data['reason'];
        }
        
        $db->insert('notifications', [
            'user_id' => $userId,
            'title_ar' => $title['ar'],
            'title_en' => $title['en'],
            'title_he' => $title['he'],
            'body_ar' => $body['ar'],
            'body_en' => $body['en'],
            'body_he' => $body['he'],
            'type' => $type,
            'data' => json_encode($data)
        ]);
        
        // Send push notification via Firebase FCM
        self::sendPushNotification($userId, $type, $title, $body, $data);
    }
    
    private static function sendPushNotification($userId, $type, $titles, $bodies, $data = []) {
        // Send via Firebase FCM
        require_once __DIR__ . '/../../helpers/FCM.php';
        
        $db = Database::getInstance();
        
        // Get user's FCM token and preferred language
        $user = $db->fetch(
            "SELECT fcm_token, preferred_language FROM users WHERE id = ?",
            [$userId]
        );
        
        error_log("FCM DEBUG: Sending notification to user $userId, type: $type");
        
        if (!$user || empty($user['fcm_token'])) {
            error_log("FCM: No token for user $userId - user data: " . json_encode($user));
            return;
        }
        
        error_log("FCM DEBUG: User token found, length: " . strlen($user['fcm_token']));
        
        $lang = $user['preferred_language'] ?? 'ar';
        $title = $titles[$lang] ?? $titles['ar'] ?? '';
        $body = $bodies[$lang] ?? $bodies['ar'] ?? '';
        
        $notificationData = array_merge($data, ['type' => $type]);
        
        // Send via FCM
        $result = FCM::sendToToken($user['fcm_token'], $title, $body, $notificationData);
        error_log("FCM DEBUG: Send result: " . json_encode($result));
    }
    
    /**
     * Notify users in the same city about a new listing
     * Only if the listing owner's subscription allows city notifications
     */
    public static function notifyNewListingInCity($cityId, $listingType, $listingId, $listingTitle, $subscriptionId, $excludeUserId = null) {
        $db = Database::getInstance();
        
        // Check if subscription allows city notifications
        if ($subscriptionId) {
            $subscription = $db->fetch(
                "SELECT s.*, p.allow_city_notifications 
                 FROM subscriptions s 
                 JOIN plans p ON s.plan_id = p.id 
                 WHERE s.id = ?",
                [$subscriptionId]
            );
            
            if (!$subscription || empty($subscription['allow_city_notifications'])) {
                return; // Subscription doesn't allow city notifications
            }
        } else {
            return; // No subscription, no city notifications
        }
        
        // Get city name
        $city = $db->fetch("SELECT name_ar, name_en, name_he FROM cities WHERE id = ?", [$cityId]);
        if (!$city) return;
        
        // Get all users in this city who have notifications enabled (except the listing owner)
        $where = "city_id = ? AND (notifications_enabled = 1 OR notifications_enabled IS NULL)";
        $params = [$cityId];
        
        if ($excludeUserId) {
            $where .= " AND id != ?";
            $params[] = $excludeUserId;
        }
        
        $users = $db->fetchAll("SELECT id, fcm_token, preferred_language, notifications_enabled FROM users WHERE $where", $params);
        
        if (empty($users)) return;
        
        // Prepare notification content
        $typeNames = [
            'property' => ['ar' => 'عقار', 'en' => 'property', 'he' => 'נכס'],
            'car' => ['ar' => 'سيارة', 'en' => 'car', 'he' => 'רכב']
        ];
        
        $typeName = $typeNames[$listingType] ?? $typeNames['property'];
        
        $titles = [
            'ar' => 'إعلان جديد في مدينتك! 🏠',
            'en' => 'New listing in your city! 🏠',
            'he' => 'מודעה חדשה בעיר שלך! 🏠'
        ];
        
        $bodies = [
            'ar' => "تم إضافة {$typeName['ar']} جديد في {$city['name_ar']}",
            'en' => "A new {$typeName['en']} has been added in {$city['name_en']}",
            'he' => "{$typeName['he']} חדש נוסף ב{$city['name_he']}"
        ];
        
        if ($listingTitle) {
            $bodies['ar'] .= ": $listingTitle";
            $bodies['en'] .= ": $listingTitle";
            $bodies['he'] .= ": $listingTitle";
        }
        
        require_once __DIR__ . '/../helpers/FCM.php';
        
        foreach ($users as $user) {
            // Save notification to database
            $db->insert('notifications', [
                'user_id' => $user['id'],
                'title_ar' => $titles['ar'],
                'title_en' => $titles['en'],
                'title_he' => $titles['he'],
                'body_ar' => $bodies['ar'],
                'body_en' => $bodies['en'],
                'body_he' => $bodies['he'],
                'type' => 'new_listing_in_city',
                'data' => json_encode([
                    'listing_type' => $listingType,
                    'listing_id' => $listingId,
                    'city_id' => $cityId
                ]),
                'is_push_sent' => 0
            ]);
            
            // Only send push if user has FCM token and hasn't disabled push notifications
            if (!empty($user['fcm_token']) && $user['notifications_enabled'] != 0) {
                $lang = $user['preferred_language'] ?? 'ar';
                FCM::sendToToken(
                    $user['fcm_token'],
                    $titles[$lang] ?? $titles['ar'],
                    $bodies[$lang] ?? $bodies['ar'],
                    [
                        'type' => 'new_listing_in_city',
                        'listing_type' => $listingType,
                        'listing_id' => (string)$listingId,
                        'city_id' => (string)$cityId
                    ]
                );
                
                // Update notification as push sent
                $db->query(
                    "UPDATE notifications SET is_push_sent = 1 
                     WHERE user_id = ? AND type = 'new_listing_in_city' 
                     AND JSON_EXTRACT(data, '$.listing_id') = ? 
                     ORDER BY id DESC LIMIT 1",
                    [$user['id'], $listingId]
                );
            }
        }
    }
    
    /**
     * Notify users in the same region about a new listing
     * Only if the listing owner's subscription allows region notifications
     */
    public static function notifyNewListingInRegion($regionId, $listingType, $listingId, $listingTitle, $subscriptionId, $excludeUserId = null) {
        $db = Database::getInstance();
        
        // Check if subscription allows region notifications
        if ($subscriptionId) {
            $subscription = $db->fetch(
                "SELECT s.*, p.allow_region_notifications 
                 FROM subscriptions s 
                 JOIN plans p ON s.plan_id = p.id 
                 WHERE s.id = ?",
                [$subscriptionId]
            );
            
            if (!$subscription || empty($subscription['allow_region_notifications'])) {
                return; // Subscription doesn't allow region notifications
            }
        } else {
            return; // No subscription, no region notifications
        }
        
        // Get region name
        $region = $db->fetch("SELECT name_ar, name_en, name_he FROM regions WHERE id = ?", [$regionId]);
        if (!$region) return;
        
        // Get all users in this region who have notifications enabled
        $where = "region_id = ? AND (notifications_enabled = 1 OR notifications_enabled IS NULL)";
        $params = [$regionId];
        
        if ($excludeUserId) {
            $where .= " AND id != ?";
            $params[] = $excludeUserId;
        }
        
        $users = $db->fetchAll("SELECT id, fcm_token, preferred_language, notifications_enabled FROM users WHERE $where", $params);
        
        if (empty($users)) return;
        
        // Prepare notification content
        $typeNames = [
            'property' => ['ar' => 'عقار', 'en' => 'property', 'he' => 'נכס'],
            'car' => ['ar' => 'سيارة', 'en' => 'car', 'he' => 'רכב']
        ];
        
        $typeName = $typeNames[$listingType] ?? $typeNames['property'];
        
        $titles = [
            'ar' => 'إعلان جديد في منطقتك! 🔔',
            'en' => 'New listing in your region! 🔔',
            'he' => 'מודעה חדשה באזור שלך! 🔔'
        ];
        
        $bodies = [
            'ar' => "تم إضافة {$typeName['ar']} جديد في {$region['name_ar']}",
            'en' => "A new {$typeName['en']} has been added in {$region['name_en']}",
            'he' => "{$typeName['he']} חדש נוסף ב{$region['name_he']}"
        ];
        
        if ($listingTitle) {
            $bodies['ar'] .= ": $listingTitle";
            $bodies['en'] .= ": $listingTitle";
            $bodies['he'] .= ": $listingTitle";
        }
        
        require_once __DIR__ . '/../helpers/FCM.php';
        
        foreach ($users as $user) {
            // Always save notification to database (for in-app bell icon)
            $db->insert('notifications', [
                'user_id' => $user['id'],
                'title_ar' => $titles['ar'],
                'title_en' => $titles['en'],
                'title_he' => $titles['he'],
                'body_ar' => $bodies['ar'],
                'body_en' => $bodies['en'],
                'body_he' => $bodies['he'],
                'type' => 'new_listing',
                'data' => json_encode([
                    'listing_type' => $listingType,
                    'listing_id' => $listingId,
                    'region_id' => $regionId
                ]),
                'is_push_sent' => 0
            ]);
            
            // Only send push if user has FCM token and hasn't disabled push notifications
            if (!empty($user['fcm_token']) && $user['notifications_enabled'] != 0) {
                $lang = $user['preferred_language'] ?? 'ar';
                FCM::sendToToken(
                    $user['fcm_token'],
                    $titles[$lang] ?? $titles['ar'],
                    $bodies[$lang] ?? $bodies['ar'],
                    [
                        'type' => 'new_listing',
                        'listing_type' => $listingType,
                        'listing_id' => (string)$listingId,
                        'region_id' => (string)$regionId
                    ]
                );
                
                // Update notification as push sent
                $db->query(
                    "UPDATE notifications SET is_push_sent = 1 
                     WHERE user_id = ? AND type = 'new_listing' 
                     AND JSON_EXTRACT(data, '$.listing_id') = ? 
                     ORDER BY id DESC LIMIT 1",
                    [$user['id'], $listingId]
                );
            }
        }
    }
    
    /**
     * Get unread count for a user
     */
    public function unreadCount() {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $count = $this->db->fetch(
            "SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND is_read = 0",
            [$auth['user_id']]
        )['count'];
        
        Response::success(['unread_count' => (int)$count]);
    }
    
    /**
     * Delete a notification
     */
    public function delete($id) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $notification = $this->db->fetch(
            "SELECT * FROM notifications WHERE id = ? AND user_id = ?",
            [$id, $auth['user_id']]
        );
        
        if (!$notification) {
            Response::notFound('Notification not found');
        }
        
        $this->db->delete('notifications', 'id = ?', [$id]);
        Response::success(null, 'Notification deleted');
    }
}
