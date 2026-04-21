-- Migration: Add language column to properties and cars tables
-- Run this on existing database to add language support

-- Add language column to properties table
ALTER TABLE `properties` 
ADD COLUMN `language` ENUM('ar', 'he') DEFAULT 'ar' AFTER `bio`;

-- Add language column to cars table  
ALTER TABLE `cars` 
ADD COLUMN `language` ENUM('ar', 'he') DEFAULT 'ar' AFTER `bio`;

-- Update existing listings to set language based on user's preferred language
UPDATE `properties` p 
JOIN `users` u ON p.user_id = u.id 
SET p.language = u.preferred_language 
WHERE p.language IS NULL OR p.language = 'ar';

UPDATE `cars` c 
JOIN `users` u ON c.user_id = u.id 
SET c.language = u.preferred_language 
WHERE c.language IS NULL OR c.language = 'ar';
