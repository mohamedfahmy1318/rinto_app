-- Add model translation columns to cars table
ALTER TABLE `cars` 
ADD COLUMN `model_ar` VARCHAR(255) DEFAULT NULL AFTER `model`,
ADD COLUMN `model_en` VARCHAR(255) DEFAULT NULL AFTER `model_ar`,
ADD COLUMN `model_he` VARCHAR(255) DEFAULT NULL AFTER `model_en`;

-- Update existing records to have model_ar same as model
UPDATE `cars` SET `model_ar` = `model` WHERE `model_ar` IS NULL AND `model` IS NOT NULL;
