-- Migration: Add welcome bonus plan feature
-- Date: 2026-02-16
-- Description: Allow admin to mark a plan as "welcome bonus" given automatically to new users

-- Add is_welcome_bonus column to plans table
ALTER TABLE `plans` 
ADD COLUMN `is_welcome_bonus` TINYINT(1) DEFAULT 0 AFTER `is_active`;

-- Add has_received_welcome_bonus column to users table
ALTER TABLE `users`
ADD COLUMN `has_received_welcome_bonus` TINYINT(1) DEFAULT 0 AFTER `is_active`;

-- Add is_welcome_bonus column to subscriptions table to track welcome bonus subscriptions
ALTER TABLE `subscriptions`
ADD COLUMN `is_welcome_bonus` TINYINT(1) DEFAULT 0 AFTER `status`;

-- Note: 
-- plans.is_welcome_bonus = 1 means this plan is given automatically to new users
-- users.has_received_welcome_bonus = 1 means user already received the welcome bonus
-- subscriptions.is_welcome_bonus = 1 means this subscription was a welcome bonus
