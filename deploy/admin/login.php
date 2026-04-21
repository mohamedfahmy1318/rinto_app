<?php
session_start();

require_once __DIR__ . '/../backend/config/database.php';

$error = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';
    
    if ($email && $password) {
        $db = Database::getInstance();
        $admin = $db->fetch("SELECT * FROM admin_users WHERE email = ? AND is_active = 1", [$email]);
        
        if ($admin && password_verify($password, $admin['password'])) {
            $_SESSION['admin_id'] = $admin['id'];
            $_SESSION['admin_name'] = $admin['name'];
            $_SESSION['admin_role'] = $admin['role'];
            
            $db->update('admin_users', ['last_login' => date('Y-m-d H:i:s')], 'id = ?', [$admin['id']]);
            
            header('Location: index.php');
            exit;
        } else {
            $error = 'بيانات الدخول غير صحيحة';
        }
    } else {
        $error = 'يرجى إدخال البريد الإلكتروني وكلمة المرور';
    }
}

if (isset($_SESSION['admin_id'])) {
    header('Location: index.php');
    exit;
}
?>
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>تسجيل الدخول - Rento Go Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.rtl.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        :root {
            --teal: #00bcd4;
            --dark-bg: #1a1a2e;
        }
        body {
            background: linear-gradient(135deg, var(--dark-bg) 0%, #16213e 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .login-card {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            overflow: hidden;
            max-width: 400px;
            width: 100%;
        }
        .login-header {
            background: linear-gradient(135deg, var(--teal), #0097a7);
            padding: 2rem;
            text-align: center;
            color: white;
        }
        .login-header h1 {
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }
        .login-body {
            padding: 2rem;
        }
        .form-control:focus {
            border-color: var(--teal);
            box-shadow: 0 0 0 0.2rem rgba(0, 188, 212, 0.25);
        }
        .btn-primary {
            background: var(--teal);
            border-color: var(--teal);
        }
        .btn-primary:hover {
            background: #0097a7;
            border-color: #0097a7;
        }
    </style>
</head>
<body>
    <div class="login-card">
        <div class="login-header">
            <h1><i class="bi bi-building"></i> Rento Go</h1>
            <p class="mb-0">لوحة التحكم</p>
        </div>
        <div class="login-body">
            <?php if ($error): ?>
            <div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
            <?php endif; ?>
            
            <form method="POST" action="">
                <div class="mb-3">
                    <label for="email" class="form-label">البريد الإلكتروني</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                        <input type="email" class="form-control" id="email" name="email" required 
                               value="<?= htmlspecialchars($_POST['email'] ?? '') ?>">
                    </div>
                </div>
                <div class="mb-4">
                    <label for="password" class="form-label">كلمة المرور</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-lock"></i></span>
                        <input type="password" class="form-control" id="password" name="password" required>
                    </div>
                </div>
                <button type="submit" class="btn btn-primary w-100 py-2">
                    <i class="bi bi-box-arrow-in-left me-2"></i>
                    تسجيل الدخول
                </button>
            </form>
            
            <div class="text-center mt-4 text-muted small">
                <p class="mb-1">بيانات الدخول الافتراضية:</p>
                <code>admin@rentogo.com / password</code>
            </div>
        </div>
    </div>
</body>
</html>
