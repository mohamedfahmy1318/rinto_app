-- Add trusted advertiser feature to plans and listings
-- Plans with this feature will mark listings as trusted

-- Add to plans table
ALTER TABLE `plans` ADD COLUMN `is_trusted_advertiser` TINYINT(1) DEFAULT 0 AFTER `allow_city_notifications`;

-- Add to properties table
ALTER TABLE `properties` ADD COLUMN `is_trusted` TINYINT(1) DEFAULT 0 AFTER `status`;

-- Add to cars table  
ALTER TABLE `cars` ADD COLUMN `is_trusted` TINYINT(1) DEFAULT 0 AFTER `status`;
