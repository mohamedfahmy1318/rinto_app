<?php
/**
 * Settings Controller - إعدادات التطبيق والشروط
 */

class SettingsController {
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    /**
     * Get terms of service
     */
    public function terms($input) {
        $lang = $input['lang'] ?? 'ar';
        $setting = $this->getSetting('terms_of_service', $lang);
        
        Response::success([
            'content' => $setting,
            'type' => 'terms_of_service'
        ]);
    }
    
    /**
     * Get privacy policy
     */
    public function privacy($input) {
        $lang = $input['lang'] ?? 'ar';
        $setting = $this->getSetting('privacy_policy', $lang);
        
        Response::success([
            'content' => $setting,
            'type' => 'privacy_policy'
        ]);
    }
    
    /**
     * Get any setting by key
     */
    public function get($input) {
        $key = $input['key'] ?? null;
        $lang = $input['lang'] ?? 'ar';
        
        if (!$key) {
            Response::error('Setting key is required', 400);
        }
        
        $setting = $this->getSetting($key, $lang);
        
        if ($setting === null) {
            Response::notFound('Setting not found');
        }
        
        Response::success([
            'key' => $key,
            'content' => $setting
        ]);
    }
    
    /**
     * Get enabled payment methods
     */
    public function paymentMethods($input) {
        $platform = $input['platform'] ?? 'android'; // ios or android
        
        // Get payment methods settings from settings table
        $methods = $this->db->fetchAll(
            "SELECT setting_key, setting_value FROM settings WHERE setting_group = 'payment_methods'"
        );
        
        $enabledMethods = [];
        foreach ($methods as $m) {
            if ($m['setting_value'] === '1') {
                // Extract method name from key (payment_xxx_enabled -> xxx)
                $methodName = str_replace(['payment_', '_enabled'], '', $m['setting_key']);
                
                // Filter platform-specific methods
                if ($methodName === 'apple_iap' && $platform !== 'ios') continue;
                if ($methodName === 'google_iap' && $platform !== 'android') continue;
                
                $enabledMethods[] = $methodName;
            }
        }
        
        // Get bank details if bank_transfer is enabled
        $bankDetails = null;
        if (in_array('bank_transfer', $enabledMethods)) {
            $bankSettings = $this->db->fetchAll(
                "SELECT setting_key, setting_value FROM settings WHERE setting_group = 'bank_details'"
            );
            $bankDetails = [];
            foreach ($bankSettings as $s) {
                $bankDetails[$s['setting_key']] = $s['setting_value'];
            }
        }
        
        Response::success([
            'enabled_methods' => $enabledMethods,
            'bank_details' => $bankDetails
        ]);
    }
    
    /**
     * Helper to get setting value
     */
    private function getSetting($key, $lang = 'ar') {
        $column = 'value_' . $lang;
        if (!in_array($column, ['value_ar', 'value_en', 'value_he'])) {
            $column = 'value_ar';
        }
        
        $result = $this->db->fetch(
            "SELECT $column as value FROM app_settings WHERE setting_key = ?",
            [$key]
        );
        
        return $result ? $result['value'] : null;
    }
}
