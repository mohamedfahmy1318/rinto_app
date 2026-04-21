<?php
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/includes/translations.php';

// Force login
if (!isset($_SESSION['user']) || !isset($_SESSION['token'])) {
    header('Location: login.php?redirect=' . urlencode($_SERVER['REQUEST_URI']));
    exit;
}

$user = $_SESSION['user'];
$planId = $_GET['plan_id'] ?? null;
$listingType = $_GET['listing_type'] ?? null;
$listingId = $_GET['listing_id'] ?? null;

if (!$planId) {
    header('Location: packages.php');
    exit;
}

// Get plan details
$planResponse = apiCall("plans/$planId");
$plan = $planResponse['data'] ?? null;

if (!$plan) {
    header('Location: packages.php');
    exit;
}

$error = '';
$success = false;

$pendingTransfer = false;

// Translations helper
function trc($key) {
    global $lang;
    $translations = [
        'complete_payment' => ['ar' => 'إتمام الدفع', 'he' => 'השלמת תשלום', 'en' => 'Complete Payment'],
        'payment_success' => ['ar' => 'تم الدفع بنجاح!', 'he' => 'התשלום הושלם בהצלחה!', 'en' => 'Payment Successful!'],
        'package_activated' => ['ar' => 'تم تفعيل الباقة في حسابك. يمكنك البدء بنشر إعلاناتك.', 'he' => 'החבילה הופעלה בחשבונך. תוכל להתחיל לפרסם מודעות.', 'en' => 'Package activated. You can start posting listings.'],
        'add_property' => ['ar' => 'أضف عقار', 'he' => 'הוסף נכס', 'en' => 'Add Property'],
        'add_car' => ['ar' => 'أضف سيارة', 'he' => 'הוסף רכב', 'en' => 'Add Car'],
        'go_to_account' => ['ar' => 'الذهاب لحسابي', 'he' => 'לחשבון שלי', 'en' => 'Go to My Account'],
        'pending_verification' => ['ar' => 'في انتظار التحقق', 'he' => 'ממתין לאישור', 'en' => 'Pending Verification'],
        'transfer_received' => ['ar' => 'تم استلام بيانات الحوالة. سيتم التحقق وتفعيل الباقة خلال 24 ساعة.', 'he' => 'קיבלנו את פרטי ההעברה. נאשר את התשלום תוך 24 שעות.', 'en' => 'Transfer details received. Verification within 24 hours.'],
        'what_next' => ['ar' => 'ماذا بعد؟', 'he' => 'מה עכשיו?', 'en' => 'What\'s next?'],
        'team_verify' => ['ar' => 'فريقنا سيتحقق من الحوالة', 'he' => 'צוות שלנו יבדוק את ההעברה', 'en' => 'Our team will verify the transfer'],
        'notify_activation' => ['ar' => 'ستتلقى إشعاراً عند تفعيل الباقة', 'he' => 'תקבל הודעה כשהחבילה תופעל', 'en' => 'You\'ll be notified when activated'],
        'package_details' => ['ar' => 'تفاصيل الباقة', 'he' => 'פרטי החבילה', 'en' => 'Package Details'],
        'package_name' => ['ar' => 'اسم الباقة', 'he' => 'שם החבילה', 'en' => 'Package Name'],
        'listings_count' => ['ar' => 'عدد الإعلانات', 'he' => 'מספר מודעות', 'en' => 'Listings Count'],
        'unlimited' => ['ar' => 'غير محدود', 'he' => 'ללא הגבלה', 'en' => 'Unlimited'],
        'duration' => ['ar' => 'المدة', 'he' => 'תקופה', 'en' => 'Duration'],
        'days' => ['ar' => 'يوم', 'he' => 'ימים', 'en' => 'days'],
        'trusted_advertiser' => ['ar' => 'معلن مميز', 'he' => 'מפרסם מובחר', 'en' => 'Trusted Advertiser'],
        'city_notifications' => ['ar' => 'إشعارات المدينة', 'he' => 'התראות לעיר', 'en' => 'City Notifications'],
        'region_notifications' => ['ar' => 'إشعارات المنطقة', 'he' => 'התראות לאזור', 'en' => 'Region Notifications'],
        'total_amount' => ['ar' => 'المبلغ الإجمالي', 'he' => 'סה"כ לתשלום', 'en' => 'Total Amount'],
        'payment_method' => ['ar' => 'طريقة الدفع', 'he' => 'אמצעי תשלום', 'en' => 'Payment Method'],
        'bank_transfer' => ['ar' => 'حوالة بنكية', 'he' => 'העברה בנקאית', 'en' => 'Bank Transfer'],
        'transfer_to_bank' => ['ar' => 'حوّل إلى حسابنا البنكي', 'he' => 'העבר לחשבון הבנק שלנו', 'en' => 'Transfer to our bank account'],
        'bank_details' => ['ar' => 'تفاصيل الحساب البنكي', 'he' => 'פרטי חשבון הבנק', 'en' => 'Bank Account Details'],
        'bank_name' => ['ar' => 'اسم البنك', 'he' => 'שם הבנק', 'en' => 'Bank Name'],
        'account_name' => ['ar' => 'اسم الحساب', 'he' => 'שם החשבון', 'en' => 'Account Name'],
        'account_number' => ['ar' => 'رقم الحساب', 'he' => 'מספר חשבון', 'en' => 'Account Number'],
        'branch' => ['ar' => 'الفرع', 'he' => 'סניף', 'en' => 'Branch'],
        'amount' => ['ar' => 'المبلغ', 'he' => 'סכום', 'en' => 'Amount'],
        'sender_name' => ['ar' => 'اسم المُحوِّل', 'he' => 'שם השולח', 'en' => 'Sender Name'],
        'transfer_date' => ['ar' => 'تاريخ التحويل', 'he' => 'תאריך העברה', 'en' => 'Transfer Date'],
        'reference' => ['ar' => 'رقم المرجع', 'he' => 'מספר אסמכתא', 'en' => 'Reference'],
        'optional' => ['ar' => 'اختياري', 'he' => 'אופציונלי', 'en' => 'Optional'],
        'fast_secure' => ['ar' => 'دفع سريع وآمن', 'he' => 'תשלום מהיר ומאובטח', 'en' => 'Fast and secure payment'],
        'test_payment' => ['ar' => 'دفع تجريبي', 'he' => 'תשלום לבדיקה', 'en' => 'Test Payment'],
        'test_only' => ['ar' => 'للاختبار فقط', 'he' => 'לבדיקה בלבד', 'en' => 'For testing only'],
        'pay_now' => ['ar' => 'ادفع الآن', 'he' => 'שלם עכשיו', 'en' => 'Pay Now'],
        'confirm_transfer' => ['ar' => 'تأكيد الحوالة', 'he' => 'אשר העברה', 'en' => 'Confirm Transfer'],
        'back_to_packages' => ['ar' => 'العودة للباقات', 'he' => 'חזרה לחבילות', 'en' => 'Back to Packages'],
        'payment_error' => ['ar' => 'خطأ في عملية الدفع', 'he' => 'שגיאה בתשלום', 'en' => 'Payment Error'],
    ];
    return $translations[$key][$lang] ?? $translations[$key]['ar'] ?? $key;
}

// Handle payment
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['pay'])) {
    $paymentMethod = $_POST['payment_method'] ?? 'test';
    
    $paymentData = [
        'plan_id' => $planId,
        'payment_method' => $paymentMethod,
        'transaction_id' => strtoupper($paymentMethod) . '_' . time() . '_' . rand(1000, 9999)
    ];
    
    // For bank transfer, set status to pending
    if ($paymentMethod === 'bank_transfer') {
        $paymentData['status'] = 'pending_verification';
        $paymentData['sender_name'] = $_POST['sender_name'] ?? '';
        $paymentData['transfer_date'] = $_POST['transfer_date'] ?? date('Y-m-d');
        $paymentData['transfer_reference'] = $_POST['transfer_reference'] ?? '';
    }
    
    // If there's a pending listing, include it
    if ($listingType && $listingId) {
        $paymentData['listing_type'] = $listingType;
        $paymentData['listing_id'] = $listingId;
    }
    
    $response = apiCall('subscriptions/purchase', 'POST', $paymentData, $_SESSION['token']);
    
    if ($response['success'] ?? false) {
        if ($paymentMethod === 'bank_transfer') {
            $pendingTransfer = true;
        } else {
            $success = true;
        }
    } else {
        $error = $response['message'] ?? ($lang === 'he' ? 'שגיאה בתשלום' : 'خطأ في عملية الدفع');
    }
}

// Load payment methods dynamically from API
$paymentMethodsResponse = apiCall('settings/payment-methods?platform=web');
$enabledMethods = $paymentMethodsResponse['data']['enabled_methods'] ?? ['bank_transfer', 'test'];
$bankDetails = $paymentMethodsResponse['data']['bank_details'] ?? [
    'bank_name' => '',
    'bank_account_name' => '',
    'bank_account_number' => '',
    'bank_iban' => '',
    'bank_branch' => ''
];

$pageTitle = $lang === 'he' ? 'השלמת תשלום' : 'إتمام الدفع';
require_once __DIR__ . '/includes/header.php';
?>

<style>
.checkout-container {
    max-width: 600px;
    margin: 2rem auto;
}
.checkout-card {
    background: white;
    border-radius: 16px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.1);
    overflow: hidden;
}
.checkout-header {
    background: linear-gradient(135deg, var(--teal) 0%, var(--teal-dark) 100%);
    color: white;
    padding: 2rem;
    text-align: center;
}
.checkout-body {
    padding: 2rem;
}
.plan-summary {
    background: #f8f9fa;
    border-radius: 12px;
    padding: 1.5rem;
    margin-bottom: 1.5rem;
}
.plan-summary-row {
    display: flex;
    justify-content: space-between;
    padding: 0.5rem 0;
    border-bottom: 1px solid #eee;
}
.plan-summary-row:last-child {
    border-bottom: none;
    font-weight: bold;
    font-size: 1.2rem;
    color: var(--teal);
}
.payment-method {
    border: 2px solid #eee;
    border-radius: 12px;
    padding: 1rem;
    margin-bottom: 1rem;
    cursor: pointer;
    transition: all 0.3s;
}
.payment-method:hover, .payment-method.selected {
    border-color: var(--teal);
    background: rgba(0, 128, 128, 0.05);
}
.payment-method input[type="radio"] {
    margin-left: 10px;
}
.btn-pay {
    background: linear-gradient(135deg, var(--teal) 0%, var(--teal-dark) 100%);
    color: white;
    border: none;
    padding: 1rem 2rem;
    font-size: 1.1rem;
    border-radius: 12px;
    width: 100%;
    cursor: pointer;
    transition: transform 0.2s;
}
.btn-pay:hover {
    transform: scale(1.02);
    color: white;
}
.success-animation {
    text-align: center;
    padding: 3rem;
}
.success-icon {
    width: 100px;
    height: 100px;
    background: linear-gradient(135deg, #28a745, #20c997);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 1.5rem;
    animation: scaleIn 0.5s ease;
}
.success-icon i {
    font-size: 3rem;
    color: white;
}
@keyframes scaleIn {
    0% { transform: scale(0); }
    50% { transform: scale(1.2); }
    100% { transform: scale(1); }
}
.test-badge {
    background: #ffc107;
    color: #000;
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 0.8rem;
    margin-right: 8px;
}
</style>

<div class="container checkout-container">
    <div class="checkout-card">
        <?php if ($success): ?>
        <!-- Success State -->
        <div class="success-animation">
            <div class="success-icon">
                <i class="bi bi-check-lg"></i>
            </div>
            <h2 class="text-success mb-3">
                <?= trc('payment_success') ?>
            </h2>
            <p class="text-muted mb-4">
                <?= trc('package_activated') ?>
            </p>
            <div class="d-flex gap-3 justify-content-center">
                <a href="add-property.php" class="btn btn-outline-primary">
                    <i class="bi bi-building me-2"></i><?= trc('add_property') ?>
                </a>
                <a href="add-car.php" class="btn btn-outline-primary">
                    <i class="bi bi-car-front me-2"></i><?= trc('add_car') ?>
                </a>
            </div>
            <hr class="my-4">
            <a href="profile.php" class="btn btn-link">
                <i class="bi bi-person me-2"></i><?= trc('go_to_account') ?>
            </a>
        </div>
        <?php elseif ($pendingTransfer): ?>
        <!-- Pending Bank Transfer -->
        <div class="success-animation">
            <div class="success-icon" style="background: linear-gradient(135deg, #ffc107, #ff9800);">
                <i class="bi bi-hourglass-split"></i>
            </div>
            <h2 class="text-warning mb-3">
                <?= trc('pending_verification') ?>
            </h2>
            <p class="text-muted mb-4">
                <?= trc('transfer_received') ?>
            </p>
            <div class="alert alert-info text-start">
                <strong><i class="bi bi-info-circle me-2"></i><?= trc('what_next') ?></strong>
                <ul class="mb-0 mt-2">
                    <li><?= trc('team_verify') ?></li>
                    <li><?= trc('notify_activation') ?></li>
                </ul>
            </div>
            <a href="profile.php" class="btn btn-primary mt-3">
                <i class="bi bi-person me-2"></i><?= trc('go_to_account') ?>
            </a>
        </div>
        <?php else: ?>
        <!-- Checkout Form -->
        <div class="checkout-header">
            <i class="bi bi-credit-card fs-1 mb-2"></i>
            <h3 class="mb-0"><?= trc('complete_payment') ?></h3>
        </div>
        
        <div class="checkout-body">
            <?php if ($error): ?>
            <div class="alert alert-danger">
                <i class="bi bi-exclamation-circle me-2"></i><?= htmlspecialchars($error) ?>
            </div>
            <?php endif; ?>
            
            <!-- Plan Summary -->
            <div class="plan-summary">
                <h5 class="mb-3">
                    <i class="bi bi-box-seam me-2 text-primary"></i>
                    <?= trc('package_details') ?>
                </h5>
                <div class="plan-summary-row">
                    <span><?= trc('package_name') ?></span>
                    <span><?= htmlspecialchars($plan['name_' . $lang] ?? $plan['name_ar']) ?></span>
                </div>
                <div class="plan-summary-row">
                    <span><?= trc('listings_count') ?></span>
                    <span>
                        <?php if ($plan['is_unlimited']): ?>
                            <?= trc('unlimited') ?>
                        <?php else: ?>
                            <?= $plan['listings_count'] ?>
                        <?php endif; ?>
                    </span>
                </div>
                <div class="plan-summary-row">
                    <span><?= trc('duration') ?></span>
                    <span><?= $plan['duration_days'] ?> <?= trc('days') ?></span>
                </div>
                <?php if (!empty($plan['is_trusted_advertiser'])): ?>
                <div class="plan-summary-row">
                    <span><i class="bi bi-patch-check-fill text-success me-1"></i><?= trc('trusted_advertiser') ?></span>
                    <span class="text-success"><i class="bi bi-check-lg"></i></span>
                </div>
                <?php endif; ?>
                <?php if (!empty($plan['allow_city_notifications'])): ?>
                <div class="plan-summary-row">
                    <span><i class="bi bi-geo-alt text-primary me-1"></i><?= trc('city_notifications') ?></span>
                    <span class="text-success"><i class="bi bi-check-lg"></i></span>
                </div>
                <?php endif; ?>
                <?php if (!empty($plan['allow_region_notifications'])): ?>
                <div class="plan-summary-row">
                    <span><i class="bi bi-map text-primary me-1"></i><?= trc('region_notifications') ?></span>
                    <span class="text-success"><i class="bi bi-check-lg"></i></span>
                </div>
                <?php endif; ?>
                <div class="plan-summary-row">
                    <span><?= trc('total_amount') ?></span>
                    <span><?= number_format($plan['price']) ?> ₪</span>
                </div>
            </div>
            
            <!-- Payment Method -->
            <h5 class="mb-3">
                <i class="bi bi-wallet2 me-2 text-primary"></i>
                <?= trc('payment_method') ?>
            </h5>
            
            <form method="POST" id="paymentForm">
                <!-- Bank Transfer Option -->
                <?php if (in_array('bank_transfer', $enabledMethods)): ?>
                <label class="payment-method d-flex align-items-center" onclick="selectPayment('bank_transfer')">
                    <input type="radio" name="payment_method" value="bank_transfer" id="pm_bank">
                    <div class="flex-grow-1 ms-3">
                        <strong><i class="bi bi-bank me-2"></i><?= trc('bank_transfer') ?></strong>
                        <small class="text-muted d-block">
                            <?= trc('transfer_to_bank') ?>
                        </small>
                    </div>
                    <i class="bi bi-building text-primary fs-4"></i>
                </label>
                
                <!-- Bank Transfer Details (hidden by default) -->
                <div id="bankTransferDetails" class="mt-3" style="display: none;">
                    <div class="alert alert-secondary">
                        <h6 class="mb-3"><i class="bi bi-bank me-2"></i><?= trc('bank_details') ?></h6>
                        <table class="table table-sm table-borderless mb-0">
                            <tr>
                                <td class="text-muted"><?= trc('bank_name') ?>:</td>
                                <td class="fw-bold"><?= htmlspecialchars($bankDetails['bank_name'] ?? '') ?></td>
                            </tr>
                            <tr>
                                <td class="text-muted"><?= trc('account_name') ?>:</td>
                                <td class="fw-bold"><?= htmlspecialchars($bankDetails['bank_account_name'] ?? '') ?></td>
                            </tr>
                            <tr>
                                <td class="text-muted"><?= trc('account_number') ?>:</td>
                                <td class="fw-bold"><?= htmlspecialchars($bankDetails['bank_account_number'] ?? '') ?></td>
                            </tr>
                            <?php if (!empty($bankDetails['bank_iban'])): ?>
                            <tr>
                                <td class="text-muted">IBAN:</td>
                                <td class="fw-bold" style="font-size: 0.85rem;"><?= htmlspecialchars($bankDetails['bank_iban']) ?></td>
                            </tr>
                            <?php endif; ?>
                            <?php if (!empty($bankDetails['bank_branch'])): ?>
                            <tr>
                                <td class="text-muted"><?= trc('branch') ?>:</td>
                                <td class="fw-bold"><?= htmlspecialchars($bankDetails['bank_branch']) ?></td>
                            </tr>
                            <?php endif; ?>
                            <tr>
                                <td class="text-muted"><?= trc('amount') ?>:</td>
                                <td class="fw-bold text-success"><?= number_format($plan['price']) ?> ₪</td>
                            </tr>
                        </table>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label"><?= trc('sender_name') ?> *</label>
                        <input type="text" name="sender_name" class="form-control" required>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label"><?= trc('transfer_date') ?></label>
                            <input type="date" name="transfer_date" class="form-control" value="<?= date('Y-m-d') ?>">
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label"><?= trc('reference') ?></label>
                            <input type="text" name="transfer_reference" class="form-control" placeholder="<?= trc('optional') ?>">
                        </div>
                    </div>
                </div>
                <?php endif; ?>
                
                <!-- Apple Pay Option -->
                <?php if (in_array('apple_iap', $enabledMethods)): ?>
                <label class="payment-method d-flex align-items-center mt-2" onclick="selectPayment('apple_pay')">
                    <input type="radio" name="payment_method" value="apple_pay" id="pm_apple">
                    <div class="flex-grow-1 ms-3">
                        <strong><i class="bi bi-apple me-2"></i>Apple Pay</strong>
                        <small class="text-muted d-block"><?= trc('fast_secure') ?></small>
                    </div>
                    <i class="bi bi-apple text-dark fs-4"></i>
                </label>
                <?php endif; ?>
                
                <!-- Google Pay Option -->
                <?php if (in_array('google_iap', $enabledMethods)): ?>
                <label class="payment-method d-flex align-items-center mt-2" onclick="selectPayment('google_pay')">
                    <input type="radio" name="payment_method" value="google_pay" id="pm_google">
                    <div class="flex-grow-1 ms-3">
                        <strong><i class="bi bi-google me-2"></i>Google Pay</strong>
                        <small class="text-muted d-block"><?= trc('fast_secure') ?></small>
                    </div>
                    <i class="bi bi-google text-primary fs-4"></i>
                </label>
                <?php endif; ?>
                
                <!-- Test Payment (for development) -->
                <?php if (in_array('test', $enabledMethods)): ?>
                <label class="payment-method <?= in_array('test', $enabledMethods) && !in_array('bank_transfer', $enabledMethods) ? 'selected' : '' ?> d-flex align-items-center mt-2" onclick="selectPayment('test')">
                    <input type="radio" name="payment_method" value="test" id="pm_test" <?= in_array('test', $enabledMethods) && !in_array('bank_transfer', $enabledMethods) ? 'checked' : '' ?>>
                    <div class="flex-grow-1 ms-3">
                        <div class="d-flex align-items-center">
                            <span class="test-badge">TEST</span>
                            <strong><?= trc('test_payment') ?></strong>
                        </div>
                        <small class="text-muted">
                            <?= trc('test_only') ?>
                        </small>
                    </div>
                    <i class="bi bi-patch-check-fill text-warning fs-4"></i>
                </label>
                <?php endif; ?>
                
                <button type="submit" name="pay" class="btn btn-pay mt-4">
                    <i class="bi bi-lock me-2"></i>
                    <span id="payBtnText"><?= trc('pay_now') ?></span> - <?= number_format($plan['price']) ?> ₪
                </button>
            </form>
            
            <script>
            function selectPayment(method) {
                document.querySelectorAll('.payment-method').forEach(el => el.classList.remove('selected'));
                document.querySelector('input[value="'+method+'"]').closest('.payment-method').classList.add('selected');
                document.querySelector('input[value="'+method+'"]').checked = true;
                
                const bankDetails = document.getElementById('bankTransferDetails');
                const payBtn = document.getElementById('payBtnText');
                
                if (method === 'bank_transfer') {
                    bankDetails.style.display = 'block';
                    payBtn.textContent = '<?= trc('confirm_transfer') ?>';
                } else {
                    bankDetails.style.display = 'none';
                    payBtn.textContent = '<?= trc('pay_now') ?>';
                }
            }
            </script>
            
            <div class="text-center mt-3">
                <a href="packages.php?category=<?= $plan['category'] ?>" class="text-muted">
                    <i class="bi bi-arrow-right me-1"></i>
                    <?= trc('back_to_packages') ?>
                </a>
            </div>
        </div>
        <?php endif; ?>
    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
