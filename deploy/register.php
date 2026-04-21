<?php
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/includes/translations.php';

$pageTitle = __('register');

$error = '';
$success = '';
$showWelcomeModal = false;

// User types with translations
$userTypes = [
    'renter' => ['ar' => 'مستأجر', 'he' => 'שוכר', 'en' => 'Renter'],
    'owner' => ['ar' => 'مالك عقار', 'he' => 'בעל נכס', 'en' => 'Property Owner'],
    'office' => ['ar' => 'مكتب عقارات', 'he' => 'משרד נדל"ן', 'en' => 'Real Estate Office'],
    'car_lessor' => ['ar' => 'مؤجر سيارات', 'he' => 'משכיר רכב', 'en' => 'Car Lessor']
];

// Get regions for dropdown
$regions = apiCall('regions')['data'] ?? [];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name = $_POST['name'] ?? '';
    $phone = $_POST['phone'] ?? '';
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';
    $confirmPassword = $_POST['confirm_password'] ?? '';
    $userType = $_POST['user_type'] ?? 'renter';
    $regionId = $_POST['region_id'] ?? null;
    $cityId = $_POST['city_id'] ?? null;
    
    // Validation
    if ($password !== $confirmPassword) {
        $error = $lang === 'he' ? 'הסיסמאות לא תואמות' : ($lang === 'en' ? 'Passwords do not match' : 'كلمتا المرور غير متطابقتين');
    } elseif (empty($regionId) || empty($cityId)) {
        $error = $lang === 'he' ? 'יש לבחור אזור ועיר' : ($lang === 'en' ? 'Please select region and city' : 'يرجى اختيار المنطقة والمدينة');
    } else {
        $response = apiCall('auth/register', 'POST', [
            'name' => $name,
            'phone' => $phone,
            'email' => $email,
            'password' => $password,
            'user_type' => $userType,
            'region_id' => $regionId,
            'city_id' => $cityId
        ]);
        
        if ($response['success'] ?? false) {
            $_SESSION['user'] = $response['data']['user'];
            $_SESSION['token'] = $response['data']['token'];
            
            // Check if requires approval
            if ($response['data']['requiresApproval'] ?? false) {
                $success = $lang === 'he' 
                    ? 'ההרשמה הושלמה! החשבון שלך בבדיקה על ידי הצוות.'
                    : ($lang === 'en' ? 'Registration successful! Your account is under review.' : 'تم التسجيل بنجاح! حسابك قيد المراجعة من قبل الإدارة.');
            } else {
                // Show welcome modal with free bonus
                $showWelcomeModal = true;
            }
        } else {
            $error = $response['message'] ?? ($lang === 'he' ? 'ההרשמה נכשלה' : ($lang === 'en' ? 'Registration failed' : 'فشل إنشاء الحساب'));
        }
    }
}

require_once __DIR__ . '/includes/header.php';
?>

<?php
// Translations for this page
$t = [
    'create_account' => ['ar' => 'إنشاء حساب جديد', 'he' => 'יצירת חשבון חדש', 'en' => 'Create New Account'],
    'create_subtitle' => ['ar' => 'أنشئ حسابك للبدء', 'he' => 'צור חשבון כדי להתחיל', 'en' => 'Create your account to get started'],
    'full_name' => ['ar' => 'الاسم الكامل', 'he' => 'שם מלא', 'en' => 'Full Name'],
    'phone' => ['ar' => 'رقم الهاتف', 'he' => 'מספר טלפון', 'en' => 'Phone Number'],
    'email_optional' => ['ar' => 'البريد الإلكتروني (اختياري)', 'he' => 'דוא"ל (אופציונלי)', 'en' => 'Email (Optional)'],
    'account_type' => ['ar' => 'نوع الحساب', 'he' => 'סוג חשבון', 'en' => 'Account Type'],
    'region' => ['ar' => 'المنطقة', 'he' => 'אזור', 'en' => 'Region'],
    'city' => ['ar' => 'المدينة', 'he' => 'עיר', 'en' => 'City'],
    'select_region' => ['ar' => 'اختر المنطقة', 'he' => 'בחר אזור', 'en' => 'Select Region'],
    'select_city' => ['ar' => 'اختر المدينة', 'he' => 'בחר עיר', 'en' => 'Select City'],
    'password' => ['ar' => 'كلمة المرور', 'he' => 'סיסמה', 'en' => 'Password'],
    'confirm_password' => ['ar' => 'تأكيد كلمة المرور', 'he' => 'אישור סיסמה', 'en' => 'Confirm Password'],
    'agree_terms' => ['ar' => 'أوافق على', 'he' => 'אני מסכים ל', 'en' => 'I agree to the'],
    'terms' => ['ar' => 'الشروط والأحكام', 'he' => 'תנאי השימוש', 'en' => 'Terms & Conditions'],
    'privacy' => ['ar' => 'سياسة الخصوصية', 'he' => 'מדיניות הפרטיות', 'en' => 'Privacy Policy'],
    'and' => ['ar' => 'و', 'he' => 'ו', 'en' => 'and'],
    'create_btn' => ['ar' => 'إنشاء الحساب', 'he' => 'צור חשבון', 'en' => 'Create Account'],
    'have_account' => ['ar' => 'لديك حساب؟', 'he' => 'יש לך חשבון?', 'en' => 'Have an account?'],
    'login' => ['ar' => 'تسجيل الدخول', 'he' => 'התחברות', 'en' => 'Login'],
    'welcome' => ['ar' => 'مرحباً بك!', 'he' => 'ברוך הבא!', 'en' => 'Welcome!'],
    'welcome_bonus' => ['ar' => 'حصلت على باقة ترحيبية مجانية!', 'he' => 'קיבלת חבילת ברוכים הבאים בחינם!', 'en' => 'You got a free welcome package!'],
    'welcome_desc' => ['ar' => 'يمكنك الآن نشر إعلاناتك مجاناً. استمتع بتجربة Rento Go!', 'he' => 'עכשיו אתה יכול לפרסם מודעות בחינם. תיהנה מ-Rento Go!', 'en' => 'You can now post listings for free. Enjoy Rento Go!'],
    'start_now' => ['ar' => 'ابدأ الآن', 'he' => 'התחל עכשיו', 'en' => 'Start Now'],
    'loading' => ['ar' => 'جاري التحميل...', 'he' => 'טוען...', 'en' => 'Loading...'],
];
function tr($key) {
    global $t, $lang;
    return $t[$key][$lang] ?? $t[$key]['ar'] ?? $key;
}
?>

<?php if ($showWelcomeModal): ?>
<!-- Welcome Modal with Free Bonus -->
<div class="modal fade show" id="welcomeModal" tabindex="-1" style="display: block; background: rgba(0,0,0,0.5);">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content text-center" style="border-radius: 20px;">
            <div class="modal-body p-5">
                <div style="width: 80px; height: 80px; background: rgba(40, 167, 69, 0.1); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 20px;">
                    <i class="bi bi-gift text-success" style="font-size: 40px;"></i>
                </div>
                <h2 class="mb-3"><?= tr('welcome') ?></h2>
                <h5 class="text-success mb-3"><?= tr('welcome_bonus') ?></h5>
                <p class="text-muted mb-4"><?= tr('welcome_desc') ?></p>
                <a href="<?= SITE_URL ?>" class="btn btn-success btn-lg w-100" style="border-radius: 12px;">
                    <?= tr('start_now') ?>
                </a>
            </div>
        </div>
    </div>
</div>
<?php endif; ?>

<div class="auth-page py-5">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-6 col-lg-5">
                <div class="auth-card">
                    <div class="text-center mb-4">
                        <i class="bi bi-person-plus-fill auth-icon"></i>
                        <h2><?= tr('create_account') ?></h2>
                        <p class="text-muted"><?= tr('create_subtitle') ?></p>
                    </div>
                    
                    <?php if ($error): ?>
                    <div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
                    <?php endif; ?>
                    
                    <?php if ($success): ?>
                    <div class="alert alert-success"><?= htmlspecialchars($success) ?></div>
                    <?php else: ?>
                    
                    <form method="POST" action="">
                        <div class="mb-3">
                            <label class="form-label"><?= tr('full_name') ?> *</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-person"></i></span>
                                <input type="text" name="name" class="form-control" required>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label"><?= tr('phone') ?> *</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-phone"></i></span>
                                <input type="tel" name="phone" class="form-control" dir="ltr" placeholder="+972501234567" required>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label"><?= tr('email_optional') ?></label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                                <input type="email" name="email" class="form-control" dir="ltr">
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label"><?= tr('account_type') ?></label>
                            <select name="user_type" class="form-select">
                                <?php foreach ($userTypes as $value => $labels): ?>
                                <option value="<?= $value ?>"><?= $labels[$lang] ?? $labels['ar'] ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label"><?= tr('region') ?> *</label>
                                <select name="region_id" id="region_id" class="form-select" required>
                                    <option value=""><?= tr('select_region') ?></option>
                                    <?php foreach ($regions as $region): ?>
                                    <option value="<?= $region['id'] ?>"><?= htmlspecialchars($region['name_' . $lang] ?? $region['name_ar']) ?></option>
                                    <?php endforeach; ?>
                                </select>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label"><?= tr('city') ?> *</label>
                                <select name="city_id" id="city_id" class="form-select" required>
                                    <option value=""><?= tr('select_city') ?></option>
                                </select>
                            </div>
                        </div>
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label"><?= tr('password') ?> *</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-lock"></i></span>
                                    <input type="password" name="password" class="form-control" minlength="6" required>
                                </div>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="form-label"><?= tr('confirm_password') ?> *</label>
                                <div class="input-group">
                                    <span class="input-group-text"><i class="bi bi-lock"></i></span>
                                    <input type="password" name="confirm_password" class="form-control" minlength="6" required>
                                </div>
                            </div>
                        </div>
                        
                        <div class="form-check mb-4">
                            <input type="checkbox" class="form-check-input" id="terms" required>
                            <label class="form-check-label" for="terms">
                                <?= tr('agree_terms') ?> <a href="terms.php"><?= tr('terms') ?></a> <?= tr('and') ?> <a href="privacy.php"><?= tr('privacy') ?></a>
                            </label>
                        </div>
                        
                        <button type="submit" class="btn btn-primary w-100 btn-lg mb-3">
                            <i class="bi bi-person-plus me-2"></i><?= tr('create_btn') ?>
                        </button>
                        
                        <p class="text-center mb-0">
                            <?= tr('have_account') ?> <a href="login.php"><?= tr('login') ?></a>
                        </p>
                    </form>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
const apiUrl = '<?= API_URL ?>';
const currentLang = '<?= $lang ?>';

document.getElementById('region_id').addEventListener('change', function() {
    const regionId = this.value;
    const citySelect = document.getElementById('city_id');
    citySelect.innerHTML = '<option value=""><?= tr('loading') ?></option>';
    
    if (regionId) {
        fetch(apiUrl + '/regions/' + regionId + '/cities')
            .then(r => r.json())
            .then(data => {
                citySelect.innerHTML = '<option value=""><?= tr('select_city') ?></option>';
                if (data.data) {
                    data.data.forEach(city => {
                        const cityName = city['name_' + currentLang] || city.name_ar;
                        citySelect.innerHTML += `<option value="${city.id}">${cityName}</option>`;
                    });
                }
            });
    } else {
        citySelect.innerHTML = '<option value=""><?= tr('select_city') ?></option>';
    }
});
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
