<?php
session_start();
require_once __DIR__ . '/../backend/config/database.php';
require_once __DIR__ . '/../backend/config/constants.php';

if (!isset($_SESSION['admin_id'])) {
    header('Location: login.php');
    exit;
}

$db = Database::getInstance();
$message = '';
$messageType = 'success';

// Handle form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    
    if ($action === 'save_apple') {
        $sharedSecret = trim($_POST['apple_shared_secret'] ?? '');
        $useSandbox = isset($_POST['apple_iap_sandbox']) ? '1' : '0';
        
        // Save or update settings
        $settings = [
            'apple_shared_secret' => $sharedSecret,
            'apple_iap_sandbox' => $useSandbox
        ];
        
        foreach ($settings as $key => $value) {
            $existing = $db->fetch("SELECT id FROM settings WHERE setting_key = ?", [$key]);
            if ($existing) {
                $db->update('settings', ['setting_value' => $value, 'updated_at' => date('Y-m-d H:i:s')], 'setting_key = ?', [$key]);
            } else {
                $db->insert('settings', [
                    'setting_key' => $key,
                    'setting_value' => $value,
                    'setting_group' => 'iap'
                ]);
            }
        }
        
        $message = 'تم حفظ إعدادات Apple IAP بنجاح';
    }
    
    if ($action === 'save_google') {
        $serviceAccountJson = trim($_POST['google_service_account'] ?? '');
        $useSandbox = isset($_POST['google_iap_sandbox']) ? '1' : '0';
        
        $settings = [
            'google_play_service_account' => $serviceAccountJson,
            'google_iap_sandbox' => $useSandbox
        ];
        
        foreach ($settings as $key => $value) {
            $existing = $db->fetch("SELECT id FROM settings WHERE setting_key = ?", [$key]);
            if ($existing) {
                $db->update('settings', ['setting_value' => $value, 'updated_at' => date('Y-m-d H:i:s')], 'setting_key = ?', [$key]);
            } else {
                $db->insert('settings', [
                    'setting_key' => $key,
                    'setting_value' => $value,
                    'setting_group' => 'iap'
                ]);
            }
        }
        
        $message = 'تم حفظ إعدادات Google Play بنجاح';
    }
}

// Get current settings
$appleSettings = [
    'apple_shared_secret' => '',
    'apple_iap_sandbox' => '1'
];

$googleSettings = [
    'google_play_service_account' => '',
    'google_iap_sandbox' => '1'
];

$allSettings = $db->fetchAll("SELECT setting_key, setting_value FROM settings WHERE setting_group = 'iap'");
foreach ($allSettings as $setting) {
    if (array_key_exists($setting['setting_key'], $appleSettings)) {
        $appleSettings[$setting['setting_key']] = $setting['setting_value'];
    }
    if (array_key_exists($setting['setting_key'], $googleSettings)) {
        $googleSettings[$setting['setting_key']] = $setting['setting_value'];
    }
}

// Get recent IAP payments
$recentPayments = $db->fetchAll(
    "SELECT p.*, u.name as user_name, u.phone as user_phone, pl.name_ar as plan_name
     FROM payments p
     JOIN users u ON p.user_id = u.id
     LEFT JOIN plans pl ON p.plan_id = pl.id
     WHERE p.payment_method IN ('apple_iap', 'google_iap')
     ORDER BY p.created_at DESC
     LIMIT 20"
);

include 'includes/header.php';
?>

<div class="container-fluid py-4">
    <div class="row mb-4">
        <div class="col-12">
            <h1 class="h3 mb-0"><i class="bi bi-credit-card me-2"></i>إعدادات الدفع داخل التطبيق (IAP)</h1>
            <p class="text-muted mb-0">إدارة إعدادات Apple In-App Purchase و Google Play Billing</p>
        </div>
    </div>

    <?php if ($message): ?>
    <div class="alert alert-<?= $messageType ?> alert-dismissible fade show" role="alert">
        <?= htmlspecialchars($message) ?>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <?php endif; ?>

    <div class="row">
        <!-- Apple IAP Settings -->
        <div class="col-lg-6 mb-4">
            <div class="card h-100">
                <div class="card-header bg-dark text-white">
                    <h5 class="mb-0"><i class="bi bi-apple me-2"></i>Apple In-App Purchase</h5>
                </div>
                <div class="card-body">
                    <form method="POST">
                        <input type="hidden" name="action" value="save_apple">
                        
                        <div class="mb-3">
                            <label class="form-label">App-Specific Shared Secret</label>
                            <input type="password" name="apple_shared_secret" class="form-control" 
                                   value="<?= htmlspecialchars($appleSettings['apple_shared_secret']) ?>"
                                   placeholder="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx">
                            <small class="text-muted">
                                من App Store Connect → App → In-App Purchases → App-Specific Shared Secret
                            </small>
                        </div>
                        
                        <div class="mb-3">
                            <div class="form-check form-switch">
                                <input type="checkbox" name="apple_iap_sandbox" class="form-check-input" id="appleSandbox"
                                       <?= $appleSettings['apple_iap_sandbox'] === '1' ? 'checked' : '' ?>>
                                <label class="form-check-label" for="appleSandbox">
                                    <i class="bi bi-bug text-warning me-1"></i>وضع Sandbox (للاختبار)
                                </label>
                            </div>
                            <small class="text-muted">
                                فعّل هذا أثناء التطوير والاختبار، وأوقفه عند الإطلاق للإنتاج
                            </small>
                        </div>
                        
                        <div class="alert alert-info mb-3">
                            <h6 class="alert-heading"><i class="bi bi-info-circle me-1"></i>كيفية الحصول على Shared Secret:</h6>
                            <ol class="mb-0 small">
                                <li>سجل الدخول إلى <a href="https://appstoreconnect.apple.com" target="_blank">App Store Connect</a></li>
                                <li>اختر التطبيق</li>
                                <li>اذهب إلى In-App Purchases</li>
                                <li>اضغط على "App-Specific Shared Secret"</li>
                                <li>انسخ المفتاح والصقه هنا</li>
                            </ol>
                        </div>
                        
                        <button type="submit" class="btn btn-dark w-100">
                            <i class="bi bi-save me-1"></i>حفظ إعدادات Apple
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <!-- Google Play Settings (للمستقبل) -->
        <div class="col-lg-6 mb-4">
            <div class="card h-100">
                <div class="card-header bg-success text-white">
                    <h5 class="mb-0"><i class="bi bi-google-play me-2"></i>Google Play Billing</h5>
                    <small class="opacity-75">قريباً</small>
                </div>
                <div class="card-body">
                    <form method="POST">
                        <input type="hidden" name="action" value="save_google">
                        
                        <div class="mb-3">
                            <label class="form-label">Service Account JSON</label>
                            <textarea name="google_service_account" class="form-control" rows="4" 
                                      placeholder='{"type": "service_account", ...}'><?= htmlspecialchars($googleSettings['google_play_service_account']) ?></textarea>
                            <small class="text-muted">
                                من Google Cloud Console → Service Accounts → Create Key (JSON)
                            </small>
                        </div>
                        
                        <div class="mb-3">
                            <div class="form-check form-switch">
                                <input type="checkbox" name="google_iap_sandbox" class="form-check-input" id="googleSandbox"
                                       <?= $googleSettings['google_iap_sandbox'] === '1' ? 'checked' : '' ?>>
                                <label class="form-check-label" for="googleSandbox">
                                    <i class="bi bi-bug text-warning me-1"></i>وضع Sandbox (للاختبار)
                                </label>
                            </div>
                            <small class="text-muted">
                                في وضع Sandbox، يتم قبول جميع المشتريات بدون التحقق من Google
                            </small>
                        </div>
                        
                        <div class="alert alert-info mb-3">
                            <h6 class="alert-heading"><i class="bi bi-info-circle me-1"></i>كيفية الحصول على Service Account:</h6>
                            <ol class="mb-0 small">
                                <li>اذهب إلى <a href="https://console.cloud.google.com" target="_blank">Google Cloud Console</a></li>
                                <li>اختر مشروعك أو أنشئ مشروع جديد</li>
                                <li>اذهب إلى IAM & Admin → Service Accounts</li>
                                <li>أنشئ Service Account جديد</li>
                                <li>اضغط على الحساب → Keys → Add Key → JSON</li>
                                <li>انسخ محتوى الملف والصقه هنا</li>
                                <li>في Google Play Console، أضف هذا الـ Service Account كمستخدم</li>
                            </ol>
                        </div>
                        
                        <button type="submit" class="btn btn-success w-100">
                            <i class="bi bi-save me-1"></i>حفظ إعدادات Google
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Recent IAP Transactions -->
    <div class="card">
        <div class="card-header">
            <h5 class="mb-0"><i class="bi bi-receipt me-2"></i>آخر عمليات الدفع داخل التطبيق</h5>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>المستخدم</th>
                            <th>الباقة</th>
                            <th>المبلغ</th>
                            <th>طريقة الدفع</th>
                            <th>الحالة</th>
                            <th>التاريخ</th>
                            <th>Transaction ID</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (empty($recentPayments)): ?>
                        <tr>
                            <td colspan="8" class="text-center py-4 text-muted">
                                <i class="bi bi-inbox fs-1 d-block mb-2"></i>
                                لا توجد عمليات دفع داخل التطبيق حتى الآن
                            </td>
                        </tr>
                        <?php endif; ?>
                        <?php foreach ($recentPayments as $payment): ?>
                        <tr>
                            <td><?= $payment['id'] ?></td>
                            <td>
                                <strong><?= htmlspecialchars($payment['user_name']) ?></strong><br>
                                <small class="text-muted"><?= $payment['user_phone'] ?></small>
                            </td>
                            <td><?= htmlspecialchars($payment['plan_name'] ?? '-') ?></td>
                            <td><?= number_format($payment['amount'], 2) ?> <?= $payment['currency'] ?></td>
                            <td>
                                <?php if ($payment['payment_method'] === 'apple_iap'): ?>
                                <span class="badge bg-dark"><i class="bi bi-apple me-1"></i>Apple</span>
                                <?php else: ?>
                                <span class="badge bg-success"><i class="bi bi-google-play me-1"></i>Google</span>
                                <?php endif; ?>
                            </td>
                            <td>
                                <?php
                                $statusBadge = [
                                    'completed' => 'success',
                                    'pending' => 'warning',
                                    'failed' => 'danger',
                                    'refunded' => 'secondary'
                                ];
                                $statusText = [
                                    'completed' => 'مكتمل',
                                    'pending' => 'معلق',
                                    'failed' => 'فشل',
                                    'refunded' => 'مسترد'
                                ];
                                ?>
                                <span class="badge bg-<?= $statusBadge[$payment['status']] ?? 'secondary' ?>">
                                    <?= $statusText[$payment['status']] ?? $payment['status'] ?>
                                </span>
                            </td>
                            <td><?= date('Y-m-d H:i', strtotime($payment['created_at'])) ?></td>
                            <td>
                                <small class="text-muted font-monospace">
                                    <?= htmlspecialchars(substr($payment['transaction_id'] ?? '', 0, 20)) ?>...
                                </small>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<?php include 'includes/footer.php'; ?>
