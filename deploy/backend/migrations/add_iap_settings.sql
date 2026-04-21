-- =====================================================
-- IAP & Payment Settings Migration
-- Run this to enable In-App Purchase and Payment tracking
-- =====================================================

-- Create settings table if not exists
CREATE TABLE IF NOT EXISTS `settings` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `setting_key` VARCHAR(100) NOT NULL UNIQUE,
    `setting_value` TEXT,
    `setting_group` VARCHAR(50) DEFAULT 'general',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_key` (`setting_key`),
    INDEX `idx_group` (`setting_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- IAP Settings
-- =====================================================

-- Apple IAP settings
INSERT INTO `settings` (`setting_key`, `setting_value`, `setting_group`) VALUES
('apple_shared_secret', '', 'iap'),
('apple_iap_sandbox', '1', 'iap')
ON DUPLICATE KEY UPDATE `setting_group` = 'iap';

-- Google Play settings
INSERT INTO `settings` (`setting_key`, `setting_value`, `setting_group`) VALUES
('google_play_service_account', '', 'iap'),
('google_iap_sandbox', '1', 'iap')
ON DUPLICATE KEY UPDATE `setting_group` = 'iap';

-- =====================================================
-- Payment Methods Settings
-- =====================================================

INSERT INTO `settings` (`setting_key`, `setting_value`, `setting_group`) VALUES
('payment_bank_transfer_enabled', '1', 'payment_methods'),
('payment_apple_iap_enabled', '1', 'payment_methods'),
('payment_google_iap_enabled', '1', 'payment_methods'),
('payment_test_enabled', '1', 'payment_methods')
ON DUPLICATE KEY UPDATE `setting_group` = 'payment_methods';

-- Bank transfer details
INSERT INTO `settings` (`setting_key`, `setting_value`, `setting_group`) VALUES
('bank_name', 'بنك فلسطين', 'bank_details'),
('bank_account_name', 'RentoGo للخدمات', 'bank_details'),
('bank_account_number', '1234567890', 'bank_details'),
('bank_iban', 'PS00PALS000000001234567890', 'bank_details'),
('bank_branch', 'الفرع الرئيسي', 'bank_details')
ON DUPLICATE KEY UPDATE `setting_group` = 'bank_details';

-- =====================================================
-- Enhance payments table for better tracking
-- =====================================================

-- Add new columns for detailed payment tracking
ALTER TABLE `payments` 
    ADD COLUMN IF NOT EXISTS `invoice_number` VARCHAR(50) NULL AFTER `id`,
    ADD COLUMN IF NOT EXISTS `fee_amount` DECIMAL(10,2) DEFAULT 0 AFTER `amount`,
    ADD COLUMN IF NOT EXISTS `net_amount` DECIMAL(10,2) DEFAULT 0 AFTER `fee_amount`,
    ADD COLUMN IF NOT EXISTS `ip_address` VARCHAR(45) NULL AFTER `platform`,
    ADD COLUMN IF NOT EXISTS `user_agent` VARCHAR(500) NULL AFTER `ip_address`,
    ADD COLUMN IF NOT EXISTS `environment` ENUM('sandbox', 'production') DEFAULT 'production' AFTER `payment_method`,
    ADD COLUMN IF NOT EXISTS `store_transaction_id` VARCHAR(255) NULL AFTER `transaction_id`,
    ADD COLUMN IF NOT EXISTS `product_id` VARCHAR(100) NULL AFTER `store_transaction_id`,
    ADD COLUMN IF NOT EXISTS `receipt_url` VARCHAR(500) NULL AFTER `receipt_data`,
    ADD COLUMN IF NOT EXISTS `error_code` VARCHAR(50) NULL AFTER `status`,
    ADD COLUMN IF NOT EXISTS `error_message` TEXT NULL AFTER `error_code`,
    ADD COLUMN IF NOT EXISTS `refund_reason` VARCHAR(255) NULL AFTER `error_message`,
    ADD COLUMN IF NOT EXISTS `refunded_at` TIMESTAMP NULL AFTER `refund_reason`,
    ADD COLUMN IF NOT EXISTS `refunded_amount` DECIMAL(10,2) DEFAULT 0 AFTER `refunded_at`;

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS `idx_status` ON `payments` (`status`);
CREATE INDEX IF NOT EXISTS `idx_payment_method` ON `payments` (`payment_method`);
CREATE INDEX IF NOT EXISTS `idx_created_at` ON `payments` (`created_at`);
CREATE INDEX IF NOT EXISTS `idx_invoice` ON `payments` (`invoice_number`);

-- =====================================================
-- Payment Logs Table (for detailed audit trail)
-- =====================================================

CREATE TABLE IF NOT EXISTS `payment_logs` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `payment_id` INT UNSIGNED NOT NULL,
    `action` ENUM('created', 'processing', 'completed', 'failed', 'refunded', 'disputed', 'cancelled') NOT NULL,
    `status_from` VARCHAR(50) NULL,
    `status_to` VARCHAR(50) NULL,
    `amount` DECIMAL(10,2) NULL,
    `message` TEXT NULL,
    `raw_response` JSON NULL,
    `ip_address` VARCHAR(45) NULL,
    `performed_by` INT UNSIGNED NULL COMMENT 'admin_id if manual, NULL if automatic',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_payment_id` (`payment_id`),
    INDEX `idx_action` (`action`),
    INDEX `idx_created_at` (`created_at`),
    FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Invoices Table (for formal invoicing)
-- =====================================================

CREATE TABLE IF NOT EXISTS `invoices` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `invoice_number` VARCHAR(50) NOT NULL UNIQUE,
    `user_id` INT UNSIGNED NOT NULL,
    `payment_id` INT UNSIGNED NULL,
    `subscription_id` INT UNSIGNED NULL,
    `type` ENUM('purchase', 'refund', 'credit_note') DEFAULT 'purchase',
    `subtotal` DECIMAL(10,2) NOT NULL,
    `tax_rate` DECIMAL(5,2) DEFAULT 0,
    `tax_amount` DECIMAL(10,2) DEFAULT 0,
    `discount_amount` DECIMAL(10,2) DEFAULT 0,
    `total` DECIMAL(10,2) NOT NULL,
    `currency` VARCHAR(10) DEFAULT 'ILS',
    `status` ENUM('draft', 'issued', 'paid', 'cancelled', 'refunded') DEFAULT 'draft',
    `issued_at` TIMESTAMP NULL,
    `paid_at` TIMESTAMP NULL,
    `due_date` DATE NULL,
    `billing_name` VARCHAR(100) NULL,
    `billing_email` VARCHAR(100) NULL,
    `billing_phone` VARCHAR(20) NULL,
    `billing_address` TEXT NULL,
    `notes` TEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_user_id` (`user_id`),
    INDEX `idx_payment_id` (`payment_id`),
    INDEX `idx_status` (`status`),
    INDEX `idx_issued_at` (`issued_at`),
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`payment_id`) REFERENCES `payments`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Invoice Items Table
-- =====================================================

CREATE TABLE IF NOT EXISTS `invoice_items` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `invoice_id` INT UNSIGNED NOT NULL,
    `description` VARCHAR(255) NOT NULL,
    `quantity` INT DEFAULT 1,
    `unit_price` DECIMAL(10,2) NOT NULL,
    `total` DECIMAL(10,2) NOT NULL,
    `plan_id` INT UNSIGNED NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_invoice_id` (`invoice_id`),
    FOREIGN KEY (`invoice_id`) REFERENCES `invoices`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- Financial Summary View (for reports)
-- =====================================================

CREATE OR REPLACE VIEW `v_payment_summary` AS
SELECT 
    DATE(p.created_at) as payment_date,
    p.payment_method,
    p.status,
    COUNT(*) as transaction_count,
    SUM(p.amount) as gross_amount,
    SUM(p.fee_amount) as total_fees,
    SUM(p.net_amount) as net_amount,
    SUM(CASE WHEN p.status = 'refunded' THEN p.refunded_amount ELSE 0 END) as refunded_amount
FROM payments p
GROUP BY DATE(p.created_at), p.payment_method, p.status;

-- =====================================================
-- Monthly Revenue View
-- =====================================================

CREATE OR REPLACE VIEW `v_monthly_revenue` AS
SELECT 
    YEAR(p.created_at) as year,
    MONTH(p.created_at) as month,
    p.payment_method,
    COUNT(CASE WHEN p.status = 'completed' THEN 1 END) as successful_transactions,
    COUNT(CASE WHEN p.status = 'failed' THEN 1 END) as failed_transactions,
    SUM(CASE WHEN p.status = 'completed' THEN p.amount ELSE 0 END) as gross_revenue,
    SUM(CASE WHEN p.status = 'completed' THEN p.fee_amount ELSE 0 END) as total_fees,
    SUM(CASE WHEN p.status = 'completed' THEN p.net_amount ELSE 0 END) as net_revenue,
    SUM(CASE WHEN p.status = 'refunded' THEN p.refunded_amount ELSE 0 END) as total_refunds
FROM payments p
GROUP BY YEAR(p.created_at), MONTH(p.created_at), p.payment_method;
