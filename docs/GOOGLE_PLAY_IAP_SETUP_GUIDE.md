# دليل إعداد Google Play In-App Purchases لتطبيق RentoGo

## المتطلبات الأساسية
- حساب Google Play Developer نشط ($25 مرة واحدة)
- تطبيق مسجل في Google Play Console
- حساب تاجر Google Play مُعد

---

## الخطوة 1: إعداد Google Cloud Console

### إنشاء Service Account:

1. اذهب إلى [Google Cloud Console](https://console.cloud.google.com)
2. اختر مشروعك أو أنشئ مشروع جديد
3. فعّل **Google Play Android Developer API**:
   - اذهب إلى APIs & Services → Library
   - ابحث عن "Google Play Android Developer API"
   - اضغط Enable

4. أنشئ Service Account:
   - اذهب إلى IAM & Admin → Service Accounts
   - اضغط **Create Service Account**
   - أدخل اسم مثل: `rentogo-iap-verifier`
   - اضغط Create and Continue
   - لا تحتاج لإضافة أدوار هنا
   - اضغط Done

5. إنشاء مفتاح JSON:
   - اضغط على Service Account الذي أنشأته
   - اذهب إلى تبويب **Keys**
   - اضغط **Add Key** → **Create new key**
   - اختر **JSON**
   - سيتم تحميل الملف تلقائياً

---

## الخطوة 2: ربط Service Account بـ Google Play Console

1. اذهب إلى [Google Play Console](https://play.google.com/console)
2. اذهب إلى **Users and permissions**
3. اضغط **Invite new users**
4. أدخل بريد Service Account (ينتهي بـ `@*.iam.gserviceaccount.com`)
5. في Permissions، اختر:
   - **View app information and download bulk reports**
   - **View financial data, orders, and cancellation survey responses**
   - **Manage orders and subscriptions**
6. اضغط **Invite user**

> ⚠️ **ملاحظة**: قد يستغرق تفعيل الصلاحيات 24-48 ساعة

---

## الخطوة 3: إنشاء In-App Products

1. في Google Play Console، اختر تطبيقك
2. اذهب إلى **Monetize** → **In-app products**
3. اضغط **Create product**

4. املأ التفاصيل:

| الحقل | الوصف |
|-------|-------|
| **Product ID** | معرّف فريد (لا يمكن تغييره لاحقاً) |
| **Name** | اسم المنتج (يظهر للمستخدم) |
| **Description** | وصف قصير |
| **Default price** | السعر الافتراضي |

5. اضغط **Save** ثم **Activate**

---

## الخطوة 4: قائمة المنتجات المقترحة

### باقات العقارات:

| الباقة | Product ID |
|--------|------------|
| إعلان شقة 7 أيام | `prop_apt_7d` |
| إعلان شقة 30 يوم | `prop_apt_30d` |
| إعلان فيلا | `prop_villa` |
| إعلان محل | `prop_shop` |
| باقة برونزية | `prop_bronze` |
| باقة فضية | `prop_silver` |
| باقة ذهبية | `prop_gold` |

### باقات السيارات:

| الباقة | Product ID |
|--------|------------|
| إعلان سيارة يومية | `cars_daily` |
| إعلان سيارة أعراس | `cars_wedding` |
| إعلان سيارة سياحية | `cars_tourism` |
| باقة سيارات برونزية | `cars_bronze` |
| باقة سيارات فضية | `cars_silver` |
| باقة سيارات ذهبية | `cars_gold` |

---

## الخطوة 5: قواعد كتابة Product ID

### ✅ مسموح:
- أحرف صغيرة: `a-z`
- أرقام: `0-9`
- شرطة سفلية: `_`
- نقطة: `.`

### ❌ ممنوع:
- أحرف كبيرة
- مسافات
- بدء بـ `android.test`

### ⚠️ مهم:
- **Product ID لا يمكن تغييره بعد الإنشاء**
- **Product ID لا يمكن إعادة استخدامه حتى بعد الحذف**

---

## الخطوة 6: إعداد لوحة التحكم

1. افتح لوحة الأدمن: `https://rento-go.com/admin/iap-settings.php`
2. في قسم **Google Play Billing**:
   - انسخ محتوى ملف JSON والصقه في حقل Service Account JSON
   - فعّل/أوقف وضع Sandbox حسب الحاجة
3. احفظ الإعدادات

4. اذهب إلى **الباقات والأسعار**:
   - حرّر كل باقة
   - أدخل **Android Product ID** المطابق

---

## الخطوة 7: الاختبار

### إعداد License Testing:

1. في Google Play Console:
   - اذهب إلى **Settings** → **License testing**
   - أضف بريد إلكتروني للمختبرين
   
2. المختبرون يمكنهم الشراء مجاناً للاختبار

### اختبار داخلي:

1. أنشئ **Internal testing track**
2. ارفع APK/AAB
3. أضف المختبرين
4. انتظر بضع ساعات للنشر
5. المختبرون يثبتون من رابط الاختبار

---

## الخطوة 8: النشر

### قبل النشر:
- ✅ جميع المنتجات في حالة **Active**
- ✅ Service Account مربوط ومفعل
- ✅ إعدادات لوحة التحكم صحيحة
- ✅ اختبار الشراء ناجح

### عند النشر:
1. أوقف وضع Sandbox في لوحة التحكم
2. ارفع الإصدار إلى Production
3. راقب المدفوعات في لوحة التحكم

---

## ملاحظات مهمة

⚠️ **عمولة Google**: 15% لأول $1M سنوياً، ثم 30%

⚠️ **الإيرادات**: تظهر في Google Play Console → Financial reports

⚠️ **الاسترداد**: المستخدم يمكنه طلب استرداد خلال 48 ساعة

⚠️ **التأخير**: قد يستغرق تفعيل Service Account حتى 48 ساعة

---

## استكشاف الأخطاء

### "Service account not found":
- تأكد من إضافة البريد الصحيح لـ Service Account
- انتظر 24-48 ساعة

### "Product not found":
- تأكد أن المنتج في حالة Active
- تأكد من تطابق Product ID

### "Purchase failed":
- تأكد من تثبيت التطبيق من Google Play (ليس APK مباشر)
- تأكد من حساب Google مُعد للدفع

---

## المساعدة

- [دليل Google الرسمي](https://developer.android.com/google/play/billing)
- [Android Publisher API](https://developers.google.com/android-publisher)

---

*آخر تحديث: مارس 2026*
