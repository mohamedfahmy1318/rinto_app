<?php
/**
 * Rento Go - Web App Configuration
 * Production: rento-go.com
 */

// Site URLs
define('SITE_URL', 'https://rento-go.com');
define('API_URL', 'https://rento-go.com/backend/api');
define('UPLOAD_URL', 'https://rento-go.com/uploads/');

// Site Info
define('SITE_NAME', 'Rento Go');
define('SITE_NAME_AR', 'رينتو جو');
define('SITE_DESCRIPTION', 'منصة إيجار العقارات والسيارات');

// Default Language
define('DEFAULT_LANG', 'ar');

// Supported Languages
define('SUPPORTED_LANGS', ['ar', 'he', 'en']);
define('LANG_NAMES', [
    'ar' => 'العربية',
    'he' => 'עברית',
    'en' => 'English'
]);

// Session
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

// Helper function to call API
function apiCall($endpoint, $method = 'GET', $data = null, $token = null) {
    $url = API_URL . '/' . ltrim($endpoint, '/');
    
    $headers = [
        'Content-Type: application/json',
        'Accept: application/json'
    ];
    
    if ($token) {
        $headers[] = 'Authorization: Bearer ' . $token;
    }
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_TIMEOUT, 10);
    curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 5);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false);
    curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
    
    if ($method === 'POST') {
        curl_setopt($ch, CURLOPT_POST, true);
        if ($data) {
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        }
    }
    
    $response = curl_exec($ch);
    $error = curl_error($ch);
    curl_close($ch);
    
    if ($error) {
        return ['success' => false, 'error' => $error];
    }
    
    return json_decode($response, true) ?? [];
}

// Get current language
function getLang() {
    $requestedLang = $_GET['lang'] ?? $_SESSION['lang'] ?? DEFAULT_LANG;
    // Validate language is supported
    if (!in_array($requestedLang, SUPPORTED_LANGS)) {
        $requestedLang = DEFAULT_LANG;
    }
    return $requestedLang;
}

// Set language
if (isset($_GET['lang']) && in_array($_GET['lang'], SUPPORTED_LANGS)) {
    $_SESSION['lang'] = $_GET['lang'];
}

$lang = getLang();
$isRTL = in_array($lang, ['ar', 'he']); // English is LTR
