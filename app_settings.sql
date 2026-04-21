-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Feb 16, 2026 at 12:53 PM
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
-- Table structure for table `app_settings`
--

CREATE TABLE `app_settings` (
  `id` int(10) UNSIGNED NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `value_ar` text DEFAULT NULL,
  `value_en` text DEFAULT NULL,
  `value_he` text DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_by` int(10) UNSIGNED DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `app_settings`
--

INSERT INTO `app_settings` (`id`, `setting_key`, `value_ar`, `value_en`, `value_he`, `updated_at`, `updated_by`) VALUES
(1, 'terms_of_service', '<h2>شروط الاستخدام</h2>\r\n<p>مرحباً بك في تطبيق RentoGo. باستخدامك لهذا التطبيق، فإنك توافق على الشروط والأحكام التالية:</p>\r\n<h3>1. القبول بالشروط</h3>\r\n<p>باستخدام هذا التطبيق، فإنك توافق على الالتزام بهذه الشروط والأحكام.</p>\r\n<h3>2. استخدام الخدمة</h3>\r\n<p>يجب استخدام التطبيق للأغراض المشروعة فقط وبما يتوافق مع القوانين المحلية.</p>\r\n<h3>3. حساب المستخدم</h3>\r\n<p>أنت مسؤول عن الحفاظ على سرية معلومات حسابك.</p>\r\n<h3>4. المحتوى</h3>\r\n<p>أنت مسؤول عن أي محتوى تنشره على التطبيق.</p>\r\n<h3>5. إنهاء الخدمة</h3>\r\n<p>نحتفظ بالحق في إنهاء أو تعليق حسابك في أي وقت.</p>', '<h2>Terms of Service</h2>\r\n<p>Welcome to RentoGo. By using this application, you agree to the following terms and conditions:</p>\r\n<h3>1. Acceptance of Terms</h3>\r\n<p>By using this app, you agree to be bound by these terms and conditions.</p>\r\n<h3>2. Use of Service</h3>\r\n<p>The app must be used for lawful purposes only and in compliance with local laws.</p>\r\n<h3>3. User Account</h3>\r\n<p>You are responsible for maintaining the confidentiality of your account information.</p>\r\n<h3>4. Content</h3>\r\n<p>You are responsible for any content you post on the app.</p>\r\n<h3>5. Termination</h3>\r\n<p>We reserve the right to terminate or suspend your account at any time.</p>', '<h2>תנאי שימוש</h2>\r\n<p>ברוכים הבאים ל-RentoGo. בשימוש באפליקציה זו, אתה מסכים לתנאים וההגבלות הבאים:</p>\r\n<h3>1. קבלת התנאים</h3>\r\n<p>בשימוש באפליקציה זו, אתה מסכים להיות כפוף לתנאים והגבלות אלה.</p>\r\n<h3>2. שימוש בשירות</h3>\r\n<p>יש להשתמש באפליקציה למטרות חוקיות בלבד ובהתאם לחוקים המקומיים.</p>\r\n<h3>3. חשבון משתמש</h3>\r\n<p>אתה אחראי לשמור על סודיות פרטי החשבון שלך.</p>\r\n<h3>4. תוכן</h3>\r\n<p>אתה אחראי לכל תוכן שאתה מפרסם באפליקציה.</p>\r\n<h3>5. סיום</h3>\r\n<p>אנו שומרים לעצמנו את הזכות לסיים או להשעות את חשבונך בכל עת.</p>', '2026-02-07 00:19:25', NULL),
(2, 'privacy_policy', '<h2>سياسة الخصوصية</h2>\r\n<p>نحن نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية.</p>\r\n<h3>1. البيانات التي نجمعها</h3>\r\n<p>نجمع المعلومات التي تقدمها لنا مباشرة مثل الاسم والبريد الإلكتروني ورقم الهاتف.</p>\r\n<h3>2. كيف نستخدم بياناتك</h3>\r\n<p>نستخدم بياناتك لتقديم خدماتنا وتحسينها.</p>\r\n<h3>3. مشاركة البيانات</h3>\r\n<p>لا نشارك بياناتك مع أطراف ثالثة إلا بموافقتك.</p>\r\n<h3>4. حذف البيانات</h3>\r\n<p>يمكنك طلب حذف حسابك وجميع بياناتك في أي وقت.</p>', '<h2>Privacy Policy</h2>\r\n<p>We respect your privacy and are committed to protecting your personal data.</p>\r\n<h3>1. Data We Collect</h3>\r\n<p>We collect information you provide directly such as name, email, and phone number.</p>\r\n<h3>2. How We Use Your Data</h3>\r\n<p>We use your data to provide and improve our services.</p>\r\n<h3>3. Data Sharing</h3>\r\n<p>We do not share your data with third parties without your consent.</p>\r\n<h3>4. Data Deletion</h3>\r\n<p>You can request deletion of your account and all your data at any time.</p>', '<h2>מדיניות פרטיות</h2>\r\n<p>אנו מכבדים את פרטיותך ומחויבים להגן על הנתונים האישיים שלך.</p>\r\n<h3>1. נתונים שאנו אוספים</h3>\r\n<p>אנו אוספים מידע שאתה מספק ישירות כגון שם, אימייל ומספר טלפון.</p>\r\n<h3>2. כיצד אנו משתמשים בנתונים שלך</h3>\r\n<p>אנו משתמשים בנתונים שלך כדי לספק ולשפר את השירותים שלנו.</p>\r\n<h3>3. שיתוף נתונים</h3>\r\n<p>איננו משתפים את הנתונים שלך עם צדדים שלישיים ללא הסכמתך.</p>\r\n<h3>4. מחיקת נתונים</h3>\r\n<p>אתה יכול לבקש מחיקת החשבון שלך וכל הנתונים שלך בכל עת.</p>', '2026-02-07 00:19:25', NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `app_settings`
--
ALTER TABLE `app_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `setting_key` (`setting_key`),
  ADD KEY `idx_key` (`setting_key`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `app_settings`
--
ALTER TABLE `app_settings`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
