-- Payments table migration
CREATE TABLE IF NOT EXISTS `payments` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `user_id` int(11) NOT NULL,
    `plan_id` int(11) NOT NULL,
    `subscription_id` int(11) DEFAULT NULL,
    `amount` decimal(10,2) NOT NULL,
    `currency` varchar(3) NOT NULL DEFAULT 'ILS',
    `platform` enum('ios','android','web') NOT NULL,
    `transaction_id` varchar(255) NOT NULL,
    `receipt_data` text DEFAULT NULL,
    `status` enum('pending','completed','failed','refunded') NOT NULL DEFAULT 'pending',
    `verified_at` datetime DEFAULT NULL,
    `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
    `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_user_id` (`user_id`),
    KEY `idx_plan_id` (`plan_id`),
    KEY `idx_subscription_id` (`subscription_id`),
    KEY `idx_status` (`status`),
    KEY `idx_transaction_id` (`transaction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
