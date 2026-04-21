-- Migration: Add is_approved column to users table
-- Run this on production database

ALTER TABLE `users` ADD COLUMN `is_approved` TINYINT(1) DEFAULT 1 AFTER `is_blocked`;

-- Set existing non-renter accounts to approved (since they were created before this change)
UPDATE `users` SET `is_approved` = 1;

-- For new non-renter accounts, they will be set to is_approved = 0 by the API
