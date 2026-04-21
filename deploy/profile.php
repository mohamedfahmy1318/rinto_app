<?php
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/includes/translations.php';
$pageTitle = __('my_account');
$extraCss = ['assets/css/profile.css'];
$extraJs = ['assets/js/profile.js'];

// Check if logged in
if (!isset($_SESSION['user']) || !isset($_SESSION['token'])) {
    header('Location: login.php');
    exit;
}

$user = $_SESSION['user'];
$token = $_SESSION['token'];
$error = '';
$success = '';

// Handle logout
if (isset($_GET['action']) && $_GET['action'] === 'logout') {
    unset($_SESSION['user']);
    unset($_SESSION['token']);
    header('Location: ' . SITE_URL);
    exit;
}

// Fetch user's listings
function apiCallWithAuth($endpoint, $token) {
    $url = API_URL . '/' . ltrim($endpoint, '/');
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 30);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Accept: application/json',
        'Authorization: Bearer ' . $token
    ]);
    
    $response = curl_exec($ch);
    curl_close($ch);
    
    return json_decode($response, true);
}

$myListings = apiCallWithAuth('me/listings', $token);
$listings = $myListings['data'] ?? [];

// Fetch user subscriptions
$subscriptionsResponse = apiCallWithAuth('subscriptions', $token);
$subscriptions = $subscriptionsResponse['data'] ?? [];

// Separate active subscriptions by category
$activeSubscriptions = [];
foreach ($subscriptions as $sub) {
    if (!($sub['is_expired'] ?? true) && ($sub['status'] ?? '') === 'active') {
        $category = $sub['category'] ?? 'properties';
        $activeSubscriptions[$category] = $sub;
    }
}

require_once __DIR__ . '/includes/header.php';
?>

<div class="profile-container">
    <div class="container">
        <div class="row">
            <!-- Sidebar -->
            <div class="col-lg-4 mb-4">
                <div class="profile-sidebar">
                    <div class="text-center mb-4">
                        <div class="profile-avatar">
                            <?php if (!empty($user['profile_image'])): ?>
                            <img src="<?= UPLOAD_URL . $user['profile_image'] ?>" alt="">
                            <?php else: ?>
                            <i class="bi bi-person"></i>
                            <?php endif; ?>
                        </div>
                        <h4 class="profile-name"><?= htmlspecialchars($user['name'] ?? '') ?></h4>
                        <p class="profile-phone"><?= htmlspecialchars($user['phone'] ?? '') ?></p>
                        <?php if ($user['is_trusted'] ?? false): ?>
                        <span class="verified-badge"><i class="bi bi-patch-check-fill"></i><?= __('verified') ?></span>
                        <?php endif; ?>
                    </div>
                    
                    <div class="profile-nav">
                        <div class="list-group">
                            <a href="#profile" class="list-group-item list-group-item-action active" data-bs-toggle="list">
                                <i class="bi bi-person"></i><?= __('my_info') ?>
                            </a>
                            <a href="#subscriptions" class="list-group-item list-group-item-action" data-bs-toggle="list">
                                <i class="bi bi-box-seam"></i><?= __('my_subscriptions') ?>
                            </a>
                            <a href="#listings" class="list-group-item list-group-item-action" data-bs-toggle="list">
                                <i class="bi bi-grid-3x3-gap"></i><?= __('my_listings') ?>
                                <span class="listings-count"><?= count($listings) ?></span>
                            </a>
                            <a href="#favorites" class="list-group-item list-group-item-action" data-bs-toggle="list">
                                <i class="bi bi-heart"></i><?= __('favorites') ?>
                            </a>
                            <a href="#settings" class="list-group-item list-group-item-action" data-bs-toggle="list">
                                <i class="bi bi-gear"></i><?= __('settings') ?>
                            </a>
                            <a href="?action=logout" class="list-group-item list-group-item-action text-danger">
                                <i class="bi bi-box-arrow-left"></i><?= __('logout') ?>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Content -->
            <div class="col-lg-8">
                <div class="tab-content">
                    <!-- Profile Info -->
                    <div class="tab-pane fade show active" id="profile">
                        <div class="profile-card">
                            <h5><i class="bi bi-person-badge"></i><?= __('personal_info') ?></h5>
                            
                            <div class="info-grid mt-4">
                                <div class="info-item">
                                    <label><?= __('full_name') ?></label>
                                    <p><?= htmlspecialchars($user['name'] ?? '-') ?></p>
                                </div>
                                <div class="info-item">
                                    <label><?= __('account_type') ?></label>
                                    <p><?= __($user['user_type'] ?? 'renter') ?></p>
                                </div>
                                <div class="info-item">
                                    <label><?= __('phone') ?></label>
                                    <p dir="ltr"><?= htmlspecialchars($user['phone'] ?? '-') ?></p>
                                </div>
                                <div class="info-item">
                                    <label><?= __('email') ?></label>
                                    <p dir="ltr"><?= htmlspecialchars($user['email'] ?? '-') ?></p>
                                </div>
                                <div class="info-item">
                                    <label><?= __('registration_date') ?></label>
                                    <p><?= date('Y/m/d', strtotime($user['created_at'] ?? 'now')) ?></p>
                                </div>
                                <div class="info-item">
                                    <label><?= __('account_status') ?></label>
                                    <p><span class="badge bg-success"><?= __('active') ?></span></p>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Subscriptions -->
                    <div class="tab-pane fade" id="subscriptions">
                        <div class="profile-card">
                            <h5><i class="bi bi-box-seam"></i><?= __('my_subscriptions') ?></h5>
                            
                            <?php if (empty($activeSubscriptions)): ?>
                            <div class="empty-state">
                                <div class="empty-state-icon">
                                    <i class="bi bi-box-seam"></i>
                                </div>
                                <h6><?= __('no_active_subscription') ?></h6>
                                <div class="mt-3">
                                    <a href="packages.php" class="btn btn-primary"><?= __('subscribe_now') ?></a>
                                </div>
                            </div>
                            <?php else: ?>
                            <div class="row g-3 mt-3">
                                <?php foreach ($activeSubscriptions as $category => $sub): 
                                    $planName = $sub['plan_name_' . $lang] ?? $sub['plan_name_ar'] ?? '';
                                    $listingsUsed = $sub['listings_used'] ?? 0;
                                    $listingsLimit = $sub['listings_limit'] ?? 0;
                                    $isUnlimited = $sub['is_unlimited'] ?? false;
                                    $listingsRemaining = $isUnlimited ? __('unlimited') : max(0, $listingsLimit - $listingsUsed);
                                    $daysRemaining = $sub['days_remaining'] ?? 0;
                                    $categoryLabel = $category === 'properties' ? __('properties_sub') : __('cars_sub');
                                ?>
                                <div class="col-md-6">
                                    <div class="subscription-card" style="background: linear-gradient(135deg, var(--teal) 0%, var(--teal-dark) 100%); border-radius: 15px; padding: 1.5rem; color: white;">
                                        <div class="d-flex align-items-center justify-content-between mb-3">
                                            <div class="d-flex align-items-center">
                                                <i class="bi bi-<?= $category === 'properties' ? 'building' : 'car-front' ?> fs-4 me-2"></i>
                                                <span class="fw-bold"><?= __('subscription_for') ?> <?= $categoryLabel ?></span>
                                            </div>
                                            <span class="badge bg-white text-success"><?= __('active') ?></span>
                                        </div>
                                        
                                        <h5 class="mb-3"><?= htmlspecialchars($planName) ?></h5>
                                        
                                        <div class="row text-center g-2">
                                            <div class="col-4">
                                                <div class="bg-white bg-opacity-25 rounded p-2">
                                                    <div class="fs-4 fw-bold"><?= $listingsUsed ?></div>
                                                    <small><?= __('listings_used') ?></small>
                                                </div>
                                            </div>
                                            <div class="col-4">
                                                <div class="bg-white bg-opacity-25 rounded p-2">
                                                    <div class="fs-4 fw-bold"><?= $isUnlimited ? '∞' : $listingsRemaining ?></div>
                                                    <small><?= __('listings_remaining') ?></small>
                                                </div>
                                            </div>
                                            <div class="col-4">
                                                <div class="bg-white bg-opacity-25 rounded p-2">
                                                    <div class="fs-4 fw-bold"><?= $daysRemaining ?></div>
                                                    <small><?= __('days') ?></small>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <?php endforeach; ?>
                            </div>
                            
                            <div class="mt-4 text-center">
                                <a href="packages.php" class="btn btn-outline-primary">
                                    <i class="bi bi-plus-circle me-2"></i><?= __('subscribe_now') ?>
                                </a>
                            </div>
                            <?php endif; ?>
                        </div>
                    </div>
                    
                    <!-- Listings -->
                    <div class="tab-pane fade" id="listings">
                        <div class="profile-card">
                            <div class="listings-header">
                                <h5><i class="bi bi-grid-3x3-gap"></i><?= __('my_listings') ?></h5>
                                <div class="d-flex gap-2">
                                    <a href="add-property.php" class="btn btn-primary btn-sm">
                                        <i class="bi bi-building-add me-1"></i><?= __('add_property') ?>
                                    </a>
                                    <a href="add-car.php" class="btn btn-primary btn-sm">
                                        <i class="bi bi-car-front-fill me-1"></i><?= __('add_car') ?>
                                    </a>
                                </div>
                            </div>
                            
                            <?php if (empty($listings)): ?>
                            <div class="empty-state">
                                <div class="empty-state-icon">
                                    <i class="bi bi-inbox"></i>
                                </div>
                                <h6><?= __('no_listings') ?></h6>
                                <p class="text-muted small"><?= $lang === 'he' ? 'הוסף את המודעה הראשונה שלך' : ($lang === 'en' ? 'Add your first listing' : 'أضف إعلانك الأول') ?></p>
                            </div>
                            <?php else: ?>
                            <div class="listings-grid">
                                <?php foreach ($listings as $listing): ?>
                                <?php
                                $cityName = $listing['city_name_' . $lang] ?? $listing['city_name_ar'] ?? '';
                                $isExpired = !empty($listing['expires_at']) && strtotime($listing['expires_at']) < time();
                                $expiresAt = !empty($listing['expires_at']) ? date('Y-m-d', strtotime($listing['expires_at'])) : null;
                                $isRented = !empty($listing['is_rented']);
                                ?>
                                <div class="listing-card-profile <?= $isExpired ? 'expired' : '' ?> <?= $isRented ? 'rented' : '' ?>">
                                    <div class="card-img-wrapper">
                                        <img src="<?= htmlspecialchars($listing['thumbnail'] ?? UPLOAD_URL . 'placeholder.png') ?>" alt="">
                                        <div class="badges">
                                            <span class="badge badge-type">
                                                <i class="bi bi-<?= $listing['listing_type'] === 'property' ? 'building' : 'car-front' ?> me-1"></i>
                                                <?= __($listing['listing_type'] === 'property' ? 'property' : 'car') ?>
                                            </span>
                                            <?php if ($isRented && !$isExpired): ?>
                                            <span class="badge badge-status rented">
                                                <i class="bi bi-house-check me-1"></i><?= $lang === 'he' ? 'מושכר' : ($lang === 'en' ? 'Rented' : 'مؤجر') ?>
                                            </span>
                                            <?php elseif ($isExpired): ?>
                                            <span class="badge badge-status expired">
                                                <i class="bi bi-clock-history me-1"></i><?= $lang === 'he' ? 'פג תוקף' : ($lang === 'en' ? 'Expired' : 'منتهي') ?>
                                            </span>
                                            <?php else: ?>
                                            <span class="badge badge-status <?= $listing['status'] === 'active' ? 'active' : ($listing['status'] === 'pending_admin_review' ? 'pending' : '') ?>">
                                                <?php
                                                $statusKey = 'status_' . ($listing['status'] === 'pending_admin_review' ? 'pending' : $listing['status']);
                                                echo ($listing['status'] === 'active' ? '✓ ' : ($listing['status'] === 'pending_admin_review' ? '⏳ ' : ($listing['status'] === 'rejected' ? '✗ ' : '')));
                                                echo __($statusKey);
                                                ?>
                                            </span>
                                            <?php endif; ?>
                                        </div>
                                        <?php if ($isExpired): ?>
                                        <div class="expired-overlay">
                                            <i class="bi bi-clock-history"></i>
                                        </div>
                                        <?php endif; ?>
                                    </div>
                                    <div class="card-body">
                                        <h6 class="listing-title"><?= htmlspecialchars($listing['title'] ?? __('no_title')) ?></h6>
                                        <p class="listing-location">
                                            <i class="bi bi-geo-alt-fill"></i>
                                            <?= htmlspecialchars($cityName) ?>
                                        </p>
                                        <p class="listing-price">
                                            <?php if ($listing['listing_type'] === 'car' && !empty($listing['price_daily'])): ?>
                                                <?= number_format($listing['price_daily']) ?> ₪ <small>/يومي</small>
                                            <?php else: ?>
                                                <?= number_format($listing['price'] ?? 0) ?> ₪
                                            <?php endif; ?>
                                        </p>
                                        <?php if ($expiresAt && !$isExpired): ?>
                                        <p class="listing-expires small text-muted">
                                            <i class="bi bi-calendar-event me-1"></i>
                                            <?= $lang === 'he' ? 'תוקף עד:' : ($lang === 'en' ? 'Expires:' : 'ينتهي:') ?> <?= $expiresAt ?>
                                        </p>
                                        <?php endif; ?>
                                    </div>
                                    <div class="card-footer">
                                        <?php if ($isExpired): ?>
                                        <button class="btn-republish" onclick="republishListing(<?= $listing['id'] ?>, '<?= $listing['listing_type'] ?>')">
                                            <i class="bi bi-arrow-repeat me-1"></i><?= $lang === 'he' ? 'פרסם מחדש' : ($lang === 'en' ? 'Republish' : 'إعادة نشر') ?>
                                        </button>
                                        <?php elseif ($listing['status'] === 'active'): ?>
                                        <button class="btn-toggle-rented <?= $isRented ? 'is-rented' : '' ?>" onclick="toggleRented(<?= $listing['id'] ?>, '<?= $listing['listing_type'] ?>')">
                                            <i class="bi bi-<?= $isRented ? 'check-circle' : 'house-check' ?> me-1"></i>
                                            <?= $isRented 
                                                ? ($lang === 'he' ? 'סמן כזמין' : ($lang === 'en' ? 'Mark Available' : 'تحديد كمتاح'))
                                                : ($lang === 'he' ? 'סמן כמושכר' : ($lang === 'en' ? 'Mark Rented' : 'تحديد كمؤجر'))
                                            ?>
                                        </button>
                                        <div class="btn-group-small">
                                            <a href="details.php?type=<?= $listing['listing_type'] ?>&id=<?= $listing['id'] ?>" class="btn-view">
                                                <i class="bi bi-eye"></i>
                                            </a>
                                            <a href="edit-listing.php?type=<?= $listing['listing_type'] ?>&id=<?= $listing['id'] ?>" class="btn-edit">
                                                <i class="bi bi-pencil"></i>
                                            </a>
                                        </div>
                                        <?php else: ?>
                                        <a href="details.php?type=<?= $listing['listing_type'] ?>&id=<?= $listing['id'] ?>" class="btn-view">
                                            <i class="bi bi-eye me-1"></i><?= __('view') ?>
                                        </a>
                                        <a href="edit-listing.php?type=<?= $listing['listing_type'] ?>&id=<?= $listing['id'] ?>" class="btn-edit">
                                            <i class="bi bi-pencil"></i>
                                        </a>
                                        <?php endif; ?>
                                    </div>
                                </div>
                                <?php endforeach; ?>
                            </div>
                            <?php endif; ?>
                        </div>
                    </div>
                    
                    <!-- Favorites -->
                    <div class="tab-pane fade" id="favorites">
                        <div class="profile-card">
                            <h5><i class="bi bi-heart"></i><?= __('favorites') ?></h5>
                            <div class="empty-state">
                                <div class="empty-state-icon">
                                    <i class="bi bi-heart"></i>
                                </div>
                                <h6><?= __('no_favorites') ?></h6>
                                <div class="mt-3">
                                    <a href="properties.php" class="btn btn-outline-primary me-2"><?= __('browse_properties') ?></a>
                                    <a href="cars.php" class="btn btn-outline-primary"><?= __('browse_cars') ?></a>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Settings -->
                    <div class="tab-pane fade" id="settings">
                        <!-- Edit Profile -->
                        <div class="profile-card mb-4">
                            <h5><i class="bi bi-person-gear me-2"></i><?= $lang === 'he' ? 'עריכת פרופיל' : ($lang === 'en' ? 'Edit Profile' : 'تعديل الملف الشخصي') ?></h5>
                            
                            <form id="editProfileForm" class="mt-4">
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label"><?= $lang === 'he' ? 'שם מלא' : ($lang === 'en' ? 'Full Name' : 'الاسم الكامل') ?></label>
                                        <input type="text" class="form-control" name="name" value="<?= htmlspecialchars($user['name'] ?? '') ?>" required>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label"><?= $lang === 'he' ? 'אימייל' : ($lang === 'en' ? 'Email' : 'البريد الإلكتروني') ?></label>
                                        <input type="email" class="form-control" name="email" value="<?= htmlspecialchars($user['email'] ?? '') ?>">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label"><?= $lang === 'he' ? 'טלפון' : ($lang === 'en' ? 'Phone' : 'رقم الهاتف') ?></label>
                                        <input type="tel" class="form-control" name="phone" value="<?= htmlspecialchars($user['phone'] ?? '') ?>" dir="ltr" readonly>
                                        <small class="text-muted"><?= $lang === 'he' ? 'לא ניתן לשנות' : ($lang === 'en' ? 'Cannot be changed' : 'لا يمكن تغييره') ?></small>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label"><?= $lang === 'he' ? 'שם חברה (אופציונלי)' : ($lang === 'en' ? 'Company Name (Optional)' : 'اسم الشركة (اختياري)') ?></label>
                                        <input type="text" class="form-control" name="company_name" value="<?= htmlspecialchars($user['company_name'] ?? '') ?>">
                                    </div>
                                    <div class="col-12">
                                        <button type="submit" class="btn btn-primary">
                                            <i class="bi bi-check-lg me-1"></i><?= $lang === 'he' ? 'שמור שינויים' : ($lang === 'en' ? 'Save Changes' : 'حفظ التغييرات') ?>
                                        </button>
                                    </div>
                                </div>
                            </form>
                        </div>
                        
                        <!-- Change Password -->
                        <div class="profile-card mb-4">
                            <h5><i class="bi bi-key me-2"></i><?= $lang === 'he' ? 'שינוי סיסמה' : ($lang === 'en' ? 'Change Password' : 'تغيير كلمة المرور') ?></h5>
                            
                            <form id="changePasswordForm" class="mt-4">
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label"><?= $lang === 'he' ? 'סיסמה נוכחית' : ($lang === 'en' ? 'Current Password' : 'كلمة المرور الحالية') ?></label>
                                        <input type="password" class="form-control" name="current_password" required>
                                    </div>
                                    <div class="col-md-6"></div>
                                    <div class="col-md-6">
                                        <label class="form-label"><?= $lang === 'he' ? 'סיסמה חדשה' : ($lang === 'en' ? 'New Password' : 'كلمة المرور الجديدة') ?></label>
                                        <input type="password" class="form-control" name="new_password" required minlength="6">
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label"><?= $lang === 'he' ? 'אישור סיסמה' : ($lang === 'en' ? 'Confirm Password' : 'تأكيد كلمة المرور') ?></label>
                                        <input type="password" class="form-control" name="confirm_password" required>
                                    </div>
                                    <div class="col-12">
                                        <button type="submit" class="btn btn-warning">
                                            <i class="bi bi-key me-1"></i><?= $lang === 'he' ? 'שנה סיסמה' : ($lang === 'en' ? 'Change Password' : 'تغيير كلمة المرور') ?>
                                        </button>
                                    </div>
                                </div>
                            </form>
                        </div>
                        
                        <!-- Preferences -->
                        <div class="profile-card mb-4">
                            <h5><i class="bi bi-sliders me-2"></i><?= $lang === 'he' ? 'העדפות' : 'التفضيلات' ?></h5>
                            
                            <div class="mt-4">
                                <div class="setting-item d-flex justify-content-between align-items-center py-3 border-bottom">
                                    <div>
                                        <h6 class="mb-1"><?= $lang === 'he' ? 'שפה' : 'اللغة' ?></h6>
                                        <small class="text-muted"><?= $lang === 'he' ? 'שפת התצוגה' : 'لغة العرض' ?></small>
                                    </div>
                                    <select class="form-select w-auto" id="languageSelect" onchange="window.location.href='?lang='+this.value">
                                        <option value="ar" <?= $lang === 'ar' ? 'selected' : '' ?>>العربية</option>
                                        <option value="he" <?= $lang === 'he' ? 'selected' : '' ?>>עברית</option>
                                        <option value="en" <?= $lang === 'en' ? 'selected' : '' ?>>English</option>
                                    </select>
                                </div>
                                
                                <div class="setting-item d-flex justify-content-between align-items-center py-3 border-bottom">
                                    <div>
                                        <h6 class="mb-1"><?= $lang === 'he' ? 'התראות' : 'الإشعارات' ?></h6>
                                        <small class="text-muted"><?= $lang === 'he' ? 'קבל התראות על מודעות חדשות' : 'استقبال إشعارات للإعلانات الجديدة' ?></small>
                                    </div>
                                    <div class="form-check form-switch">
                                        <input class="form-check-input" type="checkbox" id="notificationToggle" <?= ($user['notifications_enabled'] ?? true) ? 'checked' : '' ?>>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <!-- Danger Zone -->
                        <div class="profile-card border-danger">
                            <h5 class="text-danger"><i class="bi bi-exclamation-triangle me-2"></i><?= $lang === 'he' ? 'אזור מסוכן' : 'منطقة الخطر' ?></h5>
                            
                            <div class="mt-4">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h6><?= $lang === 'he' ? 'התנתקות' : 'تسجيل الخروج' ?></h6>
                                        <small class="text-muted"><?= $lang === 'he' ? 'התנתק מהחשבון שלך' : 'الخروج من حسابك' ?></small>
                                    </div>
                                    <a href="?action=logout" class="btn btn-outline-danger">
                                        <i class="bi bi-box-arrow-left me-1"></i><?= $lang === 'he' ? 'התנתק' : 'خروج' ?>
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<style>
.listing-card-profile.expired {
    opacity: 0.8;
}
.listing-card-profile.expired .card-img-wrapper {
    position: relative;
}
.expired-overlay {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(0,0,0,0.4);
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 2rem;
}
.badge-status.expired {
    background: #dc3545 !important;
    color: white;
}
.btn-republish {
    width: 100%;
    background: linear-gradient(135deg, var(--teal) 0%, var(--teal-dark) 100%);
    color: white;
    border: none;
    padding: 8px 16px;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 600;
    transition: all 0.3s;
}
.btn-republish:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0,128,128,0.3);
}
.listing-expires {
    margin-bottom: 0;
    font-size: 0.8rem;
}
.badge-status.rented {
    background: #fd7e14 !important;
    color: white;
}
.btn-toggle-rented {
    flex: 1;
    background: linear-gradient(135deg, #fd7e14 0%, #e65100 100%);
    color: white;
    border: none;
    padding: 8px 12px;
    border-radius: 8px;
    cursor: pointer;
    font-weight: 600;
    font-size: 0.85rem;
    transition: all 0.3s;
}
.btn-toggle-rented.is-rented {
    background: linear-gradient(135deg, #28a745 0%, #1e7e34 100%);
}
.btn-toggle-rented:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(253,126,20,0.3);
}
.btn-toggle-rented.is-rented:hover {
    box-shadow: 0 4px 12px rgba(40,167,69,0.3);
}
.btn-group-small {
    display: flex;
    gap: 8px;
}
.btn-group-small .btn-view,
.btn-group-small .btn-edit {
    padding: 8px 12px;
    border-radius: 8px;
}
.card-footer {
    display: flex;
    gap: 8px;
    align-items: center;
}
</style>

<script>
function republishListing(id, type) {
    if (!confirm('<?= $lang === "he" ? "האם אתה בטוח שברצונך לפרסם מחדש?" : ($lang === "en" ? "Are you sure you want to republish?" : "هل أنت متأكد من إعادة نشر هذا الإعلان؟") ?>')) {
        return;
    }
    
    fetch('<?= API_URL ?>/listings/' + id + '/republish', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer <?= $token ?>'
        },
        body: JSON.stringify({ type: type })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            alert(data.data.message_<?= $lang ?> || '<?= $lang === "he" ? "פורסם מחדש בהצלחה" : ($lang === "en" ? "Republished successfully" : "تم إعادة النشر بنجاح") ?>');
            location.reload();
        } else {
            alert(data.message || data.data?.message_<?= $lang ?> || '<?= $lang === "he" ? "שגיאה" : ($lang === "en" ? "Error" : "حدث خطأ") ?>');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('<?= $lang === "he" ? "שגיאת רשת" : ($lang === "en" ? "Network error" : "خطأ في الاتصال") ?>');
    });
}

function toggleRented(id, type) {
    fetch('<?= API_URL ?>/listings/' + id + '/toggle-rented', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer <?= $token ?>'
        },
        body: JSON.stringify({ type: type })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            location.reload();
        } else {
            alert(data.message || '<?= $lang === "he" ? "שגיאה" : ($lang === "en" ? "Error" : "حدث خطأ") ?>');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('<?= $lang === "he" ? "שגיאת רשת" : ($lang === "en" ? "Network error" : "خطأ في الاتصال") ?>');
    });
}
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
