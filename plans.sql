-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Mar 09, 2026 at 11:39 PM
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
-- Table structure for table `plans`
--

CREATE TABLE `plans` (
  `id` int(10) UNSIGNED NOT NULL,
  `category` enum('properties','cars') NOT NULL,
  `name_ar` varchar(255) NOT NULL,
  `name_en` varchar(255) NOT NULL,
  `name_he` varchar(255) NOT NULL,
  `description_ar` text DEFAULT NULL,
  `description_en` text DEFAULT NULL,
  `description_he` text DEFAULT NULL,
  `plan_type` enum('single','package') DEFAULT 'single',
  `property_type_id` int(10) UNSIGNED DEFAULT NULL,
  `car_type_id` int(10) UNSIGNED DEFAULT NULL,
  `property_type` varchar(50) DEFAULT NULL,
  `car_usage_type` varchar(50) DEFAULT NULL,
  `listings_count` int(11) DEFAULT NULL,
  `is_unlimited` tinyint(1) DEFAULT 0,
  `max_images` int(11) DEFAULT 10,
  `duration_days` int(11) DEFAULT 30,
  `price` decimal(10,2) NOT NULL,
  `original_price` decimal(10,2) DEFAULT NULL,
  `discount_percent` int(11) DEFAULT NULL,
  `currency` varchar(10) DEFAULT 'ILS',
  `badge` enum('bronze','silver','gold') DEFAULT NULL,
  `is_featured` tinyint(1) DEFAULT 0,
  `allow_region_notifications` tinyint(1) DEFAULT 0,
  `allow_city_notifications` tinyint(1) DEFAULT 0,
  `is_trusted_advertiser` tinyint(1) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  `is_welcome_bonus` tinyint(1) DEFAULT 0,
  `welcome_bonus_once` tinyint(1) DEFAULT 1,
  `sort_order` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `plans`
--

INSERT INTO `plans` (`id`, `category`, `name_ar`, `name_en`, `name_he`, `description_ar`, `description_en`, `description_he`, `plan_type`, `property_type_id`, `car_type_id`, `property_type`, `car_usage_type`, `listings_count`, `is_unlimited`, `max_images`, `duration_days`, `price`, `original_price`, `discount_percent`, `currency`, `badge`, `is_featured`, `allow_region_notifications`, `allow_city_notifications`, `is_trusted_advertiser`, `is_active`, `is_welcome_bonus`, `welcome_bonus_once`, `sort_order`, `created_at`, `updated_at`) VALUES
(1, 'properties', 'إعلان شقة 7 ايام', '  Apartment Ad 7Days ', 'מודעת דירה 7 ימים', NULL, NULL, NULL, 'single', 1, NULL, NULL, NULL, 1, 0, 10, 7, 100.00, 150.00, 20, 'ILS', NULL, 0, 0, 1, 0, 1, 0, 1, 1, '2026-01-21 23:56:25', '2026-03-09 00:36:38'),
(2, 'properties', 'إعلان فيلا واحد', 'Single Villa Ad', 'מודעת וילה בודדת', NULL, NULL, NULL, 'single', 4, NULL, 'villa_chalet', NULL, 15, 0, 10, 30, 100.00, NULL, NULL, 'ILS', NULL, 0, 0, 0, 0, 1, 0, 1, 2, '2026-01-21 23:56:25', '2026-02-22 23:57:13'),
(3, 'properties', 'إعلان محل واحد', 'Single Shop Ad', 'מודעת חנות בודדת', NULL, NULL, NULL, 'single', 6, NULL, 'shop_office', NULL, 30, 0, 10, 30, 75.00, NULL, NULL, 'ILS', NULL, 0, 0, 0, 0, 1, 0, 1, 3, '2026-01-21 23:56:25', '2026-02-22 23:57:13'),
(4, 'properties', 'باقة برونزية', 'Bronze Package', 'חבילת ברונזה', NULL, NULL, NULL, 'package', NULL, NULL, NULL, NULL, 5, 0, 10, 8, 230.00, 285.00, 18, 'ILS', 'bronze', 0, 0, 0, 0, 1, 0, 1, 1, '2026-01-21 23:56:25', '2026-03-08 22:28:34'),
(5, 'properties', 'باقة فضية', 'Silver Package', 'חבילת כסף', NULL, NULL, NULL, 'package', NULL, NULL, NULL, NULL, 10, 0, 10, 30, 350.00, 500.00, 30, 'ILS', 'silver', 0, 0, 0, 0, 1, 0, 1, 2, '2026-01-21 23:56:25', '2026-02-23 20:24:55'),
(6, 'properties', 'باقة ذهبية', 'Gold Package', 'חבילת זהב', NULL, NULL, NULL, 'package', 4, NULL, NULL, NULL, 1000000, 0, 10, 30, 500.00, 750.00, 33, 'ILS', 'gold', 1, 0, 0, 0, 1, 0, 1, 3, '2026-01-21 23:56:25', '2026-02-23 20:25:05'),
(7, 'cars', 'إعلان سيارة يومية', 'Daily Car Ad', 'מודעת רכב יומית', NULL, NULL, NULL, 'single', NULL, 1, NULL, NULL, 1, 0, 10, 30, 40.00, NULL, NULL, 'ILS', NULL, 0, 0, 0, 0, 0, 0, 1, 1, '2026-01-21 23:56:25', '2026-03-08 22:42:20'),
(8, 'cars', 'إعلان سيارة أعراس', 'Wedding Car Ad', 'מודעת רכב לחתונות', NULL, NULL, NULL, 'single', NULL, 2, NULL, 'wedding', 1, 0, 10, 30, 60.00, NULL, NULL, 'ILS', NULL, 0, 0, 0, 0, 1, 0, 1, 2, '2026-01-21 23:56:25', '2026-02-22 23:57:13'),
(9, 'cars', 'إعلان سيارة سياحية', 'Tourism Car Ad', 'מודעת רכב לתיירות', NULL, NULL, NULL, 'single', NULL, 3, NULL, 'tourism', 1, 0, 10, 30, 80.00, NULL, NULL, 'ILS', NULL, 0, 0, 0, 0, 1, 0, 1, 3, '2026-01-21 23:56:25', '2026-02-22 23:57:13'),
(10, 'cars', 'باقة سيارات برونزية', 'Bronze Cars Package', 'חבילת רכבים ברונזה', NULL, NULL, NULL, 'package', NULL, NULL, NULL, NULL, 5, 0, 10, 30, 150.00, 200.00, 25, 'ILS', 'bronze', 0, 0, 0, 0, 1, 0, 1, 4, '2026-01-21 23:56:25', '2026-01-21 23:56:25'),
(11, 'cars', 'باقة سيارات فضية', 'Silver Cars Package', 'חבילת רכבים כסף', NULL, NULL, NULL, 'package', NULL, NULL, NULL, NULL, 10, 0, 10, 30, 280.00, 400.00, 30, 'ILS', 'silver', 0, 0, 0, 0, 1, 0, 1, 5, '2026-01-21 23:56:25', '2026-01-21 23:56:25'),
(12, 'cars', 'باقة سيارات ذهبية', 'Gold Cars Package', 'חבילת רכבים זהב', NULL, NULL, NULL, 'package', NULL, NULL, NULL, NULL, NULL, 1, 10, 30, 400.00, 600.00, 33, 'ILS', 'gold', 1, 0, 0, 0, 1, 0, 1, 6, '2026-01-21 23:56:25', '2026-01-21 23:56:25'),
(14, 'properties', 'باقة مجانية', 'Single Apartment Ad', 'מודעת דירה בודדת', NULL, NULL, NULL, 'single', NULL, NULL, NULL, NULL, 1, 0, 3, 5, 0.00, NULL, NULL, 'ILS', NULL, 0, 0, 0, 0, 1, 1, 1, 0, '2026-02-16 12:12:13', '2026-02-26 08:33:21'),
(15, 'properties', 'tamer', 'tamer', 'tamer', NULL, NULL, NULL, 'single', NULL, NULL, NULL, NULL, 1, 1, 10, 1, 1122.00, NULL, NULL, 'ILS', NULL, 0, 0, 0, 0, 0, 0, 1, 0, '2026-02-16 12:13:59', '2026-02-16 13:28:33'),
(16, 'cars', 'باقة مجانية سيارات', 'Single Apartment Ad', 'מודעת דירה בודדת', NULL, NULL, NULL, 'single', NULL, NULL, NULL, NULL, 1, 0, 3, 2, 0.00, NULL, NULL, 'ILS', NULL, 0, 0, 0, 0, 1, 1, 1, 0, '2026-02-16 12:41:46', '2026-02-26 08:26:32'),
(17, 'properties', 'سكن طلابي', 'student apartment', 'דירה תלמידום', NULL, NULL, NULL, 'single', 8, NULL, NULL, NULL, 1, 0, 10, 30, 60.00, 100.00, NULL, 'ILS', NULL, 0, 0, 0, 0, 0, 0, 1, 0, '2026-02-17 13:58:51', '2026-03-09 01:01:18'),
(18, 'properties', 'اعلان شقة 30 يوم', '(Apartment ad (30 days', '  פרסום דירה 30 יום', NULL, NULL, NULL, 'single', 1, NULL, NULL, NULL, 1, 0, 10, 30, 300.00, 380.00, 22, 'ILS', NULL, 0, 1, 0, 0, 1, 0, 1, 0, '2026-03-09 00:34:24', '2026-03-09 00:34:24');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `plans`
--
ALTER TABLE `plans`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_category` (`category`),
  ADD KEY `idx_active` (`is_active`),
  ADD KEY `idx_property_type_id` (`property_type_id`),
  ADD KEY `idx_car_type_id` (`car_type_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `plans`
--
ALTER TABLE `plans`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `plans`
--
ALTER TABLE `plans`
  ADD CONSTRAINT `fk_plans_car_type` FOREIGN KEY (`car_type_id`) REFERENCES `car_types` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_plans_property_type` FOREIGN KEY (`property_type_id`) REFERENCES `property_types` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
