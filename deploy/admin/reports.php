<?php
session_start();
require_once __DIR__ . '/../backend/config/database.php';

if (!isset($_SESSION['admin_id'])) {
    header('Location: login.php');
    exit;
}

$db = Database::getInstance();
$message = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id = (int)$_POST['id'];
    $action = $_POST['action'];
    $notes = $_POST['admin_notes'] ?? '';
    
    $db->update('reports', [
        'status' => $action === 'resolve' ? 'resolved' : 'dismissed',
        'admin_notes' => $notes,
        'reviewed_by' => $_SESSION['admin_id'],
        'reviewed_at' => date('Y-m-d H:i:s')
    ], 'id = ?', [$id]);
    
    $message = 'تم معالجة البلاغ';
}

$status = $_GET['status'] ?? 'pending';
$reports = $db->fetchAll("
    SELECT r.*, 
           reporter.name as reporter_name,
           reported.name as reported_name
    FROM reports r
    LEFT JOIN users reporter ON r.reporter_id = reporter.id
    LEFT JOIN users reported ON r.reported_user_id = reported.id
    WHERE r.status = ?
    ORDER BY r.created_at DESC
", [$status]);

include 'includes/header.php';
?>

<div class="container-fluid py-4">
    <h1 class="h3 mb-4">إدارة البلاغات</h1>

    <?php if ($message): ?>
    <div class="alert alert-success"><?= $message ?></div>
    <?php endif; ?>

    <ul class="nav nav-tabs mb-4">
        <li class="nav-item"><a class="nav-link <?= $status === 'pending' ? 'active' : '' ?>" href="?status=pending">معلقة</a></li>
        <li class="nav-item"><a class="nav-link <?= $status === 'resolved' ? 'active' : '' ?>" href="?status=resolved">تم حلها</a></li>
        <li class="nav-item"><a class="nav-link <?= $status === 'dismissed' ? 'active' : '' ?>" href="?status=dismissed">مرفوضة</a></li>
    </ul>

    <div class="card">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>المبلغ</th>
                            <th>ضد</th>
                            <th>النوع</th>
                            <th>السبب</th>
                            <th>التاريخ</th>
                            <th>إجراءات</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($reports as $r): ?>
                        <tr>
                            <td><?= $r['id'] ?></td>
                            <td><?= htmlspecialchars($r['reporter_name']) ?></td>
                            <td><?= htmlspecialchars($r['reported_name']) ?></td>
                            <td>
                                <a href="listing-review.php?type=<?= $r['listing_type'] ?>&id=<?= $r['listing_id'] ?>" 
                                   class="badge bg-info text-decoration-none" target="_blank">
                                    <?= $r['listing_type'] === 'car' ? 'سيارة' : 'عقار' ?> #<?= $r['listing_id'] ?>
                                    <i class="bi bi-box-arrow-up-left ms-1"></i>
                                </a>
                            </td>
                            <td><?= mb_substr(htmlspecialchars($r['reason']), 0, 50) ?>...</td>
                            <td><?= date('Y/m/d', strtotime($r['created_at'])) ?></td>
                            <td>
                                <?php if ($status === 'pending'): ?>
                                <button class="btn btn-sm btn-success" data-bs-toggle="modal" data-bs-target="#modal<?= $r['id'] ?>">معالجة</button>
                                <?php else: ?>
                                <small class="text-muted"><?= $status === 'resolved' ? 'تم الحل' : 'مرفوض' ?></small>
                                <?php endif; ?>
                            </td>
                        </tr>
                        <!-- Modal -->
                        <div class="modal fade" id="modal<?= $r['id'] ?>">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <form method="POST">
                                        <input type="hidden" name="id" value="<?= $r['id'] ?>">
                                        <div class="modal-header"><h5>معالجة البلاغ</h5></div>
                                        <div class="modal-body">
                                            <p><strong>السبب:</strong> <?= htmlspecialchars($r['reason']) ?></p>
                                            <div class="mb-3">
                                                <label class="form-label">ملاحظات الإدارة</label>
                                                <textarea name="admin_notes" class="form-control" rows="3"></textarea>
                                            </div>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="submit" name="action" value="dismiss" class="btn btn-secondary">رفض</button>
                                            <button type="submit" name="action" value="resolve" class="btn btn-success">تم الحل</button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<?php include 'includes/footer.php'; ?>
