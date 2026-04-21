# دليل رفع المشروع على الاستضافة

## الملفات المطلوب رفعها

```
📁 your-domain.com/
├── 📁 backend/          ← API Backend
│   ├── 📁 api/
│   ├── 📁 config/
│   ├── 📁 database/
│   └── 📁 helpers/
├── 📁 web/              ← Public Website
│   ├── 📁 assets/
│   ├── 📁 includes/
│   └── *.php files
├── 📁 admin/            ← Admin Dashboard
├── 📁 uploads/          ← User uploads (create empty)
└── index.php            ← Redirect to web/
```

## خطوات الرفع

### 1. إعداد قاعدة البيانات

1. أنشئ قاعدة بيانات جديدة في cPanel
2. أنشئ مستخدم للقاعدة وأعطه كل الصلاحيات
3. استورد ملف `backend/database/schema.sql`
4. (اختياري) استورد `backend/database/seed_data.sql` للبيانات التجريبية

### 2. تعديل إعدادات الاتصال

#### ملف `backend/config/database.php`:
```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'your_database_name');
define('DB_USER', 'your_database_user');
define('DB_PASS', 'your_database_password');
```

#### ملف `backend/config/constants.php`:
```php
define('APP_URL', 'https://yourdomain.com');
define('API_URL', APP_URL . '/backend/api');
define('UPLOAD_URL', APP_URL . '/uploads/');

// غيّر المفتاح السري
define('JWT_SECRET', 'your-unique-secret-key-here-change-it');
```

#### ملف `web/config.php`:
```php
define('SITE_URL', 'https://yourdomain.com/web');
define('API_URL', 'https://yourdomain.com/backend/api');
define('UPLOAD_URL', 'https://yourdomain.com/uploads/');
```

#### ملف `admin/includes/header.php`:
تأكد من تحديث مسارات CSS و JS

### 3. إعداد مجلد الرفع

```bash
mkdir uploads
mkdir uploads/properties
mkdir uploads/cars
mkdir uploads/profiles
chmod 755 uploads -R
```

### 4. تعديل تطبيق Flutter

#### ملف `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'https://yourdomain.com/backend/api';
static const String uploadUrl = 'https://yourdomain.com/uploads/';
```

### 5. إنشاء ملف index.php في الجذر

```php
<?php
header('Location: /web/');
exit;
```

## إعدادات الأمان

### تفعيل HTTPS
- احصل على شهادة SSL من cPanel (Let's Encrypt مجاني)
- فعّل إعادة التوجيه من HTTP إلى HTTPS

### حماية المجلدات
أضف `.htaccess` في مجلد `backend/config/`:
```apache
Deny from all
```

### CORS للـ API
ملف `backend/api/.htaccess` يحتوي بالفعل على إعدادات CORS

## التحقق من العمل

1. **الموقع**: `https://yourdomain.com/web/`
2. **لوحة التحكم**: `https://yourdomain.com/admin/`
3. **API**: `https://yourdomain.com/backend/api/properties`

## استكشاف الأخطاء

### خطأ 500
- تحقق من صلاحيات الملفات (644) والمجلدات (755)
- راجع سجل الأخطاء في cPanel

### لا تظهر البيانات
- تأكد من إعدادات قاعدة البيانات
- تحقق من وجود بيانات في الجداول

### مشاكل الصور
- تأكد من وجود مجلد uploads بصلاحيات الكتابة
- تحقق من مسار UPLOAD_URL

## الدعم
للمساعدة، تواصل عبر: support@rentogo.com
