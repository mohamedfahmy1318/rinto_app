<?php
session_start();
require_once __DIR__ . '/../backend/config/database.php';

if (!isset($_SESSION['admin_id'])) {
    header('Location: login.php');
    exit;
}

$db = Database::getInstance();
$message = '';

// Handle verification action
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['action'])) {
    $paymentId = (int)$_POST['payment_id'];
    $action = $_POST['action'];
    
    if ($action === 'verify') {
        // Verify the payment
        $db->update('payments', [
            'status' => 'completed',
            'verified_by' => $_SESSION['admin_id'],
            'verified_at' => date('Y-m-d H:i:s')
        ], 'id = ?', [$paymentId]);
        
        // Activate the subscription
        $payment = $db->fetch("SELECT subscription_id FROM payments WHERE id = ?", [$paymentId]);
        if ($payment && $payment['subscription_id']) {
            $db->update('subscriptions', ['status' => 'active'], 'id = ?', [$payment['subscription_id']]);
        }
        
        $message = 'تم التحقق من الدفع وتفعيل الاشتراك بنجاح';
    } elseif ($action === 'reject') {
        $db->update('payments', [
            'status' => 'rejected',
            'verified_by' => $_SESSION['admin_id'],
            'verified_at' => date('Y-m-d H:i:s'),
            'notes' => $_POST['reject_reason'] ?? 'Payment rejected'
        ], 'id = ?', [$paymentId]);
        
        // Cancel the subscription
        $payment = $db->fetch("SELECT subscription_id FROM payments WHERE id = ?", [$paymentId]);
        if ($payment && $payment['subscription_id']) {
            $db->update('subscriptions', ['status' => 'cancelled'], 'id = ?', [$payment['subscription_id']]);
        }
        
        $message = 'تم رفض الدفع';
    }
}

// Filter by status
$statusFilter = $_GET['status'] ?? '';
$whereClause = $statusFilter ? "WHERE p.status = '$statusFilter'" : "";

$page = max(1, (int)($_GET['page'] ?? 1));
$perPage = 20;
$offset = ($page - 1) * $perPage;

$total = $db->fetch("SELECT COUNT(*) as total FROM payments p $whereClause")['total'];
$payments = $db->fetchAll("
    SELECT p.*, u.name as user_name, u.email as user_email, u.phone as user_phone, pl.name_ar as plan_name
    FROM payments p
    LEFT JOIN users u ON p.user_id = u.id
    LEFT JOIN plans pl ON p.plan_id = pl.id
    $whereClause
    ORDER BY CASE WHEN p.status = 'pending' THEN 0 ELSE 1 END, p.created_at DESC
    LIMIT $perPage OFFSET $offset
");

// Count pending payments
$pendingCount = $db->fetch("SELECT COUNT(*) as cnt FROM payments WHERE status = 'pending'")['cnt'];

include 'includes/header.php';
?>

<div class="container-fluid py-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0">سجل المدفوعات</h1>
        <?php if ($pendingCount > 0): ?>
        <a href="?status=pending" class="btn btn-warning">
            <i class="bi bi-hourglass-split me-1"></i>
            بانتظار التحقق <span class="badge bg-light text-dark"><?= $pendingCount ?></span>
        </a>
        <?php endif; ?>
    </div>
    
    <?php if ($message): ?>
    <div class="alert alert-success alert-dismissible fade show">
        <?= $message ?>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <?php endif; ?>
    
    <!-- Filters -->
    <div class="card mb-3">
        <div class="card-body py-2">
            <div class="d-flex gap-2">
                <a href="?" class="btn btn-sm <?= !$statusFilter ? 'btn-primary' : 'btn-outline-primary' ?>">الكل</a>
                <a href="?status=pending" class="btn btn-sm <?= $statusFilter === 'pending' ? 'btn-warning' : 'btn-outline-warning' ?>">بانتظار التحقق</a>
                <a href="?status=completed" class="btn btn-sm <?= $statusFilter === 'completed' ? 'btn-success' : 'btn-outline-success' ?>">مكتمل</a>
                <a href="?status=rejected" class="btn btn-sm <?= $statusFilter === 'rejected' ? 'btn-danger' : 'btn-outline-danger' ?>">مرفوض</a>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>المستخدم</th>
                            <th>الباقة</th>
                            <th>المبلغ</th>
                            <th>طريقة الدفع</th>
                            <th>تفاصيل الحوالة</th>
                            <th>الحالة</th>
                            <th>التاريخ</th>
                            <th>إجراء</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($payments as $pay): ?>
                        <tr class="<?= $pay['status'] === 'pending' ? 'table-warning' : '' ?>">
                            <td><?= $pay['id'] ?></td>
                            <td>
                                <?= htmlspecialchars($pay['user_name']) ?><br>
                                <small class="text-muted"><?= $pay['user_email'] ?></small><br>
                                <small class="text-muted"><?= $pay['user_phone'] ?></small>
                            </td>
                            <td><?= htmlspecialchars($pay['plan_name']) ?></td>
                            <td><strong><?= number_format($pay['amount'], 2) ?> <?= $pay['currency'] ?></strong></td>
                            <td>
                                <?php 
                                $methodLabels = [
                                    'bank_transfer' => '<span class="badge bg-info"><i class="bi bi-bank me-1"></i>حوالة بنكية</span>',
                                    'apple_pay' => '<span class="badge bg-dark"><i class="bi bi-apple me-1"></i>Apple Pay</span>',
                                    'google_pay' => '<span class="badge bg-primary"><i class="bi bi-google me-1"></i>Google Pay</span>',
                                    'test' => '<span class="badge bg-secondary">تجريبي</span>',
                                ];
                                echo $methodLabels[$pay['payment_method'] ?? 'test'] ?? '<span class="badge bg-secondary">' . ($pay['payment_method'] ?? 'غير محدد') . '</span>';
                                ?>
                            </td>
                            <td>
                                <?php if (($pay['payment_method'] ?? '') === 'bank_transfer'): ?>
                                <small>
                                    <?php if (!empty($pay['sender_name'])): ?>
                                    <strong>المُحوِّل:</strong> <?= htmlspecialchars($pay['sender_name']) ?><br>
                                    <?php endif; ?>
                                    <?php if (!empty($pay['transfer_date'])): ?>
                                    <strong>تاريخ:</strong> <?= $pay['transfer_date'] ?><br>
                                    <?php endif; ?>
                                    <?php if (!empty($pay['notes'])): ?>
                                    <strong>ملاحظات:</strong> <?= htmlspecialchars($pay['notes']) ?>
                                    <?php endif; ?>
                                </small>
                                <?php else: ?>
                                <span class="text-muted">-</span>
                                <?php endif; ?>
                            </td>
                            <td>
                                <?php 
                                $statusLabels = [
                                    'pending' => '<span class="badge bg-warning text-dark"><i class="bi bi-hourglass-split me-1"></i>بانتظار التحقق</span>',
                                    'completed' => '<span class="badge bg-success"><i class="bi bi-check-circle me-1"></i>مكتمل</span>',
                                    'rejected' => '<span class="badge bg-danger"><i class="bi bi-x-circle me-1"></i>مرفوض</span>',
                                ];
                                echo $statusLabels[$pay['status']] ?? '<span class="badge bg-secondary">' . $pay['status'] . '</span>';
                                ?>
                            </td>
                            <td><?= date('Y/m/d H:i', strtotime($pay['created_at'])) ?></td>
                            <td>
                                <?php if ($pay['status'] === 'pending'): ?>
                                <form method="POST" class="d-inline">
                                    <input type="hidden" name="payment_id" value="<?= $pay['id'] ?>">
                                    <input type="hidden" name="action" value="verify">
                                    <button type="submit" class="btn btn-sm btn-success" onclick="return confirm('هل أنت متأكد من التحقق من هذا الدفع؟')">
                                        <i class="bi bi-check-lg"></i> تحقق
                                    </button>
                                </form>
                                <button type="button" class="btn btn-sm btn-danger" data-bs-toggle="modal" data-bs-target="#rejectModal<?= $pay['id'] ?>">
                                    <i class="bi bi-x-lg"></i> رفض
                                </button>
                                
                                <!-- Reject Modal -->
                                <div class="modal fade" id="rejectModal<?= $pay['id'] ?>" tabindex="-1">
                                    <div class="modal-dialog">
                                        <div class="modal-content">
                                            <form method="POST">
                                                <div class="modal-header">
                                                    <h5 class="modal-title">رفض الدفع #<?= $pay['id'] ?></h5>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                </div>
                                                <div class="modal-body">
                                                    <input type="hidden" name="payment_id" value="<?= $pay['id'] ?>">
                                                    <input type="hidden" name="action" value="reject">
                                                    <div class="mb-3">
                                                        <label class="form-label">سبب الرفض</label>
                                                        <textarea name="reject_reason" class="form-control" rows="3" required></textarea>
                                                    </div>
                                                </div>
                                                <div class="modal-footer">
                                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">إلغاء</button>
                                                    <button type="submit" class="btn btn-danger">رفض</button>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                                <?php elseif ($pay['status'] === 'completed'): ?>
                                <span class="text-success"><i class="bi bi-check-circle"></i></span>
                                <?php elseif ($pay['status'] === 'rejected'): ?>
                                <span class="text-danger"><i class="bi bi-x-circle"></i></span>
                                <?php endif; ?>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    
    <?php if ($total > $perPage): ?>
    <!-- Pagination -->
    <nav class="mt-4">
        <ul class="pagination justify-content-center">
            <?php for ($i = 1; $i <= ceil($total / $perPage); $i++): ?>
            <li class="page-item <?= $i === $page ? 'active' : '' ?>">
                <a class="page-link" href="?page=<?= $i ?><?= $statusFilter ? "&status=$statusFilter" : '' ?>"><?= $i ?></a>
            </li>
            <?php endfor; ?>
        </ul>
    </nav>
    <?php endif; ?>
</div>

<?php include 'includes/footer.php'; ?>
