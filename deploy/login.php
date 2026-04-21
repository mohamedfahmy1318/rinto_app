<?php
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/includes/translations.php';

$pageTitle = __('login');

// Translations for this page
$t = [
    'login_title' => ['ar' => 'تسجيل الدخول', 'he' => 'התחברות', 'en' => 'Login'],
    'login_subtitle' => ['ar' => 'سجّل دخولك للمتابعة', 'he' => 'התחבר כדי להמשיך', 'en' => 'Sign in to continue'],
    'phone' => ['ar' => 'رقم الهاتف', 'he' => 'מספר טלפון', 'en' => 'Phone Number'],
    'password' => ['ar' => 'كلمة المرور', 'he' => 'סיסמה', 'en' => 'Password'],
    'remember_me' => ['ar' => 'تذكرني', 'he' => 'זכור אותי', 'en' => 'Remember me'],
    'forgot_password' => ['ar' => 'نسيت كلمة المرور؟', 'he' => 'שכחת סיסמה?', 'en' => 'Forgot password?'],
    'login_btn' => ['ar' => 'تسجيل الدخول', 'he' => 'התחבר', 'en' => 'Login'],
    'no_account' => ['ar' => 'ليس لديك حساب؟', 'he' => 'אין לך חשבון?', 'en' => 'Don\'t have an account?'],
    'create_account' => ['ar' => 'إنشاء حساب', 'he' => 'צור חשבון', 'en' => 'Create Account'],
    'login_failed' => ['ar' => 'فشل تسجيل الدخول', 'he' => 'ההתחברות נכשלה', 'en' => 'Login failed'],
    'relogin_msg' => ['ar' => 'يرجى تسجيل الدخول مرة أخرى', 'he' => 'יש להתחבר מחדש', 'en' => 'Please login again'],
];
function trl($key) {
    global $t, $lang;
    return $t[$key][$lang] ?? $t[$key]['ar'] ?? $key;
}

// Handle login
$error = '';
$success = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $phone = $_POST['phone'] ?? '';
    $password = $_POST['password'] ?? '';
    
    $response = apiCall('auth/login', 'POST', [
        'login' => $phone,
        'password' => $password
    ]);
    
    if ($response['success'] ?? false) {
        $_SESSION['user'] = $response['data']['user'];
        $_SESSION['token'] = $response['data']['token'];
        
        // Redirect to original page or home
        $redirect = $_GET['redirect'] ?? $_POST['redirect'] ?? '';
        if ($redirect && !str_contains($redirect, '://')) {
            header('Location: ' . SITE_URL . '/' . $redirect);
        } else {
            header('Location: ' . SITE_URL);
        }
        exit;
    } else {
        $error = $response['message'] ?? trl('login_failed');
    }
}

require_once __DIR__ . '/includes/header.php';
?>

<div class="auth-page py-5">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-5">
                <div class="auth-card">
                    <div class="text-center mb-4">
                        <i class="bi bi-house-heart-fill auth-icon"></i>
                        <h2><?= trl('login_title') ?></h2>
                        <p class="text-muted"><?= trl('login_subtitle') ?></p>
                    </div>
                    
                    <?php if ($error): ?>
                    <div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
                    <?php endif; ?>
                    
                    <?php if (isset($_GET['msg']) && $_GET['msg'] === 'relogin'): ?>
                    <div class="alert alert-info"><?= trl('relogin_msg') ?></div>
                    <?php endif; ?>
                    
                    <form method="POST" action="">
                        <?php if (isset($_GET['redirect'])): ?>
                        <input type="hidden" name="redirect" value="<?= htmlspecialchars($_GET['redirect']) ?>">
                        <?php endif; ?>
                        <div class="mb-3">
                            <label class="form-label"><?= trl('phone') ?></label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-phone"></i></span>
                                <input type="tel" name="phone" class="form-control" dir="ltr" placeholder="+972501234567" required>
                            </div>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label"><?= trl('password') ?></label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-lock"></i></span>
                                <input type="password" name="password" class="form-control" required>
                            </div>
                        </div>
                        
                        <div class="d-flex justify-content-between align-items-center mb-4">
                            <div class="form-check">
                                <input type="checkbox" class="form-check-input" id="remember">
                                <label class="form-check-label" for="remember"><?= trl('remember_me') ?></label>
                            </div>
                            <a href="forgot-password.php"><?= trl('forgot_password') ?></a>
                        </div>
                        
                        <button type="submit" class="btn btn-primary w-100 btn-lg mb-3">
                            <i class="bi bi-box-arrow-in-left me-2"></i><?= trl('login_btn') ?>
                        </button>
                        
                        <p class="text-center mb-0">
                            <?= trl('no_account') ?> <a href="register.php"><?= trl('create_account') ?></a>
                        </p>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
