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

$type = $_GET['type'] ?? 'property';
$id = (int)($_GET['id'] ?? 0);

if (!$id) {
    header('Location: listings.php');
    exit;
}

$table = $type === 'car' ? 'cars' : 'properties';
$mediaTable = $type === 'car' ? 'car_media' : 'property_media';
$foreignKey = $type === 'car' ? 'car_id' : 'property_id';

// Handle actions
$message = '';
$messageType = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';
    
    if ($action === 'approve') {
        $db->update($table, ['status' => 'active'], 'id = ?', [$id]);
        
        $listing = $db->fetch("SELECT user_id, city_id, region_id, title, subscription_id FROM $table WHERE id = ?", [$id]);
        NotificationController::send($listing['user_id'], 'listing_approved', [
            'listing_id' => $id,
            'listing_type' => $type
        ]);
        
        // Notify users in the same region about the new listing (if subscription allows)
        NotificationController::notifyNewListingInRegion(
            $listing['region_id'],
            $type,
            $id,
            $listing['title'],
            $listing['subscription_id'],
            $listing['user_id'] // Exclude the listing owner
        );
        
        // Notify users in the same city about the new listing (if subscription allows)
        NotificationController::notifyNewListingInCity(
            $listing['city_id'],
            $type,
            $id,
            $listing['title'],
            $listing['subscription_id'],
            $listing['user_id'] // Exclude the listing owner
        );
        
        // Log action
        $db->insert('audit_logs', [
            'admin_id' => $_SESSION['admin_id'],
            'action' => 'approve_listing',
            'entity_type' => $table,
            'entity_id' => $id,
            'ip_address' => $_SERVER['REMOTE_ADDR']
        ]);
        
        $message = 'تم نشر الإعلان بنجاح';
        $messageType = 'success';
        
    } elseif ($action === 'pause') {
        $db->update($table, ['status' => 'paused'], 'id = ?', [$id]);
        
        // Log action
        $db->insert('audit_logs', [
            'admin_id' => $_SESSION['admin_id'],
            'action' => 'pause_listing',
            'entity_type' => $table,
            'entity_id' => $id,
            'ip_address' => $_SERVER['REMOTE_ADDR']
        ]);
        
        $message = 'تم إيقاف الإعلان';
        $messageType = 'warning';
        
    } elseif ($action === 'reject') {
        $reason = $_POST['reject_reason'] ?? '';
        
        if (empty($reason)) {
            $message = 'يجب إدخال سبب الرفض';
            $messageType = 'danger';
        } else {
            $db->update($table, [
                'status' => 'rejected',
                'reject_reason' => $reason
            ], 'id = ?', [$id]);
            
            $listing = $db->fetch("SELECT user_id FROM $table WHERE id = ?", [$id]);
            NotificationController::send($listing['user_id'], 'listing_rejected', [
                'listing_id' => $id,
                'listing_type' => $type,
                'reason' => $reason
            ]);
            
            // Log action
            $db->insert('audit_logs', [
                'admin_id' => $_SESSION['admin_id'],
                'action' => 'reject_listing',
                'entity_type' => $table,
                'entity_id' => $id,
                'new_data' => json_encode(['reason' => $reason]),
                'ip_address' => $_SERVER['REMOTE_ADDR']
            ]);
            
            $message = 'تم رفض الإعلان';
            $messageType = 'warning';
        }
    }
}

// Get listing data
$sql = "SELECT l.*, u.id as user_id, u.name as user_name, u.email as user_email, u.phone as user_phone,
               u.user_type, u.is_trusted, u.company_name,
               r.name_ar as region_name, c.name_ar as city_name,
               p.name_ar as plan_name_ar, p.name_en as plan_name_en
        FROM $table l
        LEFT JOIN users u ON l.user_id = u.id
        LEFT JOIN regions r ON l.region_id = r.id
        LEFT JOIN cities c ON l.city_id = c.id
        LEFT JOIN subscriptions s ON l.subscription_id = s.id
        LEFT JOIN plans p ON s.plan_id = p.id
        WHERE l.id = ?";

$listing = $db->fetch($sql, [$id]);

if (!$listing) {
    header('Location: listings.php');
    exit;
}

// Get media
$media = $db->fetchAll("SELECT * FROM $mediaTable WHERE $foreignKey = ? ORDER BY sort_order", [$id]);

$statusLabels = [
    'draft' => 'مسودة',
    'pending_payment' => 'بانتظار الدفع',
    'pending_admin_review' => 'بانتظار المراجعة',
    'active' => 'نشط',
    'expired' => 'منتهي',
    'paused' => 'متوقف',
    'rejected' => 'مرفوض'
];

include 'includes/header.php';
?>

<div class="container-fluid py-4">
    <div class="row mb-4">
        <div class="col-12">
            <a href="listings.php" class="btn btn-outline-secondary mb-3">
                <i class="bi bi-arrow-right me-1"></i> العودة للقائمة
            </a>
            
            <!-- Listing Title Header -->
            <div class="listing-title-header">
                <div class="d-flex justify-content-between align-items-start">
                    <div>
                        <span class="badge bg-light text-dark mb-2">
                            <?= $type === 'car' ? '<i class="bi bi-car-front me-1"></i> سيارة' : '<i class="bi bi-building me-1"></i> عقار' ?> #<?= $id ?>
                        </span>
                        <h2 class="mb-1"><?= htmlspecialchars($listing['title'] ?? ($type === 'car' ? 'سيارة للإيجار' : 'عقار للإيجار')) ?></h2>
                        <p class="mb-0 opacity-75">
                            <i class="bi bi-geo-alt me-1"></i>
                            <?= htmlspecialchars($listing['city_name'] ?? '') ?> - <?= htmlspecialchars($listing['region_name'] ?? '') ?>
                        </p>
                    </div>
                    <div class="text-end">
                        <span class="badge badge-status-<?= $listing['status'] ?> fs-6 px-3 py-2">
                            <?= $statusLabels[$listing['status']] ?>
                        </span>
                        <div class="mt-2">
                            <span class="badge bg-light text-dark">
                                <i class="bi bi-eye me-1"></i> <?= number_format($listing['views_count']) ?> مشاهدة
                            </span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <?php if ($message): ?>
    <div class="alert alert-<?= $messageType ?> alert-dismissible fade show" role="alert">
        <i class="bi bi-<?= $messageType === 'success' ? 'check-circle' : ($messageType === 'danger' ? 'x-circle' : 'exclamation-triangle') ?> me-2"></i>
        <?= htmlspecialchars($message) ?>
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
    <?php endif; ?>

    <div class="row g-4">
        <!-- Main Info -->
        <div class="col-md-8">
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0"><i class="bi bi-info-circle me-2"></i>تفاصيل الإعلان</h5>
                </div>
                <div class="card-body">
                    <div class="row g-3">
                        <?php if ($type === 'property'): ?>
                        <div class="col-md-6">
                            <label class="text-muted small">نوع العقار</label>
                            <p class="mb-0 fw-bold"><?= PROPERTY_TYPES[$listing['property_type']]['ar'] ?? $listing['property_type'] ?></p>
                        </div>
                        <?php else: ?>
                        <div class="col-md-6">
                            <label class="text-muted small">نوع الاستخدام</label>
                            <p class="mb-0 fw-bold"><?= CAR_USAGE_TYPES[$listing['usage_type']]['ar'] ?? $listing['usage_type'] ?></p>
                        </div>
                        <div class="col-md-6">
                            <label class="text-muted small">الموديل</label>
                            <p class="mb-0 fw-bold"><?= htmlspecialchars($listing['model'] ?? '') ?></p>
                        </div>
                        <?php endif; ?>
                        
                        <div class="col-md-6">
                            <label class="text-muted small">المنطقة</label>
                            <p class="mb-0"><?= htmlspecialchars($listing['region_name'] ?? '') ?> - <?= htmlspecialchars($listing['city_name'] ?? '') ?></p>
                        </div>
                        
                        <div class="col-md-6">
                            <label class="text-muted small">السعر</label>
                            <?php if (!empty($listing['price_daily']) || !empty($listing['price_weekly']) || !empty($listing['price_monthly'])): ?>
                            <div class="d-flex gap-3">
                                <?php if (!empty($listing['price_daily'])): ?>
                                <div class="text-center">
                                    <span class="fw-bold text-success"><?= number_format($listing['price_daily']) ?> ₪</span>
                                    <br><small class="text-muted">يومي</small>
                                </div>
                                <?php endif; ?>
                                <?php if (!empty($listing['price_weekly'])): ?>
                                <div class="text-center">
                                    <span class="fw-bold text-success"><?= number_format($listing['price_weekly']) ?> ₪</span>
                                    <br><small class="text-muted">أسبوعي</small>
                                </div>
                                <?php endif; ?>
                                <?php if (!empty($listing['price_monthly'])): ?>
                                <div class="text-center">
                                    <span class="fw-bold text-success"><?= number_format($listing['price_monthly']) ?> ₪</span>
                                    <br><small class="text-muted">شهري</small>
                                </div>
                                <?php endif; ?>
                            </div>
                            <?php else: ?>
                            <p class="mb-0 fw-bold text-success">
                                <?php if ($listing['price_type'] === 'negotiable'): ?>
                                    قابل للتفاوض
                                <?php elseif ($listing['price_type'] === 'range'): ?>
                                    <?= number_format($listing['price_from']) ?> - <?= number_format($listing['price_to']) ?> ₪
                                <?php else: ?>
                                    <?= number_format($listing['price']) ?> ₪
                                <?php endif; ?>
                            </p>
                            <?php endif; ?>
                        </div>
                        
                        <?php if ($type === 'property'): ?>
                        <div class="col-md-4">
                            <label class="text-muted small">غرف النوم</label>
                            <p class="mb-0"><?= $listing['bedrooms'] ?? '-' ?></p>
                        </div>
                        <div class="col-md-4">
                            <label class="text-muted small">المساحة</label>
                            <p class="mb-0"><?= $listing['area_m2'] ? $listing['area_m2'] . ' م²' : '-' ?></p>
                        </div>
                        <div class="col-md-4">
                            <label class="text-muted small">الطابق</label>
                            <p class="mb-0"><?= $listing['floor'] ?? '-' ?></p>
                        </div>
                        <?php else: ?>
                        <div class="col-md-4">
                            <label class="text-muted small">ناقل الحركة</label>
                            <p class="mb-0"><?= $listing['gearbox'] === 'automatic' ? 'أوتوماتيك' : 'عادي' ?></p>
                        </div>
                        <div class="col-md-4">
                            <label class="text-muted small">مع سائق</label>
                            <p class="mb-0"><?= $listing['with_driver'] ? 'نعم' : 'لا' ?></p>
                        </div>
                        <div class="col-md-4">
                            <label class="text-muted small">لون اللوحة</label>
                            <p class="mb-0"><?= $listing['plate_color'] === 'yellow' ? 'أصفر' : 'أبيض' ?></p>
                        </div>
                        <?php endif; ?>
                        
                        <div class="col-12">
                            <label class="text-muted small">الوصف</label>
                            <p class="mb-0"><?= nl2br(htmlspecialchars($listing['bio'] ?? 'لا يوجد وصف')) ?></p>
                        </div>
                        
                        <div class="col-md-6">
                            <label class="text-muted small">هاتف التواصل</label>
                            <p class="mb-0"><?= htmlspecialchars($listing['contact_phone'] ?? '') ?></p>
                        </div>
                        <div class="col-md-6">
                            <label class="text-muted small">واتساب</label>
                            <p class="mb-0"><?= htmlspecialchars($listing['whatsapp'] ?? '') ?></p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Media Gallery -->
            <div class="card">
                <div class="card-header d-flex justify-content-between align-items-center">
                    <h5 class="mb-0">
                        <i class="bi bi-images me-2"></i>الصور والفيديو
                    </h5>
                    <span class="badge bg-primary"><?= count($media) ?> ملف</span>
                </div>
                <div class="card-body">
                    <?php if (!empty($media)): ?>
                    <!-- Main Image Preview -->
                    <?php 
                    $firstImage = null;
                    foreach ($media as $m) {
                        if ($m['media_type'] === 'image') {
                            $firstImage = $m;
                            break;
                        }
                    }
                    if ($firstImage): ?>
                    <div class="main-image-container mb-3" onclick="openMedia(0)" style="cursor: pointer;">
                        <img src="<?= htmlspecialchars(UPLOAD_URL . $firstImage['file_path']) ?>" alt="الصورة الرئيسية">
                        <div class="position-absolute bottom-0 start-0 end-0 p-3" style="background: linear-gradient(transparent, rgba(0,0,0,0.7));">
                            <span class="text-white"><i class="bi bi-zoom-in me-1"></i> انقر للتكبير</span>
                        </div>
                    </div>
                    <?php endif; ?>
                    
                    <!-- Thumbnails Grid -->
                    <div class="media-gallery">
                        <?php foreach ($media as $index => $m): ?>
                        <div class="media-item <?= $m['media_type'] === 'video' ? 'video-item' : '' ?>" onclick="openMedia(<?= $index ?>)">
                            <?php if ($m['media_type'] === 'image'): ?>
                            <img src="<?= htmlspecialchars(UPLOAD_URL . $m['file_path']) ?>" alt="صورة <?= $index + 1 ?>">
                            <?php else: ?>
                            <video muted>
                                <source src="<?= htmlspecialchars(UPLOAD_URL . $m['file_path']) ?>">
                            </video>
                            <?php endif; ?>
                            <div class="media-overlay">
                                <i class="bi <?= $m['media_type'] === 'video' ? 'bi-play-circle' : 'bi-zoom-in' ?>"></i>
                            </div>
                        </div>
                        <?php endforeach; ?>
                    </div>
                    <?php else: ?>
                    <div class="text-center py-5">
                        <i class="bi bi-image text-muted" style="font-size: 4rem;"></i>
                        <p class="text-muted mt-3 mb-0">لا توجد صور أو فيديوهات لهذا الإعلان</p>
                    </div>
                    <?php endif; ?>
                </div>
            </div>
        </div>

        <!-- Sidebar -->
        <div class="col-md-4">
            <!-- Owner Info -->
            <div class="card mb-4">
                <div class="card-header">
                    <h5 class="mb-0">معلومات المعلن</h5>
                </div>
                <div class="card-body">
                    <p class="mb-2">
                        <strong><?= htmlspecialchars($listing['user_name']) ?></strong>
                        <?php if ($listing['is_trusted']): ?>
                        <span class="badge bg-success ms-1">موثق</span>
                        <?php endif; ?>
                    </p>
                    <?php if ($listing['company_name']): ?>
                    <p class="mb-2 text-muted"><?= htmlspecialchars($listing['company_name']) ?></p>
                    <?php endif; ?>
                    <p class="mb-1"><i class="bi bi-envelope me-2"></i><?= htmlspecialchars($listing['user_email']) ?></p>
                    <p class="mb-0"><i class="bi bi-phone me-2"></i><?= htmlspecialchars($listing['user_phone']) ?></p>
                    <hr>
                    <p class="mb-0 small text-muted">
                        نوع الحساب: <?= USER_TYPES[$listing['user_type']]['ar'] ?? $listing['user_type'] ?>
                    </p>
                </div>
            </div>

            <!-- Actions -->
            <?php if (in_array($listing['status'], ['pending_admin_review', 'draft', 'rejected', 'paused', 'expired'])): ?>
            <div class="card mb-4">
                <div class="card-header bg-warning">
                    <h5 class="mb-0">إجراءات المراجعة</h5>
                </div>
                <div class="card-body">
                    <form method="POST" id="reviewForm">
                        <?php if ($listing['status'] !== 'active'): ?>
                        <button type="submit" name="action" value="approve" class="btn btn-success w-100 mb-3">
                            <i class="bi bi-check-lg me-1"></i> نشر الإعلان
                        </button>
                        <?php endif; ?>
                        
                        <?php if ($listing['status'] === 'active'): ?>
                        <button type="submit" name="action" value="pause" class="btn btn-warning w-100 mb-3">
                            <i class="bi bi-pause-lg me-1"></i> إيقاف الإعلان
                        </button>
                        <?php endif; ?>
                        
                        <?php if ($listing['status'] !== 'rejected'): ?>
                        <div class="mb-3">
                            <label class="form-label">سبب الرفض</label>
                            <textarea name="reject_reason" class="form-control" rows="3" 
                                      placeholder="يجب إدخال سبب الرفض..."></textarea>
                        </div>
                        <button type="submit" name="action" value="reject" class="btn btn-danger w-100">
                            <i class="bi bi-x-lg me-1"></i> رفض الإعلان
                        </button>
                        <?php endif; ?>
                    </form>
                </div>
            </div>
            <?php elseif ($listing['status'] === 'active'): ?>
            <div class="card mb-4">
                <div class="card-header bg-success text-white">
                    <h5 class="mb-0">إجراءات الإعلان</h5>
                </div>
                <div class="card-body">
                    <form method="POST">
                        <button type="submit" name="action" value="pause" class="btn btn-warning w-100 mb-3">
                            <i class="bi bi-pause-lg me-1"></i> إيقاف الإعلان
                        </button>
                        <div class="mb-3">
                            <label class="form-label">سبب الرفض</label>
                            <textarea name="reject_reason" class="form-control" rows="3" 
                                      placeholder="يجب إدخال سبب الرفض..."></textarea>
                        </div>
                        <button type="submit" name="action" value="reject" class="btn btn-danger w-100">
                            <i class="bi bi-x-lg me-1"></i> رفض الإعلان
                        </button>
                    </form>
                </div>
            </div>
            <?php endif; ?>

            <?php if ($listing['status'] === 'rejected' && $listing['reject_reason']): ?>
            <div class="card mb-4 border-danger">
                <div class="card-header bg-danger text-white">
                    <h5 class="mb-0">سبب الرفض</h5>
                </div>
                <div class="card-body">
                    <p class="mb-0"><?= nl2br(htmlspecialchars($listing['reject_reason'])) ?></p>
                </div>
            </div>
            <?php endif; ?>

            <!-- Timeline -->
            <div class="card">
                <div class="card-header">
                    <h5 class="mb-0">معلومات إضافية</h5>
                </div>
                <div class="card-body">
                    <ul class="list-unstyled mb-0">
                        <li class="mb-2">
                            <small class="text-muted">تاريخ الإنشاء:</small><br>
                            <?= date('Y/m/d H:i', strtotime($listing['created_at'])) ?>
                        </li>
                        <li class="mb-2">
                            <small class="text-muted">آخر تحديث:</small><br>
                            <?= date('Y/m/d H:i', strtotime($listing['updated_at'])) ?>
                        </li>
                        <?php if ($listing['expires_at']): ?>
                        <li class="mb-2">
                            <small class="text-muted">تاريخ الانتهاء:</small><br>
                            <?= date('Y/m/d H:i', strtotime($listing['expires_at'])) ?>
                        </li>
                        <?php endif; ?>
                        <?php if (!empty($listing['plan_name_ar'])): ?>
                        <li class="mb-2">
                            <small class="text-muted">الباقة المستخدمة:</small><br>
                            <span class="badge bg-primary">
                                <i class="bi bi-box me-1"></i><?= htmlspecialchars($listing['plan_name_ar']) ?>
                            </span>
                        </li>
                        <?php endif; ?>
                        <li>
                            <small class="text-muted">المشاهدات:</small><br>
                            <?= number_format($listing['views_count']) ?>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Lightbox Modal -->
<div class="modal fade" id="mediaModal" tabindex="-1">
    <div class="modal-dialog modal-xl modal-dialog-centered">
        <div class="modal-content bg-dark">
            <div class="modal-header border-0">
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body text-center p-0">
                <img id="modalImage" src="" class="img-fluid" style="max-height: 80vh;">
                <video id="modalVideo" controls class="w-100" style="max-height: 80vh; display: none;">
                    <source id="modalVideoSrc" src="">
                </video>
            </div>
            <div class="modal-footer border-0 justify-content-center">
                <button type="button" class="btn btn-outline-light btn-sm" id="prevMedia">
                    <i class="bi bi-chevron-right"></i> السابق
                </button>
                <span class="text-white mx-3" id="mediaCounter">1 / 1</span>
                <button type="button" class="btn btn-outline-light btn-sm" id="nextMedia">
                    التالي <i class="bi bi-chevron-left"></i>
                </button>
            </div>
        </div>
    </div>
</div>

<style>
.media-gallery {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
    gap: 15px;
}
.media-item {
    position: relative;
    border-radius: 12px;
    overflow: hidden;
    cursor: pointer;
    aspect-ratio: 4/3;
    background: #f0f0f0;
}
.media-item img, .media-item video {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: transform 0.3s;
}
.media-item:hover img, .media-item:hover video {
    transform: scale(1.05);
}
.media-item .media-overlay {
    position: absolute;
    inset: 0;
    background: rgba(0,0,0,0.3);
    display: flex;
    align-items: center;
    justify-content: center;
    opacity: 0;
    transition: opacity 0.3s;
}
.media-item:hover .media-overlay {
    opacity: 1;
}
.media-item .media-overlay i {
    font-size: 2rem;
    color: white;
}
.media-item.video-item::after {
    content: '';
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    width: 50px;
    height: 50px;
    background: rgba(0,0,0,0.7);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
}
.media-item.video-item::before {
    content: '▶';
    position: absolute;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    color: white;
    font-size: 1.2rem;
    z-index: 1;
}
.main-image-container {
    position: relative;
    border-radius: 16px;
    overflow: hidden;
    margin-bottom: 15px;
    background: #f8f9fa;
}
.main-image-container img {
    width: 100%;
    height: 400px;
    object-fit: cover;
}
.listing-title-header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 20px;
    border-radius: 12px;
    margin-bottom: 20px;
}
.info-card {
    background: #f8f9fa;
    border-radius: 10px;
    padding: 15px;
    height: 100%;
}
.info-card .label {
    font-size: 0.8rem;
    color: #6c757d;
    margin-bottom: 5px;
}
.info-card .value {
    font-weight: 600;
    font-size: 1rem;
}
</style>

<script>
let mediaItems = <?= json_encode(array_map(function($m) {
    return [
        'type' => $m['media_type'],
        'url' => UPLOAD_URL . $m['file_path']
    ];
}, $media)) ?>;
let currentMediaIndex = 0;

function openMedia(index) {
    currentMediaIndex = index;
    showMedia();
    new bootstrap.Modal(document.getElementById('mediaModal')).show();
}

function showMedia() {
    const item = mediaItems[currentMediaIndex];
    const img = document.getElementById('modalImage');
    const video = document.getElementById('modalVideo');
    const videoSrc = document.getElementById('modalVideoSrc');
    
    if (item.type === 'image') {
        img.src = item.url;
        img.style.display = 'block';
        video.style.display = 'none';
        video.pause();
    } else {
        videoSrc.src = item.url;
        video.load();
        video.style.display = 'block';
        img.style.display = 'none';
    }
    
    document.getElementById('mediaCounter').textContent = (currentMediaIndex + 1) + ' / ' + mediaItems.length;
}

document.getElementById('prevMedia')?.addEventListener('click', function() {
    currentMediaIndex = (currentMediaIndex - 1 + mediaItems.length) % mediaItems.length;
    showMedia();
});

document.getElementById('nextMedia')?.addEventListener('click', function() {
    currentMediaIndex = (currentMediaIndex + 1) % mediaItems.length;
    showMedia();
});

document.getElementById('mediaModal')?.addEventListener('hidden.bs.modal', function() {
    document.getElementById('modalVideo').pause();
});
</script>

<?php include 'includes/footer.php'; ?>
