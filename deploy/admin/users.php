<?php
session_start();
require_once __DIR__ . '/../backend/config/database.php';
require_once __DIR__ . '/../backend/config/constants.php';

if (!isset($_SESSION['admin_id'])) {
    header('Location: login.php');
    exit;
}

$db = Database::getInstance();

// Handle actions
$message = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    $userId = (int)($_POST['user_id'] ?? 0);
    
    if ($userId) {
        switch ($action) {
            case 'block':
                $db->update('users', ['is_blocked' => 1], 'id = ?', [$userId]);
                $message = 'تم حظر المستخدم';
                break;
            case 'unblock':
                $db->update('users', ['is_blocked' => 0], 'id = ?', [$userId]);
                $message = 'تم إلغاء حظر المستخدم';
                break;
            case 'trust':
                $trustedUntil = date('Y-m-d', strtotime('+1 month'));
                $db->update('users', ['is_trusted' => 1, 'trusted_until' => $trustedUntil], 'id = ?', [$userId]);
                $message = 'تم توثيق المستخدم';
                break;
            case 'untrust':
                $db->update('users', ['is_trusted' => 0, 'trusted_until' => null], 'id = ?', [$userId]);
                $message = 'تم إلغاء توثيق المستخدم';
                break;
            case 'approve':
                $db->update('users', ['is_approved' => 1], 'id = ?', [$userId]);
                $message = 'تم الموافقة على المستخدم';
                break;
            case 'reject':
                $db->update('users', ['is_approved' => 0], 'id = ?', [$userId]);
                $message = 'تم رفض المستخدم';
                break;
            case 'verify_phone':
                $db->update('users', ['is_verified_phone' => 1], 'id = ?', [$userId]);
                $message = 'تم تفعيل رقم الهاتف';
                break;
            case 'verify_email':
                $db->update('users', ['is_verified_email' => 1], 'id = ?', [$userId]);
                $message = 'تم تفعيل البريد الإلكتروني';
                break;
            case 'change_password':
                $newPassword = $_POST['new_password'] ?? '';
                if ($newPassword && strlen($newPassword) >= 6) {
                    $hashedPassword = password_hash($newPassword, PASSWORD_DEFAULT);
                    $db->update('users', ['password' => $hashedPassword], 'id = ?', [$userId]);
                    $message = 'تم تغيير كلمة المرور بنجاح';
                } else {
                    $message = 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                }
                break;
        }
    }
}

$search = $_GET['search'] ?? '';
$userType = $_GET['user_type'] ?? '';
$approvalStatus = $_GET['approval'] ?? '';
$page = max(1, (int)($_GET['page'] ?? 1));
$perPage = 20;
$offset = ($page - 1) * $perPage;

$where = "1=1";
$params = [];

if ($search) {
    $where .= " AND (name LIKE ? OR email LIKE ? OR phone LIKE ? OR company_name LIKE ?)";
    $params[] = "%$search%";
    $params[] = "%$search%";
    $params[] = "%$search%";
    $params[] = "%$search%";
}

if ($userType) {
    $where .= " AND user_type = ?";
    $params[] = $userType;
}

if ($approvalStatus !== '') {
    $where .= " AND is_approved = ?";
    $params[] = (int)$approvalStatus;
}

$total = $db->fetch("SELECT COUNT(*) as total FROM users WHERE $where", $params)['total'];
$users = $db->fetchAll("SELECT * FROM users WHERE $where ORDER BY created_at DESC LIMIT $perPage OFFSET $offset", $params);

// Get listings count and subscriptions for each user
foreach ($users as &$user) {
    $counts = $db->fetch("
        SELECT 
            (SELECT COUNT(*) FROM properties WHERE user_id = ?) as properties,
            (SELECT COUNT(*) FROM cars WHERE user_id = ?) as cars
    ", [$user['id'], $user['id']]);
    $user['properties_count'] = $counts['properties'];
    $user['cars_count'] = $counts['cars'];
    
    // Get user subscriptions
    $user['subscriptions'] = $db->fetchAll("
        SELECT s.*, p.name_ar as plan_name, p.category, p.badge, p.price
        FROM subscriptions s
        JOIN plans p ON s.plan_id = p.id
        WHERE s.user_id = ?
        ORDER BY s.created_at DESC
    ", [$user['id']]);
}
unset($user); // Important: break the reference to avoid bugs in subsequent foreach loops

include 'includes/header.php';
?>

<div class="container-fluid py-4">
    <div class="row mb-4">
        <div class="col-12">
            <h1 class="h3 mb-0">إدارة المستخدمين</h1>
        </div>
    </div>

    <?php if ($message): ?>
    <div class="alert alert-success alert-dismissible fade show" role="alert">
        <?= htmlspecialchars($message) ?>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <?php endif; ?>

    <!-- Filters -->
    <div class="card mb-4">
        <div class="card-body">
            <form method="GET" class="row g-3">
                <div class="col-md-3">
                    <input type="text" name="search" class="form-control" placeholder="بحث بالاسم أو الإيميل أو الهاتف..." 
                           value="<?= htmlspecialchars($search) ?>">
                </div>
                <div class="col-md-2">
                    <select name="user_type" class="form-select">
                        <option value="">كل الأنواع</option>
                        <?php foreach (USER_TYPES as $key => $val): ?>
                        <option value="<?= $key ?>" <?= $userType === $key ? 'selected' : '' ?>><?= $val['ar'] ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <div class="col-md-2">
                    <select name="approval" class="form-select">
                        <option value="">كل الحالات</option>
                        <option value="0" <?= $approvalStatus === '0' ? 'selected' : '' ?>>بانتظار الموافقة</option>
                        <option value="1" <?= $approvalStatus === '1' ? 'selected' : '' ?>>موافق عليه</option>
                    </select>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn btn-primary w-100">
                        <i class="bi bi-search me-1"></i> بحث
                    </button>
                </div>
                <div class="col-md-3">
                    <a href="?approval=0" class="btn btn-warning w-100">
                        <i class="bi bi-clock me-1"></i> بانتظار الموافقة
                    </a>
                </div>
            </form>
        </div>
    </div>

    <!-- Users Table -->
    <div class="card">
        <div class="card-header">
            <h5 class="mb-0">المستخدمين (<?= $total ?>)</h5>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>الاسم</th>
                            <th>الإيميل</th>
                            <th>الهاتف</th>
                            <th>النوع</th>
                            <th>التحقق</th>
                            <th>الموافقة</th>
                            <th>الحالة</th>
                            <th>الإعلانات</th>
                            <th>الباقات</th>
                            <th>التاريخ</th>
                            <th>إجراءات</th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php foreach ($users as $user): ?>
                        <tr class="<?= !$user['is_approved'] ? 'table-warning' : '' ?>">
                            <td><?= $user['id'] ?></td>
                            <td>
                                <strong><?= htmlspecialchars($user['name']) ?></strong>
                                <?php if ($user['company_name']): ?>
                                <br><small class="text-muted"><?= htmlspecialchars($user['company_name']) ?></small>
                                <?php endif; ?>
                                <?php if ($user['is_trusted']): ?>
                                <span class="badge bg-success">موثق</span>
                                <?php endif; ?>
                            </td>
                            <td>
                                <?= htmlspecialchars($user['email']) ?>
                                <?php if ($user['is_verified_email']): ?>
                                <i class="bi bi-check-circle-fill text-success" title="تم التحقق"></i>
                                <?php endif; ?>
                            </td>
                            <td>
                                <?= htmlspecialchars($user['phone']) ?>
                                <?php if ($user['is_verified_phone']): ?>
                                <i class="bi bi-check-circle-fill text-success" title="تم التحقق"></i>
                                <?php endif; ?>
                            </td>
                            <td><?= USER_TYPES[$user['user_type']]['ar'] ?? $user['user_type'] ?></td>
                            <td>
                                <?php if ($user['is_verified_phone']): ?>
                                <span class="badge bg-success">هاتف ✓</span>
                                <?php else: ?>
                                <span class="badge bg-secondary">هاتف ✗</span>
                                <?php endif; ?>
                                <?php if ($user['is_verified_email']): ?>
                                <span class="badge bg-success">إيميل ✓</span>
                                <?php else: ?>
                                <span class="badge bg-secondary">إيميل ✗</span>
                                <?php endif; ?>
                            </td>
                            <td>
                                <?php if ($user['is_approved']): ?>
                                <span class="badge bg-success">موافق عليه</span>
                                <?php else: ?>
                                <span class="badge bg-warning text-dark">بانتظار الموافقة</span>
                                <?php endif; ?>
                            </td>
                            <td>
                                <?php if ($user['is_blocked']): ?>
                                <span class="badge bg-danger">محظور</span>
                                <?php elseif ($user['is_active']): ?>
                                <span class="badge bg-success">نشط</span>
                                <?php else: ?>
                                <span class="badge bg-secondary">غير نشط</span>
                                <?php endif; ?>
                            </td>
                            <td>
                                <span class="badge bg-info"><?= $user['properties_count'] ?> عقار</span>
                                <span class="badge bg-secondary"><?= $user['cars_count'] ?> سيارة</span>
                            </td>
                            <td>
                                <?php if (!empty($user['subscriptions'])): ?>
                                <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#subsModal<?= $user['id'] ?>">
                                    <i class="bi bi-box-seam me-1"></i><?= count($user['subscriptions']) ?> باقة
                                </button>
                                <?php else: ?>
                                <span class="text-muted">لا يوجد</span>
                                <?php endif; ?>
                            </td>
                            <td><?= date('Y/m/d', strtotime($user['created_at'])) ?></td>
                            <td>
                                <div class="dropdown">
                                    <button class="btn btn-sm btn-outline-secondary dropdown-toggle" type="button" data-bs-toggle="dropdown">
                                        إجراءات
                                    </button>
                                    <ul class="dropdown-menu">
                                        <!-- Approval Actions -->
                                        <?php if (!$user['is_approved']): ?>
                                        <li>
                                            <form method="POST">
                                                <input type="hidden" name="user_id" value="<?= $user['id'] ?>">
                                                <button type="submit" name="action" value="approve" class="dropdown-item text-success">
                                                    <i class="bi bi-check-lg me-1"></i> موافقة على الحساب
                                                </button>
                                            </form>
                                        </li>
                                        <?php else: ?>
                                        <li>
                                            <form method="POST">
                                                <input type="hidden" name="user_id" value="<?= $user['id'] ?>">
                                                <button type="submit" name="action" value="reject" class="dropdown-item text-danger">
                                                    <i class="bi bi-x-lg me-1"></i> إلغاء الموافقة
                                                </button>
                                            </form>
                                        </li>
                                        <?php endif; ?>
                                        
                                        <li><hr class="dropdown-divider"></li>
                                        
                                        <!-- Block/Unblock -->
                                        <?php if ($user['is_blocked']): ?>
                                        <li>
                                            <form method="POST">
                                                <input type="hidden" name="user_id" value="<?= $user['id'] ?>">
                                                <button type="submit" name="action" value="unblock" class="dropdown-item text-success">
                                                    <i class="bi bi-unlock me-1"></i> إلغاء الحظر
                                                </button>
                                            </form>
                                        </li>
                                        <?php else: ?>
                                        <li>
                                            <form method="POST">
                                                <input type="hidden" name="user_id" value="<?= $user['id'] ?>">
                                                <button type="submit" name="action" value="block" class="dropdown-item text-danger">
                                                    <i class="bi bi-lock me-1"></i> حظر
                                                </button>
                                            </form>
                                        </li>
                                        <?php endif; ?>
                                        
                                        <li><hr class="dropdown-divider"></li>
                                        
                                        <!-- Trust/Untrust -->
                                        <?php if ($user['is_trusted']): ?>
                                        <li>
                                            <form method="POST">
                                                <input type="hidden" name="user_id" value="<?= $user['id'] ?>">
                                                <button type="submit" name="action" value="untrust" class="dropdown-item">
                                                    <i class="bi bi-star me-1"></i> إلغاء التوثيق
                                                </button>
                                            </form>
                                        </li>
                                        <?php else: ?>
                                        <li>
                                            <form method="POST">
                                                <input type="hidden" name="user_id" value="<?= $user['id'] ?>">
                                                <button type="submit" name="action" value="trust" class="dropdown-item text-warning">
                                                    <i class="bi bi-star-fill me-1"></i> توثيق
                                                </button>
                                            </form>
                                        </li>
                                        <?php endif; ?>
                                        
                                        <li><hr class="dropdown-divider"></li>
                                        
                                        <!-- Verify Phone/Email -->
                                        <?php if (!$user['is_verified_phone']): ?>
                                        <li>
                                            <form method="POST">
                                                <input type="hidden" name="user_id" value="<?= $user['id'] ?>">
                                                <button type="submit" name="action" value="verify_phone" class="dropdown-item">
                                                    <i class="bi bi-phone me-1"></i> تفعيل الهاتف
                                                </button>
                                            </form>
                                        </li>
                                        <?php endif; ?>
                                        <?php if (!$user['is_verified_email']): ?>
                                        <li>
                                            <form method="POST">
                                                <input type="hidden" name="user_id" value="<?= $user['id'] ?>">
                                                <button type="submit" name="action" value="verify_email" class="dropdown-item">
                                                    <i class="bi bi-envelope me-1"></i> تفعيل الإيميل
                                                </button>
                                            </form>
                                        </li>
                                        <?php endif; ?>
                                        
                                        <li><hr class="dropdown-divider"></li>
                                        
                                        <!-- Change Password -->
                                        <li>
                                            <button type="button" class="dropdown-item text-primary" data-bs-toggle="modal" data-bs-target="#passwordModal<?= $user['id'] ?>">
                                                <i class="bi bi-key me-1"></i> تغيير كلمة المرور
                                            </button>
                                        </li>
                                    </ul>
                                </div>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Subscription Modals -->
<?php foreach ($users as $user): ?>
<?php if (!empty($user['subscriptions'])): ?>
<div class="modal fade" id="subsModal<?= $user['id'] ?>" tabindex="-1">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">
                    <i class="bi bi-box-seam me-2"></i>باقات المستخدم: <?= htmlspecialchars($user['name']) ?>
                </h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="table-responsive">
                    <table class="table table-sm table-bordered">
                        <thead class="table-light">
                            <tr>
                                <th>الباقة</th>
                                <th>الفئة</th>
                                <th>المستخدم</th>
                                <th>المتبقي</th>
                                <th>الحالة</th>
                                <th>تاريخ الانتهاء</th>
                                <th>طريقة الدفع</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($user['subscriptions'] as $sub): 
                                $remaining = $sub['is_unlimited'] ? '∞' : max(0, $sub['listings_limit'] - $sub['listings_used']);
                                $isExpired = strtotime($sub['expires_at']) < time();
                                $daysLeft = max(0, (int)((strtotime($sub['expires_at']) - time()) / 86400));
                            ?>
                            <tr class="<?= $isExpired ? 'table-secondary' : '' ?>">
                                <td>
                                    <strong><?= htmlspecialchars($sub['plan_name']) ?></strong>
                                    <?php if ($sub['badge']): ?>
                                    <span class="badge bg-<?= $sub['badge'] === 'gold' ? 'warning' : ($sub['badge'] === 'silver' ? 'secondary' : 'dark') ?> ms-1">
                                        <?= $sub['badge'] ?>
                                    </span>
                                    <?php endif; ?>
                                    <br><small class="text-muted"><?= number_format($sub['price']) ?> ₪</small>
                                </td>
                                <td>
                                    <span class="badge bg-<?= $sub['category'] === 'properties' ? 'primary' : 'info' ?>">
                                        <?= $sub['category'] === 'properties' ? 'عقارات' : 'سيارات' ?>
                                    </span>
                                </td>
                                <td>
                                    <span class="fw-bold"><?= $sub['listings_used'] ?></span>
                                    <small class="text-muted">/ <?= $sub['is_unlimited'] ? '∞' : $sub['listings_limit'] ?></small>
                                </td>
                                <td>
                                    <?php if ($sub['is_unlimited']): ?>
                                    <span class="badge bg-success">غير محدود</span>
                                    <?php else: ?>
                                    <span class="badge bg-<?= $remaining > 0 ? 'success' : 'danger' ?>">
                                        <?= $remaining ?> إعلان
                                    </span>
                                    <?php endif; ?>
                                </td>
                                <td>
                                    <?php if ($isExpired || $sub['status'] === 'expired'): ?>
                                    <span class="badge bg-danger">منتهي</span>
                                    <?php elseif ($sub['status'] === 'active'): ?>
                                    <span class="badge bg-success">فعال</span>
                                    <?php elseif ($sub['status'] === 'cancelled'): ?>
                                    <span class="badge bg-secondary">ملغي</span>
                                    <?php else: ?>
                                    <span class="badge bg-warning"><?= $sub['status'] ?></span>
                                    <?php endif; ?>
                                </td>
                                <td>
                                    <?php if ($isExpired): ?>
                                    <span class="text-danger"><?= date('Y-m-d', strtotime($sub['expires_at'])) ?></span>
                                    <?php else: ?>
                                    <?= date('Y-m-d', strtotime($sub['expires_at'])) ?>
                                    <br><small class="text-success">(<?= $daysLeft ?> يوم)</small>
                                    <?php endif; ?>
                                </td>
                                <td>
                                    <?php 
                                    $methods = [
                                        'test' => 'تجريبي',
                                        'apple_pay' => 'Apple Pay',
                                        'google_pay' => 'Google Pay',
                                        'bank_transfer' => 'تحويل بنكي',
                                        'welcome_bonus' => 'هدية ترحيبية'
                                    ];
                                    ?>
                                    <small><?= $methods[$sub['payment_method']] ?? $sub['payment_method'] ?></small>
                                </td>
                            </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">إغلاق</button>
            </div>
        </div>
    </div>
</div>
<?php endif; ?>
<?php endforeach; ?>

<!-- Password Change Modals -->
<?php foreach ($users as $user): ?>
<div class="modal fade" id="passwordModal<?= $user['id'] ?>" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="POST" onsubmit="return validatePassword<?= $user['id'] ?>()">
                <input type="hidden" name="user_id" value="<?= $user['id'] ?>">
                <input type="hidden" name="action" value="change_password">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="bi bi-key me-2"></i>تغيير كلمة المرور
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="alert alert-info">
                        <i class="bi bi-info-circle me-2"></i>
                        <strong>المستخدم:</strong> <?= htmlspecialchars($user['name']) ?>
                        <br><small><?= htmlspecialchars($user['email']) ?></small>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">كلمة المرور الجديدة <span class="text-danger">*</span></label>
                        <input type="password" name="new_password" id="newPassword<?= $user['id'] ?>" 
                               class="form-control" placeholder="أدخل كلمة المرور الجديدة" 
                               minlength="6" required>
                        <small class="text-muted">يجب أن تكون 6 أحرف على الأقل</small>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">تأكيد كلمة المرور <span class="text-danger">*</span></label>
                        <input type="password" id="confirmPassword<?= $user['id'] ?>" 
                               class="form-control" placeholder="أعد إدخال كلمة المرور" 
                               minlength="6" required>
                        <div id="passwordError<?= $user['id'] ?>" class="text-danger small mt-1" style="display: none;">
                            كلمة المرور غير متطابقة
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">إلغاء</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-check-lg me-1"></i>تغيير كلمة المرور
                    </button>
                </div>
            </form>
            <script>
            function validatePassword<?= $user['id'] ?>() {
                const password = document.getElementById('newPassword<?= $user['id'] ?>').value;
                const confirm = document.getElementById('confirmPassword<?= $user['id'] ?>').value;
                const errorDiv = document.getElementById('passwordError<?= $user['id'] ?>');
                
                if (password !== confirm) {
                    errorDiv.style.display = 'block';
                    return false;
                }
                errorDiv.style.display = 'none';
                return true;
            }
            </script>
        </div>
    </div>
</div>
<?php endforeach; ?>

<?php include 'includes/footer.php'; ?>
