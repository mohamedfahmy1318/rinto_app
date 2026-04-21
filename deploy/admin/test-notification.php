<?php
/**
 * Test Push Notification - للتشخيص فقط
 * استخدم: /admin/test-notification.php?user_id=X
 */
session_start();
require_once __DIR__ . '/../backend/config/database.php';
require_once __DIR__ . '/../backend/config/constants.php';
require_once __DIR__ . '/../backend/helpers/FCM.php';

if (!isset($_SESSION['admin_id'])) {
    die('غير مصرح');
}

$db = Database::getInstance();

$userId = (int)($_GET['user_id'] ?? 0);

if (!$userId) {
    // Show all users with FCM tokens
    $users = $db->fetchAll("SELECT id, name, phone, fcm_token, preferred_language FROM users WHERE fcm_token IS NOT NULL AND fcm_token != '' LIMIT 20");
    
    echo "<h2>المستخدمين الذين لديهم FCM Token:</h2>";
    echo "<table border='1' cellpadding='10'>";
    echo "<tr><th>ID</th><th>الاسم</th><th>الهاتف</th><th>اللغة</th><th>Token (أول 50 حرف)</th><th>اختبار</th></tr>";
    
    foreach ($users as $user) {
        $tokenPreview = substr($user['fcm_token'], 0, 50) . '...';
        echo "<tr>";
        echo "<td>{$user['id']}</td>";
        echo "<td>{$user['name']}</td>";
        echo "<td>{$user['phone']}</td>";
        echo "<td>{$user['preferred_language']}</td>";
        echo "<td style='font-size:10px'>{$tokenPreview}</td>";
        echo "<td><a href='?user_id={$user['id']}'>إرسال اختبار</a></td>";
        echo "</tr>";
    }
    echo "</table>";
    
    // Show users without tokens
    $noTokenUsers = $db->fetchAll("SELECT id, name, phone FROM users WHERE fcm_token IS NULL OR fcm_token = '' LIMIT 10");
    if (!empty($noTokenUsers)) {
        echo "<h2>المستخدمين بدون FCM Token:</h2>";
        echo "<ul>";
        foreach ($noTokenUsers as $user) {
            echo "<li>{$user['name']} ({$user['phone']}) - ID: {$user['id']}</li>";
        }
        echo "</ul>";
    }
    
    exit;
}

// Send test notification
$user = $db->fetch("SELECT id, name, fcm_token, preferred_language FROM users WHERE id = ?", [$userId]);

if (!$user) {
    die("المستخدم غير موجود");
}

if (empty($user['fcm_token'])) {
    die("المستخدم ليس لديه FCM Token محفوظ. يجب أن يسجل دخول من التطبيق أولاً.");
}

echo "<h2>إرسال إشعار اختبار للمستخدم: {$user['name']}</h2>";
echo "<p>FCM Token: " . substr($user['fcm_token'], 0, 80) . "...</p>";

$result = FCM::sendToToken(
    $user['fcm_token'],
    'إشعار اختبار 🔔',
    'هذا إشعار تجريبي من لوحة التحكم',
    ['type' => 'test', 'timestamp' => time()]
);

echo "<h3>نتيجة الإرسال:</h3>";
echo "<pre>" . print_r($result, true) . "</pre>";

if ($result['success']) {
    echo "<p style='color:green; font-weight:bold'>✅ تم إرسال الإشعار بنجاح!</p>";
} else {
    echo "<p style='color:red; font-weight:bold'>❌ فشل إرسال الإشعار</p>";
    echo "<p>الخطأ: " . ($result['error'] ?? 'غير معروف') . "</p>";
}

echo "<p><a href='test-notification.php'>العودة للقائمة</a></p>";
