-- Migration: Add Notifications System Enhancements
-- Date: 2026-02-16

-- 1. Add allow_region_notifications column to plans table
ALTER TABLE `plans` 
ADD COLUMN IF NOT EXISTS `allow_region_notifications` TINYINT(1) DEFAULT 0 AFTER `is_featured`;

-- 2. Add is_push_sent column to notifications table
ALTER TABLE `notifications` 
ADD COLUMN IF NOT EXISTS `is_push_sent` TINYINT(1) DEFAULT 0 COMMENT 'Whether push notification was sent' AFTER `is_read`;

-- 3. Add new_listing type to notifications ENUM (run manually if needed)
-- ALTER TABLE `notifications` MODIFY COLUMN `type` ENUM('listing_approved','listing_rejected','subscription_approved','subscription_expiring','subscription_expired','account_approved','admin_message','broadcast','segment_message','general','new_listing') NOT NULL;

-- 4. Add notifications_enabled column to users table
ALTER TABLE `users`
ADD COLUMN IF NOT EXISTS `notifications_enabled` TINYINT(1) DEFAULT 1 AFTER `fcm_token`;

-- 5. Add index on created_at for notifications (if not exists)
-- ALTER TABLE `notifications` ADD INDEX IF NOT EXISTS `idx_created` (`created_at`);
