-- Add In-App Purchase Product IDs to plans table
-- Run this migration to enable IAP support

ALTER TABLE plans 
ADD COLUMN ios_product_id VARCHAR(100) DEFAULT NULL AFTER sort_order,
ADD COLUMN android_product_id VARCHAR(100) DEFAULT NULL AFTER ios_product_id;

-- Add index for faster lookups
ALTER TABLE plans ADD INDEX idx_ios_product_id (ios_product_id);
ALTER TABLE plans ADD INDEX idx_android_product_id (android_product_id);
