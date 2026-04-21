<?php
session_start();
require_once __DIR__ . '/../backend/config/database.php';
require_once __DIR__ . '/../backend/config/constants.php';

if (!isset($_SESSION['admin_id'])) {
    header('Location: login.php');
    exit;
}

$db = Database::getInstance();
$message = '';

// Handle form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    
    if ($action === 'save') {
        $id = (int)($_POST['id'] ?? 0);
        $data = [
            'category' => $_POST['category'],
            'name_ar' => $_POST['name_ar'],
            'name_en' => $_POST['name_en'],
            'name_he' => $_POST['name_he'],
            'plan_type' => $_POST['plan_type'],
            'property_type' => $_POST['property_type'] ?: null,
            'car_usage_type' => $_POST['car_usage_type'] ?: null,
            'property_type_id' => $_POST['property_type_id'] ?: null,
            'car_type_id' => $_POST['car_type_id'] ?: null,
            'listings_count' => $_POST['listings_count'] ?: null,
            'is_unlimited' => isset($_POST['is_unlimited']) ? 1 : 0,
            'max_images' => $_POST['max_images'] ?: 10,
            'duration_days' => $_POST['duration_days'],
            'price' => $_POST['price'],
            'original_price' => $_POST['original_price'] ?: null,
            'discount_percent' => $_POST['discount_percent'] ?: null,
            'badge' => $_POST['badge'] ?: null,
            'is_featured' => isset($_POST['is_featured']) ? 1 : 0,
            'allow_region_notifications' => isset($_POST['allow_region_notifications']) ? 1 : 0,
            'allow_city_notifications' => isset($_POST['allow_city_notifications']) ? 1 : 0,
            'is_trusted_advertiser' => isset($_POST['is_trusted_advertiser']) ? 1 : 0,
            'is_active' => isset($_POST['is_active']) ? 1 : 0,
            'is_welcome_bonus' => isset($_POST['is_welcome_bonus']) ? 1 : 0,
            'sort_order' => $_POST['sort_order'] ?? 0,
            'ios_product_id' => $_POST['ios_product_id'] ?: null,
            'android_product_id' => $_POST['android_product_id'] ?: null
        ];
        
        // If this is a welcome bonus, remove welcome bonus from other plans in same category
        if (isset($_POST['is_welcome_bonus'])) {
            $db->query("UPDATE plans SET is_welcome_bonus = 0 WHERE category = ? AND id != ?", 
                       [$_POST['category'], $id]);
        }
        
        if ($id) {
            $db->update('plans', $data, 'id = ?', [$id]);
            $message = 'تم تحديث الباقة بنجاح';
        } else {
            $db->insert('plans', $data);
            $message = 'تم إضافة الباقة بنجاح';
        }
        // Redirect after save to prevent resubmission
        header('Location: plans.php?category=' . urlencode($_POST['category']) . '&msg=' . urlencode($message));
        exit;
        
    } elseif ($action === 'delete') {
        $id = (int)($_POST['id'] ?? 0);
        
        // Check if plan has subscriptions
        $hasSubscriptions = $db->fetch("SELECT COUNT(*) as count FROM subscriptions WHERE plan_id = ?", [$id]);
        if ($hasSubscriptions && $hasSubscriptions['count'] > 0) {
            $message = 'لا يمكن حذف هذه الباقة لأنها مرتبطة باشتراكات. يمكنك تعطيلها بدلاً من حذفها.';
            $messageType = 'danger';
        } else {
            try {
                $db->delete('plans', 'id = ?', [$id]);
                $message = 'تم حذف الباقة';
                $messageType = 'success';
            } catch (Exception $e) {
                $message = 'خطأ في حذف الباقة: ' . $e->getMessage();
                $messageType = 'danger';
            }
        }
        header('Location: plans.php?category=' . urlencode($category) . '&msg=' . urlencode($message) . '&type=' . ($messageType ?? 'success'));
        exit;
    }
}

// Handle message from redirect
if (isset($_GET['msg'])) {
    $message = $_GET['msg'];
    $messageType = $_GET['type'] ?? 'success';
}

$category = $_GET['category'] ?? 'properties';
$plans = $db->fetchAll("SELECT * FROM plans WHERE category = ? ORDER BY sort_order, price", [$category]);

// Fetch dynamic types for dropdowns
$propertyTypes = $db->fetchAll("SELECT * FROM property_types WHERE is_active = 1 ORDER BY sort_order, id");
$carTypes = $db->fetchAll("SELECT * FROM car_types WHERE is_active = 1 ORDER BY sort_order, id");

$editPlan = null;
if (isset($_GET['edit'])) {
    $editPlan = $db->fetch("SELECT * FROM plans WHERE id = ?", [$_GET['edit']]);
}

include 'includes/header.php';
?>

<div class="container-fluid py-4">
    <div class="row mb-4">
        <div class="col-12 d-flex justify-content-between align-items-center">
            <h1 class="h3 mb-0">إدارة الباقات والأسعار</h1>
            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#planModal">
                <i class="bi bi-plus-lg me-1"></i> إضافة باقة
            </button>
        </div>
    </div>

    <?php if ($message): ?>
    <div class="alert alert-<?= $messageType ?? 'success' ?> alert-dismissible fade show" role="alert">
        <?= htmlspecialchars($message) ?>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <?php endif; ?>

    <!-- Category Tabs -->
    <ul class="nav nav-tabs mb-4">
        <li class="nav-item">
            <a class="nav-link <?= $category === 'properties' ? 'active' : '' ?>" href="?category=properties">
                <i class="bi bi-building me-1"></i> باقات العقارات
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link <?= $category === 'cars' ? 'active' : '' ?>" href="?category=cars">
                <i class="bi bi-car-front me-1"></i> باقات السيارات
            </a>
        </li>
    </ul>

    <!-- Plans Table -->
    <div class="card">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead>
                        <tr>
                            <th>الترتيب</th>
                            <th>الاسم</th>
                            <th>النوع</th>
                            <th>التخصيص</th>
                            <th>الإعلانات</th>
                            <th>المدة</th>
                            <th>السعر</th>
                            <th>الخصم</th>
                            <th>الشارة</th>
                            <th>الحالة</th>
                            <th>إجراءات</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($plans as $plan): ?>
                        <tr>
                            <td><?= $plan['sort_order'] ?></td>
                            <td>
                                <strong><?= htmlspecialchars($plan['name_ar']) ?></strong><br>
                                <small class="text-muted"><?= htmlspecialchars($plan['name_en']) ?></small>
                            </td>
                            <td><?= $plan['plan_type'] === 'single' ? 'إعلان واحد' : 'باقة' ?></td>
                            <td>
                                <?php 
                                $typeLabels = [
                                    'apartment' => 'شقة',
                                    'villa_chalet' => 'فيلا/شاليه',
                                    'shop_office' => 'محل/مكتب',
                                    'student_housing' => 'سكن طلاب',
                                    'land' => 'أرض',
                                    'daily' => 'يومي',
                                    'wedding' => 'أعراس',
                                    'tourism' => 'سياحة'
                                ];
                                $specificType = $plan['property_type'] ?? $plan['car_usage_type'] ?? null;
                                if ($specificType && isset($typeLabels[$specificType])):
                                ?>
                                <span class="badge bg-info"><?= $typeLabels[$specificType] ?></span>
                                <?php else: ?>
                                <span class="text-muted">-</span>
                                <?php endif; ?>
                            </td>
                            <td><?= $plan['is_unlimited'] ? 'غير محدود' : $plan['listings_count'] ?></td>
                            <td><?= $plan['duration_days'] ?> يوم</td>
                            <td>
                                <?php if ($plan['original_price']): ?>
                                <del class="text-muted"><?= number_format($plan['original_price'], 2) ?></del>
                                <?php endif; ?>
                                <strong class="text-success"><?= number_format($plan['price'], 2) ?> ₪</strong>
                            </td>
                            <td>
                                <?php if ($plan['discount_percent']): ?>
                                <span class="badge bg-danger"><?= $plan['discount_percent'] ?>%</span>
                                <?php endif; ?>
                            </td>
                            <td>
                                <?php if ($plan['badge']): ?>
                                <span class="badge bg-<?= $plan['badge'] === 'gold' ? 'warning' : ($plan['badge'] === 'silver' ? 'secondary' : 'dark') ?>">
                                    <?= $plan['badge'] ?>
                                </span>
                                <?php endif; ?>
                            </td>
                            <td>
                                <?= $plan['is_active'] ? '<span class="badge bg-success">نشط</span>' : '<span class="badge bg-secondary">معطل</span>' ?>
                            </td>
                            <td>
                                <a href="?category=<?= $category ?>&edit=<?= $plan['id'] ?>" class="btn btn-sm btn-outline-primary">
                                    <i class="bi bi-pencil"></i>
                                </a>
                                <form method="POST" class="d-inline" onsubmit="return confirm('هل أنت متأكد من الحذف؟')">
                                    <input type="hidden" name="action" value="delete">
                                    <input type="hidden" name="id" value="<?= $plan['id'] ?>">
                                    <button type="submit" class="btn btn-sm btn-outline-danger">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </form>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Plan Modal -->
<div class="modal fade" id="planModal" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <form method="POST">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="id" value="<?= $editPlan['id'] ?? '' ?>">
                
                <div class="modal-header">
                    <h5 class="modal-title"><?= $editPlan ? 'تعديل الباقة' : 'إضافة باقة جديدة' ?></h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">الفئة</label>
                            <select name="category" class="form-select" required>
                                <option value="properties" <?= ($editPlan['category'] ?? $category) === 'properties' ? 'selected' : '' ?>>عقارات</option>
                                <option value="cars" <?= ($editPlan['category'] ?? '') === 'cars' ? 'selected' : '' ?>>سيارات</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">نوع الباقة</label>
                            <select name="plan_type" class="form-select" required>
                                <option value="single" <?= ($editPlan['plan_type'] ?? '') === 'single' ? 'selected' : '' ?>>إعلان واحد</option>
                                <option value="package" <?= ($editPlan['plan_type'] ?? '') === 'package' ? 'selected' : '' ?>>باقة</option>
                            </select>
                        </div>
                        <div class="col-md-6" id="propertyTypeContainer" style="display: none;">
                            <label class="form-label">نوع العقار <small class="text-muted">(اختياري - للتخصيص)</small></label>
                            <select name="property_type_id" class="form-select">
                                <option value="">جميع الأنواع</option>
                                <?php foreach ($propertyTypes as $type): ?>
                                <option value="<?= $type['id'] ?>" <?= ($editPlan['property_type_id'] ?? '') == $type['id'] ? 'selected' : '' ?>><?= htmlspecialchars($type['name_ar']) ?></option>
                                <?php endforeach; ?>
                            </select>
                            <input type="hidden" name="property_type" value="">
                        </div>
                        <div class="col-md-6" id="carUsageTypeContainer" style="display: none;">
                            <label class="form-label">نوع استخدام السيارة <small class="text-muted">(اختياري - للتخصيص)</small></label>
                            <select name="car_type_id" class="form-select">
                                <option value="">جميع الأنواع</option>
                                <?php foreach ($carTypes as $type): ?>
                                <option value="<?= $type['id'] ?>" <?= ($editPlan['car_type_id'] ?? '') == $type['id'] ? 'selected' : '' ?>><?= htmlspecialchars($type['name_ar']) ?></option>
                                <?php endforeach; ?>
                            </select>
                            <input type="hidden" name="car_usage_type" value="">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">الاسم (عربي)</label>
                            <input type="text" name="name_ar" class="form-control" required value="<?= htmlspecialchars($editPlan['name_ar'] ?? '') ?>">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">الاسم (إنجليزي)</label>
                            <input type="text" name="name_en" class="form-control" required value="<?= htmlspecialchars($editPlan['name_en'] ?? '') ?>">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">الاسم (عبري)</label>
                            <input type="text" name="name_he" class="form-control" required value="<?= htmlspecialchars($editPlan['name_he'] ?? '') ?>">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">عدد الإعلانات</label>
                            <input type="number" name="listings_count" class="form-control" value="<?= $editPlan['listings_count'] ?? '' ?>">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">المدة (أيام)</label>
                            <input type="number" name="duration_days" class="form-control" required value="<?= $editPlan['duration_days'] ?? 30 ?>">
                        </div>
                        <div class="col-md-3">
                            <label class="form-label">حد الصور <i class="bi bi-images text-muted"></i></label>
                            <input type="number" name="max_images" class="form-control" value="<?= $editPlan['max_images'] ?? 10 ?>" min="1" max="20">
                            <small class="text-muted">الحد الأقصى للصور لكل إعلان</small>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">السعر (₪)</label>
                            <input type="number" step="0.01" name="price" class="form-control" required value="<?= $editPlan['price'] ?? '' ?>">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">السعر الأصلي (للخصم)</label>
                            <input type="number" step="0.01" name="original_price" class="form-control" value="<?= $editPlan['original_price'] ?? '' ?>">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">نسبة الخصم %</label>
                            <input type="number" name="discount_percent" class="form-control" value="<?= $editPlan['discount_percent'] ?? '' ?>">
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">الشارة</label>
                            <select name="badge" class="form-select">
                                <option value="">بدون</option>
                                <option value="bronze" <?= ($editPlan['badge'] ?? '') === 'bronze' ? 'selected' : '' ?>>Bronze</option>
                                <option value="silver" <?= ($editPlan['badge'] ?? '') === 'silver' ? 'selected' : '' ?>>Silver</option>
                                <option value="gold" <?= ($editPlan['badge'] ?? '') === 'gold' ? 'selected' : '' ?>>Gold</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label">الترتيب</label>
                            <input type="number" name="sort_order" class="form-control" value="<?= $editPlan['sort_order'] ?? 0 ?>">
                        </div>
                        <div class="col-12">
                            <div class="form-check form-check-inline">
                                <input type="checkbox" name="is_unlimited" class="form-check-input" id="isUnlimited" 
                                       <?= !empty($editPlan['is_unlimited']) ? 'checked' : '' ?>>
                                <label class="form-check-label" for="isUnlimited">إعلانات غير محدودة</label>
                            </div>
                            <div class="form-check form-check-inline">
                                <input type="checkbox" name="is_featured" class="form-check-input" id="isFeatured"
                                       <?= !empty($editPlan['is_featured']) ? 'checked' : '' ?>>
                                <label class="form-check-label" for="isFeatured">مميزة</label>
                            </div>
                            <div class="form-check form-check-inline">
                                <input type="checkbox" name="allow_region_notifications" class="form-check-input" id="allowRegionNotifications"
                                       <?= !empty($editPlan['allow_region_notifications']) ? 'checked' : '' ?>>
                                <label class="form-check-label" for="allowRegionNotifications">
                                    <i class="bi bi-bell"></i> إشعارات للمنطقة
                                </label>
                            </div>
                            <div class="form-check form-check-inline">
                                <input type="checkbox" name="allow_city_notifications" class="form-check-input" id="allowCityNotifications"
                                       <?= !empty($editPlan['allow_city_notifications']) ? 'checked' : '' ?>>
                                <label class="form-check-label" for="allowCityNotifications">
                                    <i class="bi bi-geo-alt"></i> إشعارات للمدينة
                                </label>
                            </div>
                            <div class="form-check form-check-inline">
                                <input type="checkbox" name="is_trusted_advertiser" class="form-check-input" id="isTrustedAdvertiser"
                                       <?= !empty($editPlan['is_trusted_advertiser']) ? 'checked' : '' ?>>
                                <label class="form-check-label" for="isTrustedAdvertiser">
                                    <i class="bi bi-star-fill text-warning"></i> معلن مميز
                                </label>
                            </div>
                            <div class="form-check form-check-inline">
                                <input type="checkbox" name="is_active" class="form-check-input" id="isActive" checked
                                       <?= isset($editPlan) && !$editPlan['is_active'] ? '' : 'checked' ?>>
                                <label class="form-check-label" for="isActive">نشطة</label>
                            </div>
                        </div>
                        <!-- In-App Purchase IDs -->
                        <div class="col-12 mt-3">
                            <div class="card bg-light">
                                <div class="card-body">
                                    <h6 class="card-title mb-3"><i class="bi bi-phone me-1"></i> In-App Purchase IDs</h6>
                                    <div class="row g-3">
                                        <div class="col-md-6">
                                            <label class="form-label"><i class="bi bi-apple"></i> iOS Product ID</label>
                                            <input type="text" name="ios_product_id" class="form-control" 
                                                   placeholder="com.rentogo.app.plan_name"
                                                   value="<?= htmlspecialchars($editPlan['ios_product_id'] ?? '') ?>">
                                            <small class="text-muted">معرّف المنتج في App Store Connect</small>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label"><i class="bi bi-google-play"></i> Android Product ID</label>
                                            <input type="text" name="android_product_id" class="form-control" 
                                                   placeholder="plan_name"
                                                   value="<?= htmlspecialchars($editPlan['android_product_id'] ?? '') ?>">
                                            <small class="text-muted">معرّف المنتج في Google Play Console</small>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-12 mt-3">
                            <div class="alert alert-info mb-0">
                                <div class="form-check">
                                    <input type="checkbox" name="is_welcome_bonus" class="form-check-input" id="isWelcomeBonus"
                                           <?= !empty($editPlan['is_welcome_bonus']) ? 'checked' : '' ?>>
                                    <label class="form-check-label" for="isWelcomeBonus">
                                        <i class="bi bi-gift text-success me-1"></i>
                                        <strong>باقة ترحيبية مجانية</strong>
                                    </label>
                                </div>
                                <small class="text-muted d-block mt-1">
                                    تُعطى تلقائياً للمستخدمين الجدد عند التسجيل (مرة واحدة فقط). 
                                    يمكن تحديد باقة ترحيبية واحدة فقط لكل فئة (عقارات/سيارات).
                                </small>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">إلغاء</button>
                    <button type="submit" class="btn btn-primary">حفظ</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    function toggleTypeFields() {
        const categorySelect = document.querySelector('select[name="category"]');
        if (!categorySelect) return;
        
        const category = categorySelect.value;
        const propertyContainer = document.getElementById('propertyTypeContainer');
        const carContainer = document.getElementById('carUsageTypeContainer');
        const carTypeSelect = document.querySelector('select[name="car_type_id"]');
        const propertyTypeSelect = document.querySelector('select[name="property_type_id"]');
        
        if (category === 'properties') {
            if (propertyContainer) propertyContainer.style.display = 'block';
            if (carContainer) carContainer.style.display = 'none';
            if (carTypeSelect) carTypeSelect.value = '';
        } else if (category === 'cars') {
            if (propertyContainer) propertyContainer.style.display = 'none';
            if (carContainer) carContainer.style.display = 'block';
            if (propertyTypeSelect) propertyTypeSelect.value = '';
        } else {
            if (propertyContainer) propertyContainer.style.display = 'none';
            if (carContainer) carContainer.style.display = 'none';
        }
    }
    
    document.addEventListener('DOMContentLoaded', function() {
        const categorySelect = document.querySelector('select[name="category"]');
        if (categorySelect) {
            categorySelect.addEventListener('change', toggleTypeFields);
        }
        
        // Initial toggle
        toggleTypeFields();
        
        <?php if ($editPlan): ?>
        new bootstrap.Modal(document.getElementById('planModal')).show();
        <?php endif; ?>
    });
</script>

<?php include 'includes/footer.php'; ?>
