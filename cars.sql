-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 06, 2026 at 11:12 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `rento_go`
--

-- --------------------------------------------------------

--
-- Table structure for table `cars`
--

CREATE TABLE `cars` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `usage_type` enum('daily','wedding','tourism') NOT NULL,
  `model` varchar(255) NOT NULL,
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
  `currency` varchar(10) DEFAULT 'ILS',
  `bio` text DEFAULT NULL,
  `contact_phone` varchar(20) NOT NULL,
  `whatsapp` varchar(20) DEFAULT NULL,
  `status` enum('draft','pending_payment','pending_admin_review','active','expired','paused','rejected') DEFAULT 'draft',
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

INSERT INTO `cars` (`id`, `user_id`, `title`, `usage_type`, `model`, `year`, `gearbox`, `with_driver`, `duration_type`, `plate_color`, `region_id`, `city_id`, `address_text`, `price_type`, `price`, `price_from`, `price_to`, `currency`, `bio`, `contact_phone`, `whatsapp`, `status`, `reject_reason`, `views_count`, `subscription_id`, `expires_at`, `created_at`, `updated_at`) VALUES
(1, 7, 'تويوتا كورولا 2023 للإيجار', 'daily', 'Toyota Corolla 2023', 2023, 'automatic', 0, 'daily', 'yellow', 1, 1, NULL, 'fixed', 150.00, NULL, NULL, 'ILS', 'سيارة اقتصادية مناسبة للتنقل اليومي، نظيفة ومكيفة', '+972507890123', NULL, 'active', NULL, 0, NULL, '2026-02-21 19:00:01', '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(2, 7, 'هيونداي النترا موديل 2022', 'daily', 'Hyundai Elantra 2022', 2022, 'automatic', 0, 'daily', 'yellow', 2, 5, NULL, 'fixed', 140.00, NULL, NULL, 'ILS', 'سيارة عائلية مريحة وموفرة للوقود', '+972507890123', NULL, 'active', NULL, 0, NULL, '2026-02-21 19:00:01', '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(3, 8, 'كيا سبورتاج SUV 2023', 'daily', 'Kia Sportage 2023', 2023, 'automatic', 0, 'daily', 'yellow', 1, 2, NULL, 'fixed', 200.00, NULL, NULL, 'ILS', 'سيارة دفع رباعي مناسبة للعائلات والرحلات', '+972508901234', NULL, 'active', NULL, 0, NULL, '2026-02-21 19:00:01', '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(4, 8, 'مازدا CX-5 فل كامل', 'daily', 'Mazda CX-5 2022', 2022, 'automatic', 0, 'daily', 'yellow', 2, 6, NULL, 'fixed', 220.00, NULL, NULL, 'ILS', 'سيارة أنيقة بمواصفات عالية وتجهيزات كاملة', '+972508901234', NULL, 'active', NULL, 0, NULL, '2026-02-21 19:00:01', '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(5, 7, 'مرسيدس S-Class للأعراس', 'wedding', 'Mercedes S-Class 2023', 2023, 'automatic', 1, 'daily', 'yellow', 1, 1, NULL, 'fixed', 800.00, NULL, NULL, 'ILS', 'سيارة فاخرة للأعراس والمناسبات الخاصة مع سائق محترف', '+972507890123', NULL, 'active', NULL, 0, NULL, '2026-02-21 19:00:01', '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(6, 8, 'بي ام دبليو الفئة السابعة', 'wedding', 'BMW 7 Series 2022', 2022, 'automatic', 1, 'daily', 'yellow', 2, 5, NULL, 'fixed', 750.00, NULL, NULL, 'ILS', 'سيارة فارهة للأعراس مع زينة كاملة وسائق', '+972508901234', NULL, 'active', NULL, 0, NULL, '2026-02-21 19:00:01', '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(7, 10, 'رولز رويس للأعراس الملكية', 'wedding', 'Rolls Royce Ghost 2021', 2021, 'automatic', 1, 'daily', 'yellow', 1, 1, NULL, 'fixed', 1500.00, NULL, NULL, 'ILS', 'أفخم سيارة للأعراس، تجربة ملكية لا تنسى', '+972500123456', NULL, 'active', NULL, 0, NULL, '2026-02-21 19:00:01', '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(8, 7, 'لاند كروزر للرحلات السياحية', 'tourism', 'Toyota Land Cruiser 2023', 2023, 'automatic', 1, 'daily', 'yellow', 3, 9, NULL, 'fixed', 350.00, NULL, NULL, 'ILS', 'سيارة دفع رباعي مثالية للرحلات والسفاري مع سائق', '+972507890123', NULL, 'active', NULL, 0, NULL, '2026-02-21 19:00:01', '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(9, 8, 'جيب رانجلر للمغامرات', 'tourism', 'Jeep Wrangler 2022', 2022, 'automatic', 0, 'daily', 'yellow', 3, 10, NULL, 'fixed', 300.00, NULL, NULL, 'ILS', 'سيارة مثالية للطرق الوعرة والتخييم', '+972508901234', NULL, 'active', NULL, 0, NULL, '2026-02-21 19:00:01', '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(10, 10, 'مرسيدس V-Class للسياحة', 'tourism', 'Mercedes V-Class 2023', 2023, 'automatic', 1, 'daily', 'yellow', 1, 1, NULL, 'fixed', 400.00, NULL, NULL, 'ILS', 'فان فاخر يتسع لـ 7 أشخاص مع أمتعة، مثالي للمجموعات', '+972500123456', NULL, 'active', NULL, 0, NULL, '2026-02-21 19:00:01', '2026-01-22 19:00:01', '2026-01-22 19:00:01');

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
  ADD KEY `idx_expires` (`expires_at`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `cars`
--
ALTER TABLE `cars`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `cars`
--
ALTER TABLE `cars`
  ADD CONSTRAINT `cars_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cars_ibfk_2` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`),
  ADD CONSTRAINT `cars_ibfk_3` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
