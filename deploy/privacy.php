<?php
$pageTitle = 'سياسة الخصوصية';
require_once 'config.php';
require_once 'includes/header.php';
?>

<div class="bg-white py-4 mb-4 shadow-sm">
    <div class="container">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
                <li class="breadcrumb-item"><a href="<?= SITE_URL ?>">الرئيسية</a></li>
                <li class="breadcrumb-item active">سياسة الخصوصية</li>
            </ol>
        </nav>
    </div>
</div>

<section class="py-5">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="details-info-card">
                    <h1 class="mb-4">سياسة الخصوصية</h1>
                    <p class="text-muted">آخر تحديث: <?= date('Y-m-d') ?></p>
                    
                    <hr>
                    
                    <h5>جمع المعلومات</h5>
                    <p>نحن نجمع المعلومات التي تقدمها لنا مباشرة عند إنشاء حساب أو نشر إعلان أو التواصل معنا.</p>
                    
                    <h5>استخدام المعلومات</h5>
                    <p>نستخدم المعلومات المجمعة لتقديم خدماتنا وتحسينها وتخصيصها لك.</p>
                    
                    <h5>مشاركة المعلومات</h5>
                    <p>لا نشارك معلوماتك الشخصية مع أطراف ثالثة إلا في الحالات التالية:</p>
                    <ul>
                        <li>بموافقتك الصريحة</li>
                        <li>لتقديم الخدمات المطلوبة</li>
                        <li>للامتثال للقانون</li>
                    </ul>
                    
                    <h5>حماية المعلومات</h5>
                    <p>نتخذ إجراءات أمنية مناسبة لحماية معلوماتك من الوصول غير المصرح به أو التغيير أو الإفصاح أو الإتلاف.</p>
                    
                    <h5>حقوقك</h5>
                    <p>لديك الحق في الوصول إلى معلوماتك الشخصية وتصحيحها أو حذفها. تواصل معنا لممارسة هذه الحقوق.</p>
                    
                    <h5>اتصل بنا</h5>
                    <p>إذا كان لديك أي أسئلة حول سياسة الخصوصية، يرجى <a href="contact.php">التواصل معنا</a>.</p>
                </div>
            </div>
        </div>
    </div>
</section>

<?php require_once 'includes/footer.php'; ?>
