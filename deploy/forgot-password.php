<?php
$pageTitle = 'نسيت كلمة المرور';
require_once __DIR__ . '/config.php';

$error = '';
$success = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $phone = $_POST['phone'] ?? '';
    
    $response = apiCall('auth/forgot-password', 'POST', ['phone' => $phone]);
    
    if ($response['success'] ?? false) {
        $success = 'تم إرسال رمز التحقق إلى هاتفك';
    } else {
        $error = $response['message'] ?? 'فشل إرسال رمز التحقق';
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
                        <i class="bi bi-key-fill auth-icon"></i>
                        <h2>نسيت كلمة المرور</h2>
                        <p class="text-muted">أدخل رقم هاتفك لإرسال رمز التحقق</p>
                    </div>
                    
                    <?php if ($error): ?>
                    <div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
                    <?php endif; ?>
                    
                    <?php if ($success): ?>
                    <div class="alert alert-success"><?= htmlspecialchars($success) ?></div>
                    <?php endif; ?>
                    
                    <form method="POST" action="">
                        <div class="mb-4">
                            <label class="form-label">رقم الهاتف</label>
                            <div class="input-group">
                                <span class="input-group-text"><i class="bi bi-phone"></i></span>
                                <input type="tel" name="phone" class="form-control" dir="ltr" placeholder="+972501234567" required>
                            </div>
                        </div>
                        
                        <button type="submit" class="btn btn-primary w-100 btn-lg mb-3">
                            <i class="bi bi-send me-2"></i>إرسال الرمز
                        </button>
                        
                        <p class="text-center mb-0">
                            <a href="login.php"><i class="bi bi-arrow-right me-1"></i>العودة لتسجيل الدخول</a>
                        </p>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
