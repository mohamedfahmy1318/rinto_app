<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>لوحة التحكم - Rento Go</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.rtl.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        :root {
            --teal: #00bcd4;
            --teal-dark: #0097a7;
            --dark-bg: #1a1a2e;
            --sidebar-width: 260px;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f6fa;
        }
        .sidebar {
            position: fixed;
            top: 0;
            right: 0;
            width: var(--sidebar-width);
            height: 100vh;
            background: var(--dark-bg);
            padding-top: 0;
            z-index: 1000;
            overflow-y: auto;
        }
        .sidebar-header {
            background: linear-gradient(135deg, var(--teal), var(--teal-dark));
            padding: 1.5rem;
            text-align: center;
            color: white;
        }
        .sidebar-header h4 {
            margin: 0;
            font-weight: bold;
        }
        .sidebar-menu {
            padding: 1rem 0;
        }
        .sidebar-menu a {
            display: flex;
            align-items: center;
            padding: 0.8rem 1.5rem;
            color: rgba(255,255,255,0.7);
            text-decoration: none;
            transition: all 0.3s;
        }
        .sidebar-menu a:hover, .sidebar-menu a.active {
            background: rgba(0, 188, 212, 0.2);
            color: var(--teal);
        }
        .sidebar-menu a i {
            margin-left: 0.75rem;
            font-size: 1.1rem;
        }
        .sidebar-menu .menu-header {
            padding: 1rem 1.5rem 0.5rem;
            font-size: 0.75rem;
            text-transform: uppercase;
            color: rgba(255,255,255,0.4);
            letter-spacing: 1px;
        }
        .main-content {
            margin-right: var(--sidebar-width);
            min-height: 100vh;
        }
        .top-navbar {
            background: white;
            padding: 1rem 1.5rem;
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .card {
            border: none;
            border-radius: 15px;
            box-shadow: 0 5px 20px rgba(0,0,0,0.05);
        }
        .card-header {
            background: white;
            border-bottom: 1px solid #eee;
            padding: 1rem 1.5rem;
        }
        .btn-primary {
            background: var(--teal);
            border-color: var(--teal);
        }
        .btn-primary:hover {
            background: var(--teal-dark);
            border-color: var(--teal-dark);
        }
        .badge-status-active { background: #28a745; }
        .badge-status-pending_admin_review { background: #ffc107; color: #000; }
        .badge-status-rejected { background: #dc3545; }
        .badge-status-expired { background: #6c757d; }
        .badge-status-paused { background: #17a2b8; }
        .badge-status-draft { background: #6c757d; }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <div class="sidebar">
        <div class="sidebar-header">
            <h4><i class="bi bi-building me-2"></i>Rento Go</h4>
            <small>لوحة التحكم</small>
        </div>
        <div class="sidebar-menu">
            <a href="index.php" class="<?= basename($_SERVER['PHP_SELF']) == 'index.php' ? 'active' : '' ?>">
                <i class="bi bi-speedometer2"></i> الرئيسية
            </a>
            
            <div class="menu-header">إدارة المحتوى</div>
            <a href="listings.php" class="<?= basename($_SERVER['PHP_SELF']) == 'listings.php' ? 'active' : '' ?>">
                <i class="bi bi-list-ul"></i> الإعلانات
            </a>
            <a href="banners.php" class="<?= basename($_SERVER['PHP_SELF']) == 'banners.php' ? 'active' : '' ?>">
                <i class="bi bi-megaphone"></i> البانرات الإعلانية
            </a>
            <a href="users.php" class="<?= basename($_SERVER['PHP_SELF']) == 'users.php' ? 'active' : '' ?>">
                <i class="bi bi-people"></i> المستخدمين
            </a>
            <a href="reports.php" class="<?= basename($_SERVER['PHP_SELF']) == 'reports.php' ? 'active' : '' ?>">
                <i class="bi bi-flag"></i> البلاغات
                <?php
                $db = Database::getInstance();
                $pendingReports = $db->fetch("SELECT COUNT(*) as count FROM reports WHERE status = 'pending'");
                if ($pendingReports && $pendingReports['count'] > 0):
                ?>
                <span class="badge bg-danger rounded-pill float-start"><?= $pendingReports['count'] ?></span>
                <?php endif; ?>
            </a>
            
            <div class="menu-header">الإعدادات</div>
            <a href="listing-types.php" class="<?= basename($_SERVER['PHP_SELF']) == 'listing-types.php' ? 'active' : '' ?>">
                <i class="bi bi-tags"></i> التصنيفات
            </a>
            <a href="plans.php" class="<?= basename($_SERVER['PHP_SELF']) == 'plans.php' ? 'active' : '' ?>">
                <i class="bi bi-credit-card"></i> الباقات والأسعار
            </a>
            <a href="regions.php" class="<?= basename($_SERVER['PHP_SELF']) == 'regions.php' ? 'active' : '' ?>">
                <i class="bi bi-geo-alt"></i> المناطق والمدن
            </a>
            <a href="pages.php" class="<?= basename($_SERVER['PHP_SELF']) == 'pages.php' ? 'active' : '' ?>">
                <i class="bi bi-file-text"></i> المحتوى والإعدادات
            </a>
            
            <div class="menu-header">المالية</div>
            <a href="subscriptions.php" class="<?= basename($_SERVER['PHP_SELF']) == 'subscriptions.php' ? 'active' : '' ?>">
                <i class="bi bi-card-checklist"></i> طلبات الاشتراك
            </a>
            <a href="payments.php" class="<?= basename($_SERVER['PHP_SELF']) == 'payments.php' ? 'active' : '' ?>">
                <i class="bi bi-wallet2"></i> المدفوعات
            </a>
            <a href="payment-settings.php" class="<?= basename($_SERVER['PHP_SELF']) == 'payment-settings.php' ? 'active' : '' ?>">
                <i class="bi bi-credit-card-2-front"></i> إعدادات الدفع
            </a>
            <a href="iap-settings.php" class="<?= basename($_SERVER['PHP_SELF']) == 'iap-settings.php' ? 'active' : '' ?>">
                <i class="bi bi-phone"></i> الدفع داخل التطبيق
            </a>
            <a href="stats.php" class="<?= basename($_SERVER['PHP_SELF']) == 'stats.php' ? 'active' : '' ?>">
                <i class="bi bi-graph-up"></i> التقارير
            </a>
            
            <div class="menu-header">النظام</div>
            <a href="send-notification.php" class="<?= basename($_SERVER['PHP_SELF']) == 'send-notification.php' ? 'active' : '' ?>">
                <i class="bi bi-bell"></i> إرسال إشعارات
            </a>
            <a href="admins.php" class="<?= basename($_SERVER['PHP_SELF']) == 'admins.php' ? 'active' : '' ?>">
                <i class="bi bi-person-badge"></i> المشرفين
            </a>
            <a href="logs.php" class="<?= basename($_SERVER['PHP_SELF']) == 'logs.php' ? 'active' : '' ?>">
                <i class="bi bi-clock-history"></i> سجل العمليات
            </a>
        </div>
    </div>

    <!-- Main Content -->
    <div class="main-content">
        <div class="top-navbar">
            <div>
                <span class="text-muted">مرحباً،</span>
                <strong><?= htmlspecialchars($_SESSION['admin_name'] ?? 'Admin') ?></strong>
            </div>
            <div>
                <a href="logout.php" class="btn btn-outline-danger btn-sm">
                    <i class="bi bi-box-arrow-left me-1"></i>
                    تسجيل الخروج
                </a>
            </div>
        </div>
