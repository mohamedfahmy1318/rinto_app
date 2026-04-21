-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Apr 01, 2026 at 05:52 AM
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
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `company_name` varchar(255) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `password` varchar(255) NOT NULL,
  `user_type` enum('renter','owner','office','car_lessor') NOT NULL DEFAULT 'renter',
  `profile_image` varchar(500) DEFAULT NULL,
  `is_verified_phone` tinyint(1) DEFAULT 0,
  `is_verified_email` tinyint(1) DEFAULT 0,
  `is_trusted` tinyint(1) DEFAULT 0,
  `trusted_until` date DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `has_received_welcome_bonus` tinyint(1) DEFAULT 0,
  `is_blocked` tinyint(1) DEFAULT 0,
  `is_approved` tinyint(1) DEFAULT 1,
  `preferred_language` enum('ar','en','he') DEFAULT 'ar',
  `fcm_token` varchar(500) DEFAULT NULL,
  `notifications_enabled` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `region_id` int(10) UNSIGNED DEFAULT NULL,
  `city_id` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `company_name`, `email`, `phone`, `password`, `user_type`, `profile_image`, `is_verified_phone`, `is_verified_email`, `is_trusted`, `trusted_until`, `is_active`, `has_received_welcome_bonus`, `is_blocked`, `is_approved`, `preferred_language`, `fcm_token`, `notifications_enabled`, `created_at`, `updated_at`, `region_id`, `city_id`) VALUES
(1, 'naseem', NULL, 'www.palestine.ieet@gmail.com', '0599940687', '$2y$10$1aZPkogz0UxvOduKHtwIH.7GwgWaVBSc3YylU6ONLEitc28zWm7uW', 'renter', NULL, 0, 0, 0, NULL, 1, 1, 0, 1, 'ar', 'ehsleRFiTtSoWsU14WT4F3:APA91bGrvTv_bRO8Gmg9tHfs0cG7NHlj27PgV7kFaQXnvkVIRJDqEAHj2SZuhKItjVS9iJSAoM79znzE9hUO0J1c_HOO-MUhoD9L6S66HFmMfTLLPTIc_Ec', 1, '2026-03-11 00:28:11', '2026-04-01 03:47:49', 2, 12),
(2, 'mohammad', NULL, 'mhmdkhweis.mk@gmail.com', '0548724689', '$2y$10$I6VPdhtBPxjQXyiXwv3Jne3O67bdlBKv6LYeuDKzNoaTiw923bDLW', 'car_lessor', NULL, 0, 0, 0, NULL, 1, 1, 0, 1, 'ar', 'e33UB-wPS1S7EW3RwFGV2i:APA91bEeNhBUIbGJxotcW3FNsImoy84zfWk7C4gOxlnsvbNTdp6Yq2KOzVSb0hi4QaVki9GxSDDk1n8K6EJB4hTRHDSCh-m8bIC7fGyNSb0OUkiOF5MfBwY', 1, '2026-03-11 21:27:08', '2026-03-22 15:53:54', 2, 11),
(3, 'mohammad2', NULL, 'mohammadkhweis344@gmail.com', '0547840085', '$2y$10$tim01eSnXRXVplpchBwQFOMPPgqkp9fcqsYEF.Nj79L2tPIIDcqLG', 'office', NULL, 0, 0, 0, NULL, 1, 1, 0, 1, 'ar', 'e33UB-wPS1S7EW3RwFGV2i:APA91bEeNhBUIbGJxotcW3FNsImoy84zfWk7C4gOxlnsvbNTdp6Yq2KOzVSb0hi4QaVki9GxSDDk1n8K6EJB4hTRHDSCh-m8bIC7fGyNSb0OUkiOF5MfBwY', 1, '2026-03-11 23:34:47', '2026-03-22 15:53:19', 2, 12),
(4, 'amer', NULL, 'telyhidmi@gmail.com', '0546477951', '$2y$10$McYy/cdBmPr0.OHTl1IFaehuy1CU1aN.8PloligM4khUcDwa5NyIm', 'owner', NULL, 0, 0, 0, NULL, 1, 1, 0, 1, 'ar', 'fetijtluSJuoNcPqKE0FE-:APA91bEZw031rIo9lnIFypCvxmzADnH04NIylfbfXHidzJG5-yulwf0VVXYy67qSzJo1oDWYkoWD-zsVCM0KiXYsxnQ2Rx5WFk9Wx5g73CIMCg706soMD0I', 1, '2026-03-11 23:47:22', '2026-03-11 23:47:23', 2, 11),
(5, 'kelaneps', NULL, 'kelane@info.com', '+972592123424', '$2y$10$G8.B3e5YFNED1Chu3GniMeoMw0ovQ1LLrNWdEybujphxyKPC8DD1q', 'renter', NULL, 0, 0, 0, NULL, 1, 1, 0, 1, 'ar', 'd-pny2r3Q7S9NY6r5xUI-Z:APA91bHubuZn5PbQPhc4wc9Jvjqsqyr9wfv7keGZkYaejKaGG5IbHsAkL3ewSTs_mb-v60qCGkUpmjH4nhUhXeyg9fmbdIaVgo1hNTFY54QVjq7VjvQycEY', 1, '2026-03-12 00:27:34', '2026-03-12 00:27:34', 2, 12),
(6, 'mohammad2', NULL, 'mohammad123@gmail.com', '0528602593', '$2y$10$IXLPTbDnsb88X.K1Z8EvSObrCEHbyYuvi1MYLVvIAmv65WJxqsF4.', 'office', NULL, 0, 0, 0, NULL, 1, 1, 0, 1, 'ar', 'e33UB-wPS1S7EW3RwFGV2i:APA91bEeNhBUIbGJxotcW3FNsImoy84zfWk7C4gOxlnsvbNTdp6Yq2KOzVSb0hi4QaVki9GxSDDk1n8K6EJB4hTRHDSCh-m8bIC7fGyNSb0OUkiOF5MfBwY', 1, '2026-03-22 16:19:16', '2026-03-22 16:19:16', 2, 56);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `phone` (`phone`),
  ADD KEY `idx_user_type` (`user_type`),
  ADD KEY `idx_phone` (`phone`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `users_region_fk` (`region_id`),
  ADD KEY `users_city_fk` (`city_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_city_fk` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `users_region_fk` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
