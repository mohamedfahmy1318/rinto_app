<?php
error_reporting(E_ALL);
ini_set('display_errors', 0);

require_once 'config.php';
require_once 'includes/translations.php';

// Page translations
$tr = [
    'properties' => ['ar' => 'العقارات', 'he' => 'נכסים', 'en' => 'Properties'],
    'home' => ['ar' => 'الرئيسية', 'he' => 'ראשי', 'en' => 'Home'],
    'filter_results' => ['ar' => 'تصفية النتائج', 'he' => 'סנן תוצאות', 'en' => 'Filter Results'],
    'property_type' => ['ar' => 'نوع العقار', 'he' => 'סוג נכס', 'en' => 'Property Type'],
    'all' => ['ar' => 'الكل', 'he' => 'הכל', 'en' => 'All'],
    'region' => ['ar' => 'المنطقة', 'he' => 'אזור', 'en' => 'Region'],
    'all_regions' => ['ar' => 'كل المناطق', 'he' => 'כל האזורים', 'en' => 'All Regions'],
    'bedrooms' => ['ar' => 'عدد الغرف', 'he' => 'חדרי שינה', 'en' => 'Bedrooms'],
    'city' => ['ar' => 'المدينة', 'he' => 'עיר', 'en' => 'City'],
    'all_cities' => ['ar' => 'كل المدن', 'he' => 'כל הערים', 'en' => 'All Cities'],
    'price' => ['ar' => 'السعر', 'he' => 'מחיר', 'en' => 'Price'],
    'from' => ['ar' => 'من', 'he' => 'מ-', 'en' => 'From'],
    'to' => ['ar' => 'إلى', 'he' => 'עד', 'en' => 'To'],
    'search' => ['ar' => 'بحث', 'he' => 'חיפוש', 'en' => 'Search'],
    'search_keyword' => ['ar' => 'كلمة البحث...', 'he' => 'מילת חיפוש...', 'en' => 'Search keyword...'],
    'clear_filters' => ['ar' => 'مسح الفلاتر', 'he' => 'נקה מסננים', 'en' => 'Clear Filters'],
    'result' => ['ar' => 'نتيجة', 'he' => 'תוצאה', 'en' => 'result'],
    'featured' => ['ar' => 'مميز', 'he' => 'מומלץ', 'en' => 'Featured'],
    'gold' => ['ar' => 'ذهبي', 'he' => 'זהב', 'en' => 'Gold'],
    'silver' => ['ar' => 'فضي', 'he' => 'כסף', 'en' => 'Silver'],
    'bronze' => ['ar' => 'برونزي', 'he' => 'ארד', 'en' => 'Bronze'],
    'property_for_rent' => ['ar' => 'عقار للإيجار', 'he' => 'נכס להשכרה', 'en' => 'Property for Rent'],
    'no_results' => ['ar' => 'لا توجد نتائج', 'he' => 'אין תוצאות', 'en' => 'No Results'],
    'try_changing' => ['ar' => 'جرب تغيير معايير البحث', 'he' => 'נסה לשנות את קריטריוני החיפוש', 'en' => 'Try changing search criteria'],
    'daily' => ['ar' => 'يومي', 'he' => 'יומי', 'en' => 'Daily'],
    'weekly' => ['ar' => 'أسبوعي', 'he' => 'שבועי', 'en' => 'Weekly'],
    'monthly' => ['ar' => 'شهري', 'he' => 'חודשי', 'en' => 'Monthly'],
];
function trpr($key) {
    global $tr, $lang;
    return $tr[$key][$lang] ?? $tr[$key]['ar'] ?? $key;
}

$pageTitle = trpr('properties');

$page = (int)($_GET['page'] ?? 1);
$params = http_build_query([
    'page' => $page,
    'per_page' => 12,
    'region_id' => $_GET['region_id'] ?? '',
    'city_id' => $_GET['city_id'] ?? '',
    'property_type' => $_GET['property_type'] ?? '',
    'price_min' => $_GET['price_min'] ?? '',
    'price_max' => $_GET['price_max'] ?? '',
    'bedrooms' => $_GET['bedrooms'] ?? '',
    'search' => $_GET['search'] ?? ''
]);

$properties = apiCall('properties?' . $params) ?? [];
$regions = apiCall('regions') ?? [];
$cities = apiCall('cities') ?? [];
$typesData = apiCall('types') ?? [];

// Ensure data arrays exist
if (!isset($properties['data'])) $properties['data'] = [];
if (!isset($properties['pagination'])) $properties['pagination'] = [];
if (!isset($regions['data'])) $regions['data'] = [];
if (!isset($cities['data'])) $cities['data'] = [];
$propertyTypes = $typesData['data']['property_types'] ?? [];

require_once 'includes/header.php';
?>

<div class="bg-white py-4 mb-4 shadow-sm">
    <div class="container">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
                <li class="breadcrumb-item"><a href="<?= SITE_URL ?>"><?= trpr('home') ?></a></li>
                <li class="breadcrumb-item active"><?= trpr('properties') ?></li>
            </ol>
        </nav>
    </div>
</div>

<div class="container py-4">
    <div class="row">
        <div class="col-lg-3 mb-4">
            <div class="filters-card">
                <h5><i class="bi bi-funnel"></i> <?= trpr('filter_results') ?></h5>
                
                <form id="filterForm" method="GET">
                    <div class="filter-group">
                        <label><?= trpr('property_type') ?></label>
                        <select name="property_type" class="form-select auto-submit">
                            <option value=""><?= trpr('all') ?></option>
                            <?php foreach ($propertyTypes as $type): ?>
                            <option value="<?= htmlspecialchars($type['slug']) ?>" <?= ($_GET['property_type'] ?? '') == $type['slug'] ? 'selected' : '' ?>>
                                <?= htmlspecialchars($type['name_' . $lang] ?? $type['name_ar']) ?>
                            </option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    
                    <div class="filter-group">
                        <label><?= trpr('region') ?></label>
                        <select name="region_id" class="form-select auto-submit">
                            <option value=""><?= trpr('all_regions') ?></option>
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
                        <label><?= trpr('city') ?></label>
                        <select name="city_id" class="form-select auto-submit" id="citySelect">
                            <option value=""><?= trpr('all_cities') ?></option>
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
                        <label><?= trpr('bedrooms') ?></label>
                        <select name="bedrooms" class="form-select auto-submit">
                            <option value=""><?= trpr('all') ?></option>
                            <option value="1" <?= ($_GET['bedrooms'] ?? '') == '1' ? 'selected' : '' ?>>1+</option>
                            <option value="2" <?= ($_GET['bedrooms'] ?? '') == '2' ? 'selected' : '' ?>>2+</option>
                            <option value="3" <?= ($_GET['bedrooms'] ?? '') == '3' ? 'selected' : '' ?>>3+</option>
                            <option value="4" <?= ($_GET['bedrooms'] ?? '') == '4' ? 'selected' : '' ?>>4+</option>
                            <option value="5" <?= ($_GET['bedrooms'] ?? '') == '5' ? 'selected' : '' ?>>5+</option>
                        </select>
                    </div>
                    
                    <div class="filter-group">
                        <label><?= trpr('price') ?> (₪)</label>
                        <div class="row g-2">
                            <div class="col-6">
                                <input type="number" id="priceMin" name="price_min" class="form-control" placeholder="<?= trpr('from') ?>" value="<?= $_GET['price_min'] ?? '' ?>">
                            </div>
                            <div class="col-6">
                                <input type="number" id="priceMax" name="price_max" class="form-control" placeholder="<?= trpr('to') ?>" value="<?= $_GET['price_max'] ?? '' ?>">
                            </div>
                        </div>
                    </div>
                    
                    <div class="filter-group">
                        <label><?= trpr('search') ?></label>
                        <input type="text" name="search" class="form-control" placeholder="<?= trpr('search_keyword') ?>" value="<?= htmlspecialchars($_GET['search'] ?? '') ?>">
                    </div>
                    
                    <button type="submit" class="btn btn-primary w-100">
                        <i class="bi bi-search"></i> <?= trpr('search') ?>
                    </button>
                    
                    <a href="properties.php" class="btn btn-outline-secondary w-100 mt-2">
                        <i class="bi bi-x-circle"></i> <?= trpr('clear_filters') ?>
                    </a>
                </form>
            </div>
        </div>
        
        <div class="col-lg-9">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h4 class="mb-0">
                    <?= trpr('properties') ?>
                    <?php if (!empty($properties['pagination']['total'])): ?>
                        <small class="text-muted">(<?= $properties['pagination']['total'] ?> <?= trpr('result') ?>)</small>
                    <?php endif; ?>
                </h4>
            </div>
            
            <div class="marketplace-grid" id="listingsContainer">
                <?php if (!empty($properties['data'])): ?>
                    <?php foreach ($properties['data'] as $property): ?>
                        <a href="details.php?type=property&id=<?= $property['id'] ?>" class="text-decoration-none">
                            <div class="listing-card <?= !empty($property['badge']) ? 'featured-listing' : '' ?>">
                                <div class="card-img-container">
                                    <img src="<?= $property['thumbnail'] ?? 'assets/images/placeholder.jpg' ?>" class="card-img-top" alt="<?= htmlspecialchars($property['title'] ?? trpr('property_for_rent')) ?>">
                                    <?php if (!empty($property['is_trusted'])): ?>
                                    <span class="featured-badge badge-featured">
                                        <i class="bi bi-patch-check-fill"></i>
                                        <?= trpr('featured') ?>
                                    </span>
                                    <?php elseif (!empty($property['badge'])): ?>
                                    <span class="featured-badge badge-<?= $property['badge'] ?>">
                                        <i class="bi bi-star-fill"></i>
                                        <?= $property['badge'] === 'gold' ? trpr('gold') : ($property['badge'] === 'silver' ? trpr('silver') : trpr('bronze')) ?>
                                    </span>
                                    <?php endif; ?>
                                    <button class="favorite-btn" onclick="event.preventDefault();" data-id="<?= $property['id'] ?>" data-type="property">
                                        <i class="bi bi-heart"></i>
                                    </button>
                                </div>
                                <div class="card-body">
                                    <div class="listing-price">
                                        <?php if (!empty($property['price_daily'])): ?>
                                            <?= number_format($property['price_daily']) ?> ₪<small>/<?= trpr('daily') ?></small>
                                        <?php elseif (!empty($property['price_monthly'])): ?>
                                            <?= number_format($property['price_monthly']) ?> ₪<small>/<?= trpr('monthly') ?></small>
                                        <?php else: ?>
                                            <?= number_format($property['price'] ?? 0) ?> ₪
                                        <?php endif; ?>
                                    </div>
                                    <h5 class="listing-title"><?= htmlspecialchars($property['title'] ?? trpr('property_for_rent')) ?></h5>
                                    <div class="listing-location">
                                        <i class="bi bi-geo-alt"></i>
                                        <?= $property['city_name_' . $lang] ?? $property['city_name_ar'] ?? '' ?>
                                    </div>
                                    <div class="listing-features">
                                        <?php if (!empty($property['bedrooms'])): ?>
                                            <span><i class="bi bi-door-open"></i> <?= $property['bedrooms'] ?></span>
                                        <?php endif; ?>
                                        <?php if (!empty($property['area_m2'])): ?>
                                            <span><i class="bi bi-arrows-angle-expand"></i> <?= $property['area_m2'] ?>م</span>
                                        <?php endif; ?>
                                    </div>
                                </div>
                            </div>
                        </a>
                    <?php endforeach; ?>
                <?php else: ?>
                    <div class="col-12">
                        <div class="empty-state">
                            <i class="bi bi-building"></i>
                            <h5><?= trpr('no_results') ?></h5>
                            <p><?= trpr('try_changing') ?></p>
                        </div>
                    </div>
                <?php endif; ?>
            </div>
            
            <?php if (!empty($properties['pagination']) && $properties['pagination']['total_pages'] > 1): ?>
                <nav class="mt-4">
                    <ul class="pagination justify-content-center">
                        <?php for ($i = 1; $i <= $properties['pagination']['total_pages']; $i++): ?>
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
