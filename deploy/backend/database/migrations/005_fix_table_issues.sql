-- Migration 005: Fix table issues found during code review
-- Date: 2026-03-31
-- Execute these queries on the production database

-- =====================================================
-- 1. Fix plate_color enum: add 'green' (Flutter allows it, DB doesn't)
-- =====================================================
ALTER TABLE `cars` 
MODIFY COLUMN `plate_color` enum('yellow','white','green') DEFAULT 'yellow';

-- =====================================================
-- 2. Fix property_types slug for villa (has space + capital letter)
--    Current: 'villa or Chalet' → Should be: 'villa_chalet'
-- =====================================================
UPDATE `property_types` SET `slug` = 'villa_chalet' WHERE `id` = 4;

-- =====================================================
-- 3. Fix plans with wrong property_type_id
-- =====================================================

-- Plan #12 "إعلان استوديو – أسبوع" has property_type_id=1 (apartment)
-- Should be property_type_id=3 (studio)
UPDATE `plans` SET `property_type_id` = 3 WHERE `id` = 12;

-- Plan #15 "إعلان استوديو – شهر" has property_type_id=NULL
-- Should be property_type_id=3 (studio)
UPDATE `plans` SET `property_type_id` = 3 WHERE `id` = 15;

-- Plan #23 "إعلان مبنى – شهر" has property_type_id=NULL
-- Should be property_type_id=10 (building)
UPDATE `plans` SET `property_type_id` = 10 WHERE `id` = 23;

-- =====================================================
-- 4. Fix Plan #33 duration_days: 30 → 7
--    "إعلان سيارة إيجار بالساعة – أسبوع" says "أسبوع" but has 30 days
-- =====================================================
UPDATE `plans` SET `duration_days` = 7 WHERE `id` = 33;

-- =====================================================
-- VERIFICATION QUERIES (run after to confirm):
-- =====================================================
-- SELECT column_type FROM information_schema.columns WHERE table_name='cars' AND column_name='plate_color';
-- SELECT id, slug FROM property_types WHERE id = 4;
-- SELECT id, name_ar, property_type_id, duration_days FROM plans WHERE id IN (12, 15, 23, 33);
