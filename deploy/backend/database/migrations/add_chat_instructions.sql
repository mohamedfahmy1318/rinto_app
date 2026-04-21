-- Migration: Add chat instructions setting
-- Date: 2026-02-23

INSERT INTO `app_settings` (`setting_key`, `value_ar`, `value_en`, `value_he`, `updated_by`)
VALUES (
    'chat_instructions',
    'تعليمات المحادثة:\n• لا تشارك معلوماتك الشخصية مثل رقم الهوية أو بطاقة الائتمان\n• تأكد من معاينة العقار/السيارة قبل إتمام أي صفقة\n• استخدم طرق الدفع الآمنة فقط\n• أبلغ عن أي سلوك مشبوه',
    'Chat Guidelines:\n• Do not share personal information like ID or credit card numbers\n• Make sure to inspect the property/car before completing any deal\n• Use secure payment methods only\n• Report any suspicious behavior',
    'הנחיות צאט:\n• אל תשתפו מידע אישי כמו תעודת זהות או כרטיס אשראי\n• ודאו שאתם בודקים את הנכס/רכב לפני סגירת עסקה\n• השתמשו רק באמצעי תשלום מאובטחים\n• דווחו על כל התנהגות חשודה',
    1
)
ON DUPLICATE KEY UPDATE 
    value_ar = VALUES(value_ar),
    value_en = VALUES(value_en),
    value_he = VALUES(value_he);
