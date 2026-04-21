<?php
session_start();
require_once __DIR__ . '/../backend/config/database.php';

if (!isset($_SESSION['admin_id'])) {
    header('Location: login.php');
    exit;
}

$db = Database::getInstance();
$message = '';

// Handle form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    
    if ($action === 'save_region') {
        $id = (int)($_POST['id'] ?? 0);
        $data = [
            'name_ar' => $_POST['name_ar'],
            'name_en' => $_POST['name_en'],
            'name_he' => $_POST['name_he'],
            'slug' => $_POST['slug'],
            'is_active' => isset($_POST['is_active']) ? 1 : 0,
            'sort_order' => $_POST['sort_order'] ?? 0
        ];
        
        if ($id) {
            $db->update('regions', $data, 'id = ?', [$id]);
            $message = 'تم تحديث المنطقة';
        } else {
            $db->insert('regions', $data);
            $message = 'تم إضافة المنطقة';
        }
    } elseif ($action === 'save_city') {
        $id = (int)($_POST['id'] ?? 0);
        $data = [
            'region_id' => $_POST['region_id'],
            'name_ar' => $_POST['name_ar'],
            'name_en' => $_POST['name_en'],
            'name_he' => $_POST['name_he'],
            'slug' => $_POST['slug'],
            'is_active' => isset($_POST['is_active']) ? 1 : 0,
            'sort_order' => $_POST['sort_order'] ?? 0
        ];
        
        if ($id) {
            $db->update('cities', $data, 'id = ?', [$id]);
            $message = 'تم تحديث المدينة';
        } else {
            $db->insert('cities', $data);
            $message = 'تم إضافة المدينة';
        }
    } elseif ($action === 'delete_region') {
        $id = (int)($_POST['id'] ?? 0);
        // Delete all cities in this region first
        $db->delete('cities', 'region_id = ?', [$id]);
        // Then delete the region
        $db->delete('regions', 'id = ?', [$id]);
        $message = 'تم حذف المنطقة والمدن المرتبطة بها';
    } elseif ($action === 'delete_city') {
        $id = (int)($_POST['id'] ?? 0);
        $db->delete('cities', 'id = ?', [$id]);
        $message = 'تم حذف المدينة';
    }
}

$regions = $db->fetchAll("SELECT r.*, (SELECT COUNT(*) FROM cities WHERE region_id = r.id) as cities_count FROM regions r ORDER BY sort_order, name_ar");

$selectedRegion = $_GET['region'] ?? null;
$cities = [];
if ($selectedRegion) {
    $cities = $db->fetchAll("SELECT * FROM cities WHERE region_id = ? ORDER BY sort_order, name_ar", [$selectedRegion]);
}

include 'includes/header.php';
?>

<div class="container-fluid py-4">
    <div class="row mb-4">
        <div class="col-12">
            <h1 class="h3 mb-0">إدارة المناطق والمدن</h1>
        </div>
    </div>

    <?php if ($message): ?>
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <?= htmlspecialchars($message) ?>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <?php endif; ?>

    <div class="row g-4">
        <!-- Regions -->
        <div class="col-md-6">
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">المناطق</h5>
                    <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#regionModal">
                        <i class="bi bi-plus-lg"></i> إضافة
                    </button>
                </div>
                <div class="card-body p-0">
                    <div class="list-group list-group-flush">
                        <?php foreach ($regions as $region): ?>
                        <div class="list-group-item d-flex justify-content-between align-items-center <?= $selectedRegion == $region['id'] ? 'active' : '' ?>">
                            <a href="?region=<?= $region['id'] ?>" class="text-decoration-none <?= $selectedRegion == $region['id'] ? 'text-white' : '' ?>">
                                <?= htmlspecialchars($region['name_ar']) ?>
                                <span class="badge bg-secondary ms-2"><?= $region['cities_count'] ?> مدينة</span>
                                <?php if (!$region['is_active']): ?>
                                <span class="badge bg-warning">معطل</span>
                                <?php endif; ?>
                            </a>
                            <div>
                                <button class="btn btn-sm btn-outline-primary" onclick="editRegion(<?= htmlspecialchars(json_encode($region)) ?>)">
                                    <i class="bi bi-pencil"></i>
                                </button>
                                <form method="POST" class="d-inline" onsubmit="return confirmDeleteRegion(<?= $region['cities_count'] ?>)">
                                    <input type="hidden" name="action" value="delete_region">
                                    <input type="hidden" name="id" value="<?= $region['id'] ?>">
                                    <button type="submit" class="btn btn-sm btn-outline-danger">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </form>
                            </div>
                        </div>
                        <?php endforeach; ?>
                    </div>
                </div>
            </div>
        </div>

        <!-- Cities -->
        <div class="col-md-6">
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">
                        المدن
                        <?php if ($selectedRegion): ?>
                        <?php $regionName = $db->fetch("SELECT name_ar FROM regions WHERE id = ?", [$selectedRegion])['name_ar'] ?? ''; ?>
                        - <?= htmlspecialchars($regionName) ?>
                        <?php endif; ?>
                    </h5>
                    <?php if ($selectedRegion): ?>
                    <button class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#cityModal">
                        <i class="bi bi-plus-lg"></i> إضافة
                    </button>
                    <?php endif; ?>
                </div>
                <div class="card-body p-0">
                    <?php if ($selectedRegion): ?>
                    <div class="list-group list-group-flush">
                        <?php foreach ($cities as $city): ?>
                        <div class="list-group-item d-flex justify-content-between align-items-center">
                            <span>
                                <?= htmlspecialchars($city['name_ar']) ?>
                                <?php if (!$city['is_active']): ?>
                                <span class="badge bg-warning">معطل</span>
                                <?php endif; ?>
                            </span>
                            <div>
                                <button class="btn btn-sm btn-outline-primary" onclick="editCity(<?= htmlspecialchars(json_encode($city)) ?>)">
                                    <i class="bi bi-pencil"></i>
                                </button>
                                <form method="POST" class="d-inline" onsubmit="return confirm('حذف المدينة؟')">
                                    <input type="hidden" name="action" value="delete_city">
                                    <input type="hidden" name="id" value="<?= $city['id'] ?>">
                                    <button type="submit" class="btn btn-sm btn-outline-danger">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </form>
                            </div>
                        </div>
                        <?php endforeach; ?>
                        <?php if (empty($cities)): ?>
                        <div class="list-group-item text-center text-muted">لا توجد مدن</div>
                        <?php endif; ?>
                    </div>
                    <?php else: ?>
                    <div class="p-4 text-center text-muted">
                        اختر منطقة لعرض المدن
                    </div>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Region Modal -->
<div class="modal fade" id="regionModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="POST" id="regionForm">
                <input type="hidden" name="action" value="save_region">
                <input type="hidden" name="id" id="regionId">
                <div class="modal-header">
                    <h5 class="modal-title">إضافة/تعديل منطقة</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">الاسم (عربي)</label>
                        <input type="text" name="name_ar" id="regionNameAr" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">الاسم (إنجليزي)</label>
                        <input type="text" name="name_en" id="regionNameEn" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">الاسم (عبري)</label>
                        <input type="text" name="name_he" id="regionNameHe" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Slug</label>
                        <input type="text" name="slug" id="regionSlug" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">الترتيب</label>
                        <input type="number" name="sort_order" id="regionSortOrder" class="form-control" value="0">
                    </div>
                    <div class="form-check">
                        <input type="checkbox" name="is_active" id="regionIsActive" class="form-check-input" checked>
                        <label class="form-check-label" for="regionIsActive">نشط</label>
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

<!-- City Modal -->
<div class="modal fade" id="cityModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="POST" id="cityForm">
                <input type="hidden" name="action" value="save_city">
                <input type="hidden" name="id" id="cityId">
                <input type="hidden" name="region_id" value="<?= $selectedRegion ?>">
                <div class="modal-header">
                    <h5 class="modal-title">إضافة/تعديل مدينة</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">الاسم (عربي)</label>
                        <input type="text" name="name_ar" id="cityNameAr" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">الاسم (إنجليزي)</label>
                        <input type="text" name="name_en" id="cityNameEn" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">الاسم (عبري)</label>
                        <input type="text" name="name_he" id="cityNameHe" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Slug</label>
                        <input type="text" name="slug" id="citySlug" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">الترتيب</label>
                        <input type="number" name="sort_order" id="citySortOrder" class="form-control" value="0">
                    </div>
                    <div class="form-check">
                        <input type="checkbox" name="is_active" id="cityIsActive" class="form-check-input" checked>
                        <label class="form-check-label" for="cityIsActive">نشط</label>
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
function confirmDeleteRegion(citiesCount) {
    if (citiesCount > 0) {
        return confirm('⚠️ تحذير!\n\nهذه المنطقة تحتوي على ' + citiesCount + ' مدينة.\nسيتم حذف جميع المدن المرتبطة بها أيضاً.\n\nهل أنت متأكد من الحذف؟');
    } else {
        return confirm('هل أنت متأكد من حذف هذه المنطقة؟');
    }
}

function editRegion(region) {
    document.getElementById('regionId').value = region.id;
    document.getElementById('regionNameAr').value = region.name_ar;
    document.getElementById('regionNameEn').value = region.name_en;
    document.getElementById('regionNameHe').value = region.name_he;
    document.getElementById('regionSlug').value = region.slug;
    document.getElementById('regionSortOrder').value = region.sort_order;
    document.getElementById('regionIsActive').checked = region.is_active == 1;
    new bootstrap.Modal(document.getElementById('regionModal')).show();
}

function editCity(city) {
    document.getElementById('cityId').value = city.id;
    document.getElementById('cityNameAr').value = city.name_ar;
    document.getElementById('cityNameEn').value = city.name_en;
    document.getElementById('cityNameHe').value = city.name_he;
    document.getElementById('citySlug').value = city.slug;
    document.getElementById('citySortOrder').value = city.sort_order;
    document.getElementById('cityIsActive').checked = city.is_active == 1;
    new bootstrap.Modal(document.getElementById('cityModal')).show();
}
</script>

<?php include 'includes/footer.php'; ?>
