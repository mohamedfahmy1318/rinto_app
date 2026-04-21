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
-- Table structure for table `properties`
--

CREATE TABLE `properties` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `property_type` enum('apartment','shop_office','villa_chalet','student_housing','land') NOT NULL,
  `region_id` int(10) UNSIGNED NOT NULL,
  `city_id` int(10) UNSIGNED NOT NULL,
  `address_text` varchar(500) DEFAULT NULL,
  `price_type` enum('fixed','range','negotiable') DEFAULT 'fixed',
  `price` decimal(12,2) DEFAULT NULL,
  `price_from` decimal(12,2) DEFAULT NULL,
  `price_to` decimal(12,2) DEFAULT NULL,
  `currency` varchar(10) DEFAULT 'ILS',
  `bedrooms` int(11) DEFAULT NULL,
  `bathrooms` int(11) DEFAULT NULL,
  `floor` int(11) DEFAULT NULL,
  `area_m2` decimal(10,2) DEFAULT NULL,
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
-- Dumping data for table `properties`
--

INSERT INTO `properties` (`id`, `user_id`, `title`, `property_type`, `region_id`, `city_id`, `address_text`, `price_type`, `price`, `price_from`, `price_to`, `currency`, `bedrooms`, `bathrooms`, `floor`, `area_m2`, `bio`, `contact_phone`, `whatsapp`, `status`, `reject_reason`, `views_count`, `subscription_id`, `expires_at`, `created_at`, `updated_at`) VALUES
(1, 4, 'شقة فاخرة في وسط المدينة', 'apartment', 1, 1, NULL, 'fixed', 3500.00, NULL, NULL, 'ILS', 3, 2, NULL, 120.00, 'شقة مميزة بإطلالة رائعة، قريبة من جميع الخدمات، 3 غرف نوم مع صالة واسعة', '+972504567890', NULL, 'active', NULL, 0, NULL, '2026-02-21 19:00:01', '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(2, 4, 'شقة عائلية واسعة', 'apartment', 1, 2, NULL, 'fixed', 4200.00, NULL, NULL, 'ILS', 4, 2, NULL, 150.00, 'شقة مناسبة للعائلات، 4 غرف نوم مع صالة كبيرة وبلكونة', '+972504567890', NULL, 'active', NULL, 0, NULL, '2026-02-21 19:00:01', '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(3, 5, 'استوديو مفروش بالكامل', 'apartment', 2, 5, NULL, 'fixed', 2000.00, NULL, NULL, 'ILS', 1, 1, NULL, 45.00, 'استوديو حديث مجهز بالكامل للإيجار الشهري، مناسب للعزاب', '+972505678901', NULL, 'active', NULL, 0, NULL, '2026-02-21 19:00:01', '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(4, 5, 'سكن طلابي قرب الجامعة', 'student_housing', 2, 6, NULL, 'fixed', 1200.00, NULL, NULL, 'ILS', 1, 1, NULL, 20.00, 'غرفة مفروشة في شقة مشتركة، قريبة من الجامعة والمواصلات', '+972505678901', NULL, 'active', NULL, 0, NULL, '2026-02-21 19:00:01', '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(5, 6, 'شقة جديدة تشطيب سوبر ديلوكس', 'apartment', 1, 3, NULL, 'fixed', 5000.00, NULL, NULL, 'ILS', 3, 2, NULL, 130.00, 'شقة جديدة لم تسكن من قبل، تشطيب فاخر مع مصعد وموقف سيارة', '+972506789012', NULL, 'active', NULL, 0, NULL, '2026-02-21 19:00:01', '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(6, 9, 'فيلا فاخرة مع مسبح خاص', 'villa_chalet', 3, 9, NULL, 'fixed', 12000.00, NULL, NULL, 'ILS', 5, 4, NULL, 350.00, 'فيلا راقية مع حديقة ومسبح، مناسبة للعائلات الكبيرة', '+972509012345', NULL, 'active', NULL, 0, NULL, '2026-02-21 19:00:01', '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(7, 9, 'شاليه على البحر مباشرة', 'villa_chalet', 3, 10, NULL, 'fixed', 8000.00, NULL, NULL, 'ILS', 3, 2, NULL, 150.00, 'شاليه رائع بإطلالة مباشرة على البحر، مثالي للعطلات', '+972509012345', NULL, 'active', NULL, 0, NULL, '2026-02-21 19:00:01', '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(8, 10, 'محل تجاري في موقع استراتيجي', 'shop_office', 1, 1, NULL, 'fixed', 6000.00, NULL, NULL, 'ILS', 0, 1, NULL, 80.00, 'محل بواجهة زجاجية كبيرة على الشارع الرئيسي، موقع ممتاز', '+972500123456', NULL, 'active', NULL, 0, NULL, '2026-02-21 19:00:01', '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(9, 10, 'مكتب مجهز في برج تجاري', 'shop_office', 2, 5, NULL, 'fixed', 4500.00, NULL, NULL, 'ILS', 0, 2, NULL, 100.00, 'مكتب جاهز للاستخدام مع قاعة اجتماعات ومطبخ صغير', '+972500123456', NULL, 'active', NULL, 0, NULL, '2026-02-21 19:00:01', '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(10, 4, 'أرض للإيجار صالحة للزراعة', 'land', 3, 11, NULL, 'fixed', 3000.00, NULL, NULL, 'ILS', 0, 0, NULL, 5000.00, 'أرض واسعة مع مصدر مياه، مناسبة للمشاريع الزراعية', '+972504567890', NULL, 'active', NULL, 0, NULL, '2026-02-21 19:00:01', '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(11, 5, 'غرفة في سكن طلابي مشترك', 'student_housing', 2, 6, NULL, 'fixed', 1500.00, NULL, NULL, 'ILS', 1, 1, NULL, 25.00, 'غرفة مفروشة مع إنترنت ومرافق مشتركة', '+972505678901', NULL, 'active', NULL, 0, NULL, '2026-02-21 19:00:01', '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(12, 6, 'شقة للإيجار بسعر مناسب', 'apartment', 1, 4, NULL, 'fixed', 2800.00, NULL, NULL, 'ILS', 2, 1, NULL, 85.00, 'شقة نظيفة ومرتبة في منطقة هادئة', '+972506789012', NULL, 'active', NULL, 0, NULL, '2026-02-21 19:00:01', '2026-01-22 19:00:01', '2026-01-22 19:00:01');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `properties`
--
ALTER TABLE `properties`
  ADD PRIMARY KEY (`id`),
  ADD KEY `city_id` (`city_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_property_type` (`property_type`),
  ADD KEY `idx_region_city` (`region_id`,`city_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_expires` (`expires_at`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `properties`
--
ALTER TABLE `properties`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `properties`
--
ALTER TABLE `properties`
  ADD CONSTRAINT `properties_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `properties_ibfk_2` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`),
  ADD CONSTRAINT `properties_ibfk_3` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
