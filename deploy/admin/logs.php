<?php
session_start();
require_once __DIR__ . '/../backend/config/database.php';

if (!isset($_SESSION['admin_id'])) {
    header('Location: login.php');
    exit;
}

$db = Database::getInstance();

$logs = $db->fetchAll("
    SELECT l.*, a.name as admin_name 
    FROM audit_logs l 
    LEFT JOIN admin_users a ON l.admin_id = a.id 
    ORDER BY l.created_at DESC 
    LIMIT 100
");

include 'includes/header.php';
?>

<div class="container-fluid py-4">
    <h1 class="h3 mb-4">سجل العمليات</h1>

    <div class="card">
        <div class="card-body p-0">
            <table class="table table-hover mb-0">
                <thead><tr><th>التاريخ</th><th>المشرف</th><th>العملية</th><th>النوع</th><th>ID</th><th>IP</th></tr></thead>
                <tbody>
                    <?php foreach ($logs as $log): ?>
                    <tr>
                        <td><?= date('Y/m/d H:i', strtotime($log['created_at'])) ?></td>
                        <td><?= htmlspecialchars($log['admin_name'] ?? 'System') ?></td>
                        <td><span class="badge bg-info"><?= $log['action'] ?></span></td>
                        <td><?= $log['entity_type'] ?></td>
                        <td><?= $log['entity_id'] ?></td>
                        <td><small class="text-muted"><?= $log['ip_address'] ?></small></td>
                    </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>
</div>

<?php include 'includes/footer.php'; ?>
