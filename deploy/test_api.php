<?php
/**
 * API Test Script - احذف هذا الملف بعد التأكد من عمل الموقع
 */

header('Content-Type: text/html; charset=utf-8');

echo "<h1>اختبار API</h1>";

// Test 1: Check if API URL is accessible
$apiUrl = 'https://rento-go.com/backend/api/properties';
echo "<h2>1. اختبار الاتصال بالـ API</h2>";
echo "<p>URL: $apiUrl</p>";

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $apiUrl);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 30);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
$error = curl_error($ch);
curl_close($ch);

echo "<p><strong>HTTP Code:</strong> $httpCode</p>";

if ($error) {
    echo "<p style='color:red;'><strong>Error:</strong> $error</p>";
} else {
    echo "<p style='color:green;'>✓ الاتصال ناجح</p>";
    
    $data = json_decode($response, true);
    if ($data) {
        echo "<h3>البيانات المستلمة:</h3>";
        echo "<pre style='background:#f5f5f5;padding:10px;direction:ltr;'>";
        print_r($data);
        echo "</pre>";
    } else {
        echo "<p style='color:red;'>لم يتم استلام بيانات JSON صالحة</p>";
        echo "<p>الاستجابة الخام:</p>";
        echo "<pre style='background:#f5f5f5;padding:10px;direction:ltr;'>" . htmlspecialchars($response) . "</pre>";
    }
}

// Test 2: Direct database check
echo "<h2>2. اختبار قاعدة البيانات مباشرة</h2>";

try {
    require_once __DIR__ . '/backend/config/database.php';
    $db = Database::getInstance();
    
    // Count properties
    $props = $db->fetch("SELECT COUNT(*) as count FROM properties");
    echo "<p>عدد العقارات: <strong>" . ($props['count'] ?? 0) . "</strong></p>";
    
    // Count cars
    $cars = $db->fetch("SELECT COUNT(*) as count FROM cars");
    echo "<p>عدد السيارات: <strong>" . ($cars['count'] ?? 0) . "</strong></p>";
    
    // Count users
    $users = $db->fetch("SELECT COUNT(*) as count FROM users");
    echo "<p>عدد المستخدمين: <strong>" . ($users['count'] ?? 0) . "</strong></p>";
    
    // Show tables
    $tables = $db->fetchAll("SHOW TABLES");
    echo "<p>عدد الجداول: <strong>" . count($tables) . "</strong></p>";
    
    echo "<p style='color:green;'>✓ قاعدة البيانات تعمل</p>";
    
} catch (Exception $e) {
    echo "<p style='color:red;'><strong>خطأ في قاعدة البيانات:</strong> " . $e->getMessage() . "</p>";
}

echo "<hr><p><strong>ملاحظة:</strong> احذف هذا الملف (test_api.php) بعد التأكد من عمل الموقع!</p>";
?>
