-- Add is_rented column to properties and cars tables
-- Run this migration to enable the "Rented" feature

-- Add is_rented to properties table
ALTER TABLE `properties` ADD COLUMN `is_rented` TINYINT(1) DEFAULT 0 AFTER `is_trusted`;

-- Add is_rented to cars table  
ALTER TABLE `cars` ADD COLUMN `is_rented` TINYINT(1) DEFAULT 0 AFTER `is_trusted`;

-- Add index for faster queries
ALTER TABLE `properties` ADD INDEX `idx_is_rented` (`is_rented`);
ALTER TABLE `cars` ADD INDEX `idx_is_rented` (`is_rented`);
