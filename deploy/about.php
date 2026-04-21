<?php
$pageTitle = 'من نحن';
require_once 'config.php';
require_once 'includes/header.php';
?>

<div class="bg-white py-4 mb-4 shadow-sm">
    <div class="container">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
                <li class="breadcrumb-item"><a href="<?= SITE_URL ?>">الرئيسية</a></li>
                <li class="breadcrumb-item active">من نحن</li>
            </ol>
        </nav>
    </div>
</div>

<section class="py-5">
    <div class="container">
        <div class="row align-items-center">
            <div class="col-lg-6 mb-4">
                <h1 class="mb-4">من نحن</h1>
                <p class="lead">Rento Go هي منصتك الموثوقة للبحث عن العقارات والسيارات للإيجار.</p>
                <p>نسعى لتوفير أفضل تجربة للمستخدمين من خلال منصة سهلة الاستخدام تجمع بين المؤجرين والمستأجرين في مكان واحد.</p>
                <p>تأسست Rento Go بهدف تسهيل عملية البحث عن العقارات والسيارات وتوفير خيارات متنوعة تناسب جميع الاحتياجات والميزانيات.</p>
            </div>
            <div class="col-lg-6">
                <div class="bg-primary text-white rounded-4 p-5 text-center">
                    <i class="bi bi-house-heart-fill display-1"></i>
                    <h2 class="mt-3"><?= SITE_NAME ?></h2>
                    <p class="mb-0"><?= SITE_DESCRIPTION ?></p>
                </div>
            </div>
        </div>
    </div>
</section>

<section class="py-5 bg-white">
    <div class="container">
        <h2 class="text-center mb-5">لماذا تختارنا؟</h2>
        <div class="row g-4">
            <div class="col-md-4">
                <div class="text-center">
                    <div class="bg-primary text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 80px; height: 80px;">
                        <i class="bi bi-shield-check fs-2"></i>
                    </div>
                    <h5>موثوقية</h5>
                    <p class="text-muted">نتحقق من جميع الإعلانات لضمان مصداقيتها وجودتها</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="text-center">
                    <div class="bg-primary text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 80px; height: 80px;">
                        <i class="bi bi-lightning fs-2"></i>
                    </div>
                    <h5>سرعة</h5>
                    <p class="text-muted">ابحث وتواصل مع المعلنين بسرعة وسهولة</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="text-center">
                    <div class="bg-primary text-white rounded-circle d-inline-flex align-items-center justify-content-center mb-3" style="width: 80px; height: 80px;">
                        <i class="bi bi-people fs-2"></i>
                    </div>
                    <h5>دعم</h5>
                    <p class="text-muted">فريق دعم متاح لمساعدتك في أي استفسار</p>
                </div>
            </div>
        </div>
    </div>
</section>

<?php require_once 'includes/footer.php'; ?>
