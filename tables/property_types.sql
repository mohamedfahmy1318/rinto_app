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
-- Table structure for table `property_types`
--

CREATE TABLE `property_types` (
  `id` int(10) UNSIGNED NOT NULL,
  `name_ar` varchar(100) NOT NULL,
  `name_en` varchar(100) NOT NULL,
  `name_he` varchar(100) NOT NULL,
  `slug` varchar(50) NOT NULL,
  `icon` varchar(50) DEFAULT NULL COMMENT 'Icon name for Flutter/Web',
  `is_active` tinyint(1) DEFAULT 1,
  `sort_order` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `property_types`
--

INSERT INTO `property_types` (`id`, `name_ar`, `name_en`, `name_he`, `slug`, `icon`, `is_active`, `sort_order`, `created_at`, `updated_at`) VALUES
(1, 'شقة', 'Apartment', 'דירה', 'apartment', 'apartment', 1, 1, '2026-02-22 23:46:20', '2026-02-23 18:05:00'),
(2, 'غرفة', 'Room', 'חדר', 'room', 'bed', 1, 2, '2026-02-22 23:46:20', '2026-02-22 23:46:20'),
(3, 'استوديو', 'Studio', 'סטודיו', 'studio', 'home', 1, 3, '2026-02-22 23:46:20', '2026-02-22 23:46:20'),
(4, 'فيلا او شاليه', 'Villa or Chalet', 'וילה, שאלה', 'villa or Chalet', 'cabin', 1, 4, '2026-02-22 23:46:20', '2026-03-09 21:33:01'),
(6, 'محل تجاري', 'Shop', 'חנות', 'shop', 'store', 1, 6, '2026-02-22 23:46:20', '2026-02-22 23:46:20'),
(7, 'مكتب', 'Office', 'משרד', 'office', 'work', 1, 7, '2026-02-22 23:46:20', '2026-02-22 23:46:20'),
(8, 'سكن طلاب', 'Student Housing', 'דיור סטודנטים', 'student_housing', 'school', 1, 8, '2026-02-22 23:46:20', '2026-02-22 23:46:20'),
(9, 'أرض', 'Land', 'קרקע', 'land', 'landscape', 1, 9, '2026-02-22 23:46:20', '2026-02-22 23:46:20'),
(10, 'مبنى', 'Building', 'בניין', 'building', 'business', 1, 10, '2026-02-22 23:46:20', '2026-02-22 23:46:20');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `property_types`
--
ALTER TABLE `property_types`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD KEY `idx_active` (`is_active`),
  ADD KEY `idx_sort` (`sort_order`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `property_types`
--
ALTER TABLE `property_types`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
