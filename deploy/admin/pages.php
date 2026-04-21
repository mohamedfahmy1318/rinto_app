<?php
session_start();
require_once __DIR__ . '/../backend/config/database.php';

if (!isset($_SESSION['admin_id'])) {
    header('Location: login.php');
    exit;
}

$db = Database::getInstance();
$pdo = $db->getConnection();
$message = '';
$messageType = 'success';

// Handle form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $type = $_POST['type'] ?? 'cms';
    
    if ($type === 'cms') {
        // CMS Pages (cms_pages table)
        $slug = $_POST['slug'];
        $data = [
            'title_ar' => $_POST['title_ar'],
            'title_en' => $_POST['title_en'],
            'title_he' => $_POST['title_he'],
            'content_ar' => $_POST['content_ar'],
            'content_en' => $_POST['content_en'],
            'content_he' => $_POST['content_he'],
        ];
        $db->update('cms_pages', $data, 'slug = ?', [$slug]);
        $message = 'تم حفظ الصفحة بنجاح';
    } else {
        // App Settings (app_settings table)
        $settingKey = $_POST['setting_key'];
        $stmt = $pdo->prepare("
            INSERT INTO app_settings (setting_key, value_ar, value_en, value_he, updated_by)
            VALUES (?, ?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE 
                value_ar = VALUES(value_ar),
                value_en = VALUES(value_en),
                value_he = VALUES(value_he),
                updated_by = VALUES(updated_by)
        ");
        $stmt->execute([
            $settingKey, 
            $_POST['value_ar'], 
            $_POST['value_en'], 
            $_POST['value_he'], 
            $_SESSION['admin_id']
        ]);
        $message = 'تم حفظ الإعدادات بنجاح';
    }
}

// Get CMS pages
$pages = $db->fetchAll("SELECT * FROM cms_pages ORDER BY slug");

// Get app settings for chat instructions
$chatInstructions = $db->fetch("SELECT * FROM app_settings WHERE setting_key = 'chat_instructions'");

$editPage = null;
$editType = $_GET['type'] ?? 'cms';
$editSlug = $_GET['edit'] ?? null;

if ($editSlug) {
    if ($editType === 'setting') {
        $editPage = $db->fetch("SELECT setting_key as slug, value_ar, value_en, value_he FROM app_settings WHERE setting_key = ?", [$editSlug]);
        if ($editPage) {
            $editPage['title_ar'] = $editSlug === 'chat_instructions' ? 'تعليمات المحادثة' : $editSlug;
            $editPage['is_setting'] = true;
        }
    } else {
        $editPage = $db->fetch("SELECT * FROM cms_pages WHERE slug = ?", [$editSlug]);
        if ($editPage) $editPage['is_setting'] = false;
    }
}

include 'includes/header.php';
?>

<div class="container-fluid py-4">
    <h1 class="h3 mb-4">إدارة المحتوى والإعدادات</h1>

    <?php if ($message): ?>
    <div class="alert alert-<?= $messageType ?> alert-dismissible fade show">
        <?= htmlspecialchars($message) ?>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <?php endif; ?>

    <div class="row g-4">
        <div class="col-md-3">
            <!-- CMS Pages -->
            <div class="card mb-3">
                <div class="card-header bg-primary text-white">
                    <h6 class="mb-0"><i class="bi bi-file-text me-2"></i>الصفحات القانونية</h6>
                </div>
                <div class="list-group list-group-flush">
                    <?php foreach ($pages as $page): ?>
                    <a href="?edit=<?= $page['slug'] ?>&type=cms" 
                       class="list-group-item list-group-item-action <?= ($editPage['slug'] ?? '') === $page['slug'] && !($editPage['is_setting'] ?? false) ? 'active' : '' ?>">
                        <i class="bi bi-file-earmark-text me-2"></i><?= htmlspecialchars($page['title_ar']) ?>
                    </a>
                    <?php endforeach; ?>
                </div>
            </div>
            
            <!-- App Settings -->
            <div class="card">
                <div class="card-header bg-info text-white">
                    <h6 class="mb-0"><i class="bi bi-gear me-2"></i>إعدادات التطبيق</h6>
                </div>
                <div class="list-group list-group-flush">
                    <a href="?edit=chat_instructions&type=setting" 
                       class="list-group-item list-group-item-action <?= ($editPage['slug'] ?? '') === 'chat_instructions' && ($editPage['is_setting'] ?? false) ? 'active' : '' ?>">
                        <i class="bi bi-chat-dots me-2"></i>تعليمات المحادثة
                    </a>
                </div>
            </div>
        </div>
        
        <div class="col-md-9">
            <?php if ($editPage): ?>
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">
                        <?php if ($editPage['is_setting'] ?? false): ?>
                            <i class="bi bi-gear me-2"></i>
                        <?php else: ?>
                            <i class="bi bi-file-earmark-text me-2"></i>
                        <?php endif; ?>
                        تعديل: <?= htmlspecialchars($editPage['title_ar']) ?>
                    </h5>
                </div>
                <div class="card-body">
                    <form method="POST">
                        <?php if ($editPage['is_setting'] ?? false): ?>
                            <!-- App Setting Form -->
                            <input type="hidden" name="type" value="setting">
                            <input type="hidden" name="setting_key" value="<?= htmlspecialchars($editPage['slug']) ?>">
                            
                            <ul class="nav nav-tabs mb-3" role="tablist">
                                <li class="nav-item"><a class="nav-link active" data-bs-toggle="tab" href="#ar">العربية</a></li>
                                <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#en">English</a></li>
                                <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#he">עברית</a></li>
                            </ul>
                            <div class="tab-content">
                                <div class="tab-pane fade show active" id="ar">
                                    <div class="mb-3">
                                        <label class="form-label">المحتوى بالعربية</label>
                                        <textarea name="value_ar" class="form-control" rows="10" dir="rtl"><?= htmlspecialchars($editPage['value_ar'] ?? '') ?></textarea>
                                    </div>
                                </div>
                                <div class="tab-pane fade" id="en">
                                    <div class="mb-3">
                                        <label class="form-label">Content in English</label>
                                        <textarea name="value_en" class="form-control" rows="10" dir="ltr"><?= htmlspecialchars($editPage['value_en'] ?? '') ?></textarea>
                                    </div>
                                </div>
                                <div class="tab-pane fade" id="he">
                                    <div class="mb-3">
                                        <label class="form-label">תוכן בעברית</label>
                                        <textarea name="value_he" class="form-control" rows="10" dir="rtl"><?= htmlspecialchars($editPage['value_he'] ?? '') ?></textarea>
                                    </div>
                                </div>
                            </div>
                        <?php else: ?>
                            <!-- CMS Page Form -->
                            <input type="hidden" name="type" value="cms">
                            <input type="hidden" name="slug" value="<?= htmlspecialchars($editPage['slug']) ?>">
                            
                            <ul class="nav nav-tabs mb-3" role="tablist">
                                <li class="nav-item"><a class="nav-link active" data-bs-toggle="tab" href="#ar">العربية</a></li>
                                <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#en">English</a></li>
                                <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#he">עברית</a></li>
                            </ul>
                            <div class="tab-content">
                                <div class="tab-pane fade show active" id="ar">
                                    <div class="mb-3">
                                        <label class="form-label">العنوان</label>
                                        <input type="text" name="title_ar" class="form-control" value="<?= htmlspecialchars($editPage['title_ar']) ?>">
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">المحتوى</label>
                                        <textarea name="content_ar" class="form-control" rows="15"><?= htmlspecialchars($editPage['content_ar'] ?? '') ?></textarea>
                                    </div>
                                </div>
                                <div class="tab-pane fade" id="en">
                                    <div class="mb-3">
                                        <label class="form-label">Title</label>
                                        <input type="text" name="title_en" class="form-control" value="<?= htmlspecialchars($editPage['title_en'] ?? '') ?>">
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">Content</label>
                                        <textarea name="content_en" class="form-control" rows="15"><?= htmlspecialchars($editPage['content_en'] ?? '') ?></textarea>
                                    </div>
                                </div>
                                <div class="tab-pane fade" id="he" dir="rtl">
                                    <div class="mb-3">
                                        <label class="form-label">כותרת</label>
                                        <input type="text" name="title_he" class="form-control" value="<?= htmlspecialchars($editPage['title_he'] ?? '') ?>">
                                    </div>
                                    <div class="mb-3">
                                        <label class="form-label">תוכן</label>
                                        <textarea name="content_he" class="form-control" rows="15"><?= htmlspecialchars($editPage['content_he'] ?? '') ?></textarea>
                                    </div>
                                </div>
                            </div>
                        <?php endif; ?>
                        <button type="submit" class="btn btn-primary">
                            <i class="bi bi-save me-1"></i> حفظ التغييرات
                        </button>
                    </form>
                </div>
            </div>
            <?php else: ?>
            <div class="card">
                <div class="card-body text-center text-muted py-5">
                    <i class="bi bi-hand-index-thumb" style="font-size: 3rem;"></i>
                    <p class="mt-3 mb-0">اختر صفحة أو إعداد للتعديل من القائمة الجانبية</p>
                </div>
            </div>
            <?php endif; ?>
        </div>
    </div>
</div>

<?php include 'includes/footer.php'; ?>
