<?php
session_start();
require_once __DIR__ . '/../backend/config/database.php';
require_once __DIR__ . '/../backend/config/constants.php';
require_once __DIR__ . '/../backend/helpers/Upload.php';

// Set Palestine timezone
date_default_timezone_set('Asia/Hebron');

if (!isset($_SESSION['admin_id'])) {
    header('Location: login.php');
    exit;
}

Upload::init();
$db = Database::getInstance();

$message = '';
$messageType = '';

// Handle actions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    
    try {
        if ($action === 'create' || $action === 'update') {
            $id = $_POST['id'] ?? null;
            
            $data = [
                'title' => $_POST['title'] ?? '',
                'title_ar' => $_POST['title_ar'] ?? '',
                'title_en' => $_POST['title_en'] ?? '',
                'title_he' => $_POST['title_he'] ?? '',
                'description' => $_POST['description'] ?? '',
                'description_ar' => $_POST['description_ar'] ?? '',
                'description_en' => $_POST['description_en'] ?? '',
                'description_he' => $_POST['description_he'] ?? '',
                'banner_type' => $_POST['banner_type'] ?? 'property',
                'region_id' => !empty($_POST['region_id']) ? $_POST['region_id'] : null,
                'city_id' => !empty($_POST['city_id']) ? $_POST['city_id'] : null,
                'address_text' => $_POST['address_text'] ?? '',
                'price' => !empty($_POST['price']) ? $_POST['price'] : null,
                'price_text' => $_POST['price_text'] ?? '',
                'property_type' => !empty($_POST['property_type']) ? $_POST['property_type'] : null,
                'bedrooms' => !empty($_POST['bedrooms']) ? $_POST['bedrooms'] : null,
                'bathrooms' => !empty($_POST['bathrooms']) ? $_POST['bathrooms'] : null,
                'area_m2' => !empty($_POST['area_m2']) ? $_POST['area_m2'] : null,
                'floor' => !empty($_POST['floor']) ? $_POST['floor'] : null,
                'car_model' => $_POST['car_model'] ?? '',
                'car_year' => !empty($_POST['car_year']) ? $_POST['car_year'] : null,
                'gearbox' => !empty($_POST['gearbox']) ? $_POST['gearbox'] : null,
                'contact_phone' => $_POST['contact_phone'] ?? '',
                'whatsapp' => $_POST['whatsapp'] ?? '',
                'display_order' => $_POST['display_order'] ?? 0,
                'is_active' => isset($_POST['is_active']) ? 1 : 0,
                'starts_at' => !empty($_POST['starts_at']) ? $_POST['starts_at'] : null,
                'ends_at' => !empty($_POST['ends_at']) ? $_POST['ends_at'] : null,
            ];
            
            if ($action === 'create') {
                $data['created_by'] = $_SESSION['admin_id'];
                $bannerId = $db->insert('admin_banners', $data);
                $message = 'تم إنشاء البانر بنجاح';
            } else {
                $db->update('admin_banners', $data, 'id = ?', [$id]);
                $bannerId = $id;
                $message = 'تم تحديث البانر بنجاح';
            }
            $messageType = 'success';
            
            // Handle image uploads
            if (!empty($_FILES['images']['name'][0])) {
                foreach ($_FILES['images']['tmp_name'] as $key => $tmpName) {
                    if ($_FILES['images']['error'][$key] === UPLOAD_ERR_OK) {
                        $file = [
                            'name' => $_FILES['images']['name'][$key],
                            'type' => $_FILES['images']['type'][$key],
                            'tmp_name' => $tmpName,
                            'error' => $_FILES['images']['error'][$key],
                            'size' => $_FILES['images']['size'][$key]
                        ];
                        $result = Upload::image($file, 'images/banners');
                        
                        if (isset($result['success']) && $result['success']) {
                            $db->insert('admin_banner_media', [
                                'banner_id' => $bannerId,
                                'media_type' => 'image',
                                'file_path' => $result['path'],
                                'sort_order' => $key
                            ]);
                            
                            // Set first image as thumbnail
                            if ($key === 0) {
                                $db->update('admin_banners', ['thumbnail' => $result['path']], 'id = ?', [$bannerId]);
                            }
                        }
                    }
                }
            }
            
        } elseif ($action === 'delete') {
            $id = $_POST['id'] ?? 0;
            
            // Delete media files
            $media = $db->fetchAll("SELECT file_path FROM admin_banner_media WHERE banner_id = ?", [$id]);
            foreach ($media as $m) {
                Upload::delete($m['file_path']);
            }
            
            // Delete thumbnail
            $banner = $db->fetch("SELECT thumbnail FROM admin_banners WHERE id = ?", [$id]);
            if ($banner && $banner['thumbnail']) {
                Upload::delete($banner['thumbnail']);
            }
            
            $db->delete('admin_banners', 'id = ?', [$id]);
            $message = 'تم حذف البانر';
            $messageType = 'warning';
            
        } elseif ($action === 'delete_media') {
            $mediaId = $_POST['media_id'] ?? 0;
            $media = $db->fetch("SELECT * FROM admin_banner_media WHERE id = ?", [$mediaId]);
            if ($media) {
                Upload::delete($media['file_path']);
                $db->delete('admin_banner_media', 'id = ?', [$mediaId]);
            }
            $message = 'تم حذف الصورة';
            $messageType = 'info';
            
        } elseif ($action === 'toggle_status') {
            $id = $_POST['id'] ?? 0;
            $db->query("UPDATE admin_banners SET is_active = NOT is_active WHERE id = ?", [$id]);
            $message = 'تم تغيير الحالة';
            $messageType = 'info';
        }
    } catch (Exception $e) {
        $message = 'خطأ: ' . $e->getMessage();
        $messageType = 'danger';
    }
}

// Get regions for dropdown
$regions = $db->fetchAll("SELECT * FROM regions WHERE is_active = 1 ORDER BY sort_order");

// Get all banners
$banners = $db->fetchAll("
    SELECT b.*, r.name_ar as region_name, c.name_ar as city_name, a.name as created_by_name
    FROM admin_banners b
    LEFT JOIN regions r ON b.region_id = r.id
    LEFT JOIN cities c ON b.city_id = c.id
    LEFT JOIN admin_users a ON b.created_by = a.id
    ORDER BY b.display_order ASC, b.created_at DESC
");

// Get banner for editing
$editBanner = null;
$editMedia = [];
if (isset($_GET['edit'])) {
    $editBanner = $db->fetch("SELECT * FROM admin_banners WHERE id = ?", [$_GET['edit']]);
    if ($editBanner) {
        $editMedia = $db->fetchAll("SELECT * FROM admin_banner_media WHERE banner_id = ? ORDER BY sort_order", [$editBanner['id']]);
    }
}

include 'includes/header.php';
?>

<div class="container-fluid py-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0">إدارة البانرات الإعلانية</h1>
        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#bannerModal">
            <i class="bi bi-plus-lg me-1"></i> إضافة بانر جديد
        </button>
    </div>

    <?php if ($message): ?>
    <div class="alert alert-<?= $messageType ?> alert-dismissible fade show" role="alert">
        <?= htmlspecialchars($message) ?>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <?php endif; ?>

    <div class="card">
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover align-middle">
                    <thead>
                        <tr>
                            <th width="60">الترتيب</th>
                            <th width="80">الصورة</th>
                            <th>العنوان</th>
                            <th>النوع</th>
                            <th>الموقع</th>
                            <th>السعر</th>
                            <th>الحالة</th>
                            <th>المشاهدات</th>
                            <th width="150">إجراءات</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($banners as $banner): ?>
                        <tr>
                            <td><?= $banner['display_order'] ?></td>
                            <td>
                                <?php if ($banner['thumbnail']): ?>
                                <img src="<?= UPLOAD_URL . $banner['thumbnail'] ?>" class="rounded" width="60" height="60" style="object-fit: cover;">
                                <?php else: ?>
                                <div class="bg-secondary rounded d-flex align-items-center justify-content-center" style="width:60px;height:60px;">
                                    <i class="bi bi-image text-white"></i>
                                </div>
                                <?php endif; ?>
                            </td>
                            <td>
                                <strong><?= htmlspecialchars($banner['title']) ?></strong>
                                <?php if ($banner['description']): ?>
                                <br><small class="text-muted"><?= mb_substr($banner['description'], 0, 50) ?>...</small>
                                <?php endif; ?>
                            </td>
                            <td>
                                <?php
                                $typeLabels = ['property' => 'عقار', 'car' => 'سيارة', 'general' => 'عام'];
                                echo $typeLabels[$banner['banner_type']] ?? $banner['banner_type'];
                                ?>
                            </td>
                            <td>
                                <?= $banner['region_name'] ?? '-' ?>
                                <?php if ($banner['city_name']): ?><br><small><?= $banner['city_name'] ?></small><?php endif; ?>
                            </td>
                            <td>
                                <?php if ($banner['price']): ?>
                                <?= number_format($banner['price']) ?> ₪
                                <?php elseif ($banner['price_text']): ?>
                                <?= htmlspecialchars($banner['price_text']) ?>
                                <?php else: ?>
                                -
                                <?php endif; ?>
                            </td>
                            <td>
                                <form method="POST" style="display:inline;">
                                    <input type="hidden" name="action" value="toggle_status">
                                    <input type="hidden" name="id" value="<?= $banner['id'] ?>">
                                    <button type="submit" class="btn btn-sm <?= $banner['is_active'] ? 'btn-success' : 'btn-secondary' ?>">
                                        <?= $banner['is_active'] ? 'نشط' : 'متوقف' ?>
                                    </button>
                                </form>
                            </td>
                            <td><?= number_format($banner['views_count']) ?></td>
                            <td>
                                <a href="?edit=<?= $banner['id'] ?>" class="btn btn-sm btn-outline-primary">
                                    <i class="bi bi-pencil"></i>
                                </a>
                                <form method="POST" style="display:inline;" onsubmit="return confirm('هل أنت متأكد من الحذف؟')">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="<?= $banner['id'] ?>">
                                    <button type="submit" class="btn btn-sm btn-outline-danger">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </form>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                        <?php if (empty($banners)): ?>
                        <tr>
                            <td colspan="9" class="text-center text-muted py-4">لا توجد بانرات حالياً</td>
                        </tr>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Banner Modal -->
<div class="modal fade" id="bannerModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form method="POST" enctype="multipart/form-data">
                <input type="hidden" name="action" value="<?= $editBanner ? 'update' : 'create' ?>">
                <?php if ($editBanner): ?>
                <input type="hidden" name="id" value="<?= $editBanner['id'] ?>">
                <?php endif; ?>
                
                <div class="modal-header">
                    <h5 class="modal-title"><?= $editBanner ? 'تعديل البانر' : 'إضافة بانر جديد' ?></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-8">
                            <label class="form-label">العنوان الافتراضي *</label>
                            <input type="text" name="title" class="form-control" required value="<?= htmlspecialchars($editBanner['title'] ?? '') ?>">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">النوع</label>
                            <select name="banner_type" class="form-select" id="bannerType">
                                <option value="property" <?= ($editBanner['banner_type'] ?? '') === 'property' ? 'selected' : '' ?>>عقار</option>
                                <option value="car" <?= ($editBanner['banner_type'] ?? '') === 'car' ? 'selected' : '' ?>>سيارة</option>
                                <option value="general" <?= ($editBanner['banner_type'] ?? '') === 'general' ? 'selected' : '' ?>>عام</option>
                            </select>
                        </div>
                        
                        <!-- Translated Titles -->
                        <div class="col-12">
                            <div class="card bg-light">
                                <div class="card-header py-2">
                                    <strong><i class="bi bi-translate me-1"></i> ترجمة العنوان</strong>
                                </div>
                                <div class="card-body py-2">
                                    <div class="row g-2">
                                        <div class="col-md-4">
                                            <label class="form-label small">عربي</label>
                                            <input type="text" name="title_ar" class="form-control form-control-sm" value="<?= htmlspecialchars($editBanner['title_ar'] ?? '') ?>" dir="rtl">
                                        </div>
                                        <div class="col-md-4">
                                            <label class="form-label small">עברית</label>
                                            <input type="text" name="title_he" class="form-control form-control-sm" value="<?= htmlspecialchars($editBanner['title_he'] ?? '') ?>" dir="rtl">
                                        </div>
                                        <div class="col-md-4">
                                            <label class="form-label small">English</label>
                                            <input type="text" name="title_en" class="form-control form-control-sm" value="<?= htmlspecialchars($editBanner['title_en'] ?? '') ?>" dir="ltr">
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-12">
                            <label class="form-label">الوصف الافتراضي</label>
                            <textarea name="description" class="form-control" rows="2"><?= htmlspecialchars($editBanner['description'] ?? '') ?></textarea>
                        </div>
                        
                        <!-- Translated Descriptions -->
                        <div class="col-12">
                            <div class="card bg-light">
                                <div class="card-header py-2">
                                    <strong><i class="bi bi-translate me-1"></i> ترجمة الوصف</strong>
                                </div>
                                <div class="card-body py-2">
                                    <div class="row g-2">
                                        <div class="col-md-4">
                                            <label class="form-label small">عربي</label>
                                            <textarea name="description_ar" class="form-control form-control-sm" rows="2" dir="rtl"><?= htmlspecialchars($editBanner['description_ar'] ?? '') ?></textarea>
                                        </div>
                                        <div class="col-md-4">
                                            <label class="form-label small">עברית</label>
                                            <textarea name="description_he" class="form-control form-control-sm" rows="2" dir="rtl"><?= htmlspecialchars($editBanner['description_he'] ?? '') ?></textarea>
                                        </div>
                                        <div class="col-md-4">
                                            <label class="form-label small">English</label>
                                            <textarea name="description_en" class="form-control form-control-sm" rows="2" dir="ltr"><?= htmlspecialchars($editBanner['description_en'] ?? '') ?></textarea>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <label class="form-label">المنطقة</label>
                            <select name="region_id" class="form-select" id="regionSelect">
                                <option value="">اختر المنطقة</option>
                                <?php foreach ($regions as $region): ?>
                                <option value="<?= $region['id'] ?>" <?= ($editBanner['region_id'] ?? '') == $region['id'] ? 'selected' : '' ?>><?= $region['name_ar'] ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">المدينة</label>
                            <select name="city_id" class="form-select" id="citySelect">
                                <option value="">اختر المدينة</option>
                            </select>
                        </div>
                        
                        <div class="col-12">
                            <label class="form-label">العنوان التفصيلي</label>
                            <input type="text" name="address_text" class="form-control" value="<?= htmlspecialchars($editBanner['address_text'] ?? '') ?>">
                        </div>
                        
                        <div class="col-md-6">
                            <label class="form-label">السعر</label>
                            <input type="number" name="price" class="form-control" value="<?= $editBanner['price'] ?? '' ?>">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">نص السعر (بديل)</label>
                            <input type="text" name="price_text" class="form-control" placeholder="مثال: قابل للتفاوض" value="<?= htmlspecialchars($editBanner['price_text'] ?? '') ?>">
                        </div>
                        
                        <!-- Property Fields -->
                        <div id="propertyFields" class="col-12">
                            <div class="row g-3">
                                <div class="col-md-4">
                                    <label class="form-label">نوع العقار</label>
                                    <select name="property_type" class="form-select">
                                        <option value="">اختر</option>
                                        <option value="apartment" <?= ($editBanner['property_type'] ?? '') === 'apartment' ? 'selected' : '' ?>>شقة</option>
                                        <option value="villa_chalet" <?= ($editBanner['property_type'] ?? '') === 'villa_chalet' ? 'selected' : '' ?>>فيلا/شاليه</option>
                                        <option value="shop_office" <?= ($editBanner['property_type'] ?? '') === 'shop_office' ? 'selected' : '' ?>>محل/مكتب</option>
                                        <option value="land" <?= ($editBanner['property_type'] ?? '') === 'land' ? 'selected' : '' ?>>أرض</option>
                                    </select>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">غرف</label>
                                    <input type="number" name="bedrooms" class="form-control" value="<?= $editBanner['bedrooms'] ?? '' ?>">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">حمامات</label>
                                    <input type="number" name="bathrooms" class="form-control" value="<?= $editBanner['bathrooms'] ?? '' ?>">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">المساحة</label>
                                    <input type="number" name="area_m2" class="form-control" value="<?= $editBanner['area_m2'] ?? '' ?>">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label">الطابق</label>
                                    <input type="number" name="floor" class="form-control" value="<?= $editBanner['floor'] ?? '' ?>">
                                </div>
                            </div>
                        </div>
                        
                        <!-- Car Fields -->
                        <div id="carFields" class="col-12" style="display:none;">
                            <div class="row g-3">
                                <div class="col-md-4">
                                    <label class="form-label">موديل السيارة</label>
                                    <input type="text" name="car_model" class="form-control" value="<?= htmlspecialchars($editBanner['car_model'] ?? '') ?>">
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">سنة الصنع</label>
                                    <input type="number" name="car_year" class="form-control" value="<?= $editBanner['car_year'] ?? '' ?>">
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label">ناقل الحركة</label>
                                    <select name="gearbox" class="form-select">
                                        <option value="">اختر</option>
                                        <option value="automatic" <?= ($editBanner['gearbox'] ?? '') === 'automatic' ? 'selected' : '' ?>>أوتوماتيك</option>
                                        <option value="manual" <?= ($editBanner['gearbox'] ?? '') === 'manual' ? 'selected' : '' ?>>عادي</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-md-6">
                            <label class="form-label">رقم التواصل</label>
                            <input type="text" name="contact_phone" class="form-control" value="<?= htmlspecialchars($editBanner['contact_phone'] ?? '') ?>">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">واتساب</label>
                            <input type="text" name="whatsapp" class="form-control" value="<?= htmlspecialchars($editBanner['whatsapp'] ?? '') ?>">
                        </div>
                        
                        <div class="col-md-4">
                            <label class="form-label">ترتيب العرض</label>
                            <input type="number" name="display_order" class="form-control" value="<?= $editBanner['display_order'] ?? 0 ?>">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">يبدأ من</label>
                            <input type="datetime-local" name="starts_at" class="form-control" value="<?= $editBanner['starts_at'] ? date('Y-m-d\TH:i', strtotime($editBanner['starts_at'])) : '' ?>">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">ينتهي في</label>
                            <input type="datetime-local" name="ends_at" class="form-control" value="<?= $editBanner['ends_at'] ? date('Y-m-d\TH:i', strtotime($editBanner['ends_at'])) : '' ?>">
                        </div>
                        
                        <div class="col-12">
                            <div class="form-check">
                                <input type="checkbox" name="is_active" class="form-check-input" id="isActive" <?= ($editBanner['is_active'] ?? 1) ? 'checked' : '' ?>>
                                <label class="form-check-label" for="isActive">نشط</label>
                            </div>
                        </div>
                        
                        <div class="col-12">
                            <label class="form-label">الصور</label>
                            <input type="file" name="images[]" class="form-control" multiple accept="image/*">
                            <small class="text-muted">يمكنك رفع عدة صور</small>
                        </div>
                        
                        <?php if (!empty($editMedia)): ?>
                        <div class="col-12">
                            <label class="form-label">الصور الحالية</label>
                            <div class="d-flex gap-2 flex-wrap">
                                <?php foreach ($editMedia as $media): ?>
                                <div class="position-relative">
                                    <img src="<?= UPLOAD_URL . $media['file_path'] ?>" class="rounded" width="100" height="100" style="object-fit: cover;">
                                    <form method="POST" class="position-absolute top-0 end-0">
                                        <input type="hidden" name="action" value="delete_media">
                                        <input type="hidden" name="media_id" value="<?= $media['id'] ?>">
                                        <button type="submit" class="btn btn-danger btn-sm rounded-circle" style="width:24px;height:24px;padding:0;">
                                            <i class="bi bi-x"></i>
                                        </button>
                                    </form>
                                </div>
                                <?php endforeach; ?>
                            </div>
                        </div>
                        <?php endif; ?>
                    </div>
                </div>
                
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">إلغاء</button>
                    <button type="submit" class="btn btn-primary"><?= $editBanner ? 'تحديث' : 'إنشاء' ?></button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const bannerType = document.getElementById('bannerType');
    const propertyFields = document.getElementById('propertyFields');
    const carFields = document.getElementById('carFields');
    
    function toggleFields() {
        if (bannerType.value === 'property') {
            propertyFields.style.display = 'block';
            carFields.style.display = 'none';
        } else if (bannerType.value === 'car') {
            propertyFields.style.display = 'none';
            carFields.style.display = 'block';
        } else {
            propertyFields.style.display = 'none';
            carFields.style.display = 'none';
        }
    }
    
    bannerType.addEventListener('change', toggleFields);
    toggleFields();
    
    // Region/City cascade
    const regionSelect = document.getElementById('regionSelect');
    const citySelect = document.getElementById('citySelect');
    const selectedCity = '<?= $editBanner['city_id'] ?? '' ?>';
    
    regionSelect.addEventListener('change', function() {
        const regionId = this.value;
        citySelect.innerHTML = '<option value="">اختر المدينة</option>';
        
        if (regionId) {
            fetch('../backend/api/regions/' + regionId + '/cities')
                .then(r => r.json())
                .then(data => {
                    if (data.success && data.data) {
                        data.data.forEach(city => {
                            const opt = document.createElement('option');
                            opt.value = city.id;
                            opt.textContent = city.name_ar;
                            if (city.id == selectedCity) opt.selected = true;
                            citySelect.appendChild(opt);
                        });
                    }
                });
        }
    });
    
    if (regionSelect.value) {
        regionSelect.dispatchEvent(new Event('change'));
    }
    
    // Open modal if editing
    <?php if ($editBanner): ?>
    new bootstrap.Modal(document.getElementById('bannerModal')).show();
    <?php endif; ?>
});
</script>

<?php include 'includes/footer.php'; ?>
