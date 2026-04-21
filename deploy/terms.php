<?php
$pageTitle = 'الشروط والأحكام';
require_once 'config.php';
require_once 'includes/header.php';
?>

<div class="bg-white py-4 mb-4 shadow-sm">
    <div class="container">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
                <li class="breadcrumb-item"><a href="<?= SITE_URL ?>">الرئيسية</a></li>
                <li class="breadcrumb-item active">الشروط والأحكام</li>
            </ol>
        </nav>
    </div>
</div>

<section class="py-5">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="details-info-card">
                    <h1 class="mb-4">الشروط والأحكام</h1>
                    <p class="text-muted">آخر تحديث: <?= date('Y-m-d') ?></p>
                    
                    <hr>
                    
                    <h5>قبول الشروط</h5>
                    <p>باستخدام منصة Rento Go، فإنك توافق على الالتزام بهذه الشروط والأحكام.</p>
                    
                    <h5>استخدام الخدمة</h5>
                    <p>يجب استخدام المنصة لأغراض مشروعة فقط. يُحظر:</p>
                    <ul>
                        <li>نشر معلومات كاذبة أو مضللة</li>
                        <li>انتهاك حقوق الآخرين</li>
                        <li>استخدام المنصة لأنشطة غير قانونية</li>
                        <li>محاولة اختراق النظام أو إلحاق الضرر به</li>
                    </ul>
                    
                    <h5>المحتوى</h5>
                    <p>أنت مسؤول عن المحتوى الذي تنشره على المنصة. نحتفظ بالحق في إزالة أي محتوى ينتهك هذه الشروط.</p>
                    
                    <h5>إخلاء المسؤولية</h5>
                    <p>Rento Go منصة وسيطة فقط ولا نتحمل مسؤولية أي اتفاقات أو معاملات بين المستخدمين.</p>
                    
                    <h5>التعديلات</h5>
                    <p>نحتفظ بالحق في تعديل هذه الشروط في أي وقت. سيتم إخطارك بأي تغييرات جوهرية.</p>
                    
                    <h5>اتصل بنا</h5>
                    <p>للأسئلة حول هذه الشروط، يرجى <a href="contact.php">التواصل معنا</a>.</p>
                </div>
            </div>
        </div>
    </div>
</section>

<?php require_once 'includes/footer.php'; ?>
