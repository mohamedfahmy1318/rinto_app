-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Feb 23, 2026 at 03:27 AM
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
-- Table structure for table `admin_banners`
--

CREATE TABLE `admin_banners` (
  `id` int(10) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `banner_type` enum('property','car','general') DEFAULT 'property',
  `thumbnail` varchar(500) DEFAULT NULL,
  `region_id` int(10) UNSIGNED DEFAULT NULL,
  `city_id` int(10) UNSIGNED DEFAULT NULL,
  `address_text` varchar(500) DEFAULT NULL,
  `price` decimal(12,2) DEFAULT NULL,
  `price_text` varchar(100) DEFAULT NULL,
  `currency` varchar(10) DEFAULT 'ILS',
  `property_type` enum('apartment','shop_office','villa_chalet','student_housing','land') DEFAULT NULL,
  `bedrooms` int(11) DEFAULT NULL,
  `bathrooms` int(11) DEFAULT NULL,
  `area_m2` decimal(10,2) DEFAULT NULL,
  `floor` int(11) DEFAULT NULL,
  `car_model` varchar(255) DEFAULT NULL,
  `car_year` int(11) DEFAULT NULL,
  `gearbox` enum('manual','automatic') DEFAULT NULL,
  `contact_phone` varchar(20) DEFAULT NULL,
  `whatsapp` varchar(20) DEFAULT NULL,
  `display_order` int(11) DEFAULT 0,
  `is_active` tinyint(1) DEFAULT 1,
  `starts_at` timestamp NULL DEFAULT NULL,
  `ends_at` timestamp NULL DEFAULT NULL,
  `views_count` int(11) DEFAULT 0,
  `created_by` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admin_banners`
--

INSERT INTO `admin_banners` (`id`, `title`, `description`, `banner_type`, `thumbnail`, `region_id`, `city_id`, `address_text`, `price`, `price_text`, `currency`, `property_type`, `bedrooms`, `bathrooms`, `area_m2`, `floor`, `car_model`, `car_year`, `gearbox`, `contact_phone`, `whatsapp`, `display_order`, `is_active`, `starts_at`, `ends_at`, `views_count`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 'tertertert', 'terter', 'property', 'images/banners/699b900ee2d2f_1771802638.jpg', 1, 1, 'treter', 1500.00, 'قابل للتفاوض', 'ILS', NULL, NULL, NULL, NULL, NULL, '', NULL, NULL, '0599940687', '972599940689', 0, 1, '2026-02-22 00:16:00', '2026-02-28 00:16:00', 0, 1, '2026-02-22 23:18:30', '2026-02-22 23:23:58');

-- --------------------------------------------------------

--
-- Table structure for table `admin_banner_media`
--

CREATE TABLE `admin_banner_media` (
  `id` int(10) UNSIGNED NOT NULL,
  `banner_id` int(10) UNSIGNED NOT NULL,
  `media_type` enum('image','video') DEFAULT 'image',
  `file_path` varchar(500) NOT NULL,
  `sort_order` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admin_banner_media`
--

INSERT INTO `admin_banner_media` (`id`, `banner_id`, `media_type`, `file_path`, `sort_order`, `created_at`) VALUES
(1, 1, 'image', 'images/banners/699b900ee2d2f_1771802638.jpg', 0, '2026-02-22 23:23:58');

-- --------------------------------------------------------

--
-- Table structure for table `admin_users`
--

CREATE TABLE `admin_users` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('super_admin','admin','moderator') DEFAULT 'admin',
  `is_active` tinyint(1) DEFAULT 1,
  `last_login` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admin_users`
--

INSERT INTO `admin_users` (`id`, `name`, `email`, `password`, `role`, `is_active`, `last_login`, `created_at`, `updated_at`) VALUES
(1, 'Super Admin', 'admin@rentogo.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'super_admin', 1, '2026-02-23 00:46:02', '2026-01-21 23:56:25', '2026-02-23 01:46:02'),
(2, 'kelane', 'kelaneps2@gmail.com', '$2y$10$iL7Nk3pHZ579g4OB/XwniOTeJOXTu0dfYt0YQ2DL3VD4EXhwc3vJu', 'admin', 1, NULL, '2026-02-16 12:35:42', '2026-02-16 12:35:42');

-- --------------------------------------------------------

--
-- Table structure for table `app_settings`
--

CREATE TABLE `app_settings` (
  `id` int(10) UNSIGNED NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_group` varchar(50) DEFAULT 'general',
  `setting_type` enum('text','number','boolean','json','password','html') DEFAULT 'text',
  `is_sensitive` tinyint(1) DEFAULT 0,
  `description` varchar(255) DEFAULT NULL,
  `value_ar` text DEFAULT NULL,
  `value_en` text DEFAULT NULL,
  `value_he` text DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `app_settings`
--

INSERT INTO `app_settings` (`id`, `setting_key`, `setting_group`, `setting_type`, `is_sensitive`, `description`, `value_ar`, `value_en`, `value_he`, `updated_at`, `updated_by`) VALUES
(1, 'terms_of_service', 'content', 'html', 0, NULL, '<h2>شروط الاستخدام</h2>\r\n<p>مرحباً بك في تطبيق RentoGo. باستخدامك لهذا التطبيق، فإنك توافق على الشروط والأحكام التالية:</p>\r\n<h3>1. القبول بالشروط</h3>\r\n<p>باستخدام هذا التطبيق، فإنك توافق على الالتزام بهذه الشروط والأحكام.</p>\r\n<h3>2. استخدام الخدمة</h3>\r\n<p>يجب استخدام التطبيق للأغراض المشروعة فقط وبما يتوافق مع القوانين المحلية.</p>\r\n<h3>3. حساب المستخدم</h3>\r\n<p>أنت مسؤول عن الحفاظ على سرية معلومات حسابك.</p>\r\n<h3>4. المحتوى</h3>\r\n<p>أنت مسؤول عن أي محتوى تنشره على التطبيق.</p>\r\n<h3>5. إنهاء الخدمة</h3>\r\n<p>نحتفظ بالحق في إنهاء أو تعليق حسابك في أي وقت.</p>', '<h2>Terms of Service</h2>\r\n<p>Welcome to RentoGo. By using this application, you agree to the following terms and conditions:</p>\r\n<h3>1. Acceptance of Terms</h3>\r\n<p>By using this app, you agree to be bound by these terms and conditions.</p>\r\n<h3>2. Use of Service</h3>\r\n<p>The app must be used for lawful purposes only and in compliance with local laws.</p>\r\n<h3>3. User Account</h3>\r\n<p>You are responsible for maintaining the confidentiality of your account information.</p>\r\n<h3>4. Content</h3>\r\n<p>You are responsible for any content you post on the app.</p>\r\n<h3>5. Termination</h3>\r\n<p>We reserve the right to terminate or suspend your account at any time.</p>', '<h2>תנאי שימוש</h2>\r\n<p>ברוכים הבאים ל-RentoGo. בשימוש באפליקציה זו, אתה מסכים לתנאים וההגבלות הבאים:</p>\r\n<h3>1. קבלת התנאים</h3>\r\n<p>בשימוש באפליקציה זו, אתה מסכים להיות כפוף לתנאים והגבלות אלה.</p>\r\n<h3>2. שימוש בשירות</h3>\r\n<p>יש להשתמש באפליקציה למטרות חוקיות בלבד ובהתאם לחוקים המקומיים.</p>\r\n<h3>3. חשבון משתמש</h3>\r\n<p>אתה אחראי לשמור על סודיות פרטי החשבון שלך.</p>\r\n<h3>4. תוכן</h3>\r\n<p>אתה אחראי לכל תוכן שאתה מפרסם באפליקציה.</p>\r\n<h3>5. סיום</h3>\r\n<p>אנו שומרים לעצמנו את הזכות לסיים או להשעות את חשבונך בכל עת.</p>', '2026-02-16 11:55:42', NULL),
(2, 'privacy_policy', 'content', 'html', 0, NULL, '<h2>سياسة الخصوصية</h2>\r\n<p>نحن نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية.</p>\r\n<h3>1. البيانات التي نجمعها</h3>\r\n<p>نجمع المعلومات التي تقدمها لنا مباشرة مثل الاسم والبريد الإلكتروني ورقم الهاتف.</p>\r\n<h3>2. كيف نستخدم بياناتك</h3>\r\n<p>نستخدم بياناتك لتقديم خدماتنا وتحسينها.</p>\r\n<h3>3. مشاركة البيانات</h3>\r\n<p>لا نشارك بياناتك مع أطراف ثالثة إلا بموافقتك.</p>\r\n<h3>4. حذف البيانات</h3>\r\n<p>يمكنك طلب حذف حسابك وجميع بياناتك في أي وقت.</p>', '<h2>Privacy Policy</h2>\r\n<p>We respect your privacy and are committed to protecting your personal data.</p>\r\n<h3>1. Data We Collect</h3>\r\n<p>We collect information you provide directly such as name, email, and phone number.</p>\r\n<h3>2. How We Use Your Data</h3>\r\n<p>We use your data to provide and improve our services.</p>\r\n<h3>3. Data Sharing</h3>\r\n<p>We do not share your data with third parties without your consent.</p>\r\n<h3>4. Data Deletion</h3>\r\n<p>You can request deletion of your account and all your data at any time.</p>', '<h2>מדיניות פרטיות</h2>\r\n<p>אנו מכבדים את פרטיותך ומחויבים להגן על הנתונים האישיים שלך.</p>\r\n<h3>1. נתונים שאנו אוספים</h3>\r\n<p>אנו אוספים מידע שאתה מספק ישירות כגון שם, אימייל ומספר טלפון.</p>\r\n<h3>2. כיצד אנו משתמשים בנתונים שלך</h3>\r\n<p>אנו משתמשים בנתונים שלך כדי לספק ולשפר את השירותים שלנו.</p>\r\n<h3>3. שיתוף נתונים</h3>\r\n<p>איננו משתפים את הנתונים שלך עם צדדים שלישיים ללא הסכמתך.</p>\r\n<h3>4. מחיקת נתונים</h3>\r\n<p>אתה יכול לבקש מחיקת החשבון שלך וכל הנתונים שלך בכל עת.</p>', '2026-02-16 11:55:42', NULL),
(3, 'payment_mode', 'payment', 'text', 0, 'Payment environment: sandbox or production', 'sandbox', NULL, NULL, '2026-02-16 11:55:42', NULL),
(4, 'payment_currency', 'payment', 'text', 0, 'Default payment currency', 'ILS', NULL, NULL, '2026-02-16 11:55:42', NULL),
(5, 'apple_pay_enabled', 'apple_pay', 'boolean', 0, 'Enable Apple Pay payments', '0', NULL, NULL, '2026-02-16 11:55:42', NULL),
(6, 'apple_pay_merchant_id', 'apple_pay', 'text', 0, 'Apple Pay Merchant ID', '', NULL, NULL, '2026-02-16 11:55:42', NULL),
(7, 'apple_pay_merchant_name', 'apple_pay', 'text', 0, 'Merchant display name', 'Rento Go', NULL, NULL, '2026-02-16 11:55:42', NULL),
(8, 'apple_pay_certificate_path', 'apple_pay', 'text', 0, 'Path to Apple Pay certificate file (.pem)', '', NULL, NULL, '2026-02-16 11:55:42', NULL),
(9, 'apple_pay_certificate_key', 'apple_pay', 'password', 1, 'Apple Pay certificate private key', '', NULL, NULL, '2026-02-16 11:55:42', NULL),
(10, 'apple_pay_merchant_domain', 'apple_pay', 'text', 0, 'Verified merchant domain', '', NULL, NULL, '2026-02-16 11:55:42', NULL),
(11, 'apple_pay_supported_networks', 'apple_pay', 'json', 0, 'Supported card networks', '[\"visa\",\"masterCard\",\"amex\"]', NULL, NULL, '2026-02-16 11:55:42', NULL),
(12, 'stripe_enabled', 'stripe', 'boolean', 0, 'Enable Stripe payments', '0', NULL, NULL, '2026-02-16 11:55:42', NULL),
(13, 'stripe_publishable_key', 'stripe', 'text', 0, 'Stripe publishable API key', '', NULL, NULL, '2026-02-16 11:55:42', NULL),
(14, 'stripe_secret_key', 'stripe', 'password', 1, 'Stripe secret API key', '', NULL, NULL, '2026-02-16 11:55:42', NULL),
(15, 'stripe_webhook_secret', 'stripe', 'password', 1, 'Stripe webhook signing secret', '', NULL, NULL, '2026-02-16 11:55:42', NULL),
(16, 'paypal_enabled', 'paypal', 'boolean', 0, 'Enable PayPal payments', '0', NULL, NULL, '2026-02-16 11:55:42', NULL),
(17, 'paypal_client_id', 'paypal', 'text', 0, 'PayPal client ID', '', NULL, NULL, '2026-02-16 11:55:42', NULL),
(18, 'paypal_client_secret', 'paypal', 'password', 1, 'PayPal client secret', '', NULL, NULL, '2026-02-16 11:55:42', NULL),
(19, 'paypal_mode', 'paypal', 'text', 0, 'PayPal mode: sandbox or live', 'sandbox', NULL, NULL, '2026-02-16 11:55:42', NULL),
(20, 'admin_notification_email', 'notifications', 'text', 0, 'Email for payment notifications', '', NULL, NULL, '2026-02-16 11:55:42', NULL),
(21, 'payment_success_webhook', 'notifications', 'text', 0, 'Webhook URL for successful payments', '', NULL, NULL, '2026-02-16 11:55:42', NULL),
(22, 'payment_failed_webhook', 'notifications', 'text', 0, 'Webhook URL for failed payments', '', NULL, NULL, '2026-02-16 11:55:42', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE `audit_logs` (
  `id` int(10) UNSIGNED NOT NULL,
  `admin_id` int(10) UNSIGNED DEFAULT NULL,
  `action` varchar(100) NOT NULL,
  `entity_type` varchar(100) DEFAULT NULL,
  `entity_id` int(10) UNSIGNED DEFAULT NULL,
  `old_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_data`)),
  `new_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_data`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `audit_logs`
--

INSERT INTO `audit_logs` (`id`, `admin_id`, `action`, `entity_type`, `entity_id`, `old_data`, `new_data`, `ip_address`, `user_agent`, `created_at`) VALUES
(1, 1, 'approve_listing', 'properties', 13, NULL, NULL, '188.161.64.188', NULL, '2026-01-22 03:20:24'),
(2, 1, 'approve_listing', 'properties', 14, NULL, NULL, '188.161.64.188', NULL, '2026-01-22 03:35:36'),
(3, 1, 'approve_listing', 'properties', 16, NULL, NULL, '188.161.64.188', NULL, '2026-01-22 03:53:33'),
(4, 1, 'approve_listing', 'properties', 15, NULL, NULL, '188.161.64.188', NULL, '2026-01-22 03:53:39'),
(5, 1, 'approve_listing', 'properties', 17, NULL, NULL, '188.161.64.188', NULL, '2026-01-22 11:43:12'),
(6, 1, 'approve_listing', 'properties', 19, NULL, NULL, '188.161.64.188', NULL, '2026-02-16 12:54:22'),
(7, 1, 'approve_listing', 'properties', 23, NULL, NULL, '188.161.64.188', NULL, '2026-02-16 13:29:09'),
(8, 1, 'approve_listing', 'cars', 11, NULL, NULL, '188.120.128.192', NULL, '2026-02-16 14:02:08'),
(9, 1, 'approve_listing', 'properties', 24, NULL, NULL, '185.46.76.17', NULL, '2026-02-17 12:59:50'),
(10, 1, 'reject_listing', 'properties', 25, NULL, '{\"reason\":\"\\u0627\\u0644\\u0631\\u062c\\u0627\\u0621 \\u0648\\u0636\\u0639 \\u0635\\u0648\\u0631 \"}', '147.235.203.165', NULL, '2026-02-17 18:33:33'),
(11, 1, 'approve_listing', 'properties', 25, NULL, NULL, '147.235.203.165', NULL, '2026-02-17 18:54:37'),
(12, 1, 'approve_listing', 'properties', 26, NULL, NULL, '46.210.224.48', NULL, '2026-02-17 22:30:38'),
(13, 1, 'approve_listing', 'properties', 27, NULL, NULL, '213.6.44.62', NULL, '2026-02-22 22:38:41'),
(14, 1, 'reject_listing', 'properties', 22, NULL, '{\"reason\":\"\\u0642\\u062b\\u0642\\u062b\\u0642\\u062b\"}', '213.6.44.62', NULL, '2026-02-22 23:01:44'),
(15, 1, 'approve_listing', 'properties', 20, NULL, NULL, '213.6.44.62', NULL, '2026-02-23 01:50:05');

-- --------------------------------------------------------

--
-- Table structure for table `cars`
--

CREATE TABLE `cars` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `usage_type` enum('daily','wedding','tourism') NOT NULL,
  `car_type_id` int(10) UNSIGNED DEFAULT NULL,
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
  `price_daily` decimal(12,2) DEFAULT NULL,
  `price_weekly` decimal(12,2) DEFAULT NULL,
  `price_monthly` decimal(12,2) DEFAULT NULL,
  `currency` varchar(10) DEFAULT 'ILS',
  `bio` text DEFAULT NULL,
  `language` enum('ar','he') DEFAULT 'ar',
  `contact_phone` varchar(20) NOT NULL,
  `whatsapp` varchar(20) DEFAULT NULL,
  `status` enum('draft','pending_payment','pending_admin_review','active','expired','paused','rejected') DEFAULT 'draft',
  `is_trusted` tinyint(1) DEFAULT 0,
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

INSERT INTO `cars` (`id`, `user_id`, `title`, `usage_type`, `car_type_id`, `model`, `year`, `gearbox`, `with_driver`, `duration_type`, `plate_color`, `region_id`, `city_id`, `address_text`, `price_type`, `price`, `price_from`, `price_to`, `price_daily`, `price_weekly`, `price_monthly`, `currency`, `bio`, `language`, `contact_phone`, `whatsapp`, `status`, `is_trusted`, `reject_reason`, `views_count`, `subscription_id`, `expires_at`, `created_at`, `updated_at`) VALUES
(1, 7, 'تويوتا كورولا 2023 للإيجار', 'daily', 1, 'Toyota Corolla 2023', 2023, 'automatic', 0, 'daily', 'yellow', 1, 1, NULL, 'fixed', 150.00, NULL, NULL, 150.00, NULL, NULL, 'ILS', 'سيارة اقتصادية مناسبة للتنقل اليومي، نظيفة ومكيفة', 'ar', '+972507890123', NULL, 'active', 0, NULL, 49, NULL, '2026-02-20 23:56:25', '2026-01-21 23:56:25', '2026-02-22 23:46:20'),
(2, 7, 'هيونداي النترا موديل 2022', 'daily', 1, 'Hyundai Elantra 2022', 2022, 'automatic', 0, 'daily', 'yellow', 2, 5, NULL, 'fixed', 140.00, NULL, NULL, 140.00, NULL, NULL, 'ILS', 'سيارة عائلية مريحة وموفرة للوقود', 'ar', '+972507890123', NULL, 'active', 0, NULL, 45, NULL, '2026-02-20 23:56:25', '2026-01-21 23:56:25', '2026-02-22 23:46:20'),
(3, 8, 'كيا سبورتاج SUV 2023', 'daily', 1, 'Kia Sportage 2023', 2023, 'automatic', 0, 'daily', 'yellow', 1, 2, NULL, 'fixed', 200.00, NULL, NULL, 200.00, NULL, NULL, 'ILS', 'سيارة دفع رباعي مناسبة للعائلات والرحلات', 'ar', '+972508901234', NULL, 'active', 0, NULL, 49, NULL, '2026-02-20 23:56:25', '2026-01-21 23:56:25', '2026-02-22 23:46:20'),
(4, 8, 'مازدا CX-5 فل كامل', 'daily', 1, 'Mazda CX-5 2022', 2022, 'automatic', 0, 'daily', 'yellow', 2, 6, NULL, 'fixed', 220.00, NULL, NULL, 220.00, NULL, NULL, 'ILS', 'سيارة أنيقة بمواصفات عالية وتجهيزات كاملة', 'ar', '+972508901234', NULL, 'active', 0, NULL, 54, NULL, '2026-02-20 23:56:25', '2026-01-21 23:56:25', '2026-02-22 23:46:20'),
(5, 7, 'مرسيدس S-Class للأعراس', 'wedding', 2, 'Mercedes S-Class 2023', 2023, 'automatic', 1, 'daily', 'yellow', 1, 1, NULL, 'fixed', 800.00, NULL, NULL, 800.00, NULL, NULL, 'ILS', 'سيارة فاخرة للأعراس والمناسبات الخاصة مع سائق محترف', 'ar', '+972507890123', NULL, 'active', 0, NULL, 47, NULL, '2026-02-20 23:56:25', '2026-01-21 23:56:25', '2026-02-22 23:46:20'),
(6, 8, 'بي ام دبليو الفئة السابعة', 'wedding', 2, 'BMW 7 Series 2022', 2022, 'automatic', 1, 'daily', 'yellow', 2, 5, NULL, 'fixed', 750.00, NULL, NULL, 750.00, NULL, NULL, 'ILS', 'سيارة فارهة للأعراس مع زينة كاملة وسائق', 'ar', '+972508901234', NULL, 'active', 0, NULL, 50, NULL, '2026-02-20 23:56:25', '2026-01-21 23:56:25', '2026-02-22 23:46:20'),
(7, 10, 'رولز رويس للأعراس الملكية', 'wedding', 2, 'Rolls Royce Ghost 2021', 2021, 'automatic', 1, 'daily', 'yellow', 1, 1, NULL, 'fixed', 1500.00, NULL, NULL, 1500.00, NULL, NULL, 'ILS', 'أفخم سيارة للأعراس، تجربة ملكية لا تنسى', 'ar', '+972500123456', NULL, 'active', 0, NULL, 28, NULL, '2026-02-20 23:56:25', '2026-01-21 23:56:25', '2026-02-22 23:46:20'),
(8, 7, 'لاند كروزر للرحلات السياحية', 'tourism', 3, 'Toyota Land Cruiser 2023', 2023, 'automatic', 1, 'daily', 'yellow', 3, 9, NULL, 'fixed', 350.00, NULL, NULL, 350.00, NULL, NULL, 'ILS', 'سيارة دفع رباعي مثالية للرحلات والسفاري مع سائق', 'ar', '+972507890123', NULL, 'active', 0, NULL, 36, NULL, '2026-02-20 23:56:25', '2026-01-21 23:56:25', '2026-02-22 23:46:20'),
(9, 8, 'جيب رانجلر للمغامرات', 'tourism', 3, 'Jeep Wrangler 2022', 2022, 'automatic', 0, 'daily', 'yellow', 3, 10, NULL, 'fixed', 300.00, NULL, NULL, 300.00, NULL, NULL, 'ILS', 'سيارة مثالية للطرق الوعرة والتخييم', 'ar', '+972508901234', NULL, 'active', 0, NULL, 29, NULL, '2026-02-20 23:56:25', '2026-01-21 23:56:25', '2026-02-22 23:46:20'),
(10, 10, 'مرسيدس V-Class للسياحة', 'tourism', 3, 'Mercedes V-Class 2023', 2023, 'automatic', 1, 'daily', 'yellow', 1, 1, NULL, 'fixed', 400.00, NULL, NULL, 400.00, NULL, NULL, 'ILS', 'فان فاخر يتسع لـ 7 أشخاص مع أمتعة، مثالي للمجموعات', 'ar', '+972500123456', NULL, 'active', 0, NULL, 30, NULL, '2026-02-20 23:56:25', '2026-01-21 23:56:25', '2026-02-22 23:46:20'),
(11, 23, NULL, 'daily', 1, 'corolla', 2000, 'automatic', 0, 'daily', 'yellow', 2, 12, NULL, 'fixed', 200.00, NULL, NULL, 200.00, 500.00, 4000.00, 'ILS', 'hdgsgshaja', 'ar', '05548756889', '05548756889', 'active', 0, NULL, 4, 25, NULL, '2026-02-16 14:01:05', '2026-02-22 23:46:20');

-- --------------------------------------------------------

--
-- Table structure for table `car_media`
--

CREATE TABLE `car_media` (
  `id` int(10) UNSIGNED NOT NULL,
  `car_id` int(10) UNSIGNED NOT NULL,
  `media_type` enum('image','video') DEFAULT 'image',
  `file_path` varchar(500) NOT NULL,
  `file_name` varchar(255) DEFAULT NULL,
  `sort_order` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `car_media`
--

INSERT INTO `car_media` (`id`, `car_id`, `media_type`, `file_path`, `file_name`, `sort_order`, `created_at`) VALUES
(1, 1, 'image', 'sample.png', NULL, 1, '2026-01-21 23:56:25'),
(2, 2, 'image', 'sample.png', NULL, 1, '2026-01-21 23:56:25'),
(3, 3, 'image', 'sample.png', NULL, 1, '2026-01-21 23:56:25'),
(4, 4, 'image', 'sample.png', NULL, 1, '2026-01-21 23:56:25'),
(5, 5, 'image', 'sample.png', NULL, 1, '2026-01-21 23:56:25'),
(6, 6, 'image', 'sample.png', NULL, 1, '2026-01-21 23:56:25'),
(7, 7, 'image', 'sample.png', NULL, 1, '2026-01-21 23:56:25'),
(8, 8, 'image', 'sample.png', NULL, 1, '2026-01-21 23:56:25'),
(9, 9, 'image', 'sample.png', NULL, 1, '2026-01-21 23:56:25'),
(10, 10, 'image', 'sample.png', NULL, 1, '2026-01-21 23:56:25');

-- --------------------------------------------------------

--
-- Table structure for table `car_types`
--

CREATE TABLE `car_types` (
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
-- Dumping data for table `car_types`
--

INSERT INTO `car_types` (`id`, `name_ar`, `name_en`, `name_he`, `slug`, `icon`, `is_active`, `sort_order`, `created_at`, `updated_at`) VALUES
(1, 'إيجار يومي', 'Daily Rental', 'השכרה יומית', 'daily', 'calendar_today', 1, 1, '2026-02-22 23:46:20', '2026-02-22 23:46:20'),
(2, 'زفاف', 'Wedding', 'חתונה', 'wedding', 'favorite', 1, 2, '2026-02-22 23:46:20', '2026-02-22 23:46:20'),
(3, 'سياحة', 'Tourism', 'תיירות', 'tourism', 'flight', 1, 3, '2026-02-22 23:46:20', '2026-02-22 23:46:20'),
(4, 'رحلات', 'Trips', 'טיולים', 'trips', 'directions_car', 1, 4, '2026-02-22 23:46:20', '2026-02-22 23:46:20'),
(5, 'نقل', 'Transportation', 'הובלות', 'transportation', 'local_shipping', 1, 5, '2026-02-22 23:46:20', '2026-02-22 23:46:20'),
(6, 'ايجار بالساعة', 'Hourly rental', 'השכרה לשעה', 'hourly_rental', 'directions_car', 1, 6, '2026-02-23 00:09:49', '2026-02-23 00:09:49');

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
(1, 1, 'رام الله', 'Ramallah', 'רמאללה', 'ramallah', 1, 1, '2026-01-21 23:56:25'),
(2, 1, 'نابلس', 'Nablus', 'שכם', 'nablus', 1, 2, '2026-01-21 23:56:25'),
(3, 1, 'الخليل', 'Hebron', 'חברון', 'hebron', 1, 3, '2026-01-21 23:56:25'),
(4, 1, 'بيت لحم', 'Bethlehem', 'בית לחם', 'bethlehem', 1, 4, '2026-01-21 23:56:25'),
(5, 1, 'جنين', 'Jenin', 'ג׳נין', 'jenin', 1, 5, '2026-01-21 23:56:25'),
(6, 1, 'طولكرم', 'Tulkarm', 'טול כרם', 'tulkarm', 1, 6, '2026-01-21 23:56:25'),
(7, 1, 'قلقيلية', 'Qalqilya', 'קלקיליה', 'qalqilya', 1, 7, '2026-01-21 23:56:25'),
(8, 1, 'سلفيت', 'Salfit', 'סלפית', 'salfit', 1, 8, '2026-01-21 23:56:25'),
(9, 1, 'طوباس', 'Tubas', 'טובאס', 'tubas', 1, 9, '2026-01-21 23:56:25'),
(10, 1, 'أريحا', 'Jericho', 'יריחו', 'jericho', 1, 10, '2026-01-21 23:56:25'),
(11, 2, 'القدس', 'Jerusalem', 'ירושלים', 'jerusalem-city', 1, 1, '2026-01-21 23:56:25'),
(12, 2, 'العيزرية', 'Al-Eizariya', 'אל-עיזריה', 'al-eizariya', 1, 2, '2026-01-21 23:56:25'),
(13, 2, 'أبو ديس', 'Abu Dis', 'אבו דיס', 'abu-dis', 1, 3, '2026-01-21 23:56:25'),
(14, 3, 'حيفا', 'Haifa', 'חיפה', 'haifa', 1, 1, '2026-01-21 23:56:25'),
(15, 3, 'يافا', 'Jaffa', 'יפו', 'jaffa', 1, 2, '2026-01-21 23:56:25'),
(16, 3, 'الناصرة', 'Nazareth', 'נצרת', 'nazareth', 1, 3, '2026-01-21 23:56:25'),
(17, 3, 'عكا', 'Acre', 'עכו', 'acre', 1, 4, '2026-01-21 23:56:25'),
(18, 3, 'اللد', 'Lod', 'לוד', 'lod', 1, 5, '2026-01-21 23:56:25'),
(19, 3, 'الرملة', 'Ramla', 'רמלה', 'ramla', 1, 6, '2026-01-21 23:56:25'),
(20, 4, 'بئر السبع', 'Beersheba', 'באר שבע', 'beersheba', 1, 1, '2026-01-21 23:56:25'),
(21, 4, 'رهط', 'Rahat', 'רהט', 'rahat', 1, 2, '2026-01-21 23:56:25');

-- --------------------------------------------------------

--
-- Table structure for table `cms_pages`
--

CREATE TABLE `cms_pages` (
  `id` int(10) UNSIGNED NOT NULL,
  `slug` varchar(100) NOT NULL,
  `title_ar` varchar(255) NOT NULL,
  `title_en` varchar(255) NOT NULL,
  `title_he` varchar(255) NOT NULL,
  `content_ar` longtext DEFAULT NULL,
  `content_en` longtext DEFAULT NULL,
  `content_he` longtext DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `cms_pages`
--

INSERT INTO `cms_pages` (`id`, `slug`, `title_ar`, `title_en`, `title_he`, `content_ar`, `content_en`, `content_he`, `is_active`, `created_at`, `updated_at`) VALUES
(1, 'privacy', 'سياسة الخصوصية', 'Privacy Policy', 'מדיניות פרטיות', '<h1>سياسة الخصوصية</h1><p>محتوى سياسة الخصوصية...</p>', '<h1>Privacy Policy</h1><p>Privacy policy content...</p>', '<h1>מדיניות פרטיות</h1><p>תוכן מדיניות הפרטיות...</p>', 1, '2026-01-21 23:56:25', '2026-01-21 23:56:25'),
(2, 'terms', 'الشروط والأحكام', 'Terms & Conditions', 'תנאים והגבלות', '<h1>الشروط والأحكام</h1><p>محتوى الشروط والأحكام...</p>', '<h1>Terms & Conditions</h1><p>Terms and conditions content...</p>', '<h1>תנאים והגבלות</h1><p>תוכן התנאים וההגבלות...</p>', 1, '2026-01-21 23:56:25', '2026-01-21 23:56:25'),
(3, 'disclaimer', 'إخلاء المسؤولية', 'Disclaimer', 'כתב ויתור', '<h1>إخلاء المسؤولية</h1><p>Rento Go منصة إعلانية فقط ولا تتدخل في العقود أو المدفوعات بين الأطراف...</p>', '<h1>Disclaimer</h1><p>Rento Go is an advertising platform only and does not intervene in contracts or payments between parties...</p>', '<h1>כתב ויתור</h1><p>Rento Go היא פלטפורמת פרסום בלבד ואינה מתערבת בחוזים או תשלומים בין הצדדים...</p>', 1, '2026-01-21 23:56:25', '2026-01-21 23:56:25');

-- --------------------------------------------------------

--
-- Table structure for table `conversations`
--

CREATE TABLE `conversations` (
  `id` int(10) UNSIGNED NOT NULL,
  `user1_id` int(10) UNSIGNED NOT NULL,
  `user2_id` int(10) UNSIGNED NOT NULL,
  `listing_type` enum('property','car') DEFAULT NULL,
  `listing_id` int(10) UNSIGNED DEFAULT NULL,
  `last_message_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `conversations`
--

INSERT INTO `conversations` (`id`, `user1_id`, `user2_id`, `listing_type`, `listing_id`, `last_message_at`, `created_at`) VALUES
(1, 11, 12, 'property', 15, NULL, '2026-02-07 01:31:28'),
(2, 11, 5, 'property', 3, NULL, '2026-02-07 01:32:06'),
(3, 11, 4, 'property', 1, NULL, '2026-02-07 01:58:35'),
(4, 26, 10, 'car', 10, NULL, '2026-02-17 22:39:02'),
(5, 21, 12, 'property', 13, '2026-02-23 01:23:03', '2026-02-23 02:17:00'),
(6, 21, 12, 'property', 16, '2026-02-23 01:25:05', '2026-02-23 02:24:59');

-- --------------------------------------------------------

--
-- Table structure for table `favorites`
--

CREATE TABLE `favorites` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `listing_type` enum('property','car') NOT NULL,
  `listing_id` int(10) UNSIGNED NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `favorites`
--

INSERT INTO `favorites` (`id`, `user_id`, `listing_type`, `listing_id`, `created_at`) VALUES
(1, 1, 'property', 1, '2026-01-21 23:56:25'),
(2, 1, 'property', 6, '2026-01-21 23:56:25'),
(3, 1, 'car', 1, '2026-01-21 23:56:25'),
(4, 2, 'property', 2, '2026-01-21 23:56:25'),
(5, 2, 'property', 7, '2026-01-21 23:56:25'),
(6, 2, 'car', 5, '2026-01-21 23:56:25'),
(7, 3, 'property', 3, '2026-01-21 23:56:25'),
(8, 3, 'car', 8, '2026-01-21 23:56:25'),
(10, 12, 'car', 1, '2026-01-22 04:51:57'),
(12, 12, 'property', 4, '2026-01-22 11:07:47'),
(13, 13, 'car', 3, '2026-01-22 11:21:50'),
(14, 13, 'property', 16, '2026-01-22 20:47:53'),
(15, 11, 'property', 12, '2026-01-22 22:25:48'),
(16, 11, 'property', 17, '2026-01-22 22:25:58'),
(17, 11, 'property', 16, '2026-01-22 22:26:01'),
(18, 11, 'property', 2, '2026-01-22 22:26:55'),
(19, 17, 'car', 1, '2026-02-16 12:29:28'),
(20, 18, 'property', 14, '2026-02-16 12:29:32'),
(21, 18, 'property', 3, '2026-02-16 12:29:33'),
(22, 23, 'property', 4, '2026-02-16 15:00:37'),
(23, 23, 'property', 2, '2026-02-17 13:16:15'),
(25, 25, 'property', 7, '2026-02-17 14:14:56'),
(26, 23, 'car', 1, '2026-02-17 17:02:16'),
(27, 26, 'property', 2, '2026-02-17 22:22:19'),
(28, 21, 'property', 16, '2026-02-22 22:35:56'),
(29, 21, 'property', 25, '2026-02-22 22:36:14'),
(30, 21, 'property', 15, '2026-02-23 00:47:14'),
(31, 21, 'property', 18, '2026-02-23 00:47:23'),
(32, 21, 'property', 17, '2026-02-23 00:47:24'),
(33, 21, 'property', 14, '2026-02-23 00:47:31'),
(34, 21, 'property', 24, '2026-02-23 00:47:37'),
(35, 21, 'property', 19, '2026-02-23 00:47:45'),
(36, 21, 'property', 23, '2026-02-23 00:47:47'),
(37, 21, 'property', 26, '2026-02-23 00:47:49'),
(38, 21, 'property', 27, '2026-02-23 00:47:53'),
(39, 21, 'property', 13, '2026-02-23 00:47:54');

-- --------------------------------------------------------

--
-- Table structure for table `messages`
--

CREATE TABLE `messages` (
  `id` int(10) UNSIGNED NOT NULL,
  `conversation_id` int(10) UNSIGNED NOT NULL,
  `sender_id` int(10) UNSIGNED NOT NULL,
  `message` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `messages`
--

INSERT INTO `messages` (`id`, `conversation_id`, `sender_id`, `message`, `is_read`, `created_at`) VALUES
(1, 1, 11, 'hi', 0, '2026-02-07 01:31:39'),
(2, 1, 11, 'hi', 0, '2026-02-07 01:31:45'),
(3, 2, 11, 'hi', 0, '2026-02-07 01:32:14'),
(4, 2, 11, 'hi', 0, '2026-02-07 01:32:19'),
(5, 2, 11, 'hi', 0, '2026-02-07 01:32:25'),
(6, 2, 11, 'كيفك', 0, '2026-02-07 01:40:59'),
(7, 2, 11, 'كيفك', 0, '2026-02-07 01:41:05'),
(8, 2, 11, 'كيفك', 0, '2026-02-07 01:41:14'),
(9, 2, 11, 'hi', 0, '2026-02-07 01:58:13'),
(10, 3, 11, 'hi', 0, '2026-02-07 01:58:42'),
(11, 5, 21, 'مرحبا', 0, '2026-02-23 02:17:14'),
(12, 5, 21, 'مرحبا', 0, '2026-02-23 02:17:20'),
(13, 5, 21, 'مرحبا', 0, '2026-02-23 02:17:26'),
(14, 5, 21, 'كيفك', 0, '2026-02-23 02:19:45'),
(15, 5, 21, 'كيفك,هاي', 0, '2026-02-23 02:22:52'),
(16, 5, 21, 'كيفك,هاي', 0, '2026-02-23 02:23:03'),
(17, 6, 21, 'مرحبا', 0, '2026-02-23 02:25:02'),
(18, 6, 21, 'كسفك', 0, '2026-02-23 02:25:05');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `title_ar` varchar(255) NOT NULL,
  `title_en` varchar(255) NOT NULL,
  `title_he` varchar(255) NOT NULL,
  `body_ar` text DEFAULT NULL,
  `body_en` text DEFAULT NULL,
  `body_he` text DEFAULT NULL,
  `type` enum('listing_approved','listing_rejected','subscription_expiring','subscription_expired','subscription_approved','account_approved','admin_message','broadcast','segment_message','region_message','city_message','new_listing','new_message','general') NOT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data`)),
  `is_read` tinyint(1) DEFAULT 0,
  `is_push_sent` tinyint(1) DEFAULT 0 COMMENT 'Whether push notification was sent',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `title_ar`, `title_en`, `title_he`, `body_ar`, `body_en`, `body_he`, `type`, `data`, `is_read`, `is_push_sent`, `created_at`) VALUES
(1, 1, 'مرحباً بك في رينتو جو!', 'Welcome to Rento Go!', 'ברוכים הבאים לרנטו גו!', 'شكراً لانضمامك إلينا. استكشف أفضل العقارات والسيارات للإيجار.', 'Thank you for joining us. Explore the best properties and cars for rent.', 'תודה שהצטרפת אלינו. גלה את הנכסים והמכוניות הטובים ביותר להשכרה.', 'general', NULL, 0, 0, '2026-01-21 23:56:25'),
(2, 4, 'تمت الموافقة على إعلانك', 'Your listing is approved', 'המודעה שלך אושרה', 'تهانينا! تم الموافقة على إعلان شقة فاخرة في وسط المدينة', 'Congratulations! Your listing has been approved', 'מזל טוב! המודעה שלך אושרה', 'listing_approved', NULL, 0, 0, '2026-01-21 23:56:25'),
(3, 7, 'لديك استفسار جديد', 'You have a new inquiry', 'יש לך פנייה חדשה', 'قام مستخدم بالاستفسار عن سيارتك تويوتا كورولا', 'A user has inquired about your Toyota Corolla', 'משתמש התעניין בטויוטה קורולה שלך', 'general', NULL, 0, 0, '2026-01-21 23:56:25'),
(4, 12, 'تم قبول إعلانك', 'Listing Approved', 'המודעה אושרה', 'إعلانك الآن متاح للجميع', 'Your listing is now live', 'המודעה שלך זמינה כעת', 'listing_approved', '{\"listing_id\":13,\"listing_type\":\"property\"}', 0, 0, '2026-01-22 03:20:24'),
(5, 12, 'تم قبول إعلانك', 'Listing Approved', 'המודעה אושרה', 'إعلانك الآن متاح للجميع', 'Your listing is now live', 'המודעה שלך זמינה כעת', 'listing_approved', '{\"listing_id\":14,\"listing_type\":\"property\"}', 0, 0, '2026-01-22 03:35:36'),
(6, 12, 'تم قبول إعلانك', 'Listing Approved', 'המודעה אושרה', 'إعلانك الآن متاح للجميع', 'Your listing is now live', 'המודעה שלך זמינה כעת', 'listing_approved', '{\"listing_id\":16,\"listing_type\":\"property\"}', 0, 0, '2026-01-22 03:53:33'),
(7, 12, 'تم قبول إعلانك', 'Listing Approved', 'המודעה אושרה', 'إعلانك الآن متاح للجميع', 'Your listing is now live', 'המודעה שלך זמינה כעת', 'listing_approved', '{\"listing_id\":15,\"listing_type\":\"property\"}', 0, 0, '2026-01-22 03:53:39'),
(8, 11, 'تم قبول إعلانك', 'Listing Approved', 'המודעה אושרה', 'إعلانك الآن متاح للجميع', 'Your listing is now live', 'המודעה שלך זמינה כעת', 'listing_approved', '{\"listing_id\":17,\"listing_type\":\"property\"}', 0, 0, '2026-01-22 11:43:12'),
(9, 11, 'بقل', 'بقل', 'بقل', 'ليبل', 'ليبل', 'ليبل', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-23 21:07:14'),
(10, 11, 'بيب', 'بيب', 'بيب', 'ليبليب', 'ليبليب', 'ليبليب', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-23 21:07:58'),
(11, 11, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-23 21:19:10'),
(12, 11, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-23 21:23:40'),
(13, 11, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-23 21:23:59'),
(14, 11, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-23 21:24:19'),
(15, 11, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-23 21:49:05'),
(16, 11, 'gftg', 'gftg', 'gftg', 'ertretre', 'ertretre', 'ertretre', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-23 21:49:13'),
(17, 11, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-23 23:36:23'),
(18, 11, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-23 23:39:28'),
(19, 11, '65465', '65465', '65465', 'غقفغ', 'غقفغ', 'غقفغ', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-23 23:39:38'),
(20, 11, '65465', '65465', '65465', 'غقفغ', 'غقفغ', 'غقفغ', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-23 23:40:46'),
(21, 11, '059999', '059999', '059999', 'قفغقثفثقفثق', 'قفغقثفثقفثق', 'قفغقثفثقفثق', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-23 23:41:00'),
(22, 11, '059999', '059999', '059999', 'قفغقثفثقفثق', 'قفغقثفثقفثق', 'قفغقثفثقفثق', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-23 23:42:53'),
(23, 11, 'قثفغقفغ', 'قثفغقفغ', 'قثفغقفغ', 'غفقغ', 'غفقغ', 'غفقغ', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-23 23:43:05'),
(24, 11, 'فقغعفغ', 'فقغعفغ', 'فقغعفغ', 'عغفعغ', 'عغفعغ', 'عغفعغ', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-23 23:45:42'),
(25, 11, 'فقغعفغ', 'فقغعفغ', 'فقغعفغ', 'عغفعغ', 'عغفعغ', 'عغفعغ', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-23 23:47:24'),
(26, 12, 'فقغفغ', 'فقغفغ', 'فقغفغ', 'غقفغفق', 'غقفغفق', 'غقفغفق', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-23 23:47:38'),
(27, 11, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-23 23:50:35'),
(28, 11, 'hi', 'hi', 'hi', 'hi', 'hi', 'hi', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-23 23:52:16'),
(29, 11, 'hi', 'hi', 'hi', 'hi', 'hi', 'hi', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-24 00:07:22'),
(30, 11, 'مرحبا', 'مرحبا', 'مرحبا', 'اهلا وسهلا بك في تطبيق رينتو', 'اهلا وسهلا بك في تطبيق رينتو', 'اهلا وسهلا بك في تطبيق رينتو', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:01:15'),
(31, 1, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:02:53'),
(32, 2, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:02:53'),
(33, 3, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:02:53'),
(34, 13, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:02:53'),
(35, 15, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:02:53'),
(36, 4, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:02:53'),
(37, 5, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:02:53'),
(38, 6, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:02:53'),
(39, 11, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:02:53'),
(40, 12, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:02:53'),
(41, 9, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:02:53'),
(42, 10, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:02:53'),
(43, 7, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:02:53'),
(44, 8, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:02:53'),
(45, 14, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:02:53'),
(46, 12, 'طز فيك', 'طز فيك', 'طز فيك', 'طز فيك', 'طز فيك', 'طز فيك', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:28:55'),
(47, 12, 'نسيم', 'نسيم', 'نسيم', 'نسيم', 'نسيم', 'نسيم', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:29:47'),
(48, 11, 'تفعيل اشتراك', 'تفعيل اشتراك', 'تفعيل اشتراك', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:34:54'),
(49, 1, 'تفعيل اشتراك', 'تفعيل اشتراك', 'تفعيل اشتراك', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:35:53'),
(50, 2, 'تفعيل اشتراك', 'تفعيل اشتراك', 'تفعيل اشتراك', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:35:53'),
(51, 3, 'تفعيل اشتراك', 'تفعيل اشتراك', 'تفعيل اشتراك', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:35:53'),
(52, 13, 'تفعيل اشتراك', 'تفعيل اشتراك', 'تفعيل اشتراك', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:35:53'),
(53, 15, 'تفعيل اشتراك', 'تفعيل اشتراك', 'تفعيل اشتراك', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:35:53'),
(54, 4, 'تفعيل اشتراك', 'تفعيل اشتراك', 'تفعيل اشتراك', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:35:53'),
(55, 5, 'تفعيل اشتراك', 'تفعيل اشتراك', 'تفعيل اشتراك', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:35:53'),
(56, 6, 'تفعيل اشتراك', 'تفعيل اشتراك', 'تفعيل اشتراك', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:35:53'),
(57, 11, 'تفعيل اشتراك', 'تفعيل اشتراك', 'تفعيل اشتراك', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:35:53'),
(58, 12, 'تفعيل اشتراك', 'تفعيل اشتراك', 'تفعيل اشتراك', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:35:53'),
(59, 9, 'تفعيل اشتراك', 'تفعيل اشتراك', 'تفعيل اشتراك', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:35:53'),
(60, 10, 'تفعيل اشتراك', 'تفعيل اشتراك', 'تفعيل اشتراك', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:35:53'),
(61, 7, 'تفعيل اشتراك', 'تفعيل اشتراك', 'تفعيل اشتراك', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:35:53'),
(62, 8, 'تفعيل اشتراك', 'تفعيل اشتراك', 'تفعيل اشتراك', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:35:53'),
(63, 14, 'تفعيل اشتراك', 'تفعيل اشتراك', 'تفعيل اشتراك', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'اهلا وسهلا بكم تم تفعيل الاشتراك الخاص بكم بنجاح .اهلا وسهلا بكم فيrento.go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:35:53'),
(64, 1, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:37:02'),
(65, 2, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:37:02'),
(66, 3, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:37:02'),
(67, 13, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:37:02'),
(68, 15, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:37:02'),
(69, 4, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:37:02'),
(70, 5, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:37:02'),
(71, 6, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:37:02'),
(72, 11, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:37:02'),
(73, 12, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:37:02'),
(74, 9, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:37:02'),
(75, 10, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:37:02'),
(76, 7, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:37:02'),
(77, 8, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:37:02'),
(78, 14, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'سيتم انطلاق التطبيق قريبا . انتظرونا بكل جديد', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-24 07:37:02'),
(79, 13, 'تفعيل خدمه', 'تفعيل خدمه', 'تفعيل خدمه', 'تم تفعيل الخدمه بنجاح', 'تم تفعيل الخدمه بنجاح', 'تم تفعيل الخدمه بنجاح', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-24 09:42:54'),
(80, 13, 'تفعيل اشتراك', 'تفعيل اشتراك', 'تفعيل اشتراك', 'تم تفعيل اشتراك بنجاح', 'تم تفعيل اشتراك بنجاح', 'تم تفعيل اشتراك بنجاح', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-24 09:43:53'),
(81, 13, 'رسوم اشتراك', 'رسوم اشتراك', 'رسوم اشتراك', 'تم الدفع بنجاح', 'تم الدفع بنجاح', 'تم الدفع بنجاح', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-24 09:44:21'),
(82, 1, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-25 10:04:42'),
(83, 2, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-25 10:04:42'),
(84, 3, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-25 10:04:42'),
(85, 13, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-25 10:04:42'),
(86, 15, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-25 10:04:42'),
(87, 4, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-25 10:04:42'),
(88, 5, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-25 10:04:42'),
(89, 6, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-25 10:04:42'),
(90, 11, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-25 10:04:42'),
(91, 12, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-25 10:04:42'),
(92, 9, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-25 10:04:42'),
(93, 10, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-25 10:04:42'),
(94, 7, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-25 10:04:42'),
(95, 8, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-25 10:04:42'),
(96, 14, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-01-25 10:04:42'),
(97, 11, 'yuiyu', 'yuiyu', 'yuiyu', 'iyui', 'iyui', 'iyui', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-01-28 21:13:19'),
(98, 12, 'تم تفعيل اشتراكك', 'Subscription Activated', 'המנוי שלך הופעל', 'تم تفعيل اشتراكك بنجاح. يمكنك الآن إضافة إعلاناتك', 'Your subscription is now active. You can now add your listings', 'המנוי שלך פעיל כעת. כעת תוכל להוסיף מודעות', 'subscription_approved', '{\"plan_name\":\"\\u0628\\u0627\\u0642\\u0629 \\u0641\\u0636\\u064a\\u0629\"}', 0, 0, '2026-01-28 21:16:17'),
(99, 11, 'iuyui', 'iuyui', 'iuyui', 'iyui', 'iyui', 'iyui', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-02-09 17:54:45'),
(100, 1, '[p][p', '[p][p', '[p][p', '][p]p[', '][p]p[', '][p]p[', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-02-09 17:55:07'),
(101, 11, '-90-90', '-90-90', '-90-90', '-90-9', '-90-9', '-90-9', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-02-09 17:55:57'),
(102, 1, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:06:28'),
(103, 2, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:06:28'),
(104, 3, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:06:28'),
(105, 13, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:06:28'),
(106, 15, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:06:28'),
(107, 16, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:06:28'),
(108, 17, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 1, 0, '2026-02-16 12:06:28'),
(109, 18, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 1, 0, '2026-02-16 12:06:28'),
(110, 4, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:06:28'),
(111, 5, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:06:28'),
(112, 6, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:06:28'),
(113, 11, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:06:28'),
(114, 12, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:06:28'),
(115, 9, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:06:28'),
(116, 10, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:06:28'),
(117, 7, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:06:28'),
(118, 8, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:06:28'),
(119, 14, 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:06:28'),
(120, 1, 'test', 'test', 'test', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:07:21'),
(121, 2, 'test', 'test', 'test', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:07:21'),
(122, 3, 'test', 'test', 'test', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:07:21'),
(123, 13, 'test', 'test', 'test', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:07:21'),
(124, 15, 'test', 'test', 'test', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:07:21'),
(125, 16, 'test', 'test', 'test', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:07:21'),
(126, 17, 'test', 'test', 'test', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 1, 0, '2026-02-16 12:07:21'),
(127, 18, 'test', 'test', 'test', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 1, 0, '2026-02-16 12:07:21'),
(128, 4, 'test', 'test', 'test', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:07:21'),
(129, 5, 'test', 'test', 'test', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:07:21'),
(130, 6, 'test', 'test', 'test', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:07:21'),
(131, 11, 'test', 'test', 'test', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:07:21'),
(132, 12, 'test', 'test', 'test', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:07:21'),
(133, 9, 'test', 'test', 'test', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:07:21'),
(134, 10, 'test', 'test', 'test', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:07:21'),
(135, 7, 'test', 'test', 'test', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:07:21'),
(136, 8, 'test', 'test', 'test', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:07:21'),
(137, 14, 'test', 'test', 'test', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'اهلا وسهلا بكم', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:07:21'),
(138, 16, 'لفثق', 'لفثق', 'لفثق', 'فقثف', 'فقثف', 'فقثف', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:17:19'),
(139, 16, 'يببيس', 'يببيس', 'يببيس', 'بيسبيس', 'بيسبيس', 'بيسبيس', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:17:34'),
(140, 17, 'hjhbgg', 'hjhbgg', 'hjhbgg', 'jbugb hyuikb', 'jbugb hyuikb', 'jbugb hyuikb', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:18:55'),
(141, 1, 'jhbniknik', 'jhbniknik', 'jhbniknik', 'jkninonmo', 'jkninonmo', 'jkninonmo', 'segment_message', '{\"user_type\":\"renter\",\"sent_by\":1}', 0, 0, '2026-02-16 12:19:26'),
(142, 2, 'jhbniknik', 'jhbniknik', 'jhbniknik', 'jkninonmo', 'jkninonmo', 'jkninonmo', 'segment_message', '{\"user_type\":\"renter\",\"sent_by\":1}', 0, 0, '2026-02-16 12:19:26'),
(143, 3, 'jhbniknik', 'jhbniknik', 'jhbniknik', 'jkninonmo', 'jkninonmo', 'jkninonmo', 'segment_message', '{\"user_type\":\"renter\",\"sent_by\":1}', 0, 0, '2026-02-16 12:19:26'),
(144, 13, 'jhbniknik', 'jhbniknik', 'jhbniknik', 'jkninonmo', 'jkninonmo', 'jkninonmo', 'segment_message', '{\"user_type\":\"renter\",\"sent_by\":1}', 0, 0, '2026-02-16 12:19:26'),
(145, 15, 'jhbniknik', 'jhbniknik', 'jhbniknik', 'jkninonmo', 'jkninonmo', 'jkninonmo', 'segment_message', '{\"user_type\":\"renter\",\"sent_by\":1}', 0, 0, '2026-02-16 12:19:26'),
(146, 16, 'jhbniknik', 'jhbniknik', 'jhbniknik', 'jkninonmo', 'jkninonmo', 'jkninonmo', 'segment_message', '{\"user_type\":\"renter\",\"sent_by\":1}', 0, 0, '2026-02-16 12:19:26'),
(147, 17, 'jhbniknik', 'jhbniknik', 'jhbniknik', 'jkninonmo', 'jkninonmo', 'jkninonmo', 'segment_message', '{\"user_type\":\"renter\",\"sent_by\":1}', 1, 0, '2026-02-16 12:19:26'),
(148, 18, 'jhbniknik', 'jhbniknik', 'jhbniknik', 'jkninonmo', 'jkninonmo', 'jkninonmo', 'segment_message', '{\"user_type\":\"renter\",\"sent_by\":1}', 0, 0, '2026-02-16 12:19:26'),
(149, 16, 'يببيس', 'يببيس', 'يببيس', 'بيسبيس', 'بيسبيس', 'بيسبيس', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:21:12'),
(150, 1, 'اهلا وسهلا', 'اهلا وسهلا', 'اهلا وسهلا', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:21:42'),
(151, 2, 'اهلا وسهلا', 'اهلا وسهلا', 'اهلا وسهلا', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:21:42'),
(152, 3, 'اهلا وسهلا', 'اهلا وسهلا', 'اهلا وسهلا', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:21:42'),
(153, 13, 'اهلا وسهلا', 'اهلا وسهلا', 'اهلا وسهلا', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:21:42'),
(154, 15, 'اهلا وسهلا', 'اهلا وسهلا', 'اهلا وسهلا', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:21:42'),
(155, 16, 'اهلا وسهلا', 'اهلا وسهلا', 'اهلا وسهلا', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:21:42'),
(156, 17, 'اهلا وسهلا', 'اهلا وسهلا', 'اهلا وسهلا', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:21:42'),
(157, 18, 'اهلا وسهلا', 'اهلا وسهلا', 'اهلا وسهلا', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:21:42'),
(158, 4, 'اهلا وسهلا', 'اهلا وسهلا', 'اهلا وسهلا', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:21:42'),
(159, 5, 'اهلا وسهلا', 'اهلا وسهلا', 'اهلا وسهلا', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:21:42'),
(160, 6, 'اهلا وسهلا', 'اهلا وسهلا', 'اهلا وسهلا', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:21:42'),
(161, 11, 'اهلا وسهلا', 'اهلا وسهلا', 'اهلا وسهلا', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:21:42'),
(162, 12, 'اهلا وسهلا', 'اهلا وسهلا', 'اهلا وسهلا', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:21:42'),
(163, 9, 'اهلا وسهلا', 'اهلا وسهلا', 'اهلا وسهلا', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:21:42'),
(164, 10, 'اهلا وسهلا', 'اهلا وسهلا', 'اهلا وسهلا', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:21:42'),
(165, 7, 'اهلا وسهلا', 'اهلا وسهلا', 'اهلا وسهلا', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:21:42'),
(166, 8, 'اهلا وسهلا', 'اهلا وسهلا', 'اهلا وسهلا', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:21:42'),
(167, 14, 'اهلا وسهلا', 'اهلا وسهلا', 'اهلا وسهلا', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'اهل بكم في rento-go', 'broadcast', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:21:42'),
(168, 16, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-02-16 12:22:12'),
(169, 1, 'بيس', 'بيس', 'بيس', 'بيسب', 'بيسب', 'بيسب', 'segment_message', '{\"user_type\":\"renter\",\"sent_by\":1}', 0, 0, '2026-02-16 12:22:51'),
(170, 2, 'بيس', 'بيس', 'بيس', 'بيسب', 'بيسب', 'بيسب', 'segment_message', '{\"user_type\":\"renter\",\"sent_by\":1}', 0, 0, '2026-02-16 12:22:51'),
(171, 3, 'بيس', 'بيس', 'بيس', 'بيسب', 'بيسب', 'بيسب', 'segment_message', '{\"user_type\":\"renter\",\"sent_by\":1}', 0, 0, '2026-02-16 12:22:51'),
(172, 13, 'بيس', 'بيس', 'بيس', 'بيسب', 'بيسب', 'بيسب', 'segment_message', '{\"user_type\":\"renter\",\"sent_by\":1}', 0, 0, '2026-02-16 12:22:51'),
(173, 15, 'بيس', 'بيس', 'بيس', 'بيسب', 'بيسب', 'بيسب', 'segment_message', '{\"user_type\":\"renter\",\"sent_by\":1}', 0, 0, '2026-02-16 12:22:51'),
(174, 16, 'بيس', 'بيس', 'بيس', 'بيسب', 'بيسب', 'بيسب', 'segment_message', '{\"user_type\":\"renter\",\"sent_by\":1}', 0, 0, '2026-02-16 12:22:51'),
(175, 17, 'بيس', 'بيس', 'بيس', 'بيسب', 'بيسب', 'بيسب', 'segment_message', '{\"user_type\":\"renter\",\"sent_by\":1}', 0, 0, '2026-02-16 12:22:51'),
(176, 18, 'بيس', 'بيس', 'بيس', 'بيسب', 'بيسب', 'بيسب', 'segment_message', '{\"user_type\":\"renter\",\"sent_by\":1}', 0, 0, '2026-02-16 12:22:51'),
(177, 15, 'تم تفعيل اشتراكك', 'Subscription Activated', 'המנוי שלך הופעל', 'تم تفعيل اشتراكك بنجاح. يمكنك الآن إضافة إعلاناتك', 'Your subscription is now active. You can now add your listings', 'המנוי שלך פעיל כעת. כעת תוכל להוסיף מודעות', 'subscription_approved', '{\"plan_name\":\"\\u0625\\u0639\\u0644\\u0627\\u0646 \\u0634\\u0642\\u0629 \\u0648\\u0627\\u062d\\u062f\"}', 0, 0, '2026-02-16 12:27:44'),
(178, 15, 'تم تفعيل اشتراكك', 'Subscription Activated', 'המנוי שלך הופעל', 'تم تفعيل اشتراكك بنجاح. يمكنك الآن إضافة إعلاناتك', 'Your subscription is now active. You can now add your listings', 'המנוי שלך פעיל כעת. כעת תוכל להוסיף מודעות', 'subscription_approved', '{\"plan_name\":\"\\u0625\\u0639\\u0644\\u0627\\u0646 \\u0634\\u0642\\u0629 \\u0648\\u0627\\u062d\\u062f\"}', 0, 0, '2026-02-16 12:27:47'),
(179, 21, 'تم قبول إعلانك', 'Listing Approved', 'המודעה אושרה', 'إعلانك الآن متاح للجميع', 'Your listing is now live', 'המודעה שלך זמינה כעת', 'listing_approved', '{\"listing_id\":18,\"listing_type\":\"property\"}', 0, 0, '2026-02-16 12:49:01'),
(180, 21, 'تم قبول إعلانك', 'Listing Approved', 'המודעה אושרה', 'إعلانك الآن متاح للجميع', 'Your listing is now live', 'המודעה שלך זמינה כעת', 'listing_approved', '{\"listing_id\":19,\"listing_type\":\"property\"}', 0, 0, '2026-02-16 12:54:22'),
(181, 13, 'تم تفعيل اشتراكك', 'Subscription Activated', 'המנוי שלך הופעל', 'تم تفعيل اشتراكك بنجاح. يمكنك الآن إضافة إعلاناتك', 'Your subscription is now active. You can now add your listings', 'המנוי שלך פעיל כעת. כעת תוכל להוסיף מודעות', 'subscription_approved', '{\"plan_name\":\"\\u0625\\u0639\\u0644\\u0627\\u0646 \\u0641\\u064a\\u0644\\u0627 \\u0648\\u0627\\u062d\\u062f\"}', 0, 0, '2026-02-16 13:11:29'),
(182, 13, 'تم تفعيل اشتراكك', 'Subscription Activated', 'המנוי שלך הופעל', 'تم تفعيل اشتراكك بنجاح. يمكنك الآن إضافة إعلاناتك', 'Your subscription is now active. You can now add your listings', 'המנוי שלך פעיל כעת. כעת תוכל להוסיף מודעות', 'subscription_approved', '{\"plan_name\":\"\\u0625\\u0639\\u0644\\u0627\\u0646 \\u0634\\u0642\\u0629 \\u0648\\u0627\\u062d\\u062f\"}', 0, 0, '2026-02-16 13:11:44'),
(183, 15, 'تم تفعيل اشتراكك', 'Subscription Activated', 'המנוי שלך הופעל', 'تم تفعيل اشتراكك بنجاح. يمكنك الآن إضافة إعلاناتك', 'Your subscription is now active. You can now add your listings', 'המנוי שלך פעיל כעת. כעת תוכל להוסיף מודעות', 'subscription_approved', '{\"plan_name\":\"\\u0625\\u0639\\u0644\\u0627\\u0646 \\u0633\\u064a\\u0627\\u0631\\u0629 \\u0633\\u064a\\u0627\\u062d\\u064a\\u0629\"}', 0, 0, '2026-02-16 13:12:33'),
(184, 15, 'تم تفعيل اشتراكك', 'Subscription Activated', 'המנוי שלך הופעל', 'تم تفعيل اشتراكك بنجاح. يمكنك الآن إضافة إعلاناتك', 'Your subscription is now active. You can now add your listings', 'המנוי שלך פעיל כעת. כעת תוכל להוסיף מודעות', 'subscription_approved', '{\"plan_name\":\"\\u0625\\u0639\\u0644\\u0627\\u0646 \\u0633\\u064a\\u0627\\u0631\\u0629 \\u064a\\u0648\\u0645\\u064a\\u0629\"}', 0, 0, '2026-02-16 13:12:37'),
(185, 15, 'تم تفعيل اشتراكك', 'Subscription Activated', 'המנוי שלך הופעל', 'تم تفعيل اشتراكك بنجاح. يمكنك الآن إضافة إعلاناتك', 'Your subscription is now active. You can now add your listings', 'המנוי שלך פעיל כעת. כעת תוכל להוסיף מודעות', 'subscription_approved', '{\"plan_name\":\"\\u0625\\u0639\\u0644\\u0627\\u0646 \\u0641\\u064a\\u0644\\u0627 \\u0648\\u0627\\u062d\\u062f\"}', 0, 0, '2026-02-16 13:12:41'),
(186, 11, 'تم تفعيل اشتراكك', 'Subscription Activated', 'המנוי שלך הופעל', 'تم تفعيل اشتراكك بنجاح. يمكنك الآن إضافة إعلاناتك', 'Your subscription is now active. You can now add your listings', 'המנוי שלך פעיל כעת. כעת תוכל להוסיף מודעות', 'subscription_approved', '{\"plan_name\":\"\\u0625\\u0639\\u0644\\u0627\\u0646 \\u0633\\u064a\\u0627\\u0631\\u0629 \\u064a\\u0648\\u0645\\u064a\\u0629\"}', 0, 0, '2026-02-16 13:28:53'),
(187, 21, 'تم قبول إعلانك', 'Listing Approved', 'המודעה אושרה', 'إعلانك الآن متاح للجميع', 'Your listing is now live', 'המודעה שלך זמינה כעת', 'listing_approved', '{\"listing_id\":23,\"listing_type\":\"property\"}', 0, 0, '2026-02-16 13:29:09'),
(188, 23, 'تم قبول إعلانك', 'Listing Approved', 'המודעה אושרה', 'إعلانك الآن متاح للجميع', 'Your listing is now live', 'המודעה שלך זמינה כעת', 'listing_approved', '{\"listing_id\":11,\"listing_type\":\"car\"}', 1, 0, '2026-02-16 14:02:08'),
(189, 14, 'Hi', 'Hi', 'Hi', 'Hi', 'Hi', 'Hi', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-02-16 14:28:23'),
(190, 22, 'Hi', 'Hi', 'Hi', 'Hi', 'Hi', 'Hi', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-02-16 14:29:02'),
(191, 24, 'تم قبول إعلانك', 'Listing Approved', 'המודעה אושרה', 'إعلانك الآن متاح للجميع', 'Your listing is now live', 'המודעה שלך זמינה כעת', 'listing_approved', '{\"listing_id\":24,\"listing_type\":\"property\"}', 1, 0, '2026-02-17 12:59:50'),
(192, 25, 'تم رفض إعلانك', 'Listing Rejected', 'המודעה נדחתה', 'سبب الرفض: الرجاء وضع صور ', 'Rejection reason: الرجاء وضع صور ', 'סיבת הדחייה: الرجاء وضع صور ', 'listing_rejected', '{\"listing_id\":25,\"listing_type\":\"property\",\"reason\":\"\\u0627\\u0644\\u0631\\u062c\\u0627\\u0621 \\u0648\\u0636\\u0639 \\u0635\\u0648\\u0631 \"}', 1, 0, '2026-02-17 18:33:33'),
(193, 25, 'تم قبول إعلانك', 'Listing Approved', 'המודעה אושרה', 'إعلانك الآن متاح للجميع', 'Your listing is now live', 'המודעה שלך זמינה כעת', 'listing_approved', '{\"listing_id\":25,\"listing_type\":\"property\"}', 1, 0, '2026-02-17 18:54:37'),
(194, 26, 'تم قبول إعلانك', 'Listing Approved', 'המודעה אושרה', 'إعلانك الآن متاح للجميع', 'Your listing is now live', 'המודעה שלך זמינה כעת', 'listing_approved', '{\"listing_id\":26,\"listing_type\":\"property\"}', 1, 0, '2026-02-17 22:30:38'),
(195, 26, 'خضر', 'خضر', 'خضر', 'احلا خضر', 'احلا خضر', 'احلا خضر', 'admin_message', '{\"sent_by\":1}', 1, 0, '2026-02-17 22:31:16'),
(196, 21, 'تم قبول إعلانك', 'Listing Approved', 'המודעה אושרה', 'إعلانك الآن متاح للجميع', 'Your listing is now live', 'המודעה שלך זמינה כעת', 'listing_approved', '{\"listing_id\":27,\"listing_type\":\"property\"}', 0, 0, '2026-02-22 22:38:41'),
(197, 21, 'تم رفض إعلانك', 'Listing Rejected', 'המודעה נדחתה', 'سبب الرفض: قثقثقث', 'Rejection reason: قثقثقث', 'סיבת הדחייה: قثقثقث', 'listing_rejected', '{\"listing_id\":22,\"listing_type\":\"property\",\"reason\":\"\\u0642\\u062b\\u0642\\u062b\\u0642\\u062b\"}', 0, 0, '2026-02-22 23:01:43'),
(198, 21, 'تم قبول إعلانك', 'Listing Approved', 'המודעה אושרה', 'إعلانك الآن متاح للجميع', 'Your listing is now live', 'המודעה שלך זמינה כעת', 'listing_approved', '{\"listing_id\":20,\"listing_type\":\"property\"}', 0, 0, '2026-02-23 01:50:05'),
(199, 12, 'رسالة جديدة من نسيم', 'New message from نسيم', 'הודעה חדשה מنسيم', 'بخصوص: hgvv\nمرحبا', 'About: hgvv\nمرحبا', 'בנוגע ל: hgvv\nمرحبا', 'new_message', '{\"conversation_id\":6,\"listing_type\":\"property\",\"listing_id\":16,\"sender_id\":\"21\"}', 0, 0, '2026-02-23 02:25:03'),
(200, 12, 'رسالة جديدة من نسيم', 'New message from نسيم', 'הודעה חדשה מنسيم', 'بخصوص: hgvv\nكسفك', 'About: hgvv\nكسفك', 'בנוגע ל: hgvv\nكسفك', 'new_message', '{\"conversation_id\":6,\"listing_type\":\"property\",\"listing_id\":16,\"sender_id\":\"21\"}', 0, 0, '2026-02-23 02:25:05');

-- --------------------------------------------------------

--
-- Table structure for table `otp_codes`
--

CREATE TABLE `otp_codes` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `code` varchar(6) NOT NULL,
  `type` enum('phone','email','password_reset') NOT NULL,
  `expires_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `is_used` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `otp_codes`
--

INSERT INTO `otp_codes` (`id`, `user_id`, `phone`, `email`, `code`, `type`, `expires_at`, `is_used`, `created_at`) VALUES
(1, 11, '0599940687', NULL, '737311', 'phone', '2026-01-21 23:56:56', 0, '2026-01-22 00:46:56'),
(2, 12, '0599940688', NULL, '011016', 'phone', '2026-01-22 02:08:41', 0, '2026-01-22 02:58:41'),
(3, 13, '0547840085', NULL, '304433', 'phone', '2026-01-22 10:26:07', 0, '2026-01-22 11:16:07'),
(4, 14, '0548793766', NULL, '644023', 'phone', '2026-01-22 10:33:42', 0, '2026-01-22 11:23:42'),
(5, 15, '0592123455', NULL, '965090', 'phone', '2026-01-24 02:00:48', 0, '2026-01-24 02:50:48'),
(6, 16, '0599940666', NULL, '203443', 'phone', '2026-02-14 00:52:32', 0, '2026-02-14 01:42:32'),
(7, 17, '0546477951', NULL, '002252', 'phone', '2026-02-16 11:11:35', 0, '2026-02-16 12:01:35'),
(8, 18, '0566123424', NULL, '515035', 'phone', '2026-02-16 11:14:57', 0, '2026-02-16 12:04:57'),
(9, 19, '0599940777', NULL, '759656', 'phone', '2026-02-16 11:39:48', 0, '2026-02-16 12:29:48'),
(10, 20, '0599940888', NULL, '044816', 'phone', '2026-02-16 11:46:03', 0, '2026-02-16 12:36:03'),
(11, 21, '0599940999', NULL, '398026', 'phone', '2026-02-16 11:49:16', 0, '2026-02-16 12:39:16'),
(12, 22, '0548794648', NULL, '850349', 'phone', '2026-02-16 12:48:04', 0, '2026-02-16 13:38:04'),
(13, 23, '05548756889', NULL, '048086', 'phone', '2026-02-16 13:03:03', 0, '2026-02-16 13:53:03'),
(14, 24, '054647778', NULL, '860608', 'phone', '2026-02-17 12:07:38', 0, '2026-02-17 12:57:38'),
(15, 25, '054687989', NULL, '250459', 'phone', '2026-02-17 13:00:11', 0, '2026-02-17 13:50:11'),
(16, 26, '0547091183', NULL, '421150', 'phone', '2026-02-17 21:30:39', 0, '2026-02-17 22:20:39');

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `plan_id` int(10) UNSIGNED NOT NULL,
  `subscription_id` int(10) UNSIGNED DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL,
  `currency` varchar(10) DEFAULT 'ILS',
  `platform` enum('ios','android','web') NOT NULL,
  `payment_method` varchar(50) DEFAULT 'test',
  `sender_name` varchar(100) DEFAULT NULL,
  `transfer_date` date DEFAULT NULL,
  `transaction_id` varchar(255) DEFAULT NULL,
  `receipt_data` text DEFAULT NULL,
  `status` enum('pending','completed','failed','refunded') DEFAULT 'pending',
  `verified_at` timestamp NULL DEFAULT NULL,
  `verified_by` int(10) UNSIGNED DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `payments`
--

INSERT INTO `payments` (`id`, `user_id`, `plan_id`, `subscription_id`, `amount`, `currency`, `platform`, `payment_method`, `sender_name`, `transfer_date`, `transaction_id`, `receipt_data`, `status`, `verified_at`, `verified_by`, `notes`, `created_at`, `updated_at`) VALUES
(1, 17, 3, 4, 75.00, 'ILS', 'android', 'test', NULL, NULL, 'TEST_69930828c05fd', NULL, 'completed', NULL, NULL, NULL, '2026-02-16 12:06:00', '2026-02-16 12:06:00'),
(2, 17, 3, 4, 75.00, 'ILS', 'android', 'test', NULL, NULL, 'TEST_69930833b5219', NULL, 'completed', NULL, NULL, NULL, '2026-02-16 12:06:11', '2026-02-16 12:06:11'),
(3, 17, 7, 5, 40.00, 'ILS', 'android', 'test', NULL, NULL, 'TEST_69930994f3ee5', NULL, 'completed', NULL, NULL, NULL, '2026-02-16 12:12:04', '2026-02-16 12:12:04'),
(4, 17, 7, 5, 40.00, 'ILS', 'android', 'test', NULL, NULL, 'TEST_699309a274e58', NULL, 'completed', NULL, NULL, NULL, '2026-02-16 12:12:18', '2026-02-16 12:12:18'),
(5, 17, 14, 4, 0.00, 'ILS', 'android', 'apple_pay', NULL, NULL, 'APPLE_PAY_69930a5f48e48', NULL, 'completed', NULL, NULL, NULL, '2026-02-16 12:15:27', '2026-02-16 12:15:27'),
(6, 18, 14, 6, 0.00, 'ILS', 'android', 'apple_pay', NULL, NULL, 'APPLE_PAY_69930d0fafa65', NULL, 'completed', NULL, NULL, NULL, '2026-02-16 12:26:55', '2026-02-16 12:26:55'),
(7, 17, 14, 4, 0.00, 'ILS', 'android', 'test', NULL, NULL, 'TEST_69930d1ac8374', NULL, 'completed', NULL, NULL, NULL, '2026-02-16 12:27:06', '2026-02-16 12:27:06'),
(8, 21, 15, 10, 0.00, 'ILS', 'android', 'test', NULL, NULL, 'TEST_699313604422a', NULL, 'completed', NULL, NULL, NULL, '2026-02-16 12:53:52', '2026-02-16 12:53:52'),
(9, 21, 4, 13, 200.00, 'ILS', 'android', 'test', NULL, NULL, 'TEST_6994616317ffd', NULL, 'completed', NULL, NULL, NULL, '2026-02-17 12:38:59', '2026-02-17 12:38:59'),
(10, 23, 8, 25, 60.00, 'ILS', 'android', 'apple_pay', NULL, NULL, 'APPLE_PAY_6994690165a7d', NULL, 'completed', '2026-02-22 21:40:51', 1, NULL, '2026-02-17 13:11:29', '2026-02-22 22:40:51'),
(11, 25, 17, 28, 60.00, 'ILS', 'android', 'test', NULL, NULL, 'TEST_6994b430bff13', NULL, 'completed', NULL, NULL, NULL, '2026-02-17 18:32:16', '2026-02-17 18:32:16'),
(12, 26, 1, 30, 50.00, 'ILS', 'android', 'test', NULL, NULL, 'TEST_6994ead4e0a6a', NULL, 'completed', NULL, NULL, NULL, '2026-02-17 22:25:24', '2026-02-17 22:25:24'),
(13, 26, 17, 30, 60.00, 'ILS', 'android', 'test', NULL, NULL, 'TEST_6994ff124d6c1', NULL, 'completed', NULL, NULL, NULL, '2026-02-17 23:51:46', '2026-02-17 23:51:46');

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
  `property_type` enum('apartment','shop_office','villa_chalet','student_housing','land') DEFAULT NULL,
  `car_usage_type` enum('daily','wedding','tourism') DEFAULT NULL,
  `listings_count` int(11) DEFAULT NULL,
  `is_unlimited` tinyint(1) DEFAULT 0,
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

INSERT INTO `plans` (`id`, `category`, `name_ar`, `name_en`, `name_he`, `description_ar`, `description_en`, `description_he`, `plan_type`, `property_type_id`, `car_type_id`, `property_type`, `car_usage_type`, `listings_count`, `is_unlimited`, `duration_days`, `price`, `original_price`, `discount_percent`, `currency`, `badge`, `is_featured`, `allow_region_notifications`, `allow_city_notifications`, `is_trusted_advertiser`, `is_active`, `is_welcome_bonus`, `welcome_bonus_once`, `sort_order`, `created_at`, `updated_at`) VALUES
(1, 'properties', 'إعلان شقة واحد', 'Single Apartment Ad', 'מודעת דירה בודדת', NULL, NULL, NULL, 'single', 1, NULL, 'apartment', NULL, 1, 0, 5, 50.00, NULL, NULL, 'ILS', NULL, 1, 1, 0, 0, 1, 0, 1, 1, '2026-01-21 23:56:25', '2026-02-22 23:57:13'),
(2, 'properties', 'إعلان فيلا واحد', 'Single Villa Ad', 'מודעת וילה בודדת', NULL, NULL, NULL, 'single', 4, NULL, 'villa_chalet', NULL, 15, 0, 30, 100.00, NULL, NULL, 'ILS', NULL, 0, 0, 0, 0, 1, 0, 1, 2, '2026-01-21 23:56:25', '2026-02-22 23:57:13'),
(3, 'properties', 'إعلان محل واحد', 'Single Shop Ad', 'מודעת חנות בודדת', NULL, NULL, NULL, 'single', 6, NULL, 'shop_office', NULL, 30, 0, 30, 75.00, NULL, NULL, 'ILS', NULL, 0, 0, 0, 0, 1, 0, 1, 3, '2026-01-21 23:56:25', '2026-02-22 23:57:13'),
(4, 'properties', 'باقة برونزية', 'Bronze Package', 'חבילת ברונזה', NULL, NULL, NULL, 'package', NULL, NULL, NULL, NULL, 5, 0, 30, 200.00, 250.00, 20, 'ILS', 'bronze', 0, 0, 0, 0, 1, 0, 1, 4, '2026-01-21 23:56:25', '2026-01-21 23:56:25'),
(5, 'properties', 'باقة فضية', 'Silver Package', 'חבילת כסף', NULL, NULL, NULL, 'package', NULL, NULL, NULL, NULL, 10, 0, 30, 350.00, 500.00, 30, 'ILS', 'silver', 0, 0, 0, 0, 1, 0, 1, 5, '2026-01-21 23:56:25', '2026-01-21 23:56:25'),
(6, 'properties', 'باقة ذهبية', 'Gold Package', 'חבילת זהב', NULL, NULL, NULL, 'package', NULL, NULL, NULL, NULL, 1000000, 0, 30, 500.00, 750.00, 33, 'ILS', 'gold', 1, 0, 0, 0, 1, 0, 1, 6, '2026-01-21 23:56:25', '2026-01-23 00:37:57'),
(7, 'cars', 'إعلان سيارة يومية', 'Daily Car Ad', 'מודעת רכב יומית', NULL, NULL, NULL, 'single', NULL, 1, NULL, 'daily', 1, 0, 30, 40.00, NULL, NULL, 'ILS', NULL, 0, 0, 0, 0, 1, 0, 1, 1, '2026-01-21 23:56:25', '2026-02-22 23:57:13'),
(8, 'cars', 'إعلان سيارة أعراس', 'Wedding Car Ad', 'מודעת רכב לחתונות', NULL, NULL, NULL, 'single', NULL, 2, NULL, 'wedding', 1, 0, 30, 60.00, NULL, NULL, 'ILS', NULL, 0, 0, 0, 0, 1, 0, 1, 2, '2026-01-21 23:56:25', '2026-02-22 23:57:13'),
(9, 'cars', 'إعلان سيارة سياحية', 'Tourism Car Ad', 'מודעת רכב לתיירות', NULL, NULL, NULL, 'single', NULL, 3, NULL, 'tourism', 1, 0, 30, 80.00, NULL, NULL, 'ILS', NULL, 0, 0, 0, 0, 1, 0, 1, 3, '2026-01-21 23:56:25', '2026-02-22 23:57:13'),
(10, 'cars', 'باقة سيارات برونزية', 'Bronze Cars Package', 'חבילת רכבים ברונזה', NULL, NULL, NULL, 'package', NULL, NULL, NULL, NULL, 5, 0, 30, 150.00, 200.00, 25, 'ILS', 'bronze', 0, 0, 0, 0, 1, 0, 1, 4, '2026-01-21 23:56:25', '2026-01-21 23:56:25'),
(11, 'cars', 'باقة سيارات فضية', 'Silver Cars Package', 'חבילת רכבים כסף', NULL, NULL, NULL, 'package', NULL, NULL, NULL, NULL, 10, 0, 30, 280.00, 400.00, 30, 'ILS', 'silver', 0, 0, 0, 0, 1, 0, 1, 5, '2026-01-21 23:56:25', '2026-01-21 23:56:25'),
(12, 'cars', 'باقة سيارات ذهبية', 'Gold Cars Package', 'חבילת רכבים זהב', NULL, NULL, NULL, 'package', NULL, NULL, NULL, NULL, NULL, 1, 30, 400.00, 600.00, 33, 'ILS', 'gold', 1, 0, 0, 0, 1, 0, 1, 6, '2026-01-21 23:56:25', '2026-01-21 23:56:25'),
(13, 'properties', 'قفقثف', 'فقثفق', 'فثقفث', NULL, NULL, NULL, 'single', 4, NULL, 'villa_chalet', NULL, 1, 0, 5, 50.00, 70.00, 10, 'ILS', NULL, 1, 0, 0, 0, 1, 0, 1, 1, '2026-02-16 02:03:56', '2026-02-22 23:57:13'),
(14, 'properties', 'باقة مجانية', 'Single Apartment Ad', 'מודעת דירה בודדת', NULL, NULL, NULL, 'single', NULL, NULL, NULL, NULL, 1, 0, 5, 0.00, NULL, NULL, 'ILS', NULL, 0, 0, 0, 0, 1, 1, 1, 0, '2026-02-16 12:12:13', '2026-02-17 14:18:34'),
(15, 'properties', 'tamer', 'tamer', 'tamer', NULL, NULL, NULL, 'single', NULL, NULL, NULL, NULL, 1, 1, 1, 1122.00, NULL, NULL, 'ILS', NULL, 0, 0, 0, 0, 0, 0, 1, 0, '2026-02-16 12:13:59', '2026-02-16 13:28:33'),
(16, 'cars', 'باقة مجانية سيارات', 'Single Apartment Ad', 'מודעת דירה בודדת', NULL, NULL, NULL, 'single', NULL, NULL, NULL, NULL, 1, 0, 2, 0.00, NULL, NULL, 'ILS', NULL, 0, 0, 0, 0, 1, 1, 1, 0, '2026-02-16 12:41:46', '2026-02-16 12:41:46'),
(17, 'properties', 'سكن طلابي', 'student apartment', 'דירה תלמידום', NULL, NULL, NULL, 'single', 8, NULL, 'student_housing', NULL, 1, 0, 30, 60.00, 100.00, NULL, 'ILS', NULL, 0, 0, 0, 0, 1, 0, 1, 0, '2026-02-17 13:58:51', '2026-02-22 23:57:13');

-- --------------------------------------------------------

--
-- Table structure for table `properties`
--

CREATE TABLE `properties` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `property_type` enum('apartment','shop_office','villa_chalet','student_housing','land') NOT NULL,
  `property_type_id` int(10) UNSIGNED DEFAULT NULL,
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
  `language` enum('ar','he') DEFAULT 'ar',
  `contact_phone` varchar(20) NOT NULL,
  `whatsapp` varchar(20) DEFAULT NULL,
  `status` enum('draft','pending_payment','pending_admin_review','active','expired','paused','rejected') DEFAULT 'draft',
  `is_trusted` tinyint(1) DEFAULT 0,
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

INSERT INTO `properties` (`id`, `user_id`, `title`, `property_type`, `property_type_id`, `region_id`, `city_id`, `address_text`, `price_type`, `price`, `price_from`, `price_to`, `currency`, `bedrooms`, `bathrooms`, `floor`, `area_m2`, `bio`, `language`, `contact_phone`, `whatsapp`, `status`, `is_trusted`, `reject_reason`, `views_count`, `subscription_id`, `expires_at`, `created_at`, `updated_at`) VALUES
(1, 4, 'شقة فاخرة في وسط المدينة', 'apartment', 1, 1, 1, NULL, 'fixed', 3500.00, NULL, NULL, 'ILS', 3, 2, NULL, 120.00, 'شقة مميزة بإطلالة رائعة، قريبة من جميع الخدمات، 3 غرف نوم مع صالة واسعة', 'ar', '+972504567890', NULL, 'active', 0, NULL, 54, NULL, '2026-02-20 23:56:25', '2026-01-21 23:56:25', '2026-02-22 23:46:20'),
(2, 4, 'شقة عائلية واسعة', 'apartment', 1, 1, 2, NULL, 'fixed', 4200.00, NULL, NULL, 'ILS', 4, 2, NULL, 150.00, 'شقة مناسبة للعائلات، 4 غرف نوم مع صالة كبيرة وبلكونة', 'ar', '+972504567890', NULL, 'active', 0, NULL, 38, NULL, '2026-02-20 23:56:25', '2026-01-21 23:56:25', '2026-02-22 23:46:20'),
(3, 5, 'استوديو مفروش بالكامل', 'apartment', 1, 2, 5, NULL, 'fixed', 2000.00, NULL, NULL, 'ILS', 1, 1, NULL, 45.00, 'استوديو حديث مجهز بالكامل للإيجار الشهري، مناسب للعزاب', 'ar', '+972505678901', NULL, 'active', 0, NULL, 34, NULL, '2026-02-20 23:56:25', '2026-01-21 23:56:25', '2026-02-22 23:46:20'),
(4, 5, 'سكن طلابي قرب الجامعة', 'student_housing', 8, 2, 6, NULL, 'fixed', 1200.00, NULL, NULL, 'ILS', 1, 1, NULL, 20.00, 'غرفة مفروشة في شقة مشتركة، قريبة من الجامعة والمواصلات', 'ar', '+972505678901', NULL, 'active', 0, NULL, 36, NULL, '2026-02-20 23:56:25', '2026-01-21 23:56:25', '2026-02-22 23:46:20'),
(5, 6, 'شقة جديدة تشطيب سوبر ديلوكس', 'apartment', 1, 1, 3, NULL, 'fixed', 5000.00, NULL, NULL, 'ILS', 3, 2, NULL, 130.00, 'شقة جديدة لم تسكن من قبل، تشطيب فاخر مع مصعد وموقف سيارة', 'ar', '+972506789012', NULL, 'active', 0, NULL, 34, NULL, '2026-02-20 23:56:25', '2026-01-21 23:56:25', '2026-02-22 23:46:20'),
(6, 9, 'فيلا فاخرة مع مسبح خاص', 'villa_chalet', 4, 3, 9, NULL, 'fixed', 12000.00, NULL, NULL, 'ILS', 5, 4, NULL, 350.00, 'فيلا راقية مع حديقة ومسبح، مناسبة للعائلات الكبيرة', 'ar', '+972509012345', NULL, 'active', 0, NULL, 30, NULL, '2026-02-20 23:56:25', '2026-01-21 23:56:25', '2026-02-22 23:46:20'),
(7, 9, 'شاليه على البحر مباشرة', 'villa_chalet', 4, 3, 10, NULL, 'fixed', 8000.00, NULL, NULL, 'ILS', 3, 2, NULL, 150.00, 'شاليه رائع بإطلالة مباشرة على البحر، مثالي للعطلات', 'ar', '+972509012345', NULL, 'active', 0, NULL, 37, NULL, '2026-02-20 23:56:25', '2026-01-21 23:56:25', '2026-02-22 23:46:20'),
(8, 10, 'محل تجاري في موقع استراتيجي', 'shop_office', 6, 1, 1, NULL, 'fixed', 6000.00, NULL, NULL, 'ILS', 0, 1, NULL, 80.00, 'محل بواجهة زجاجية كبيرة على الشارع الرئيسي، موقع ممتاز', 'ar', '+972500123456', NULL, 'active', 0, NULL, 17, NULL, '2026-02-20 23:56:25', '2026-01-21 23:56:25', '2026-02-22 23:46:20'),
(9, 10, 'مكتب مجهز في برج تجاري', 'shop_office', 6, 2, 5, NULL, 'fixed', 4500.00, NULL, NULL, 'ILS', 0, 2, NULL, 100.00, 'مكتب جاهز للاستخدام مع قاعة اجتماعات ومطبخ صغير', 'ar', '+972500123456', NULL, 'active', 0, NULL, 21, NULL, '2026-02-20 23:56:25', '2026-01-21 23:56:25', '2026-02-22 23:46:20'),
(10, 4, 'أرض للإيجار صالحة للزراعة', 'land', 9, 3, 11, NULL, 'fixed', 3000.00, NULL, NULL, 'ILS', 0, 0, NULL, 5000.00, 'أرض واسعة مع مصدر مياه، مناسبة للمشاريع الزراعية', 'ar', '+972504567890', NULL, 'active', 0, NULL, 23, NULL, '2026-02-20 23:56:25', '2026-01-21 23:56:25', '2026-02-22 23:46:20'),
(11, 5, 'غرفة في سكن طلابي مشترك', 'student_housing', 8, 2, 6, NULL, 'fixed', 1500.00, NULL, NULL, 'ILS', 1, 1, NULL, 25.00, 'غرفة مفروشة مع إنترنت ومرافق مشتركة', 'ar', '+972505678901', NULL, 'active', 0, NULL, 22, NULL, '2026-02-20 23:56:25', '2026-01-21 23:56:25', '2026-02-22 23:46:20'),
(12, 6, 'شقة للإيجار بسعر مناسب', 'apartment', 1, 1, 4, NULL, 'fixed', 2800.00, NULL, NULL, 'ILS', 2, 1, NULL, 85.00, 'شقة نظيفة ومرتبة في منطقة هادئة', 'ar', '+972506789012', NULL, 'active', 0, NULL, 25, NULL, '2026-02-20 23:56:25', '2026-01-21 23:56:25', '2026-02-22 23:46:20'),
(13, 12, 'hdhdjhdh', 'shop_office', 6, 2, 13, 'hshdjshe', 'fixed', 1200.00, NULL, NULL, 'ILS', 111, 111, NULL, NULL, 'vsbsbsbsb', 'ar', '0599940688', '', 'active', 0, NULL, 49, NULL, NULL, '2026-01-22 03:11:39', '2026-02-23 02:16:57'),
(14, 12, 'gvv', 'shop_office', 6, 2, 11, 'bbvv', 'fixed', 1200.00, NULL, NULL, 'ILS', NULL, NULL, NULL, NULL, '', 'ar', '0599940688', '', 'active', 0, NULL, 50, NULL, NULL, '2026-01-22 03:34:55', '2026-02-23 00:47:31'),
(15, 12, 'gg', 'villa_chalet', 4, 2, 13, 'vvvv', 'fixed', 12000.00, NULL, NULL, 'ILS', NULL, NULL, NULL, NULL, 'cccccc', 'ar', '0599940688', '', 'active', 0, NULL, 62, NULL, NULL, '2026-01-22 03:50:33', '2026-02-23 00:47:15'),
(16, 12, 'hgvv', 'shop_office', 6, 2, 13, 'vvv', 'fixed', 1500.00, NULL, NULL, 'ILS', NULL, NULL, NULL, NULL, 'gv', 'ar', '0599940688', '', 'active', 0, NULL, 63, NULL, NULL, '2026-01-22 03:52:19', '2026-02-23 02:24:58'),
(17, 11, 'قثفثق', 'apartment', 1, 1, 8, 'فثقفقث', 'fixed', 1200.00, NULL, NULL, 'ILS', 1, 1, 1, 120.00, 'هخعغهغع', 'ar', '0599940687', '0599940687', 'active', 0, NULL, 59, NULL, NULL, '2026-01-22 11:42:45', '2026-02-23 00:47:27'),
(18, 21, 'bxbdbd', 'villa_chalet', 4, 3, 16, 'xnndb', 'fixed', 10000.00, NULL, NULL, 'ILS', NULL, NULL, NULL, NULL, 'wjhsssbsbbbsbsb', 'ar', '0599940999', '0599940999', 'active', 0, NULL, 0, 10, NULL, '2026-02-16 12:48:47', '2026-02-22 23:46:20'),
(19, 21, 'hddbb', 'apartment', 1, 3, 16, 'ndndn', 'fixed', 1000.00, NULL, NULL, 'ILS', 1, 1, NULL, NULL, 'snsnndb', 'ar', '0599940999', '0599940999', 'active', 0, NULL, 3, 10, NULL, '2026-02-16 12:53:56', '2026-02-23 00:57:50'),
(20, 21, 'bdbdb', 'shop_office', 6, 2, 11, 'hddh', 'fixed', 100.00, NULL, NULL, 'ILS', 1, NULL, NULL, NULL, 'hshdj', 'ar', '0599940999', '0599940999', 'active', 0, NULL, 0, 10, NULL, '2026-02-16 12:55:17', '2026-02-23 01:50:05'),
(21, 21, 'bdbdb', 'shop_office', 6, 3, 17, 'nzdndn', 'fixed', 195992.00, NULL, NULL, 'ILS', NULL, NULL, NULL, NULL, 'ndndnd', 'ar', '0599940999', '0599940999', 'pending_admin_review', 0, NULL, 0, 10, NULL, '2026-02-16 12:55:46', '2026-02-22 23:46:20'),
(22, 21, 'jdjdnd', 'shop_office', 6, 3, 17, 'nddn', 'fixed', 5959959.00, NULL, NULL, 'ILS', NULL, NULL, NULL, NULL, 'jdndndnnd', 'ar', '0599940999', '0599940999', 'rejected', 0, 'قثقثقث', 0, 10, NULL, '2026-02-16 12:56:05', '2026-02-22 23:46:20'),
(23, 21, 'ndnd', 'shop_office', 6, 2, 12, 'nddn', 'fixed', 1000.00, NULL, NULL, 'ILS', NULL, NULL, NULL, NULL, 'jdndnsn', 'ar', '0599940999', '0599940999', 'active', 0, NULL, 0, 10, NULL, '2026-02-16 12:56:28', '2026-02-22 23:46:20'),
(24, 24, 'hdhd', 'villa_chalet', 4, 2, 12, 'fs ddecac', 'fixed', 1234.00, NULL, NULL, 'ILS', 1, 2, 4, 33.00, 'dddda', 'ar', '054647778', '054647778', 'active', 0, NULL, 4, 26, NULL, '2026-02-17 12:58:37', '2026-02-22 23:46:20'),
(25, 25, 'نابلس', 'student_housing', 8, 1, 2, NULL, 'fixed', 200.00, NULL, NULL, 'ILS', NULL, 2, 5, 50.00, NULL, 'ar', '054687989', '054687989', 'active', 0, 'الرجاء وضع صور ', 4, 28, NULL, '2026-02-17 18:32:35', '2026-02-22 23:46:20'),
(26, 26, 'القدس الطور ', 'apartment', 1, 2, 11, NULL, 'fixed', 3000.00, NULL, NULL, 'ILS', 2, 2, 4, 150.00, 'بتجنن\n\n', 'ar', '0547091183', '0547091183', 'active', 0, NULL, 0, 30, NULL, '2026-02-17 22:25:32', '2026-02-22 23:46:20'),
(27, 21, NULL, 'villa_chalet', 4, 2, 12, 'تتتنهتتتتتتت', 'fixed', 1500.00, NULL, NULL, 'ILS', 2, NULL, 2, NULL, 'اغات', 'ar', '0599940999', '0599940999', 'active', 0, NULL, 1, 13, NULL, '2026-02-22 22:38:00', '2026-02-22 23:46:20');

-- --------------------------------------------------------

--
-- Table structure for table `property_media`
--

CREATE TABLE `property_media` (
  `id` int(10) UNSIGNED NOT NULL,
  `property_id` int(10) UNSIGNED NOT NULL,
  `media_type` enum('image','video') DEFAULT 'image',
  `file_path` varchar(500) NOT NULL,
  `file_name` varchar(255) DEFAULT NULL,
  `sort_order` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `property_media`
--

INSERT INTO `property_media` (`id`, `property_id`, `media_type`, `file_path`, `file_name`, `sort_order`, `created_at`) VALUES
(1, 1, 'image', 'sample.png', NULL, 1, '2026-01-21 23:56:25'),
(2, 2, 'image', 'sample.png', NULL, 1, '2026-01-21 23:56:25'),
(3, 3, 'image', 'sample.png', NULL, 1, '2026-01-21 23:56:25'),
(4, 4, 'image', 'sample.png', NULL, 1, '2026-01-21 23:56:25'),
(5, 5, 'image', 'sample.png', NULL, 1, '2026-01-21 23:56:25'),
(6, 6, 'image', 'sample.png', NULL, 1, '2026-01-21 23:56:25'),
(7, 7, 'image', 'sample.png', NULL, 1, '2026-01-21 23:56:25'),
(8, 8, 'image', 'sample.png', NULL, 1, '2026-01-21 23:56:25'),
(9, 9, 'image', 'sample.png', NULL, 1, '2026-01-21 23:56:25'),
(10, 10, 'image', 'sample.png', NULL, 1, '2026-01-21 23:56:25'),
(11, 11, 'image', 'sample.png', NULL, 1, '2026-01-21 23:56:25'),
(12, 12, 'image', 'sample.png', NULL, 1, '2026-01-21 23:56:25'),
(13, 14, 'image', 'images/properties/69719ae027ad2_1769052896.jpg', '69719ae027ad2_1769052896.jpg', 0, '2026-01-22 03:34:56'),
(14, 15, 'image', 'images/properties/69719e8a26869_1769053834.jpg', '69719e8a26869_1769053834.jpg', 0, '2026-01-22 03:50:34'),
(15, 16, 'image', 'images/properties/69719ef4d2499_1769053940.jpg', '69719ef4d2499_1769053940.jpg', 0, '2026-01-22 03:52:20'),
(16, 16, 'image', 'images/properties/69719ef586b2b_1769053941.jpg', '69719ef586b2b_1769053941.jpg', 1, '2026-01-22 03:52:21'),
(17, 16, 'image', 'images/properties/69719ef6b26df_1769053942.jpg', '69719ef6b26df_1769053942.jpg', 2, '2026-01-22 03:52:22'),
(18, 17, 'image', 'images/properties/69720d352563e_1769082165.jpg', '69720d352563e_1769082165.jpg', 0, '2026-01-22 11:42:45');

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
(1, 'شقة', 'Apartment', 'דירה', 'apartment', 'apartment', 1, 1, '2026-02-22 23:46:20', '2026-02-22 23:46:20'),
(2, 'غرفة', 'Room', 'חדר', 'room', 'bed', 1, 2, '2026-02-22 23:46:20', '2026-02-22 23:46:20'),
(3, 'استوديو', 'Studio', 'סטודיו', 'studio', 'home', 1, 3, '2026-02-22 23:46:20', '2026-02-22 23:46:20'),
(4, 'فيلا', 'Villa', 'וילה', 'villa', 'villa', 1, 4, '2026-02-22 23:46:20', '2026-02-22 23:46:20'),
(5, 'شاليه', 'Chalet', 'שאלה', 'chalet', 'cabin', 1, 5, '2026-02-22 23:46:20', '2026-02-22 23:46:20'),
(6, 'محل تجاري', 'Shop', 'חנות', 'shop', 'store', 1, 6, '2026-02-22 23:46:20', '2026-02-22 23:46:20'),
(7, 'مكتب', 'Office', 'משרד', 'office', 'work', 1, 7, '2026-02-22 23:46:20', '2026-02-22 23:46:20'),
(8, 'سكن طلاب', 'Student Housing', 'דיור סטודנטים', 'student_housing', 'school', 1, 8, '2026-02-22 23:46:20', '2026-02-22 23:46:20'),
(9, 'أرض', 'Land', 'קרקע', 'land', 'landscape', 1, 9, '2026-02-22 23:46:20', '2026-02-22 23:46:20'),
(10, 'مبنى', 'Building', 'בניין', 'building', 'business', 1, 10, '2026-02-22 23:46:20', '2026-02-22 23:46:20'),
(11, 'غرافانات', 'Caravans', 'קרוואנים', 'caravans', 'home', 1, 11, '2026-02-23 00:08:25', '2026-02-23 00:08:25');

-- --------------------------------------------------------

--
-- Table structure for table `realtime_messages`
--

CREATE TABLE `realtime_messages` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `message_type` varchar(50) NOT NULL COMMENT 'new_chat_message, typing, read_receipt, etc',
  `message_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`message_data`)),
  `is_delivered` tinyint(1) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `realtime_messages`
--

INSERT INTO `realtime_messages` (`id`, `user_id`, `message_type`, `message_data`, `is_delivered`, `created_at`) VALUES
(1, 12, 'new_chat_message', '{\"conversation_id\":6,\"message\":{\"id\":17,\"conversation_id\":6,\"sender_id\":21,\"message\":\"\\u0645\\u0631\\u062d\\u0628\\u0627\",\"is_read\":0,\"created_at\":\"2026-02-23 03:25:02\",\"sender_name\":\"\\u0646\\u0633\\u064a\\u0645\",\"sender_image\":null}}', 0, '2026-02-23 02:25:03'),
(2, 12, 'new_chat_message', '{\"conversation_id\":6,\"message\":{\"id\":18,\"conversation_id\":6,\"sender_id\":21,\"message\":\"\\u0643\\u0633\\u0641\\u0643\",\"is_read\":0,\"created_at\":\"2026-02-23 03:25:05\",\"sender_name\":\"\\u0646\\u0633\\u064a\\u0645\",\"sender_image\":null}}', 0, '2026-02-23 02:25:06');

-- --------------------------------------------------------

--
-- Table structure for table `regions`
--

CREATE TABLE `regions` (
  `id` int(10) UNSIGNED NOT NULL,
  `name_ar` varchar(255) NOT NULL,
  `name_en` varchar(255) NOT NULL,
  `name_he` varchar(255) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `is_active` tinyint(1) DEFAULT 1,
  `sort_order` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `regions`
--

INSERT INTO `regions` (`id`, `name_ar`, `name_en`, `name_he`, `slug`, `is_active`, `sort_order`, `created_at`) VALUES
(1, 'الضفة الغربية', 'West Bank', 'הגדה המערבית', 'west-bank', 1, 1, '2026-01-21 23:56:25'),
(2, 'القدس', 'Jerusalem', 'ירושלים', 'jerusalem', 1, 2, '2026-01-21 23:56:25'),
(3, 'الداخل', 'Israel', 'ישראל', 'israel', 1, 3, '2026-01-21 23:56:25'),
(4, 'النقب', 'Negev', 'הנגב', 'negev', 1, 4, '2026-01-21 23:56:25');

-- --------------------------------------------------------

--
-- Table structure for table `reports`
--

CREATE TABLE `reports` (
  `id` int(10) UNSIGNED NOT NULL,
  `reporter_id` int(10) UNSIGNED NOT NULL,
  `listing_type` enum('property','car') NOT NULL,
  `listing_id` int(10) UNSIGNED NOT NULL,
  `reported_user_id` int(10) UNSIGNED NOT NULL,
  `reason` text NOT NULL,
  `screenshot` varchar(500) DEFAULT NULL,
  `status` enum('pending','reviewed','resolved','dismissed') DEFAULT 'pending',
  `admin_notes` text DEFAULT NULL,
  `reviewed_by` int(10) UNSIGNED DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `subscriptions`
--

CREATE TABLE `subscriptions` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `plan_id` int(10) UNSIGNED NOT NULL,
  `category` enum('properties','cars') DEFAULT NULL,
  `listings_used` int(11) DEFAULT 0,
  `listings_limit` int(11) DEFAULT NULL,
  `is_unlimited` tinyint(1) DEFAULT 0,
  `status` enum('active','expired','cancelled') DEFAULT 'active',
  `payment_method` varchar(50) DEFAULT 'test',
  `payment_reference` varchar(100) DEFAULT NULL,
  `starts_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `expires_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `subscriptions`
--

INSERT INTO `subscriptions` (`id`, `user_id`, `plan_id`, `category`, `listings_used`, `listings_limit`, `is_unlimited`, `status`, `payment_method`, `payment_reference`, `starts_at`, `expires_at`, `created_at`) VALUES
(1, 11, 1, NULL, 0, 1, 0, 'active', 'test', NULL, '2026-01-22 13:40:23', '2026-02-21 12:40:23', '2026-01-22 13:40:23'),
(2, 11, 1, NULL, 0, 1, 0, 'active', 'test', NULL, '2026-01-23 00:31:03', '2026-02-21 23:31:03', '2026-01-23 00:31:03'),
(3, 12, 5, NULL, 0, 10, 0, 'active', 'test', NULL, '2026-01-28 21:16:17', '2026-02-27 20:16:17', '2026-01-28 21:16:17'),
(4, 17, 3, 'properties', 0, 62, 0, 'active', 'test', 'TEST_1771243560_17', '2026-02-16 12:06:00', '2026-03-18 11:06:11', '2026-02-16 12:06:00'),
(5, 17, 7, 'cars', 0, 2, 0, 'active', 'test', 'TEST_1771243924_17', '2026-02-16 12:12:04', '2026-03-18 11:12:18', '2026-02-16 12:12:04'),
(6, 18, 14, 'properties', 0, 1, 0, 'active', 'apple_pay', 'APPLE_PAY_1771244815_18', '2026-02-16 12:26:55', '2026-02-21 11:26:55', '2026-02-16 12:26:55'),
(7, 15, 1, NULL, 0, 1, 0, 'active', 'test', NULL, '2026-02-16 12:27:44', '2026-02-21 11:27:44', '2026-02-16 12:27:44'),
(8, 15, 1, NULL, 0, 1, 0, 'active', 'test', NULL, '2026-02-16 12:27:47', '2026-02-21 11:27:47', '2026-02-16 12:27:47'),
(9, 21, 15, 'properties', 0, 1, 1, 'active', 'welcome_bonus', 'WELCOME_BONUS_21', '2026-02-16 11:39:16', '2026-02-17 11:39:16', '2026-02-16 12:39:16'),
(10, 21, 14, 'properties', 6, 999999, 1, 'active', 'welcome_bonus', 'WELCOME_BONUS_21', '2026-02-16 12:45:53', '2026-02-21 12:45:53', '2026-02-16 12:45:53'),
(11, 21, 16, 'cars', 0, 1, 0, 'active', 'welcome_bonus', 'WELCOME_BONUS_21', '2026-02-16 12:45:53', '2026-02-18 12:45:53', '2026-02-16 12:45:53'),
(13, 21, 14, 'properties', 1, 7, 0, 'active', 'welcome_bonus', 'WELCOME_BONUS_21', '2026-02-16 13:02:39', '2026-03-19 11:38:59', '2026-02-16 13:02:39'),
(14, 21, 16, 'cars', 0, 1, 0, 'active', 'welcome_bonus', 'WELCOME_BONUS_21', '2026-02-16 13:02:39', '2026-02-18 13:02:39', '2026-02-16 13:02:39'),
(16, 13, 2, NULL, 0, 15, 0, 'active', 'test', NULL, '2026-02-16 13:11:29', '2026-03-18 12:11:29', '2026-02-16 13:11:29'),
(17, 13, 1, NULL, 0, 1, 0, 'active', 'test', NULL, '2026-02-16 13:11:44', '2026-02-21 12:11:44', '2026-02-16 13:11:44'),
(18, 15, 9, NULL, 0, 1, 0, 'active', 'test', NULL, '2026-02-16 13:12:33', '2026-03-18 12:12:33', '2026-02-16 13:12:33'),
(19, 15, 7, NULL, 0, 1, 0, 'active', 'test', NULL, '2026-02-16 13:12:37', '2026-03-18 12:12:37', '2026-02-16 13:12:37'),
(20, 15, 2, NULL, 0, 15, 0, 'active', 'test', NULL, '2026-02-16 13:12:41', '2026-03-18 12:12:41', '2026-02-16 13:12:41'),
(21, 11, 7, NULL, 0, 1, 0, 'active', 'test', NULL, '2026-02-16 13:28:53', '2026-03-18 12:28:53', '2026-02-16 13:28:53'),
(22, 22, 14, 'properties', 0, 2, 0, 'active', 'welcome_bonus', 'WELCOME_BONUS_22', '2026-02-16 12:38:04', '2026-02-21 12:38:04', '2026-02-16 13:38:04'),
(23, 22, 16, 'cars', 0, 1, 0, 'active', 'welcome_bonus', 'WELCOME_BONUS_22', '2026-02-16 12:38:04', '2026-02-18 12:38:04', '2026-02-16 13:38:04'),
(24, 23, 14, 'properties', 0, 2, 0, 'active', 'welcome_bonus', 'WELCOME_BONUS_23', '2026-02-16 12:53:03', '2026-02-21 12:53:03', '2026-02-16 13:53:03'),
(25, 23, 16, 'cars', 1, 2, 0, 'active', 'welcome_bonus', 'WELCOME_BONUS_23', '2026-02-16 12:53:03', '2026-03-19 12:11:29', '2026-02-16 13:53:03'),
(26, 24, 14, 'properties', 1, 2, 0, 'active', 'welcome_bonus', 'WELCOME_BONUS_24', '2026-02-17 11:57:38', '2026-02-22 11:57:38', '2026-02-17 12:57:38'),
(27, 24, 16, 'cars', 0, 1, 0, 'active', 'welcome_bonus', 'WELCOME_BONUS_24', '2026-02-17 11:57:38', '2026-02-19 11:57:38', '2026-02-17 12:57:38'),
(28, 25, 14, 'properties', 1, 3, 0, 'active', 'welcome_bonus', 'WELCOME_BONUS_25', '2026-02-17 12:50:11', '2026-03-19 17:32:16', '2026-02-17 13:50:11'),
(29, 25, 16, 'cars', 0, 1, 0, 'active', 'welcome_bonus', 'WELCOME_BONUS_25', '2026-02-17 12:50:11', '2026-02-19 12:50:11', '2026-02-17 13:50:11'),
(30, 26, 14, 'properties', 1, 3, 0, 'active', 'welcome_bonus', 'WELCOME_BONUS_26', '2026-02-17 21:20:39', '2026-03-19 22:51:46', '2026-02-17 22:20:39'),
(31, 26, 16, 'cars', 0, 1, 0, 'active', 'welcome_bonus', 'WELCOME_BONUS_26', '2026-02-17 21:20:39', '2026-02-19 21:20:39', '2026-02-17 22:20:39');

-- --------------------------------------------------------

--
-- Table structure for table `subscription_requests`
--

CREATE TABLE `subscription_requests` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `plan_id` int(10) UNSIGNED NOT NULL,
  `status` enum('pending','approved','rejected') DEFAULT 'pending',
  `admin_notes` text DEFAULT NULL,
  `reviewed_by` int(10) UNSIGNED DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `subscription_requests`
--

INSERT INTO `subscription_requests` (`id`, `user_id`, `plan_id`, `status`, `admin_notes`, `reviewed_by`, `reviewed_at`, `created_at`, `updated_at`) VALUES
(1, 11, 1, 'approved', '756756', 1, '2026-01-22 12:40:23', '2026-01-22 13:40:11', '2026-01-22 13:40:23'),
(2, 11, 1, 'approved', '', 1, '2026-01-22 23:31:03', '2026-01-23 00:18:13', '2026-01-23 00:31:03'),
(3, 11, 1, 'rejected', '65765', 1, '2026-01-22 23:36:21', '2026-01-23 00:31:35', '2026-01-23 00:36:21'),
(4, 11, 1, 'pending', NULL, NULL, NULL, '2026-01-23 00:39:49', '2026-01-23 00:39:49'),
(5, 11, 7, 'approved', 'فققف', 1, '2026-02-16 12:28:53', '2026-01-23 00:40:05', '2026-02-16 13:28:53'),
(6, 11, 8, 'pending', NULL, NULL, NULL, '2026-01-23 00:40:05', '2026-01-23 00:40:05'),
(7, 15, 1, 'approved', '', 1, '2026-02-16 11:27:47', '2026-01-24 02:51:07', '2026-02-16 12:27:47'),
(8, 15, 2, 'approved', '', 1, '2026-02-16 12:12:41', '2026-01-24 02:51:11', '2026-02-16 13:12:41'),
(9, 15, 7, 'approved', '', 1, '2026-02-16 12:12:37', '2026-01-24 02:51:14', '2026-02-16 13:12:37'),
(10, 15, 9, 'approved', '', 1, '2026-02-16 12:12:33', '2026-01-24 02:51:19', '2026-02-16 13:12:33'),
(11, 13, 1, 'approved', 'خهحخهحخه', 1, '2026-02-16 12:11:44', '2026-01-24 08:11:45', '2026-02-16 13:11:44'),
(12, 13, 2, 'approved', 'ثقفقثف', 1, '2026-02-16 12:11:29', '2026-01-25 11:23:43', '2026-02-16 13:11:29'),
(13, 12, 5, 'approved', 'l,htr', 1, '2026-01-28 20:16:17', '2026-01-28 21:15:53', '2026-01-28 21:16:17');

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
(1, 'أحمد محمد', NULL, 'ahmed@test.com', '+972501234567', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'renter', NULL, 1, 1, 1, NULL, 1, 0, 0, 1, 'ar', NULL, 1, '2026-01-21 23:56:25', '2026-01-22 03:09:15', NULL, NULL),
(2, 'سارة أحمد', NULL, 'sara@test.com', '+972502345678', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'renter', NULL, 1, 1, 0, NULL, 1, 0, 0, 1, 'ar', NULL, 1, '2026-01-21 23:56:25', '2026-01-21 23:56:25', NULL, NULL),
(3, 'محمد علي', NULL, 'mohamed@test.com', '+972503456789', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'renter', NULL, 1, 1, 0, NULL, 1, 0, 0, 1, 'ar', NULL, 1, '2026-01-21 23:56:25', '2026-01-21 23:56:25', NULL, NULL),
(4, 'عبدالله العمري', NULL, 'abdullah@test.com', '+972504567890', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'owner', NULL, 1, 1, 1, NULL, 1, 0, 0, 1, 'ar', NULL, 1, '2026-01-21 23:56:25', '2026-01-21 23:56:25', NULL, NULL),
(5, 'فاطمة حسن', NULL, 'fatima@test.com', '+972505678901', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'owner', NULL, 1, 1, 1, NULL, 1, 0, 0, 1, 'ar', NULL, 1, '2026-01-21 23:56:25', '2026-01-21 23:56:25', NULL, NULL),
(6, 'خالد الشمري', NULL, 'khaled@test.com', '+972506789012', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'owner', NULL, 1, 1, 0, NULL, 1, 0, 0, 1, 'ar', NULL, 1, '2026-01-21 23:56:25', '2026-01-21 23:56:25', NULL, NULL),
(7, 'يوسف الزهراني', NULL, 'yousef@test.com', '+972507890123', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'car_lessor', NULL, 1, 1, 1, NULL, 1, 0, 0, 1, 'ar', NULL, 1, '2026-01-21 23:56:25', '2026-01-21 23:56:25', NULL, NULL),
(8, 'نورة السالم', NULL, 'noura@test.com', '+972508901234', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'car_lessor', NULL, 1, 1, 0, NULL, 1, 0, 0, 1, 'ar', NULL, 1, '2026-01-21 23:56:25', '2026-01-21 23:56:25', NULL, NULL),
(9, 'مكتب الأمانة العقاري', NULL, 'amana@test.com', '+972509012345', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'office', NULL, 1, 1, 1, NULL, 1, 0, 0, 1, 'ar', NULL, 1, '2026-01-21 23:56:25', '2026-01-21 23:56:25', NULL, NULL),
(10, 'مكتب النجاح للعقارات', NULL, 'najah@test.com', '+972500123456', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'office', NULL, 1, 1, 1, NULL, 1, 0, 0, 1, 'ar', NULL, 1, '2026-01-21 23:56:25', '2026-01-21 23:56:25', NULL, NULL),
(11, 'naseem', NULL, 'www.palestine.it@gmail.com', '0599940687', '$2y$10$U9xDnb9qbY3kfIoJWmbfCu7Mgv5/YIkxVetihWTjsyhHZoINp8qGm', 'owner', NULL, 0, 0, 1, '2026-02-22', 1, 0, 0, 1, 'ar', 'dhL3HhqLTlaWzfLaUp7RDo:APA91bELODQFL6IQKozjOT4SEW2tZgkix71Ehuiacjk77LPwLp86nNCtqYuT6JxG6qFzghW24_P6uIgQmOdzCQWK9QUaNgZWYN99A5soxHD_gi7nqcklllc', 1, '2026-01-22 00:46:56', '2026-01-24 07:24:06', NULL, NULL),
(12, 'naseem tom', NULL, 'www.palestine.iwt@gmail.com', '0599940688', '$2y$10$opd0OapiIZWqEgjqWE5erugMsHho1AFTvMljs1wxb45zGAk.wwh0m', 'owner', NULL, 0, 0, 1, '2026-02-22', 1, 0, 0, 1, 'ar', 'dhL3HhqLTlaWzfLaUp7RDo:APA91bELODQFL6IQKozjOT4SEW2tZgkix71Ehuiacjk77LPwLp86nNCtqYuT6JxG6qFzghW24_P6uIgQmOdzCQWK9QUaNgZWYN99A5soxHD_gi7nqcklllc', 1, '2026-01-22 02:58:41', '2026-01-28 21:15:40', NULL, NULL),
(13, 'محمد', NULL, 'mhmfkhweis.mk@gmail.com', '0547840085', '$2y$10$b9Z0xFJxzbn9WlHiWJiV4OKrAuD6hvK5y5pFIaMnjfC5M08pUPD/G', 'renter', NULL, 0, 0, 0, NULL, 1, 0, 0, 1, 'ar', 'dh1pOINjRL6KfkjoL-PbmJ:APA91bGEGEXmH9Ck59N5vKl_jqlWZRCFgyeOo0558RedxDIt_0cyTYVVkk-t9OTZHaDs4CPSLiNsjg4nwwEmtfJw5W0PPqUyBzBgVrVt3t7mJAx_F0Pj_Sw', 1, '2026-01-22 11:16:07', '2026-01-24 08:10:57', NULL, NULL),
(14, 'mohammad', NULL, 'mhmdkhweis.mk@gnail.com', '0548793766', '$2y$10$ajPmtJjTSYzl3HtPPnF2Eep1LTdnF/rbW/p7E2Q5EBJyVFq/H4Zfe', 'car_lessor', NULL, 0, 0, 0, NULL, 1, 0, 0, 1, 'ar', NULL, 1, '2026-01-22 11:23:42', '2026-01-24 07:37:45', NULL, NULL),
(15, 'kelane', NULL, 'kelaneps2@gmail.com', '0592123455', '$2y$10$gKeFUzvlCRZcG1qNCwWOtOpU7c/iV/4Z75N8AtHirvPkBiS4C4tEe', 'renter', NULL, 0, 0, 0, NULL, 1, 0, 0, 1, 'ar', 'eniaAAXORd66uF0MuR4etO:APA91bHzR9fyfWe0eXO9bAkVg7f2iltPTrM2ydAWDNI3HQgRfHjz_nQKkr6hO9UxzFC3zmJwrBGjU73LrSeOeNeYr_zncYlqt-eV5pi0r_c5hDoXXBD5jHg', 1, '2026-01-24 02:50:48', '2026-01-24 02:50:49', NULL, NULL),
(16, 'naseem', NULL, 'www.palestine.ity@gmail.com', '0599940666', '$2y$10$yjF4GcWg0K3cb42lPI..uevcLHXj4XCJrfvPyiT/6ivnTJpCA.8Om', 'renter', NULL, 0, 0, 0, NULL, 1, 0, 0, 1, 'ar', NULL, 1, '2026-02-14 01:42:32', '2026-02-14 01:42:32', 2, 12),
(17, 'tamer', NULL, 'telhiomi@gmail.com', '0546477951', '$2y$10$WSqAks7h3zq0yN034VPK7uVbMHDv6JgFhBmVU9ZJbYsuZLI22eSGm', 'renter', NULL, 0, 0, 1, '2026-03-16', 1, 0, 0, 1, 'ar', NULL, 1, '2026-02-16 12:01:35', '2026-02-16 12:24:54', 2, 11),
(18, 'naworas', NULL, 'kelane@nawrassoft.com', '0566123424', '$2y$10$NeW53PB4Ptv880zuNBB79.EhHJdDB8M1anlc8ZZb1hIT8rOA64qj2', 'renter', NULL, 0, 0, 0, NULL, 1, 0, 0, 1, 'ar', NULL, 1, '2026-02-16 12:04:57', '2026-02-16 12:04:57', 2, 13),
(19, 'نسيم', NULL, 'www.palestine.it7@gmail.com', '0599940777', '$2y$10$H3GYbCArUnegZd8LjR2Ty.ap18BGbGj05wkZUhFjpCVvF4KW9ttne', 'renter', NULL, 0, 0, 0, NULL, 1, 0, 0, 1, 'ar', NULL, 1, '2026-02-16 12:29:48', '2026-02-16 12:29:48', 2, 12),
(20, 'نسيم', NULL, 'www.palestine.it8@gmail.com', '0599940888', '$2y$10$.sX10dAgJYnudejd1b2gs./CIrfAwADaitlZL2rJFdzXJY5BlEx92', 'renter', NULL, 0, 0, 0, NULL, 1, 0, 0, 1, 'ar', NULL, 1, '2026-02-16 12:36:03', '2026-02-16 12:36:03', 2, 12),
(21, 'نسيم', NULL, 'www.palestine.it9@gmail.com', '0599940999', '$2y$10$rmWRBkwwH/A/dUhbDTcvmOYECcJ3dHErYF0vKkUyOEjDFfpAZOXIO', 'renter', NULL, 0, 0, 0, NULL, 1, 1, 0, 1, 'ar', 'f_6eyH-aQXW477MfV6-8oT:APA91bEhbfbp2QGTlIUVNqWvStjpGftYdph7IJddxbARypeNqKZzc5gc0pPi1xQi_64CjwF4GbOvl_WooKZj8WFlKW--BMGn4Y8ODxBNG16Rm7V2lAxhZaE', 1, '2026-02-16 12:39:16', '2026-02-16 12:39:17', 2, 12),
(22, 'mohammad', NULL, 'abdul@gmail.com', '0548794648', '$2y$10$LFJLp4xiwqgWkHy871mFp.H1Fo/Ie3omZb.jsWsJo9KW2IJPWRRDO', 'office', NULL, 0, 0, 0, NULL, 1, 1, 0, 1, 'ar', 'dh1pOINjRL6KfkjoL-PbmJ:APA91bGikYswxYar-UH3K7UGC165clBlwUDibACE5CaAsZHihhroQdb-qD8KbwLivtR77td5Rj23zPnKDr36nGJ5_LqT7pdDdH9V8xO80bqZsH7oTBo1TiQ', 1, '2026-02-16 13:38:04', '2026-02-16 13:38:04', 2, 11),
(23, 'محمد', NULL, 'moh@gmail.com', '05548756889', '$2y$10$nm1I0qprMu9IeCIw3ZVWvur.qrx8U.43pZlwj.mpTP/SPW/aiAMDi', 'office', NULL, 0, 0, 0, NULL, 1, 1, 0, 1, 'ar', 'dh1pOINjRL6KfkjoL-PbmJ:APA91bGDvPNMsDO6MGrN8fl8ZBAEfMe2CnFjBpdNd9LFKJ14GO0_muaTAubAVnUlB3vJEjFY_6YfkpHooG477UcybyNbPRKBT8NDkRzV2qPJZyLwGJKBUSk', 1, '2026-02-16 13:53:03', '2026-02-16 13:53:03', 1, 1),
(24, 'tamer', NULL, 'telhidomii@gamil.com', '054647778', '$2y$10$/kyP7.oQjbO770v0VSBF5OJM5Pjqjv5Gp6gk.pyr30u5C2u7Lr25W', 'renter', NULL, 0, 0, 0, NULL, 1, 1, 0, 1, 'ar', 'dk3lAwScRAqxcJ3DIMQdqx:APA91bH7ZxwO7kFFfT2E4NUjw3-Ss2KtM7cZLl6Tp927gvF47z9Ue3HfEsqvY7W5sOyNaVnkE2akf4uG9x3L-aQi5ZWA01BuXhKcFdOvWeX4GyNU1BTMqrE', 1, '2026-02-17 12:57:38', '2026-02-17 12:57:38', 2, 12),
(25, 'moh', NULL, '07@gmail.com', '054687989', '$2y$10$FDyN/rz1gZTvpJh4//rWruULAPOX/8I7PGBRP9Bp1LGmYfezgX2Fm', 'renter', NULL, 0, 0, 0, NULL, 1, 1, 0, 1, 'ar', 'd6w_nKc7SYiHd3kBo1HQvn:APA91bEQD3hQyV-RBOscwadfYH5aL-UWIhmLPysbI1Wez6UpvYRZmK9vdlpkj4Ib1XI_a5qPJPsaCytlbr_-EgcXe-mdEkBNbgXTr1jJuOuqKS1eb-3VXow', 1, '2026-02-17 13:50:11', '2026-02-17 13:50:11', 2, 11),
(26, 'khader', NULL, 'khaderabughannam99@gmail.com', '0547091183', '$2y$10$SDiDeV.9LyZvBBuZrhJZse6S6Y//NjyAptdn.e7/PT..r6apbqjXK', 'renter', NULL, 0, 0, 0, NULL, 1, 1, 0, 1, 'ar', 'dKmbVMddTa-u0NVL0AeucH:APA91bGkiZtfPHoq-kUJCSqM7BMBbwSevoIO4L2Bl5dLRvwELLZz6BVqtSLx4NIceHTDMxWO9Ee94GYHxECK-LIsQ1tf40h5tmpE8mDU6uQiuJnIZ3twABI', 1, '2026-02-17 22:20:39', '2026-02-17 22:20:39', 2, 11);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin_banners`
--
ALTER TABLE `admin_banners`
  ADD PRIMARY KEY (`id`),
  ADD KEY `region_id` (`region_id`),
  ADD KEY `city_id` (`city_id`),
  ADD KEY `created_by` (`created_by`),
  ADD KEY `idx_active` (`is_active`),
  ADD KEY `idx_type` (`banner_type`),
  ADD KEY `idx_order` (`display_order`);

--
-- Indexes for table `admin_banner_media`
--
ALTER TABLE `admin_banner_media`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_banner` (`banner_id`);

--
-- Indexes for table `admin_users`
--
ALTER TABLE `admin_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `app_settings`
--
ALTER TABLE `app_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `setting_key` (`setting_key`),
  ADD KEY `idx_key` (`setting_key`),
  ADD KEY `idx_setting_group` (`setting_group`);

--
-- Indexes for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_admin` (`admin_id`),
  ADD KEY `idx_action` (`action`),
  ADD KEY `idx_entity` (`entity_type`,`entity_id`);

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
  ADD KEY `car_type_id` (`car_type_id`);

--
-- Indexes for table `car_media`
--
ALTER TABLE `car_media`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_car` (`car_id`);

--
-- Indexes for table `car_types`
--
ALTER TABLE `car_types`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD KEY `idx_active` (`is_active`),
  ADD KEY `idx_sort` (`sort_order`);

--
-- Indexes for table `cities`
--
ALTER TABLE `cities`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_city_region` (`region_id`,`slug`),
  ADD KEY `idx_region` (`region_id`);

--
-- Indexes for table `cms_pages`
--
ALTER TABLE `cms_pages`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Indexes for table `conversations`
--
ALTER TABLE `conversations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user2_id` (`user2_id`),
  ADD KEY `idx_users` (`user1_id`,`user2_id`),
  ADD KEY `idx_conv_user1` (`user1_id`),
  ADD KEY `idx_conv_user2` (`user2_id`),
  ADD KEY `idx_conv_listing` (`listing_type`,`listing_id`),
  ADD KEY `idx_conv_last_message` (`last_message_at` DESC);

--
-- Indexes for table `favorites`
--
ALTER TABLE `favorites`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_favorite` (`user_id`,`listing_type`,`listing_id`),
  ADD KEY `idx_user` (`user_id`);

--
-- Indexes for table `messages`
--
ALTER TABLE `messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sender_id` (`sender_id`),
  ADD KEY `idx_conversation` (`conversation_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_read` (`is_read`);

--
-- Indexes for table `otp_codes`
--
ALTER TABLE `otp_codes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `plan_id` (`plan_id`),
  ADD KEY `subscription_id` (`subscription_id`),
  ADD KEY `verified_by` (`verified_by`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_status` (`status`);

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
-- Indexes for table `properties`
--
ALTER TABLE `properties`
  ADD PRIMARY KEY (`id`),
  ADD KEY `city_id` (`city_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_property_type` (`property_type`),
  ADD KEY `idx_region_city` (`region_id`,`city_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_expires` (`expires_at`),
  ADD KEY `property_type_id` (`property_type_id`);

--
-- Indexes for table `property_media`
--
ALTER TABLE `property_media`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_property` (`property_id`);

--
-- Indexes for table `property_types`
--
ALTER TABLE `property_types`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD KEY `idx_active` (`is_active`),
  ADD KEY `idx_sort` (`sort_order`);

--
-- Indexes for table `realtime_messages`
--
ALTER TABLE `realtime_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_pending` (`user_id`,`is_delivered`),
  ADD KEY `idx_created` (`created_at`);

--
-- Indexes for table `regions`
--
ALTER TABLE `regions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Indexes for table `reports`
--
ALTER TABLE `reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `reporter_id` (`reporter_id`),
  ADD KEY `reported_user_id` (`reported_user_id`),
  ADD KEY `reviewed_by` (`reviewed_by`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `subscriptions`
--
ALTER TABLE `subscriptions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `plan_id` (`plan_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_expires` (`expires_at`);

--
-- Indexes for table `subscription_requests`
--
ALTER TABLE `subscription_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `reviewed_by` (`reviewed_by`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_plan` (`plan_id`);

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
-- AUTO_INCREMENT for table `admin_banners`
--
ALTER TABLE `admin_banners`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `admin_banner_media`
--
ALTER TABLE `admin_banner_media`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `admin_users`
--
ALTER TABLE `admin_users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `app_settings`
--
ALTER TABLE `app_settings`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `cars`
--
ALTER TABLE `cars`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `car_media`
--
ALTER TABLE `car_media`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `car_types`
--
ALTER TABLE `car_types`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `cities`
--
ALTER TABLE `cities`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `cms_pages`
--
ALTER TABLE `cms_pages`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `conversations`
--
ALTER TABLE `conversations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `favorites`
--
ALTER TABLE `favorites`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=201;

--
-- AUTO_INCREMENT for table `otp_codes`
--
ALTER TABLE `otp_codes`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `plans`
--
ALTER TABLE `plans`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `properties`
--
ALTER TABLE `properties`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `property_media`
--
ALTER TABLE `property_media`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `property_types`
--
ALTER TABLE `property_types`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `realtime_messages`
--
ALTER TABLE `realtime_messages`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `regions`
--
ALTER TABLE `regions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `reports`
--
ALTER TABLE `reports`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `subscriptions`
--
ALTER TABLE `subscriptions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT for table `subscription_requests`
--
ALTER TABLE `subscription_requests`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `admin_banners`
--
ALTER TABLE `admin_banners`
  ADD CONSTRAINT `admin_banners_ibfk_1` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `admin_banners_ibfk_2` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `admin_banners_ibfk_3` FOREIGN KEY (`created_by`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `admin_banner_media`
--
ALTER TABLE `admin_banner_media`
  ADD CONSTRAINT `admin_banner_media_ibfk_1` FOREIGN KEY (`banner_id`) REFERENCES `admin_banners` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD CONSTRAINT `audit_logs_ibfk_1` FOREIGN KEY (`admin_id`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `cars`
--
ALTER TABLE `cars`
  ADD CONSTRAINT `cars_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `cars_ibfk_2` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`),
  ADD CONSTRAINT `cars_ibfk_3` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`),
  ADD CONSTRAINT `cars_ibfk_4` FOREIGN KEY (`car_type_id`) REFERENCES `car_types` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `car_media`
--
ALTER TABLE `car_media`
  ADD CONSTRAINT `car_media_ibfk_1` FOREIGN KEY (`car_id`) REFERENCES `cars` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `cities`
--
ALTER TABLE `cities`
  ADD CONSTRAINT `cities_ibfk_1` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `conversations`
--
ALTER TABLE `conversations`
  ADD CONSTRAINT `conversations_ibfk_1` FOREIGN KEY (`user1_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `conversations_ibfk_2` FOREIGN KEY (`user2_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `favorites`
--
ALTER TABLE `favorites`
  ADD CONSTRAINT `favorites_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `messages`
--
ALTER TABLE `messages`
  ADD CONSTRAINT `messages_ibfk_1` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `messages_ibfk_2` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `otp_codes`
--
ALTER TABLE `otp_codes`
  ADD CONSTRAINT `otp_codes_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `payments`
--
ALTER TABLE `payments`
  ADD CONSTRAINT `payments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `payments_ibfk_2` FOREIGN KEY (`plan_id`) REFERENCES `plans` (`id`),
  ADD CONSTRAINT `payments_ibfk_3` FOREIGN KEY (`subscription_id`) REFERENCES `subscriptions` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `payments_ibfk_4` FOREIGN KEY (`verified_by`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `plans`
--
ALTER TABLE `plans`
  ADD CONSTRAINT `fk_plans_car_type` FOREIGN KEY (`car_type_id`) REFERENCES `car_types` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_plans_property_type` FOREIGN KEY (`property_type_id`) REFERENCES `property_types` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `properties`
--
ALTER TABLE `properties`
  ADD CONSTRAINT `properties_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `properties_ibfk_2` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`),
  ADD CONSTRAINT `properties_ibfk_3` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`),
  ADD CONSTRAINT `properties_ibfk_4` FOREIGN KEY (`property_type_id`) REFERENCES `property_types` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `property_media`
--
ALTER TABLE `property_media`
  ADD CONSTRAINT `property_media_ibfk_1` FOREIGN KEY (`property_id`) REFERENCES `properties` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `realtime_messages`
--
ALTER TABLE `realtime_messages`
  ADD CONSTRAINT `realtime_messages_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `reports`
--
ALTER TABLE `reports`
  ADD CONSTRAINT `reports_ibfk_1` FOREIGN KEY (`reporter_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reports_ibfk_2` FOREIGN KEY (`reported_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reports_ibfk_3` FOREIGN KEY (`reviewed_by`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `subscriptions`
--
ALTER TABLE `subscriptions`
  ADD CONSTRAINT `subscriptions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `subscriptions_ibfk_2` FOREIGN KEY (`plan_id`) REFERENCES `plans` (`id`);

--
-- Constraints for table `subscription_requests`
--
ALTER TABLE `subscription_requests`
  ADD CONSTRAINT `subscription_requests_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `subscription_requests_ibfk_2` FOREIGN KEY (`plan_id`) REFERENCES `plans` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `subscription_requests_ibfk_3` FOREIGN KEY (`reviewed_by`) REFERENCES `admin_users` (`id`) ON DELETE SET NULL;

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
