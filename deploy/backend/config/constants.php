<?php
/**
 * Application Constants for Rento Go
 */

// App Settings
define('APP_NAME', 'Rento Go');
define('APP_VERSION', '1.0.0');
define('APP_TIMEZONE', 'Asia/Hebron'); // Palestine timezone

// Set default timezone
date_default_timezone_set(APP_TIMEZONE);

// Production (rento-go.com)
define('APP_URL', 'https://rento-go.com');
define('API_URL', APP_URL . '/backend/api');

// Local Development (uncomment):
// define('APP_URL', 'http://localhost/rento_go');
// define('API_URL', APP_URL . '/backend/api');

// JWT Settings
define('JWT_SECRET', 'RentoGo2026$Pr0duct10n#SecretKey!X9kL2mN4pQ7r');
define('JWT_EXPIRY', 86400 * 30); // 30 days

// Upload Settings
define('UPLOAD_PATH', __DIR__ . '/../../uploads/');
define('UPLOAD_URL', APP_URL . '/uploads/');
define('MAX_IMAGE_SIZE', 5 * 1024 * 1024); // 5MB
define('MAX_VIDEO_SIZE', 50 * 1024 * 1024); // 50MB
define('MAX_IMAGES_PER_LISTING', 5);
define('MAX_VIDEOS_PER_LISTING', 1);
define('ALLOWED_IMAGE_TYPES', ['image/jpeg', 'image/png', 'image/webp']);
define('ALLOWED_VIDEO_TYPES', ['video/mp4', 'video/quicktime', 'video/webm']);

// Listing Settings
define('MAX_BIO_LENGTH', 500);
define('DEFAULT_CURRENCY', 'ILS');
define('LISTING_DURATION_DAYS', 30);

// Property Types - All types from property_types table
define('PROPERTY_TYPES', [
    'apartment' => ['ar' => 'شقة', 'en' => 'Apartment', 'he' => 'דירה'],
    'room' => ['ar' => 'غرفة', 'en' => 'Room', 'he' => 'חדר'],
    'studio' => ['ar' => 'استوديو', 'en' => 'Studio', 'he' => 'סטודיו'],
    'villa' => ['ar' => 'فيلا', 'en' => 'Villa', 'he' => 'וילה'],
    'chalet' => ['ar' => 'شاليه', 'en' => 'Chalet', 'he' => 'שאלה'],
    'shop' => ['ar' => 'محل تجاري', 'en' => 'Shop', 'he' => 'חנות'],
    'office' => ['ar' => 'مكتب', 'en' => 'Office', 'he' => 'משרד'],
    'student_housing' => ['ar' => 'سكن طلاب', 'en' => 'Student Housing', 'he' => 'דיור סטודנטים'],
    'land' => ['ar' => 'أرض', 'en' => 'Land', 'he' => 'קרקע'],
    'building' => ['ar' => 'مبنى', 'en' => 'Building', 'he' => 'בניין'],
    'caravans' => ['ar' => 'غرافانات', 'en' => 'Caravans', 'he' => 'קרוואנים'],
]);

// Car Usage Types - All types from car_types table
define('CAR_USAGE_TYPES', [
    'daily' => ['ar' => 'إيجار يومي', 'en' => 'Daily Rental', 'he' => 'השכרה יומית'],
    'wedding' => ['ar' => 'زفاف', 'en' => 'Wedding', 'he' => 'חתונה'],
    'tourism' => ['ar' => 'سياحة', 'en' => 'Tourism', 'he' => 'תיירות'],
    'trips' => ['ar' => 'رحلات', 'en' => 'Trips', 'he' => 'טיולים'],
    'transportation' => ['ar' => 'نقل', 'en' => 'Transportation', 'he' => 'הובלות'],
    'hourly_rental' => ['ar' => 'ايجار بالساعة', 'en' => 'Hourly Rental', 'he' => 'השכרה לשעה'],
]);

// User Types
define('USER_TYPES', [
    'renter' => ['ar' => 'مستأجر', 'en' => 'Renter', 'he' => 'שוכר'],
    'owner' => ['ar' => 'مالك', 'en' => 'Owner', 'he' => 'בעלים'],
    'office' => ['ar' => 'مكتب عقارات', 'en' => 'Real Estate Office', 'he' => 'משרד נדל"ן'],
    'car_lessor' => ['ar' => 'مؤجر سيارات', 'en' => 'Car Lessor', 'he' => 'משכיר רכב'],
]);

// Listing Statuses
define('LISTING_STATUSES', [
    'draft' => ['ar' => 'مسودة', 'en' => 'Draft', 'he' => 'טיוטה'],
    'pending_payment' => ['ar' => 'بانتظار الدفع', 'en' => 'Pending Payment', 'he' => 'ממתין לתשלום'],
    'pending_admin_review' => ['ar' => 'بانتظار المراجعة', 'en' => 'Pending Review', 'he' => 'ממתין לבדיקה'],
    'active' => ['ar' => 'نشط', 'en' => 'Active', 'he' => 'פעיל'],
    'expired' => ['ar' => 'منتهي', 'en' => 'Expired', 'he' => 'פג תוקף'],
    'paused' => ['ar' => 'متوقف', 'en' => 'Paused', 'he' => 'מושהה'],
    'rejected' => ['ar' => 'مرفوض', 'en' => 'Rejected', 'he' => 'נדחה'],
]);

// Languages
define('SUPPORTED_LANGUAGES', ['ar', 'en', 'he']);
define('DEFAULT_LANGUAGE', 'ar');

// RTL Languages
define('RTL_LANGUAGES', ['ar', 'he']);

// Pagination
define('DEFAULT_PAGE_SIZE', 20);
define('MAX_PAGE_SIZE', 100);

// OneSignal Push Notifications
define('ONESIGNAL_APP_ID', '0943d6d4-8fff-4336-97a0-f8dedb66b025');
define('ONESIGNAL_REST_API_KEY', 'os_v2_app_bfb5nvep75btnf5a7dpnwzvqewwb4m2jvqde5snmctrb5nda4k7avztu73vfnqrh5asb3k2ltmqj5hn2xl5w3b6ugk5bf4cnpsx6nhi');
