<?php
session_start();
require_once __DIR__ . '/../backend/config/database.php';
require_once __DIR__ . '/../backend/config/constants.php';
require_once __DIR__ . '/../backend/helpers/FCM.php';
require_once __DIR__ . '/../backend/api/controllers/NotificationController.php';

if (!isset($_SESSION['admin_id'])) {
    header('Location: login.php');
    exit;
}

$db = Database::getInstance();
$message = '';
$messageType = 'success';

// Handle actions
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    $requestId = (int)($_POST['request_id'] ?? 0);
    $subscriptionId = (int)($_POST['subscription_id'] ?? 0);
    
    // Handle direct subscription approval (Apple Pay, Google Pay, etc.)
    if ($subscriptionId && ($action === 'approve_subscription' || $action === 'reject_subscription')) {
        $subscription = $db->fetch(
            "SELECT s.*, p.name_ar as plan_name, u.name as user_name 
             FROM subscriptions s 
             JOIN plans p ON s.plan_id = p.id 
             JOIN users u ON s.user_id = u.id 
             WHERE s.id = ?",
            [$subscriptionId]
        );
        
        if ($subscription) {
            if ($action === 'approve_subscription') {
                $db->update('subscriptions', [
                    'status' => 'active'
                ], 'id = ?', [$subscriptionId]);
                
                // Update payment status
                $db->update('payments', ['status' => 'completed'], 'subscription_id = ?', [$subscriptionId]);
                
                // Send notification
                NotificationController::send($subscription['user_id'], 'subscription_approved', [
                    'plan_name' => $subscription['plan_name'] ?? ''
                ]);
                
                $message = 'تم الموافقة على الاشتراك وتفعيله';
            } else {
                $db->update('subscriptions', [
                    'status' => 'rejected'
                ], 'id = ?', [$subscriptionId]);
                
                // Update payment status
                $db->update('payments', ['status' => 'rejected'], 'subscription_id = ?', [$subscriptionId]);
                
                $message = 'تم رفض الاشتراك';
                $messageType = 'warning';
            }
            // Redirect to refresh the page
            header('Location: subscriptions.php?msg=' . urlencode($message) . '&type=' . $messageType);
            exit;
        }
    }
    
    if ($requestId) {
        $request = $db->fetch(
            "SELECT sr.*, p.duration_days, p.listings_count, p.is_unlimited, p.category 
             FROM subscription_requests sr 
             JOIN plans p ON sr.plan_id = p.id 
             WHERE sr.id = ?",
            [$requestId]
        );
        
        if ($request) {
            if ($action === 'approve') {
                // Create subscription for user
                $expiresAt = date('Y-m-d H:i:s', strtotime("+{$request['duration_days']} days"));
                
                $subscriptionId = $db->insert('subscriptions', [
                    'user_id' => $request['user_id'],
                    'plan_id' => $request['plan_id'],
                    'listings_limit' => $request['listings_count'],
                    'is_unlimited' => $request['is_unlimited'],
                    'status' => 'active',
                    'expires_at' => $expiresAt
                ]);
                
                // Update request status
                $db->update('subscription_requests', [
                    'status' => 'approved',
                    'reviewed_by' => $_SESSION['admin_id'],
                    'reviewed_at' => date('Y-m-d H:i:s'),
                    'admin_notes' => $_POST['notes'] ?? null
                ], 'id = ?', [$requestId]);
                
                // Get plan name for notification
                $plan = $db->fetch("SELECT name_ar FROM plans WHERE id = ?", [$request['plan_id']]);
                
                // Send push notification via OneSignal
                NotificationController::send($request['user_id'], 'subscription_approved', [
                    'plan_name' => $plan['name_ar'] ?? ''
                ]);
                
                $message = 'تم الموافقة على الطلب وتفعيل الباقة للمستخدم';
                header('Location: subscriptions.php?msg=' . urlencode($message) . '&type=success');
                exit;
                
            } elseif ($action === 'reject') {
                $db->update('subscription_requests', [
                    'status' => 'rejected',
                    'reviewed_by' => $_SESSION['admin_id'],
                    'reviewed_at' => date('Y-m-d H:i:s'),
                    'admin_notes' => $_POST['notes'] ?? null
                ], 'id = ?', [$requestId]);
                
                // TODO: Send rejection notification if needed
                
                $message = 'تم رفض الطلب';
                header('Location: subscriptions.php?msg=' . urlencode($message) . '&type=warning');
                exit;
            }
        }
    }
}

// Handle message from redirect
if (isset($_GET['msg'])) {
    $message = $_GET['msg'];
    $messageType = $_GET['type'] ?? 'success';
}

// Get filter
$status = $_GET['status'] ?? 'pending';
$category = $_GET['category'] ?? '';

$where = "1=1";
$params = [];

if ($status && $status !== 'all') {
    $where .= " AND sr.status = ?";
    $params[] = $status;
}

if ($category && in_array($category, ['properties', 'cars'])) {
    $where .= " AND p.category = ?";
    $params[] = $category;
}

$requests = $db->fetchAll(
    "SELECT sr.*, 
            u.name as user_name, u.phone as user_phone, u.email as user_email,
            p.name_ar as plan_name, p.category, p.plan_type, p.price, p.listings_count, p.is_unlimited, p.duration_days, p.badge,
            a.name as reviewer_name
     FROM subscription_requests sr
     JOIN users u ON sr.user_id = u.id
     JOIN plans p ON sr.plan_id = p.id
     LEFT JOIN admin_users a ON sr.reviewed_by = a.id
     WHERE $where
     ORDER BY sr.created_at DESC",
    $params
);

// Get counts
$counts = [
    'pending' => $db->fetch("SELECT COUNT(*) as count FROM subscription_requests WHERE status = 'pending'")['count'],
    'approved' => $db->fetch("SELECT COUNT(*) as count FROM subscription_requests WHERE status = 'approved'")['count'],
    'rejected' => $db->fetch("SELECT COUNT(*) as count FROM subscription_requests WHERE status = 'rejected'")['count']
];

// Get pending direct subscriptions (Apple Pay, Google Pay, Bank Transfer)
$pendingSubscriptions = $db->fetchAll(
    "SELECT s.*, 
            u.name as user_name, u.phone as user_phone,
            p.name_ar as plan_name, p.category, p.price, p.listings_count, p.is_unlimited, p.duration_days, p.badge,
            pay.transaction_id, pay.sender_name
     FROM subscriptions s
     JOIN users u ON s.user_id = u.id
     JOIN plans p ON s.plan_id = p.id
     LEFT JOIN payments pay ON pay.subscription_id = s.id
     WHERE s.status = 'pending_verification'
     ORDER BY s.created_at DESC"
);
$pendingSubCount = count($pendingSubscriptions);

include 'includes/header.php';
?>

<div class="container-fluid py-4">
    <div class="row mb-4">
        <div class="col-12">
            <h1 class="h3 mb-0">إدارة طلبات الاشتراكات</h1>
        </div>
    </div>

    <?php if ($message): ?>
    <div class="alert alert-<?= $messageType ?> alert-dismissible fade show" role="alert">
        <?= htmlspecialchars($message) ?>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <?php endif; ?>

    <!-- Stats Cards -->
    <div class="row mb-4">
        <div class="col-md-4">
            <div class="card bg-warning text-dark">
                <div class="card-body">
                    <h5 class="card-title">طلبات معلقة</h5>
                    <h2><?= $counts['pending'] ?></h2>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card bg-success text-white">
                <div class="card-body">
                    <h5 class="card-title">طلبات موافق عليها</h5>
                    <h2><?= $counts['approved'] ?></h2>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card bg-danger text-white">
                <div class="card-body">
                    <h5 class="card-title">طلبات مرفوضة</h5>
                    <h2><?= $counts['rejected'] ?></h2>
                </div>
            </div>
        </div>
    </div>

    <!-- Pending Direct Subscriptions (Apple Pay, Google Pay, Bank Transfer) -->
    <?php if ($pendingSubCount > 0): ?>
    <div class="card mb-4 border-warning">
        <div class="card-header bg-warning text-dark">
            <h5 class="mb-0"><i class="bi bi-clock-history me-2"></i>اشتراكات بانتظار الموافقة (<?= $pendingSubCount ?>)</h5>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>المستخدم</th>
                            <th>الباقة</th>
                            <th>طريقة الدفع</th>
                            <th>السعر</th>
                            <th>تاريخ الطلب</th>
                            <th>إجراءات</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($pendingSubscriptions as $sub): ?>
                        <tr>
                            <td><?= $sub['id'] ?></td>
                            <td>
                                <strong><?= htmlspecialchars($sub['user_name']) ?></strong><br>
                                <small class="text-muted"><?= $sub['user_phone'] ?></small>
                            </td>
                            <td>
                                <?= htmlspecialchars($sub['plan_name']) ?>
                                <?php if ($sub['badge']): ?>
                                <span class="badge bg-<?= $sub['badge'] === 'gold' ? 'warning' : ($sub['badge'] === 'silver' ? 'secondary' : 'dark') ?>">
                                    <?= $sub['badge'] ?>
                                </span>
                                <?php endif; ?>
                            </td>
                            <td>
                                <?php
                                $methodLabels = [
                                    'apple_pay' => 'Apple Pay',
                                    'google_pay' => 'Google Pay',
                                    'bank_transfer' => 'تحويل بنكي',
                                ];
                                echo $methodLabels[$sub['payment_method']] ?? $sub['payment_method'];
                                if ($sub['sender_name']): ?>
                                <br><small class="text-muted">المرسل: <?= htmlspecialchars($sub['sender_name']) ?></small>
                                <?php endif; ?>
                            </td>
                            <td><?= number_format($sub['price']) ?> ₪</td>
                            <td><?= date('Y-m-d H:i', strtotime($sub['created_at'])) ?></td>
                            <td>
                                <form method="POST" class="d-inline">
                                    <input type="hidden" name="subscription_id" value="<?= $sub['id'] ?>">
                                    <button type="submit" name="action" value="approve_subscription" class="btn btn-sm btn-success">
                                        <i class="bi bi-check-lg"></i> موافقة
                                    </button>
                                    <button type="submit" name="action" value="reject_subscription" class="btn btn-sm btn-danger">
                                        <i class="bi bi-x-lg"></i> رفض
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
    <?php endif; ?>

    <!-- Filters -->
    <div class="card mb-4">
        <div class="card-body">
            <form method="GET" class="row g-3">
                <div class="col-md-4">
                    <label class="form-label">الحالة</label>
                    <select name="status" class="form-select">
                        <option value="pending" <?= $status === 'pending' ? 'selected' : '' ?>>معلق</option>
                        <option value="approved" <?= $status === 'approved' ? 'selected' : '' ?>>موافق عليه</option>
                        <option value="rejected" <?= $status === 'rejected' ? 'selected' : '' ?>>مرفوض</option>
                        <option value="all" <?= $status === 'all' ? 'selected' : '' ?>>الكل</option>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">الفئة</label>
                    <select name="category" class="form-select">
                        <option value="">الكل</option>
                        <option value="properties" <?= $category === 'properties' ? 'selected' : '' ?>>عقارات</option>
                        <option value="cars" <?= $category === 'cars' ? 'selected' : '' ?>>سيارات</option>
                    </select>
                </div>
                <div class="col-md-4 d-flex align-items-end">
                    <button type="submit" class="btn btn-primary">فلترة</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Requests Table -->
    <div class="card">
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>المستخدم</th>
                            <th>الباقة</th>
                            <th>الفئة</th>
                            <th>السعر</th>
                            <th>الإعلانات</th>
                            <th>المدة</th>
                            <th>تاريخ الطلب</th>
                            <th>الحالة</th>
                            <th>إجراءات</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (empty($requests)): ?>
                        <tr>
                            <td colspan="10" class="text-center py-4">لا توجد طلبات</td>
                        </tr>
                        <?php endif; ?>
                        <?php foreach ($requests as $req): ?>
                        <tr>
                            <td><?= $req['id'] ?></td>
                            <td>
                                <strong><?= htmlspecialchars($req['user_name']) ?></strong><br>
                                <small class="text-muted"><?= $req['user_phone'] ?></small>
                            </td>
                            <td>
                                <?= htmlspecialchars($req['plan_name']) ?>
                                <?php if ($req['badge']): ?>
                                <span class="badge bg-<?= $req['badge'] === 'gold' ? 'warning' : ($req['badge'] === 'silver' ? 'secondary' : 'dark') ?>">
                                    <?= $req['badge'] ?>
                                </span>
                                <?php endif; ?>
                            </td>
                            <td>
                                <span class="badge bg-<?= $req['category'] === 'properties' ? 'primary' : 'info' ?>">
                                    <?= $req['category'] === 'properties' ? 'عقارات' : 'سيارات' ?>
                                </span>
                            </td>
                            <td><?= number_format($req['price']) ?> ₪</td>
                            <td><?= $req['is_unlimited'] ? 'غير محدود' : $req['listings_count'] ?></td>
                            <td><?= $req['duration_days'] ?> يوم</td>
                            <td><?= date('Y-m-d H:i', strtotime($req['created_at'])) ?></td>
                            <td>
                                <?php
                                $statusBadge = [
                                    'pending' => 'warning',
                                    'approved' => 'success',
                                    'rejected' => 'danger'
                                ];
                                $statusText = [
                                    'pending' => 'معلق',
                                    'approved' => 'موافق',
                                    'rejected' => 'مرفوض'
                                ];
                                ?>
                                <span class="badge bg-<?= $statusBadge[$req['status']] ?>">
                                    <?= $statusText[$req['status']] ?>
                                </span>
                                <?php if ($req['reviewer_name']): ?>
                                <br><small class="text-muted">بواسطة: <?= htmlspecialchars($req['reviewer_name']) ?></small>
                                <?php endif; ?>
                            </td>
                            <td>
                                <?php if ($req['status'] === 'pending'): ?>
                                <button class="btn btn-sm btn-success" data-bs-toggle="modal" data-bs-target="#approveModal<?= $req['id'] ?>">
                                    <i class="bi bi-check-lg"></i> موافقة
                                </button>
                                <button class="btn btn-sm btn-danger" data-bs-toggle="modal" data-bs-target="#rejectModal<?= $req['id'] ?>">
                                    <i class="bi bi-x-lg"></i> رفض
                                </button>
                                
                                <!-- Approve Modal -->
                                <div class="modal fade" id="approveModal<?= $req['id'] ?>" tabindex="-1">
                                    <div class="modal-dialog">
                                        <div class="modal-content">
                                            <form method="POST">
                                                <input type="hidden" name="action" value="approve">
                                                <input type="hidden" name="request_id" value="<?= $req['id'] ?>">
                                                <div class="modal-header">
                                                    <h5 class="modal-title">تأكيد الموافقة</h5>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                </div>
                                                <div class="modal-body">
                                                    <p>هل تريد الموافقة على طلب الاشتراك للمستخدم <strong><?= htmlspecialchars($req['user_name']) ?></strong>؟</p>
                                                    <p>الباقة: <strong><?= htmlspecialchars($req['plan_name']) ?></strong></p>
                                                    <div class="mb-3">
                                                        <label class="form-label">ملاحظات (اختياري)</label>
                                                        <textarea name="notes" class="form-control" rows="2"></textarea>
                                                    </div>
                                                </div>
                                                <div class="modal-footer">
                                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">إلغاء</button>
                                                    <button type="submit" class="btn btn-success">موافقة</button>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                                
                                <!-- Reject Modal -->
                                <div class="modal fade" id="rejectModal<?= $req['id'] ?>" tabindex="-1">
                                    <div class="modal-dialog">
                                        <div class="modal-content">
                                            <form method="POST">
                                                <input type="hidden" name="action" value="reject">
                                                <input type="hidden" name="request_id" value="<?= $req['id'] ?>">
                                                <div class="modal-header">
                                                    <h5 class="modal-title">تأكيد الرفض</h5>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                </div>
                                                <div class="modal-body">
                                                    <p>هل تريد رفض طلب الاشتراك للمستخدم <strong><?= htmlspecialchars($req['user_name']) ?></strong>؟</p>
                                                    <div class="mb-3">
                                                        <label class="form-label">سبب الرفض</label>
                                                        <textarea name="notes" class="form-control" rows="2" required></textarea>
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
                                <?php else: ?>
                                <span class="text-muted">—</span>
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

<?php include 'includes/footer.php'; ?>
