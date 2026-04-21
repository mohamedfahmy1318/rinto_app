<?php
// Temporary error display - remove after debugging
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

session_start();

require_once __DIR__ . '/../backend/config/database.php';
require_once __DIR__ . '/../backend/config/constants.php';

// Check if logged in
if (!isset($_SESSION['admin_id'])) {
    header('Location: login.php');
    exit;
}

$db = Database::getInstance();

// Get stats
$stats = [
    'users' => $db->fetch("SELECT COUNT(*) as count FROM users")['count'],
    'properties' => $db->fetch("SELECT COUNT(*) as count FROM properties")['count'],
    'cars' => $db->fetch("SELECT COUNT(*) as count FROM cars")['count'],
    'pending_properties' => $db->fetch("SELECT COUNT(*) as count FROM properties WHERE status = 'pending_admin_review'")['count'],
    'pending_cars' => $db->fetch("SELECT COUNT(*) as count FROM cars WHERE status = 'pending_admin_review'")['count'],
    'active_subscriptions' => $db->fetch("SELECT COUNT(*) as count FROM subscriptions WHERE status = 'active' AND expires_at > NOW()")['count'],
    'monthly_revenue' => $db->fetch("SELECT COALESCE(SUM(amount), 0) as total FROM payments WHERE status = 'completed' AND MONTH(created_at) = MONTH(NOW()) AND YEAR(created_at) = YEAR(NOW())")['total'],
    'pending_reports' => $db->fetch("SELECT COUNT(*) as count FROM reports WHERE status = 'pending'")['count']
];

// Recent listings pending review
$pendingListings = $db->fetchAll("
    (SELECT 'property' as type, id, title, created_at, user_id FROM properties WHERE status = 'pending_admin_review' ORDER BY created_at DESC LIMIT 5)
    UNION ALL
    (SELECT 'car' as type, id, title, created_at, user_id FROM cars WHERE status = 'pending_admin_review' ORDER BY created_at DESC LIMIT 5)
    ORDER BY created_at DESC LIMIT 10
");

include 'includes/header.php';
?>

<div class="container-fluid py-4">
    <div class="row mb-4">
        <div class="col-12">
            <h1 class="h3 mb-0">لوحة التحكم - Rento Go</h1>
        </div>
    </div>

    <!-- Stats Cards -->
    <div class="row g-3 mb-4">
        <div class="col-md-3">
            <div class="card bg-primary text-white h-100">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="card-subtitle mb-2">المستخدمين</h6>
                            <h2 class="card-title mb-0"><?= number_format($stats['users']) ?></h2>
                        </div>
                        <i class="bi bi-people fs-1 opacity-50"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card bg-success text-white h-100">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="card-subtitle mb-2">العقارات</h6>
                            <h2 class="card-title mb-0"><?= number_format($stats['properties']) ?></h2>
                        </div>
                        <i class="bi bi-building fs-1 opacity-50"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card bg-info text-white h-100">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="card-subtitle mb-2">السيارات</h6>
                            <h2 class="card-title mb-0"><?= number_format($stats['cars']) ?></h2>
                        </div>
                        <i class="bi bi-car-front fs-1 opacity-50"></i>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-3">
            <div class="card bg-warning text-dark h-100">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center">
                        <div>
                            <h6 class="card-subtitle mb-2">الإيرادات الشهرية</h6>
                            <h2 class="card-title mb-0"><?= number_format($stats['monthly_revenue'], 2) ?> ₪</h2>
                        </div>
                        <i class="bi bi-currency-dollar fs-1 opacity-50"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Pending Items Alert -->
    <?php if ($stats['pending_properties'] + $stats['pending_cars'] > 0): ?>
    <div class="alert alert-warning d-flex align-items-center mb-4" role="alert">
        <i class="bi bi-exclamation-triangle-fill me-2 fs-4"></i>
        <div>
            <strong>يوجد إعلانات بانتظار المراجعة:</strong>
            <?= $stats['pending_properties'] ?> عقار و <?= $stats['pending_cars'] ?> سيارة
            <a href="listings.php?status=pending_admin_review" class="alert-link ms-2">عرض الكل</a>
        </div>
    </div>
    <?php endif; ?>

    <div class="row g-4">
        <!-- Recent Pending Listings -->
        <div class="col-md-8">
            <div class="card h-100">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">إعلانات بانتظار المراجعة</h5>
                    <a href="listings.php?status=pending_admin_review" class="btn btn-sm btn-outline-primary">عرض الكل</a>
                </div>
                <div class="card-body p-0">
                    <div class="table-responsive">
                        <table class="table table-hover mb-0">
                            <thead>
                                <tr>
                                    <th>النوع</th>
                                    <th>العنوان</th>
                                    <th>التاريخ</th>
                                    <th>إجراءات</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($pendingListings as $listing): ?>
                                <tr>
                                    <td>
                                        <span class="badge bg-<?= $listing['type'] === 'property' ? 'success' : 'info' ?>">
                                            <?= $listing['type'] === 'property' ? 'عقار' : 'سيارة' ?>
                                        </span>
                                    </td>
                                    <td><?= htmlspecialchars($listing['title'] ?: 'بدون عنوان') ?></td>
                                    <td><?= date('Y/m/d H:i', strtotime($listing['created_at'])) ?></td>
                                    <td>
                                        <a href="listing-review.php?type=<?= $listing['type'] ?>&id=<?= $listing['id'] ?>" class="btn btn-sm btn-primary">
                                            مراجعة
                                        </a>
                                    </td>
                                </tr>
                                <?php endforeach; ?>
                                <?php if (empty($pendingListings)): ?>
                                <tr>
                                    <td colspan="4" class="text-center text-muted py-4">لا توجد إعلانات بانتظار المراجعة</td>
                                </tr>
                                <?php endif; ?>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- Quick Stats -->
        <div class="col-md-4">
            <div class="card h-100">
                <div class="card-header">
                    <h5 class="mb-0">إحصائيات سريعة</h5>
                </div>
                <div class="card-body">
                    <ul class="list-group list-group-flush">
                        <li class="list-group-item d-flex justify-content-between align-items-center">
                            الاشتراكات النشطة
                            <span class="badge bg-success rounded-pill"><?= $stats['active_subscriptions'] ?></span>
                        </li>
                        <li class="list-group-item d-flex justify-content-between align-items-center">
                            عقارات بانتظار المراجعة
                            <span class="badge bg-warning rounded-pill"><?= $stats['pending_properties'] ?></span>
                        </li>
                        <li class="list-group-item d-flex justify-content-between align-items-center">
                            سيارات بانتظار المراجعة
                            <span class="badge bg-warning rounded-pill"><?= $stats['pending_cars'] ?></span>
                        </li>
                        <li class="list-group-item d-flex justify-content-between align-items-center">
                            بلاغات معلقة
                            <span class="badge bg-danger rounded-pill"><?= $stats['pending_reports'] ?></span>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>

<?php include 'includes/footer.php'; ?>
