-- Migration: Update plans table to use dynamic type IDs
-- Date: 2026-02-23
-- Description: Replace ENUM property_type and car_usage_type with foreign keys to dynamic types tables

-- Step 1: Add new columns for dynamic type IDs
ALTER TABLE `plans` 
ADD COLUMN `property_type_id` INT UNSIGNED NULL AFTER `plan_type`,
ADD COLUMN `car_type_id` INT UNSIGNED NULL AFTER `property_type_id`;

-- Step 2: Migrate existing data - map old ENUM values to new type IDs
-- Property types mapping
UPDATE `plans` SET `property_type_id` = (
    SELECT id FROM `property_types` WHERE `slug` = 'apartment' LIMIT 1
) WHERE `property_type` = 'apartment';

UPDATE `plans` SET `property_type_id` = (
    SELECT id FROM `property_types` WHERE `slug` = 'villa' LIMIT 1
) WHERE `property_type` = 'villa_chalet';

UPDATE `plans` SET `property_type_id` = (
    SELECT id FROM `property_types` WHERE `slug` = 'shop' LIMIT 1
) WHERE `property_type` = 'shop_office';

UPDATE `plans` SET `property_type_id` = (
    SELECT id FROM `property_types` WHERE `slug` = 'student_housing' LIMIT 1
) WHERE `property_type` = 'student_housing';

UPDATE `plans` SET `property_type_id` = (
    SELECT id FROM `property_types` WHERE `slug` = 'land' LIMIT 1
) WHERE `property_type` = 'land';

-- Car types mapping
UPDATE `plans` SET `car_type_id` = (
    SELECT id FROM `car_types` WHERE `slug` = 'daily' LIMIT 1
) WHERE `car_usage_type` = 'daily';

UPDATE `plans` SET `car_type_id` = (
    SELECT id FROM `car_types` WHERE `slug` = 'wedding' LIMIT 1
) WHERE `car_usage_type` = 'wedding';

UPDATE `plans` SET `car_type_id` = (
    SELECT id FROM `car_types` WHERE `slug` = 'tourism' LIMIT 1
) WHERE `car_usage_type` = 'tourism';

-- Step 3: Add foreign key constraints
ALTER TABLE `plans`
ADD CONSTRAINT `fk_plans_property_type` FOREIGN KEY (`property_type_id`) REFERENCES `property_types`(`id`) ON DELETE SET NULL,
ADD CONSTRAINT `fk_plans_car_type` FOREIGN KEY (`car_type_id`) REFERENCES `car_types`(`id`) ON DELETE SET NULL;

-- Step 4: Drop old ENUM columns (optional - can keep for backward compatibility)
-- Uncomment these lines after verifying the migration is successful
-- ALTER TABLE `plans` DROP COLUMN `property_type`;
-- ALTER TABLE `plans` DROP COLUMN `car_usage_type`;

-- Add indexes for better query performance
ALTER TABLE `plans` ADD INDEX `idx_property_type_id` (`property_type_id`);
ALTER TABLE `plans` ADD INDEX `idx_car_type_id` (`car_type_id`);
