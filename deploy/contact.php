<?php
$pageTitle = 'اتصل بنا';
require_once 'config.php';
require_once 'includes/header.php';
?>

<div class="bg-white py-4 mb-4 shadow-sm">
    <div class="container">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
                <li class="breadcrumb-item"><a href="<?= SITE_URL ?>">الرئيسية</a></li>
                <li class="breadcrumb-item active">اتصل بنا</li>
            </ol>
        </nav>
    </div>
</div>

<section class="py-5">
    <div class="container">
        <div class="row">
            <div class="col-lg-6 mb-4">
                <h1 class="mb-4">اتصل بنا</h1>
                <p class="lead">نحن هنا لمساعدتك! لا تتردد في التواصل معنا.</p>
                
                <div class="mt-5">
                    <div class="d-flex mb-4">
                        <div class="me-3">
                            <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center" style="width: 50px; height: 50px;">
                                <i class="bi bi-envelope fs-5"></i>
                            </div>
                        </div>
                        <div>
                            <h5>البريد الإلكتروني</h5>
                            <a href="mailto:support@rentogo.com" class="text-muted">support@rentogo.com</a>
                        </div>
                    </div>
                    
                    <div class="d-flex mb-4">
                        <div class="me-3">
                            <div class="bg-primary text-white rounded-circle d-flex align-items-center justify-content-center" style="width: 50px; height: 50px;">
                                <i class="bi bi-telephone fs-5"></i>
                            </div>
                        </div>
                        <div>
                            <h5>الهاتف</h5>
                            <a href="tel:+972501234567" class="text-muted">+972 50 123 4567</a>
                        </div>
                    </div>
                    
                    <div class="d-flex mb-4">
                        <div class="me-3">
                            <div class="bg-success text-white rounded-circle d-flex align-items-center justify-content-center" style="width: 50px; height: 50px;">
                                <i class="bi bi-whatsapp fs-5"></i>
                            </div>
                        </div>
                        <div>
                            <h5>واتساب</h5>
                            <a href="https://wa.me/972501234567" class="text-muted" target="_blank">+972 50 123 4567</a>
                        </div>
                    </div>
                </div>
                
                <div class="mt-4">
                    <h5>تابعنا على</h5>
                    <div class="social-links">
                        <a href="#" class="btn btn-outline-primary btn-sm me-2"><i class="bi bi-facebook"></i></a>
                        <a href="#" class="btn btn-outline-primary btn-sm me-2"><i class="bi bi-instagram"></i></a>
                        <a href="#" class="btn btn-outline-primary btn-sm me-2"><i class="bi bi-twitter-x"></i></a>
                    </div>
                </div>
            </div>
            
            <div class="col-lg-6">
                <div class="details-info-card">
                    <h5 class="mb-4">أرسل رسالة</h5>
                    <form action="#" method="POST">
                        <div class="mb-3">
                            <label class="form-label">الاسم</label>
                            <input type="text" name="name" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">البريد الإلكتروني</label>
                            <input type="email" name="email" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">الموضوع</label>
                            <input type="text" name="subject" class="form-control" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">الرسالة</label>
                            <textarea name="message" class="form-control" rows="5" required></textarea>
                        </div>
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-send"></i> إرسال
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</section>

<?php require_once 'includes/footer.php'; ?>
