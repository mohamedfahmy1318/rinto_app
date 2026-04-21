<?php
/**
 * سكربت إعداد قاعدة البيانات الكامل
 * Run: http://localhost/rento_go/backend/database/setup.php
 */

header('Content-Type: text/html; charset=utf-8');

echo "<!DOCTYPE html><html dir='rtl'><head><meta charset='utf-8'><title>إعداد قاعدة البيانات</title></head><body style='font-family: Arial; padding: 20px;'>";
echo "<h1>🚀 إعداد قاعدة البيانات - Rento Go</h1>";

$host = 'localhost';
$username = 'root';
$password = 'Naseem@123';
$dbname = 'rento_go';

try {
    $pdo = new PDO("mysql:host={$host}", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->exec("SET NAMES utf8mb4");
    
    echo "<p>📁 إنشاء قاعدة البيانات...</p>";
    $pdo->exec("DROP DATABASE IF EXISTS `{$dbname}`");
    $pdo->exec("CREATE DATABASE `{$dbname}` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
    $pdo->exec("USE `{$dbname}`");
    echo "<p style='color: green;'>✅ تم إنشاء قاعدة البيانات</p>";
    
    // تشغيل schema.sql مباشرة
    echo "<h2>📋 إنشاء الجداول...</h2>";
    $schemaFile = __DIR__ . '/schema.sql';
    $schema = file_get_contents($schemaFile);
    
    // إزالة التعليقات
    $schema = preg_replace('/--.*$/m', '', $schema);
    $schema = preg_replace('/\/\*.*?\*\//s', '', $schema);
    
    // تنفيذ multi-query
    $pdo->exec("SET FOREIGN_KEY_CHECKS = 0");
    
    // تقسيم على أساس ; مع مراعاة أنها ليست داخل نص
    $statements = array_filter(array_map('trim', preg_split('/;(?=(?:[^\']*\'[^\']*\')*[^\']*$)/', $schema)));
    
    $tableCount = 0;
    foreach ($statements as $stmt) {
        if (empty($stmt)) continue;
        if (preg_match('/^(SET|USE|CREATE DATABASE)/i', $stmt)) continue;
        
        try {
            $pdo->exec($stmt);
            if (stripos($stmt, 'CREATE TABLE') !== false) {
                if (preg_match('/CREATE TABLE\s+`?(\w+)`?/i', $stmt, $m)) {
                    echo "<p style='color: green; margin: 2px 0;'>✅ {$m[1]}</p>";
                    $tableCount++;
                }
            }
        } catch (PDOException $e) {
            if (strpos($e->getMessage(), 'already exists') === false) {
                echo "<p style='color: red; font-size: 11px;'>❌ خطأ: " . htmlspecialchars($e->getMessage()) . "</p>";
            }
        }
    }
    
    $pdo->exec("SET FOREIGN_KEY_CHECKS = 1");
    echo "<p><strong>تم إنشاء {$tableCount} جدول</strong></p>";
    
    // تشغيل seed_data.sql
    echo "<h2>🌱 إدخال البيانات الوهمية...</h2>";
    $seedFile = __DIR__ . '/seed_data.sql';
    $seed = file_get_contents($seedFile);
    $seed = preg_replace('/--.*$/m', '', $seed);
    
    $seedStatements = array_filter(array_map('trim', preg_split('/;(?=(?:[^\']*\'[^\']*\')*[^\']*$)/', $seed)));
    
    $insertCount = 0;
    foreach ($seedStatements as $stmt) {
        if (empty($stmt)) continue;
        if (preg_match('/^SELECT/i', $stmt)) continue;
        
        try {
            $pdo->exec($stmt);
            if (stripos($stmt, 'INSERT') !== false) $insertCount++;
        } catch (PDOException $e) {
            if (stripos($stmt, 'DELETE') === false && stripos($stmt, 'ALTER') === false) {
                echo "<p style='color: orange; font-size: 11px;'>⚠️ " . htmlspecialchars($e->getMessage()) . "</p>";
            }
        }
    }
    echo "<p><strong>تم تنفيذ {$insertCount} عملية إدخال</strong></p>";
    
    // إحصائيات
    echo "<div style='background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;'>";
    echo "<h2>✅ تم الإعداد بنجاح!</h2>";
    echo "<h3>📊 الإحصائيات:</h3><ul>";
    
    $tables = ['users', 'admin_users', 'properties', 'cars', 'property_media', 'car_media', 'favorites', 'regions', 'cities', 'plans'];
    foreach ($tables as $table) {
        try {
            $count = $pdo->query("SELECT COUNT(*) FROM `{$table}`")->fetchColumn();
            echo "<li><strong>{$table}:</strong> {$count} سجل</li>";
        } catch (Exception $e) {
            echo "<li style='color:red;'><strong>{$table}:</strong> غير موجود</li>";
        }
    }
    echo "</ul></div>";
    
    // بيانات الدخول
    echo "<div style='background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;'>";
    echo "<h3>🔑 بيانات تسجيل الدخول:</h3>";
    echo "<table border='1' cellpadding='10' style='border-collapse: collapse;'>";
    echo "<tr><th>Email</th><th>Password</th><th>النوع</th></tr>";
    echo "<tr><td>ahmed@test.com</td><td>password</td><td>مستأجر</td></tr>";
    echo "<tr><td>abdullah@test.com</td><td>password</td><td>مالك عقار</td></tr>";
    echo "<tr><td>yousef@test.com</td><td>password</td><td>مؤجر سيارات</td></tr>";
    echo "<tr><td>amana@test.com</td><td>password</td><td>مكتب عقاري</td></tr>";
    echo "<tr style='background: #fff3e0;'><td>admin@rentogo.com</td><td>password</td><td>مدير النظام</td></tr>";
    echo "</table></div>";
    
    echo "<p><a href='/rento_go/admin' style='padding: 10px 20px; background: #1976d2; color: white; text-decoration: none; border-radius: 5px; margin-left: 10px;'>لوحة التحكم</a> ";
    echo "<a href='/rento_go/backend/api/properties' style='padding: 10px 20px; background: #388e3c; color: white; text-decoration: none; border-radius: 5px;'>اختبار API</a></p>";
    
} catch (Exception $e) {
    echo "<div style='color: red; background: #ffebee; padding: 20px; border-radius: 10px;'>";
    echo "<h2>❌ خطأ!</h2>";
    echo "<p>" . htmlspecialchars($e->getMessage()) . "</p>";
    echo "</div>";
}

echo "</body></html>";
