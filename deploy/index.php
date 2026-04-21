<?php
error_reporting(E_ALL);
ini_set('display_errors', 0);

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/includes/translations.php';
$pageTitle = __('home');

// Fetch all data BEFORE rendering (with caching)
$cacheKey = 'home_data_' . date('YmdH'); // Cache for 1 hour
$cachedData = $_SESSION[$cacheKey] ?? null;

if ($cachedData && (time() - ($cachedData['time'] ?? 0)) < 300) {
    // Use cached data (5 minutes)
    $properties = $cachedData['properties'];
    $cars = $cachedData['cars'];
    $banners = $cachedData['banners'];
    $propertyTypes = $cachedData['propertyTypes'];
    $carTypes = $cachedData['carTypes'];
} else {
    // Fetch fresh data
    $propertiesData = apiCall('properties?limit=6');
    $properties = $propertiesData['data'] ?? [];
    
    $carsData = apiCall('cars?limit=6');
    $cars = $carsData['data'] ?? [];
    
    $bannersData = apiCall('banners');
    $banners = $bannersData['data'] ?? [];
    
    $typesData = apiCall('types');
    $propertyTypes = $typesData['data']['property_types'] ?? [];
    $carTypes = $typesData['data']['car_types'] ?? [];
    
    // Cache the data
    $_SESSION[$cacheKey] = [
        'time' => time(),
        'properties' => $properties,
        'cars' => $cars,
        'banners' => $banners,
        'propertyTypes' => $propertyTypes,
        'carTypes' => $carTypes
    ];
}

require_once __DIR__ . '/includes/header.php';

// Get location field based on language
$regionField = 'region_name_' . $lang;
$cityField = 'city_name_' . $lang;
$typeNameField = 'name_' . $lang;
?>

<section class="hero-section">
    <div class="container">
        <div class="hero-content text-center">
            <h1 class="hero-title"><?= __('hero_title') ?></h1>
            <p class="hero-subtitle"><?= __('hero_subtitle') ?></p>
            
            <div class="search-box">
                <form action="properties.php" method="GET" class="search-form">
                    <div class="row g-3 align-items-end">
                        <div class="col-md-4">
                            <select name="type" class="form-select form-select-lg">
                                <option value=""><?= __('property_type') ?></option>
                                <?php foreach ($propertyTypes as $type): ?>
                                <option value="<?= htmlspecialchars($type['slug']) ?>"><?= htmlspecialchars($type[$typeNameField]) ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <select name="region" class="form-select form-select-lg">
                                <option value=""><?= __('select_region') ?></option>
                                <option value="1"><?= $lang === 'he' ? 'הגדה המערבית' : ($lang === 'en' ? 'West Bank' : 'الضفة الغربية') ?></option>
                                <option value="2"><?= $lang === 'he' ? 'ירושלים' : ($lang === 'en' ? 'Jerusalem' : 'القدس') ?></option>
                                <option value="3"><?= $lang === 'he' ? 'הפנים' : ($lang === 'en' ? 'Inside' : 'الداخل') ?></option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <button type="submit" class="btn btn-primary btn-lg w-100">
                                <i class="bi bi-search me-2"></i><?= __('search') ?>
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</section>

<section class="categories-section py-5">
    <div class="container">
        <h2 class="section-title text-center mb-4"><?= __('browse_categories') ?></h2>
        <div class="row g-4">
            <?php 
            // Icon mapping for property types
            $iconMap = [
                'apartment' => 'bi-building',
                'room' => 'bi-door-open',
                'studio' => 'bi-house-door',
                'villa' => 'bi-house',
                'chalet' => 'bi-house-heart',
                'shop' => 'bi-shop',
                'office' => 'bi-briefcase',
                'student_housing' => 'bi-mortarboard',
                'land' => 'bi-map',
                'building' => 'bi-buildings',
                'daily' => 'bi-car-front',
                'wedding' => 'bi-gem',
                'tourism' => 'bi-airplane',
                'trips' => 'bi-compass',
                'transportation' => 'bi-truck',
            ];
            
            // Display first 4 property types
            $displayedPropertyTypes = array_slice($propertyTypes, 0, 4);
            foreach ($displayedPropertyTypes as $type): 
                $icon = $iconMap[$type['slug']] ?? 'bi-grid';
            ?>
            <div class="col-6 col-md-4 col-lg-2">
                <a href="properties.php?type=<?= htmlspecialchars($type['slug']) ?>" class="category-card">
                    <div class="category-icon"><i class="bi <?= $icon ?>"></i></div>
                    <h5><?= htmlspecialchars($type[$typeNameField]) ?></h5>
                </a>
            </div>
            <?php endforeach; ?>
            
            <?php 
            // Display first 2 car types
            $displayedCarTypes = array_slice($carTypes, 0, 2);
            foreach ($displayedCarTypes as $type): 
                $icon = $iconMap[$type['slug']] ?? 'bi-car-front';
            ?>
            <div class="col-6 col-md-4 col-lg-2">
                <a href="cars.php?type=<?= htmlspecialchars($type['slug']) ?>" class="category-card">
                    <div class="category-icon"><i class="bi <?= $icon ?>"></i></div>
                    <h5><?= htmlspecialchars($type[$typeNameField]) ?></h5>
                </a>
            </div>
            <?php endforeach; ?>
        </div>
    </div>
</section>

<?php if (!empty($banners)): ?>
<section class="admin-banners-section py-4">
    <div class="container">
        <div class="admin-banners-slider">
            <?php foreach ($banners as $banner): ?>
            <a href="banner-details.php?id=<?= $banner['id'] ?>" class="admin-banner-card">
                <div class="banner-image">
                    <img src="<?= htmlspecialchars($banner['thumbnail'] ?? UPLOAD_URL . 'sample.png') ?>" alt="<?= htmlspecialchars($banner['title']) ?>">
                    <span class="featured-tag">
                        <i class="bi bi-star-fill"></i>
                        <?= $lang === 'he' ? 'מומלץ' : ($lang === 'en' ? 'Featured' : 'مميز') ?>
                    </span>
                </div>
                <div class="banner-content">
                    <h4><?= htmlspecialchars($banner['title']) ?></h4>
                    <div class="banner-location">
                        <i class="bi bi-geo-alt"></i>
                        <?= htmlspecialchars($banner[$cityField] ?? $banner['city_name_ar'] ?? '') ?>
                    </div>
                    <?php if (!empty($banner['price'])): ?>
                    <div class="banner-price"><?= number_format($banner['price']) ?> <?= __('currency') ?></div>
                    <?php elseif (!empty($banner['price_text'])): ?>
                    <div class="banner-price"><?= htmlspecialchars($banner['price_text']) ?></div>
                    <?php endif; ?>
                </div>
            </a>
            <?php endforeach; ?>
        </div>
    </div>
</section>
<?php endif; ?>

<?php if (!empty($properties)): ?>
<section class="listings-section py-5 bg-light">
    <div class="container">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="section-title mb-0"><?= __('featured_properties') ?></h2>
            <a href="properties.php" class="btn btn-outline-primary"><?= __('view_all') ?></a>
        </div>
        <div class="marketplace-grid">
            <?php foreach (array_slice($properties, 0, 8) as $property): ?>
            <a href="details.php?type=property&id=<?= $property['id'] ?>" class="text-decoration-none">
                <div class="listing-card <?= !empty($property['badge']) ? 'featured-listing' : '' ?>">
                    <div class="card-img-container">
                        <img src="<?= htmlspecialchars($property['thumbnail'] ?? UPLOAD_URL . 'sample.png') ?>" class="card-img-top" alt="<?= htmlspecialchars($property['title'] ?? '') ?>">
                        <?php if (!empty($property['is_trusted'])): ?>
                        <span class="featured-badge badge-featured">
                            <i class="bi bi-patch-check-fill"></i>
                            <?= $lang === 'he' ? 'מובחר' : ($lang === 'en' ? 'Featured' : 'مميز') ?>
                        </span>
                        <?php elseif (!empty($property['badge'])): ?>
                        <span class="featured-badge badge-<?= $property['badge'] ?>">
                            <i class="bi bi-star-fill"></i>
                            <?= $property['badge'] === 'gold' ? ($lang === 'he' ? 'זהב' : ($lang === 'en' ? 'Gold' : 'ذهبي')) : ($property['badge'] === 'silver' ? ($lang === 'he' ? 'כסף' : ($lang === 'en' ? 'Silver' : 'فضي')) : ($lang === 'he' ? 'ארד' : ($lang === 'en' ? 'Bronze' : 'برونزي'))) ?>
                        </span>
                        <?php endif; ?>
                        <button class="favorite-btn" onclick="event.preventDefault();" data-id="<?= $property['id'] ?>" data-type="property">
                            <i class="bi bi-heart"></i>
                        </button>
                    </div>
                    <div class="card-body">
                        <div class="listing-price"><?= number_format($property['price'] ?? 0) ?> <?= __('currency') ?></div>
                        <h5 class="listing-title"><?= htmlspecialchars($property['title'] ?? __('for_rent')) ?></h5>
                        <div class="listing-location">
                            <i class="bi bi-geo-alt"></i>
                            <?= htmlspecialchars($property[$cityField] ?? $property['city_name_ar'] ?? '') ?>
                        </div>
                        <div class="listing-features">
                            <?php if (isset($property['bedrooms']) && $property['bedrooms'] > 0): ?>
                            <span><i class="bi bi-door-open"></i> <?= $property['bedrooms'] ?></span>
                            <?php endif; ?>
                            <?php if (isset($property['area_m2']) && $property['area_m2'] > 0): ?>
                            <span><i class="bi bi-arrows-angle-expand"></i> <?= $property['area_m2'] ?>م</span>
                            <?php endif; ?>
                        </div>
                    </div>
                </div>
            </a>
            <?php endforeach; ?>
        </div>
    </div>
</section>
<?php endif; ?>

<?php if (!empty($cars)): ?>
<section class="listings-section py-5">
    <div class="container">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h2 class="section-title mb-0"><?= __('featured_cars') ?></h2>
            <a href="cars.php" class="btn btn-outline-primary"><?= __('view_all') ?></a>
        </div>
        <div class="marketplace-grid">
            <?php foreach (array_slice($cars, 0, 8) as $car): ?>
            <a href="details.php?type=car&id=<?= $car['id'] ?>" class="text-decoration-none">
                <div class="listing-card <?= !empty($car['badge']) ? 'featured-listing' : '' ?>">
                    <div class="card-img-container">
                        <img src="<?= htmlspecialchars($car['thumbnail'] ?? UPLOAD_URL . 'sample.png') ?>" class="card-img-top" alt="<?= htmlspecialchars($car['title'] ?? '') ?>">
                        <?php if (!empty($car['is_trusted'])): ?>
                        <span class="featured-badge badge-featured">
                            <i class="bi bi-patch-check-fill"></i>
                            <?= $lang === 'he' ? 'מובחר' : ($lang === 'en' ? 'Featured' : 'مميز') ?>
                        </span>
                        <?php elseif (!empty($car['badge'])): ?>
                        <span class="featured-badge badge-<?= $car['badge'] ?>">
                            <i class="bi bi-star-fill"></i>
                            <?= $car['badge'] === 'gold' ? ($lang === 'he' ? 'זהב' : ($lang === 'en' ? 'Gold' : 'ذهبي')) : ($car['badge'] === 'silver' ? ($lang === 'he' ? 'כסף' : ($lang === 'en' ? 'Silver' : 'فضي')) : ($lang === 'he' ? 'ארד' : ($lang === 'en' ? 'Bronze' : 'برونزي'))) ?>
                        </span>
                        <?php endif; ?>
                        <button class="favorite-btn" onclick="event.preventDefault();" data-id="<?= $car['id'] ?>" data-type="car">
                            <i class="bi bi-heart"></i>
                        </button>
                    </div>
                    <div class="card-body">
                        <div class="listing-price">
                            <?php if (!empty($car['price_daily'])): ?>
                                <?= number_format($car['price_daily']) ?> <?= __('currency') ?>
                            <?php elseif (!empty($car['price_weekly'])): ?>
                                <?= number_format($car['price_weekly']) ?> <?= __('currency') ?>
                            <?php elseif (!empty($car['price_monthly'])): ?>
                                <?= number_format($car['price_monthly']) ?> <?= __('currency') ?>
                            <?php else: ?>
                                <?= number_format($car['price'] ?? 0) ?> <?= __('currency') ?>
                            <?php endif; ?>
                        </div>
                        <h5 class="listing-title"><?= htmlspecialchars($car['model'] ?? __('cars')) ?></h5>
                        <div class="listing-location">
                            <i class="bi bi-geo-alt"></i>
                            <?= htmlspecialchars($car[$cityField] ?? $car['city_name_ar'] ?? '') ?>
                        </div>
                        <div class="listing-features">
                            <span><i class="bi bi-calendar3"></i> <?= $car['year'] ?? '' ?></span>
                            <span><i class="bi bi-gear"></i> <?= $car['gearbox'] === 'automatic' ? 'أوتو' : 'عادي' ?></span>
                        </div>
                    </div>
                </div>
            </a>
            <?php endforeach; ?>
        </div>
    </div>
</section>
<?php endif; ?>

<section class="stats-section py-5 bg-primary text-white">
    <div class="container">
        <div class="row text-center g-4">
            <div class="col-6 col-md-3">
                <div class="stat-item">
                    <div class="stat-number">500+</div>
                    <div class="stat-label"><?= $lang === 'he' ? 'נכסים זמינים' : 'عقار متاح' ?></div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="stat-item">
                    <div class="stat-number">200+</div>
                    <div class="stat-label"><?= $lang === 'he' ? 'רכבים להשכרה' : 'سيارة للإيجار' ?></div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="stat-item">
                    <div class="stat-number">1000+</div>
                    <div class="stat-label"><?= $lang === 'he' ? 'לקוחות מרוצים' : 'عميل سعيد' ?></div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="stat-item">
                    <div class="stat-number">50+</div>
                    <div class="stat-label"><?= $lang === 'he' ? 'ערים' : 'مدينة' ?></div>
                </div>
            </div>
        </div>
    </div>
</section>

<section class="cta-section py-5">
    <div class="container text-center">
        <h2 class="mb-3"><?= $lang === 'he' ? 'הורד את האפליקציה עכשיו' : 'حمّل التطبيق الآن' ?></h2>
        <p class="text-muted mb-4"><?= $lang === 'he' ? 'חווית משתמש טובה יותר באפליקציה' : 'استمتع بتجربة أفضل عبر تطبيق الهاتف' ?></p>
        <div class="app-buttons">
            <a href="#" class="btn btn-dark btn-lg me-2">
                <i class="bi bi-apple me-2"></i>App Store
            </a>
            <a href="#" class="btn btn-dark btn-lg">
                <i class="bi bi-google-play me-2"></i>Google Play
            </a>
        </div>
    </div>
</section>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
