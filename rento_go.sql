-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 07, 2026 at 02:29 AM
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
(1, 'Super Admin', 'admin@rentogo.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'super_admin', 1, NULL, '2026-01-22 19:00:01', '2026-01-22 19:00:01');

-- --------------------------------------------------------

--
-- Table structure for table `app_settings`
--

CREATE TABLE `app_settings` (
  `id` int(10) UNSIGNED NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `value_ar` text DEFAULT NULL,
  `value_en` text DEFAULT NULL,
  `value_he` text DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `app_settings`
--

INSERT INTO `app_settings` (`id`, `setting_key`, `value_ar`, `value_en`, `value_he`, `updated_at`, `updated_by`) VALUES
(1, 'terms_of_service', '<h2>شروط الاستخدام</h2>\r\n<p>مرحباً بك في تطبيق RentoGo. باستخدامك لهذا التطبيق، فإنك توافق على الشروط والأحكام التالية:</p>\r\n<h3>1. القبول بالشروط</h3>\r\n<p>باستخدام هذا التطبيق، فإنك توافق على الالتزام بهذه الشروط والأحكام.</p>\r\n<h3>2. استخدام الخدمة</h3>\r\n<p>يجب استخدام التطبيق للأغراض المشروعة فقط وبما يتوافق مع القوانين المحلية.</p>\r\n<h3>3. حساب المستخدم</h3>\r\n<p>أنت مسؤول عن الحفاظ على سرية معلومات حسابك.</p>\r\n<h3>4. المحتوى</h3>\r\n<p>أنت مسؤول عن أي محتوى تنشره على التطبيق.</p>\r\n<h3>5. إنهاء الخدمة</h3>\r\n<p>نحتفظ بالحق في إنهاء أو تعليق حسابك في أي وقت.</p>', '<h2>Terms of Service</h2>\r\n<p>Welcome to RentoGo. By using this application, you agree to the following terms and conditions:</p>\r\n<h3>1. Acceptance of Terms</h3>\r\n<p>By using this app, you agree to be bound by these terms and conditions.</p>\r\n<h3>2. Use of Service</h3>\r\n<p>The app must be used for lawful purposes only and in compliance with local laws.</p>\r\n<h3>3. User Account</h3>\r\n<p>You are responsible for maintaining the confidentiality of your account information.</p>\r\n<h3>4. Content</h3>\r\n<p>You are responsible for any content you post on the app.</p>\r\n<h3>5. Termination</h3>\r\n<p>We reserve the right to terminate or suspend your account at any time.</p>', '<h2>תנאי שימוש</h2>\r\n<p>ברוכים הבאים ל-RentoGo. בשימוש באפליקציה זו, אתה מסכים לתנאים וההגבלות הבאים:</p>\r\n<h3>1. קבלת התנאים</h3>\r\n<p>בשימוש באפליקציה זו, אתה מסכים להיות כפוף לתנאים והגבלות אלה.</p>\r\n<h3>2. שימוש בשירות</h3>\r\n<p>יש להשתמש באפליקציה למטרות חוקיות בלבד ובהתאם לחוקים המקומיים.</p>\r\n<h3>3. חשבון משתמש</h3>\r\n<p>אתה אחראי לשמור על סודיות פרטי החשבון שלך.</p>\r\n<h3>4. תוכן</h3>\r\n<p>אתה אחראי לכל תוכן שאתה מפרסם באפליקציה.</p>\r\n<h3>5. סיום</h3>\r\n<p>אנו שומרים לעצמנו את הזכות לסיים או להשעות את חשבונך בכל עת.</p>', '2026-02-07 00:19:39', NULL),
(2, 'privacy_policy', '<h2>سياسة الخصوصية</h2>\r\n<p>نحن نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية.</p>\r\n<h3>1. البيانات التي نجمعها</h3>\r\n<p>نجمع المعلومات التي تقدمها لنا مباشرة مثل الاسم والبريد الإلكتروني ورقم الهاتف.</p>\r\n<h3>2. كيف نستخدم بياناتك</h3>\r\n<p>نستخدم بياناتك لتقديم خدماتنا وتحسينها.</p>\r\n<h3>3. مشاركة البيانات</h3>\r\n<p>لا نشارك بياناتك مع أطراف ثالثة إلا بموافقتك.</p>\r\n<h3>4. حذف البيانات</h3>\r\n<p>يمكنك طلب حذف حسابك وجميع بياناتك في أي وقت.</p>', '<h2>Privacy Policy</h2>\r\n<p>We respect your privacy and are committed to protecting your personal data.</p>\r\n<h3>1. Data We Collect</h3>\r\n<p>We collect information you provide directly such as name, email, and phone number.</p>\r\n<h3>2. How We Use Your Data</h3>\r\n<p>We use your data to provide and improve our services.</p>\r\n<h3>3. Data Sharing</h3>\r\n<p>We do not share your data with third parties without your consent.</p>\r\n<h3>4. Data Deletion</h3>\r\n<p>You can request deletion of your account and all your data at any time.</p>', '<h2>מדיניות פרטיות</h2>\r\n<p>אנו מכבדים את פרטיותך ומחויבים להגן על הנתונים האישיים שלך.</p>\r\n<h3>1. נתונים שאנו אוספים</h3>\r\n<p>אנו אוספים מידע שאתה מספק ישירות כגון שם, אימייל ומספר טלפון.</p>\r\n<h3>2. כיצד אנו משתמשים בנתונים שלך</h3>\r\n<p>אנו משתמשים בנתונים שלך כדי לספק ולשפר את השירותים שלנו.</p>\r\n<h3>3. שיתוף נתונים</h3>\r\n<p>איננו משתפים את הנתונים שלך עם צדדים שלישיים ללא הסכמתך.</p>\r\n<h3>4. מחיקת נתונים</h3>\r\n<p>אתה יכול לבקש מחיקת החשבון שלך וכל הנתונים שלך בכל עת.</p>', '2026-02-07 00:19:39', NULL);

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
(1, 1, 'image', 'sample.png', NULL, 1, '2026-01-22 19:00:01'),
(2, 2, 'image', 'sample.png', NULL, 1, '2026-01-22 19:00:01'),
(3, 3, 'image', 'sample.png', NULL, 1, '2026-01-22 19:00:01'),
(4, 4, 'image', 'sample.png', NULL, 1, '2026-01-22 19:00:01'),
(5, 5, 'image', 'sample.png', NULL, 1, '2026-01-22 19:00:01'),
(6, 6, 'image', 'sample.png', NULL, 1, '2026-01-22 19:00:01'),
(7, 7, 'image', 'sample.png', NULL, 1, '2026-01-22 19:00:01'),
(8, 8, 'image', 'sample.png', NULL, 1, '2026-01-22 19:00:01'),
(9, 9, 'image', 'sample.png', NULL, 1, '2026-01-22 19:00:01'),
(10, 10, 'image', 'sample.png', NULL, 1, '2026-01-22 19:00:01');

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
(1, 'privacy', 'سياسة الخصوصية', 'Privacy Policy', 'מדיניות פרטיות', '<h1>سياسة الخصوصية</h1><p>محتوى سياسة الخصوصية...</p>', '<h1>Privacy Policy</h1><p>Privacy policy content...</p>', '<h1>מדיניות פרטיות</h1><p>תוכן מדיניות הפרטיות...</p>', 1, '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(2, 'terms', 'الشروط والأحكام', 'Terms & Conditions', 'תנאים והגבלות', '<h1>الشروط والأحكام</h1><p>محتوى الشروط والأحكام...</p>', '<h1>Terms & Conditions</h1><p>Terms and conditions content...</p>', '<h1>תנאים והגבלות</h1><p>תוכן התנאים וההגבלות...</p>', 1, '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(3, 'disclaimer', 'إخلاء المسؤولية', 'Disclaimer', 'כתב ויתור', '<h1>إخلاء المسؤولية</h1><p>Rento Go منصة إعلانية فقط ولا تتدخل في العقود أو المدفوعات بين الأطراف...</p>', '<h1>Disclaimer</h1><p>Rento Go is an advertising platform only and does not intervene in contracts or payments between parties...</p>', '<h1>כתב ויתור</h1><p>Rento Go היא פלטפורמת פרסום בלבד ואינה מתערבת בחוזים או תשלומים בין הצדדים...</p>', 1, '2026-01-22 19:00:01', '2026-01-22 19:00:01');

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
(1, 1, 'property', 1, '2026-01-22 19:00:01'),
(2, 1, 'property', 6, '2026-01-22 19:00:01'),
(3, 1, 'car', 1, '2026-01-22 19:00:01'),
(4, 2, 'property', 2, '2026-01-22 19:00:01'),
(5, 2, 'property', 7, '2026-01-22 19:00:01'),
(6, 2, 'car', 5, '2026-01-22 19:00:01'),
(7, 3, 'property', 3, '2026-01-22 19:00:01'),
(8, 3, 'car', 8, '2026-01-22 19:00:01');

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
  `type` enum('listing_approved','listing_rejected','subscription_expiring','subscription_expired','general') NOT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data`)),
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `user_id`, `title_ar`, `title_en`, `title_he`, `body_ar`, `body_en`, `body_he`, `type`, `data`, `is_read`, `created_at`) VALUES
(1, 1, 'مرحباً بك في رينتو جو!', 'Welcome to Rento Go!', 'ברוכים הבאים לרנטו גו!', 'شكراً لانضمامك إلينا. استكشف أفضل العقارات والسيارات للإيجار.', 'Thank you for joining us. Explore the best properties and cars for rent.', 'תודה שהצטרפת אלינו. גלה את הנכסים והמכוניות הטובים ביותר להשכרה.', 'general', NULL, 0, '2026-01-22 19:00:01'),
(2, 4, 'تمت الموافقة على إعلانك', 'Your listing is approved', 'המודעה שלך אושרה', 'تهانينا! تم الموافقة على إعلان شقة فاخرة في وسط المدينة', 'Congratulations! Your listing has been approved', 'מזל טוב! המודעה שלך אושרה', 'listing_approved', NULL, 0, '2026-01-22 19:00:01'),
(3, 7, 'لديك استفسار جديد', 'You have a new inquiry', 'יש לך פנייה חדשה', 'قام مستخدم بالاستفسار عن سيارتك تويوتا كورولا', 'A user has inquired about your Toyota Corolla', 'משתמש התעניין בטויוטה קורולה שלך', 'general', NULL, 0, '2026-01-22 19:00:01');

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
  `transaction_id` varchar(255) DEFAULT NULL,
  `receipt_data` text DEFAULT NULL,
  `status` enum('pending','completed','failed','refunded') DEFAULT 'pending',
  `verified_at` timestamp NULL DEFAULT NULL,
  `verified_by` int(10) UNSIGNED DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
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
  `is_active` tinyint(1) DEFAULT 1,
  `sort_order` int(11) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `plans`
--

INSERT INTO `plans` (`id`, `category`, `name_ar`, `name_en`, `name_he`, `description_ar`, `description_en`, `description_he`, `plan_type`, `property_type`, `car_usage_type`, `listings_count`, `is_unlimited`, `duration_days`, `price`, `original_price`, `discount_percent`, `currency`, `badge`, `is_featured`, `is_active`, `sort_order`, `created_at`, `updated_at`) VALUES
(1, 'properties', 'إعلان شقة واحد', 'Single Apartment Ad', 'מודעת דירה בודדת', NULL, NULL, NULL, 'single', 'apartment', NULL, 1, 0, 30, 50.00, NULL, NULL, 'ILS', NULL, 0, 1, 1, '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(2, 'properties', 'إعلان فيلا واحد', 'Single Villa Ad', 'מודעת וילה בודדת', NULL, NULL, NULL, 'single', 'villa_chalet', NULL, 1, 0, 30, 100.00, NULL, NULL, 'ILS', NULL, 0, 1, 2, '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(3, 'properties', 'إعلان محل واحد', 'Single Shop Ad', 'מודעת חנות בודדת', NULL, NULL, NULL, 'single', 'shop_office', NULL, 1, 0, 30, 75.00, NULL, NULL, 'ILS', NULL, 0, 1, 3, '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(4, 'properties', 'باقة برونزية', 'Bronze Package', 'חבילת ברונזה', NULL, NULL, NULL, 'package', NULL, NULL, 5, 0, 30, 200.00, 250.00, 20, 'ILS', 'bronze', 0, 1, 4, '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(5, 'properties', 'باقة فضية', 'Silver Package', 'חבילת כסף', NULL, NULL, NULL, 'package', NULL, NULL, 10, 0, 30, 350.00, 500.00, 30, 'ILS', 'silver', 0, 1, 5, '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(6, 'properties', 'باقة ذهبية', 'Gold Package', 'חבילת זהב', NULL, NULL, NULL, 'package', NULL, NULL, NULL, 1, 30, 500.00, 750.00, 33, 'ILS', 'gold', 1, 1, 6, '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(7, 'cars', 'إعلان سيارة يومية', 'Daily Car Ad', 'מודעת רכב יומית', NULL, NULL, NULL, 'single', NULL, 'daily', 1, 0, 30, 40.00, NULL, NULL, 'ILS', NULL, 0, 1, 1, '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(8, 'cars', 'إعلان سيارة أعراس', 'Wedding Car Ad', 'מודעת רכב לחתונות', NULL, NULL, NULL, 'single', NULL, 'wedding', 1, 0, 30, 60.00, NULL, NULL, 'ILS', NULL, 0, 1, 2, '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(9, 'cars', 'إعلان سيارة سياحية', 'Tourism Car Ad', 'מודעת רכב לתיירות', NULL, NULL, NULL, 'single', NULL, 'tourism', 1, 0, 30, 80.00, NULL, NULL, 'ILS', NULL, 0, 1, 3, '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(10, 'cars', 'باقة سيارات برونزية', 'Bronze Cars Package', 'חבילת רכבים ברונזה', NULL, NULL, NULL, 'package', NULL, NULL, 5, 0, 30, 150.00, 200.00, 25, 'ILS', 'bronze', 0, 1, 4, '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(11, 'cars', 'باقة سيارات فضية', 'Silver Cars Package', 'חבילת רכבים כסף', NULL, NULL, NULL, 'package', NULL, NULL, 10, 0, 30, 280.00, 400.00, 30, 'ILS', 'silver', 0, 1, 5, '2026-01-22 19:00:01', '2026-01-22 19:00:01'),
(12, 'cars', 'باقة سيارات ذهبية', 'Gold Cars Package', 'חבילת רכבים זהב', NULL, NULL, NULL, 'package', NULL, NULL, NULL, 1, 30, 400.00, 600.00, 33, 'ILS', 'gold', 1, 1, 6, '2026-01-22 19:00:01', '2026-01-22 19:00:01');

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
(1, 1, 'image', 'sample.png', NULL, 1, '2026-01-22 19:00:01'),
(2, 2, 'image', 'sample.png', NULL, 1, '2026-01-22 19:00:01'),
(3, 3, 'image', 'sample.png', NULL, 1, '2026-01-22 19:00:01'),
(4, 4, 'image', 'sample.png', NULL, 1, '2026-01-22 19:00:01'),
(5, 5, 'image', 'sample.png', NULL, 1, '2026-01-22 19:00:01'),
(6, 6, 'image', 'sample.png', NULL, 1, '2026-01-22 19:00:01'),
(7, 7, 'image', 'sample.png', NULL, 1, '2026-01-22 19:00:01'),
(8, 8, 'image', 'sample.png', NULL, 1, '2026-01-22 19:00:01'),
(9, 9, 'image', 'sample.png', NULL, 1, '2026-01-22 19:00:01'),
(10, 10, 'image', 'sample.png', NULL, 1, '2026-01-22 19:00:01'),
(11, 11, 'image', 'sample.png', NULL, 1, '2026-01-22 19:00:01'),
(12, 12, 'image', 'sample.png', NULL, 1, '2026-01-22 19:00:01');

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
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
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
(1, 'الضفة الغربية', 'West Bank', 'הגדה המערבית', 'west-bank', 1, 1, '2026-01-22 19:00:01'),
(2, 'القدس', 'Jerusalem', 'ירושלים', 'jerusalem', 1, 2, '2026-01-22 19:00:01'),
(3, 'الداخل', 'Israel', 'ישראל', 'israel', 1, 3, '2026-01-22 19:00:01'),
(4, 'النقب', 'Negev', 'הנגב', 'negev', 1, 4, '2026-01-22 19:00:01');

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
  `listings_used` int(11) DEFAULT 0,
  `listings_limit` int(11) DEFAULT NULL,
  `is_unlimited` tinyint(1) DEFAULT 0,
  `status` enum('active','expired','cancelled') DEFAULT 'active',
  `starts_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `expires_at` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
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
  `is_blocked` tinyint(1) DEFAULT 0,
  `preferred_language` enum('ar','en','he') DEFAULT 'ar',
  `fcm_token` varchar(500) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `region_id` int(10) UNSIGNED DEFAULT NULL,
  `city_id` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `company_name`, `email`, `phone`, `password`, `user_type`, `profile_image`, `is_verified_phone`, `is_verified_email`, `is_trusted`, `trusted_until`, `is_active`, `is_blocked`, `preferred_language`, `fcm_token`, `created_at`, `updated_at`, `region_id`, `city_id`) VALUES
(1, 'أحمد محمد', NULL, 'ahmed@test.com', '+972501234567', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'renter', NULL, 1, 1, 0, NULL, 1, 0, 'ar', NULL, '2026-01-22 19:00:01', '2026-01-22 19:00:01', NULL, NULL),
(2, 'سارة أحمد', NULL, 'sara@test.com', '+972502345678', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'renter', NULL, 1, 1, 0, NULL, 1, 0, 'ar', NULL, '2026-01-22 19:00:01', '2026-01-22 19:00:01', NULL, NULL),
(3, 'محمد علي', NULL, 'mohamed@test.com', '+972503456789', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'renter', NULL, 1, 1, 0, NULL, 1, 0, 'ar', NULL, '2026-01-22 19:00:01', '2026-01-22 19:00:01', NULL, NULL),
(4, 'عبدالله العمري', NULL, 'abdullah@test.com', '+972504567890', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'owner', NULL, 1, 1, 1, NULL, 1, 0, 'ar', NULL, '2026-01-22 19:00:01', '2026-01-22 19:00:01', NULL, NULL),
(5, 'فاطمة حسن', NULL, 'fatima@test.com', '+972505678901', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'owner', NULL, 1, 1, 1, NULL, 1, 0, 'ar', NULL, '2026-01-22 19:00:01', '2026-01-22 19:00:01', NULL, NULL),
(6, 'خالد الشمري', NULL, 'khaled@test.com', '+972506789012', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'owner', NULL, 1, 1, 0, NULL, 1, 0, 'ar', NULL, '2026-01-22 19:00:01', '2026-01-22 19:00:01', NULL, NULL),
(7, 'يوسف الزهراني', NULL, 'yousef@test.com', '+972507890123', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'car_lessor', NULL, 1, 1, 1, NULL, 1, 0, 'ar', NULL, '2026-01-22 19:00:01', '2026-01-22 19:00:01', NULL, NULL),
(8, 'نورة السالم', NULL, 'noura@test.com', '+972508901234', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'car_lessor', NULL, 1, 1, 0, NULL, 1, 0, 'ar', NULL, '2026-01-22 19:00:01', '2026-01-22 19:00:01', NULL, NULL),
(9, 'مكتب الأمانة العقاري', NULL, 'amana@test.com', '+972509012345', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'office', NULL, 1, 1, 1, NULL, 1, 0, 'ar', NULL, '2026-01-22 19:00:01', '2026-01-22 19:00:01', NULL, NULL),
(10, 'مكتب النجاح للعقارات', NULL, 'najah@test.com', '+972500123456', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'office', NULL, 1, 1, 1, NULL, 1, 0, 'ar', NULL, '2026-01-22 19:00:01', '2026-01-22 19:00:01', NULL, NULL);

--
-- Indexes for dumped tables
--

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
  ADD KEY `idx_key` (`setting_key`);

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
  ADD KEY `idx_expires` (`expires_at`);

--
-- Indexes for table `car_media`
--
ALTER TABLE `car_media`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_car` (`car_id`);

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
  ADD KEY `idx_users` (`user1_id`,`user2_id`),
  ADD KEY `idx_conv_user1` (`user1_id`),
  ADD KEY `idx_conv_user2` (`user2_id`),
  ADD KEY `idx_conv_listing` (`listing_type`,`listing_id`),
  ADD KEY `idx_conv_last_message` (`last_message_at`);

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
  ADD KEY `idx_active` (`is_active`);

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
-- Indexes for table `property_media`
--
ALTER TABLE `property_media`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_property` (`property_id`);

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
-- AUTO_INCREMENT for table `admin_users`
--
ALTER TABLE `admin_users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `app_settings`
--
ALTER TABLE `app_settings`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `cars`
--
ALTER TABLE `cars`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `car_media`
--
ALTER TABLE `car_media`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

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
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `favorites`
--
ALTER TABLE `favorites`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `messages`
--
ALTER TABLE `messages`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `otp_codes`
--
ALTER TABLE `otp_codes`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `payments`
--
ALTER TABLE `payments`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `plans`
--
ALTER TABLE `plans`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `properties`
--
ALTER TABLE `properties`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `property_media`
--
ALTER TABLE `property_media`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `realtime_messages`
--
ALTER TABLE `realtime_messages`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

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
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Constraints for dumped tables
--

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
  ADD CONSTRAINT `cars_ibfk_3` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`);

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
-- Constraints for table `properties`
--
ALTER TABLE `properties`
  ADD CONSTRAINT `properties_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `properties_ibfk_2` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`),
  ADD CONSTRAINT `properties_ibfk_3` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`);

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
-- Constraints for table `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `users_city_fk` FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `users_region_fk` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
