-- Migration: Add daily/weekly/monthly pricing for properties (like cars table)
-- Date: 2026-03-31

ALTER TABLE `properties` 
ADD COLUMN `price_daily` DECIMAL(12,2) DEFAULT NULL AFTER `price_to`,
ADD COLUMN `price_weekly` DECIMAL(12,2) DEFAULT NULL AFTER `price_daily`,
ADD COLUMN `price_monthly` DECIMAL(12,2) DEFAULT NULL AFTER `price_weekly`;

-- Migrate existing price data to price_monthly for current records
UPDATE `properties` SET `price_monthly` = `price` WHERE `price` IS NOT NULL;
