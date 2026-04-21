-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Mar 31, 2026 at 12:45 PM
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
  `title_ar` varchar(255) DEFAULT NULL,
  `title_en` varchar(255) DEFAULT NULL,
  `title_he` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `description_ar` text DEFAULT NULL,
  `description_en` text DEFAULT NULL,
  `description_he` text DEFAULT NULL,
  `banner_type` enum('property','car','general') DEFAULT 'property',
  `thumbnail` varchar(500) DEFAULT NULL,
  `region_id` int(10) UNSIGNED DEFAULT NULL,
  `city_id` int(10) UNSIGNED DEFAULT NULL,
  `address_text` varchar(500) DEFAULT NULL,
  `price` decimal(12,2) DEFAULT NULL,
  `price_text` varchar(100) DEFAULT NULL,
  `currency` varchar(10) DEFAULT 'ILS',
  `property_type` varchar(50) DEFAULT NULL,
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

INSERT INTO `admin_banners` (`id`, `title`, `title_ar`, `title_en`, `title_he`, `description`, `description_ar`, `description_en`, `description_he`, `banner_type`, `thumbnail`, `region_id`, `city_id`, `address_text`, `price`, `price_text`, `currency`, `property_type`, `bedrooms`, `bathrooms`, `area_m2`, `floor`, `car_model`, `car_year`, `gearbox`, `contact_phone`, `whatsapp`, `display_order`, `is_active`, `starts_at`, `ends_at`, `views_count`, `created_by`, `created_at`, `updated_at`) VALUES
(6, 'kiuygf', '', '', '', '', '', '', '', 'general', 'images/banners/69c011b3e5f0b_1774195123.jpg', 2, NULL, '', NULL, '', 'ILS', NULL, NULL, NULL, NULL, NULL, '', NULL, NULL, '', '', 0, 1, '2026-03-22 16:58:00', '2027-02-22 16:58:00', 15, 1, '2026-03-22 15:58:43', '2026-03-30 07:20:47'),
(7, 'Jerusalem ', '', '', '', '', '', '', '', 'general', 'images/banners/69c0120a1da82_1774195210.png', NULL, NULL, '', NULL, '', 'ILS', NULL, NULL, NULL, NULL, NULL, '', NULL, NULL, '', '', 0, 1, NULL, NULL, 17, 1, '2026-03-22 16:00:10', '2026-03-30 07:20:40'),
(8, 'Jerusalem ', '', '', '', '', '', '', '', 'general', 'images/banners/69c01221ae74f_1774195233.png', NULL, NULL, '', NULL, '', 'ILS', NULL, NULL, NULL, NULL, NULL, '', NULL, NULL, '', '', 0, 1, NULL, NULL, 15, 1, '2026-03-22 16:00:33', '2026-03-30 07:20:42'),
(9, 'Jerusalem ', '', '', '', '', '', '', '', 'general', 'images/banners/69c0122a9fea1_1774195242.png', NULL, NULL, '', NULL, '', 'ILS', NULL, NULL, NULL, NULL, NULL, '', NULL, NULL, '', '', 0, 1, NULL, NULL, 16, 1, '2026-03-22 16:00:42', '2026-03-30 22:33:06');

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
(5, 6, 'image', 'images/banners/69c011b3e5f0b_1774195123.jpg', 0, '2026-03-22 15:58:43'),
(6, 7, 'image', 'images/banners/69c0120a1da82_1774195210.png', 0, '2026-03-22 16:00:10'),
(7, 8, 'image', 'images/banners/69c01221ae74f_1774195233.png', 0, '2026-03-22 16:00:33'),
(8, 9, 'image', 'images/banners/69c0122a9fea1_1774195242.png', 0, '2026-03-22 16:00:42');

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
(1, 'Super Admin', 'admin@rentogo.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'super_admin', 1, '2026-03-29 11:03:44', '2026-01-21 23:56:25', '2026-03-29 13:03:44'),
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
(22, 'payment_failed_webhook', 'notifications', 'text', 0, 'Webhook URL for failed payments', '', NULL, NULL, '2026-02-16 11:55:42', NULL),
(23, 'chat_instructions', 'general', 'text', 0, NULL, 'تعليمات المحادثة:\n• لا تشارك معلوماتك الشخصية مثل رقم الهوية أو بطاقة الائتمان\n• تأكد من معاينة العقار/السيارة قبل إتمام أي صفقة\n• استخدم طرق الدفع الآمنة فقط\n• أبلغ عن أي سلوك مشبوه', 'Chat Guidelines:\n• Do not share personal information like ID or credit card numbers\n• Make sure to inspect the property/car before completing any deal\n• Use secure payment methods only\n• Report any suspicious behavior', 'הנחיות צאט:\n• אל תשתפו מידע אישי כמו תעודת זהות או כרטיס אשראי\n• ודאו שאתם בודקים את הנכס/רכב לפני סגירת עסקה\n• השתמשו רק באמצעי תשלום מאובטחים\n• דווחו על כל התנהגות חשודה', '2026-02-23 02:33:07', 1);

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
(1, 1, 'approve_listing', 'properties', 1, NULL, NULL, '213.6.17.6', NULL, '2026-03-11 20:22:55'),
(2, 1, 'reject_listing', 'properties', 2, NULL, '{\"reason\":\"\\u0639\\u062f\\u0644 \\u0635\\u0648\\u0631\"}', '147.235.203.146', NULL, '2026-03-11 21:59:58'),
(3, 1, 'reject_listing', 'properties', 2, NULL, '{\"reason\":\"\\u0639\\u062f\\u0644 \\u0635\\u0648\\u0631\"}', '147.235.203.146', NULL, '2026-03-11 22:00:23'),
(4, 1, 'approve_listing', 'properties', 2, NULL, NULL, '147.235.203.146', NULL, '2026-03-11 22:01:48'),
(5, 1, 'approve_listing', 'properties', 3, NULL, NULL, '213.6.17.6', NULL, '2026-03-12 00:13:18'),
(6, 1, 'approve_listing', 'cars', 1, NULL, NULL, '185.46.77.153', NULL, '2026-03-12 23:04:33'),
(7, 1, 'approve_listing', 'properties', 4, NULL, NULL, '185.46.77.15', NULL, '2026-03-13 19:52:40'),
(8, 1, 'pause_listing', 'properties', 4, NULL, NULL, '185.46.77.15', NULL, '2026-03-13 19:53:16'),
(9, 1, 'reject_listing', 'cars', 2, NULL, '{\"reason\":\"pictures?\"}', '147.235.203.146', NULL, '2026-03-15 20:51:56'),
(10, 1, 'reject_listing', 'cars', 2, NULL, '{\"reason\":\"pictures?\"}', '147.235.203.146', NULL, '2026-03-15 20:52:36'),
(11, 1, 'approve_listing', 'cars', 2, NULL, NULL, '147.235.203.146', NULL, '2026-03-15 20:53:08');

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
(1, 1, 'image', 'images/cars/69b3461809930_1773356568.jpg', '69b3461809930_1773356568.jpg', 0, '2026-03-12 23:02:48'),
(2, 2, 'image', 'images/cars/69b71c0ab8586_1773607946.jpg', '69b71c0ab8586_1773607946.jpg', 0, '2026-03-15 20:52:26'),
(3, 2, 'image', 'images/cars/69b71c0b5c131_1773607947.jpg', '69b71c0b5c131_1773607947.jpg', 1, '2026-03-15 20:52:27');

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
(2, 'سيارات مناسبات فخمة', 'Event luxury Cars', 'מכוניות יוקרה לאירועים', 'wedding', 'car_rental', 1, 2, '2026-02-22 23:46:20', '2026-03-09 21:46:46'),
(5, 'خدمات نقل', 'Transportation', 'הובלות', 'transportation', 'local_shipping', 1, 4, '2026-02-22 23:46:20', '2026-03-15 23:27:44'),
(6, 'ايجار بالساعة', 'Hourly rental', 'השכרה לשעה', 'hourly_rental', 'directions_car', 1, 3, '2026-02-23 00:09:49', '2026-03-15 23:27:30');

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
(12, 2, 'العيزرية', 'Al-Eizariya', 'אל-עיזריה', 'al-eizariya', 1, 5, '2026-01-21 23:56:25'),
(14, 3, 'حيفا', 'Haifa', 'חיפה', 'haifa', 1, 1, '2026-01-21 23:56:25'),
(16, 3, 'الناصرة', 'Nazareth', 'נצרת', 'nazareth', 1, 3, '2026-01-21 23:56:25'),
(17, 3, 'عكا', 'Acre', 'עכו', 'acre', 1, 4, '2026-01-21 23:56:25'),
(20, 4, 'بئر السبع', 'Beersheba', 'באר שבע', 'beersheba', 1, 1, '2026-01-21 23:56:25'),
(21, 4, 'رهط', 'Rahat', 'רהט', 'Rahat', 1, 5, '2026-01-21 23:56:25'),
(22, 3, 'طبريا', 'Tiberias', 'טבריה', 'Tiberias', 1, 4, '2026-03-12 20:37:58'),
(23, 3, 'العفولة', ' Afula', 'עפולה', ' Afula', 1, 5, '2026-03-12 20:42:13'),
(24, 3, 'كرميئيل', ' Karmiel', 'כרמיאל', ' Karmiel', 1, 6, '2026-03-12 20:43:28'),
(25, 3, 'أم الفحم', 'Umm al-Fahm', 'אום אל-פחם', 'Umm al-Fahm', 1, 7, '2026-03-12 20:44:11'),
(26, 3, 'سخنين ', 'Sakhnin ', 'סכנין', 'Sakhnin ', 1, 8, '2026-03-12 20:45:06'),
(27, 3, 'شفا عمرو', 'Shfaram', 'שפרעם', 'Shfaram', 1, 9, '2026-03-12 20:45:51'),
(28, 6, 'تل أبيب ', 'Tel Aviv ', ' תל אביב', 'Tel Aviv ', 1, 1, '2026-03-12 20:52:37'),
(29, 6, 'ريشون لتسيون', 'Rishon LeZion', 'ראשון לציון', 'Rishon LeZion', 1, 2, '2026-03-12 20:53:22'),
(30, 6, 'بيتح تكفا ', 'Petah Tikva ', 'פתח תקווה', 'Petah Tikva ', 1, 3, '2026-03-12 20:54:07'),
(31, 6, 'حولون ', 'Holon', 'חולון', 'Holon', 1, 4, '2026-03-12 20:54:56'),
(32, 6, 'بات يام ', ' Bat Yam ', 'בת ים', ' Bat Yam ', 1, 5, '2026-03-12 20:55:34'),
(33, 6, 'نتانيا ', 'Netanya ', ' נתניה', 'Netanya ', 1, 6, '2026-03-12 20:56:14'),
(34, 6, 'هرتسليا ', 'Herzliya', 'הרצליה', 'Herzliya', 1, 7, '2026-03-12 20:56:54'),
(35, 6, 'رعنانا', ' Ra’anana', ' רעננה', ' Ra’anana', 1, 8, '2026-03-12 20:57:32'),
(36, 6, 'كفار سابا ', 'Kfar Saba ', 'כפר סבא', 'Kfar Saba ', 1, 9, '2026-03-12 20:58:09'),
(37, 6, 'اللد ', ' Lod ', 'לוד', ' Lod ', 1, 10, '2026-03-12 20:58:50'),
(38, 6, 'الرملة ', 'Ramla', ' רמלה', 'Ramla', 1, 11, '2026-03-12 20:59:34'),
(39, 4, 'إيلات ', 'Eilat ', 'אילת', 'Eilat ', 1, 2, '2026-03-12 21:02:48'),
(40, 4, 'عسقلان', 'Ashkelon ', ' אשקלון', 'Ashkelon ', 1, 3, '2026-03-12 21:03:29'),
(41, 4, 'أشدود', ' Ashdod', ' אשדוד', ' Ashdod', 1, 4, '2026-03-12 21:04:18'),
(42, 4, 'ديمونا ', ' Dimona ', ' דימונה', ' Dimona ', 1, 6, '2026-03-12 21:05:37'),
(43, 4, 'سديروت', ' Sderot ', 'שדרות', ' Sderot ', 1, 7, '2026-03-12 21:06:20'),
(44, 2, 'بسغات زئيف', ' Pisgat Ze’ev ', 'פסגת זאב', ' Pisgat Ze’ev ', 1, 1, '2026-03-12 21:23:06'),
(45, 2, 'شعفاط ', ' Shuafat ', 'שועפאט', ' Shuafat ', 1, 2, '2026-03-12 21:50:42'),
(46, 2, 'مخيم شعفاط ', 'Shuafat Camp', 'מחנה פליטים שועפאט', 'Shuafat Camp', 1, 3, '2026-03-12 21:55:28'),
(47, 2, 'بيت حنينا ', 'Beit Hanina', 'בית חנינא', 'Beit Hanina', 1, 6, '2026-03-12 22:01:26'),
(48, 2, 'التلة الفرنسية', ' French Hill ', ' הגבעה הצרפתית', ' French Hill ', 1, 6, '2026-03-12 22:02:17'),
(49, 2, 'العيسوية', ' Issawiya ', ' עיסאוויה', ' Issawiya ', 1, 8, '2026-03-12 22:03:10'),
(50, 2, 'عناتا ', 'Anata ', ' ענתא', 'Anata ', 1, 9, '2026-03-12 22:05:05'),
(51, 2, 'كفر عقب ', 'Kafr Aqab ', 'כפר עקב', 'Kafr Aqab ', 1, 10, '2026-03-12 22:06:34'),
(52, 2, 'الرام ', 'Al-Ram', 'א-ראם', 'Al-Ram', 1, 11, '2026-03-12 22:07:14'),
(53, 2, 'الشيخ جراح ', 'Sheikh Jarrah ', 'שייח’ ג’ראח', 'Sheikh Jarrah ', 1, 12, '2026-03-12 22:08:10'),
(54, 2, 'البلدة القديمة', 'Old City', 'העיר העתיקה', 'Old City', 1, 13, '2026-03-12 22:08:51'),
(55, 2, 'سلوان', ' Silwan ', 'סילוואן', ' Silwan ', 1, 13, '2026-03-12 22:09:27'),
(56, 2, 'الطور ', ' At-Tur', 'א-טור', ' At-Tur', 1, 15, '2026-03-12 22:10:48'),
(57, 2, 'أبو طور ', ' Abu Tor', 'אבו תור', ' Abu Tor', 1, 16, '2026-03-12 22:11:24'),
(58, 2, 'كاتامون ', 'Katamon', 'קטמון', 'Katamon', 1, 17, '2026-03-12 22:12:05'),
(59, 2, 'بيت هكيرم ', 'Beit Hakerem', ' בית הכרם', 'Beit Hakerem', 1, 18, '2026-03-12 22:12:43'),
(60, 2, 'هار نوف', ' Har Nof', 'הר נוף', ' Har Nof', 1, 19, '2026-03-12 22:13:26'),
(61, 2, 'جبل المكبر', 'Jabal Mukaber', 'ג’בל מוכאבר', 'Jabal Mukaber', 1, 20, '2026-03-12 22:14:05'),
(62, 2, 'صور باهر ', 'Sur Baher ', 'צור באהר', 'Sur Baher ', 1, 21, '2026-03-12 22:14:38'),
(63, 2, 'بيت صفافا ', 'Beit Safafa', 'בית צפאפא', 'Beit Safafa', 1, 22, '2026-03-12 22:15:17'),
(64, 2, 'جيلو', 'Gilo', ' גילה', 'Gilo', 1, 23, '2026-03-12 22:16:03'),
(65, 2, 'مالحا ', 'Malha', 'מלחה', 'Malha', 1, 24, '2026-03-12 22:16:42'),
(66, 2, 'راموت ', 'Ramot ', 'רמות', 'Ramot ', 1, 25, '2026-03-12 22:17:20'),
(67, 2, 'أبو غوش ', ' Abu Ghosh ', 'אבו גוש', ' Abu Ghosh ', 1, 26, '2026-03-12 22:17:59'),
(68, 2, 'بيت شيمش', ' Beit Shemesh', ' בית שמש', ' Beit Shemesh', 1, 27, '2026-03-12 22:18:47'),
(69, 2, 'معاليه أدوميم', ' Ma’ale Adumim ', 'מעלה אדומים', 'Ma’ale Adumim ', 1, 28, '2026-03-12 22:39:15'),
(70, 2, 'العيزرية', ' Al-Eizariya ', 'אלעיזריה', ' Al-Eizariya ', 1, 29, '2026-03-12 22:39:52'),
(71, 2, 'أبو ديس', 'Abu Dis', 'אבו דיס', 'Abu Dis', 1, 30, '2026-03-12 22:40:31');

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
(1, 'privacy', 'سياسة الخصوصية', 'Privacy Policy', 'מדיניות פרטיות', 'سياسة الخصوصية – Rento Go\r\n\r\nنلتزم بحماية بيانات المستخدمين واستخدامها بشفافية.\r\n\r\n1. البيانات التي نجمعها\r\n\r\nقد نجمع:\r\n	•	الاسم ورقم الهاتف والبريد الإلكتروني\r\n	•	بيانات الإعلانات\r\n	•	معلومات تقنية (IP، نوع الجهاز، معرف الجهاز)\r\n	•	بيانات استخدام داخل التطبيق\r\n\r\n2. استخدام البيانات\r\n\r\nتُستخدم البيانات من أجل:\r\n	•	تشغيل وإدارة المنصة\r\n	•	مراجعة الإعلانات قبل النشر\r\n	•	إرسال الإشعارات\r\n	•	منع الاحتيال وإساءة الاستخدام\r\n	•	تحسين الأداء\r\n\r\n3. المدفوعات\r\n\r\nلا نقوم بتخزين بيانات البطاقات البنكية.\r\nتتم عمليات الدفع عبر مزودي خدمات معتمدين أو عبر متاجر التطبيقات.\r\n\r\n4. مشاركة المعلومات\r\n\r\nلا نقوم ببيع البيانات.\r\nقد يتم الإفصاح عنها إذا طُلب ذلك قانونياً أو لحماية حقوق المنصة.\r\n\r\n5. الاحتفاظ بالبيانات\r\n\r\nيتم الاحتفاظ بالبيانات طالما الحساب نشط أو حسب الضرورة القانونية.\r\n\r\n6. حقوق المستخدم\r\n\r\nيمكن للمستخدم تعديل بياناته أو حذف حسابه في أي وقت.\r\n', 'Privacy Policy – Rento Go\r\n\r\nWe are committed to protecting user data.\r\n\r\n1. Information Collected\r\n\r\nWe may collect:\r\n	•	Name, phone number, email\r\n	•	Listing details\r\n	•	Technical data (IP, device ID)\r\n	•	Usage data\r\n\r\n2. Use of Information\r\n\r\nData is used to:\r\n	•	Operate and manage the platform\r\n	•	Review listings before publication\r\n	•	Send notifications\r\n	•	Prevent fraud and misuse\r\n	•	Improve performance\r\n\r\n3. Payments\r\n\r\nCredit card details are not stored.\r\nPayments are processed through authorized providers or app stores.\r\n\r\n4. Data Sharing\r\n\r\nWe do not sell personal data.\r\nInformation may be disclosed if legally required.\r\n\r\n5. Data Retention\r\n\r\nData is retained while accounts remain active or as required.\r\n\r\n6. User Rights\r\n\r\nUsers may update or delete their accounts at any time.\r\n', 'מדיניות פרטיות – Rento Go\r\n\r\nאנו מחויבים להגנה על נתוני המשתמשים.\r\n\r\n1. מידע שנאסף\r\n\r\nייתכן שנאסוף:\r\n	•	שם, טלפון ודוא״ל\r\n	•	פרטי מודעות\r\n	•	מידע טכני (IP, מזהה מכשיר)\r\n	•	נתוני שימוש\r\n\r\n2. שימוש במידע\r\n\r\nהמידע משמש ל:\r\n	•	תפעול וניהול הפלטפורמה\r\n	•	בדיקת מודעות לפני פרסום\r\n	•	שליחת התראות\r\n	•	מניעת הונאה\r\n	•	שיפור השירות\r\n\r\n3. תשלומים\r\n\r\nאין שמירה של פרטי אשראי.\r\nהתשלומים מתבצעים דרך ספקים מורשים או חנויות האפליקציות.\r\n\r\n4. שיתוף מידע\r\n\r\nהמידע אינו נמכר.\r\nייתכן גילוי מידע אם נדרש לפי חוק.\r\n\r\n5. שמירת מידע\r\n\r\nהמידע נשמר כל עוד החשבון פעיל או כנדרש.\r\n\r\n6. זכויות משתמש\r\n\r\nניתן לעדכן או למחוק חשבון בכל עת.\r\n', 1, '2026-01-21 23:56:25', '2026-02-26 05:38:21'),
(2, 'terms', 'الشروط والأحكام', 'Terms & Conditions', 'תנאים והגבלות', 'الشروط والأحكام – Rento Go\r\n\r\n1. طبيعة الخدمة\r\n\r\nRento Go منصة إعلانية لنشر وعرض إعلانات العقارات والمركبات فقط.\r\n\r\n2. مراجعة الإعلانات\r\n	•	جميع الإعلانات تخضع للمراجعة قبل النشر.\r\n	•	دفع الرسوم لا يضمن الموافقة.\r\n	•	في حال الرفض، يتم توضيح السبب ومنح فرصة تعديل دون رسوم إضافية.\r\n	•	لا يتم استرداد الرسوم عند رفض الإعلان لمخالفته الشروط.\r\n\r\n3. الخدمات المدفوعة\r\n\r\nقد تشمل الخدمات المدفوعة إعلانات مميزة أو اشتراكات.\r\nالرسوم مقابل خدمة النشر والإبراز فقط.\r\nالمدفوعات غير قابلة للاسترداد بعد التفعيل.\r\nعمليات الاسترداد عبر متاجر التطبيقات تخضع لسياساتهم.\r\n\r\n4. مسؤولية المستخدم\r\n\r\nالمستخدم مسؤول عن صحة الإعلان وأي اتفاق يتم بسببه.\r\n\r\n5. إساءة الاستخدام\r\n\r\nيُحظر التحايل أو نشر محتوى مخالف.\r\nيحق للمنصة إيقاف الحساب عند المخالفة.\r\n\r\n6. تحديد المسؤولية\r\n\r\nلا تتحمل المنصة مسؤولية النزاعات أو الخسائر الناتجة عن استخدام الخدمة.\r\n\r\n7. التعديلات\r\n\r\nيجوز تعديل الشروط في أي وقت.\r\n', 'Terms & Conditions – Rento Go\r\n\r\n1. Service Nature\r\n\r\nRento Go is an advertising platform for property and vehicle listings only.\r\n\r\n2. Listing Review\r\n	•	All listings are reviewed before publication.\r\n	•	Payment does not guarantee approval.\r\n	•	Rejected listings may be edited and resubmitted without extra charge.\r\n	•	Fees are non-refundable if rejected due to policy violations.\r\n\r\n3. Paid Services\r\n\r\nPaid features may include featured ads or subscriptions.\r\nFees are for publishing and visibility only.\r\nPayments are non-refundable once activated.\r\nRefunds via app stores follow their policies.\r\n\r\n4. User Responsibility\r\n\r\nUsers are responsible for their listings and resulting agreements.\r\n\r\n5. Misuse\r\n\r\nCircumvention or unlawful content is prohibited.\r\nAccounts may be suspended if violated.\r\n\r\n6. Limitation of Liability\r\n\r\nThe platform is not responsible for disputes or losses between users.\r\n\r\n7. Updates\r\n\r\nTerms may be updated at any time.\r\n', 'תנאים והגבלות – Rento Go\r\n\r\n1. מהות השירות\r\n\r\nRento Go היא פלטפורמת פרסום לנכסים ורכבים בלבד.\r\n\r\n2. בדיקת מודעות\r\n	•	כל מודעה נבדקת לפני פרסום.\r\n	•	תשלום אינו מבטיח אישור.\r\n	•	מודעה שנדחתה ניתנת לעריכה והגשה מחדש ללא תשלום נוסף.\r\n	•	אין החזר כספי במקרה של הפרת תנאים.\r\n\r\n3. שירותים בתשלום\r\n\r\nייתכן שיוצעו מודעות מודגשות או מנויים.\r\nהתשלום עבור פרסום והבלטה בלבד.\r\nהתשלומים אינם ניתנים להחזר לאחר הפעלה.\r\nהחזרים דרך חנויות האפליקציות כפופים למדיניותן.\r\n\r\n4. אחריות המשתמש\r\n\r\nהמשתמש אחראי לתוכן המודעה ולכל הסכם שיתבצע בעקבותיה.\r\n\r\n5. שימוש לרעה\r\n\r\nאסור לעקוף מערכות או לפרסם תוכן בלתי חוקי.\r\nהחשבון עשוי להיחסם במקרה של הפרה.\r\n\r\n6. הגבלת אחריות\r\n\r\nהפלטפורמה אינה אחראית לסכסוכים או הפסדים בין משתמשים.\r\n\r\n7. עדכונים\r\n\r\nהתנאים עשויים להתעדכן מעת לעת.\r\n', 1, '2026-01-21 23:56:25', '2026-02-26 05:41:01'),
(3, 'disclaimer', 'إخلاء المسؤولية Rento-go', 'Disclaimer', 'כתב ויתור', 'إخلاء المسؤولية – Rento Go\r\n\r\nRento Go منصة إعلانية إلكترونية فقط تتيح للمستخدمين نشر وعرض إعلانات العقارات والمركبات.\r\n	•لا تتحقق المنصة من الملكية القانونية أو صحة المعلومات المنشورة.\r\n	•لا تتدخل في المفاوضات أو العقود أو المدفوعات بين المستخدمين.\r\n	•لا تقدم أي ضمانات بشأن جودة أو قانونية أو توفر العقارات أو المركبات المعروضة.\r\n	•أي تعامل يتم بين المستخدمين يتم على مسؤوليتهم الكاملة.\r\nتخلي المنصة مسؤوليتها عن أي خسائر أو أضرار مباشرة أو غير مباشرة ناتجة عن استخدام الخدمة', '< Disclaimer – Rento Go\r\n\r\nRento Go is an online advertising platform only.\r\n	•	The platform does not verify ownership or the accuracy of listings.\r\n	•	It does not participate in negotiations, contracts, or payments between users.\r\n	•	It provides no guarantees regarding the quality, legality, or availability of listed properties or vehicles.\r\n	•	Any transaction between users is solely their responsibility.\r\n\r\nThe platform disclaims liability for any direct or indirect losses arising from use of the service.', 'כתב ויתור – Rento Go\r\n\r\nRento Go היא פלטפורמת פרסום מקוונת בלבד.\r\n	•	הפלטפורמה אינה מאמתת בעלות או את נכונות המידע במודעות.\r\n	•	היא אינה צד למשא ומתן, חוזים או תשלומים בין משתמשים.\r\n	•	אין כל אחריות לאיכות, חוקיות או זמינות הנכסים או הרכבים.\r\n	•	כל עסקה בין משתמשים הינה באחריותם הבלעדית.\r\n\r\nהפלטפורמה מסירה אחריות לכל נזק ישיר או עקיף הנובע מהשימוש בשירות.\r\n', 1, '2026-01-21 23:56:25', '2026-02-26 05:35:41');

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
(1, 3, 2, 'property', 2, NULL, '2026-03-11 23:36:10'),
(2, 4, 2, 'property', 2, NULL, '2026-03-11 23:48:10'),
(3, 2, 1, 'property', 1, NULL, '2026-03-29 11:08:11');

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
(4, 2, 'property', 2, '2026-03-11 22:11:50'),
(5, 3, 'property', 2, '2026-03-11 23:35:32'),
(8, 5, 'property', 2, '2026-03-12 00:28:13'),
(9, 2, 'car', 1, '2026-03-12 23:05:52'),
(10, 2, 'car', 2, '2026-03-15 20:59:11');

-- --------------------------------------------------------

--
-- Table structure for table `invoices`
--

CREATE TABLE `invoices` (
  `id` int(10) UNSIGNED NOT NULL,
  `invoice_number` varchar(50) NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `payment_id` int(10) UNSIGNED DEFAULT NULL,
  `subscription_id` int(10) UNSIGNED DEFAULT NULL,
  `type` enum('purchase','refund','credit_note') DEFAULT 'purchase',
  `subtotal` decimal(10,2) NOT NULL,
  `tax_rate` decimal(5,2) DEFAULT 0.00,
  `tax_amount` decimal(10,2) DEFAULT 0.00,
  `discount_amount` decimal(10,2) DEFAULT 0.00,
  `total` decimal(10,2) NOT NULL,
  `currency` varchar(10) DEFAULT 'ILS',
  `status` enum('draft','issued','paid','cancelled','refunded') DEFAULT 'draft',
  `issued_at` timestamp NULL DEFAULT NULL,
  `paid_at` timestamp NULL DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `billing_name` varchar(100) DEFAULT NULL,
  `billing_email` varchar(100) DEFAULT NULL,
  `billing_phone` varchar(20) DEFAULT NULL,
  `billing_address` text DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `invoice_items`
--

CREATE TABLE `invoice_items` (
  `id` int(10) UNSIGNED NOT NULL,
  `invoice_id` int(10) UNSIGNED NOT NULL,
  `description` varchar(255) NOT NULL,
  `quantity` int(11) DEFAULT 1,
  `unit_price` decimal(10,2) NOT NULL,
  `total` decimal(10,2) NOT NULL,
  `plan_id` int(10) UNSIGNED DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
(1, 1, 'تم تفعيل اشتراكك', 'Subscription Activated', 'המנוי שלך הופעל', 'تم تفعيل اشتراكك بنجاح. يمكنك الآن إضافة إعلاناتك', 'Your subscription is now active. You can now add your listings', 'המנוי שלך פעיל כעת. כעת תוכל להוסיף מודעות', 'subscription_approved', '{\"plan_name\":\"\\u0627\\u0639\\u0644\\u0627\\u0646 \\u0634\\u0642\\u0629 \\u0648\\u0627\\u062d\\u062f\\u0629 7 \\u064a\\u0648\\u0645\"}', 0, 0, '2026-03-11 20:22:30'),
(2, 1, 'تم قبول إعلانك', 'Listing Approved', 'המודעה אושרה', 'إعلانك الآن متاح للجميع', 'Your listing is now live', 'המודעה שלך זמינה כעת', 'listing_approved', '{\"listing_id\":1,\"listing_type\":\"property\"}', 0, 0, '2026-03-11 20:22:54'),
(3, 1, 'تم تفعيل اشتراكك', 'Subscription Activated', 'המנוי שלך הופעל', 'تم تفعيل اشتراكك بنجاح. يمكنك الآن إضافة إعلاناتك', 'Your subscription is now active. You can now add your listings', 'המנוי שלך פעיל כעת. כעת תוכל להוסיף מודעות', 'subscription_approved', '{\"plan_name\":\"\\u0627\\u0639\\u0644\\u0627\\u0646 \\u0634\\u0642\\u0629 \\u0648\\u0627\\u062d\\u062f\\u0629 7 \\u064a\\u0648\\u0645\"}', 0, 0, '2026-03-11 20:55:29'),
(4, 2, 'تم رفض إعلانك', 'Listing Rejected', 'המודעה נדחתה', 'سبب الرفض: عدل صور', 'Rejection reason: عدل صور', 'סיבת הדחייה: عدل صور', 'listing_rejected', '{\"listing_id\":2,\"listing_type\":\"property\",\"reason\":\"\\u0639\\u062f\\u0644 \\u0635\\u0648\\u0631\"}', 1, 0, '2026-03-11 21:59:57'),
(5, 2, 'تم رفض إعلانك', 'Listing Rejected', 'המודעה נדחתה', 'سبب الرفض: عدل صور', 'Rejection reason: عدل صور', 'סיבת הדחייה: عدل صور', 'listing_rejected', '{\"listing_id\":2,\"listing_type\":\"property\",\"reason\":\"\\u0639\\u062f\\u0644 \\u0635\\u0648\\u0631\"}', 1, 0, '2026-03-11 22:00:23'),
(6, 2, 'تم قبول إعلانك', 'Listing Approved', 'המודעה אושרה', 'إعلانك الآن متاح للجميع', 'Your listing is now live', 'המודעה שלך זמינה כעת', 'listing_approved', '{\"listing_id\":2,\"listing_type\":\"property\"}', 1, 0, '2026-03-11 22:01:47'),
(7, 2, 'تم تفعيل اشتراكك', 'Subscription Activated', 'המנוי שלך הופעל', 'تم تفعيل اشتراكك بنجاح. يمكنك الآن إضافة إعلاناتك', 'Your subscription is now active. You can now add your listings', 'המנוי שלך פעיל כעת. כעת תוכל להוסיף מודעות', 'subscription_approved', '{\"plan_name\":\"\\u0628\\u0627\\u0642\\u0629 \\u0628\\u0631\\u0648\\u0646\\u0632\\u064a\\u0629\"}', 1, 0, '2026-03-11 22:08:56'),
(8, 1, 'تم قبول إعلانك', 'Listing Approved', 'המודעה אושרה', 'إعلانك الآن متاح للجميع', 'Your listing is now live', 'המודעה שלך זמינה כעת', 'listing_approved', '{\"listing_id\":3,\"listing_type\":\"property\"}', 0, 0, '2026-03-12 00:13:18'),
(9, 2, 'تم تفعيل اشتراكك', 'Subscription Activated', 'המנוי שלך הופעל', 'تم تفعيل اشتراكك بنجاح. يمكنك الآن إضافة إعلاناتك', 'Your subscription is now active. You can now add your listings', 'המנוי שלך פעיל כעת. כעת תוכל להוסיף מודעות', 'subscription_approved', '{\"plan_name\":\"\\u0628\\u0627\\u0642\\u0629 \\u0645\\u062c\\u0627\\u0646\\u064a\\u0629 \\u0645\\u0631\\u0629 \\u0648\\u0627\\u062d\\u062f\\u0629\"}', 1, 0, '2026-03-12 22:48:44'),
(10, 4, 'بتحركش', 'بتحركش', 'بتحركش', 'ولك كزووون', 'ولك كزووون', 'ولك كزووون', 'admin_message', '{\"sent_by\":1}', 0, 0, '2026-03-12 22:58:07'),
(11, 2, 'تم قبول إعلانك', 'Listing Approved', 'המודעה אושרה', 'إعلانك الآن متاح للجميع', 'Your listing is now live', 'המודעה שלך זמינה כעת', 'listing_approved', '{\"listing_id\":1,\"listing_type\":\"car\"}', 1, 0, '2026-03-12 23:04:33'),
(12, 2, 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'مرحبا', 'admin_message', '{\"sent_by\":1}', 1, 0, '2026-03-12 23:08:16'),
(13, 2, 'تم تفعيل اشتراكك', 'Subscription Activated', 'המנוי שלך הופעל', 'تم تفعيل اشتراكك بنجاح. يمكنك الآن إضافة إعلاناتك', 'Your subscription is now active. You can now add your listings', 'המנוי שלך פעיל כעת. כעת תוכל להוסיף מודעות', 'subscription_approved', '{\"plan_name\":\"\\u0627\\u0639\\u0644\\u0627\\u0646 \\u0634\\u0642\\u0629 \\u0648\\u0627\\u062d\\u062f\\u0629 7 \\u064a\\u0648\\u0645\"}', 1, 0, '2026-03-13 00:11:06'),
(14, 2, 'تم قبول إعلانك', 'Listing Approved', 'המודעה אושרה', 'إعلانك الآن متاح للجميع', 'Your listing is now live', 'המודעה שלך זמינה כעת', 'listing_approved', '{\"listing_id\":4,\"listing_type\":\"property\"}', 1, 0, '2026-03-13 19:52:40'),
(15, 2, 'تم تفعيل اشتراكك', 'Subscription Activated', 'המנוי שלך הופעל', 'تم تفعيل اشتراكك بنجاح. يمكنك الآن إضافة إعلاناتك', 'Your subscription is now active. You can now add your listings', 'המנוי שלך פעיל כעת. כעת תוכל להוסיף מודעות', 'subscription_approved', '{\"plan_name\":\"\\u0628\\u0627\\u0642\\u0629 \\u0627\\u0644\\u0633\\u064a\\u0627\\u0631\\u0627\\u062a \\u0627\\u0644\\u0630\\u0647\\u0628\\u064a\\u0629\"}', 1, 0, '2026-03-15 20:49:19'),
(16, 2, 'تم رفض إعلانك', 'Listing Rejected', 'המודעה נדחתה', 'سبب الرفض: pictures?', 'Rejection reason: pictures?', 'סיבת הדחייה: pictures?', 'listing_rejected', '{\"listing_id\":2,\"listing_type\":\"car\",\"reason\":\"pictures?\"}', 1, 0, '2026-03-15 20:51:55'),
(17, 2, 'تم رفض إعلانك', 'Listing Rejected', 'המודעה נדחתה', 'سبب الرفض: pictures?', 'Rejection reason: pictures?', 'סיבת הדחייה: pictures?', 'listing_rejected', '{\"listing_id\":2,\"listing_type\":\"car\",\"reason\":\"pictures?\"}', 1, 0, '2026-03-15 20:52:36'),
(18, 2, 'تم قبول إعلانك', 'Listing Approved', 'המודעה אושרה', 'إعلانك الآن متاح للجميع', 'Your listing is now live', 'המודעה שלך זמינה כעת', 'listing_approved', '{\"listing_id\":2,\"listing_type\":\"car\"}', 1, 0, '2026-03-15 20:53:07');

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
(1, 1, '0599940687', NULL, '133381', 'phone', '2026-03-11 00:38:11', 0, '2026-03-11 00:28:11'),
(2, 2, '0548724689', NULL, '945459', 'phone', '2026-03-11 21:37:08', 0, '2026-03-11 21:27:08'),
(3, 3, '0547840085', NULL, '428777', 'phone', '2026-03-11 23:44:47', 0, '2026-03-11 23:34:47'),
(4, 4, '0546477951', NULL, '151358', 'phone', '2026-03-11 23:57:22', 0, '2026-03-11 23:47:22'),
(5, 5, '+972592123424', NULL, '663134', 'phone', '2026-03-12 00:37:34', 0, '2026-03-12 00:27:34'),
(6, 6, '0528602593', NULL, '981124', 'phone', '2026-03-22 16:29:16', 0, '2026-03-22 16:19:16');

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

CREATE TABLE `payments` (
  `id` int(10) UNSIGNED NOT NULL,
  `invoice_number` varchar(50) DEFAULT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `plan_id` int(10) UNSIGNED NOT NULL,
  `subscription_id` int(10) UNSIGNED DEFAULT NULL,
  `amount` decimal(10,2) NOT NULL,
  `fee_amount` decimal(10,2) DEFAULT 0.00,
  `net_amount` decimal(10,2) DEFAULT 0.00,
  `currency` varchar(10) DEFAULT 'ILS',
  `platform` enum('ios','android','web') NOT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(500) DEFAULT NULL,
  `payment_method` varchar(50) DEFAULT 'test',
  `environment` enum('sandbox','production') DEFAULT 'production',
  `sender_name` varchar(100) DEFAULT NULL,
  `transfer_date` date DEFAULT NULL,
  `transaction_id` varchar(255) DEFAULT NULL,
  `store_transaction_id` varchar(255) DEFAULT NULL,
  `product_id` varchar(100) DEFAULT NULL,
  `receipt_data` text DEFAULT NULL,
  `receipt_url` varchar(500) DEFAULT NULL,
  `status` enum('pending','completed','failed','refunded','rejected') DEFAULT 'pending',
  `error_code` varchar(50) DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  `refund_reason` varchar(255) DEFAULT NULL,
  `refunded_at` timestamp NULL DEFAULT NULL,
  `refunded_amount` decimal(10,2) DEFAULT 0.00,
  `verified_at` timestamp NULL DEFAULT NULL,
  `verified_by` int(10) UNSIGNED DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `payments`
--

INSERT INTO `payments` (`id`, `invoice_number`, `user_id`, `plan_id`, `subscription_id`, `amount`, `fee_amount`, `net_amount`, `currency`, `platform`, `ip_address`, `user_agent`, `payment_method`, `environment`, `sender_name`, `transfer_date`, `transaction_id`, `store_transaction_id`, `product_id`, `receipt_data`, `receipt_url`, `status`, `error_code`, `error_message`, `refund_reason`, `refunded_at`, `refunded_amount`, `verified_at`, `verified_by`, `notes`, `created_at`, `updated_at`) VALUES
(1, NULL, 1, 3, 3, 79.00, 0.00, 0.00, 'ILS', 'android', NULL, NULL, 'test', 'production', NULL, NULL, 'TEST_69b1ced523156', NULL, NULL, NULL, NULL, 'completed', NULL, NULL, NULL, NULL, 0.00, NULL, NULL, NULL, '2026-03-11 20:21:41', '2026-03-11 20:22:30'),
(2, NULL, 1, 3, 4, 79.00, 0.00, 0.00, 'ILS', 'android', NULL, NULL, 'test', 'production', NULL, NULL, 'TEST_69b1d6afe094e', NULL, NULL, NULL, NULL, 'completed', NULL, NULL, NULL, NULL, 0.00, NULL, NULL, NULL, '2026-03-11 20:55:11', '2026-03-11 20:55:29'),
(3, NULL, 2, 5, 7, 249.00, 0.00, 0.00, 'ILS', 'android', NULL, NULL, 'test', 'production', NULL, NULL, 'TEST_69b1e7ea41a10', NULL, NULL, NULL, NULL, 'completed', NULL, NULL, NULL, NULL, 0.00, NULL, NULL, NULL, '2026-03-11 22:08:42', '2026-03-11 22:08:56'),
(4, NULL, 2, 6, 14, 0.00, 0.00, 0.00, 'ILS', 'android', NULL, NULL, 'test', 'production', NULL, NULL, 'TEST_69b342b9bfbaf', NULL, NULL, NULL, NULL, 'completed', NULL, NULL, NULL, NULL, 0.00, NULL, NULL, NULL, '2026-03-12 22:48:25', '2026-03-12 22:48:44'),
(5, NULL, 2, 3, 15, 79.00, 0.00, 0.00, 'ILS', 'android', NULL, NULL, 'test', 'production', NULL, NULL, 'TEST_69b355fd46188', NULL, NULL, NULL, NULL, 'completed', NULL, NULL, NULL, NULL, 0.00, NULL, NULL, NULL, '2026-03-13 00:10:37', '2026-03-13 00:11:06'),
(6, NULL, 2, 11, 16, 750.00, 0.00, 0.00, 'ILS', 'android', NULL, NULL, 'test', 'production', NULL, NULL, 'TEST_69b71b4267a4d', NULL, NULL, NULL, NULL, 'completed', NULL, NULL, NULL, NULL, 0.00, NULL, NULL, NULL, '2026-03-15 20:49:06', '2026-03-15 20:49:19');

-- --------------------------------------------------------

--
-- Table structure for table `payment_logs`
--

CREATE TABLE `payment_logs` (
  `id` int(10) UNSIGNED NOT NULL,
  `payment_id` int(10) UNSIGNED NOT NULL,
  `action` enum('created','processing','completed','failed','refunded','disputed','cancelled') NOT NULL,
  `status_from` varchar(50) DEFAULT NULL,
  `status_to` varchar(50) DEFAULT NULL,
  `amount` decimal(10,2) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `raw_response` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`raw_response`)),
  `ip_address` varchar(45) DEFAULT NULL,
  `performed_by` int(10) UNSIGNED DEFAULT NULL COMMENT 'admin_id if manual, NULL if automatic',
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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

-- --------------------------------------------------------

--
-- Table structure for table `properties`
--

CREATE TABLE `properties` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `title_ar` varchar(255) DEFAULT NULL,
  `title_en` varchar(255) DEFAULT NULL,
  `title_he` varchar(255) DEFAULT NULL,
  `property_type` varchar(50) NOT NULL,
  `property_type_id` int(10) UNSIGNED DEFAULT NULL,
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
  `bedrooms` int(11) DEFAULT NULL,
  `bathrooms` int(11) DEFAULT NULL,
  `floor` int(11) DEFAULT NULL,
  `area_m2` decimal(10,2) DEFAULT NULL,
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
-- Dumping data for table `properties`
--

INSERT INTO `properties` (`id`, `user_id`, `title`, `title_ar`, `title_en`, `title_he`, `property_type`, `property_type_id`, `region_id`, `city_id`, `address_text`, `price_type`, `price`, `price_from`, `price_to`, `price_daily`, `price_weekly`, `price_monthly`, `currency`, `bedrooms`, `bathrooms`, `floor`, `area_m2`, `bio`, `bio_ar`, `bio_en`, `bio_he`, `language`, `contact_phone`, `whatsapp`, `status`, `is_trusted`, `is_rented`, `reject_reason`, `views_count`, `subscription_id`, `expires_at`, `created_at`, `updated_at`) VALUES
(1, 1, 'شقة فاخرة', 'شقة فاخرة', 'Luxury Apartment', 'דירת יוקרה', 'studio', NULL, 2, 12, 'الداخل', 'fixed', 1500.00, NULL, NULL, NULL, NULL, 1500.00, 'ILS', NULL, NULL, NULL, NULL, 'شقة كبرة في', 'شقة كبرة في', 'Large apartment in...', 'דירה גדולה ב...', 'ar', '0599940687', '0599940687', 'active', 0, 1, NULL, 40, 3, NULL, '2026-03-11 20:22:42', '2026-03-31 10:43:40'),
(2, 2, 'الطور', 'الطور', 'Al-Tur', 'א-טור', 'apartment', NULL, 2, 11, '', 'fixed', 2500.00, NULL, NULL, NULL, NULL, 2500.00, 'ILS', 2, 2, 3, 150.00, 'حي سكني راقي ', 'حي سكني راقي ', 'A high-end residential neighborhood', 'שכונת מגורים יוקרתית', 'ar', '0548724689', '0548724689', 'active', 0, 0, NULL, 80, 6, NULL, '2026-03-11 21:34:09', '2026-03-31 10:43:40'),
(3, 1, 'شقة مميزه', 'شقة مميزه', 'Distinguished Apartment', 'דירה מיוחדת', 'studio', NULL, 2, 12, 'القدس', 'fixed', 1000.00, NULL, NULL, NULL, NULL, 1000.00, 'ILS', NULL, NULL, NULL, NULL, 'شقة ممتازة لأسرة صغيرة', 'شقة ممتازة لأسرة صغيرة', 'Excellent apartment for a small family', 'דירה מצוינת למשפחה קטנה', 'ar', '0599940687', '0599940687', 'active', 0, 1, NULL, 17, 4, '2026-03-19 00:12:46', '2026-03-12 00:12:46', '2026-03-31 10:43:40'),
(4, 2, NULL, '', 'Large Apartment Suitable for Newlyweds', 'דירה גדולה מתאימה לזוגות צעירים', 'apartment', NULL, 2, 47, NULL, 'fixed', 2500.00, NULL, NULL, NULL, NULL, 2500.00, 'ILS', 2, 2, 0, 150.00, 'شقة كبيرة تصلح لعرسان', 'شقة كبيرة تصلح لعرسان', 'Spacious apartment perfect for a young couple.', 'דירה מרווחת מושלמת לזוג צעיר.', 'ar', '0548724689', '0548724689', 'active', 0, 0, NULL, 6, 7, '2026-03-21 22:08:42', '2026-03-13 19:52:14', '2026-03-31 10:43:40');

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
(1, 1, 'image', 'images/properties/69b1cf133b5a7_1773260563.jpg', '69b1cf133b5a7_1773260563.jpg', 0, '2026-03-11 20:22:43'),
(2, 2, 'image', 'images/properties/69b1dfd1ddd91_1773264849.jpg', '69b1dfd1ddd91_1773264849.jpg', 0, '2026-03-11 21:34:09'),
(3, 2, 'image', 'images/properties/69b1dfd27ef20_1773264850.jpg', '69b1dfd27ef20_1773264850.jpg', 1, '2026-03-11 21:34:10'),
(4, 2, 'image', 'images/properties/69b1dfd2ecedf_1773264850.jpg', '69b1dfd2ecedf_1773264850.jpg', 2, '2026-03-11 21:34:10'),
(5, 3, 'image', 'images/properties/69b204ffbc924_1773274367.jpg', '69b204ffbc924_1773274367.jpg', 0, '2026-03-12 00:12:47'),
(6, 3, 'image', 'images/properties/69b2050147e2d_1773274369.jpg', '69b2050147e2d_1773274369.jpg', 1, '2026-03-12 00:12:49'),
(7, 4, 'image', 'images/properties/69b46aeec0b68_1773431534.jpg', '69b46aeec0b68_1773431534.jpg', 0, '2026-03-13 19:52:14'),
(8, 4, 'image', 'images/properties/69b46aef44fac_1773431535.jpg', '69b46aef44fac_1773431535.jpg', 1, '2026-03-13 19:52:15'),
(9, 4, 'image', 'images/properties/69b46aefd7b6d_1773431535.jpg', '69b46aefd7b6d_1773431535.jpg', 2, '2026-03-13 19:52:15'),
(10, 4, 'image', 'images/properties/69b46af050fbe_1773431536.jpg', '69b46af050fbe_1773431536.jpg', 3, '2026-03-13 19:52:16');

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
(1, 'الضفة الغربية', 'West Bank', 'הגדה המערבית', 'west-bank', 1, 5, '2026-01-21 23:56:25'),
(2, 'القدس (كل المناطق)', 'Jerusalem all Areas', 'ירושלים (כל איזורים)', ' Jerusalem all Areas', 1, 2, '2026-01-21 23:56:25'),
(3, 'الداخل الشمال', ' South Israel', 'ישראל צפון', 'israel', 1, 3, '2026-01-21 23:56:25'),
(4, 'النقب (الجنوب)', 'South) Negev)', 'הנגב (דרום)', 'south ) Negev)', 1, 4, '2026-01-21 23:56:25'),
(6, 'المركز', 'Center', 'מרכז', 'Center', 1, 1, '2026-03-12 20:47:05');

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
-- Table structure for table `settings`
--

CREATE TABLE `settings` (
  `id` int(10) UNSIGNED NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `setting_group` varchar(50) DEFAULT 'general',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`id`, `setting_key`, `setting_value`, `setting_group`, `created_at`, `updated_at`) VALUES
(1, 'apple_shared_secret', '', 'iap', '2026-03-09 23:47:35', '2026-03-09 23:47:35'),
(2, 'apple_iap_sandbox', '1', 'iap', '2026-03-09 23:47:35', '2026-03-09 23:47:35'),
(3, 'google_play_service_account', '', 'iap', '2026-03-09 23:47:35', '2026-03-09 23:47:35'),
(4, 'google_iap_sandbox', '1', 'iap', '2026-03-09 23:47:35', '2026-03-09 23:47:35'),
(9, 'payment_bank_transfer_enabled', '0', 'payment_methods', '2026-03-09 23:58:57', '2026-03-23 08:10:19'),
(10, 'payment_apple_iap_enabled', '1', 'payment_methods', '2026-03-09 23:58:57', '2026-03-09 23:58:57'),
(11, 'payment_google_iap_enabled', '1', 'payment_methods', '2026-03-09 23:58:57', '2026-03-09 23:58:57'),
(12, 'payment_test_enabled', '1', 'payment_methods', '2026-03-09 23:58:57', '2026-03-09 23:58:57'),
(13, 'bank_name', 'بنك فلسطين', 'bank_details', '2026-03-09 23:58:57', '2026-03-09 23:58:57'),
(14, 'bank_account_name', 'RentoGo للخدمات', 'bank_details', '2026-03-09 23:58:57', '2026-03-09 23:58:57'),
(15, 'bank_account_number', '1234567890', 'bank_details', '2026-03-09 23:58:57', '2026-03-09 23:58:57'),
(16, 'bank_iban', 'PS00PALS000000001234567890', 'bank_details', '2026-03-09 23:58:57', '2026-03-09 23:58:57'),
(17, 'bank_branch', 'الفرع الرئيسي', 'bank_details', '2026-03-09 23:58:57', '2026-03-09 23:58:57');

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
  `status` enum('active','expired','cancelled','pending_verification','rejected') DEFAULT 'active',
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
(1, 1, 1, 'cars', 0, 1, 0, 'active', 'welcome_bonus', 'WELCOME_BONUS_1', '2026-03-11 00:28:11', '2026-03-18 00:28:11', '2026-03-11 00:28:11'),
(2, 1, 2, 'properties', 0, 1, 0, 'active', 'welcome_bonus', 'WELCOME_BONUS_1', '2026-03-11 00:28:11', '2026-03-18 00:28:11', '2026-03-11 00:28:11'),
(3, 1, 3, 'properties', 1, 1, 0, 'active', 'test', 'TEST_1773260501_1', '2026-03-11 20:21:41', '2026-03-18 20:21:41', '2026-03-11 20:21:41'),
(4, 1, 3, 'properties', 1, 1, 0, 'active', 'test', 'TEST_1773262511_1', '2026-03-11 20:55:11', '2026-03-18 20:55:11', '2026-03-11 20:55:11'),
(5, 2, 1, 'cars', 1, 1, 0, 'active', 'welcome_bonus', 'WELCOME_BONUS_2', '2026-03-11 21:27:08', '2026-03-18 21:27:08', '2026-03-11 21:27:08'),
(6, 2, 2, 'properties', 1, 1, 0, 'active', 'welcome_bonus', 'WELCOME_BONUS_2', '2026-03-11 21:27:08', '2026-03-18 21:27:08', '2026-03-11 21:27:08'),
(7, 2, 5, 'properties', 1, 5, 0, 'active', 'test', 'TEST_1773266922_2', '2026-03-11 22:08:42', '2026-03-21 22:08:42', '2026-03-11 22:08:42'),
(8, 3, 1, 'cars', 0, 1, 0, 'active', 'welcome_bonus', 'WELCOME_BONUS_3', '2026-03-11 23:34:47', '2026-03-18 23:34:47', '2026-03-11 23:34:47'),
(9, 3, 2, 'properties', 0, 1, 0, 'active', 'welcome_bonus', 'WELCOME_BONUS_3', '2026-03-11 23:34:47', '2026-03-18 23:34:47', '2026-03-11 23:34:47'),
(10, 4, 1, 'cars', 0, 1, 0, 'active', 'welcome_bonus', 'WELCOME_BONUS_4', '2026-03-11 23:47:22', '2026-03-18 23:47:22', '2026-03-11 23:47:22'),
(11, 4, 2, 'properties', 0, 1, 0, 'active', 'welcome_bonus', 'WELCOME_BONUS_4', '2026-03-11 23:47:22', '2026-03-18 23:47:22', '2026-03-11 23:47:22'),
(12, 5, 1, 'cars', 0, 1, 0, 'active', 'welcome_bonus', 'WELCOME_BONUS_5', '2026-03-12 00:27:34', '2026-03-19 00:27:34', '2026-03-12 00:27:34'),
(13, 5, 2, 'properties', 0, 1, 0, 'active', 'welcome_bonus', 'WELCOME_BONUS_5', '2026-03-12 00:27:34', '2026-03-19 00:27:34', '2026-03-12 00:27:34'),
(14, 2, 6, 'cars', 0, 50, 0, 'active', 'test', 'TEST_1773355705_2', '2026-03-12 22:48:25', '2026-04-11 22:48:25', '2026-03-12 22:48:25'),
(15, 2, 3, 'properties', 1, 1, 0, 'active', 'test', 'TEST_1773360637_2', '2026-03-13 00:10:37', '2026-03-20 00:10:37', '2026-03-13 00:10:37'),
(16, 2, 11, 'cars', 1, 999999, 1, 'active', 'test', 'TEST_1773607746_2', '2026-03-15 20:49:06', '2026-04-14 20:49:06', '2026-03-15 20:49:06'),
(17, 6, 2, 'properties', 0, 1, 0, 'active', 'welcome_bonus', 'WELCOME_BONUS_6', '2026-03-22 16:19:16', '2026-03-29 16:19:16', '2026-03-22 16:19:16');

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
(1, 'نسيم', NULL, 'www.palestine.ieet@gmail.com', '0599940687', '$2y$10$1aZPkogz0UxvOduKHtwIH.7GwgWaVBSc3YylU6ONLEitc28zWm7uW', 'renter', NULL, 0, 0, 0, NULL, 1, 1, 0, 1, 'ar', 'ehsleRFiTtSoWsU14WT4F3:APA91bGrvTv_bRO8Gmg9tHfs0cG7NHlj27PgV7kFaQXnvkVIRJDqEAHj2SZuhKItjVS9iJSAoM79znzE9hUO0J1c_HOO-MUhoD9L6S66HFmMfTLLPTIc_Ec', 1, '2026-03-11 00:28:11', '2026-03-12 00:18:35', 2, 12),
(2, 'mohammad', NULL, 'mhmdkhweis.mk@gmail.com', '0548724689', '$2y$10$I6VPdhtBPxjQXyiXwv3Jne3O67bdlBKv6LYeuDKzNoaTiw923bDLW', 'car_lessor', NULL, 0, 0, 0, NULL, 1, 1, 0, 1, 'ar', 'e33UB-wPS1S7EW3RwFGV2i:APA91bEeNhBUIbGJxotcW3FNsImoy84zfWk7C4gOxlnsvbNTdp6Yq2KOzVSb0hi4QaVki9GxSDDk1n8K6EJB4hTRHDSCh-m8bIC7fGyNSb0OUkiOF5MfBwY', 1, '2026-03-11 21:27:08', '2026-03-22 15:53:54', 2, 11),
(3, 'mohammad2', NULL, 'mohammadkhweis344@gmail.com', '0547840085', '$2y$10$tim01eSnXRXVplpchBwQFOMPPgqkp9fcqsYEF.Nj79L2tPIIDcqLG', 'office', NULL, 0, 0, 0, NULL, 1, 1, 0, 1, 'ar', 'e33UB-wPS1S7EW3RwFGV2i:APA91bEeNhBUIbGJxotcW3FNsImoy84zfWk7C4gOxlnsvbNTdp6Yq2KOzVSb0hi4QaVki9GxSDDk1n8K6EJB4hTRHDSCh-m8bIC7fGyNSb0OUkiOF5MfBwY', 1, '2026-03-11 23:34:47', '2026-03-22 15:53:19', 2, 12),
(4, 'amer', NULL, 'telyhidmi@gmail.com', '0546477951', '$2y$10$McYy/cdBmPr0.OHTl1IFaehuy1CU1aN.8PloligM4khUcDwa5NyIm', 'owner', NULL, 0, 0, 0, NULL, 1, 1, 0, 1, 'ar', 'fetijtluSJuoNcPqKE0FE-:APA91bEZw031rIo9lnIFypCvxmzADnH04NIylfbfXHidzJG5-yulwf0VVXYy67qSzJo1oDWYkoWD-zsVCM0KiXYsxnQ2Rx5WFk9Wx5g73CIMCg706soMD0I', 1, '2026-03-11 23:47:22', '2026-03-11 23:47:23', 2, 11),
(5, 'kelaneps', NULL, 'kelane@info.com', '+972592123424', '$2y$10$G8.B3e5YFNED1Chu3GniMeoMw0ovQ1LLrNWdEybujphxyKPC8DD1q', 'renter', NULL, 0, 0, 0, NULL, 1, 1, 0, 1, 'ar', 'd-pny2r3Q7S9NY6r5xUI-Z:APA91bHubuZn5PbQPhc4wc9Jvjqsqyr9wfv7keGZkYaejKaGG5IbHsAkL3ewSTs_mb-v60qCGkUpmjH4nhUhXeyg9fmbdIaVgo1hNTFY54QVjq7VjvQycEY', 1, '2026-03-12 00:27:34', '2026-03-12 00:27:34', 2, 12),
(6, 'mohammad2', NULL, 'mohammad123@gmail.com', '0528602593', '$2y$10$IXLPTbDnsb88X.K1Z8EvSObrCEHbyYuvi1MYLVvIAmv65WJxqsF4.', 'office', NULL, 0, 0, 0, NULL, 1, 1, 0, 1, 'ar', 'e33UB-wPS1S7EW3RwFGV2i:APA91bEeNhBUIbGJxotcW3FNsImoy84zfWk7C4gOxlnsvbNTdp6Yq2KOzVSb0hi4QaVki9GxSDDk1n8K6EJB4hTRHDSCh-m8bIC7fGyNSb0OUkiOF5MfBwY', 1, '2026-03-22 16:19:16', '2026-03-22 16:19:16', 2, 56);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_monthly_revenue`
-- (See below for the actual view)
--
CREATE TABLE `v_monthly_revenue` (
`year` int(5)
,`month` int(3)
,`payment_method` varchar(50)
,`successful_transactions` bigint(21)
,`failed_transactions` bigint(21)
,`gross_revenue` decimal(32,2)
,`total_fees` decimal(32,2)
,`net_revenue` decimal(32,2)
,`total_refunds` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `v_payment_summary`
-- (See below for the actual view)
--
CREATE TABLE `v_payment_summary` (
`payment_date` date
,`payment_method` varchar(50)
,`status` enum('pending','completed','failed','refunded','rejected')
,`transaction_count` bigint(21)
,`gross_amount` decimal(32,2)
,`total_fees` decimal(32,2)
,`net_amount` decimal(32,2)
,`refunded_amount` decimal(32,2)
);

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
  ADD KEY `car_type_id` (`car_type_id`),
  ADD KEY `idx_is_rented` (`is_rented`);

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
-- Indexes for table `invoices`
--
ALTER TABLE `invoices`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `invoice_number` (`invoice_number`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_payment_id` (`payment_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_issued_at` (`issued_at`);

--
-- Indexes for table `invoice_items`
--
ALTER TABLE `invoice_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_invoice_id` (`invoice_id`);

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
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_payment_method` (`payment_method`),
  ADD KEY `idx_created_at` (`created_at`),
  ADD KEY `idx_invoice` (`invoice_number`);

--
-- Indexes for table `payment_logs`
--
ALTER TABLE `payment_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_payment_id` (`payment_id`),
  ADD KEY `idx_action` (`action`),
  ADD KEY `idx_created_at` (`created_at`);

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
  ADD KEY `property_type_id` (`property_type_id`),
  ADD KEY `idx_is_rented` (`is_rented`);

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
-- Indexes for table `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `setting_key` (`setting_key`),
  ADD KEY `idx_key` (`setting_key`),
  ADD KEY `idx_group` (`setting_group`);

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
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `admin_banner_media`
--
ALTER TABLE `admin_banner_media`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `admin_users`
--
ALTER TABLE `admin_users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `app_settings`
--
ALTER TABLE `app_settings`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `cars`
--
ALTER TABLE `cars`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `car_media`
--
ALTER TABLE `car_media`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `car_types`
--
ALTER TABLE `car_types`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `cities`
--
ALTER TABLE `cities`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=72;

--
-- AUTO_INCREMENT for table `cms_pages`
--
ALTER TABLE `cms_pages`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `conversations`
--
ALTER TABLE `conversations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `favorites`
--
ALTER TABLE `favorites`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `invoices`
--
ALTER TABLE `invoices`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `invoice_items`
--
ALTER TABLE `invoice_items`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `otp_codes`
--
ALTER TABLE `otp_codes`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `payment_logs`
--
ALTER TABLE `payment_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `plans`
--
ALTER TABLE `plans`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `properties`
--
ALTER TABLE `properties`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `property_media`
--
ALTER TABLE `property_media`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `property_types`
--
ALTER TABLE `property_types`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `realtime_messages`
--
ALTER TABLE `realtime_messages`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `regions`
--
ALTER TABLE `regions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `reports`
--
ALTER TABLE `reports`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `settings`
--
ALTER TABLE `settings`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `subscriptions`
--
ALTER TABLE `subscriptions`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `subscription_requests`
--
ALTER TABLE `subscription_requests`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

-- --------------------------------------------------------

--
-- Structure for view `v_monthly_revenue`
--
DROP TABLE IF EXISTS `v_monthly_revenue`;

CREATE ALGORITHM=UNDEFINED DEFINER=`rentogo`@`localhost` SQL SECURITY DEFINER VIEW `v_monthly_revenue`  AS SELECT year(`p`.`created_at`) AS `year`, month(`p`.`created_at`) AS `month`, `p`.`payment_method` AS `payment_method`, count(case when `p`.`status` = 'completed' then 1 end) AS `successful_transactions`, count(case when `p`.`status` = 'failed' then 1 end) AS `failed_transactions`, sum(case when `p`.`status` = 'completed' then `p`.`amount` else 0 end) AS `gross_revenue`, sum(case when `p`.`status` = 'completed' then `p`.`fee_amount` else 0 end) AS `total_fees`, sum(case when `p`.`status` = 'completed' then `p`.`net_amount` else 0 end) AS `net_revenue`, sum(case when `p`.`status` = 'refunded' then `p`.`refunded_amount` else 0 end) AS `total_refunds` FROM `payments` AS `p` GROUP BY year(`p`.`created_at`), month(`p`.`created_at`), `p`.`payment_method` ;

-- --------------------------------------------------------

--
-- Structure for view `v_payment_summary`
--
DROP TABLE IF EXISTS `v_payment_summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`rentogo`@`localhost` SQL SECURITY DEFINER VIEW `v_payment_summary`  AS SELECT cast(`p`.`created_at` as date) AS `payment_date`, `p`.`payment_method` AS `payment_method`, `p`.`status` AS `status`, count(0) AS `transaction_count`, sum(`p`.`amount`) AS `gross_amount`, sum(`p`.`fee_amount`) AS `total_fees`, sum(`p`.`net_amount`) AS `net_amount`, sum(case when `p`.`status` = 'refunded' then `p`.`refunded_amount` else 0 end) AS `refunded_amount` FROM `payments` AS `p` GROUP BY cast(`p`.`created_at` as date), `p`.`payment_method`, `p`.`status` ;

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
-- Constraints for table `invoices`
--
ALTER TABLE `invoices`
  ADD CONSTRAINT `invoices_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `invoices_ibfk_2` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `invoice_items`
--
ALTER TABLE `invoice_items`
  ADD CONSTRAINT `invoice_items_ibfk_1` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`) ON DELETE CASCADE;

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
-- Constraints for table `payment_logs`
--
ALTER TABLE `payment_logs`
  ADD CONSTRAINT `payment_logs_ibfk_1` FOREIGN KEY (`payment_id`) REFERENCES `payments` (`id`) ON DELETE CASCADE;

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
