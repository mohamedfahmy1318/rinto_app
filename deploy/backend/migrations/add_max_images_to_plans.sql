-- Add max_images column to plans table
-- This controls the maximum number of images allowed per listing based on the subscription plan

ALTER TABLE plans ADD COLUMN max_images INT DEFAULT 10 AFTER is_unlimited;

-- Update welcome bonus (free) plans to allow only 3 images
UPDATE plans SET max_images = 3 WHERE is_welcome_bonus = 1;

-- Update paid plans to allow 10 images (or keep default)
UPDATE plans SET max_images = 10 WHERE is_welcome_bonus = 0 OR is_welcome_bonus IS NULL;
