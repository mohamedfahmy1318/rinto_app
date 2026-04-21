<?php
/**
 * API Debug Test - Delete this file after testing!
 */
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Test direct API calls
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/constants.php';
require_once __DIR__ . '/../helpers/Response.php';

// Test types endpoint directly
if (isset($_GET['test']) && $_GET['test'] === 'types') {
    require_once __DIR__ . '/controllers/TypesController.php';
    $controller = new TypesController();
    $controller->allTypes();
    exit;
}

// Test listings endpoint directly
if (isset($_GET['test']) && $_GET['test'] === 'listings') {
    require_once __DIR__ . '/../helpers/JWT.php';
    require_once __DIR__ . '/controllers/ListingController.php';
    $controller = new ListingController();
    $controller->index(['tab' => 'properties', 'page' => 1]);
    exit;
}

// Test properties endpoint directly  
if (isset($_GET['test']) && $_GET['test'] === 'properties') {
    require_once __DIR__ . '/../helpers/JWT.php';
    require_once __DIR__ . '/controllers/PropertyController.php';
    $controller = new PropertyController();
    $controller->index([]);
    exit;
}

// Test full API router simulation
if (isset($_GET['test']) && $_GET['test'] === 'router') {
    require_once __DIR__ . '/../helpers/JWT.php';
    require_once __DIR__ . '/../helpers/Validator.php';
    require_once __DIR__ . '/../helpers/Upload.php';
    
    // Check if OneSignal exists
    $onesignalPath = __DIR__ . '/../helpers/OneSignal.php';
    if (file_exists($onesignalPath)) {
        echo json_encode(['OneSignal' => 'EXISTS at ' . $onesignalPath]);
    } else {
        echo json_encode(['OneSignal' => 'NOT FOUND at ' . $onesignalPath]);
    }
    exit;
}

// Test banners endpoint
if (isset($_GET['test']) && $_GET['test'] === 'banners') {
    require_once __DIR__ . '/controllers/BannerController.php';
    $controller = new BannerController();
    $controller->index([]);
    exit;
}

// Test subscriptions/me endpoint
if (isset($_GET['test']) && $_GET['test'] === 'subscriptions') {
    require_once __DIR__ . '/../helpers/JWT.php';
    require_once __DIR__ . '/controllers/SubscriptionController.php';
    $controller = new SubscriptionController();
    $controller->mySubscriptions(['status' => 'active']);
    exit;
}

// Test plans endpoint
if (isset($_GET['test']) && $_GET['test'] === 'plans') {
    require_once __DIR__ . '/controllers/PlanController.php';
    $controller = new PlanController();
    $controller->index(['category' => 'properties']);
    exit;
}

$results = [];

// Test 1: Database connection
try {
    require_once __DIR__ . '/../config/database.php';
    $db = Database::getInstance();
    $results['database'] = 'OK';
} catch (Exception $e) {
    $results['database'] = 'ERROR: ' . $e->getMessage();
}

// Test 2: Check if property_types table exists
try {
    $check = $db->fetch("SHOW TABLES LIKE 'property_types'");
    $results['property_types_table'] = $check ? 'EXISTS' : 'NOT FOUND';
} catch (Exception $e) {
    $results['property_types_table'] = 'ERROR: ' . $e->getMessage();
}

// Test 3: Check if car_types table exists
try {
    $check = $db->fetch("SHOW TABLES LIKE 'car_types'");
    $results['car_types_table'] = $check ? 'EXISTS' : 'NOT FOUND';
} catch (Exception $e) {
    $results['car_types_table'] = 'ERROR: ' . $e->getMessage();
}

// Test 4: Fetch property_types
try {
    $types = $db->fetchAll("SELECT * FROM property_types LIMIT 3");
    $results['property_types_data'] = $types ? count($types) . ' rows' : 'EMPTY';
} catch (Exception $e) {
    $results['property_types_data'] = 'ERROR: ' . $e->getMessage();
}

// Test 5: Fetch car_types
try {
    $types = $db->fetchAll("SELECT * FROM car_types LIMIT 3");
    $results['car_types_data'] = $types ? count($types) . ' rows' : 'EMPTY';
} catch (Exception $e) {
    $results['car_types_data'] = 'ERROR: ' . $e->getMessage();
}

// Test 6: Check plans table columns
try {
    $columns = $db->fetchAll("SHOW COLUMNS FROM plans");
    $columnNames = array_column($columns, 'Field');
    $results['plans_has_property_type_id'] = in_array('property_type_id', $columnNames) ? 'YES' : 'NO';
    $results['plans_has_car_type_id'] = in_array('car_type_id', $columnNames) ? 'YES' : 'NO';
} catch (Exception $e) {
    $results['plans_columns'] = 'ERROR: ' . $e->getMessage();
}

// Test 7: Fetch properties
try {
    $props = $db->fetchAll("SELECT id, title FROM properties WHERE status = 'active' LIMIT 3");
    $results['properties_data'] = $props ? count($props) . ' rows' : 'EMPTY';
} catch (Exception $e) {
    $results['properties_data'] = 'ERROR: ' . $e->getMessage();
}

// Test 8: Fetch cars
try {
    $cars = $db->fetchAll("SELECT id, title FROM cars WHERE status = 'active' LIMIT 3");
    $results['cars_data'] = $cars ? count($cars) . ' rows' : 'EMPTY';
} catch (Exception $e) {
    $results['cars_data'] = 'ERROR: ' . $e->getMessage();
}

// Test 9: Check TypesController
try {
    require_once __DIR__ . '/controllers/TypesController.php';
    $results['TypesController'] = 'LOADED OK';
} catch (Exception $e) {
    $results['TypesController'] = 'ERROR: ' . $e->getMessage();
}

// Test 10: Check SubscriptionController
try {
    require_once __DIR__ . '/controllers/SubscriptionController.php';
    $results['SubscriptionController'] = 'LOADED OK';
} catch (Exception $e) {
    $results['SubscriptionController'] = 'ERROR: ' . $e->getMessage();
}

echo json_encode(['success' => true, 'tests' => $results], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
