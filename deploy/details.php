<?php
require_once 'config.php';

$type = $_GET['type'] ?? 'property';
$id = (int)($_GET['id'] ?? 0);
$lang = $_SESSION['lang'] ?? 'ar';

if (!$id) {
    header('Location: ' . SITE_URL);
    exit;
}

$endpoint = $type === 'car' ? 'cars' : 'properties';
$listing = apiCall("{$endpoint}/{$id}");

if (!$listing['success'] || empty($listing['data'])) {
    header('Location: ' . SITE_URL);
    exit;
}

$data = $listing['data'];

// Get localized names
$cityName = $data['city_name_' . $lang] ?? $data['city_name_ar'] ?? '';
$regionName = $data['region_name_' . $lang] ?? $data['region_name_ar'] ?? '';
$pageTitle = $data['title'] ?? ($type === 'car' ? ($lang == 'he' ? 'רכב להשכרה' : ($lang == 'en' ? 'Car for Rent' : 'سيارة للإيجار')) : ($lang == 'he' ? 'נכס להשכרה' : ($lang == 'en' ? 'Property for Rent' : 'عقار للإيجار')));

// Property type names
$propertyTypes = [
    'apartment' => ['ar' => 'شقة', 'he' => 'דירה', 'en' => 'Apartment'],
    'villa_chalet' => ['ar' => 'فيلا/شاليه', 'he' => 'וילה', 'en' => 'Villa'],
    'shop_office' => ['ar' => 'محل/مكتب', 'he' => 'חנות', 'en' => 'Shop'],
    'student_housing' => ['ar' => 'سكن طلاب', 'he' => 'דיור סטודנטים', 'en' => 'Student'],
    'land' => ['ar' => 'أرض', 'he' => 'קרקע', 'en' => 'Land'],
    'daily' => ['ar' => 'يومي', 'he' => 'יומי', 'en' => 'Daily'],
    'wedding' => ['ar' => 'أعراس', 'he' => 'חתונות', 'en' => 'Wedding'],
    'tourism' => ['ar' => 'سياحة', 'he' => 'תיירות', 'en' => 'Tourism'],
];
$propertyType = $data['property_type'] ?? $data['usage_type'] ?? '';
$typeName = $propertyTypes[$propertyType][$lang] ?? $propertyTypes[$propertyType]['ar'] ?? $propertyType;

// Time ago function
function timeAgo($datetime, $lang) {
    $time = strtotime($datetime);
    $diff = time() - $time;
    $days = floor($diff / 86400);
    $hours = floor($diff / 3600);
    $minutes = floor($diff / 60);
    
    if ($days > 0) {
        if ($lang == 'he') return "לפני $days ימים";
        if ($lang == 'en') return "$days days ago";
        return "منذ $days يوم";
    } elseif ($hours > 0) {
        if ($lang == 'he') return "לפני $hours שעות";
        if ($lang == 'en') return "$hours hours ago";
        return "منذ $hours ساعة";
    } else {
        if ($lang == 'he') return "לפני $minutes דקות";
        if ($lang == 'en') return "$minutes minutes ago";
        return "منذ $minutes دقيقة";
    }
}

// Translations
$t = [
    'home' => ['ar' => 'الرئيسية', 'he' => 'ראשי', 'en' => 'Home'],
    'cars' => ['ar' => 'السيارات', 'he' => 'רכבים', 'en' => 'Cars'],
    'properties' => ['ar' => 'العقارات', 'he' => 'נכסים', 'en' => 'Properties'],
    'featured' => ['ar' => 'مميز', 'he' => 'מומלץ', 'en' => 'Featured'],
    'details' => ['ar' => 'التفاصيل', 'he' => 'פרטים', 'en' => 'Details'],
    'description' => ['ar' => 'الوصف', 'he' => 'תיאור', 'en' => 'Description'],
    'bedrooms' => ['ar' => 'غرف النوم', 'he' => 'חדרי שינה', 'en' => 'Bedrooms'],
    'bathrooms' => ['ar' => 'الحمامات', 'he' => 'חדרי אמבטיה', 'en' => 'Bathrooms'],
    'area' => ['ar' => 'المساحة', 'he' => 'שטח', 'en' => 'Area'],
    'floor' => ['ar' => 'الطابق', 'he' => 'קומה', 'en' => 'Floor'],
    'model' => ['ar' => 'الموديل', 'he' => 'דגם', 'en' => 'Model'],
    'gearbox' => ['ar' => 'ناقل الحركة', 'he' => 'תיבת הילוכים', 'en' => 'Gearbox'],
    'automatic' => ['ar' => 'أوتوماتيك', 'he' => 'אוטומטי', 'en' => 'Automatic'],
    'manual' => ['ar' => 'عادي', 'he' => 'ידני', 'en' => 'Manual'],
    'driver' => ['ar' => 'السائق', 'he' => 'נהג', 'en' => 'Driver'],
    'with_driver' => ['ar' => 'مع سائق', 'he' => 'עם נהג', 'en' => 'With driver'],
    'without_driver' => ['ar' => 'بدون سائق', 'he' => 'בלי נהג', 'en' => 'Without driver'],
    'daily' => ['ar' => 'يومي', 'he' => 'יומי', 'en' => 'Daily'],
    'weekly' => ['ar' => 'أسبوعي', 'he' => 'שבועי', 'en' => 'Weekly'],
    'monthly' => ['ar' => 'شهري', 'he' => 'חודשי', 'en' => 'Monthly'],
    'call' => ['ar' => 'اتصل', 'he' => 'התקשר', 'en' => 'Call'],
    'whatsapp' => ['ar' => 'واتساب', 'he' => 'וואטסאפ', 'en' => 'WhatsApp'],
    'share' => ['ar' => 'مشاركة', 'he' => 'שתף', 'en' => 'Share'],
    'report' => ['ar' => 'إبلاغ', 'he' => 'דווח', 'en' => 'Report'],
    'advertiser' => ['ar' => 'المعلن', 'he' => 'המפרסם', 'en' => 'Advertiser'],
    'download_app' => ['ar' => 'حمّل التطبيق', 'he' => 'הורד את האפליקציה', 'en' => 'Download App'],
    'tip' => ['ar' => 'نصيحة', 'he' => 'טיפ', 'en' => 'Tip'],
    'app_tip' => ['ar' => 'استخدم تطبيق Rento Go للحصول على أفضل تجربة!', 'he' => 'השתמש באפליקציית Rento Go לחוויה הטובה ביותר!', 'en' => 'Use Rento Go app for the best experience!'],
];
function tr($key, $translations, $lang) {
    return $translations[$key][$lang] ?? $translations[$key]['ar'] ?? $key;
}

require_once 'includes/header.php';
?>

<style>
.details-hero {
    position: relative;
    height: 450px;
    background: #1a1a1a;
    overflow: hidden;
}
.details-hero-image {
    width: 100%;
    height: 100%;
    object-fit: cover;
}
.details-hero-nav {
    position: absolute;
    top: 20px;
    left: 20px;
    right: 20px;
    display: flex;
    justify-content: space-between;
    z-index: 10;
}
.details-hero-btn {
    width: 44px;
    height: 44px;
    background: rgba(0,0,0,0.5);
    border: none;
    border-radius: 12px;
    color: white;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    transition: background 0.3s;
}
.details-hero-btn:hover {
    background: rgba(0,0,0,0.7);
    color: white;
}
.details-hero-btn.active {
    color: #ff4757;
}
.details-hero-dots {
    position: absolute;
    bottom: 70px;
    left: 50%;
    transform: translateX(-50%);
    display: flex;
    gap: 8px;
}
.details-hero-dot {
    width: 8px;
    height: 8px;
    background: rgba(255,255,255,0.5);
    border-radius: 4px;
    cursor: pointer;
    transition: all 0.3s;
}
.details-hero-dot.active {
    width: 24px;
    background: var(--bs-primary);
}
.details-card {
    background: white;
    border-radius: 30px 30px 0 0;
    margin-top: -50px;
    position: relative;
    z-index: 5;
    padding: 24px;
    min-height: 60vh;
}
.details-tag {
    display: inline-block;
    padding: 6px 14px;
    background: #f1f3f5;
    border: 1px solid #e9ecef;
    border-radius: 20px;
    font-size: 13px;
    color: #495057;
    margin-left: 8px;
    margin-bottom: 8px;
}
.details-badge {
    display: inline-block;
    padding: 6px 14px;
    background: var(--bs-primary);
    border-radius: 6px;
    font-size: 12px;
    color: white;
    font-weight: bold;
}
.details-price {
    font-size: 24px;
    font-weight: bold;
    color: var(--bs-primary);
}
.details-title {
    font-size: 26px;
    font-weight: bold;
    margin: 16px 0 12px;
    color: #212529;
}
.details-meta {
    display: flex;
    gap: 20px;
    color: #6c757d;
    font-size: 14px;
    margin-bottom: 24px;
}
.details-meta i {
    margin-left: 4px;
}
.details-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
    margin-bottom: 24px;
}
.details-box {
    background: #f8f9fa;
    border-radius: 12px;
    padding: 14px;
    display: flex;
    align-items: center;
    gap: 12px;
}
.details-box-icon {
    width: 40px;
    height: 40px;
    background: var(--bs-primary);
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 18px;
}
.details-box-label {
    font-size: 12px;
    color: #6c757d;
}
.details-box-value {
    font-size: 16px;
    font-weight: bold;
    color: #212529;
}
.details-section-title {
    font-size: 18px;
    font-weight: bold;
    margin-bottom: 12px;
    color: #212529;
}
.details-description {
    font-size: 15px;
    line-height: 1.7;
    color: #495057;
}
.details-prices {
    background: rgba(var(--bs-primary-rgb), 0.05);
    border: 1px solid rgba(var(--bs-primary-rgb), 0.2);
    border-radius: 12px;
    padding: 16px;
    display: flex;
    justify-content: space-around;
    margin-bottom: 24px;
}
.details-price-item {
    text-align: center;
}
.details-price-amount {
    font-size: 20px;
    font-weight: bold;
    color: var(--bs-primary);
}
.details-price-label {
    font-size: 12px;
    color: #6c757d;
}
.details-bottom-bar {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    background: white;
    padding: 12px 20px;
    box-shadow: 0 -4px 20px rgba(0,0,0,0.1);
    z-index: 100;
    display: flex;
    gap: 10px;
}
.details-call-btn {
    flex: 2;
    background: var(--bs-primary);
    color: white;
    border: none;
    border-radius: 12px;
    padding: 14px;
    font-size: 16px;
    font-weight: bold;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
}
.details-action-btn {
    width: 50px;
    height: 50px;
    border-radius: 12px;
    border: 1px solid rgba(0,0,0,0.1);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
    cursor: pointer;
}
.details-action-btn.whatsapp {
    background: rgba(37, 211, 102, 0.1);
    color: #25d366;
    border-color: rgba(37, 211, 102, 0.3);
}
.details-action-btn.chat {
    background: rgba(var(--bs-primary-rgb), 0.1);
    color: var(--bs-primary);
    border-color: rgba(var(--bs-primary-rgb), 0.3);
}
body {
    padding-bottom: 80px;
}
@media (max-width: 768px) {
    .details-hero { height: 350px; }
    .details-grid { grid-template-columns: 1fr 1fr; }
}
</style>

<!-- Hero Image Section -->
<div class="details-hero">
    <?php 
    $images = $data['media'] ?? [];
    $mainImage = !empty($images[0]) ? UPLOAD_URL . $images[0]['file_path'] : 'assets/images/placeholder.jpg';
    ?>
    <img src="<?= $mainImage ?>" id="heroImage" class="details-hero-image" alt="<?= htmlspecialchars($pageTitle) ?>">
    
    <!-- Top Navigation -->
    <div class="details-hero-nav">
        <a href="javascript:history.back()" class="details-hero-btn">
            <i class="bi bi-arrow-<?= $lang == 'he' ? 'right' : 'left' ?>"></i>
        </a>
        <div class="d-flex gap-2">
            <button onclick="shareListing('<?= htmlspecialchars($pageTitle) ?>', window.location.href)" class="details-hero-btn">
                <i class="bi bi-share"></i>
            </button>
            <button class="details-hero-btn favorite-btn" data-id="<?= $id ?>" data-type="<?= $type ?>">
                <i class="bi bi-heart"></i>
            </button>
            <button class="details-hero-btn" onclick="alert('<?= tr('report', $t, $lang) ?>')">
                <i class="bi bi-flag"></i>
            </button>
        </div>
    </div>
    
    <!-- Image Dots -->
    <?php if (count($images) > 1): ?>
    <div class="details-hero-dots">
        <?php foreach ($images as $index => $img): ?>
        <div class="details-hero-dot <?= $index === 0 ? 'active' : '' ?>" 
             data-src="<?= UPLOAD_URL . $img['file_path'] ?>" 
             onclick="changeImage(this)"></div>
        <?php endforeach; ?>
    </div>
    <?php endif; ?>
</div>

<!-- Details Card -->
<div class="details-card">
    <!-- Tags + Price -->
    <div class="d-flex justify-content-between align-items-start flex-wrap mb-2">
        <div>
            <span class="details-tag"><?= htmlspecialchars($typeName) ?></span>
            <span class="details-tag"><?= htmlspecialchars($regionName) ?></span>
        </div>
        <div class="details-price">
            <?php if (!empty($data['price_daily'])): ?>
                <?= number_format($data['price_daily']) ?> ₪<small style="font-size:12px;color:#6c757d">/<?= tr('daily', $t, $lang) ?></small>
            <?php elseif (!empty($data['price_monthly'])): ?>
                <?= number_format($data['price_monthly']) ?> ₪<small style="font-size:12px;color:#6c757d">/<?= tr('monthly', $t, $lang) ?></small>
            <?php else: ?>
                <?= number_format($data['price'] ?? 0) ?> ₪
            <?php endif; ?>
        </div>
    </div>
    
    <!-- Featured Badge -->
    <?php if (!empty($data['is_trusted']) || !empty($data['owner_is_trusted'])): ?>
    <div class="mb-3">
        <span class="details-badge"><?= tr('featured', $t, $lang) ?></span>
    </div>
    <?php endif; ?>
    
    <!-- Title -->
    <h1 class="details-title"><?= htmlspecialchars($pageTitle) ?></h1>
    
    <!-- Location & Time -->
    <div class="details-meta">
        <span><i class="bi bi-geo-alt"></i> <?= htmlspecialchars($cityName) ?></span>
        <span><i class="bi bi-clock"></i> <?= timeAgo($data['created_at'] ?? 'now', $lang) ?></span>
    </div>
    
    <!-- Details Grid -->
    <div class="details-grid">
        <?php if ($type === 'property'): ?>
            <?php if (!empty($data['bedrooms'])): ?>
            <div class="details-box">
                <div class="details-box-icon"><i class="bi bi-door-open"></i></div>
                <div>
                    <div class="details-box-label"><?= tr('bedrooms', $t, $lang) ?></div>
                    <div class="details-box-value"><?= $data['bedrooms'] ?></div>
                </div>
            </div>
            <?php endif; ?>
            <?php if (!empty($data['bathrooms'])): ?>
            <div class="details-box">
                <div class="details-box-icon"><i class="bi bi-droplet"></i></div>
                <div>
                    <div class="details-box-label"><?= tr('bathrooms', $t, $lang) ?></div>
                    <div class="details-box-value"><?= $data['bathrooms'] ?></div>
                </div>
            </div>
            <?php endif; ?>
            <?php if (!empty($data['area_m2'])): ?>
            <div class="details-box">
                <div class="details-box-icon"><i class="bi bi-arrows-angle-expand"></i></div>
                <div>
                    <div class="details-box-label"><?= tr('area', $t, $lang) ?></div>
                    <div class="details-box-value"><?= $data['area_m2'] ?> m²</div>
                </div>
            </div>
            <?php endif; ?>
            <?php if (!empty($data['floor'])): ?>
            <div class="details-box">
                <div class="details-box-icon"><i class="bi bi-layers"></i></div>
                <div>
                    <div class="details-box-label"><?= tr('floor', $t, $lang) ?></div>
                    <div class="details-box-value"><?= $data['floor'] ?></div>
                </div>
            </div>
            <?php endif; ?>
        <?php else: ?>
            <?php if (!empty($data['model'])): ?>
            <div class="details-box">
                <div class="details-box-icon"><i class="bi bi-car-front"></i></div>
                <div>
                    <div class="details-box-label"><?= tr('model', $t, $lang) ?></div>
                    <div class="details-box-value"><?= htmlspecialchars($data['model']) ?></div>
                </div>
            </div>
            <?php endif; ?>
            <?php if (!empty($data['gearbox'])): ?>
            <div class="details-box">
                <div class="details-box-icon"><i class="bi bi-gear"></i></div>
                <div>
                    <div class="details-box-label"><?= tr('gearbox', $t, $lang) ?></div>
                    <div class="details-box-value"><?= $data['gearbox'] == 'automatic' ? tr('automatic', $t, $lang) : tr('manual', $t, $lang) ?></div>
                </div>
            </div>
            <?php endif; ?>
            <div class="details-box">
                <div class="details-box-icon"><i class="bi bi-person"></i></div>
                <div>
                    <div class="details-box-label"><?= tr('driver', $t, $lang) ?></div>
                    <div class="details-box-value"><?= !empty($data['with_driver']) ? tr('with_driver', $t, $lang) : tr('without_driver', $t, $lang) ?></div>
                </div>
            </div>
        <?php endif; ?>
    </div>
    
    <!-- Rental Prices (daily/weekly/monthly) for both properties and cars -->
    <?php if (!empty($data['price_daily']) || !empty($data['price_weekly']) || !empty($data['price_monthly'])): ?>
    <div class="details-prices">
        <?php if (!empty($data['price_daily'])): ?>
        <div class="details-price-item">
            <div class="details-price-amount"><?= number_format($data['price_daily']) ?> ₪</div>
            <div class="details-price-label"><?= tr('daily', $t, $lang) ?></div>
        </div>
        <?php endif; ?>
        <?php if (!empty($data['price_weekly'])): ?>
        <div class="details-price-item">
            <div class="details-price-amount"><?= number_format($data['price_weekly']) ?> ₪</div>
            <div class="details-price-label"><?= tr('weekly', $t, $lang) ?></div>
        </div>
        <?php endif; ?>
        <?php if (!empty($data['price_monthly'])): ?>
        <div class="details-price-item">
            <div class="details-price-amount"><?= number_format($data['price_monthly']) ?> ₪</div>
            <div class="details-price-label"><?= tr('monthly', $t, $lang) ?></div>
        </div>
        <?php endif; ?>
    </div>
    <?php endif; ?>
    
    <!-- Description -->
    <?php if (!empty($data['bio'])): ?>
    <h3 class="details-section-title"><?= tr('description', $t, $lang) ?></h3>
    <p class="details-description"><?= nl2br(htmlspecialchars($data['bio'])) ?></p>
    <?php endif; ?>
    
    <!-- App Tip -->
    <div class="alert alert-info mt-4">
        <i class="bi bi-info-circle me-2"></i>
        <strong><?= tr('tip', $t, $lang) ?>:</strong> <?= tr('app_tip', $t, $lang) ?>
        <div class="mt-2">
            <a href="download.php" class="btn btn-sm btn-primary"><?= tr('download_app', $t, $lang) ?></a>
        </div>
    </div>
</div>

<!-- Bottom Action Bar -->
<div class="details-bottom-bar">
    <a href="tel:<?= $data['contact_phone'] ?? '' ?>" class="details-call-btn text-decoration-none">
        <i class="bi bi-telephone"></i>
        <?= tr('call', $t, $lang) ?>: <?= $data['contact_phone'] ?? '' ?>
    </a>
    <a href="https://wa.me/<?= preg_replace('/[^0-9]/', '', $data['whatsapp'] ?? $data['contact_phone'] ?? '') ?>" 
       class="details-action-btn whatsapp text-decoration-none" target="_blank">
        <i class="bi bi-whatsapp"></i>
    </a>
    <a href="chat.php?listing_type=<?= $type ?>&listing_id=<?= $id ?>" class="details-action-btn chat text-decoration-none">
        <i class="bi bi-chat"></i>
    </a>
</div>

<script>
function changeImage(dot) {
    const src = dot.dataset.src;
    document.getElementById('heroImage').src = src;
    document.querySelectorAll('.details-hero-dot').forEach(d => d.classList.remove('active'));
    dot.classList.add('active');
}

function shareListing(title, url) {
    if (navigator.share) {
        navigator.share({ title: title, url: url });
    } else {
        navigator.clipboard.writeText(url);
        alert('<?= $lang == 'he' ? 'הקישור הועתק' : ($lang == 'en' ? 'Link copied' : 'تم نسخ الرابط') ?>');
    }
}
</script>

<?php require_once 'includes/footer.php'; ?>
