-- Migration: Add payment method fields for bank transfers
-- Date: 2026-02-16
-- Description: Support bank transfer payments with verification

-- Add payment_method column to subscriptions if not exists
ALTER TABLE `subscriptions` 
ADD COLUMN IF NOT EXISTS `payment_method` VARCHAR(50) DEFAULT 'test' AFTER `status`,
ADD COLUMN IF NOT EXISTS `payment_reference` VARCHAR(100) DEFAULT NULL AFTER `payment_method`;

-- Add new columns to payments table for bank transfer details
ALTER TABLE `payments`
ADD COLUMN IF NOT EXISTS `payment_method` VARCHAR(50) DEFAULT 'test' AFTER `platform`,
ADD COLUMN IF NOT EXISTS `sender_name` VARCHAR(100) DEFAULT NULL AFTER `payment_method`,
ADD COLUMN IF NOT EXISTS `transfer_date` DATE DEFAULT NULL AFTER `sender_name`,
ADD COLUMN IF NOT EXISTS `notes` TEXT DEFAULT NULL AFTER `transfer_date`,
ADD COLUMN IF NOT EXISTS `verified_by` INT DEFAULT NULL AFTER `notes`,
ADD COLUMN IF NOT EXISTS `verified_at` DATETIME DEFAULT NULL AFTER `verified_by`;

-- Update status enum to include pending_verification
-- Note: In MySQL, you may need to modify the column type
-- ALTER TABLE `subscriptions` MODIFY COLUMN `status` ENUM('active', 'expired', 'cancelled', 'pending_verification') DEFAULT 'active';

-- Payment method values:
-- 'test' - Test payment (development)
-- 'bank_transfer' - Bank transfer (pending verification)
-- 'apple_pay' - Apple Pay
-- 'google_pay' - Google Pay
-- 'credit_card' - Credit card (future)
