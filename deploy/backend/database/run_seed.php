<?php
/**
 * سكربت إدخال البيانات الوهمية
 * Run: http://localhost/rento_go/backend/database/run_seed.php
 */

header('Content-Type: text/html; charset=utf-8');

require_once __DIR__ . '/../config/database.php';

echo "<h1 style='font-family: Arial; direction: rtl;'>🚀 إدخال البيانات الوهمية - Rento Go</h1>";

try {
    $db = Database::getInstance();
    $conn = $db->getConnection();
    
    // قراءة ملف SQL
    $sqlFile = __DIR__ . '/seed.sql';
    
    if (!file_exists($sqlFile)) {
        throw new Exception("ملف seed.sql غير موجود!");
    }
    
    $sql = file_get_contents($sqlFile);
    
    // تقسيم الاستعلامات
    $statements = array_filter(
        array_map('trim', explode(';', $sql)),
        function($stmt) {
            return !empty($stmt) && 
                   strpos($stmt, '--') !== 0 && 
                   strpos($stmt, 'SELECT') !== 0;
        }
    );
    
    $successCount = 0;
    $errorCount = 0;
    
    foreach ($statements as $statement) {
        if (empty(trim($statement))) continue;
        
        try {
            $conn->exec($statement);
            $successCount++;
        } catch (PDOException $e) {
            // تجاهل أخطاء الحذف إذا كانت الجداول فارغة
            if (strpos($statement, 'DELETE') === false && strpos($statement, 'ALTER') === false) {
                echo "<p style='color: orange; direction: ltr; font-size: 12px;'>⚠️ " . htmlspecialchars(substr($statement, 0, 100)) . "...</p>";
                $errorCount++;
            }
        }
    }
    
    // عرض النتائج
    echo "<div style='font-family: Arial; direction: rtl; background: #e8f5e9; padding: 20px; border-radius: 10px; margin: 20px 0;'>";
    echo "<h2>✅ تم إدخال البيانات بنجاح!</h2>";
    echo "<p>عدد الاستعلامات المنفذة: <strong>{$successCount}</strong></p>";
    
    // إحصائيات
    $stats = [
        'المستخدمين' => $db->fetch("SELECT COUNT(*) as count FROM users")['count'],
        'العقارات' => $db->fetch("SELECT COUNT(*) as count FROM properties")['count'],
        'السيارات' => $db->fetch("SELECT COUNT(*) as count FROM cars")['count'],
        'الوسائط' => $db->fetch("SELECT COUNT(*) as count FROM media")['count'],
        'المفضلة' => $db->fetch("SELECT COUNT(*) as count FROM favorites")['count'],
    ];
    
    echo "<h3>📊 الإحصائيات:</h3>";
    echo "<ul>";
    foreach ($stats as $label => $count) {
        echo "<li><strong>{$label}:</strong> {$count}</li>";
    }
    echo "</ul>";
    echo "</div>";
    
    // معلومات تسجيل الدخول
    echo "<div style='font-family: Arial; direction: rtl; background: #e3f2fd; padding: 20px; border-radius: 10px; margin: 20px 0;'>";
    echo "<h3>🔑 بيانات تسجيل الدخول للاختبار:</h3>";
    echo "<table border='1' cellpadding='10' style='border-collapse: collapse; direction: ltr;'>";
    echo "<tr><th>Email</th><th>Password</th><th>Type</th></tr>";
    echo "<tr><td>ahmed@test.com</td><td>password</td><td>مستأجر (renter)</td></tr>";
    echo "<tr><td>abdullah@test.com</td><td>password</td><td>مالك عقار (owner)</td></tr>";
    echo "<tr><td>yousef@test.com</td><td>password</td><td>مؤجر سيارات (car_lessor)</td></tr>";
    echo "<tr><td>amana@test.com</td><td>password</td><td>مكتب عقاري (office)</td></tr>";
    echo "</table>";
    echo "<p><small>كلمة المرور لجميع الحسابات: <code>password</code></small></p>";
    echo "</div>";
    
    echo "<p><a href='/rento_go/admin' style='padding: 10px 20px; background: #1976d2; color: white; text-decoration: none; border-radius: 5px;'>الذهاب للوحة التحكم →</a></p>";
    
} catch (Exception $e) {
    echo "<div style='color: red; font-family: Arial;'>";
    echo "<h2>❌ خطأ!</h2>";
    echo "<p>" . htmlspecialchars($e->getMessage()) . "</p>";
    echo "</div>";
}
