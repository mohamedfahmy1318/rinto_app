-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Mar 31, 2026 at 12:50 PM
-- Server version: 10.11.15-MariaDB
-- PHP Version: 8.4.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `rentogo_1`
--

-- --------------------------------------------------------

--
-- Table structure for table `cars`
--

CREATE TABLE `cars` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `title_ar` varchar(255) DEFAULT NULL,
  `title_en` varchar(255) DEFAULT NULL,
  `title_he` varchar(255) DEFAULT NULL,
  `usage_type` varchar(50) NOT NULL,
  `car_type_id` int(10) UNSIGNED DEFAULT NULL,
  `model` varchar(255) NOT NULL,
  `model_ar` varchar(255) DEFAULT NULL,
  `model_en` varchar(255) DEFAULT NULL,
  `model_he` varchar(255) DEFAULT NULL,
  `year` int(11) DEFAULT NULL,
  `gearbox` enum('manual','automatic') DEFAULT 'automatic',
  `with_driver` tinyint(1) DEFAULT 0,
  `duration_type` enum('daily','weekly','monthly') DEFAULT 'daily',
  `plate_color` enum('yellow','white') DEFAULT 'yellow',
  `region_id` int(10) UNSIGNED NOT NULL,
  `city_id` int(10) UNSIGNED NOT NULL,
  `address_text` varchar(500) DEFAULT NULL,
  `price_type` enum('fixed','range','negotiable') DEFAULT 'fixed',
  `price` decimal(12,2) DEFAULT NULL,
  `price_from` decimal(12,2) DEFAULT NULL,
  `price_to` decimal(12,2) DEFAULT NULL,
  `price_daily` decimal(12,2) DEFAULT NULL,
  `price_weekly` decimal(12,2) DEFAULT NULL,
  `price_monthly` decimal(12,2) DEFAULT NULL,
  `currency` varchar(10) DEFAULT 'ILS',
  `bio` text DEFAULT NULL,
  `bio_ar` text DEFAULT NULL,
  `bio_en` text DEFAULT NULL,
  `bio_he` text DEFAULT NULL,
  `language` enum('ar','he','en') DEFAULT 'ar',
  `contact_phone` varchar(20) NOT NULL,
  `whatsapp` varchar(20) DEFAULT NULL,
  `status` enum('draft','pending_payment','pending_admin_review','active','expired','paused','rejected') DEFAULT 'draft',
  `is_trusted` tinyint(1) DEFAULT 0,
  `is_rented` tinyint(1) DEFAULT 0,
  `reject_reason` text DEFAULT NULL,
  `views_count` int(11) DEFAULT 0,
  `subscription_id` int(10) UNSIGNED DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `cars`
--

INSERT INTO `cars` (`id`, `user_id`, `title`, `title_ar`, `title_en`, `title_he`, `usage_type`, `car_type_id`, `model`, `model_ar`, `model_en`, `model_he`, `year`, `gearbox`, `with_driver`, `duration_type`, `plate_color`, `region_id`, `city_id`, `address_text`, `price_type`, `price`, `price_from`, `price_to`, `price_daily`, `price_weekly`, `price_monthly`, `currency`, `bio`, `bio_ar`, `bio_en`, `bio_he`, `language`, `contact_phone`, `whatsapp`, `status`, `is_trusted`, `is_rented`, `reject_reason`, `views_count`, `subscription_id`, `expires_at`, `created_at`, `updated_at`) VALUES
(1, 2, NULL, '', 'Camry', 'קאמרי', 'wedding', NULL, 'كامري', 'كامري', 'Camry', 'קאמרי', NULL, 'automatic', 0, 'daily', 'yellow', 2, 48, NULL, 'fixed', 200.00, NULL, NULL, 200.00, NULL, NULL, 'ILS', '', '', 'Camry', 'קאמרי', 'ar', '0548724689', '0548724689', 'active', 0, 0, NULL, 31, 5, '2026-03-26 22:45:42', '2026-03-12 22:45:42', '2026-03-26 17:40:58'),
(2, 2, NULL, '', 'Very luxurious car, suitable for events', 'מכונית יוקרתית מאוד, מתאימה לאירועים', 'wedding', NULL, 'camry', 'camry', 'Camry', 'קאמרי', 2000, 'automatic', 1, 'daily', 'yellow', 1, 5, NULL, 'fixed', 1000.00, NULL, NULL, 1000.00, NULL, NULL, 'ILS', 'سيارة فخمة جدا وتصلح للمناسبات \n', 'سيارة فخمة جدا وتصلح للمناسبات \n', 'Very luxurious car and suitable for events', 'מכונית יוקרתית מאוד ומתאימה לאירועים', 'ar', '0548724689', '0548724689', 'active', 0, 0, 'pictures?', 35, 16, '2026-04-14 20:51:09', '2026-03-15 20:51:09', '2026-03-29 19:25:13');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cars`
--
ALTER TABLE `cars`
  ADD PRIMARY KEY (`id`),
  ADD KEY `city_id` (`city_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_usage_type` (`usage_type`),
  ADD KEY `idx_region_city` (`region_id`,`city_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_expires` (`expires_at`),
  ADD KEY `car_type_id` (`car_type_id`),
  ADD KEY `idx_is_rented` (`is_rented`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `cars`
--
ALTER TABLE `cars`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `cars`
--
ALTER TABLE `cars`
  ADD CONSTRAINT `cars_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cars_ibfk_2` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`),
  ADD CONSTRAINT `cars_ibfk_3` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`),
  ADD CONSTRAINT `cars_ibfk_4` FOREIGN KEY (`car_type_id`) REFERENCES `car_types` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
