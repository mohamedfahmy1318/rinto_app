-- Migration: Add multilingual fields for properties and cars
-- Date: 2026-03-06
-- Description: Add title and bio fields for Arabic, Hebrew, and English languages

-- =====================================================
-- PROPERTIES TABLE
-- =====================================================

-- Add multilingual title fields
ALTER TABLE `properties` 
ADD COLUMN `title_ar` VARCHAR(255) NULL AFTER `title`,
ADD COLUMN `title_en` VARCHAR(255) NULL AFTER `title_ar`,
ADD COLUMN `title_he` VARCHAR(255) NULL AFTER `title_en`;

-- Add multilingual bio/description fields
ALTER TABLE `properties`
ADD COLUMN `bio_ar` TEXT NULL AFTER `bio`,
ADD COLUMN `bio_en` TEXT NULL AFTER `bio_ar`,
ADD COLUMN `bio_he` TEXT NULL AFTER `bio_en`;

-- Update language enum to include English
ALTER TABLE `properties` 
MODIFY COLUMN `language` ENUM('ar', 'he', 'en') DEFAULT 'ar';

-- Migrate existing data to new fields based on original language
UPDATE `properties` SET 
    `title_ar` = `title`,
    `bio_ar` = `bio`
WHERE `language` = 'ar' OR `language` IS NULL;

UPDATE `properties` SET 
    `title_he` = `title`,
    `bio_he` = `bio`
WHERE `language` = 'he';

-- =====================================================
-- CARS TABLE
-- =====================================================

-- Add multilingual title fields
ALTER TABLE `cars` 
ADD COLUMN `title_ar` VARCHAR(255) NULL AFTER `title`,
ADD COLUMN `title_en` VARCHAR(255) NULL AFTER `title_ar`,
ADD COLUMN `title_he` VARCHAR(255) NULL AFTER `title_en`;

-- Add multilingual bio/description fields
ALTER TABLE `cars`
ADD COLUMN `bio_ar` TEXT NULL AFTER `bio`,
ADD COLUMN `bio_en` TEXT NULL AFTER `bio_ar`,
ADD COLUMN `bio_he` TEXT NULL AFTER `bio_en`;

-- Update language enum to include English
ALTER TABLE `cars` 
MODIFY COLUMN `language` ENUM('ar', 'he', 'en') DEFAULT 'ar';

-- Migrate existing data to new fields based on original language
UPDATE `cars` SET 
    `title_ar` = `title`,
    `bio_ar` = `bio`
WHERE `language` = 'ar' OR `language` IS NULL;

UPDATE `cars` SET 
    `title_he` = `title`,
    `bio_he` = `bio`
WHERE `language` = 'he';

-- =====================================================
-- ADMIN BANNERS TABLE (if needed)
-- =====================================================

-- Add multilingual fields for admin banners
ALTER TABLE `admin_banners` 
ADD COLUMN `title_ar` VARCHAR(255) NULL AFTER `title`,
ADD COLUMN `title_en` VARCHAR(255) NULL AFTER `title_ar`,
ADD COLUMN `title_he` VARCHAR(255) NULL AFTER `title_en`,
ADD COLUMN `description_ar` TEXT NULL AFTER `description`,
ADD COLUMN `description_en` TEXT NULL AFTER `description_ar`,
ADD COLUMN `description_he` TEXT NULL AFTER `description_en`;

-- Migrate existing banner data
UPDATE `admin_banners` SET 
    `title_ar` = `title`,
    `description_ar` = `description`;
