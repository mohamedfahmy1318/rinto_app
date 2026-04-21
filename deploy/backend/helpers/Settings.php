<?php
/**
 * Settings Helper
 * Provides easy access to app_settings from database
 */

class Settings {
    private static $cache = [];
    private static $db = null;
    
    /**
     * Get a setting value by key
     */
    public static function get($key, $default = null) {
        // Check cache first
        if (isset(self::$cache[$key])) {
            return self::$cache[$key];
        }
        
        $db = self::getDb();
        $setting = $db->fetch(
            "SELECT value_ar, setting_type, is_sensitive FROM app_settings WHERE setting_key = ?",
            [$key]
        );
        
        if (!$setting) {
            return $default;
        }
        
        $value = $setting['value_ar'];
        
        // Parse based on type
        switch ($setting['setting_type']) {
            case 'boolean':
                $value = $value === '1' || $value === 'true';
                break;
            case 'number':
                $value = is_numeric($value) ? (float)$value : $default;
                break;
            case 'json':
                $decoded = json_decode($value, true);
                $value = $decoded !== null ? $decoded : $default;
                break;
        }
        
        // Cache the value
        self::$cache[$key] = $value;
        
        return $value;
    }
    
    /**
     * Get all settings for a group
     */
    public static function getGroup($group) {
        $db = self::getDb();
        $settings = $db->fetchAll(
            "SELECT setting_key, value_ar, setting_type FROM app_settings WHERE setting_group = ?",
            [$group]
        );
        
        $result = [];
        foreach ($settings as $setting) {
            $value = $setting['value_ar'];
            
            switch ($setting['setting_type']) {
                case 'boolean':
                    $value = $value === '1' || $value === 'true';
                    break;
                case 'number':
                    $value = is_numeric($value) ? (float)$value : null;
                    break;
                case 'json':
                    $decoded = json_decode($value, true);
                    $value = $decoded !== null ? $decoded : null;
                    break;
            }
            
            $result[$setting['setting_key']] = $value;
        }
        
        return $result;
    }
    
    /**
     * Set a setting value
     */
    public static function set($key, $value, $adminId = null) {
        $db = self::getDb();
        
        // Convert value to string for storage
        if (is_bool($value)) {
            $value = $value ? '1' : '0';
        } elseif (is_array($value)) {
            $value = json_encode($value);
        }
        
        $existing = $db->fetch("SELECT id FROM app_settings WHERE setting_key = ?", [$key]);
        
        if ($existing) {
            $db->query(
                "UPDATE app_settings SET value_ar = ?, updated_at = NOW(), updated_by = ? WHERE setting_key = ?",
                [$value, $adminId, $key]
            );
        } else {
            $db->insert('app_settings', [
                'setting_key' => $key,
                'value_ar' => $value,
                'updated_by' => $adminId
            ]);
        }
        
        // Clear cache
        unset(self::$cache[$key]);
        
        return true;
    }
    
    /**
     * Check if a payment gateway is enabled
     */
    public static function isPaymentGatewayEnabled($gateway) {
        return self::get($gateway . '_enabled', false);
    }
    
    /**
     * Get payment mode (sandbox/production)
     */
    public static function getPaymentMode() {
        return self::get('payment_mode', 'sandbox');
    }
    
    /**
     * Check if we're in sandbox mode
     */
    public static function isSandbox() {
        return self::getPaymentMode() === 'sandbox';
    }
    
    /**
     * Get Apple Pay configuration
     */
    public static function getApplePayConfig() {
        if (!self::isPaymentGatewayEnabled('apple_pay')) {
            return null;
        }
        
        return [
            'merchant_id' => self::get('apple_pay_merchant_id'),
            'merchant_name' => self::get('apple_pay_merchant_name', 'Rento Go'),
            'certificate_path' => self::get('apple_pay_certificate_path'),
            'certificate_key' => self::get('apple_pay_certificate_key'),
            'merchant_domain' => self::get('apple_pay_merchant_domain'),
            'supported_networks' => self::get('apple_pay_supported_networks', ['visa', 'masterCard']),
            'sandbox' => self::isSandbox()
        ];
    }
    
    /**
     * Get Stripe configuration
     */
    public static function getStripeConfig() {
        if (!self::isPaymentGatewayEnabled('stripe')) {
            return null;
        }
        
        return [
            'publishable_key' => self::get('stripe_publishable_key'),
            'secret_key' => self::get('stripe_secret_key'),
            'webhook_secret' => self::get('stripe_webhook_secret'),
            'sandbox' => self::isSandbox()
        ];
    }
    
    /**
     * Get PayPal configuration
     */
    public static function getPayPalConfig() {
        if (!self::isPaymentGatewayEnabled('paypal')) {
            return null;
        }
        
        return [
            'client_id' => self::get('paypal_client_id'),
            'client_secret' => self::get('paypal_client_secret'),
            'mode' => self::get('paypal_mode', 'sandbox')
        ];
    }
    
    /**
     * Get available payment methods
     */
    public static function getAvailablePaymentMethods() {
        $methods = [];
        
        if (self::isPaymentGatewayEnabled('apple_pay')) {
            $methods[] = 'apple_pay';
        }
        if (self::isPaymentGatewayEnabled('stripe')) {
            $methods[] = 'stripe';
        }
        if (self::isPaymentGatewayEnabled('paypal')) {
            $methods[] = 'paypal';
        }
        
        return $methods;
    }
    
    /**
     * Clear settings cache
     */
    public static function clearCache() {
        self::$cache = [];
    }
    
    /**
     * Get database instance
     */
    private static function getDb() {
        if (self::$db === null) {
            self::$db = Database::getInstance();
        }
        return self::$db;
    }
}
