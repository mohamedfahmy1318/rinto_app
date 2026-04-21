-- Migration: Add missing columns for subscription purchase flow
-- Run this on your production database

-- 1. Update subscriptions table
ALTER TABLE `subscriptions` 
    MODIFY COLUMN `status` ENUM('active', 'expired', 'cancelled', 'pending_verification', 'rejected') DEFAULT 'active',
    ADD COLUMN IF NOT EXISTS `category` VARCHAR(20) NULL AFTER `plan_id`,
    ADD COLUMN IF NOT EXISTS `payment_method` VARCHAR(50) NULL AFTER `is_unlimited`,
    ADD COLUMN IF NOT EXISTS `payment_reference` VARCHAR(255) NULL AFTER `payment_method`;

-- Add index for category
ALTER TABLE `subscriptions` ADD INDEX IF NOT EXISTS `idx_category` (`category`);

-- 2. Update payments table
ALTER TABLE `payments`
    ADD COLUMN IF NOT EXISTS `payment_method` VARCHAR(50) NULL AFTER `platform`,
    ADD COLUMN IF NOT EXISTS `sender_name` VARCHAR(255) NULL AFTER `receipt_data`,
    ADD COLUMN IF NOT EXISTS `transfer_date` DATE NULL AFTER `sender_name`;

-- Update payments status enum to include 'rejected'
ALTER TABLE `payments`
    MODIFY COLUMN `status` ENUM('pending', 'completed', 'failed', 'refunded', 'rejected') DEFAULT 'pending';
