<?php
error_reporting(E_ALL);
ini_set('display_errors', 0);

require_once 'config.php';
require_once 'includes/translations.php';

// Page translations
$trc = [
    'cars' => ['ar' => 'السيارات', 'he' => 'רכבים', 'en' => 'Cars'],
    'home' => ['ar' => 'الرئيسية', 'he' => 'ראשי', 'en' => 'Home'],
    'filter_results' => ['ar' => 'تصفية النتائج', 'he' => 'סנן תוצאות', 'en' => 'Filter Results'],
    'usage_type' => ['ar' => 'نوع الاستخدام', 'he' => 'סוג שימוש', 'en' => 'Usage Type'],
    'all' => ['ar' => 'الكل', 'he' => 'הכל', 'en' => 'All'],
    'region' => ['ar' => 'المنطقة', 'he' => 'אזור', 'en' => 'Region'],
    'all_regions' => ['ar' => 'كل المناطق', 'he' => 'כל האזורים', 'en' => 'All Regions'],
    'daily_price' => ['ar' => 'السعر اليومي', 'he' => 'מחיר יומי', 'en' => 'Daily Price'],
    'city' => ['ar' => 'المدينة', 'he' => 'עיר', 'en' => 'City'],
    'all_cities' => ['ar' => 'كل المدن', 'he' => 'כל הערים', 'en' => 'All Cities'],
    'gearbox' => ['ar' => 'ناقل الحركة', 'he' => 'תיבת הילוכים', 'en' => 'Gearbox'],
    'all_gearbox' => ['ar' => 'الكل', 'he' => 'הכל', 'en' => 'All'],
    'with_driver' => ['ar' => 'مع سائق', 'he' => 'עם נהג', 'en' => 'With Driver'],
    'without_driver' => ['ar' => 'بدون سائق', 'he' => 'ללא נהג', 'en' => 'Without Driver'],
    'driver_option' => ['ar' => 'خيار السائق', 'he' => 'אפשרות נהג', 'en' => 'Driver Option'],
    'from' => ['ar' => 'من', 'he' => 'מ-', 'en' => 'From'],
    'to' => ['ar' => 'إلى', 'he' => 'עד', 'en' => 'To'],
    'search' => ['ar' => 'بحث', 'he' => 'חיפוש', 'en' => 'Search'],
    'brand_or_model' => ['ar' => 'ماركة أو موديل...', 'he' => 'יצרן או דגם...', 'en' => 'Brand or model...'],
    'clear_filters' => ['ar' => 'مسح الفلاتر', 'he' => 'נקה מסננים', 'en' => 'Clear Filters'],
    'result' => ['ar' => 'نتيجة', 'he' => 'תוצאה', 'en' => 'result'],
    'featured' => ['ar' => 'مميز', 'he' => 'מומלץ', 'en' => 'Featured'],
    'gold' => ['ar' => 'ذهبي', 'he' => 'זהב', 'en' => 'Gold'],
    'silver' => ['ar' => 'فضي', 'he' => 'כסף', 'en' => 'Silver'],
    'bronze' => ['ar' => 'برونزي', 'he' => 'ארד', 'en' => 'Bronze'],
    'car_for_rent' => ['ar' => 'سيارة للإيجار', 'he' => 'רכב להשכרה', 'en' => 'Car for Rent'],
    'automatic' => ['ar' => 'أوتو', 'he' => 'אוטו', 'en' => 'Auto'],
    'manual' => ['ar' => 'عادي', 'he' => 'ידני', 'en' => 'Manual'],
    'no_results' => ['ar' => 'لا توجد نتائج', 'he' => 'אין תוצאות', 'en' => 'No Results'],
    'try_changing' => ['ar' => 'جرب تغيير معايير البحث', 'he' => 'נסה לשנות את קריטריוני החיפוש', 'en' => 'Try changing search criteria'],
];
function trca($key) {
    global $trc, $lang;
    return $trc[$key][$lang] ?? $trc[$key]['ar'] ?? $key;
}

$pageTitle = trca('cars');

$page = (int)($_GET['page'] ?? 1);
$params = http_build_query([
    'page' => $page,
    'per_page' => 12,
    'region_id' => $_GET['region_id'] ?? '',
    'city_id' => $_GET['city_id'] ?? '',
    'usage_type' => $_GET['usage_type'] ?? '',
    'gearbox' => $_GET['gearbox'] ?? '',
    'with_driver' => $_GET['with_driver'] ?? '',
    'price_min' => $_GET['price_min'] ?? '',
    'price_max' => $_GET['price_max'] ?? '',
    'search' => $_GET['search'] ?? ''
]);

$cars = apiCall('cars?' . $params) ?? [];
$regions = apiCall('regions') ?? [];
$cities = apiCall('cities') ?? [];
$typesData = apiCall('types') ?? [];

// Ensure data arrays exist
if (!isset($cars['data'])) $cars['data'] = [];
if (!isset($cars['pagination'])) $cars['pagination'] = [];
if (!isset($regions['data'])) $regions['data'] = [];
if (!isset($cities['data'])) $cities['data'] = [];
$carTypes = $typesData['data']['car_types'] ?? [];

require_once 'includes/header.php';
?>

<div class="bg-white py-4 mb-4 shadow-sm">
    <div class="container">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
                <li class="breadcrumb-item"><a href="<?= SITE_URL ?>"><?= trca('home') ?></a></li>
                <li class="breadcrumb-item active"><?= trca('cars') ?></li>
            </ol>
        </nav>
    </div>
</div>

<div class="container py-4">
    <div class="row">
        <div class="col-lg-3 mb-4">
            <div class="filters-card">
                <h5><i class="bi bi-funnel"></i> <?= trca('filter_results') ?></h5>
                
                <form id="filterForm" method="GET">
                    <div class="filter-group">
                        <label><?= trca('usage_type') ?></label>
                        <select name="usage_type" class="form-select auto-submit">
                            <option value=""><?= trca('all') ?></option>
                            <?php foreach ($carTypes as $type): ?>
                            <option value="<?= htmlspecialchars($type['slug']) ?>" <?= ($_GET['usage_type'] ?? '') == $type['slug'] ? 'selected' : '' ?>>
                                <?= htmlspecialchars($type['name_' . $lang] ?? $type['name_ar']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    
                    <div class="filter-group">
                        <label><?= trca('region') ?></label>
                        <select name="region_id" class="form-select auto-submit">
                            <option value=""><?= trca('all_regions') ?></option>
                            <?php if (!empty($regions['data'])): ?>
                                <?php foreach ($regions['data'] as $region): ?>
                                    <option value="<?= $region['id'] ?>" <?= ($_GET['region_id'] ?? '') == $region['id'] ? 'selected' : '' ?>>
                                        <?= $region['name_' . $lang] ?? $region['name_ar'] ?>
                                    </option>
                                <?php endforeach; ?>
                            <?php endif; ?>
                        </select>
                    </div>
                    
                    <div class="filter-group">
                        <label><?= trca('city') ?></label>
                        <select name="city_id" class="form-select auto-submit" id="citySelect">
                            <option value=""><?= trca('all_cities') ?></option>
                            <?php if (!empty($cities['data'])): ?>
                                <?php foreach ($cities['data'] as $city): ?>
                                    <option value="<?= $city['id'] ?>" data-region="<?= $city['region_id'] ?>" <?= ($_GET['city_id'] ?? '') == $city['id'] ? 'selected' : '' ?>>
                                        <?= $city['name_' . $lang] ?? $city['name_ar'] ?>
                                    </option>
                                <?php endforeach; ?>
                            <?php endif; ?>
                        </select>
                    </div>
                    
                    <div class="filter-group">
                        <label><?= trca('gearbox') ?></label>
                        <select name="gearbox" class="form-select auto-submit">
                            <option value=""><?= trca('all_gearbox') ?></option>
                            <option value="automatic" <?= ($_GET['gearbox'] ?? '') == 'automatic' ? 'selected' : '' ?>><?= trca('automatic') ?></option>
                            <option value="manual" <?= ($_GET['gearbox'] ?? '') == 'manual' ? 'selected' : '' ?>><?= trca('manual') ?></option>
                        </select>
                    </div>
                    
                    <div class="filter-group">
                        <label><?= trca('driver_option') ?></label>
                        <select name="with_driver" class="form-select auto-submit">
                            <option value=""><?= trca('all') ?></option>
                            <option value="1" <?= ($_GET['with_driver'] ?? '') === '1' ? 'selected' : '' ?>><?= trca('with_driver') ?></option>
                            <option value="0" <?= ($_GET['with_driver'] ?? '') === '0' ? 'selected' : '' ?>><?= trca('without_driver') ?></option>
                        </select>
                    </div>
                    
                    <div class="filter-group">
                        <label><?= trca('daily_price') ?> (₪)</label>
                        <div class="row g-2">
                            <div class="col-6">
                                <input type="number" id="priceMin" name="price_min" class="form-control" placeholder="<?= trca('from') ?>" value="<?= $_GET['price_min'] ?? '' ?>">
                            </div>
                            <div class="col-6">
                                <input type="number" id="priceMax" name="price_max" class="form-control" placeholder="<?= trca('to') ?>" value="<?= $_GET['price_max'] ?? '' ?>">
                            </div>
                        </div>
                    </div>
                    
                    <div class="filter-group">
                        <label><?= trca('search') ?></label>
                        <input type="text" name="search" class="form-control" placeholder="<?= trca('brand_or_model') ?>" value="<?= htmlspecialchars($_GET['search'] ?? '') ?>">
                    </div>
                    
                    <button type="submit" class="btn btn-primary w-100">
                        <i class="bi bi-search"></i> <?= trca('search') ?>
                    </button>
                    
                    <a href="cars.php" class="btn btn-outline-secondary w-100 mt-2">
                        <i class="bi bi-x-circle"></i> <?= trca('clear_filters') ?>
                    </a>
                </form>
            </div>
        </div>
        
        <div class="col-lg-9">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h4 class="mb-0">
                    <?= trca('cars') ?>
                    <?php if (!empty($cars['pagination']['total'])): ?>
                        <small class="text-muted">(<?= $cars['pagination']['total'] ?> <?= trca('result') ?>)</small>
                    <?php endif; ?>
                </h4>
            </div>
            
            <div class="marketplace-grid" id="listingsContainer">
                <?php if (!empty($cars['data'])): ?>
                    <?php foreach ($cars['data'] as $car): ?>
                        <a href="details.php?type=car&id=<?= $car['id'] ?>" class="text-decoration-none">
                            <div class="listing-card <?= !empty($car['badge']) ? 'featured-listing' : '' ?>">
                                <div class="card-img-container">
                                    <img src="<?= $car['thumbnail'] ?? 'assets/images/car-placeholder.jpg' ?>" class="card-img-top" alt="<?= htmlspecialchars($car['title'] ?? trca('car_for_rent')) ?>">
                                    <?php if (!empty($car['is_trusted'])): ?>
                                    <span class="featured-badge badge-featured">
                                        <i class="bi bi-patch-check-fill"></i>
                                        <?= trca('featured') ?>
                                    </span>
                                    <?php elseif (!empty($car['badge'])): ?>
                                    <span class="featured-badge badge-<?= $car['badge'] ?>">
                                        <i class="bi bi-star-fill"></i>
                                        <?= $car['badge'] === 'gold' ? trca('gold') : ($car['badge'] === 'silver' ? trca('silver') : trca('bronze')) ?>
                                    </span>
                                    <?php endif; ?>
                                    <button class="favorite-btn" onclick="event.preventDefault();" data-id="<?= $car['id'] ?>" data-type="car">
                                        <i class="bi bi-heart"></i>
                                    </button>
                                </div>
                                <div class="card-body">
                                    <div class="listing-price">
                                        <?php if (!empty($car['price_daily'])): ?>
                                            <?= number_format($car['price_daily']) ?> ₪
                                        <?php elseif (!empty($car['price_weekly'])): ?>
                                            <?= number_format($car['price_weekly']) ?> ₪
                                        <?php elseif (!empty($car['price_monthly'])): ?>
                                            <?= number_format($car['price_monthly']) ?> ₪
                                        <?php else: ?>
                                            <?= number_format($car['price'] ?? 0) ?> ₪
                                        <?php endif; ?>
                                    </div>
                                    <h5 class="listing-title"><?= htmlspecialchars($car['model'] ?? trca('car_for_rent')) ?></h5>
                                    <div class="listing-location">
                                        <i class="bi bi-geo-alt"></i>
                                        <?= $car['city_name_' . $lang] ?? $car['city_name_ar'] ?? '' ?>
                                    </div>
                                    <div class="listing-features">
                                        <?php if (!empty($car['year'])): ?>
                                            <span><i class="bi bi-calendar"></i> <?= $car['year'] ?></span>
                                        <?php endif; ?>
                                        <?php if (!empty($car['gearbox'])): ?>
                                            <span><i class="bi bi-gear"></i> <?= $car['gearbox'] == 'automatic' ? trca('automatic') : trca('manual') ?></span>
                                        <?php endif; ?>
                                    </div>
                                </div>
                            </div>
                        </a>
                    <?php endforeach; ?>
                <?php else: ?>
                    <div class="col-12">
                        <div class="empty-state">
                            <i class="bi bi-car-front"></i>
                            <h5><?= trca('no_results') ?></h5>
                            <p><?= trca('try_changing') ?></p>
                        </div>
                    </div>
                <?php endif; ?>
            </div>
            
            <?php if (!empty($cars['pagination']) && $cars['pagination']['total_pages'] > 1): ?>
                <nav class="mt-4">
                    <ul class="pagination justify-content-center">
                        <?php for ($i = 1; $i <= $cars['pagination']['total_pages']; $i++): ?>
                            <li class="page-item <?= $i == $page ? 'active' : '' ?>">
                                <a class="page-link" href="?<?= http_build_query(array_merge($_GET, ['page' => $i])) ?>"><?= $i ?></a>
                            </li>
                        <?php endfor; ?>
                    </ul>
                </nav>
            <?php endif; ?>
        </div>
    </div>
</div>

<?php require_once 'includes/footer.php'; ?>
