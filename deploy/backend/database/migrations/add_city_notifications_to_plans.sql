-- Add allow_city_notifications column to plans table
-- This allows plans to send notifications to users in the same city when a listing is added

ALTER TABLE `plans` ADD COLUMN `allow_city_notifications` TINYINT(1) DEFAULT 0 AFTER `allow_region_notifications`;

-- Update comment
-- allow_region_notifications: sends to all users in the region (e.g., West Bank)
-- allow_city_notifications: sends to users in the specific city only (e.g., Ramallah)
