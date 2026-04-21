# Rento Go - دليل الرفع على rento-go.com

## هيكل الملفات للرفع

```
public_html/ (أو www/)
├── backend/           ← API الخلفية
│   ├── api/
│   ├── config/
│   ├── database/
│   └── helpers/
├── admin/             ← لوحة التحكم
├── uploads/           ← مجلد الصور (أنشئه فارغ)
├── assets/
│   ├── css/
│   └── js/
├── includes/
├── .htaccess
├── index.php          ← الصفحة الرئيسية
├── properties.php
├── cars.php
├── details.php
├── about.php
├── contact.php
├── download.php
├── privacy.php
├── terms.php
└── config.php
```

## خطوات الرفع

### 1. إنشاء قاعدة البيانات
1. ادخل إلى cPanel → MySQL Databases
2. أنشئ قاعدة بيانات جديدة
3. أنشئ مستخدم وأعطه كل الصلاحيات
4. استورد ملف `backend/database/schema.sql`
5. استورد ملف `backend/database/seed_data.sql` (للبيانات التجريبية)

### 2. تعديل إعدادات قاعدة البيانات
عدّل ملف `backend/config/database.php`:
```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'اسم_قاعدة_البيانات');
define('DB_USER', 'اسم_المستخدم');
define('DB_PASS', 'كلمة_المرور');
```

### 3. تعديل المفتاح السري
عدّل ملف `backend/config/constants.php`:
```php
define('JWT_SECRET', 'مفتاح_سري_عشوائي_قوي_هنا');
```

### 4. إنشاء مجلدات الرفع
```
uploads/
├── properties/
├── cars/
└── profiles/
```
وأعطها صلاحيات الكتابة: `chmod 755 uploads -R`

### 5. رفع الملفات
ارفع كل محتويات مجلد `deploy/` إلى `public_html/`

### 6. تفعيل SSL
- من cPanel → SSL/TLS
- فعّل شهادة Let's Encrypt المجانية

## روابط الموقع بعد الرفع

| الصفحة | الرابط |
|--------|--------|
| الموقع | https://rento-go.com |
| لوحة التحكم | https://rento-go.com/admin |
| API | https://rento-go.com/backend/api |

## إعدادات تطبيق Flutter

عدّل ملف `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'https://rento-go.com/backend/api';
static const String uploadUrl = 'https://rento-go.com/uploads/';
```

## بيانات الدخول الافتراضية

### لوحة التحكم (Admin):
- **البريد**: admin@rentogo.com
- **كلمة المرور**: Admin@123

### مستخدم تجريبي:
- **الهاتف**: +972501234567
- **كلمة المرور**: User@123

---
**ملاحظة**: غيّر كلمات المرور فوراً بعد أول تسجيل دخول!
