<?php
session_start();
require_once __DIR__ . '/../backend/config/database.php';
require_once __DIR__ . '/../backend/config/constants.php';

if (!isset($_SESSION['admin_id'])) {
    header('Location: login.php');
    exit;
}

$db = Database::getInstance();

$type = $_GET['type'] ?? 'all';
$status = $_GET['status'] ?? '';
$search = $_GET['search'] ?? '';
$page = max(1, (int)($_GET['page'] ?? 1));
$perPage = 20;
$offset = ($page - 1) * $perPage;

// Build queries
$properties = [];
$cars = [];
$totalProperties = 0;
$totalCars = 0;

if ($type === 'all' || $type === 'properties') {
    $where = "1=1";
    $params = [];
    
    if ($status) {
        $where .= " AND p.status = ?";
        $params[] = $status;
    }
    if ($search) {
        $where .= " AND (p.title LIKE ? OR p.bio LIKE ?)";
        $params[] = "%$search%";
        $params[] = "%$search%";
    }
    
    $totalProperties = $db->fetch("SELECT COUNT(*) as total FROM properties p WHERE $where", $params)['total'];
    
    if ($type === 'properties' || $type === 'all') {
        $sql = "SELECT p.*, u.name as user_name, u.phone as user_phone, 
                       r.name_ar as region_name, c.name_ar as city_name
                FROM properties p
                LEFT JOIN users u ON p.user_id = u.id
                LEFT JOIN regions r ON p.region_id = r.id
                LEFT JOIN cities c ON p.city_id = c.id
                WHERE $where
                ORDER BY p.created_at DESC
                LIMIT $perPage OFFSET $offset";
        $properties = $db->fetchAll($sql, $params);
    }
}

if ($type === 'all' || $type === 'cars') {
    $where = "1=1";
    $params = [];
    
    if ($status) {
        $where .= " AND c.status = ?";
        $params[] = $status;
    }
    if ($search) {
        $where .= " AND (c.title LIKE ? OR c.model LIKE ? OR c.bio LIKE ?)";
        $params[] = "%$search%";
        $params[] = "%$search%";
        $params[] = "%$search%";
    }
    
    $totalCars = $db->fetch("SELECT COUNT(*) as total FROM cars c WHERE $where", $params)['total'];
    
    if ($type === 'cars' || $type === 'all') {
        $sql = "SELECT c.*, u.name as user_name, u.phone as user_phone,
                       r.name_ar as region_name, ci.name_ar as city_name
                FROM cars c
                LEFT JOIN users u ON c.user_id = u.id
                LEFT JOIN regions r ON c.region_id = r.id
                LEFT JOIN cities ci ON c.city_id = ci.id
                WHERE $where
                ORDER BY c.created_at DESC
                LIMIT $perPage OFFSET $offset";
        $cars = $db->fetchAll($sql, $params);
    }
}

$statusLabels = [
    'draft' => 'مسودة',
    'pending_payment' => 'بانتظار الدفع',
    'pending_admin_review' => 'بانتظار المراجعة',
    'active' => 'نشط',
    'expired' => 'منتهي',
    'paused' => 'متوقف',
    'rejected' => 'مرفوض'
];

include 'includes/header.php';
?>

<div class="container-fluid py-4">
    <div class="row mb-4">
        <div class="col-12">
            <h1 class="h3 mb-0">إدارة الإعلانات</h1>
        </div>
    </div>

    <!-- Filters -->
    <div class="card mb-4">
        <div class="card-body">
            <form method="GET" class="row g-3">
                <div class="col-md-3">
                    <label class="form-label">النوع</label>
                    <select name="type" class="form-select">
                        <option value="all" <?= $type === 'all' ? 'selected' : '' ?>>الكل</option>
                        <option value="properties" <?= $type === 'properties' ? 'selected' : '' ?>>العقارات</option>
                        <option value="cars" <?= $type === 'cars' ? 'selected' : '' ?>>السيارات</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label">الحالة</label>
                    <select name="status" class="form-select">
                        <option value="">الكل</option>
                        <?php foreach ($statusLabels as $key => $label): ?>
                        <option value="<?= $key ?>" <?= $status === $key ? 'selected' : '' ?>><?= $label ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">بحث</label>
                    <input type="text" name="search" class="form-control" placeholder="بحث..." value="<?= htmlspecialchars($search) ?>">
                </div>
                <div class="col-md-2 d-flex align-items-end">
                    <button type="submit" class="btn btn-primary w-100">
                        <i class="bi bi-search me-1"></i> بحث
                    </button>
                </div>
            </form>
        </div>
    </div>

    <!-- Results -->
    <?php if ($type === 'all' || $type === 'properties'): ?>
    <div class="card mb-4">
        <div class="card-header">
            <h5 class="mb-0"><i class="bi bi-building me-2"></i>العقارات (<?= $totalProperties ?>)</h5>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>العنوان</th>
                            <th>النوع</th>
                            <th>المنطقة</th>
                            <th>السعر</th>
                            <th>المعلن</th>
                            <th>الحالة</th>
                            <th>التاريخ</th>
                            <th>إجراءات</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($properties as $p): ?>
                        <tr>
                            <td><?= $p['id'] ?></td>
                            <td><?= htmlspecialchars($p['title'] ?: 'بدون عنوان') ?></td>
                            <td><?= PROPERTY_TYPES[$p['property_type']]['ar'] ?? $p['property_type'] ?></td>
                            <td><?= htmlspecialchars($p['city_name'] ?? '') ?></td>
                            <td>
                                <?php if (!empty($p['price_daily']) || !empty($p['price_weekly']) || !empty($p['price_monthly'])): ?>
                                    <?php 
                                    $prices = [];
                                    if (!empty($p['price_daily'])) $prices[] = number_format($p['price_daily']) . '/يوم';
                                    if (!empty($p['price_weekly'])) $prices[] = number_format($p['price_weekly']) . '/أسبوع';
                                    if (!empty($p['price_monthly'])) $prices[] = number_format($p['price_monthly']) . '/شهر';
                                    echo implode('<br><small>', $prices) . ' ₪';
                                    ?>
                                <?php elseif ($p['price_type'] === 'negotiable'): ?>
                                    قابل للتفاوض
                                <?php elseif ($p['price_type'] === 'range'): ?>
                                    <?= number_format($p['price_from']) ?> - <?= number_format($p['price_to']) ?> ₪
                                <?php else: ?>
                                    <?= number_format($p['price']) ?> ₪
                                <?php endif; ?>
                            </td>
                            <td><?= htmlspecialchars($p['user_name']) ?></td>
                            <td><span class="badge badge-status-<?= $p['status'] ?>"><?= $statusLabels[$p['status']] ?? $p['status'] ?></span></td>
                            <td><?= date('Y/m/d', strtotime($p['created_at'])) ?></td>
                            <td>
                                <a href="listing-review.php?type=property&id=<?= $p['id'] ?>" class="btn btn-sm btn-outline-primary">
                                    <i class="bi bi-eye"></i>
                                </a>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                        <?php if (empty($properties)): ?>
                        <tr><td colspan="9" class="text-center text-muted py-4">لا توجد عقارات</td></tr>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <?php endif; ?>

    <?php if ($type === 'all' || $type === 'cars'): ?>
    <div class="card">
        <div class="card-header">
            <h5 class="mb-0"><i class="bi bi-car-front me-2"></i>السيارات (<?= $totalCars ?>)</h5>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>الموديل</th>
                            <th>الاستخدام</th>
                            <th>المنطقة</th>
                            <th>السعر</th>
                            <th>المعلن</th>
                            <th>الحالة</th>
                            <th>التاريخ</th>
                            <th>إجراءات</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($cars as $c): ?>
                        <tr>
                            <td><?= $c['id'] ?></td>
                            <td><?= htmlspecialchars($c['model']) ?></td>
                            <td><?= CAR_USAGE_TYPES[$c['usage_type']]['ar'] ?? $c['usage_type'] ?></td>
                            <td><?= htmlspecialchars($c['city_name'] ?? '') ?></td>
                            <td>
                                <?php if (!empty($c['price_daily']) || !empty($c['price_weekly']) || !empty($c['price_monthly'])): ?>
                                    <?php 
                                    $prices = [];
                                    if (!empty($c['price_daily'])) $prices[] = number_format($c['price_daily']) . '/يوم';
                                    if (!empty($c['price_weekly'])) $prices[] = number_format($c['price_weekly']) . '/أسبوع';
                                    if (!empty($c['price_monthly'])) $prices[] = number_format($c['price_monthly']) . '/شهر';
                                    echo implode('<br><small>', $prices) . ' ₪';
                                    ?>
                                <?php elseif ($c['price_type'] === 'negotiable'): ?>
                                    قابل للتفاوض
                                <?php elseif ($c['price_type'] === 'range'): ?>
                                    <?= number_format($c['price_from']) ?> - <?= number_format($c['price_to']) ?> ₪
                                <?php else: ?>
                                    <?= number_format($c['price']) ?> ₪
                                <?php endif; ?>
                            </td>
                            <td><?= htmlspecialchars($c['user_name']) ?></td>
                            <td><span class="badge badge-status-<?= $c['status'] ?>"><?= $statusLabels[$c['status']] ?? $c['status'] ?></span></td>
                            <td><?= date('Y/m/d', strtotime($c['created_at'])) ?></td>
                            <td>
                                <a href="listing-review.php?type=car&id=<?= $c['id'] ?>" class="btn btn-sm btn-outline-primary">
                                    <i class="bi bi-eye"></i>
                                </a>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                        <?php if (empty($cars)): ?>
                        <tr><td colspan="9" class="text-center text-muted py-4">لا توجد سيارات</td></tr>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <?php endif; ?>
</div>

<?php include 'includes/footer.php'; ?>
