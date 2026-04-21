-- Migration: Add multiple pricing options for cars (daily, weekly, monthly)
-- Date: 2026-02-16

-- Add pricing columns for cars
ALTER TABLE `cars` 
ADD COLUMN `price_daily` DECIMAL(12,2) DEFAULT NULL AFTER `price_to`,
ADD COLUMN `price_weekly` DECIMAL(12,2) DEFAULT NULL AFTER `price_daily`,
ADD COLUMN `price_monthly` DECIMAL(12,2) DEFAULT NULL AFTER `price_weekly`;

-- Copy existing price to price_daily for existing records
UPDATE `cars` SET `price_daily` = `price` WHERE `price` IS NOT NULL;

-- Note: The existing 'price' column is kept for backward compatibility
-- It will now be used as the primary display price (usually daily)
