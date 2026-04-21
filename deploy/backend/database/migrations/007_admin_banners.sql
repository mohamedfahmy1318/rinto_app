-- Admin Banners (Promotional Listings managed by Admin)
-- These appear on home screen and work like regular listings but are admin-controlled

CREATE TABLE IF NOT EXISTS `admin_banners` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `title` VARCHAR(255) NOT NULL,
    `description` TEXT NULL,
    `banner_type` ENUM('property', 'car', 'general') DEFAULT 'property',
    `thumbnail` VARCHAR(500) NULL,
    
    -- Location
    `region_id` INT UNSIGNED NULL,
    `city_id` INT UNSIGNED NULL,
    `address_text` VARCHAR(500) NULL,
    
    -- Price info (optional)
    `price` DECIMAL(12, 2) NULL,
    `price_text` VARCHAR(100) NULL,
    `currency` VARCHAR(10) DEFAULT 'ILS',
    
    -- Property specific fields
    `property_type` ENUM('apartment', 'shop_office', 'villa_chalet', 'student_housing', 'land') NULL,
    `bedrooms` INT NULL,
    `bathrooms` INT NULL,
    `area_m2` DECIMAL(10, 2) NULL,
    `floor` INT NULL,
    
    -- Car specific fields
    `car_model` VARCHAR(255) NULL,
    `car_year` INT NULL,
    `gearbox` ENUM('manual', 'automatic') NULL,
    
    -- Contact info
    `contact_phone` VARCHAR(20) NULL,
    `whatsapp` VARCHAR(20) NULL,
    
    -- Display settings
    `display_order` INT DEFAULT 0,
    `is_active` TINYINT(1) DEFAULT 1,
    `starts_at` TIMESTAMP NULL,
    `ends_at` TIMESTAMP NULL,
    
    -- Metadata
    `views_count` INT DEFAULT 0,
    `created_by` INT UNSIGNED NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (`region_id`) REFERENCES `regions`(`id`) ON DELETE SET NULL,
    FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`) ON DELETE SET NULL,
    FOREIGN KEY (`created_by`) REFERENCES `admin_users`(`id`) ON DELETE SET NULL,
    INDEX `idx_active` (`is_active`),
    INDEX `idx_type` (`banner_type`),
    INDEX `idx_order` (`display_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Banner media (multiple images)
CREATE TABLE IF NOT EXISTS `admin_banner_media` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `banner_id` INT UNSIGNED NOT NULL,
    `media_type` ENUM('image', 'video') DEFAULT 'image',
    `file_path` VARCHAR(500) NOT NULL,
    `sort_order` INT DEFAULT 0,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`banner_id`) REFERENCES `admin_banners`(`id`) ON DELETE CASCADE,
    INDEX `idx_banner` (`banner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
