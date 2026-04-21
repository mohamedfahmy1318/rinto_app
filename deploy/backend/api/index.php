<?php
/**
 * Rento Go API Router
 */

header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/constants.php';
require_once __DIR__ . '/../helpers/Response.php';
require_once __DIR__ . '/../helpers/JWT.php';
require_once __DIR__ . '/../helpers/Validator.php';
require_once __DIR__ . '/../helpers/Upload.php';
require_once __DIR__ . '/../helpers/OneSignal.php';

Upload::init();

$requestUri = $_SERVER['REQUEST_URI'];
// Auto-detect base path for both local and production
$scriptName = $_SERVER['SCRIPT_NAME'];
$basePath = dirname($scriptName);
if ($basePath === '/' || $basePath === '\\') {
    $basePath = '';
}
$path = parse_url($requestUri, PHP_URL_PATH);
$path = str_replace($basePath, '', $path);
$path = trim($path, '/');

$method = $_SERVER['REQUEST_METHOD'];

$input = json_decode(file_get_contents('php://input'), true) ?? [];
$input = array_merge($input, $_POST, $_GET);

$segments = explode('/', $path);

try {
    switch ($segments[0]) {
        case 'auth':
            require_once __DIR__ . '/controllers/AuthController.php';
            $controller = new AuthController();
            handleAuthRoutes($controller, $segments, $method, $input);
            break;
            
        case 'listings':
            require_once __DIR__ . '/controllers/ListingController.php';
            $controller = new ListingController();
            handleListingRoutes($controller, $segments, $method, $input);
            break;
            
        case 'properties':
            require_once __DIR__ . '/controllers/PropertyController.php';
            $controller = new PropertyController();
            handlePropertyRoutes($controller, $segments, $method, $input);
            break;
            
        case 'cars':
            require_once __DIR__ . '/controllers/CarController.php';
            $controller = new CarController();
            handleCarRoutes($controller, $segments, $method, $input);
            break;
            
        case 'favorites':
            require_once __DIR__ . '/controllers/FavoriteController.php';
            $controller = new FavoriteController();
            handleFavoriteRoutes($controller, $segments, $method, $input);
            break;
            
        case 'plans':
            require_once __DIR__ . '/controllers/PlanController.php';
            $controller = new PlanController();
            handlePlanRoutes($controller, $segments, $method, $input);
            break;
            
        case 'payments':
            require_once __DIR__ . '/controllers/PaymentController.php';
            $controller = new PaymentController();
            handlePaymentRoutes($controller, $segments, $method, $input);
            break;
            
        case 'subscriptions':
            require_once __DIR__ . '/controllers/SubscriptionController.php';
            $controller = new SubscriptionController();
            handleSubscriptionRoutes($controller, $segments, $method, $input);
            break;
            
        case 'reports':
            require_once __DIR__ . '/controllers/ReportController.php';
            $controller = new ReportController();
            handleReportRoutes($controller, $segments, $method, $input);
            break;
            
        case 'regions':
            require_once __DIR__ . '/controllers/RegionController.php';
            $controller = new RegionController();
            handleRegionRoutes($controller, $segments, $method, $input);
            break;
            
        case 'cities':
            require_once __DIR__ . '/controllers/RegionController.php';
            $controller = new RegionController();
            $controller->allCities($input);
            break;
            
        case 'pages':
            require_once __DIR__ . '/controllers/PageController.php';
            $controller = new PageController();
            handlePageRoutes($controller, $segments, $method, $input);
            break;
            
        case 'uploads':
            require_once __DIR__ . '/controllers/UploadController.php';
            $controller = new UploadController();
            handleUploadRoutes($controller, $segments, $method, $input);
            break;
            
        case 'me':
            require_once __DIR__ . '/controllers/UserController.php';
            $controller = new UserController();
            $controller->me();
            break;
            
        case 'users':
            require_once __DIR__ . '/controllers/UserController.php';
            $controller = new UserController();
            handleUserRoutes($controller, $segments, $method, $input);
            break;
            
        case 'notifications':
            require_once __DIR__ . '/controllers/NotificationController.php';
            $controller = new NotificationController();
            handleNotificationRoutes($controller, $segments, $method, $input);
            break;
            
        case 'chat':
            require_once __DIR__ . '/controllers/ChatController.php';
            $controller = new ChatController();
            handleChatRoutes($controller, $segments, $method, $input);
            break;
            
        case 'settings':
            require_once __DIR__ . '/controllers/SettingsController.php';
            $controller = new SettingsController();
            handleSettingsRoutes($controller, $segments, $method, $input);
            break;
            
        case 'banners':
            require_once __DIR__ . '/controllers/BannerController.php';
            $controller = new BannerController();
            handleBannerRoutes($controller, $segments, $method, $input);
            break;
            
        case 'types':
            require_once __DIR__ . '/controllers/TypesController.php';
            $controller = new TypesController();
            handleTypesRoutes($controller, $segments, $method, $input);
            break;
            
        case '':
            Response::success(['version' => APP_VERSION, 'name' => APP_NAME], 'Rento Go API');
            break;
            
        default:
            Response::notFound('Endpoint not found');
    }
} catch (Exception $e) {
    Response::serverError($e->getMessage());
}

function handleAuthRoutes($controller, $segments, $method, $input) {
    $action = $segments[1] ?? '';
    
    switch ($action) {
        case 'register':
            if ($method === 'POST') $controller->register($input);
            break;
        case 'login':
            if ($method === 'POST') $controller->login($input);
            break;
        case 'verify-phone':
            if ($method === 'POST') $controller->verifyPhone($input);
            break;
        case 'verify-email':
            if ($method === 'POST') $controller->verifyEmail($input);
            break;
        case 'forgot-password':
            if ($method === 'POST') $controller->forgotPassword($input);
            break;
        case 'reset-password':
            if ($method === 'POST') $controller->resetPassword($input);
            break;
        case 'resend-otp':
            if ($method === 'POST') $controller->resendOtp($input);
            break;
        case 'delete-account':
            if ($method === 'POST') $controller->deleteAccount($input);
            break;
        default:
            Response::notFound();
    }
}

function handleListingRoutes($controller, $segments, $method, $input) {
    $id = $segments[1] ?? null;
    $action = $segments[2] ?? null;
    
    if (!$id) {
        if ($method === 'GET') $controller->index($input);
        else Response::notFound();
        return;
    }
    
    if ($action) {
        switch ($action) {
            case 'pause':
                if ($method === 'POST') $controller->pause($id);
                break;
            case 'resume':
                if ($method === 'POST') $controller->resume($id);
                break;
            case 'renew':
                if ($method === 'POST') $controller->renew($id, $input);
                break;
            case 'republish':
                if ($method === 'POST') $controller->republish($id, $input);
                break;
            case 'toggle-rented':
                if ($method === 'POST') $controller->toggleRented($id, $input);
                break;
            default:
                Response::notFound();
        }
        return;
    }
    
    switch ($method) {
        case 'GET':
            $controller->show($id);
            break;
        case 'DELETE':
            $controller->delete($id);
            break;
        default:
            Response::notFound();
    }
}

function handlePropertyRoutes($controller, $segments, $method, $input) {
    $id = $segments[1] ?? null;
    
    if (!$id) {
        switch ($method) {
            case 'GET':
                $controller->index($input);
                break;
            case 'POST':
                $controller->store($input);
                break;
            default:
                Response::notFound();
        }
        return;
    }
    
    switch ($method) {
        case 'GET':
            $controller->show($id);
            break;
        case 'PUT':
            $controller->update($id, $input);
            break;
        case 'DELETE':
            $controller->delete($id);
            break;
        default:
            Response::notFound();
    }
}

function handleCarRoutes($controller, $segments, $method, $input) {
    $id = $segments[1] ?? null;
    
    if (!$id) {
        switch ($method) {
            case 'GET':
                $controller->index($input);
                break;
            case 'POST':
                $controller->store($input);
                break;
            default:
                Response::notFound();
        }
        return;
    }
    
    switch ($method) {
        case 'GET':
            $controller->show($id);
            break;
        case 'PUT':
            $controller->update($id, $input);
            break;
        case 'DELETE':
            $controller->delete($id);
            break;
        default:
            Response::notFound();
    }
}

function handleFavoriteRoutes($controller, $segments, $method, $input) {
    $listingId = $segments[1] ?? null;
    
    if (!$listingId) {
        if ($method === 'GET') $controller->index($input);
        else Response::notFound();
        return;
    }
    
    switch ($method) {
        case 'POST':
            $controller->add($listingId, $input);
            break;
        case 'DELETE':
            $controller->remove($listingId, $input);
            break;
        default:
            Response::notFound();
    }
}

function handlePlanRoutes($controller, $segments, $method, $input) {
    $id = $segments[1] ?? null;
    
    if (!$id) {
        if ($method === 'GET') $controller->index($input);
        else Response::notFound();
        return;
    }
    
    if ($method === 'GET') $controller->show($id);
    else Response::notFound();
}

function handlePaymentRoutes($controller, $segments, $method, $input) {
    $action = $segments[1] ?? '';
    
    switch ($action) {
        case 'verify-receipt':
            if ($method === 'POST') $controller->verifyReceipt($input);
            break;
        case 'history':
            if ($method === 'GET') $controller->history($input);
            break;
        default:
            Response::notFound();
    }
}

function handleSubscriptionRoutes($controller, $segments, $method, $input) {
    $action = $segments[1] ?? '';
    
    switch ($action) {
        case 'me':
            if ($method === 'GET') $controller->mySubscriptions($input);
            else Response::notFound();
            break;
        case 'active':
            if ($method === 'GET') $controller->active($input);
            else Response::notFound();
            break;
        case 'can-add':
            if ($method === 'GET') $controller->canAddListing($input);
            else Response::notFound();
            break;
        case 'available-for-listing':
            if ($method === 'GET') $controller->availableForListing($input);
            else Response::notFound();
            break;
        case 'warnings':
            if ($method === 'GET') $controller->warnings();
            else Response::notFound();
            break;
        case 'requests':
            if ($method === 'GET') $controller->myRequests($input);
            elseif ($method === 'POST') $controller->requestPlan($input);
            else Response::notFound();
            break;
        case 'purchase':
            if ($method === 'POST') $controller->purchase($input);
            else Response::notFound();
            break;
        case 'verify-apple-purchase':
            if ($method === 'POST') $controller->verifyApplePurchase($input);
            else Response::notFound();
            break;
        case 'verify-google-purchase':
            if ($method === 'POST') $controller->verifyGooglePurchase($input);
            else Response::notFound();
            break;
        default:
            if ($method === 'GET') $controller->index($input);
            else Response::notFound();
    }
}

function handleReportRoutes($controller, $segments, $method, $input) {
    if ($method === 'POST') {
        $controller->store($input);
    } else {
        Response::notFound();
    }
}

function handleRegionRoutes($controller, $segments, $method, $input) {
    $id = $segments[1] ?? null;
    $action = $segments[2] ?? null;
    
    if (!$id) {
        if ($method === 'GET') $controller->index($input);
        else Response::notFound();
        return;
    }
    
    if ($action === 'cities') {
        if ($method === 'GET') $controller->cities($id, $input);
        else Response::notFound();
        return;
    }
    
    if ($method === 'GET') $controller->show($id);
    else Response::notFound();
}

function handlePageRoutes($controller, $segments, $method, $input) {
    $slug = $segments[1] ?? null;
    
    if (!$slug) {
        Response::notFound();
        return;
    }
    
    if ($method === 'GET') $controller->show($slug, $input);
    else Response::notFound();
}

function handleUploadRoutes($controller, $segments, $method, $input) {
    $type = $segments[1] ?? '';
    
    if ($method !== 'POST') {
        Response::notFound();
        return;
    }
    
    switch ($type) {
        case 'images':
            $controller->uploadImages($input);
            break;
        case 'image':
            // Single base64 image upload (used by mobile app)
            $controller->uploadBase64Image($input);
            break;
        case 'video':
            $controller->uploadVideo($input);
            break;
        default:
            Response::notFound();
    }
}

function handleNotificationRoutes($controller, $segments, $method, $input) {
    $id = $segments[1] ?? null;
    $action = $segments[2] ?? null;
    
    if (!$id) {
        if ($method === 'GET') $controller->index($input);
        else Response::notFound();
        return;
    }
    
    // GET /notifications/unread-count
    if ($id === 'unread-count') {
        if ($method === 'GET') $controller->unreadCount();
        else Response::notFound();
        return;
    }
    
    // POST /notifications/{id}/read or /notifications/all/read
    if ($action === 'read') {
        if ($method === 'POST') $controller->markAsRead($id);
        else Response::notFound();
        return;
    }
    
    // DELETE /notifications/{id}
    if ($method === 'DELETE') {
        $controller->delete($id);
        return;
    }
    
    Response::notFound();
}

function handleChatRoutes($controller, $segments, $method, $input) {
    $action = $segments[1] ?? null;
    $id = $segments[2] ?? null;
    
    switch ($action) {
        case 'conversations':
            if ($method === 'GET') $controller->index($input);
            else Response::notFound();
            break;
            
        case 'conversation':
            if ($id) {
                if ($method === 'GET') $controller->messages($id, $input);
                else Response::notFound();
            } else {
                if ($method === 'POST') $controller->getOrCreate($input);
                else Response::notFound();
            }
            break;
            
        case 'send':
            if ($method === 'POST') $controller->send($input);
            else Response::notFound();
            break;
            
        case 'unread':
            if ($method === 'GET') $controller->unreadCount();
            else Response::notFound();
            break;
            
        default:
            Response::notFound();
    }
}

function handleSettingsRoutes($controller, $segments, $method, $input) {
    $action = $segments[1] ?? '';
    
    switch ($action) {
        case 'terms':
            if ($method === 'GET') $controller->terms($input);
            else Response::notFound();
            break;
            
        case 'privacy':
            if ($method === 'GET') $controller->privacy($input);
            else Response::notFound();
            break;
            
        case 'get':
            if ($method === 'GET') $controller->get($input);
            else Response::notFound();
            break;
        
        case 'payment-methods':
            if ($method === 'GET') $controller->paymentMethods($input);
            else Response::notFound();
            break;
            
        default:
            Response::notFound();
    }
}

function handleUserRoutes($controller, $segments, $method, $input) {
    $action = $segments[1] ?? '';
    
    switch ($action) {
        case 'fcm-token':
            if ($method === 'POST') $controller->saveFcmToken();
            else Response::notFound();
            break;
            
        case 'update-fcm-token':
            if ($method === 'POST') $controller->updateFcmToken($input);
            else Response::notFound();
            break;
            
        case 'profile':
        case 'update-profile':
            if ($method === 'PUT' || $method === 'POST') $controller->updateProfile($input);
            else Response::notFound();
            break;
        
        case 'change-password':
            if ($method === 'POST') $controller->changePassword($input);
            else Response::notFound();
            break;
        
        case 'change-email':
            if ($method === 'POST') $controller->changeEmail($input);
            else Response::notFound();
            break;
        
        case 'change-phone':
            if ($method === 'POST') $controller->changePhone($input);
            else Response::notFound();
            break;
            
        case 'my-listings':
            if ($method === 'GET') $controller->myListings($input);
            else Response::notFound();
            break;
            
        default:
            Response::notFound();
    }
}

function handleBannerRoutes($controller, $segments, $method, $input) {
    $id = $segments[1] ?? null;
    
    if (!$id) {
        if ($method === 'GET') $controller->index($input);
        else Response::notFound();
        return;
    }
    
    if ($method === 'GET') $controller->show($id);
    else Response::notFound();
}

function handleTypesRoutes($controller, $segments, $method, $input) {
    $type = $segments[1] ?? '';
    
    if ($method !== 'GET') {
        Response::notFound();
        return;
    }
    
    switch ($type) {
        case 'property':
        case 'properties':
            $controller->propertyTypes();
            break;
        case 'car':
        case 'cars':
            $controller->carTypes();
            break;
        case '':
            $controller->allTypes();
            break;
        default:
            Response::notFound();
    }
}
