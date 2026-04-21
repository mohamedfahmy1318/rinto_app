-- Add payment settings to app_settings table
-- Run this migration: mysql -u root rento_go < 006_add_payment_settings.sql

-- Add new columns for payment settings
ALTER TABLE `app_settings` 
ADD COLUMN `setting_group` VARCHAR(50) DEFAULT 'general' AFTER `setting_key`,
ADD COLUMN `setting_type` ENUM('text', 'number', 'boolean', 'json', 'password', 'html') DEFAULT 'text' AFTER `setting_group`,
ADD COLUMN `is_sensitive` BOOLEAN DEFAULT FALSE AFTER `setting_type`,
ADD COLUMN `description` VARCHAR(255) DEFAULT NULL AFTER `is_sensitive`;

-- Add index for setting_group
ALTER TABLE `app_settings` ADD INDEX `idx_setting_group` (`setting_group`);

-- Update existing settings
UPDATE `app_settings` SET `setting_group` = 'content', `setting_type` = 'html' WHERE `setting_key` = 'terms_of_service';
UPDATE `app_settings` SET `setting_group` = 'content', `setting_type` = 'html' WHERE `setting_key` = 'privacy_policy';

-- Insert payment settings
INSERT INTO `app_settings` (`setting_key`, `setting_group`, `setting_type`, `value_ar`, `is_sensitive`, `description`) VALUES
-- General Payment Settings
('payment_mode', 'payment', 'text', 'sandbox', FALSE, 'Payment environment: sandbox or production'),
('payment_currency', 'payment', 'text', 'ILS', FALSE, 'Default payment currency'),

-- Apple Pay Settings
('apple_pay_enabled', 'apple_pay', 'boolean', '0', FALSE, 'Enable Apple Pay payments'),
('apple_pay_merchant_id', 'apple_pay', 'text', '', FALSE, 'Apple Pay Merchant ID'),
('apple_pay_merchant_name', 'apple_pay', 'text', 'Rento Go', FALSE, 'Merchant display name'),
('apple_pay_certificate_path', 'apple_pay', 'text', '', FALSE, 'Path to Apple Pay certificate file (.pem)'),
('apple_pay_certificate_key', 'apple_pay', 'password', '', TRUE, 'Apple Pay certificate private key'),
('apple_pay_merchant_domain', 'apple_pay', 'text', '', FALSE, 'Verified merchant domain'),
('apple_pay_supported_networks', 'apple_pay', 'json', '["visa","masterCard","amex"]', FALSE, 'Supported card networks'),

-- Stripe Settings
('stripe_enabled', 'stripe', 'boolean', '0', FALSE, 'Enable Stripe payments'),
('stripe_publishable_key', 'stripe', 'text', '', FALSE, 'Stripe publishable API key'),
('stripe_secret_key', 'stripe', 'password', '', TRUE, 'Stripe secret API key'),
('stripe_webhook_secret', 'stripe', 'password', '', TRUE, 'Stripe webhook signing secret'),

-- PayPal Settings
('paypal_enabled', 'paypal', 'boolean', '0', FALSE, 'Enable PayPal payments'),
('paypal_client_id', 'paypal', 'text', '', FALSE, 'PayPal client ID'),
('paypal_client_secret', 'paypal', 'password', '', TRUE, 'PayPal client secret'),
('paypal_mode', 'paypal', 'text', 'sandbox', FALSE, 'PayPal mode: sandbox or live'),

-- Notification Settings
('admin_notification_email', 'notifications', 'text', '', FALSE, 'Email for payment notifications'),
('payment_success_webhook', 'notifications', 'text', '', FALSE, 'Webhook URL for successful payments'),
('payment_failed_webhook', 'notifications', 'text', '', FALSE, 'Webhook URL for failed payments');
