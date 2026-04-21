<?php
session_start();
require_once __DIR__ . '/../backend/config/database.php';

if (!isset($_SESSION['admin_id']) || $_SESSION['admin_role'] !== 'super_admin') {
    header('Location: index.php');
    exit;
}

$db = Database::getInstance();
$message = '';
$messageType = 'success';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'];
    
    if ($action === 'add') {
        // Check if email already exists
        $existing = $db->fetch("SELECT id FROM admin_users WHERE email = ?", [$_POST['email']]);
        if ($existing) {
            $message = 'البريد الإلكتروني مستخدم بالفعل';
            $messageType = 'danger';
        } else {
            $db->insert('admin_users', [
                'name' => $_POST['name'],
                'email' => $_POST['email'],
                'password' => password_hash($_POST['password'], PASSWORD_DEFAULT),
                'role' => $_POST['role']
            ]);
            $message = 'تم إضافة المشرف بنجاح';
        }
    } elseif ($action === 'edit') {
        $id = (int)$_POST['id'];
        
        // Check if email already exists for another admin
        $existing = $db->fetch("SELECT id FROM admin_users WHERE email = ? AND id != ?", [$_POST['email'], $id]);
        if ($existing) {
            $message = 'البريد الإلكتروني مستخدم بالفعل';
            $messageType = 'danger';
        } else {
            $updateData = [
                'name' => $_POST['name'],
                'email' => $_POST['email'],
                'role' => $_POST['role']
            ];
            
            // Only update password if provided
            if (!empty($_POST['password'])) {
                $updateData['password'] = password_hash($_POST['password'], PASSWORD_DEFAULT);
            }
            
            $db->update('admin_users', $updateData, 'id = ?', [$id]);
            $message = 'تم تحديث بيانات المشرف بنجاح';
        }
    } elseif ($action === 'toggle') {
        $id = (int)$_POST['id'];
        $current = $db->fetch("SELECT is_active FROM admin_users WHERE id = ?", [$id]);
        $db->update('admin_users', ['is_active' => !$current['is_active']], 'id = ?', [$id]);
        $message = 'تم تحديث الحالة';
    } elseif ($action === 'delete') {
        $id = (int)$_POST['id'];
        // Prevent deleting self
        if ($id == $_SESSION['admin_id']) {
            $message = 'لا يمكنك حذف حسابك الخاص';
            $messageType = 'danger';
        } else {
            $db->delete('admin_users', 'id = ?', [$id]);
            $message = 'تم حذف المشرف بنجاح';
        }
    }
}

$admins = $db->fetchAll("SELECT * FROM admin_users ORDER BY id");

include 'includes/header.php';
?>

<div class="container-fluid py-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0">إدارة المشرفين</h1>
        <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addModal">
            <i class="bi bi-plus-lg me-1"></i> إضافة مشرف
        </button>
    </div>

    <?php if ($message): ?>
    <div class="alert alert-<?= $messageType ?>"><?= $message ?></div>
    <?php endif; ?>

    <div class="card">
        <div class="card-body p-0">
            <table class="table table-hover mb-0">
                <thead>
                    <tr><th>#</th><th>الاسم</th><th>الإيميل</th><th>الدور</th><th>آخر دخول</th><th>الحالة</th><th>إجراءات</th></tr>
                </thead>
                <tbody>
                    <?php foreach ($admins as $admin): ?>
                    <tr>
                        <td><?= $admin['id'] ?></td>
                        <td><?= htmlspecialchars($admin['name']) ?></td>
                        <td><?= htmlspecialchars($admin['email']) ?></td>
                        <td><span class="badge bg-<?= $admin['role'] === 'super_admin' ? 'danger' : 'primary' ?>"><?= $admin['role'] ?></span></td>
                        <td><?= $admin['last_login'] ? date('Y/m/d H:i', strtotime($admin['last_login'])) : '-' ?></td>
                        <td><?= $admin['is_active'] ? '<span class="badge bg-success">نشط</span>' : '<span class="badge bg-secondary">معطل</span>' ?></td>
                        <td>
                            <button class="btn btn-sm btn-outline-primary me-1" onclick="editAdmin(<?= htmlspecialchars(json_encode($admin)) ?>)">
                                <i class="bi bi-pencil"></i> تعديل
                            </button>
                            <?php if ($admin['id'] != $_SESSION['admin_id']): ?>
                            <form method="POST" class="d-inline">
                                <input type="hidden" name="action" value="toggle">
                                <input type="hidden" name="id" value="<?= $admin['id'] ?>">
                                <button class="btn btn-sm btn-outline-warning me-1"><?= $admin['is_active'] ? 'تعطيل' : 'تفعيل' ?></button>
                            </form>
                            <form method="POST" class="d-inline" onsubmit="return confirm('هل أنت متأكد من حذف هذا المشرف؟')">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="id" value="<?= $admin['id'] ?>">
                                <button class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i></button>
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

<div class="modal fade" id="addModal">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="POST">
                <input type="hidden" name="action" value="add">
                <div class="modal-header"><h5>إضافة مشرف</h5></div>
                <div class="modal-body">
                    <div class="mb-3"><label class="form-label">الاسم</label><input type="text" name="name" class="form-control" required></div>
                    <div class="mb-3"><label class="form-label">الإيميل</label><input type="email" name="email" class="form-control" required></div>
                    <div class="mb-3"><label class="form-label">كلمة المرور</label><input type="password" name="password" class="form-control" required></div>
                    <div class="mb-3"><label class="form-label">الدور</label>
                        <select name="role" class="form-select">
                            <option value="admin">Admin</option>
                            <option value="moderator">Moderator</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">إلغاء</button>
                    <button type="submit" class="btn btn-primary">إضافة</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Edit Modal -->
<div class="modal fade" id="editModal">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="POST">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="id" id="edit_id">
                <div class="modal-header">
                    <h5 class="modal-title">تعديل بيانات المشرف</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">الاسم</label>
                        <input type="text" name="name" id="edit_name" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">البريد الإلكتروني</label>
                        <input type="email" name="email" id="edit_email" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">كلمة المرور الجديدة</label>
                        <input type="password" name="password" id="edit_password" class="form-control" minlength="6">
                        <small class="text-muted">اتركه فارغاً إذا لم ترد تغيير كلمة المرور</small>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">الدور</label>
                        <select name="role" id="edit_role" class="form-select">
                            <option value="super_admin">Super Admin</option>
                            <option value="admin">Admin</option>
                            <option value="moderator">Moderator</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">إلغاء</button>
                    <button type="submit" class="btn btn-primary">حفظ التغييرات</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
function editAdmin(admin) {
    document.getElementById('edit_id').value = admin.id;
    document.getElementById('edit_name').value = admin.name;
    document.getElementById('edit_email').value = admin.email;
    document.getElementById('edit_role').value = admin.role;
    document.getElementById('edit_password').value = '';
    
    new bootstrap.Modal(document.getElementById('editModal')).show();
}
</script>

<?php include 'includes/footer.php'; ?>
