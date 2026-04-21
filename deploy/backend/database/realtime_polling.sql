-- جدول الرسائل المعلقة للـ Real-time Polling
-- يستخدم كبديل لـ WebSocket

CREATE TABLE IF NOT EXISTS `realtime_messages` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT UNSIGNED NOT NULL,
    `message_type` VARCHAR(50) NOT NULL COMMENT 'new_chat_message, typing, read_receipt, etc',
    `message_data` JSON NOT NULL,
    `is_delivered` TINYINT(1) DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_user_pending` (`user_id`, `is_delivered`),
    INDEX `idx_created` (`created_at`),
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- تنظيف تلقائي للرسائل القديمة (اختياري - يمكن تشغيله كـ Cron Job)
-- DELETE FROM realtime_messages WHERE created_at < DATE_SUB(NOW(), INTERVAL 1 HOUR);
