-- Add region_id and city_id columns to users table
-- Run this migration to add location fields to users

ALTER TABLE `users` 
ADD COLUMN `region_id` int(10) UNSIGNED NULL AFTER `user_type`,
ADD COLUMN `city_id` int(10) UNSIGNED NULL AFTER `region_id`;

-- Add foreign key constraints
ALTER TABLE `users`
ADD CONSTRAINT `users_region_fk` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON DELETE SET NULL,
ADD CONSTRAINT `users_city_fk` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`) ON DELETE SET NULL;

-- Add index for faster queries
ALTER TABLE `users`
ADD INDEX `idx_user_city` (`city_id`),
ADD INDEX `idx_user_region` (`region_id`);
