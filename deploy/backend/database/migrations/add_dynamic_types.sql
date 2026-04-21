-- Migration: Add Dynamic Property and Car Types
-- Run this SQL in phpMyAdmin

-- ============================================
-- PROPERTY TYPES (Dynamic Categories)
-- ============================================

CREATE TABLE IF NOT EXISTS `property_types` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name_ar` VARCHAR(100) NOT NULL,
    `name_en` VARCHAR(100) NOT NULL,
    `name_he` VARCHAR(100) NOT NULL,
    `slug` VARCHAR(50) NOT NULL UNIQUE,
    `icon` VARCHAR(50) NULL COMMENT 'Icon name for Flutter/Web',
    `is_active` TINYINT(1) DEFAULT 1,
    `sort_order` INT DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_active` (`is_active`),
    INDEX `idx_sort` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default property types
INSERT INTO `property_types` (`name_ar`, `name_en`, `name_he`, `slug`, `icon`, `sort_order`) VALUES
('شقة', 'Apartment', 'דירה', 'apartment', 'apartment', 1),
('غرفة', 'Room', 'חדר', 'room', 'bed', 2),
('استوديو', 'Studio', 'סטודיו', 'studio', 'home', 3),
('فيلا', 'Villa', 'וילה', 'villa', 'villa', 4),
('شاليه', 'Chalet', 'שאלה', 'chalet', 'cabin', 5),
('محل تجاري', 'Shop', 'חנות', 'shop', 'store', 6),
('مكتب', 'Office', 'משרד', 'office', 'work', 7),
('سكن طلاب', 'Student Housing', 'דיור סטודנטים', 'student_housing', 'school', 8),
('أرض', 'Land', 'קרקע', 'land', 'landscape', 9),
('مبنى', 'Building', 'בניין', 'building', 'business', 10);

-- ============================================
-- CAR TYPES (Dynamic Categories)
-- ============================================

CREATE TABLE IF NOT EXISTS `car_types` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `name_ar` VARCHAR(100) NOT NULL,
    `name_en` VARCHAR(100) NOT NULL,
    `name_he` VARCHAR(100) NOT NULL,
    `slug` VARCHAR(50) NOT NULL UNIQUE,
    `icon` VARCHAR(50) NULL COMMENT 'Icon name for Flutter/Web',
    `is_active` TINYINT(1) DEFAULT 1,
    `sort_order` INT DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_active` (`is_active`),
    INDEX `idx_sort` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default car types
INSERT INTO `car_types` (`name_ar`, `name_en`, `name_he`, `slug`, `icon`, `sort_order`) VALUES
('إيجار يومي', 'Daily Rental', 'השכרה יומית', 'daily', 'calendar_today', 1),
('زفاف', 'Wedding', 'חתונה', 'wedding', 'favorite', 2),
('سياحة', 'Tourism', 'תיירות', 'tourism', 'flight', 3),
('رحلات', 'Trips', 'טיולים', 'trips', 'directions_car', 4),
('نقل', 'Transportation', 'הובלות', 'transportation', 'local_shipping', 5);

-- ============================================
-- MODIFY PROPERTIES TABLE
-- ============================================

-- Add property_type_id column
ALTER TABLE `properties` 
ADD COLUMN `property_type_id` INT UNSIGNED NULL AFTER `property_type`,
ADD FOREIGN KEY (`property_type_id`) REFERENCES `property_types`(`id`) ON DELETE SET NULL;

-- Migrate existing data
UPDATE `properties` p
SET `property_type_id` = (
    SELECT pt.id FROM `property_types` pt 
    WHERE pt.slug = p.property_type 
    OR (p.property_type = 'shop_office' AND pt.slug = 'shop')
    OR (p.property_type = 'villa_chalet' AND pt.slug = 'villa')
    LIMIT 1
);

-- ============================================
-- MODIFY CARS TABLE
-- ============================================

-- Add car_type_id column
ALTER TABLE `cars` 
ADD COLUMN `car_type_id` INT UNSIGNED NULL AFTER `usage_type`,
ADD FOREIGN KEY (`car_type_id`) REFERENCES `car_types`(`id`) ON DELETE SET NULL;

-- Migrate existing data
UPDATE `cars` c
SET `car_type_id` = (
    SELECT ct.id FROM `car_types` ct 
    WHERE ct.slug = c.usage_type
    LIMIT 1
);
