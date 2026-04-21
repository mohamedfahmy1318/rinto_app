-- جدول إعدادات التطبيق (الشروط وسياسة الخصوصية)
CREATE TABLE IF NOT EXISTS `app_settings` (
    `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `setting_key` VARCHAR(100) NOT NULL UNIQUE,
    `value_ar` TEXT,
    `value_en` TEXT,
    `value_he` TEXT,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `updated_by` INT UNSIGNED NULL,
    INDEX `idx_key` (`setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- إدراج البيانات الافتراضية
INSERT INTO `app_settings` (`setting_key`, `value_ar`, `value_en`, `value_he`) VALUES
('terms_of_service', 
'<h2>شروط الاستخدام</h2>
<p>مرحباً بك في تطبيق RentoGo. باستخدامك لهذا التطبيق، فإنك توافق على الشروط والأحكام التالية:</p>
<h3>1. القبول بالشروط</h3>
<p>باستخدام هذا التطبيق، فإنك توافق على الالتزام بهذه الشروط والأحكام.</p>
<h3>2. استخدام الخدمة</h3>
<p>يجب استخدام التطبيق للأغراض المشروعة فقط وبما يتوافق مع القوانين المحلية.</p>
<h3>3. حساب المستخدم</h3>
<p>أنت مسؤول عن الحفاظ على سرية معلومات حسابك.</p>
<h3>4. المحتوى</h3>
<p>أنت مسؤول عن أي محتوى تنشره على التطبيق.</p>
<h3>5. إنهاء الخدمة</h3>
<p>نحتفظ بالحق في إنهاء أو تعليق حسابك في أي وقت.</p>',

'<h2>Terms of Service</h2>
<p>Welcome to RentoGo. By using this application, you agree to the following terms and conditions:</p>
<h3>1. Acceptance of Terms</h3>
<p>By using this app, you agree to be bound by these terms and conditions.</p>
<h3>2. Use of Service</h3>
<p>The app must be used for lawful purposes only and in compliance with local laws.</p>
<h3>3. User Account</h3>
<p>You are responsible for maintaining the confidentiality of your account information.</p>
<h3>4. Content</h3>
<p>You are responsible for any content you post on the app.</p>
<h3>5. Termination</h3>
<p>We reserve the right to terminate or suspend your account at any time.</p>',

'<h2>תנאי שימוש</h2>
<p>ברוכים הבאים ל-RentoGo. בשימוש באפליקציה זו, אתה מסכים לתנאים וההגבלות הבאים:</p>
<h3>1. קבלת התנאים</h3>
<p>בשימוש באפליקציה זו, אתה מסכים להיות כפוף לתנאים והגבלות אלה.</p>
<h3>2. שימוש בשירות</h3>
<p>יש להשתמש באפליקציה למטרות חוקיות בלבד ובהתאם לחוקים המקומיים.</p>
<h3>3. חשבון משתמש</h3>
<p>אתה אחראי לשמור על סודיות פרטי החשבון שלך.</p>
<h3>4. תוכן</h3>
<p>אתה אחראי לכל תוכן שאתה מפרסם באפליקציה.</p>
<h3>5. סיום</h3>
<p>אנו שומרים לעצמנו את הזכות לסיים או להשעות את חשבונך בכל עת.</p>'),

('privacy_policy',
'<h2>سياسة الخصوصية</h2>
<p>نحن نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية.</p>
<h3>1. البيانات التي نجمعها</h3>
<p>نجمع المعلومات التي تقدمها لنا مباشرة مثل الاسم والبريد الإلكتروني ورقم الهاتف.</p>
<h3>2. كيف نستخدم بياناتك</h3>
<p>نستخدم بياناتك لتقديم خدماتنا وتحسينها.</p>
<h3>3. مشاركة البيانات</h3>
<p>لا نشارك بياناتك مع أطراف ثالثة إلا بموافقتك.</p>
<h3>4. حذف البيانات</h3>
<p>يمكنك طلب حذف حسابك وجميع بياناتك في أي وقت.</p>',

'<h2>Privacy Policy</h2>
<p>We respect your privacy and are committed to protecting your personal data.</p>
<h3>1. Data We Collect</h3>
<p>We collect information you provide directly such as name, email, and phone number.</p>
<h3>2. How We Use Your Data</h3>
<p>We use your data to provide and improve our services.</p>
<h3>3. Data Sharing</h3>
<p>We do not share your data with third parties without your consent.</p>
<h3>4. Data Deletion</h3>
<p>You can request deletion of your account and all your data at any time.</p>',

'<h2>מדיניות פרטיות</h2>
<p>אנו מכבדים את פרטיותך ומחויבים להגן על הנתונים האישיים שלך.</p>
<h3>1. נתונים שאנו אוספים</h3>
<p>אנו אוספים מידע שאתה מספק ישירות כגון שם, אימייל ומספר טלפון.</p>
<h3>2. כיצד אנו משתמשים בנתונים שלך</h3>
<p>אנו משתמשים בנתונים שלך כדי לספק ולשפר את השירותים שלנו.</p>
<h3>3. שיתוף נתונים</h3>
<p>איננו משתפים את הנתונים שלך עם צדדים שלישיים ללא הסכמתך.</p>
<h3>4. מחיקת נתונים</h3>
<p>אתה יכול לבקש מחיקת החשבון שלך וכל הנתונים שלך בכל עת.</p>')
ON DUPLICATE KEY UPDATE setting_key = setting_key;
