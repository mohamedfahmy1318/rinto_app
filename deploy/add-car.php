<?php
require_once __DIR__ . '/config.php';
require_once __DIR__ . '/includes/translations.php';
$pageTitle = __('add_car');

// Check if logged in with valid token
if (!isset($_SESSION['user']) || !isset($_SESSION['token']) || empty($_SESSION['token'])) {
    // Clear any partial session
    unset($_SESSION['user']);
    unset($_SESSION['token']);
    header('Location: login.php?redirect=add-car.php&msg=relogin');
    exit;
}

$user = $_SESSION['user'];

// Any registered user can add listings (subscription required for activation)
// Check if user has active subscription for cars
$subscriptionCheck = apiCall('subscriptions/can-add?category=cars', 'GET', null, $_SESSION['token']);
$canAddListing = $subscriptionCheck['data']['can_add'] ?? false;

$error = '';
$success = '';

// Get regions
$regions = apiCall('regions')['data'] ?? [];

$usageTypes = [
    'daily' => __('daily_use'),
    'wedding' => __('wedding'),
    'tourism' => __('tourism')
];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Check if subscription_id is provided
    $subscriptionId = $_POST['subscription_id'] ?? null;
    if (empty($subscriptionId)) {
        $error = $lang === 'he' ? 'יש לבחור אפשרות תשלום' : ($lang === 'en' ? 'Please select a payment option' : 'يرجى اختيار خيار دفع');
    } else {
    $data = [
        'brand' => $_POST['brand'] ?? '',
        'model' => $_POST['model'] ?? '',
        'year' => $_POST['year'] ?? '',
        'usage_type' => $_POST['usage_type'] ?? '',
        'region_id' => $_POST['region_id'] ?? '',
        'city_id' => $_POST['city_id'] ?? '',
        'price_type' => 'fixed',
        'price' => $_POST['price_daily'] ?? null,
        'price_daily' => $_POST['price_daily'] ?? null,
        'price_weekly' => $_POST['price_weekly'] ?? null,
        'price_monthly' => $_POST['price_monthly'] ?? null,
        'currency' => 'ILS',
        'gearbox' => $_POST['gearbox'] ?? 'automatic',
        'with_driver' => isset($_POST['with_driver']) ? 1 : 0,
        'plate_color' => $_POST['plate_color'] ?? 'yellow',
        'bio' => $_POST['bio'] ?? '',
        'contact_phone' => $_POST['contact_phone'] ?? $user['phone'],
        'whatsapp' => $_POST['whatsapp'] ?? '',
        'subscription_id' => $subscriptionId
    ];
    
    // API call with token
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, API_URL . '/cars');
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Content-Type: application/json',
        'Authorization: Bearer ' . $_SESSION['token']
    ]);
    $response = json_decode(curl_exec($ch), true);
    curl_close($ch);
    
    if ($response['success'] ?? false) {
        $listingId = $response['data']['id'] ?? null;
        
        // Upload images if any
        if ($listingId && isset($_FILES['images']) && !empty($_FILES['images']['name'][0])) {
            $uploadedCount = 0;
            $files = $_FILES['images'];
            
            for ($i = 0; $i < count($files['name']); $i++) {
                if ($files['error'][$i] === UPLOAD_ERR_OK && $files['size'][$i] <= 5 * 1024 * 1024) {
                    $imageData = base64_encode(file_get_contents($files['tmp_name'][$i]));
                    $mimeType = mime_content_type($files['tmp_name'][$i]);
                    
                    $imgCh = curl_init();
                    curl_setopt($imgCh, CURLOPT_URL, API_URL . '/uploads/image');
                    curl_setopt($imgCh, CURLOPT_RETURNTRANSFER, true);
                    curl_setopt($imgCh, CURLOPT_POST, true);
                    curl_setopt($imgCh, CURLOPT_SSL_VERIFYPEER, false);
                    curl_setopt($imgCh, CURLOPT_SSL_VERIFYHOST, false);
                    curl_setopt($imgCh, CURLOPT_POSTFIELDS, json_encode([
                        'listing_id' => $listingId,
                        'listing_type' => 'car',
                        'image' => "data:$mimeType;base64,$imageData",
                        'sort_order' => $i
                    ]));
                    curl_setopt($imgCh, CURLOPT_HTTPHEADER, [
                        'Content-Type: application/json',
                        'Authorization: Bearer ' . $_SESSION['token']
                    ]);
                    curl_exec($imgCh);
                    curl_close($imgCh);
                    $uploadedCount++;
                }
            }
            $success = sprintf(__('listing_created_with_images'), $uploadedCount);
        } else {
            $success = __('listing_created');
        }
    } else {
        $reason = $response['data']['reason'] ?? '';
        if ($reason === 'no_subscription' || $reason === 'wrong_type' || $reason === 'limit_reached') {
            $error = ($response['data']['message_ar'] ?? $response['message'] ?? __('listing_failed')) . 
                     ' <a href="packages.php?category=cars" class="alert-link">' . 
                     ($lang === 'he' ? 'רכוש חבילה' : 'شراء باقة') . '</a>';
        } else {
            $error = $response['message'] ?? __('listing_failed');
        }
    }
    } // Close subscription_id check
}

require_once __DIR__ . '/includes/header.php';
?>

<div class="bg-white py-4 mb-4 shadow-sm">
    <div class="container">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb mb-0">
                <li class="breadcrumb-item"><a href="<?= SITE_URL ?>"><?= __('home') ?></a></li>
                <li class="breadcrumb-item"><a href="profile.php"><?= __('my_account') ?></a></li>
                <li class="breadcrumb-item active"><?= __('add_car') ?></li>
            </ol>
        </nav>
    </div>
</div>

<div class="container py-4">
    <div class="row justify-content-center">
        <div class="col-lg-8">
            <div class="add-listing-card">
                <h4 class="mb-4"><i class="bi bi-car-front-fill me-2"></i><?= __('add_new_car') ?></h4>
                
                <?php if ($error): ?>
                <div class="alert alert-danger"><?= $error ?></div>
                <?php endif; ?>
                
                <?php if ($success): ?>
                <div class="alert alert-success"><?= htmlspecialchars($success) ?></div>
                <?php else: ?>
                
                <?php if ($canAddListing): ?>
                <div class="alert alert-success">
                    <i class="bi bi-check-circle me-2"></i><?= $lang === 'he' ? 'יש לך מנוי פעיל' : 'لديك اشتراك فعال' ?>
                </div>
                <?php endif; ?>
                
                <form method="POST" action="" enctype="multipart/form-data">
                    <!-- Image Upload Section -->
                    <div class="mb-4">
                        <label class="form-label"><?= __('car_images') ?></label>
                        <div class="image-upload-area border rounded p-3">
                            <input type="file" name="images[]" id="images" class="form-control" multiple accept="image/*">
                            <small class="text-muted d-block mt-2"><?= __('upload_hint') ?></small>
                            <div id="image-preview" class="d-flex flex-wrap gap-2 mt-3"></div>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <label class="form-label"><?= __('car_brand') ?> *</label>
                            <input type="text" name="brand" class="form-control" placeholder="<?= __('brand_placeholder') ?>" required>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label"><?= __('model') ?> *</label>
                            <input type="text" name="model" class="form-control" placeholder="<?= __('model_placeholder') ?>" required>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label"><?= __('manufacturing_year') ?> *</label>
                            <input type="number" name="year" class="form-control" min="2000" max="2026" required>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label"><?= __('usage_type') ?> *</label>
                            <select name="usage_type" class="form-select" required>
                                <option value=""><?= __('select_type') ?></option>
                                <?php foreach ($usageTypes as $value => $label): ?>
                                <option value="<?= $value ?>"><?= $label ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                    </div>
                    
                    <!-- أسعار التأجير -->
                    <div class="card bg-light mb-3">
                        <div class="card-body">
                            <h6 class="card-title mb-3">
                                <i class="bi bi-currency-dollar me-1"></i>
                                <?= $lang === 'he' ? 'מחירי השכרה (₪)' : 'أسعار التأجير (₪)' ?>
                            </h6>
                            <p class="text-muted small mb-3">
                                <?= $lang === 'he' ? 'הזן לפחות מחיר אחד' : 'أدخل سعر واحد على الأقل' ?>
                            </p>
                            <div class="row">
                                <div class="col-md-4 mb-3">
                                    <label class="form-label"><?= $lang === 'he' ? 'יומי' : 'يومي' ?></label>
                                    <div class="input-group">
                                        <input type="number" name="price_daily" class="form-control" placeholder="150">
                                        <span class="input-group-text">₪</span>
                                    </div>
                                </div>
                                <div class="col-md-4 mb-3">
                                    <label class="form-label"><?= $lang === 'he' ? 'שבועי' : 'أسبوعي' ?></label>
                                    <div class="input-group">
                                        <input type="number" name="price_weekly" class="form-control" placeholder="900">
                                        <span class="input-group-text">₪</span>
                                    </div>
                                </div>
                                <div class="col-md-4 mb-3">
                                    <label class="form-label"><?= $lang === 'he' ? 'חודשי' : 'شهري' ?></label>
                                    <div class="input-group">
                                        <input type="number" name="price_monthly" class="form-control" placeholder="3000">
                                        <span class="input-group-text">₪</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label"><?= __('select_region') ?> *</label>
                            <select name="region_id" id="region_id" class="form-select" required>
                                <option value=""><?= __('select_region') ?></option>
                                <?php foreach ($regions as $region): ?>
                                <option value="<?= $region['id'] ?>"><?= htmlspecialchars($region['name_' . $lang] ?? $region['name_ar']) ?></option>
                                <?php endforeach; ?>
                            </select>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label"><?= __('select_city') ?> *</label>
                            <select name="city_id" id="city_id" class="form-select" required>
                                <option value=""><?= __('select_city') ?></option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <label class="form-label"><?= __('gearbox') ?></label>
                            <select name="gearbox" class="form-select">
                                <option value="automatic"><?= __('automatic') ?></option>
                                <option value="manual"><?= __('manual') ?></option>
                            </select>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label"><?= __('plate_color') ?></label>
                            <select name="plate_color" class="form-select">
                                <option value="yellow"><?= __('yellow') ?></option>
                                <option value="white"><?= __('white') ?></option>
                                <option value="green"><?= __('green') ?></option>
                            </select>
                        </div>
                        <div class="col-md-4 mb-3">
                            <label class="form-label">&nbsp;</label>
                            <div class="form-check mt-2">
                                <input type="checkbox" name="with_driver" class="form-check-input" id="with_driver">
                                <label class="form-check-label" for="with_driver"><?= __('with_driver') ?></label>
                            </div>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label"><?= __('listing_description') ?></label>
                        <textarea name="bio" class="form-control" rows="4" placeholder="<?= __('description_car_placeholder') ?>"></textarea>
                    </div>
                    
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label class="form-label"><?= __('contact_phone') ?> *</label>
                            <input type="tel" name="contact_phone" class="form-control" dir="ltr" value="<?= htmlspecialchars($user['phone']) ?>" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label class="form-label"><?= __('whatsapp') ?></label>
                            <input type="tel" name="whatsapp" class="form-control" dir="ltr" placeholder="+972...">
                        </div>
                    </div>
                    
                    <!-- Payment Options Section -->
                    <div class="card mb-4" id="payment-options-section">
                        <div class="card-header bg-light">
                            <h5 class="mb-0"><i class="bi bi-credit-card me-2"></i><?= $lang === 'he' ? 'אפשרויות תשלום' : 'خيارات الدفع' ?></h5>
                        </div>
                        <div class="card-body">
                            <p class="text-muted mb-3"><?= $lang === 'he' ? 'יש לבחור סוג שימוש כדי לראות אפשרויות תשלום' : 'يرجى اختيار نوع الاستخدام لعرض خيارات الدفع' ?></p>
                            <div id="payment-options-loading" class="text-center d-none">
                                <div class="spinner-border text-primary" role="status"></div>
                            </div>
                            <div id="payment-options-list"></div>
                        </div>
                    </div>
                    
                    <input type="hidden" name="subscription_id" id="subscription_id" value="">
                    
                    <div class="alert alert-info">
                        <i class="bi bi-info-circle me-2"></i>
                        <?= __('review_notice') ?>
                    </div>
                    
                    <button type="submit" class="btn btn-primary btn-lg w-100" id="submit-btn">
                        <i class="bi bi-plus-lg me-2"></i><?= __('submit_listing') ?>
                    </button>
                </form>
                <?php endif; ?>
            </div>
        </div>
    </div>
</div>

<script>
const currentLang = '<?= $lang ?>';
const apiUrl = '<?= API_URL ?>';
const authToken = '<?= $_SESSION['token'] ?>';

// Load payment options when usage type changes
document.querySelector('select[name="usage_type"]').addEventListener('change', function() {
    loadPaymentOptions(this.value);
});

function loadPaymentOptions(usageType) {
    const container = document.getElementById('payment-options-list');
    const loading = document.getElementById('payment-options-loading');
    const submitBtn = document.getElementById('submit-btn');
    
    if (!usageType) {
        container.innerHTML = `<p class="text-muted">${currentLang === 'he' ? 'יש לבחור סוג שימוש' : 'يرجى اختيار نوع الاستخدام'}</p>`;
        document.getElementById('subscription_id').value = '';
        return;
    }
    
    loading.classList.remove('d-none');
    container.innerHTML = '';
    
    fetch(`${apiUrl}/subscriptions/available-for-listing?category=cars&sub_type=${usageType}`, {
        headers: {
            'Authorization': `Bearer ${authToken}`,
            'Accept': 'application/json'
        }
    })
    .then(r => r.json())
    .then(data => {
        loading.classList.add('d-none');
        
        if (!data.success) {
            container.innerHTML = `<div class="alert alert-danger">${data.message || 'Error'}</div>`;
            return;
        }
        
        const result = data.data;
        let html = '';
        let hasOptions = false;
        
        // Free Bonus
        if (result.free_bonus) {
            hasOptions = true;
            const remaining = result.free_bonus.listings_remaining;
            html += `
                <div class="form-check payment-option mb-3 p-3 border rounded" onclick="selectPaymentOption(${result.free_bonus.id})">
                    <input class="form-check-input" type="radio" name="payment_option" id="payment_free" value="${result.free_bonus.id}" checked>
                    <label class="form-check-label w-100" for="payment_free">
                        <div class="d-flex align-items-center">
                            <i class="bi bi-gift text-success fs-4 me-3"></i>
                            <div>
                                <strong class="text-success">${currentLang === 'he' ? 'חבילת ברוכים הבאים (חינם)' : 'باقة الترحيب (مجانية)'}</strong>
                                <br><small class="text-muted">${currentLang === 'he' ? `מודעות נותרו: ${remaining}` : `متبقي: ${remaining} إعلان`}</small>
                            </div>
                        </div>
                    </label>
                </div>
            `;
            document.getElementById('subscription_id').value = result.free_bonus.id;
        }
        
        // Active Subscriptions
        if (result.active_subscriptions && result.active_subscriptions.length > 0) {
            result.active_subscriptions.forEach((sub, index) => {
                hasOptions = true;
                const name = currentLang === 'he' ? (sub.name_he || sub.name_ar) : sub.name_ar;
                const remaining = sub.listings_remaining;
                const isFirst = !result.free_bonus && index === 0;
                
                html += `
                    <div class="form-check payment-option mb-3 p-3 border rounded" onclick="selectPaymentOption(${sub.id})">
                        <input class="form-check-input" type="radio" name="payment_option" id="payment_${sub.id}" value="${sub.id}" ${isFirst ? 'checked' : ''}>
                        <label class="form-check-label w-100" for="payment_${sub.id}">
                            <div class="d-flex align-items-center">
                                <i class="bi bi-check-circle text-primary fs-4 me-3"></i>
                                <div>
                                    <strong>${name}</strong>
                                    ${sub.badge ? `<span class="badge bg-primary ms-2">${sub.badge}</span>` : ''}
                                    <br><small class="text-muted">${currentLang === 'he' ? `מודעות נותרו: ${remaining}` : `متبقي: ${remaining} إعلان`}</small>
                                </div>
                            </div>
                        </label>
                    </div>
                `;
                
                if (isFirst) {
                    document.getElementById('subscription_id').value = sub.id;
                }
            });
        }
        
        // Buy New Option
        html += `
            <a href="packages.php?category=cars&car_usage_type=${usageType}" class="d-block p-3 border rounded text-decoration-none ${hasOptions ? 'text-muted' : 'border-primary'}">
                <div class="d-flex align-items-center justify-content-between">
                    <div class="d-flex align-items-center">
                        <i class="bi bi-cart-plus ${hasOptions ? 'text-muted' : 'text-primary'} fs-4 me-3"></i>
                        <div>
                            <strong>${currentLang === 'he' ? 'רכוש חבילה חדשה' : 'شراء باقة جديدة'}</strong>
                            <br><small>${hasOptions ? (currentLang === 'he' ? 'שמור על החבילות הקיימות' : 'احتفظ بباقاتك الحالية') : (currentLang === 'he' ? 'נדרש לפרסום המודעה' : 'مطلوب لنشر الإعلان')}</small>
                        </div>
                    </div>
                    <i class="bi bi-chevron-${currentLang === 'he' ? 'left' : 'right'}"></i>
                </div>
            </a>
        `;
        
        if (!hasOptions) {
            html = `
                <div class="alert alert-warning mb-3">
                    <i class="bi bi-exclamation-triangle me-2"></i>
                    ${currentLang === 'he' ? 'אין לך חבילה פעילה. יש לרכוש חבילה כדי לפרסם מודעה.' : 'ليس لديك باقة فعالة. يجب شراء باقة لنشر الإعلان.'}
                </div>
            ` + html;
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="bi bi-lock me-2"></i>' + (currentLang === 'he' ? 'יש לרכוש חבילה' : 'يجب شراء باقة أولاً');
        } else {
            submitBtn.disabled = false;
            submitBtn.innerHTML = '<i class="bi bi-plus-lg me-2"></i><?= __('submit_listing') ?>';
        }
        
        container.innerHTML = html;
    })
    .catch(err => {
        loading.classList.add('d-none');
        container.innerHTML = `<div class="alert alert-danger">${err.message}</div>`;
    });
}

function selectPaymentOption(id) {
    document.getElementById('subscription_id').value = id;
    document.querySelector(`input[value="${id}"]`).checked = true;
}

document.getElementById('region_id').addEventListener('change', function() {
    const regionId = this.value;
    const citySelect = document.getElementById('city_id');
    citySelect.innerHTML = '<option value=""><?= __('loading') ?></option>';
    
    if (regionId) {
        fetch('<?= API_URL ?>/regions/' + regionId + '/cities')
            .then(r => r.json())
            .then(data => {
                citySelect.innerHTML = '<option value=""><?= __('select_city') ?></option>';
                if (data.data) {
                    data.data.forEach(city => {
                        const cityName = city['name_' + currentLang] || city.name_ar;
                        citySelect.innerHTML += `<option value="${city.id}">${cityName}</option>`;
                    });
                }
            });
    } else {
        citySelect.innerHTML = '<option value=""><?= __('select_city') ?></option>';
    }
});

// Image preview
document.getElementById('images').addEventListener('change', function(e) {
    const preview = document.getElementById('image-preview');
    preview.innerHTML = '';
    
    const files = Array.from(e.target.files).slice(0, 10);
    files.forEach((file, index) => {
        if (file.type.startsWith('image/')) {
            const reader = new FileReader();
            reader.onload = function(e) {
                const div = document.createElement('div');
                div.className = 'position-relative';
                div.innerHTML = `
                    <img src="${e.target.result}" class="rounded" style="width: 100px; height: 100px; object-fit: cover;">
                    ${index === 0 ? '<span class="badge bg-primary position-absolute top-0 start-0"><?= __('main_image') ?></span>' : ''}
                `;
                preview.appendChild(div);
            };
            reader.readAsDataURL(file);
        }
    });
});
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
