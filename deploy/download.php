<?php
$pageTitle = 'حمّل التطبيق';
require_once 'config.php';
require_once 'includes/header.php';
?>

<section class="hero-section text-center">
    <div class="container">
        <h1 class="hero-title">حمّل تطبيق Rento Go</h1>
        <p class="hero-subtitle">استمتع بأفضل تجربة للبحث عن العقارات والسيارات من جوالك</p>
    </div>
</section>

<section class="py-5">
    <div class="container">
        <div class="row align-items-center">
            <div class="col-lg-6 mb-4">
                <h2 class="mb-4">مميزات التطبيق</h2>
                
                <div class="d-flex mb-3">
                    <div class="me-3">
                        <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center" style="width: 50px; height: 50px;">
                            <i class="bi bi-search fs-5"></i>
                        </div>
                    </div>
                    <div>
                        <h5>بحث متقدم</h5>
                        <p class="text-muted mb-0">ابحث بسهولة عن العقارات والسيارات حسب المنطقة والسعر والمواصفات</p>
                    </div>
                </div>
                
                <div class="d-flex mb-3">
                    <div class="me-3">
                        <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center" style="width: 50px; height: 50px;">
                            <i class="bi bi-heart fs-5"></i>
                        </div>
                    </div>
                    <div>
                        <h5>المفضلة</h5>
                        <p class="text-muted mb-0">احفظ الإعلانات المفضلة لديك للرجوع إليها لاحقاً</p>
                    </div>
                </div>
                
                <div class="d-flex mb-3">
                    <div class="me-3">
                        <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center" style="width: 50px; height: 50px;">
                            <i class="bi bi-bell fs-5"></i>
                        </div>
                    </div>
                    <div>
                        <h5>إشعارات فورية</h5>
                        <p class="text-muted mb-0">احصل على إشعارات للعقارات والسيارات الجديدة</p>
                    </div>
                </div>
                
                <div class="d-flex mb-3">
                    <div class="me-3">
                        <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center" style="width: 50px; height: 50px;">
                            <i class="bi bi-plus-circle fs-5"></i>
                        </div>
                    </div>
                    <div>
                        <h5>نشر الإعلانات</h5>
                        <p class="text-muted mb-0">أنشر إعلاناتك بسهولة وصل لآلاف العملاء</p>
                    </div>
                </div>
                
                <div class="d-flex mb-3">
                    <div class="me-3">
                        <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center" style="width: 50px; height: 50px;">
                            <i class="bi bi-moon fs-5"></i>
                        </div>
                    </div>
                    <div>
                        <h5>الوضع الليلي</h5>
                        <p class="text-muted mb-0">استمتع بتجربة مريحة للعين مع الوضع الداكن</p>
                    </div>
                </div>
            </div>
            
            <div class="col-lg-6 text-center">
                <img src="assets/images/app-mockup.png" alt="Rento Go App" class="img-fluid" style="max-height: 500px;">
                
                <div class="mt-4">
                    <h5 class="mb-3">حمّل التطبيق الآن</h5>
                    <div class="d-flex justify-content-center gap-3">
                        <a href="#" class="btn btn-dark btn-lg">
                            <i class="bi bi-apple"></i> App Store
                        </a>
                        <a href="#" class="btn btn-dark btn-lg">
                            <i class="bi bi-google-play"></i> Google Play
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</section>

<?php require_once 'includes/footer.php'; ?>
