<?php
/**
 * Favorite Action Handler - Web endpoint for favorites
 * Uses session-based authentication
 */

require_once __DIR__ . '/config.php';

header('Content-Type: application/json');

// Check if logged in
if (!isset($_SESSION['user']) || !isset($_SESSION['token'])) {
    echo json_encode(['success' => false, 'message' => 'يرجى تسجيل الدخول أولاً']);
    exit;
}

// Get input
$input = json_decode(file_get_contents('php://input'), true);
$listingType = $input['listing_type'] ?? '';
$listingId = $input['listing_id'] ?? '';

if (!$listingType || !$listingId) {
    echo json_encode(['success' => false, 'message' => 'بيانات غير صحيحة']);
    exit;
}

// Call API with token
$response = apiCall('favorites', 'POST', [
    'listing_type' => $listingType,
    'listing_id' => $listingId
], $_SESSION['token']);

echo json_encode($response);
