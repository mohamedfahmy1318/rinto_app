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
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `ios_product_id` varchar(100) DEFAULT NULL,
  `android_product_id` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `plans`
--

INSERT INTO `plans` (`id`, `category`, `name_ar`, `name_en`, `name_he`, `description_ar`, `description_en`, `description_he`, `plan_type`, `property_type_id`, `car_type_id`, `property_type`, `car_usage_type`, `listings_count`, `is_unlimited`, `max_images`, `duration_days`, `price`, `original_price`, `discount_percent`, `currency`, `badge`, `is_featured`, `allow_region_notifications`, `allow_city_notifications`, `is_trusted_advertiser`, `is_active`, `is_welcome_bonus`, `welcome_bonus_once`, `sort_order`, `created_at`, `updated_at`, `ios_product_id`, `android_product_id`) VALUES
(1, 'cars', 'باقة مجانية مرة واحدة', 'One-time free package', 'חבילה חד פעמית בחינם', NULL, NULL, NULL, 'single', NULL, NULL, NULL, NULL, 50, 0, 10, 14, 0.00, NULL, NULL, 'ILS', NULL, 0, 0, 0, 0, 0, 1, 1, 0, '2026-03-09 23:25:41', '2026-03-13 19:15:27', NULL, NULL),
(2, 'properties', 'باقة مجانية لمرة واحدة ', 'One-time free package', 'חבילה חד פעמית בחינם', NULL, NULL, NULL, 'single', NULL, NULL, NULL, NULL, 1, 0, 3, 7, 0.00, NULL, NULL, 'ILS', NULL, 0, 0, 0, 0, 1, 1, 1, 0, '2026-03-09 23:27:22', '2026-03-14 20:58:47', NULL, NULL),
(3, 'properties', 'إعلان شقة –شهر ', 'Apartment Listing – 30 Days', 'מודעה לדירה יחידה ל 30 ימים', NULL, NULL, NULL, 'single', 1, NULL, NULL, NULL, 1, 0, 20, 30, 119.90, 149.00, 20, 'ILS', NULL, 1, 0, 0, 0, 1, 0, 1, 1, '2026-03-09 23:44:14', '2026-03-23 09:07:53', 'com.rentogo.property.apartment.month', 'com.rentogo.property.apartment.month'),
(4, 'cars', 'اعلان سيارة ايجار يومي واحدة اسبوع', 'daily Car Ad, 7 days', 'מודעת רכב אחת, 7 ימים', NULL, NULL, NULL, 'single', NULL, 1, NULL, NULL, 1, 0, 15, 7, 50.00, 70.00, 29, 'ILS', NULL, 0, 0, 0, 0, 1, 0, 1, 0, '2026-03-09 23:48:09', '2026-03-22 16:30:29', 'com.rentogo.car.daily.week', 'rentogo_car_daily_week'),
(5, 'properties', 'باقة  العقارات البرونزية', 'Bronze Package', 'חבילת ברונזה', NULL, NULL, NULL, 'package', NULL, NULL, NULL, NULL, 10, 0, 10, 30, 250.00, 350.00, 28, 'ILS', 'bronze', 0, 0, 0, 1, 1, 0, 1, 1, '2026-03-10 02:15:59', '2026-03-15 20:29:28', 'com.rentogo.app.property_bronze_package', 'property_bronze_package'),
(6, 'cars', 'باقة مجانية مرة واحدة', 'One-time free package', 'חבילה חד פעמית בחינם', NULL, NULL, NULL, 'package', NULL, NULL, NULL, NULL, 1, 0, 3, 7, 0.00, NULL, NULL, 'ILS', NULL, 0, 0, 0, 0, 0, 0, 1, 0, '2026-03-12 22:47:29', '2026-03-22 16:27:15', NULL, NULL),
(7, 'properties', 'باقة العقارات الفضية', 'Silver Property Package', 'חבילת נדל״ן כסף', NULL, NULL, NULL, 'package', NULL, NULL, NULL, NULL, 20, 0, 15, 30, 450.00, 500.00, 20, 'ILS', 'silver', 1, 1, 0, 1, 1, 0, 1, 2, '2026-03-14 19:49:40', '2026-03-16 22:21:46', 'com.rentogo.app.property_silver_package', 'property_silver_package'),
(8, 'properties', 'باقة العقارات الذهبية', 'Gold Property Package', 'חבילת נדל״ן זהב', NULL, NULL, NULL, 'package', NULL, NULL, NULL, NULL, NULL, 1, 10, 30, 600.00, 899.00, 33, 'ILS', 'gold', 1, 1, 1, 1, 1, 0, 1, 3, '2026-03-14 19:56:05', '2026-03-15 22:37:09', 'com.rentogo.app.property_gold_v2', 'property_gold_package'),
(9, 'cars', 'باقة السيارات البرونزية', 'Bronze Car Package', 'חבילת רכבים ברונזה', NULL, NULL, NULL, 'package', NULL, NULL, NULL, NULL, 10, 0, 15, 30, 250.00, 350.00, 28, 'ILS', 'bronze', 0, 0, 0, 1, 1, 0, 1, 1, '2026-03-14 20:10:31', '2026-03-15 20:58:02', 'com.rentogo.app.car_bronze_package', 'car_bronze_package'),
(10, 'cars', 'باقة السيارات الفضية', 'Silver Car Package', 'חבילת רכבים כסף', NULL, NULL, NULL, 'package', NULL, NULL, NULL, NULL, 30, 0, 15, 30, 450.00, 600.00, 25, 'ILS', 'silver', 1, 1, 0, 1, 1, 0, 1, 2, '2026-03-14 20:15:18', '2026-03-22 15:04:02', 'com.rentogo.app.car_silver_package', 'car_silver_package'),
(11, 'cars', 'باقة السيارات الذهبية', 'Gold Car Package', 'חבילת רכבים זהב', NULL, NULL, NULL, 'package', NULL, NULL, NULL, NULL, NULL, 1, 20, 30, 600.00, 1000.00, 40, 'ILS', 'gold', 1, 1, 1, 1, 1, 0, 1, 3, '2026-03-14 20:24:50', '2026-03-15 23:07:47', 'com.rentogo.app.car_gold_package', 'car_gold_package'),
(12, 'properties', 'إعلان استوديو – أسبوع', 'Studio Listing – 7 Days', 'מודעת סטודיו – שבוע', NULL, NULL, NULL, 'single', 1, NULL, NULL, NULL, 1, 0, 10, 7, 50.00, 60.00, 20, 'ILS', NULL, 0, 0, 0, 0, 1, 0, 1, 1, '2026-03-14 21:02:25', '2026-03-14 22:49:18', 'com.rentogo.property.studio.week', 'rentogo_property_studio_week'),
(13, 'properties', 'إعلان غرفة – أسبوع', 'Room Listing – 7 Days', 'מודעת חדר – שבוע', NULL, NULL, NULL, 'single', 2, NULL, NULL, NULL, 1, 0, 10, 7, 39.99, 50.00, 20, 'ILS', NULL, 0, 0, 0, 0, 1, 0, 1, 1, '2026-03-14 21:05:02', '2026-03-27 06:38:29', 'com.rentogo.property.room.week', 'rentogo_property_room_week'),
(14, 'properties', 'إعلان غرفة – شهر', 'Room Listing – 30 Days', 'מודעת חדר – חודש', NULL, NULL, NULL, 'single', 2, NULL, NULL, NULL, 1, 0, 10, 30, 70.00, 90.00, 25, 'ILS', NULL, 1, 0, 0, 0, 1, 0, 1, 1, '2026-03-14 21:07:21', '2026-03-14 21:07:21', 'com.rentogo.property.room.month', 'rentogo_property_room_month'),
(15, 'properties', 'إعلان استوديو – شهر', 'Studio Listing – 30 Days', 'מודעת סטודיו – חודש', NULL, NULL, NULL, 'single', NULL, NULL, NULL, NULL, 1, 0, 15, 30, 120.90, 150.00, 23, 'ILS', NULL, 1, 0, 0, 0, 1, 0, 1, 1, '2026-03-14 21:33:37', '2026-03-23 09:17:19', 'com.rentogo.property.studio.month', 'rentogo_property_studio_month'),
(16, 'properties', 'إعلان فيلا أو شاليه – 7 أيام', 'Villa / Chalet Listing – 7 Days', 'מודעת וילה / צימר – 7 ימים', NULL, NULL, NULL, 'single', 4, NULL, NULL, NULL, 1, 0, 15, 7, 80.00, 130.00, 38, 'ILS', NULL, 0, 0, 0, 0, 1, 0, 1, 1, '2026-03-14 21:44:46', '2026-03-14 21:44:46', 'com.rentogo.property.villa.week', 'rentogo_property_villa_week'),
(17, 'properties', 'إعلان فيلا أو شاليه – شهر', 'Villa / Chalet Listing – 30 Days', 'מודעת וילה / צימר – חודש', NULL, NULL, NULL, 'single', 4, NULL, NULL, NULL, 1, 0, 20, 30, 199.90, 250.00, 22, 'ILS', NULL, 1, 1, 0, 0, 1, 0, 1, 1, '2026-03-14 21:47:51', '2026-03-23 09:20:35', 'com.rentogo.property.villa.month', 'rentogo_property_villa_month'),
(18, 'properties', 'إعلان محل تجاري – أسبوع', 'Shop Listing – 7 Days', 'מודעת חנות – שבוע', NULL, NULL, NULL, 'single', 6, NULL, NULL, NULL, 1, 0, 15, 7, 80.00, 100.00, 20, 'ILS', NULL, 0, 0, 0, 0, 1, 0, 1, 1, '2026-03-14 22:16:00', '2026-03-14 22:16:00', 'com.rentogo.property.shop.week', 'rentogo_property_shop_week'),
(19, 'properties', 'إعلان محل تجاري – شهر', 'Shop Listing – 30 Days', 'מודעת חנות – חודש', NULL, NULL, NULL, 'single', 6, NULL, NULL, NULL, 1, 0, 20, 30, 190.00, 250.00, 24, 'ILS', NULL, 1, 1, 0, 0, 1, 0, 1, 1, '2026-03-14 22:19:29', '2026-03-22 15:32:23', 'com.rentogo.property.shop.month', 'rentogo_property_shop_month'),
(20, 'properties', 'إعلان مكتب – 7 أيام', 'Office Listing – 7 Days', 'מודעת משרד – 7 ימים', NULL, NULL, NULL, 'single', 7, NULL, NULL, NULL, 1, 0, 15, 7, 80.00, 100.00, 20, 'ILS', NULL, 1, 0, 0, 0, 1, 0, 1, 1, '2026-03-14 22:31:26', '2026-03-14 22:31:26', 'com.rentogo.property.office.week', 'rentogo_property_office_week'),
(21, 'properties', 'إعلان مكتب – 30 يوم', 'Office Listing – 30 Days', 'מודעת משרד – חודש', NULL, NULL, NULL, 'single', 7, NULL, NULL, NULL, 1, 0, 20, 30, 169.90, 200.00, 15, 'ILS', NULL, 1, 1, 0, 0, 1, 0, 1, 1, '2026-03-14 22:35:08', '2026-03-23 09:32:20', 'com.rentogo.property.office.month', 'rentogo_property_office_month'),
(22, 'properties', 'إعلان مبنى – أسبوع', 'Building Listing – 7 Days', 'מודעת בניין – שבוע', NULL, NULL, NULL, 'single', 10, NULL, NULL, NULL, 1, 0, 15, 7, 120.00, 150.00, 20, 'ILS', NULL, 1, 1, 0, 0, 1, 0, 1, 1, '2026-03-14 22:39:22', '2026-03-14 22:39:22', 'com.rentogo.property.building.week', 'rentogo_property_building_week'),
(23, 'properties', 'إعلان مبنى – شهر', 'Building Listing – 30 Days', 'מודעת בניין – חודש', NULL, NULL, NULL, 'single', NULL, NULL, NULL, NULL, 1, 0, 20, 30, 299.90, 399.00, 20, 'ILS', NULL, 1, 1, 1, 1, 1, 0, 1, 1, '2026-03-14 22:41:53', '2026-03-23 09:43:48', 'com.rentogo.property.building.month', 'rentogo_property_building_month'),
(24, 'properties', 'إعلان أرض – أسبوع', 'Land Listing – 7 Days', 'מודעת קרקע – שבוע', NULL, NULL, NULL, 'single', 9, NULL, NULL, NULL, 1, 0, 15, 7, 70.00, 90.00, 20, 'ILS', NULL, 1, 0, 0, 0, 1, 0, 1, 1, '2026-03-14 22:44:22', '2026-03-14 22:44:22', 'com.rentogo.property.land.week', 'rentogo_property_land_week'),
(25, 'properties', 'إعلان أرض – شهر', 'Land Listing – 30 Days', 'מודעת קרקע – חודש', NULL, NULL, NULL, 'single', 9, NULL, NULL, NULL, 1, 0, 20, 30, 199.90, 250.00, 20, 'ILS', NULL, 1, 0, 1, 0, 1, 0, 1, 1, '2026-03-14 22:46:06', '2026-03-23 09:39:12', 'com.rentogo.property.land.month', 'rentogo_property_land_month'),
(26, 'properties', 'إعلان سكن طلابي – أسبوع', 'Student Housing – 7 Days Listing', 'מודעת דיור סטודנטים – שבוע', NULL, NULL, NULL, 'single', 8, NULL, NULL, NULL, 1, 0, 15, 7, 35.00, 50.00, 30, 'ILS', NULL, 0, 0, 0, 0, 1, 0, 1, 1, '2026-03-14 22:48:57', '2026-03-14 22:48:57', 'com.rentogo.property.student.week', 'rentogo_property_student_week'),
(27, 'properties', 'إعلان سكن طلابي – شهر', 'Student Housing – 30 Days Listing', 'מודעת דיור סטודנטים – חודש', NULL, NULL, NULL, 'single', 8, NULL, NULL, NULL, 1, 0, 20, 30, 69.99, 119.99, 41, 'ILS', NULL, 1, 0, 1, 0, 1, 0, 1, 0, '2026-03-14 22:59:22', '2026-03-24 07:28:41', 'com.rentogo.property.student.month', 'rentogo_property_student_month'),
(28, 'cars', 'إعلان سيارة تأجير يومي – شهر', 'Daily Rental Car – 30 Days', 'מודעת רכב להשכרה יומית – חודש', NULL, NULL, NULL, 'single', NULL, 1, NULL, NULL, 1, 0, 20, 30, 99.90, 120.00, 16, 'ILS', NULL, 1, 0, 0, 1, 1, 0, 1, 1, '2026-03-14 23:08:54', '2026-03-23 09:57:16', 'com.rentogo.car.daily.month', 'rentogo_car_daily_month'),
(29, 'cars', 'إعلان سيارة فخمة أو مناسبات – أسبوع', 'Luxury / Event Car – 7 Days', 'מודעת רכב יוקרה / אירועים – שבוע', NULL, NULL, NULL, 'single', NULL, 2, NULL, NULL, 1, 0, 15, 7, 99.00, 130.00, 23, 'ILS', NULL, 1, 0, 1, 1, 1, 0, 1, 0, '2026-03-15 00:29:46', '2026-03-22 16:28:28', 'com.rentogo.car.luxury.week', 'rentogo_car_luxury_week'),
(30, 'cars', 'إعلان سيارة فخمة أو مناسبات – شهر', 'Luxury / Event Car – 30 Days', 'מודעת רכב יוקרה / אירועים – חודש', NULL, NULL, NULL, 'single', NULL, 2, NULL, NULL, 1, 0, 20, 30, 199.90, 250.00, 20, 'ILS', NULL, 1, 1, 0, 1, 1, 0, 1, 1, '2026-03-15 00:33:53', '2026-03-23 10:01:20', 'com.rentogo.car.luxury.month', 'rentogo_car_luxury_month'),
(31, 'cars', 'إعلان خدمات نقل – أسبوع', 'Transport Service – 7 Days', 'מודעת שירותי הסעה – שבוע', NULL, NULL, NULL, 'single', NULL, 5, NULL, NULL, 1, 0, 15, 7, 59.00, 75.00, 21, 'ILS', NULL, 0, 0, 0, 0, 1, 0, 1, 1, '2026-03-15 00:44:59', '2026-03-15 00:44:59', 'com.rentogo.car.transport.week', 'rentogo_car_transport_week'),
(32, 'cars', 'إعلان خدمات نقل – شهر', 'Transport Service – 30 Days', 'מודעת שירותי הסעה – חודש', NULL, NULL, NULL, 'single', NULL, 5, NULL, NULL, 1, 0, 20, 30, 109.90, 140.00, 22, 'ILS', NULL, 1, 0, 0, 1, 1, 0, 1, 1, '2026-03-15 00:48:32', '2026-03-23 10:11:03', 'com.rentogo.car.transport.month', 'rentogo_car_transport_month'),
(33, 'cars', 'إعلان سيارة إيجار بالساعة – أسبوع', 'Hourly Car Rental – 7 Days', 'מודעת רכב להשכרה לפי שעה – שבוע', NULL, NULL, NULL, 'single', NULL, 6, NULL, NULL, 1, 0, 15, 30, 50.00, 59.00, 17, 'ILS', NULL, 0, 0, 0, 0, 1, 0, 1, 1, '2026-03-15 00:51:46', '2026-03-15 00:51:46', 'com.rentogo.car.hourly.week', 'rentogo_car_hourly_week'),
(34, 'cars', 'إعلان سيارة إيجار بالساعة – شهر', 'Hourly Car Rental – 30 Days', 'מודעת רכב להשכרה לפי שעה – חודש', NULL, NULL, NULL, 'single', NULL, 6, NULL, NULL, 1, 0, 20, 30, 100.00, 120.00, 17, 'ILS', NULL, 1, 0, 0, 0, 1, 0, 1, 1, '2026-03-15 00:54:23', '2026-03-23 10:06:14', 'com.rentogo.car.hourly.month', 'rentogo_car_hourly_month');

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
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

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
