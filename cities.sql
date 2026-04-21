-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 06, 2026 at 11:11 PM
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
-- Table structure for table `cities`
--

CREATE TABLE `cities` (
  `id` int(10) UNSIGNED NOT NULL,
  `region_id` int(10) UNSIGNED NOT NULL,
  `name_ar` varchar(255) NOT NULL,
  `name_en` varchar(255) NOT NULL,
  `name_he` varchar(255) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `sort_order` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `cities`
--

INSERT INTO `cities` (`id`, `region_id`, `name_ar`, `name_en`, `name_he`, `slug`, `is_active`, `sort_order`, `created_at`) VALUES
(1, 1, 'رام الله', 'Ramallah', 'רמאללה', 'ramallah', 1, 1, '2026-01-22 19:00:01'),
(2, 1, 'نابلس', 'Nablus', 'שכם', 'nablus', 1, 2, '2026-01-22 19:00:01'),
(3, 1, 'الخليل', 'Hebron', 'חברון', 'hebron', 1, 3, '2026-01-22 19:00:01'),
(4, 1, 'بيت لحم', 'Bethlehem', 'בית לחם', 'bethlehem', 1, 4, '2026-01-22 19:00:01'),
(5, 1, 'جنين', 'Jenin', 'ג׳נין', 'jenin', 1, 5, '2026-01-22 19:00:01'),
(6, 1, 'طولكرم', 'Tulkarm', 'טול כרם', 'tulkarm', 1, 6, '2026-01-22 19:00:01'),
(7, 1, 'قلقيلية', 'Qalqilya', 'קלקיליה', 'qalqilya', 1, 7, '2026-01-22 19:00:01'),
(8, 1, 'سلفيت', 'Salfit', 'סלפית', 'salfit', 1, 8, '2026-01-22 19:00:01'),
(9, 1, 'طوباس', 'Tubas', 'טובאס', 'tubas', 1, 9, '2026-01-22 19:00:01'),
(10, 1, 'أريحا', 'Jericho', 'יריחו', 'jericho', 1, 10, '2026-01-22 19:00:01'),
(11, 2, 'القدس', 'Jerusalem', 'ירושלים', 'jerusalem-city', 1, 1, '2026-01-22 19:00:01'),
(12, 2, 'العيزرية', 'Al-Eizariya', 'אל-עיזריה', 'al-eizariya', 1, 2, '2026-01-22 19:00:01'),
(13, 2, 'أبو ديس', 'Abu Dis', 'אבו דיס', 'abu-dis', 1, 3, '2026-01-22 19:00:01'),
(14, 3, 'حيفا', 'Haifa', 'חיפה', 'haifa', 1, 1, '2026-01-22 19:00:01'),
(15, 3, 'يافا', 'Jaffa', 'יפו', 'jaffa', 1, 2, '2026-01-22 19:00:01'),
(16, 3, 'الناصرة', 'Nazareth', 'נצרת', 'nazareth', 1, 3, '2026-01-22 19:00:01'),
(17, 3, 'عكا', 'Acre', 'עכו', 'acre', 1, 4, '2026-01-22 19:00:01'),
(18, 3, 'اللد', 'Lod', 'לוד', 'lod', 1, 5, '2026-01-22 19:00:01'),
(19, 3, 'الرملة', 'Ramla', 'רמלה', 'ramla', 1, 6, '2026-01-22 19:00:01'),
(20, 4, 'بئر السبع', 'Beersheba', 'באר שבע', 'beersheba', 1, 1, '2026-01-22 19:00:01'),
(21, 4, 'رهط', 'Rahat', 'רהט', 'rahat', 1, 2, '2026-01-22 19:00:01');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cities`
--
ALTER TABLE `cities`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_city_region` (`region_id`,`slug`),
  ADD KEY `idx_region` (`region_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `cities`
--
ALTER TABLE `cities`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `cities`
--
ALTER TABLE `cities`
  ADD CONSTRAINT `cities_ibfk_1` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
