-- Migration: Add new_message type to notifications ENUM
-- Date: 2026-02-23
-- Fix for: SQLSTATE[01000]: Warning: 1265 Data truncated for column 'type'

ALTER TABLE `notifications` 
MODIFY COLUMN `type` ENUM(
    'listing_approved', 
    'listing_rejected', 
    'subscription_expiring', 
    'subscription_expired', 
    'subscription_approved',
    'account_approved',
    'admin_message',
    'broadcast',
    'segment_message',
    'region_message',
    'city_message',
    'new_listing',
    'new_message',
    'general'
) NOT NULL;
