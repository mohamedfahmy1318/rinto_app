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
    
    if ($action === 'save_payment_methods') {
        // Save payment method toggles
        $methods = ['bank_transfer', 'apple_iap', 'google_iap', 'test'];
        foreach ($methods as $method) {
            $enabled = isset($_POST['payment_' . $method . '_enabled']) ? '1' : '0';
            $key = 'payment_' . $method . '_enabled';
            
            $existing = $db->fetch("SELECT id FROM settings WHERE setting_key = ?", [$key]);
            if ($existing) {
                $db->query("UPDATE settings SET setting_value = ? WHERE setting_key = ?", [$enabled, $key]);
            } else {
                $db->query("INSERT INTO settings (setting_key, setting_value, setting_group) VALUES (?, ?, 'payment_methods')", [$key, $enabled]);
            }
        }
        $message = 'تم حفظ إعدادات وسائل الدفع بنجاح';
        
    } elseif ($action === 'save_bank_details') {
        // Save bank details
        $bankFields = ['bank_name', 'bank_account_name', 'bank_account_number', 'bank_iban', 'bank_branch'];
        foreach ($bankFields as $field) {
            $value = $_POST[$field] ?? '';
            $existing = $db->fetch("SELECT id FROM settings WHERE setting_key = ?", [$field]);
            if ($existing) {
                $db->query("UPDATE settings SET setting_value = ? WHERE setting_key = ?", [$value, $field]);
            } else {
                $db->query("INSERT INTO settings (setting_key, setting_value, setting_group) VALUES (?, ?, 'bank_details')", [$field, $value]);
            }
        }
        $message = 'تم حفظ بيانات البنك بنجاح';
    }
}

// Get payment methods settings
$paymentMethods = [];
$methodsResult = $db->fetchAll("SELECT setting_key, setting_value FROM settings WHERE setting_group = 'payment_methods'");
foreach ($methodsResult as $row) {
    $paymentMethods[$row['setting_key']] = $row['setting_value'];
}

// Get bank details
$bankDetails = [];
$bankResult = $db->fetchAll("SELECT setting_key, setting_value FROM settings WHERE setting_group = 'bank_details'");
foreach ($bankResult as $row) {
    $bankDetails[$row['setting_key']] = $row['setting_value'];
}

// Helper function
function isMethodEnabled($methods, $key) {
    return ($methods[$key] ?? '0') === '1';
}

$pageTitle = 'إعدادات وسائل الدفع';
require_once 'includes/header.php';
?>

<div class="container-fluid py-4">
    <div class="row mb-4">
        <div class="col">
            <h2><i class="bi bi-credit-card-2-front"></i> إعدادات وسائل الدفع</h2>
            <p class="text-muted">تفعيل وإخفاء وسائل الدفع المتاحة في التطبيق</p>
        </div>
    </div>
    
    <?php if ($message): ?>
    <div class="alert alert-<?= $messageType ?> alert-dismissible fade show">
        <i class="bi bi-check-circle me-2"></i>
        <?= htmlspecialchars($message) ?>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <?php endif; ?>
    
    <div class="row">
        <!-- Payment Methods -->
        <div class="col-lg-6 mb-4">
            <div class="card h-100">
                <div class="card-header bg-primary text-white">
                    <h5 class="mb-0"><i class="bi bi-toggle-on me-2"></i>وسائل الدفع المتاحة</h5>
                </div>
                <div class="card-body">
                    <form method="POST">
                        <input type="hidden" name="action" value="save_payment_methods">
                        
                        <!-- Bank Transfer -->
                        <div class="payment-method-item mb-3 p-3 border rounded">
                            <div class="d-flex justify-content-between align-items-center">
                                <div class="d-flex align-items-center">
                                    <div class="icon-box bg-success bg-opacity-10 text-success rounded p-2 me-3">
                                        <i class="bi bi-bank fs-4"></i>
                                    </div>
                                    <div>
                                        <h6 class="mb-0">حوالة بنكية</h6>
                                        <small class="text-muted">تحويل إلى حساب البنك - يحتاج موافقة الأدمن</small>
                                    </div>
                                </div>
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" name="payment_bank_transfer_enabled" 
                                           id="bankTransfer" <?= isMethodEnabled($paymentMethods, 'payment_bank_transfer_enabled') ? 'checked' : '' ?>>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Apple IAP -->
                        <div class="payment-method-item mb-3 p-3 border rounded">
                            <div class="d-flex justify-content-between align-items-center">
                                <div class="d-flex align-items-center">
                                    <div class="icon-box bg-dark text-white rounded p-2 me-3">
                                        <i class="bi bi-apple fs-4"></i>
                                    </div>
                                    <div>
                                        <h6 class="mb-0">Apple Pay (In-App Purchase)</h6>
                                        <small class="text-muted">دفع عبر App Store - تفعيل فوري</small>
                                    </div>
                                </div>
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" name="payment_apple_iap_enabled" 
                                           id="appleIap" <?= isMethodEnabled($paymentMethods, 'payment_apple_iap_enabled') ? 'checked' : '' ?>>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Google IAP -->
                        <div class="payment-method-item mb-3 p-3 border rounded">
                            <div class="d-flex justify-content-between align-items-center">
                                <div class="d-flex align-items-center">
                                    <div class="icon-box bg-primary bg-opacity-10 text-primary rounded p-2 me-3">
                                        <i class="bi bi-google-play fs-4"></i>
                                    </div>
                                    <div>
                                        <h6 class="mb-0">Google Play (In-App Purchase)</h6>
                                        <small class="text-muted">دفع عبر Play Store - تفعيل فوري</small>
                                    </div>
                                </div>
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" name="payment_google_iap_enabled" 
                                           id="googleIap" <?= isMethodEnabled($paymentMethods, 'payment_google_iap_enabled') ? 'checked' : '' ?>>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Test Payment -->
                        <div class="payment-method-item mb-3 p-3 border rounded border-warning">
                            <div class="d-flex justify-content-between align-items-center">
                                <div class="d-flex align-items-center">
                                    <div class="icon-box bg-warning bg-opacity-10 text-warning rounded p-2 me-3">
                                        <i class="bi bi-bug fs-4"></i>
                                    </div>
                                    <div>
                                        <h6 class="mb-0">دفع تجريبي <span class="badge bg-warning text-dark">للاختبار</span></h6>
                                        <small class="text-muted">للمطورين فقط - لا يتم خصم أموال حقيقية</small>
                                    </div>
                                </div>
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" name="payment_test_enabled" 
                                           id="testPayment" <?= isMethodEnabled($paymentMethods, 'payment_test_enabled') ? 'checked' : '' ?>>
                                </div>
                            </div>
                        </div>
                        
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="bi bi-check-lg me-2"></i>حفظ إعدادات وسائل الدفع
                        </button>
                    </form>
                </div>
            </div>
        </div>
        
        <!-- Bank Details -->
        <div class="col-lg-6 mb-4">
            <div class="card h-100">
                <div class="card-header bg-success text-white">
                    <h5 class="mb-0"><i class="bi bi-bank me-2"></i>بيانات الحساب البنكي</h5>
                </div>
                <div class="card-body">
                    <form method="POST">
                        <input type="hidden" name="action" value="save_bank_details">
                        
                        <div class="mb-3">
                            <label class="form-label">اسم البنك</label>
                            <input type="text" class="form-control" name="bank_name" 
                                   value="<?= htmlspecialchars($bankDetails['bank_name'] ?? 'بنك فلسطين') ?>">
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">اسم الحساب</label>
                            <input type="text" class="form-control" name="bank_account_name" 
                                   value="<?= htmlspecialchars($bankDetails['bank_account_name'] ?? '') ?>">
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">رقم الحساب</label>
                            <input type="text" class="form-control" name="bank_account_number" 
                                   value="<?= htmlspecialchars($bankDetails['bank_account_number'] ?? '') ?>">
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">رقم IBAN</label>
                            <input type="text" class="form-control font-monospace" name="bank_iban" 
                                   value="<?= htmlspecialchars($bankDetails['bank_iban'] ?? '') ?>" dir="ltr">
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">الفرع</label>
                            <input type="text" class="form-control" name="bank_branch" 
                                   value="<?= htmlspecialchars($bankDetails['bank_branch'] ?? '') ?>">
                        </div>
                        
                        <button type="submit" class="btn btn-success w-100">
                            <i class="bi bi-check-lg me-2"></i>حفظ بيانات البنك
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Info Cards -->
    <div class="row">
        <div class="col-md-4 mb-3">
            <div class="card border-dark h-100">
                <div class="card-body text-center">
                    <i class="bi bi-apple fs-1 text-dark"></i>
                    <h6 class="mt-2">Apple Pay</h6>
                    <p class="small text-muted mb-0">
                        يتطلب إعداد App Store Connect<br>
                        <a href="iap-settings.php" class="text-primary">إعدادات IAP</a>
                    </p>
                </div>
            </div>
        </div>
        <div class="col-md-4 mb-3">
            <div class="card border-primary h-100">
                <div class="card-body text-center">
                    <i class="bi bi-google-play fs-1 text-primary"></i>
                    <h6 class="mt-2">Google Play</h6>
                    <p class="small text-muted mb-0">
                        يتطلب إعداد Google Play Console<br>
                        <a href="iap-settings.php" class="text-primary">إعدادات IAP</a>
                    </p>
                </div>
            </div>
        </div>
        <div class="col-md-4 mb-3">
            <div class="card border-success h-100">
                <div class="card-body text-center">
                    <i class="bi bi-bank fs-1 text-success"></i>
                    <h6 class="mt-2">حوالة بنكية</h6>
                    <p class="small text-muted mb-0">
                        يتم التحقق يدوياً من الأدمن<br>
                        <a href="payments.php" class="text-primary">إدارة المدفوعات</a>
                    </p>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
.payment-method-item {
    transition: all 0.2s;
}
.payment-method-item:hover {
    background-color: #f8f9fa;
}
.icon-box {
    width: 48px;
    height: 48px;
    display: flex;
    align-items: center;
    justify-content: center;
}
.form-check-input:checked {
    background-color: #198754;
    border-color: #198754;
}
</style>

<?php require_once 'includes/footer.php'; ?>
