-- Rento Go - بيانات وهمية للاختبار
-- يطابق هيكل schema.sql

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
-- العقارات - properties
-- property_type: apartment, shop_office, villa_chalet, student_housing, land
-- =====================================================
INSERT INTO properties (user_id, property_type, region_id, city_id, title, bio, price, currency, bedrooms, bathrooms, area_m2, contact_phone, status, expires_at, created_at) VALUES
(4, 'apartment', 1, 1, 'شقة فاخرة في وسط المدينة', 'شقة مميزة بإطلالة رائعة، قريبة من جميع الخدمات، 3 غرف نوم مع صالة واسعة', 3500, 'ILS', 3, 2, 120, '+972504567890', 'active', DATE_ADD(NOW(), INTERVAL 30 DAY), NOW()),
(4, 'apartment', 1, 2, 'شقة عائلية واسعة', 'شقة مناسبة للعائلات، 4 غرف نوم مع صالة كبيرة وبلكونة', 4200, 'ILS', 4, 2, 150, '+972504567890', 'active', DATE_ADD(NOW(), INTERVAL 30 DAY), NOW()),
(5, 'apartment', 2, 5, 'استوديو مفروش بالكامل', 'استوديو حديث مجهز بالكامل للإيجار الشهري، مناسب للعزاب', 2000, 'ILS', 1, 1, 45, '+972505678901', 'active', DATE_ADD(NOW(), INTERVAL 30 DAY), NOW()),
(5, 'student_housing', 2, 6, 'سكن طلابي قرب الجامعة', 'غرفة مفروشة في شقة مشتركة، قريبة من الجامعة والمواصلات', 1200, 'ILS', 1, 1, 20, '+972505678901', 'active', DATE_ADD(NOW(), INTERVAL 30 DAY), NOW()),
(6, 'apartment', 1, 3, 'شقة جديدة تشطيب سوبر ديلوكس', 'شقة جديدة لم تسكن من قبل، تشطيب فاخر مع مصعد وموقف سيارة', 5000, 'ILS', 3, 2, 130, '+972506789012', 'active', DATE_ADD(NOW(), INTERVAL 30 DAY), NOW()),
(9, 'villa_chalet', 3, 9, 'فيلا فاخرة مع مسبح خاص', 'فيلا راقية مع حديقة ومسبح، مناسبة للعائلات الكبيرة', 12000, 'ILS', 5, 4, 350, '+972509012345', 'active', DATE_ADD(NOW(), INTERVAL 30 DAY), NOW()),
(9, 'villa_chalet', 3, 10, 'شاليه على البحر مباشرة', 'شاليه رائع بإطلالة مباشرة على البحر، مثالي للعطلات', 8000, 'ILS', 3, 2, 150, '+972509012345', 'active', DATE_ADD(NOW(), INTERVAL 30 DAY), NOW()),
(10, 'shop_office', 1, 1, 'محل تجاري في موقع استراتيجي', 'محل بواجهة زجاجية كبيرة على الشارع الرئيسي، موقع ممتاز', 6000, 'ILS', 0, 1, 80, '+972500123456', 'active', DATE_ADD(NOW(), INTERVAL 30 DAY), NOW()),
(10, 'shop_office', 2, 5, 'مكتب مجهز في برج تجاري', 'مكتب جاهز للاستخدام مع قاعة اجتماعات ومطبخ صغير', 4500, 'ILS', 0, 2, 100, '+972500123456', 'active', DATE_ADD(NOW(), INTERVAL 30 DAY), NOW()),
(4, 'land', 3, 11, 'أرض للإيجار صالحة للزراعة', 'أرض واسعة مع مصدر مياه، مناسبة للمشاريع الزراعية', 3000, 'ILS', 0, 0, 5000, '+972504567890', 'active', DATE_ADD(NOW(), INTERVAL 30 DAY), NOW()),
(5, 'student_housing', 2, 6, 'غرفة في سكن طلابي مشترك', 'غرفة مفروشة مع إنترنت ومرافق مشتركة', 1500, 'ILS', 1, 1, 25, '+972505678901', 'active', DATE_ADD(NOW(), INTERVAL 30 DAY), NOW()),
(6, 'apartment', 1, 4, 'شقة للإيجار بسعر مناسب', 'شقة نظيفة ومرتبة في منطقة هادئة', 2800, 'ILS', 2, 1, 85, '+972506789012', 'active', DATE_ADD(NOW(), INTERVAL 30 DAY), NOW());

-- =====================================================
-- السيارات - cars
-- usage_type: daily, wedding, tourism
-- =====================================================
INSERT INTO cars (user_id, usage_type, model, year, gearbox, with_driver, region_id, city_id, title, bio, price, currency, contact_phone, status, expires_at, created_at) VALUES
(7, 'daily', 'Toyota Corolla 2023', 2023, 'automatic', 0, 1, 1, 'تويوتا كورولا 2023 للإيجار', 'سيارة اقتصادية مناسبة للتنقل اليومي، نظيفة ومكيفة', 150, 'ILS', '+972507890123', 'active', DATE_ADD(NOW(), INTERVAL 30 DAY), NOW()),
(7, 'daily', 'Hyundai Elantra 2022', 2022, 'automatic', 0, 2, 5, 'هيونداي النترا موديل 2022', 'سيارة عائلية مريحة وموفرة للوقود', 140, 'ILS', '+972507890123', 'active', DATE_ADD(NOW(), INTERVAL 30 DAY), NOW()),
(8, 'daily', 'Kia Sportage 2023', 2023, 'automatic', 0, 1, 2, 'كيا سبورتاج SUV 2023', 'سيارة دفع رباعي مناسبة للعائلات والرحلات', 200, 'ILS', '+972508901234', 'active', DATE_ADD(NOW(), INTERVAL 30 DAY), NOW()),
(8, 'daily', 'Mazda CX-5 2022', 2022, 'automatic', 0, 2, 6, 'مازدا CX-5 فل كامل', 'سيارة أنيقة بمواصفات عالية وتجهيزات كاملة', 220, 'ILS', '+972508901234', 'active', DATE_ADD(NOW(), INTERVAL 30 DAY), NOW()),
(7, 'wedding', 'Mercedes S-Class 2023', 2023, 'automatic', 1, 1, 1, 'مرسيدس S-Class للأعراس', 'سيارة فاخرة للأعراس والمناسبات الخاصة مع سائق محترف', 800, 'ILS', '+972507890123', 'active', DATE_ADD(NOW(), INTERVAL 30 DAY), NOW()),
(8, 'wedding', 'BMW 7 Series 2022', 2022, 'automatic', 1, 2, 5, 'بي ام دبليو الفئة السابعة', 'سيارة فارهة للأعراس مع زينة كاملة وسائق', 750, 'ILS', '+972508901234', 'active', DATE_ADD(NOW(), INTERVAL 30 DAY), NOW()),
(10, 'wedding', 'Rolls Royce Ghost 2021', 2021, 'automatic', 1, 1, 1, 'رولز رويس للأعراس الملكية', 'أفخم سيارة للأعراس، تجربة ملكية لا تنسى', 1500, 'ILS', '+972500123456', 'active', DATE_ADD(NOW(), INTERVAL 30 DAY), NOW()),
(7, 'tourism', 'Toyota Land Cruiser 2023', 2023, 'automatic', 1, 3, 9, 'لاند كروزر للرحلات السياحية', 'سيارة دفع رباعي مثالية للرحلات والسفاري مع سائق', 350, 'ILS', '+972507890123', 'active', DATE_ADD(NOW(), INTERVAL 30 DAY), NOW()),
(8, 'tourism', 'Jeep Wrangler 2022', 2022, 'automatic', 0, 3, 10, 'جيب رانجلر للمغامرات', 'سيارة مثالية للطرق الوعرة والتخييم', 300, 'ILS', '+972508901234', 'active', DATE_ADD(NOW(), INTERVAL 30 DAY), NOW()),
(10, 'tourism', 'Mercedes V-Class 2023', 2023, 'automatic', 1, 1, 1, 'مرسيدس V-Class للسياحة', 'فان فاخر يتسع لـ 7 أشخاص مع أمتعة، مثالي للمجموعات', 400, 'ILS', '+972500123456', 'active', DATE_ADD(NOW(), INTERVAL 30 DAY), NOW());

-- =====================================================
-- صور العقارات - property_media
-- =====================================================
INSERT INTO property_media (property_id, media_type, file_path, sort_order) VALUES
(1, 'image', 'sample.png', 1),
(2, 'image', 'sample.png', 1),
(3, 'image', 'sample.png', 1),
(4, 'image', 'sample.png', 1),
(5, 'image', 'sample.png', 1),
(6, 'image', 'sample.png', 1),
(7, 'image', 'sample.png', 1),
(8, 'image', 'sample.png', 1),
(9, 'image', 'sample.png', 1),
(10, 'image', 'sample.png', 1),
(11, 'image', 'sample.png', 1),
(12, 'image', 'sample.png', 1);

-- =====================================================
-- صور السيارات - car_media
-- =====================================================
INSERT INTO car_media (car_id, media_type, file_path, sort_order) VALUES
(1, 'image', 'sample.png', 1),
(2, 'image', 'sample.png', 1),
(3, 'image', 'sample.png', 1),
(4, 'image', 'sample.png', 1),
(5, 'image', 'sample.png', 1),
(6, 'image', 'sample.png', 1),
(7, 'image', 'sample.png', 1),
(8, 'image', 'sample.png', 1),
(9, 'image', 'sample.png', 1),
(10, 'image', 'sample.png', 1);

-- =====================================================
-- المفضلة
-- =====================================================
INSERT INTO favorites (user_id, listing_type, listing_id) VALUES
(1, 'property', 1),
(1, 'property', 6),
(1, 'car', 1),
(2, 'property', 2),
(2, 'property', 7),
(2, 'car', 5),
(3, 'property', 3),
(3, 'car', 8);

-- =====================================================
-- الإشعارات
-- type: listing_approved, listing_rejected, subscription_expiring, subscription_expired, general
-- =====================================================
INSERT INTO notifications (user_id, title_ar, title_en, title_he, body_ar, body_en, body_he, type, is_read, created_at) VALUES
(1, 'مرحباً بك في رينتو جو!', 'Welcome to Rento Go!', 'ברוכים הבאים לרנטו גו!', 'شكراً لانضمامك إلينا. استكشف أفضل العقارات والسيارات للإيجار.', 'Thank you for joining us. Explore the best properties and cars for rent.', 'תודה שהצטרפת אלינו. גלה את הנכסים והמכוניות הטובים ביותר להשכרה.', 'general', 0, NOW()),
(4, 'تمت الموافقة على إعلانك', 'Your listing is approved', 'המודעה שלך אושרה', 'تهانينا! تم الموافقة على إعلان شقة فاخرة في وسط المدينة', 'Congratulations! Your listing has been approved', 'מזל טוב! המודעה שלך אושרה', 'listing_approved', 0, NOW()),
(7, 'لديك استفسار جديد', 'You have a new inquiry', 'יש לך פנייה חדשה', 'قام مستخدم بالاستفسار عن سيارتك تويوتا كورولا', 'A user has inquired about your Toyota Corolla', 'משתמש התעניין בטויוטה קורולה שלך', 'general', 0, NOW());
