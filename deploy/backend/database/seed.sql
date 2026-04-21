-- Rento Go - بيانات وهمية للاختبار
-- Run this after schema.sql

-- =====================================================
-- المستخدمين
-- =====================================================
INSERT INTO users (name, email, phone, password, user_type, is_verified_phone, is_verified_email, is_trusted, created_at) VALUES
('أحمد محمد', 'ahmed@test.com', '+972501234567', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'renter', 1, 1, 0, NOW()),
('سارة أحمد', 'sara@test.com', '+972502345678', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'renter', 1, 1, 0, NOW()),
('محمد علي', 'mohamed@test.com', '+972503456789', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'renter', 1, 1, 0, NOW()),
('عبدالله العمري', 'abdullah@test.com', '+972504567890', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'owner', 1, 1, 1, NOW()),
('فاطمة حسن', 'fatima@test.com', '+972505678901', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'owner', 1, 1, 1, NOW()),
('خالد الشمري', 'khaled@test.com', '+972506789012', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'owner', 1, 1, 0, NOW()),
('يوسف الزهراني', 'yousef@test.com', '+972507890123', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'car_lessor', 1, 1, 1, NOW()),
('نورة السالم', 'noura@test.com', '+972508901234', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'car_lessor', 1, 1, 0, NOW()),
('مكتب الأمانة العقاري', 'amana@test.com', '+972509012345', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'office', 1, 1, 1, NOW()),
('مكتب النجاح للعقارات', 'najah@test.com', '+972500123456', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'office', 1, 1, 1, NOW());

-- =====================================================
-- العقارات
-- =====================================================
INSERT INTO properties (user_id, region_id, city_id, property_type, title_ar, title_en, title_he, description_ar, price, currency, bedrooms, bathrooms, area_m2, furnished, amenities, latitude, longitude, status, created_at, expires_at) VALUES

-- شقق
(4, 1, 1, 'apartment', 'شقة فاخرة في وسط المدينة', 'Luxury apartment downtown', 'דירת יוקרה במרכז העיר', 'شقة مميزة بإطلالة رائعة، قريبة من جميع الخدمات', 3500, 'ILS', 3, 2, 120, 'furnished', '["wifi","ac","parking","elevator"]', 31.7683, 35.2137, 'active', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),

(4, 1, 2, 'apartment', 'شقة عائلية واسعة', 'Spacious family apartment', 'דירה משפחתית מרווחת', 'شقة مناسبة للعائلات، 4 غرف نوم مع صالة كبيرة', 4200, 'ILS', 4, 2, 150, 'semi_furnished', '["wifi","ac","parking"]', 31.8928, 34.8113, 'active', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),

(5, 2, 3, 'apartment', 'استوديو مفروش بالكامل', 'Fully furnished studio', 'סטודיו מרוהט במלואו', 'استوديو حديث مجهز بالكامل للإيجار الشهري', 2000, 'ILS', 1, 1, 45, 'furnished', '["wifi","ac"]', 32.0853, 34.7818, 'active', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),

(5, 2, 4, 'apartment', 'شقة طلابية قرب الجامعة', 'Student apartment near university', 'דירת סטודנטים ליד האוניברסיטה', 'شقة مثالية للطلاب، قريبة من الجامعة والمواصلات', 1800, 'ILS', 2, 1, 65, 'furnished', '["wifi","ac","laundry"]', 32.1133, 34.8044, 'active', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),

(9, 1, 1, 'apartment', 'شقة جديدة تشطيب سوبر ديلوكس', 'New super deluxe apartment', 'דירה חדשה גימור סופר דלוקס', 'شقة جديدة لم تسكن من قبل، تشطيب فاخر', 5000, 'ILS', 3, 2, 130, 'unfurnished', '["ac","parking","elevator","security"]', 31.7789, 35.2256, 'active', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),

-- فلل وشاليهات
(4, 3, 5, 'villa', 'فيلا فاخرة مع مسبح خاص', 'Luxury villa with private pool', 'וילת יוקרה עם בריכה פרטית', 'فيلا راقية مع حديقة ومسبح، مناسبة للعائلات', 12000, 'ILS', 5, 4, 350, 'furnished', '["wifi","ac","parking","pool","garden","security"]', 32.7940, 34.9896, 'active', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),

(9, 3, 6, 'chalet', 'شاليه على البحر مباشرة', 'Beachfront chalet', 'שאלה על החוף', 'شاليه رائع بإطلالة مباشرة على البحر', 8000, 'ILS', 3, 2, 150, 'furnished', '["wifi","ac","parking","beach_access"]', 32.8191, 34.9983, 'active', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),

(10, 2, 3, 'villa', 'فيلا عصرية في حي راقي', 'Modern villa in upscale neighborhood', 'וילה מודרנית בשכונה יוקרתית', 'فيلا بتصميم عصري في أفضل الأحياء', 15000, 'ILS', 6, 5, 450, 'furnished', '["wifi","ac","parking","pool","garden","gym","security"]', 32.0927, 34.7873, 'active', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),

-- محلات ومكاتب
(5, 1, 1, 'shop', 'محل تجاري في موقع استراتيجي', 'Commercial shop in strategic location', 'חנות מסחרית במיקום אסטרטגי', 'محل بواجهة زجاجية كبيرة على الشارع الرئيسي', 6000, 'ILS', 0, 1, 80, 'unfurnished', '["ac","parking"]', 31.7700, 35.2100, 'active', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),

(10, 2, 4, 'office', 'مكتب مجهز في برج تجاري', 'Equipped office in business tower', 'משרד מאובזר במגדל עסקים', 'مكتب جاهز للاستخدام مع قاعة اجتماعات', 4500, 'ILS', 0, 2, 100, 'furnished', '["wifi","ac","parking","elevator","security"]', 32.1000, 34.8100, 'active', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),

-- سكن طلابي
(6, 2, 3, 'student_housing', 'غرفة في سكن طلابي مشترك', 'Room in shared student housing', 'חדר בדיור סטודנטים משותף', 'غرفة مفروشة في شقة مشتركة مع طلاب', 1200, 'ILS', 1, 1, 20, 'furnished', '["wifi","ac","laundry","kitchen"]', 32.0800, 34.7700, 'active', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),

(6, 1, 2, 'student_housing', 'سكن طلابي قرب الكلية', 'Student housing near college', 'דיור סטודנטים ליד המכללה', 'سكن مخصص للطلاب مع جميع المرافق', 1500, 'ILS', 1, 1, 25, 'furnished', '["wifi","ac","laundry","study_room"]', 31.9000, 34.8200, 'active', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),

-- أراضي
(4, 3, 5, 'land', 'أرض للإيجار صالحة للزراعة', 'Agricultural land for rent', 'קרקע חקלאית להשכרה', 'أرض واسعة مع مصدر مياه، مناسبة للمشاريع الزراعية', 3000, 'ILS', 0, 0, 5000, 'unfurnished', '["water_source"]', 32.8000, 35.0000, 'active', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),

(9, 1, 1, 'land', 'أرض تجارية في موقع مميز', 'Commercial land in prime location', 'קרקע מסחרית במיקום מעולה', 'أرض مناسبة لمشروع تجاري أو مخزن', 8000, 'ILS', 0, 0, 2000, 'unfurnished', '["road_access"]', 31.7800, 35.2300, 'active', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY));

-- =====================================================
-- السيارات
-- =====================================================
INSERT INTO cars (user_id, region_id, city_id, car_type, brand, model, year, color, gearbox, fuel_type, seats, title_ar, title_en, title_he, description_ar, price_daily, price_weekly, price_monthly, currency, mileage_limit, status, created_at, expires_at) VALUES

-- سيارات للاستخدام اليومي
(7, 1, 1, 'daily_use', 'Toyota', 'Corolla', 2023, 'أبيض', 'automatic', 'petrol', 5, 'تويوتا كورولا 2023 للإيجار اليومي', 'Toyota Corolla 2023 for daily rent', 'טויוטה קורולה 2023 להשכרה יומית', 'سيارة اقتصادية مناسبة للتنقل اليومي', 150, 900, 3000, 'ILS', 200, 'active', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),

(7, 2, 3, 'daily_use', 'Hyundai', 'Elantra', 2022, 'فضي', 'automatic', 'petrol', 5, 'هيونداي النترا موديل 2022', 'Hyundai Elantra 2022', 'יונדאי אלנטרה 2022', 'سيارة عائلية مريحة وموفرة للوقود', 140, 850, 2800, 'ILS', 200, 'active', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),

(8, 1, 2, 'daily_use', 'Kia', 'Sportage', 2023, 'أسود', 'automatic', 'petrol', 5, 'كيا سبورتاج SUV 2023', 'Kia Sportage SUV 2023', 'קיה ספורטאז\' SUV 2023', 'سيارة دفع رباعي مناسبة للعائلات', 200, 1200, 4000, 'ILS', 250, 'active', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),

(10, 2, 4, 'daily_use', 'Mazda', 'CX-5', 2022, 'أحمر', 'automatic', 'petrol', 5, 'مازدا CX-5 فل كامل', 'Mazda CX-5 Full Option', 'מאזדה CX-5 פול', 'سيارة أنيقة بمواصفات عالية', 220, 1300, 4500, 'ILS', 200, 'active', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),

-- سيارات أعراس
(7, 1, 1, 'wedding', 'Mercedes', 'S-Class', 2023, 'أبيض لؤلؤي', 'automatic', 'petrol', 5, 'مرسيدس S-Class للأعراس', 'Mercedes S-Class for weddings', 'מרצדס S-Class לחתונות', 'سيارة فاخرة للأعراس والمناسبات الخاصة مع سائق', 800, NULL, NULL, 'ILS', 100, 'active', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),

(8, 2, 3, 'wedding', 'BMW', '7 Series', 2022, 'أسود', 'automatic', 'petrol', 5, 'بي ام دبليو الفئة السابعة للمناسبات', 'BMW 7 Series for events', 'ב.מ.וו סדרה 7 לאירועים', 'سيارة فارهة للأعراس مع زينة كاملة', 750, NULL, NULL, 'ILS', 100, 'active', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),

(10, 1, 1, 'wedding', 'Rolls Royce', 'Ghost', 2021, 'أبيض', 'automatic', 'petrol', 5, 'رولز رويس جوست للأعراس الملكية', 'Rolls Royce Ghost for royal weddings', 'רולס רויס גוסט לחתונות מלכותיות', 'أفخم سيارة للأعراس، تجربة ملكية لا تنسى', 1500, NULL, NULL, 'ILS', 50, 'active', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),

-- سيارات سياحية
(7, 3, 5, 'tourism', 'Toyota', 'Land Cruiser', 2023, 'بيج', 'automatic', 'diesel', 7, 'تويوتا لاند كروزر للرحلات', 'Toyota Land Cruiser for trips', 'טויוטה לנד קרוזר לטיולים', 'سيارة دفع رباعي مثالية للرحلات والسفاري', 350, 2000, 7000, 'ILS', 300, 'active', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),

(8, 3, 6, 'tourism', 'Jeep', 'Wrangler', 2022, 'أخضر', 'automatic', 'petrol', 5, 'جيب رانجلر للمغامرات', 'Jeep Wrangler for adventures', 'ג\'יפ רנגלר להרפתקאות', 'سيارة مثالية للطرق الوعرة والتخييم', 300, 1800, 6000, 'ILS', 250, 'active', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY)),

(10, 1, 1, 'tourism', 'Mercedes', 'V-Class', 2023, 'أسود', 'automatic', 'diesel', 7, 'مرسيدس V-Class للسياحة العائلية', 'Mercedes V-Class for family tourism', 'מרצדס V-Class לתיירות משפחתית', 'فان فاخر يتسع لـ 7 أشخاص مع أمتعة', 400, 2500, 8000, 'ILS', 300, 'active', NOW(), DATE_ADD(NOW(), INTERVAL 30 DAY));

-- =====================================================
-- الوسائط (صور وهمية - URLs خارجية للاختبار)
-- =====================================================
INSERT INTO media (listing_type, listing_id, media_type, file_path, is_primary, sort_order) VALUES
-- صور العقارات
('property', 1, 'image', 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800', 1, 1),
('property', 1, 'image', 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800', 0, 2),
('property', 2, 'image', 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800', 1, 1),
('property', 2, 'image', 'https://images.unsplash.com/photo-1560185007-cde436f6a4d0?w=800', 0, 2),
('property', 3, 'image', 'https://images.unsplash.com/photo-1536376072261-38c75010e6c9?w=800', 1, 1),
('property', 4, 'image', 'https://images.unsplash.com/photo-1554995207-c18c203602cb?w=800', 1, 1),
('property', 5, 'image', 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800', 1, 1),
('property', 6, 'image', 'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800', 1, 1),
('property', 6, 'image', 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800', 0, 2),
('property', 7, 'image', 'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2?w=800', 1, 1),
('property', 8, 'image', 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800', 1, 1),
('property', 9, 'image', 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800', 1, 1),
('property', 10, 'image', 'https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=800', 1, 1),
('property', 11, 'image', 'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=800', 1, 1),
('property', 12, 'image', 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=800', 1, 1),
('property', 13, 'image', 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800', 1, 1),
('property', 14, 'image', 'https://images.unsplash.com/photo-1628624747186-a941c476b7ef?w=800', 1, 1),

-- صور السيارات
('car', 1, 'image', 'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800', 1, 1),
('car', 2, 'image', 'https://images.unsplash.com/photo-1580273916550-e323be2ae537?w=800', 1, 1),
('car', 3, 'image', 'https://images.unsplash.com/photo-1606611013016-969c19ba27bb?w=800', 1, 1),
('car', 4, 'image', 'https://images.unsplash.com/photo-1612825173281-9a193378527e?w=800', 1, 1),
('car', 5, 'image', 'https://images.unsplash.com/photo-1618843479313-40f8afb4b4d8?w=800', 1, 1),
('car', 6, 'image', 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800', 1, 1),
('car', 7, 'image', 'https://images.unsplash.com/photo-1631295868223-63265b40d9e4?w=800', 1, 1),
('car', 8, 'image', 'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=800', 1, 1),
('car', 9, 'image', 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=800', 1, 1),
('car', 10, 'image', 'https://images.unsplash.com/photo-1609521263047-f8f205293f24?w=800', 1, 1);

-- =====================================================
-- المفضلة
-- =====================================================
INSERT INTO favorites (user_id, listing_type, listing_id) VALUES
(1, 'property', 1),
(1, 'property', 6),
(1, 'car', 1),
(2, 'property', 2),
(2, 'property', 8),
(2, 'car', 5),
(3, 'property', 3),
(3, 'car', 8);

-- =====================================================
-- الإشعارات
-- =====================================================
INSERT INTO notifications (user_id, title_ar, title_en, body_ar, body_en, notification_type, is_read, created_at) VALUES
(1, 'مرحباً بك في رينتو جو!', 'Welcome to Rento Go!', 'شكراً لانضمامك إلينا. استكشف أفضل العقارات والسيارات للإيجار.', 'Thank you for joining us. Explore the best properties and cars for rent.', 'general', 0, NOW()),
(4, 'تمت الموافقة على إعلانك', 'Your listing is approved', 'تهانينا! تم الموافقة على إعلان "شقة فاخرة في وسط المدينة"', 'Congratulations! Your listing "Luxury apartment downtown" has been approved', 'listing_approved', 0, NOW()),
(7, 'لديك حجز جديد', 'You have a new booking', 'قام مستخدم بحجز سيارتك تويوتا كورولا', 'A user has booked your Toyota Corolla', 'general', 0, NOW());

-- =====================================================
-- تم إنشاء البيانات الوهمية بنجاح!
-- =====================================================
SELECT 'تم إدخال البيانات الوهمية بنجاح!' AS message;
SELECT COUNT(*) AS total_users FROM users;
SELECT COUNT(*) AS total_properties FROM properties;
SELECT COUNT(*) AS total_cars FROM cars;
SELECT COUNT(*) AS total_media FROM media;
