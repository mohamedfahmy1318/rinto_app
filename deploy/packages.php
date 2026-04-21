<?php
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/includes/translations.php';

// Translations helper for this page
function trp($key) {
    global $lang;
    $translations = [
        'packages_title' => ['ar' => 'الباقات والأسعار', 'he' => 'חבילות ומחירים', 'en' => 'Packages & Pricing'],
        'choose_package' => ['ar' => 'اختر الباقة المناسبة لك', 'he' => 'בחר את החבילה המתאימה לך', 'en' => 'Choose the right package for you'],
        'active_subscription' => ['ar' => 'اشتراك فعال', 'he' => 'מנוי פעיל', 'en' => 'Active Subscription'],
        'valid_for' => ['ar' => 'صالح لمدة', 'he' => 'בתוקף עוד', 'en' => 'Valid for'],
        'days' => ['ar' => 'يوم', 'he' => 'ימים', 'en' => 'days'],
        'used' => ['ar' => 'مستخدم', 'he' => 'נוצלו', 'en' => 'Used'],
        'remaining' => ['ar' => 'متبقي', 'he' => 'נותרו', 'en' => 'Remaining'],
        'total' => ['ar' => 'الإجمالي', 'he' => 'סה"כ', 'en' => 'Total'],
        'properties' => ['ar' => 'عقارات', 'he' => 'נכסים', 'en' => 'Properties'],
        'cars' => ['ar' => 'سيارات', 'he' => 'רכבים', 'en' => 'Cars'],
        'unlimited' => ['ar' => 'إعلانات غير محدودة', 'he' => 'מודעות ללא הגבלה', 'en' => 'Unlimited listings'],
        'listings' => ['ar' => 'إعلانات', 'he' => 'מודעות', 'en' => 'listings'],
        'trusted_advertiser' => ['ar' => 'معلن مميز', 'he' => 'מפרסם מובחר', 'en' => 'Trusted Advertiser'],
        'city_notifications' => ['ar' => 'إشعارات للمدينة', 'he' => 'התראות לעיר', 'en' => 'City Notifications'],
        'region_notifications' => ['ar' => 'إشعارات للمنطقة', 'he' => 'התראות לאזור', 'en' => 'Region Notifications'],
        'full_support' => ['ar' => 'دعم كامل', 'he' => 'תמיכה מלאה', 'en' => 'Full Support'],
        'login_to_order' => ['ar' => 'سجل دخول للطلب', 'he' => 'התחבר לבקשה', 'en' => 'Login to Order'],
        'pending_approval' => ['ar' => 'في انتظار الموافقة', 'he' => 'ממתין לאישור', 'en' => 'Pending Approval'],
        'buy_now' => ['ar' => 'اشتر الآن', 'he' => 'קנה עכשיו', 'en' => 'Buy Now'],
        'no_packages' => ['ar' => 'لا توجد باقات متاحة حالياً', 'he' => 'אין חבילות זמינות כרגע', 'en' => 'No packages available'],
        'discount' => ['ar' => 'خصم', 'he' => 'הנחה', 'en' => 'Discount'],
        'recommended' => ['ar' => 'الأفضل', 'he' => 'מומלץ', 'en' => 'Recommended'],
        'request_sent' => ['ar' => 'تم إرسال طلب الاشتراك بنجاح. في انتظار موافقة الإدارة.', 'he' => 'בקשת המנוי נשלחה בהצלחה. ממתין לאישור המנהל.', 'en' => 'Subscription request sent. Pending admin approval.'],
        'request_error' => ['ar' => 'خطأ في إرسال الطلب', 'he' => 'שגיאה בשליחת הבקשה', 'en' => 'Error sending request'],
    ];
    return $translations[$key][$lang] ?? $translations[$key]['ar'] ?? $key;
}

$pageTitle = trp('packages_title');

// Force login
if (!isset($_SESSION['user']) || !isset($_SESSION['token'])) {
    header('Location: login.php');
    exit;
}

$user = $_SESSION['user'];
$isLoggedIn = isset($_SESSION['user']) && isset($_SESSION['token']);

$category = $_GET['category'] ?? 'properties';
if (!in_array($category, ['properties', 'cars'])) {
    $category = 'properties';
}

$error = '';
$success = '';

// Handle subscription request
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $planId = $_POST['plan_id'] ?? null;
    
    if ($planId) {
        $response = apiCall('subscriptions/requests', 'POST', ['plan_id' => $planId], $_SESSION['token']);
        
        if ($response['success'] ?? false) {
            $success = trp('request_sent');
        } else {
            $error = $response['message'] ?? trp('request_error');
        }
    }
}

// Get plans
$plans = apiCall("plans?category=$category")['data'] ?? [];

// Get user's pending requests
$pendingRequests = [];
if ($isLoggedIn) {
    $requestsResponse = apiCall('subscriptions/requests', 'GET', null, $_SESSION['token']);
    $allRequests = $requestsResponse['data'] ?? [];
    foreach ($allRequests as $req) {
        if ($req['status'] === 'pending' && $req['category'] === $category) {
            $pendingRequests[$req['plan_id']] = true;
        }
    }
}

// Get active subscription
$activeSubscription = null;
if ($isLoggedIn) {
    $subResponse = apiCall("subscriptions/active?category=$category", 'GET', null, $_SESSION['token']);
    $activeSubscription = $subResponse['data'] ?? null;
}

require_once __DIR__ . '/includes/header.php';
?>

<style>
.packages-hero {
    background: linear-gradient(135deg, var(--teal) 0%, var(--teal-dark) 100%);
    color: white;
    padding: 3rem 0;
    margin-bottom: 2rem;
}
.package-card {
    border: 2px solid #eee;
    border-radius: 15px;
    padding: 2rem;
    text-align: center;
    transition: all 0.3s;
    height: 100%;
    background: white;
}
.package-card:hover {
    border-color: var(--teal);
    transform: translateY(-5px);
    box-shadow: 0 10px 30px rgba(0,188,212,0.2);
}
.package-card.featured {
    border-color: var(--teal);
    position: relative;
}
.package-card.featured::before {
    content: '<?= trp('recommended') ?>';
    position: absolute;
    top: -12px;
    left: 50%;
    transform: translateX(-50%);
    background: var(--teal);
    color: white;
    padding: 4px 20px;
    border-radius: 20px;
    font-size: 0.85rem;
}
.package-price {
    font-size: 2.5rem;
    font-weight: bold;
    color: var(--teal);
}
.package-price small {
    font-size: 1rem;
    color: #666;
}
.package-original-price {
    text-decoration: line-through;
    color: #999;
    font-size: 1.2rem;
}
.package-features {
    list-style: none;
    padding: 0;
    margin: 1.5rem 0;
}
.package-features li {
    padding: 0.5rem 0;
    border-bottom: 1px solid #eee;
}
.package-features li:last-child {
    border-bottom: none;
}
.badge-gold { background: linear-gradient(135deg, #FFD700, #FFA500); color: #000; }
.badge-silver { background: linear-gradient(135deg, #C0C0C0, #A9A9A9); color: #000; }
.badge-bronze { background: linear-gradient(135deg, #CD7F32, #8B4513); color: #fff; }
.category-tabs {
    display: flex;
    justify-content: center;
    gap: 1rem;
    margin-bottom: 2rem;
}
.category-tabs a {
    padding: 0.75rem 2rem;
    border-radius: 30px;
    text-decoration: none;
    color: #666;
    background: #f5f5f5;
    transition: all 0.3s;
}
.category-tabs a.active {
    background: var(--teal);
    color: white;
}
</style>

<div class="packages-hero">
    <div class="container text-center">
        <h1><?= trp('packages_title') ?></h1>
        <p class="mb-0"><?= trp('choose_package') ?></p>
    </div>
</div>

<div class="container py-4">
    <?php if ($error): ?>
    <div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
    <?php endif; ?>
    
    <?php if ($success): ?>
    <div class="alert alert-success"><?= htmlspecialchars($success) ?></div>
    <?php endif; ?>
    
    <?php if ($activeSubscription): 
        $listingsUsed = $activeSubscription['listings_used'] ?? 0;
        $listingsLimit = $activeSubscription['listings_limit'] ?? 0;
        $listingsRemaining = $listingsLimit - $listingsUsed;
        $isUnlimited = $activeSubscription['is_unlimited'] ?? false;
        $expiresAt = $activeSubscription['expires_at'] ?? null;
        $daysRemaining = $expiresAt ? max(0, (int)((strtotime($expiresAt) - time()) / 86400)) : 0;
    ?>
    <div class="card border-0 shadow-sm mb-4" style="background: linear-gradient(135deg, var(--teal) 0%, var(--teal-dark) 100%);">
        <div class="card-body text-white p-4">
            <div class="row align-items-center">
                <div class="col-md-6">
                    <div class="d-flex align-items-center mb-2">
                        <i class="bi bi-patch-check-fill fs-4 me-2"></i>
                        <span class="fw-bold"><?= trp('active_subscription') ?></span>
                    </div>
                    <h4 class="mb-1"><?= htmlspecialchars($activeSubscription['name_' . $lang] ?? $activeSubscription['name_ar']) ?></h4>
                    <?php if ($expiresAt): ?>
                    <small class="opacity-75">
                        <i class="bi bi-calendar3 me-1"></i>
                        <?= trp('valid_for') ?> <?= $daysRemaining ?> <?= trp('days') ?>
                    </small>
                    <?php endif; ?>
                </div>
                <div class="col-md-6">
                    <div class="row text-center mt-3 mt-md-0">
                        <div class="col-4">
                            <div class="bg-white bg-opacity-25 rounded p-3">
                                <div class="fs-3 fw-bold"><?= $listingsUsed ?></div>
                                <small><?= trp('used') ?></small>
                            </div>
                        </div>
                        <div class="col-4">
                            <div class="bg-white bg-opacity-25 rounded p-3">
                                <div class="fs-3 fw-bold"><?= $isUnlimited ? '∞' : $listingsRemaining ?></div>
                                <small><?= trp('remaining') ?></small>
                            </div>
                        </div>
                        <div class="col-4">
                            <div class="bg-white bg-opacity-25 rounded p-3">
                                <div class="fs-3 fw-bold"><?= $isUnlimited ? '∞' : $listingsLimit ?></div>
                                <small><?= trp('total') ?></small>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <?php endif; ?>

    <!-- Category Tabs -->
    <div class="category-tabs">
        <a href="?category=properties" class="<?= $category === 'properties' ? 'active' : '' ?>">
            <i class="bi bi-building me-2"></i><?= trp('properties') ?>
        </a>
        <a href="?category=cars" class="<?= $category === 'cars' ? 'active' : '' ?>">
            <i class="bi bi-car-front me-2"></i><?= trp('cars') ?>
        </a>
    </div>

    <!-- Packages Grid -->
    <div class="row g-4">
        <?php foreach ($plans as $plan): ?>
        <div class="col-md-6 col-lg-4">
            <div class="package-card <?= $plan['is_featured'] ? 'featured' : '' ?>">
                <?php if ($plan['badge']): ?>
                <span class="badge badge-<?= $plan['badge'] ?> mb-3" style="font-size: 0.9rem; padding: 8px 16px;">
                    <?= ucfirst($plan['badge']) ?>
                </span>
                <?php endif; ?>
                
                <h4><?= htmlspecialchars($plan['name_' . $lang] ?? $plan['name_ar']) ?></h4>
                
                <?php if ($plan['original_price']): ?>
                <div class="package-original-price"><?= number_format($plan['original_price']) ?> ₪</div>
                <?php endif; ?>
                
                <div class="package-price">
                    <?= number_format($plan['price']) ?>
                    <small>₪</small>
                </div>
                
                <?php if ($plan['discount_percent']): ?>
                <span class="badge bg-danger"><?= trp('discount') ?> <?= $plan['discount_percent'] ?>%</span>
                <?php endif; ?>
                
                <ul class="package-features">
                    <li>
                        <i class="bi bi-check-circle text-success me-2"></i>
                        <?php if ($plan['is_unlimited']): ?>
                            <?= trp('unlimited') ?>
                        <?php else: ?>
                            <?= $plan['listings_count'] ?> <?= trp('listings') ?>
                        <?php endif; ?>
                    </li>
                    <li>
                        <i class="bi bi-check-circle text-success me-2"></i>
                        <?= $plan['duration_days'] ?> <?= trp('days') ?>
                    </li>
                    <?php if (!empty($plan['is_trusted_advertiser'])): ?>
                    <li>
                        <i class="bi bi-patch-check-fill text-success me-2"></i>
                        <strong class="text-success"><?= trp('trusted_advertiser') ?></strong>
                    </li>
                    <?php endif; ?>
                    <?php if (!empty($plan['allow_city_notifications'])): ?>
                    <li>
                        <i class="bi bi-geo-alt-fill text-primary me-2"></i>
                        <?= trp('city_notifications') ?>
                    </li>
                    <?php endif; ?>
                    <?php if (!empty($plan['allow_region_notifications'])): ?>
                    <li>
                        <i class="bi bi-map-fill text-primary me-2"></i>
                        <?= trp('region_notifications') ?>
                    </li>
                    <?php endif; ?>
                    <li>
                        <i class="bi bi-check-circle text-success me-2"></i>
                        <?= trp('full_support') ?>
                    </li>
                </ul>
                
                <?php if (!$isLoggedIn): ?>
                <a href="login.php?redirect=packages.php?category=<?= $category ?>" class="btn btn-outline-primary w-100">
                    <?= trp('login_to_order') ?>
                </a>
                <?php elseif (isset($pendingRequests[$plan['id']])): ?>
                <button class="btn btn-secondary w-100" disabled>
                    <i class="bi bi-clock me-2"></i><?= trp('pending_approval') ?>
                </button>
                <?php else: ?>
                <a href="checkout.php?plan_id=<?= $plan['id'] ?>" class="btn <?= $plan['is_featured'] ? 'btn-primary' : 'btn-outline-primary' ?> w-100">
                    <i class="bi bi-cart-check me-2"></i><?= trp('buy_now') ?>
                </a>
                <?php endif; ?>
            </div>
        </div>
        <?php endforeach; ?>
    </div>
    
    <?php if (empty($plans)): ?>
    <div class="text-center py-5">
        <i class="bi bi-box-seam display-1 text-muted"></i>
        <p class="mt-3 text-muted"><?= trp('no_packages') ?></p>
    </div>
    <?php endif; ?>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
