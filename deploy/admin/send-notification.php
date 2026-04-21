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

// Handle form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    
    if ($action === 'send_to_user') {
        $userId = (int)($_POST['user_id'] ?? 0);
        $title = trim($_POST['title'] ?? '');
        $body = trim($_POST['body'] ?? '');
        
        if (!$userId || !$title || !$body) {
            $message = 'جميع الحقول مطلوبة';
            $messageType = 'danger';
        } else {
            // Check user exists and get FCM token
            $user = $db->fetch("SELECT id, name, fcm_token FROM users WHERE id = ?", [$userId]);
            if (!$user) {
                $message = 'المستخدم غير موجود';
                $messageType = 'danger';
            } else {
                // Send notification if FCM token exists
                if (!empty($user['fcm_token'])) {
                    $result = FCM::sendToToken($user['fcm_token'], $title, $body, [
                        'type' => 'admin_message',
                        'sent_by' => (string)$_SESSION['admin_id']
                    ]);
                } else {
                    $result = ['success' => false, 'error' => 'المستخدم ليس لديه FCM token (User ID: ' . $userId . ')'];
                }
                
                // Save to database
                $db->insert('notifications', [
                    'user_id' => $userId,
                    'title_ar' => $title,
                    'title_en' => $title,
                    'title_he' => $title,
                    'body_ar' => $body,
                    'body_en' => $body,
                    'body_he' => $body,
                    'type' => 'admin_message',
                    'data' => json_encode(['sent_by' => $_SESSION['admin_id']])
                ]);
                
                if ($result['success']) {
                    $message = 'تم إرسال الإشعار بنجاح إلى ' . htmlspecialchars($user['name']);
                    if (isset($result['data']['name'])) {
                        $message .= ' (Message: ' . $result['data']['name'] . ')';
                    }
                } else {
                    $errorMsg = is_array($result['error']) ? json_encode($result['error']) : ($result['error'] ?? 'Unknown error');
                    $message = 'خطأ في الإرسال: ' . $errorMsg;
                    if (isset($result['code'])) {
                        $message .= ' (Code: ' . $result['code'] . ')';
                    }
                    // Show full response for debugging
                    $message .= ' | Response: ' . json_encode($result);
                    $messageType = 'danger';
                }
            }
        }
    } elseif ($action === 'send_to_all') {
        $title = trim($_POST['title'] ?? '');
        $body = trim($_POST['body'] ?? '');
        
        if (!$title || !$body) {
            $message = 'العنوان والرسالة مطلوبان';
            $messageType = 'danger';
        } else {
            // Send to all via topic
            $result = FCM::sendToAll($title, $body, [
                'type' => 'broadcast',
                'sent_by' => (string)$_SESSION['admin_id']
            ]);
            
            // Save to all users
            $users = $db->fetchAll("SELECT id FROM users");
            foreach ($users as $user) {
                $db->insert('notifications', [
                    'user_id' => $user['id'],
                    'title_ar' => $title,
                    'title_en' => $title,
                    'title_he' => $title,
                    'body_ar' => $body,
                    'body_en' => $body,
                    'body_he' => $body,
                    'type' => 'broadcast',
                    'data' => json_encode(['sent_by' => $_SESSION['admin_id']])
                ]);
            }
            
            if ($result['success']) {
                $message = 'تم إرسال الإشعار لجميع المستخدمين';
            } else {
                $message = 'تم حفظ الإشعارات ولكن قد تكون هناك مشكلة في الإرسال';
                $messageType = 'warning';
            }
        }
    } elseif ($action === 'send_to_type') {
        $userType = $_POST['user_type'] ?? '';
        $title = trim($_POST['title'] ?? '');
        $body = trim($_POST['body'] ?? '');
        
        if (!$userType || !$title || !$body) {
            $message = 'جميع الحقول مطلوبة';
            $messageType = 'danger';
        } else {
            // Send to user type topic
            $result = FCM::sendToUserType($userType, $title, $body, [
                'type' => 'segment_message',
                'user_type' => $userType,
                'sent_by' => (string)$_SESSION['admin_id']
            ]);
            
            // Save to users of this type
            $users = $db->fetchAll("SELECT id FROM users WHERE user_type = ?", [$userType]);
            foreach ($users as $user) {
                $db->insert('notifications', [
                    'user_id' => $user['id'],
                    'title_ar' => $title,
                    'title_en' => $title,
                    'title_he' => $title,
                    'body_ar' => $body,
                    'body_en' => $body,
                    'body_he' => $body,
                    'type' => 'segment_message',
                    'data' => json_encode(['user_type' => $userType, 'sent_by' => $_SESSION['admin_id']])
                ]);
            }
            
            $typeName = USER_TYPES[$userType]['ar'] ?? $userType;
            if ($result['success']) {
                $message = "تم إرسال الإشعار لجميع المستخدمين من نوع: $typeName (" . count($users) . " مستخدم)";
            } else {
                $message = 'تم حفظ الإشعارات ولكن قد تكون هناك مشكلة في الإرسال';
                $messageType = 'warning';
            }
        }
    } elseif ($action === 'send_to_region') {
        $regionId = (int)($_POST['region_id'] ?? 0);
        $title = trim($_POST['title'] ?? '');
        $body = trim($_POST['body'] ?? '');
        
        if (!$regionId || !$title || !$body) {
            $message = 'جميع الحقول مطلوبة';
            $messageType = 'danger';
        } else {
            // Get region name
            $region = $db->fetch("SELECT name_ar FROM regions WHERE id = ?", [$regionId]);
            $regionName = $region['name_ar'] ?? 'المنطقة';
            
            // Get users in this region (from their listings or preferred region)
            $users = $db->fetchAll("
                SELECT DISTINCT u.id, u.fcm_token 
                FROM users u 
                WHERE u.id IN (
                    SELECT DISTINCT user_id FROM properties WHERE region_id = ?
                    UNION
                    SELECT DISTINCT user_id FROM cars WHERE region_id = ?
                )
                OR u.preferred_region_id = ?
            ", [$regionId, $regionId, $regionId]);
            
            $sentCount = 0;
            foreach ($users as $user) {
                // Send FCM if token exists
                if (!empty($user['fcm_token'])) {
                    FCM::sendToToken($user['fcm_token'], $title, $body, [
                        'type' => 'region_message',
                        'region_id' => (string)$regionId,
                        'sent_by' => (string)$_SESSION['admin_id']
                    ]);
                }
                
                // Save to database
                $db->insert('notifications', [
                    'user_id' => $user['id'],
                    'title_ar' => $title,
                    'title_en' => $title,
                    'title_he' => $title,
                    'body_ar' => $body,
                    'body_en' => $body,
                    'body_he' => $body,
                    'type' => 'region_message',
                    'data' => json_encode(['region_id' => $regionId, 'sent_by' => $_SESSION['admin_id']])
                ]);
                $sentCount++;
            }
            
            $message = "تم إرسال الإشعار لمستخدمي منطقة: $regionName ($sentCount مستخدم)";
        }
    } elseif ($action === 'send_to_city') {
        $cityId = (int)($_POST['city_id'] ?? 0);
        $title = trim($_POST['title'] ?? '');
        $body = trim($_POST['body'] ?? '');
        
        if (!$cityId || !$title || !$body) {
            $message = 'جميع الحقول مطلوبة';
            $messageType = 'danger';
        } else {
            // Get city name
            $city = $db->fetch("SELECT name_ar FROM cities WHERE id = ?", [$cityId]);
            $cityName = $city['name_ar'] ?? 'المدينة';
            
            // Get users in this city (from their listings or preferred city)
            $users = $db->fetchAll("
                SELECT DISTINCT u.id, u.fcm_token 
                FROM users u 
                WHERE u.id IN (
                    SELECT DISTINCT user_id FROM properties WHERE city_id = ?
                    UNION
                    SELECT DISTINCT user_id FROM cars WHERE city_id = ?
                )
                OR u.preferred_city_id = ?
            ", [$cityId, $cityId, $cityId]);
            
            $sentCount = 0;
            foreach ($users as $user) {
                // Send FCM if token exists
                if (!empty($user['fcm_token'])) {
                    FCM::sendToToken($user['fcm_token'], $title, $body, [
                        'type' => 'city_message',
                        'city_id' => (string)$cityId,
                        'sent_by' => (string)$_SESSION['admin_id']
                    ]);
                }
                
                // Save to database
                $db->insert('notifications', [
                    'user_id' => $user['id'],
                    'title_ar' => $title,
                    'title_en' => $title,
                    'title_he' => $title,
                    'body_ar' => $body,
                    'body_en' => $body,
                    'body_he' => $body,
                    'type' => 'city_message',
                    'data' => json_encode(['city_id' => $cityId, 'sent_by' => $_SESSION['admin_id']])
                ]);
                $sentCount++;
            }
            
            $message = "تم إرسال الإشعار لمستخدمي مدينة: $cityName ($sentCount مستخدم)";
        }
    }
}

// Get users for dropdown
$users = $db->fetchAll("SELECT id, name, phone, user_type FROM users ORDER BY name");

// Get regions and cities
$regions = $db->fetchAll("SELECT id, name_ar FROM regions ORDER BY name_ar");
$cities = $db->fetchAll("SELECT id, name_ar, region_id FROM cities ORDER BY name_ar");

// Get region/city user counts
$regionStats = $db->fetchAll("
    SELECT r.id, r.name_ar, COUNT(DISTINCT u.id) as user_count
    FROM regions r
    LEFT JOIN (
        SELECT DISTINCT user_id, region_id FROM properties
        UNION
        SELECT DISTINCT user_id, region_id FROM cars
    ) listings ON listings.region_id = r.id
    LEFT JOIN users u ON u.id = listings.user_id
    GROUP BY r.id, r.name_ar
");
$regionCounts = [];
foreach ($regionStats as $rs) {
    $regionCounts[$rs['id']] = $rs['user_count'];
}

$cityStats = $db->fetchAll("
    SELECT c.id, c.name_ar, COUNT(DISTINCT u.id) as user_count
    FROM cities c
    LEFT JOIN (
        SELECT DISTINCT user_id, city_id FROM properties
        UNION
        SELECT DISTINCT user_id, city_id FROM cars
    ) listings ON listings.city_id = c.id
    LEFT JOIN users u ON u.id = listings.user_id
    GROUP BY c.id, c.name_ar
");
$cityCounts = [];
foreach ($cityStats as $cs) {
    $cityCounts[$cs['id']] = $cs['user_count'];
}

// Get stats
$stats = [
    'total_users' => $db->fetch("SELECT COUNT(*) as count FROM users")['count'],
    'renters' => $db->fetch("SELECT COUNT(*) as count FROM users WHERE user_type = 'renter'")['count'],
    'owners' => $db->fetch("SELECT COUNT(*) as count FROM users WHERE user_type = 'owner'")['count'],
    'offices' => $db->fetch("SELECT COUNT(*) as count FROM users WHERE user_type = 'office'")['count'],
    'car_lessors' => $db->fetch("SELECT COUNT(*) as count FROM users WHERE user_type = 'car_lessor'")['count'],
];

include 'includes/header.php';
?>

<div class="container-fluid py-4">
    <div class="row mb-4">
        <div class="col-12">
            <h1 class="h3 mb-0">
                <i class="bi bi-bell me-2"></i>
                إرسال إشعارات
            </h1>
        </div>
    </div>

    <?php if ($message): ?>
    <div class="alert alert-<?= $messageType ?> alert-dismissible fade show" role="alert">
        <?= htmlspecialchars($message) ?>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <?php endif; ?>

    <!-- Stats -->
    <div class="row mb-4">
        <div class="col-md-2">
            <div class="card text-center">
                <div class="card-body">
                    <h5 class="text-muted">إجمالي</h5>
                    <h3><?= $stats['total_users'] ?></h3>
                </div>
            </div>
        </div>
        <div class="col-md-2">
            <div class="card text-center">
                <div class="card-body">
                    <h5 class="text-muted">مستأجرين</h5>
                    <h3><?= $stats['renters'] ?></h3>
                </div>
            </div>
        </div>
        <div class="col-md-2">
            <div class="card text-center">
                <div class="card-body">
                    <h5 class="text-muted">ملاك</h5>
                    <h3><?= $stats['owners'] ?></h3>
                </div>
            </div>
        </div>
        <div class="col-md-2">
            <div class="card text-center">
                <div class="card-body">
                    <h5 class="text-muted">مكاتب</h5>
                    <h3><?= $stats['offices'] ?></h3>
                </div>
            </div>
        </div>
        <div class="col-md-2">
            <div class="card text-center">
                <div class="card-body">
                    <h5 class="text-muted">مؤجري سيارات</h5>
                    <h3><?= $stats['car_lessors'] ?></h3>
                </div>
            </div>
        </div>
    </div>

    <div class="row g-4">
        <!-- Send to Specific User -->
        <div class="col-md-4">
            <div class="card h-100">
                <div class="card-header bg-primary text-white">
                    <h5 class="mb-0"><i class="bi bi-person me-2"></i>إرسال لمستخدم محدد</h5>
                </div>
                <div class="card-body">
                    <form method="POST">
                        <input type="hidden" name="action" value="send_to_user">
                        
                        <div class="mb-3">
                            <label class="form-label">اختر المستخدم</label>
                            <select name="user_id" class="form-select" required>
                                <option value="">-- اختر مستخدم --</option>
                                <?php foreach ($users as $user): ?>
                                <option value="<?= $user['id'] ?>">
                                    <?= htmlspecialchars($user['name']) ?> 
                                    (<?= $user['phone'] ?>) - 
                                    <?= USER_TYPES[$user['user_type']]['ar'] ?? $user['user_type'] ?>
                                </option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">عنوان الإشعار</label>
                            <input type="text" name="title" class="form-control" required 
                                   placeholder="مثال: رسالة مهمة">
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">نص الإشعار</label>
                            <textarea name="body" class="form-control" rows="3" required
                                      placeholder="اكتب نص الإشعار هنا..."></textarea>
                        </div>
                        
                        <button type="submit" class="btn btn-primary w-100">
                            <i class="bi bi-send me-1"></i> إرسال
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <!-- Send to User Type -->
        <div class="col-md-4">
            <div class="card h-100">
                <div class="card-header bg-info text-white">
                    <h5 class="mb-0"><i class="bi bi-people me-2"></i>إرسال لنوع مستخدمين</h5>
                </div>
                <div class="card-body">
                    <form method="POST">
                        <input type="hidden" name="action" value="send_to_type">
                        
                        <div class="mb-3">
                            <label class="form-label">نوع المستخدمين</label>
                            <select name="user_type" class="form-select" required>
                                <option value="">-- اختر النوع --</option>
                                <option value="renter">مستأجرين (<?= $stats['renters'] ?>)</option>
                                <option value="owner">ملاك عقارات (<?= $stats['owners'] ?>)</option>
                                <option value="office">مكاتب عقارية (<?= $stats['offices'] ?>)</option>
                                <option value="car_lessor">مؤجري سيارات (<?= $stats['car_lessors'] ?>)</option>
                            </select>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">عنوان الإشعار</label>
                            <input type="text" name="title" class="form-control" required
                                   placeholder="مثال: عرض خاص">
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">نص الإشعار</label>
                            <textarea name="body" class="form-control" rows="3" required
                                      placeholder="اكتب نص الإشعار هنا..."></textarea>
                        </div>
                        
                        <button type="submit" class="btn btn-info w-100">
                            <i class="bi bi-send me-1"></i> إرسال للمجموعة
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <!-- Send to All -->
        <div class="col-md-4">
            <div class="card h-100">
                <div class="card-header bg-success text-white">
                    <h5 class="mb-0"><i class="bi bi-broadcast me-2"></i>إرسال للجميع</h5>
                </div>
                <div class="card-body">
                    <form method="POST" onsubmit="return confirm('هل أنت متأكد من إرسال الإشعار لجميع المستخدمين؟');">
                        <input type="hidden" name="action" value="send_to_all">
                        
                        <div class="alert alert-warning">
                            <i class="bi bi-exclamation-triangle me-1"></i>
                            سيتم إرسال الإشعار لـ <strong><?= $stats['total_users'] ?></strong> مستخدم
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">عنوان الإشعار</label>
                            <input type="text" name="title" class="form-control" required
                                   placeholder="مثال: إعلان هام">
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">نص الإشعار</label>
                            <textarea name="body" class="form-control" rows="3" required
                                      placeholder="اكتب نص الإشعار هنا..."></textarea>
                        </div>
                        
                        <button type="submit" class="btn btn-success w-100">
                            <i class="bi bi-broadcast me-1"></i> إرسال للجميع
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Location Based Notifications -->
    <h4 class="mt-5 mb-3"><i class="bi bi-geo-alt me-2"></i>إرسال حسب الموقع</h4>
    <div class="row g-4">
        <!-- Send to Region -->
        <div class="col-md-6">
            <div class="card h-100">
                <div class="card-header bg-warning text-dark">
                    <h5 class="mb-0"><i class="bi bi-map me-2"></i>إرسال لمنطقة</h5>
                </div>
                <div class="card-body">
                    <form method="POST">
                        <input type="hidden" name="action" value="send_to_region">
                        
                        <div class="mb-3">
                            <label class="form-label">اختر المنطقة</label>
                            <select name="region_id" class="form-select" required>
                                <option value="">-- اختر المنطقة --</option>
                                <?php foreach ($regions as $region): ?>
                                <option value="<?= $region['id'] ?>">
                                    <?= htmlspecialchars($region['name_ar']) ?> 
                                    (<?= $regionCounts[$region['id']] ?? 0 ?> مستخدم)
                                </option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">عنوان الإشعار</label>
                            <input type="text" name="title" class="form-control" required
                                   placeholder="مثال: عروض خاصة لمنطقتك">
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">نص الإشعار</label>
                            <textarea name="body" class="form-control" rows="3" required
                                      placeholder="اكتب نص الإشعار هنا..."></textarea>
                        </div>
                        
                        <button type="submit" class="btn btn-warning w-100">
                            <i class="bi bi-send me-1"></i> إرسال للمنطقة
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <!-- Send to City -->
        <div class="col-md-6">
            <div class="card h-100">
                <div class="card-header bg-secondary text-white">
                    <h5 class="mb-0"><i class="bi bi-building me-2"></i>إرسال لمدينة</h5>
                </div>
                <div class="card-body">
                    <form method="POST">
                        <input type="hidden" name="action" value="send_to_city">
                        
                        <div class="mb-3">
                            <label class="form-label">اختر المنطقة أولاً</label>
                            <select id="regionFilter" class="form-select" onchange="filterCities()">
                                <option value="">-- كل المناطق --</option>
                                <?php foreach ($regions as $region): ?>
                                <option value="<?= $region['id'] ?>"><?= htmlspecialchars($region['name_ar']) ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">اختر المدينة</label>
                            <select name="city_id" id="citySelect" class="form-select" required>
                                <option value="">-- اختر المدينة --</option>
                                <?php foreach ($cities as $city): ?>
                                <option value="<?= $city['id'] ?>" data-region="<?= $city['region_id'] ?>">
                                    <?= htmlspecialchars($city['name_ar']) ?>
                                    (<?= $cityCounts[$city['id']] ?? 0 ?> مستخدم)
                                </option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">عنوان الإشعار</label>
                            <input type="text" name="title" class="form-control" required
                                   placeholder="مثال: إعلانات جديدة في مدينتك">
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label">نص الإشعار</label>
                            <textarea name="body" class="form-control" rows="3" required
                                      placeholder="اكتب نص الإشعار هنا..."></textarea>
                        </div>
                        
                        <button type="submit" class="btn btn-secondary w-100">
                            <i class="bi bi-send me-1"></i> إرسال للمدينة
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function filterCities() {
    const regionId = document.getElementById('regionFilter').value;
    const citySelect = document.getElementById('citySelect');
    const options = citySelect.querySelectorAll('option');
    
    options.forEach(option => {
        if (!option.value) return; // Skip the placeholder
        const optionRegion = option.getAttribute('data-region');
        if (!regionId || optionRegion === regionId) {
            option.style.display = '';
        } else {
            option.style.display = 'none';
        }
    });
    
    // Reset selection
    citySelect.value = '';
}
</script>

<?php include 'includes/footer.php'; ?>
