<?php
require_once __DIR__ . '/config.php';

$id = $_GET['id'] ?? 0;
if (!$id) {
    header('Location: index.php');
    exit;
}

// Fetch banner details from API
$bannerData = apiCall("banners/$id");
$banner = $bannerData['data'] ?? null;

if (!$banner) {
    header('Location: index.php');
    exit;
}

require_once __DIR__ . '/includes/header.php';
$pageTitle = $banner['title'];

$regionField = $lang === 'he' ? 'region_name_he' : 'region_name_ar';
$cityField = $lang === 'he' ? 'city_name_he' : 'city_name_ar';

// Parse media
$media = $banner['media'] ?? [];
$images = array_filter($media, fn($m) => ($m['media_type'] ?? 'image') === 'image');
?>

<section class="listing-details py-4">
    <div class="container">
        <div class="row">
            <!-- Images Gallery -->
            <div class="col-lg-7 mb-4">
                <div class="gallery-container">
                    <?php if (!empty($images)): ?>
                    <div id="imageCarousel" class="carousel slide" data-bs-ride="carousel">
                        <div class="carousel-inner">
                            <?php foreach ($images as $index => $image): ?>
                            <div class="carousel-item <?= $index === 0 ? 'active' : '' ?>">
                                <img src="<?= htmlspecialchars($image['url'] ?? UPLOAD_URL . $image['file_path']) ?>" class="d-block w-100 rounded-3" alt="" style="height: 400px; object-fit: cover;">
                            </div>
                            <?php endforeach; ?>
                        </div>
                        <?php if (count($images) > 1): ?>
                        <button class="carousel-control-prev" type="button" data-bs-target="#imageCarousel" data-bs-slide="prev">
                            <span class="carousel-control-prev-icon"></span>
                        </button>
                        <button class="carousel-control-next" type="button" data-bs-target="#imageCarousel" data-bs-slide="next">
                            <span class="carousel-control-next-icon"></span>
                        </button>
                        <div class="carousel-indicators">
                            <?php foreach ($images as $index => $image): ?>
                            <button type="button" data-bs-target="#imageCarousel" data-bs-slide-to="<?= $index ?>" class="<?= $index === 0 ? 'active' : '' ?>"></button>
                            <?php endforeach; ?>
                        </div>
                        <?php endif; ?>
                    </div>
                    <?php elseif (!empty($banner['thumbnail'])): ?>
                    <img src="<?= htmlspecialchars($banner['thumbnail']) ?>" class="w-100 rounded-3" alt="" style="height: 400px; object-fit: cover;">
                    <?php else: ?>
                    <div class="bg-secondary rounded-3 d-flex align-items-center justify-content-center" style="height: 400px;">
                        <i class="bi bi-image text-white" style="font-size: 4rem;"></i>
                    </div>
                    <?php endif; ?>
                </div>
                
                <!-- Thumbnails -->
                <?php if (count($images) > 1): ?>
                <div class="thumbnails-row mt-3 d-flex gap-2 overflow-auto">
                    <?php foreach ($images as $index => $image): ?>
                    <img src="<?= htmlspecialchars($image['url'] ?? UPLOAD_URL . $image['file_path']) ?>" 
                         class="rounded cursor-pointer" 
                         style="width: 80px; height: 60px; object-fit: cover; cursor: pointer;"
                         onclick="document.querySelector('[data-bs-slide-to=\'<?= $index ?>\']').click()">
                    <?php endforeach; ?>
                </div>
                <?php endif; ?>
            </div>
            
            <!-- Details -->
            <div class="col-lg-5">
                <div class="details-card bg-white rounded-3 p-4 shadow-sm">
                    <!-- Featured Badge -->
                    <span class="badge bg-primary mb-3">
                        <i class="bi bi-star-fill me-1"></i>
                        <?= $lang === 'he' ? 'מומלץ' : 'إعلان مميز' ?>
                    </span>
                    
                    <!-- Title -->
                    <h1 class="h3 mb-3"><?= htmlspecialchars($banner['title']) ?></h1>
                    
                    <!-- Location -->
                    <?php if (!empty($banner[$cityField]) || !empty($banner['address_text'])): ?>
                    <p class="text-muted mb-3">
                        <i class="bi bi-geo-alt me-1"></i>
                        <?= htmlspecialchars($banner[$cityField] ?? $banner['city_name_ar'] ?? '') ?>
                        <?php if (!empty($banner[$regionField])): ?>
                        - <?= htmlspecialchars($banner[$regionField] ?? $banner['region_name_ar'] ?? '') ?>
                        <?php endif; ?>
                        <?php if (!empty($banner['address_text'])): ?>
                        <br><small><?= htmlspecialchars($banner['address_text']) ?></small>
                        <?php endif; ?>
                    </p>
                    <?php endif; ?>
                    
                    <!-- Price -->
                    <?php if (!empty($banner['price']) || !empty($banner['price_text'])): ?>
                    <div class="price-box bg-light rounded-3 p-3 mb-4">
                        <span class="h2 text-primary mb-0">
                            <?php if (!empty($banner['price'])): ?>
                            <?= number_format($banner['price']) ?> <?= __('currency') ?>
                            <?php else: ?>
                            <?= htmlspecialchars($banner['price_text']) ?>
                            <?php endif; ?>
                        </span>
                    </div>
                    <?php endif; ?>
                    
                    <!-- Property Details -->
                    <?php if ($banner['banner_type'] === 'property'): ?>
                    <div class="specs-grid row g-3 mb-4">
                        <?php if (!empty($banner['bedrooms'])): ?>
                        <div class="col-6">
                            <div class="spec-item bg-light rounded-3 p-3 text-center">
                                <i class="bi bi-door-open text-primary fs-4"></i>
                                <div class="fw-bold"><?= $banner['bedrooms'] ?></div>
                                <small class="text-muted"><?= $lang === 'he' ? 'חדרי שינה' : 'غرف نوم' ?></small>
                            </div>
                        </div>
                        <?php endif; ?>
                        <?php if (!empty($banner['bathrooms'])): ?>
                        <div class="col-6">
                            <div class="spec-item bg-light rounded-3 p-3 text-center">
                                <i class="bi bi-droplet text-primary fs-4"></i>
                                <div class="fw-bold"><?= $banner['bathrooms'] ?></div>
                                <small class="text-muted"><?= $lang === 'he' ? 'חדרי אמבט' : 'حمامات' ?></small>
                            </div>
                        </div>
                        <?php endif; ?>
                        <?php if (!empty($banner['area_m2'])): ?>
                        <div class="col-6">
                            <div class="spec-item bg-light rounded-3 p-3 text-center">
                                <i class="bi bi-arrows-angle-expand text-primary fs-4"></i>
                                <div class="fw-bold"><?= $banner['area_m2'] ?> م²</div>
                                <small class="text-muted"><?= $lang === 'he' ? 'שטח' : 'المساحة' ?></small>
                            </div>
                        </div>
                        <?php endif; ?>
                        <?php if (!empty($banner['floor'])): ?>
                        <div class="col-6">
                            <div class="spec-item bg-light rounded-3 p-3 text-center">
                                <i class="bi bi-layers text-primary fs-4"></i>
                                <div class="fw-bold"><?= $banner['floor'] ?></div>
                                <small class="text-muted"><?= $lang === 'he' ? 'קומה' : 'الطابق' ?></small>
                            </div>
                        </div>
                        <?php endif; ?>
                    </div>
                    <?php endif; ?>
                    
                    <!-- Car Details -->
                    <?php if ($banner['banner_type'] === 'car'): ?>
                    <div class="specs-grid row g-3 mb-4">
                        <?php if (!empty($banner['car_model'])): ?>
                        <div class="col-6">
                            <div class="spec-item bg-light rounded-3 p-3 text-center">
                                <i class="bi bi-car-front text-primary fs-4"></i>
                                <div class="fw-bold"><?= htmlspecialchars($banner['car_model']) ?></div>
                                <small class="text-muted"><?= $lang === 'he' ? 'דגם' : 'الموديل' ?></small>
                            </div>
                        </div>
                        <?php endif; ?>
                        <?php if (!empty($banner['car_year'])): ?>
                        <div class="col-6">
                            <div class="spec-item bg-light rounded-3 p-3 text-center">
                                <i class="bi bi-calendar text-primary fs-4"></i>
                                <div class="fw-bold"><?= $banner['car_year'] ?></div>
                                <small class="text-muted"><?= $lang === 'he' ? 'שנה' : 'السنة' ?></small>
                            </div>
                        </div>
                        <?php endif; ?>
                        <?php if (!empty($banner['gearbox'])): ?>
                        <div class="col-6">
                            <div class="spec-item bg-light rounded-3 p-3 text-center">
                                <i class="bi bi-gear text-primary fs-4"></i>
                                <div class="fw-bold"><?= $banner['gearbox'] === 'automatic' ? ($lang === 'he' ? 'אוטומטי' : 'أوتوماتيك') : ($lang === 'he' ? 'ידני' : 'عادي') ?></div>
                                <small class="text-muted"><?= $lang === 'he' ? 'תיבת הילוכים' : 'ناقل الحركة' ?></small>
                            </div>
                        </div>
                        <?php endif; ?>
                    </div>
                    <?php endif; ?>
                    
                    <!-- Description -->
                    <?php if (!empty($banner['description'])): ?>
                    <div class="description mb-4">
                        <h5><?= $lang === 'he' ? 'תיאור' : 'الوصف' ?></h5>
                        <p class="text-muted"><?= nl2br(htmlspecialchars($banner['description'])) ?></p>
                    </div>
                    <?php endif; ?>
                    
                    <!-- Contact Buttons -->
                    <div class="contact-buttons d-flex gap-2">
                        <?php if (!empty($banner['contact_phone'])): ?>
                        <a href="tel:<?= htmlspecialchars($banner['contact_phone']) ?>" class="btn btn-primary flex-fill">
                            <i class="bi bi-telephone me-2"></i>
                            <?= $lang === 'he' ? 'התקשר' : 'اتصال' ?>
                        </a>
                        <?php endif; ?>
                        <?php if (!empty($banner['whatsapp'])): ?>
                        <a href="https://wa.me/<?= preg_replace('/[^0-9]/', '', $banner['whatsapp']) ?>" target="_blank" class="btn btn-success flex-fill">
                            <i class="bi bi-whatsapp me-2"></i>
                            <?= $lang === 'he' ? 'וואטסאפ' : 'واتساب' ?>
                        </a>
                        <?php endif; ?>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
