<?php
require_once 'includes/header.php';
require_once '../backend/config/database.php';

$db = Database::getInstance();
$message = '';
$messageType = '';
$activeTab = $_GET['tab'] ?? 'property';

// Handle POST requests
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    try {
        $action = $_POST['action'] ?? '';
        $type = $_POST['type'] ?? 'property'; // property or car
        $table = $type === 'car' ? 'car_types' : 'property_types';
        
        if ($action === 'save') {
            $id = $_POST['id'] ?? 0;
            $data = [
                'name_ar' => trim($_POST['name_ar'] ?? ''),
                'name_en' => trim($_POST['name_en'] ?? ''),
                'name_he' => trim($_POST['name_he'] ?? ''),
                'slug' => trim($_POST['slug'] ?? ''),
                'icon' => trim($_POST['icon'] ?? ''),
                'sort_order' => (int)($_POST['sort_order'] ?? 0),
                'is_active' => isset($_POST['is_active']) ? 1 : 0,
            ];
            
            // Generate slug if empty
            if (empty($data['slug'])) {
                $data['slug'] = strtolower(preg_replace('/[^a-zA-Z0-9]+/', '_', $data['name_en']));
            }
            
            if ($id > 0) {
                $db->update($table, $data, 'id = ?', [$id]);
                $message = 'تم تحديث التصنيف بنجاح';
            } else {
                $db->insert($table, $data);
                $message = 'تم إضافة التصنيف بنجاح';
            }
            $messageType = 'success';
            $activeTab = $type;
            
        } elseif ($action === 'delete') {
            $id = $_POST['id'] ?? 0;
            $db->delete($table, 'id = ?', [$id]);
            $message = 'تم حذف التصنيف';
            $messageType = 'warning';
            $activeTab = $type;
            
        } elseif ($action === 'toggle_status') {
            $id = $_POST['id'] ?? 0;
            $db->query("UPDATE $table SET is_active = NOT is_active WHERE id = ?", [$id]);
            $message = 'تم تغيير الحالة';
            $messageType = 'info';
            $activeTab = $type;
        }
    } catch (Exception $e) {
        $message = 'خطأ: ' . $e->getMessage();
        $messageType = 'danger';
    }
}

// Fetch all types
$propertyTypes = $db->fetchAll("SELECT * FROM property_types ORDER BY sort_order, id") ?: [];
$carTypes = $db->fetchAll("SELECT * FROM car_types ORDER BY sort_order, id") ?: [];

// Count usage
$propertyTypesUsage = [];
$carTypesUsage = [];

$propertyUsage = $db->fetchAll("SELECT property_type_id, COUNT(*) as count FROM properties WHERE property_type_id IS NOT NULL GROUP BY property_type_id") ?: [];
foreach ($propertyUsage as $u) {
    $propertyTypesUsage[$u['property_type_id']] = $u['count'];
}

$carUsage = $db->fetchAll("SELECT car_type_id, COUNT(*) as count FROM cars WHERE car_type_id IS NOT NULL GROUP BY car_type_id") ?: [];
foreach ($carUsage as $u) {
    $carTypesUsage[$u['car_type_id']] = $u['count'];
}

// Icons list for selection
$icons = [
    'apartment', 'home', 'house', 'villa', 'cabin', 'bed', 'hotel',
    'store', 'storefront', 'work', 'business', 'domain', 'school',
    'landscape', 'terrain', 'location_city', 'corporate_fare',
    'directions_car', 'car_rental', 'local_taxi', 'airport_shuttle',
    'favorite', 'flight', 'local_shipping', 'calendar_today', 'event'
];
?>

<div class="container-fluid py-4">
    <?php if ($message): ?>
        <div class="alert alert-<?= $messageType ?> alert-dismissible fade show">
            <?= $message ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <?php endif; ?>

    <div class="d-flex justify-content-between align-items-center mb-4">
        <h4 class="mb-0">
            <i class="fas fa-tags me-2"></i>
            إدارة التصنيفات
        </h4>
    </div>

    <!-- Tabs -->
    <ul class="nav nav-tabs mb-4" role="tablist">
        <li class="nav-item">
            <a class="nav-link <?= $activeTab === 'property' ? 'active' : '' ?>" 
               href="#property-types" data-bs-toggle="tab">
                <i class="fas fa-building me-1"></i>
                أنواع العقارات
                <span class="badge bg-primary ms-1"><?= count($propertyTypes) ?></span>
            </a>
        </li>
        <li class="nav-item">
            <a class="nav-link <?= $activeTab === 'car' ? 'active' : '' ?>" 
               href="#car-types" data-bs-toggle="tab">
                <i class="fas fa-car me-1"></i>
                أنواع السيارات
                <span class="badge bg-success ms-1"><?= count($carTypes) ?></span>
            </a>
        </li>
    </ul>

    <div class="tab-content">
        <!-- Property Types Tab -->
        <div class="tab-pane fade <?= $activeTab === 'property' ? 'show active' : '' ?>" id="property-types">
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <span>أنواع العقارات</span>
                    <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#propertyTypeModal" onclick="resetForm('property')">
                        <i class="fas fa-plus me-1"></i> إضافة نوع جديد
                    </button>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th width="50">#</th>
                                    <th>الأيقونة</th>
                                    <th>الاسم (عربي)</th>
                                    <th>الاسم (إنجليزي)</th>
                                    <th>الاسم (عبري)</th>
                                    <th>الترتيب</th>
                                    <th>الإعلانات</th>
                                    <th>الحالة</th>
                                    <th width="120">إجراءات</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($propertyTypes as $pt): ?>
                                <tr>
                                    <td><?= $pt['id'] ?></td>
                                    <td>
                                        <span class="material-icons text-primary"><?= htmlspecialchars($pt['icon'] ?? 'home') ?></span>
                                    </td>
                                    <td><?= htmlspecialchars($pt['name_ar']) ?></td>
                                    <td><?= htmlspecialchars($pt['name_en']) ?></td>
                                    <td><?= htmlspecialchars($pt['name_he']) ?></td>
                                    <td><?= $pt['sort_order'] ?></td>
                                    <td>
                                        <span class="badge bg-secondary">
                                            <?= $propertyTypesUsage[$pt['id']] ?? 0 ?>
                                        </span>
                                    </td>
                                    <td>
                                        <form method="POST" class="d-inline">
                                            <input type="hidden" name="action" value="toggle_status">
                                            <input type="hidden" name="type" value="property">
                                            <input type="hidden" name="id" value="<?= $pt['id'] ?>">
                                            <button type="submit" class="btn btn-sm <?= $pt['is_active'] ? 'btn-success' : 'btn-secondary' ?>">
                                                <?= $pt['is_active'] ? 'مفعل' : 'معطل' ?>
                                            </button>
                                        </form>
                                    </td>
                                    <td>
                                        <button class="btn btn-sm btn-outline-primary" onclick="editType('property', <?= htmlspecialchars(json_encode($pt)) ?>)">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <?php if (($propertyTypesUsage[$pt['id']] ?? 0) == 0): ?>
                                        <form method="POST" class="d-inline" onsubmit="return confirm('هل أنت متأكد من الحذف؟')">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="type" value="property">
                                            <input type="hidden" name="id" value="<?= $pt['id'] ?>">
                                            <button type="submit" class="btn btn-sm btn-outline-danger">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </form>
                                        <?php endif; ?>
                                    </td>
                                </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- Car Types Tab -->
        <div class="tab-pane fade <?= $activeTab === 'car' ? 'show active' : '' ?>" id="car-types">
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <span>أنواع السيارات</span>
                    <button class="btn btn-success btn-sm" data-bs-toggle="modal" data-bs-target="#carTypeModal" onclick="resetForm('car')">
                        <i class="fas fa-plus me-1"></i> إضافة نوع جديد
                    </button>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover mb-0">
                            <thead class="table-light">
                                <tr>
                                    <th width="50">#</th>
                                    <th>الأيقونة</th>
                                    <th>الاسم (عربي)</th>
                                    <th>الاسم (إنجليزي)</th>
                                    <th>الاسم (عبري)</th>
                                    <th>الترتيب</th>
                                    <th>الإعلانات</th>
                                    <th>الحالة</th>
                                    <th width="120">إجراءات</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($carTypes as $ct): ?>
                                <tr>
                                    <td><?= $ct['id'] ?></td>
                                    <td>
                                        <span class="material-icons text-success"><?= htmlspecialchars($ct['icon'] ?? 'directions_car') ?></span>
                                    </td>
                                    <td><?= htmlspecialchars($ct['name_ar']) ?></td>
                                    <td><?= htmlspecialchars($ct['name_en']) ?></td>
                                    <td><?= htmlspecialchars($ct['name_he']) ?></td>
                                    <td><?= $ct['sort_order'] ?></td>
                                    <td>
                                        <span class="badge bg-secondary">
                                            <?= $carTypesUsage[$ct['id']] ?? 0 ?>
                                        </span>
                                    </td>
                                    <td>
                                        <form method="POST" class="d-inline">
                                            <input type="hidden" name="action" value="toggle_status">
                                            <input type="hidden" name="type" value="car">
                                            <input type="hidden" name="id" value="<?= $ct['id'] ?>">
                                            <button type="submit" class="btn btn-sm <?= $ct['is_active'] ? 'btn-success' : 'btn-secondary' ?>">
                                                <?= $ct['is_active'] ? 'مفعل' : 'معطل' ?>
                                            </button>
                                        </form>
                                    </td>
                                    <td>
                                        <button class="btn btn-sm btn-outline-primary" onclick="editType('car', <?= htmlspecialchars(json_encode($ct)) ?>)">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <?php if (($carTypesUsage[$ct['id']] ?? 0) == 0): ?>
                                        <form method="POST" class="d-inline" onsubmit="return confirm('هل أنت متأكد من الحذف؟')">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="type" value="car">
                                            <input type="hidden" name="id" value="<?= $ct['id'] ?>">
                                            <button type="submit" class="btn btn-sm btn-outline-danger">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </form>
                                        <?php endif; ?>
                                    </td>
                                </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Property Type Modal -->
<div class="modal fade" id="propertyTypeModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="POST">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="type" value="property">
                <input type="hidden" name="id" id="property_id" value="0">
                
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="fas fa-building me-2"></i>
                        <span id="property_modal_title">إضافة نوع عقار</span>
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">الاسم بالعربية *</label>
                        <input type="text" name="name_ar" id="property_name_ar" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">الاسم بالإنجليزية *</label>
                        <input type="text" name="name_en" id="property_name_en" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">الاسم بالعبرية *</label>
                        <input type="text" name="name_he" id="property_name_he" class="form-control" required dir="rtl">
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">الأيقونة</label>
                            <select name="icon" id="property_icon" class="form-select">
                                <?php foreach ($icons as $icon): ?>
                                <option value="<?= $icon ?>"><?= $icon ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">الترتيب</label>
                            <input type="number" name="sort_order" id="property_sort_order" class="form-control" value="0">
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Slug (للرابط)</label>
                        <input type="text" name="slug" id="property_slug" class="form-control" placeholder="يتم إنشاؤه تلقائياً">
                    </div>
                    <div class="form-check">
                        <input type="checkbox" name="is_active" id="property_is_active" class="form-check-input" checked>
                        <label class="form-check-label" for="property_is_active">مفعل</label>
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

<!-- Car Type Modal -->
<div class="modal fade" id="carTypeModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="POST">
                <input type="hidden" name="action" value="save">
                <input type="hidden" name="type" value="car">
                <input type="hidden" name="id" id="car_id" value="0">
                
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="fas fa-car me-2"></i>
                        <span id="car_modal_title">إضافة نوع سيارة</span>
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">الاسم بالعربية *</label>
                        <input type="text" name="name_ar" id="car_name_ar" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">الاسم بالإنجليزية *</label>
                        <input type="text" name="name_en" id="car_name_en" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">الاسم بالعبرية *</label>
                        <input type="text" name="name_he" id="car_name_he" class="form-control" required dir="rtl">
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label">الأيقونة</label>
                            <select name="icon" id="car_icon" class="form-select">
                                <?php foreach ($icons as $icon): ?>
                                <option value="<?= $icon ?>"><?= $icon ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label">الترتيب</label>
                            <input type="number" name="sort_order" id="car_sort_order" class="form-control" value="0">
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Slug (للرابط)</label>
                        <input type="text" name="slug" id="car_slug" class="form-control" placeholder="يتم إنشاؤه تلقائياً">
                    </div>
                    <div class="form-check">
                        <input type="checkbox" name="is_active" id="car_is_active" class="form-check-input" checked>
                        <label class="form-check-label" for="car_is_active">مفعل</label>
                    </div>
                </div>
                
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">إلغاء</button>
                    <button type="submit" class="btn btn-success">حفظ</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Material Icons -->
<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

<script>
function resetForm(type) {
    if (type === 'property') {
        document.getElementById('property_id').value = '0';
        document.getElementById('property_name_ar').value = '';
        document.getElementById('property_name_en').value = '';
        document.getElementById('property_name_he').value = '';
        document.getElementById('property_slug').value = '';
        document.getElementById('property_icon').value = 'home';
        document.getElementById('property_sort_order').value = '0';
        document.getElementById('property_is_active').checked = true;
        document.getElementById('property_modal_title').textContent = 'إضافة نوع عقار';
    } else {
        document.getElementById('car_id').value = '0';
        document.getElementById('car_name_ar').value = '';
        document.getElementById('car_name_en').value = '';
        document.getElementById('car_name_he').value = '';
        document.getElementById('car_slug').value = '';
        document.getElementById('car_icon').value = 'directions_car';
        document.getElementById('car_sort_order').value = '0';
        document.getElementById('car_is_active').checked = true;
        document.getElementById('car_modal_title').textContent = 'إضافة نوع سيارة';
    }
}

function editType(type, data) {
    if (type === 'property') {
        document.getElementById('property_id').value = data.id;
        document.getElementById('property_name_ar').value = data.name_ar;
        document.getElementById('property_name_en').value = data.name_en;
        document.getElementById('property_name_he').value = data.name_he;
        document.getElementById('property_slug').value = data.slug;
        document.getElementById('property_icon').value = data.icon || 'home';
        document.getElementById('property_sort_order').value = data.sort_order;
        document.getElementById('property_is_active').checked = data.is_active == 1;
        document.getElementById('property_modal_title').textContent = 'تعديل نوع عقار';
        new bootstrap.Modal(document.getElementById('propertyTypeModal')).show();
    } else {
        document.getElementById('car_id').value = data.id;
        document.getElementById('car_name_ar').value = data.name_ar;
        document.getElementById('car_name_en').value = data.name_en;
        document.getElementById('car_name_he').value = data.name_he;
        document.getElementById('car_slug').value = data.slug;
        document.getElementById('car_icon').value = data.icon || 'directions_car';
        document.getElementById('car_sort_order').value = data.sort_order;
        document.getElementById('car_is_active').checked = data.is_active == 1;
        document.getElementById('car_modal_title').textContent = 'تعديل نوع سيارة';
        new bootstrap.Modal(document.getElementById('carTypeModal')).show();
    }
}
</script>

<?php require_once 'includes/footer.php'; ?>
