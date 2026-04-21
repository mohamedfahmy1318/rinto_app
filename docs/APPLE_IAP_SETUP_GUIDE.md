# دليل إعداد Apple In-App Purchases لتطبيق RentoGo

## المتطلبات الأساسية
- حساب Apple Developer نشط ($99/سنة)
- تطبيق مسجل في App Store Connect
- اتفاقيات الدفع موقعة في App Store Connect

---

## الخطوة 1: الدخول إلى App Store Connect

1. اذهب إلى [App Store Connect](https://appstoreconnect.apple.com)
2. سجل الدخول بحساب Apple Developer
3. اختر تطبيق **RentoGo Marketplace**

---

## الخطوة 2: إنشاء In-App Purchase

1. من القائمة الجانبية، اذهب إلى:
   - **MONETIZATION** → **In-App Purchases**

2. اضغط على زر **+** (إضافة)

3. في نافذة الإنشاء، املأ:

| الحقل | القيمة | الشرح |
|-------|--------|-------|
| **Type** | `Consumable` | لأن الباقة تُستهلك مرة واحدة |
| **Reference Name** | اسم وصفي | للإدارة الداخلية فقط |
| **Product ID** | معرّف فريد | يُستخدم في الكود |

4. اضغط **Create**

---

## الخطوة 3: إعداد تفاصيل المنتج

بعد إنشاء المنتج، تحتاج إعداد:

### أ) التسعير (Pricing)
1. اضغط على **Pricing and Availability**
2. اختر **Price** من القائمة
3. حدد السعر بالـ USD (Apple يحوّل تلقائياً للعملات الأخرى)

### ب) الترجمات (Localizations)
1. اضغط على **App Store Localization**
2. أضف الترجمات:
   - **Arabic** (العربية)
   - **English** (الإنجليزية)
   - **Hebrew** (العبرية)

3. لكل لغة، أدخل:
   - **Display Name**: اسم يظهر للمستخدم
   - **Description**: وصف قصير

### ج) صورة المراجعة (Review Screenshot)
1. اضغط على **Review Information**
2. ارفع صورة توضح كيف يظهر الشراء في التطبيق
3. أضف ملاحظات للمراجعين إذا لزم

---

## الخطوة 4: قائمة المنتجات المطلوبة

### باقات العقارات:

| الباقة | Reference Name | Product ID |
|--------|----------------|------------|
| إعلان شقة 7 أيام | Apartment Ad 7 Days | `com.rentogo.app.prop_apt_7d` |
| إعلان شقة 30 يوم | Apartment Ad 30 Days | `com.rentogo.app.prop_apt_30d` |
| إعلان فيلا | Villa Ad | `com.rentogo.app.prop_villa` |
| إعلان محل | Shop Ad | `com.rentogo.app.prop_shop` |
| باقة برونزية | Bronze Package Properties | `com.rentogo.app.prop_bronze` |
| باقة فضية | Silver Package Properties | `com.rentogo.app.prop_silver` |
| باقة ذهبية | Gold Package Properties | `com.rentogo.app.prop_gold` |

### باقات السيارات:

| الباقة | Reference Name | Product ID |
|--------|----------------|------------|
| إعلان سيارة يومية | Daily Car Ad | `com.rentogo.app.cars_daily` |
| إعلان سيارة أعراس | Wedding Car Ad | `com.rentogo.app.cars_wedding` |
| إعلان سيارة سياحية | Tourism Car Ad | `com.rentogo.app.cars_tourism` |
| باقة سيارات برونزية | Bronze Package Cars | `com.rentogo.app.cars_bronze` |
| باقة سيارات فضية | Silver Package Cars | `com.rentogo.app.cars_silver` |
| باقة سيارات ذهبية | Gold Package Cars | `com.rentogo.app.cars_gold` |

---

## الخطوة 5: قواعد كتابة Product ID

### ✅ مسموح:
- أحرف صغيرة: `a-z`
- أرقام: `0-9`
- نقطة: `.`
- شرطة سفلية: `_`

### ❌ ممنوع:
- أحرف كبيرة: `A-Z`
- مسافات
- رموز خاصة: `@#$%`

### صيغة مقترحة:
```
com.rentogo.app.{category}_{type}
```

أمثلة:
- `com.rentogo.app.prop_bronze`
- `com.rentogo.app.cars_gold`
- `com.rentogo.app.prop_apt_7d`

---

## الخطوة 6: إضافة Product ID في لوحة الأدمن

1. افتح لوحة الأدمن: `https://rento-go.com/admin/plans.php`
2. اختر الباقة المراد تعديلها
3. في قسم **In-App Purchase IDs**:
   - أدخل **iOS Product ID** الذي أنشأته في App Store Connect
4. احفظ التغييرات

---

## الخطوة 7: اختبار المنتجات (Sandbox)

### إنشاء حساب Sandbox:
1. في App Store Connect، اذهب إلى **Users and Access**
2. اختر **Sandbox Testers**
3. اضغط **+** لإضافة مختبر جديد
4. أدخل بريد إلكتروني (لا يجب أن يكون Apple ID حقيقي)

### الاختبار:
1. على جهاز iPhone حقيقي (ليس Simulator)
2. سجل خروج من App Store
3. شغل التطبيق وحاول الشراء
4. سيطلب تسجيل الدخول - استخدم حساب Sandbox
5. الشراء سيكون مجاني (للاختبار فقط)

---

## الخطوة 8: تقديم للمراجعة

1. تأكد أن كل منتج له:
   - سعر محدد
   - ترجمات كاملة
   - صورة مراجعة
   
2. حالة المنتج يجب أن تكون **Ready to Submit**

3. عند رفع تحديث التطبيق:
   - في صفحة الإصدار، اختر **In-App Purchases**
   - أضف المنتجات الجديدة للإصدار

---

## ملاحظات مهمة

⚠️ **عمولة Apple**: 30% من كل عملية شراء (15% للتطبيقات التي تربح أقل من $1M سنوياً)

⚠️ **المراجعة**: المنتجات تحتاج مراجعة من Apple قبل النشر

⚠️ **الاتفاقيات**: تأكد من توقيع اتفاقيات الدفع في App Store Connect

⚠️ **الضرائب**: أعد إعدادات الضرائب حسب موقعك

---

## المساعدة

- [دليل Apple الرسمي](https://developer.apple.com/in-app-purchase/)
- [أنواع In-App Purchases](https://developer.apple.com/help/app-store-connect/manage-in-app-purchases/create-in-app-purchases)

---

*آخر تحديث: مارس 2026*
