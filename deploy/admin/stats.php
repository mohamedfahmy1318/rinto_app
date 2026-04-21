<?php
session_start();
require_once __DIR__ . '/../backend/config/database.php';

if (!isset($_SESSION['admin_id'])) {
    header('Location: login.php');
    exit;
}

$db = Database::getInstance();

// Monthly revenue for last 6 months
$monthlyRevenue = $db->fetchAll("
    SELECT DATE_FORMAT(created_at, '%Y-%m') as month, SUM(amount) as total
    FROM payments WHERE status = 'completed'
    GROUP BY month ORDER BY month DESC LIMIT 6
");

// Top regions
$topRegions = $db->fetchAll("
    SELECT r.name_ar, COUNT(p.id) as count
    FROM properties p
    JOIN regions r ON p.region_id = r.id
    WHERE p.status = 'active'
    GROUP BY r.id ORDER BY count DESC LIMIT 5
");

// Stats
$stats = [
    'total_users' => $db->fetch("SELECT COUNT(*) as c FROM users")['c'],
    'total_properties' => $db->fetch("SELECT COUNT(*) as c FROM properties")['c'],
    'total_cars' => $db->fetch("SELECT COUNT(*) as c FROM cars")['c'],
    'active_properties' => $db->fetch("SELECT COUNT(*) as c FROM properties WHERE status = 'active'")['c'],
    'active_cars' => $db->fetch("SELECT COUNT(*) as c FROM cars WHERE status = 'active'")['c'],
    'total_revenue' => $db->fetch("SELECT COALESCE(SUM(amount), 0) as c FROM payments WHERE status = 'completed'")['c'],
];

include 'includes/header.php';
?>

<div class="container-fluid py-4">
    <h1 class="h3 mb-4">التقارير والإحصائيات</h1>

    <div class="row g-4 mb-4">
        <div class="col-md-2">
            <div class="card text-center">
                <div class="card-body">
                    <h3 class="text-primary"><?= number_format($stats['total_users']) ?></h3>
                    <small>المستخدمين</small>
                </div>
            </div>
        </div>
        <div class="col-md-2">
            <div class="card text-center">
                <div class="card-body">
                    <h3 class="text-success"><?= number_format($stats['active_properties']) ?></h3>
                    <small>عقارات نشطة</small>
                </div>
            </div>
        </div>
        <div class="col-md-2">
            <div class="card text-center">
                <div class="card-body">
                    <h3 class="text-info"><?= number_format($stats['active_cars']) ?></h3>
                    <small>سيارات نشطة</small>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card text-center bg-success text-white">
                <div class="card-body">
                    <h3><?= number_format($stats['total_revenue'], 2) ?> ₪</h3>
                    <small>إجمالي الإيرادات</small>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-md-6">
            <div class="card">
                <div class="card-header"><h5 class="mb-0">الإيرادات الشهرية</h5></div>
                <div class="card-body">
                    <table class="table">
                        <thead><tr><th>الشهر</th><th>الإيرادات</th></tr></thead>
                        <tbody>
                            <?php foreach ($monthlyRevenue as $m): ?>
                            <tr><td><?= $m['month'] ?></td><td><?= number_format($m['total'], 2) ?> ₪</td></tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="card">
                <div class="card-header"><h5 class="mb-0">أكثر المناطق نشاطاً</h5></div>
                <div class="card-body">
                    <table class="table">
                        <thead><tr><th>المنطقة</th><th>الإعلانات</th></tr></thead>
                        <tbody>
                            <?php foreach ($topRegions as $r): ?>
                            <tr><td><?= htmlspecialchars($r['name_ar']) ?></td><td><?= $r['count'] ?></td></tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<?php include 'includes/footer.php'; ?>
