<?php
/**
 * Authentication Controller
 */

class AuthController {
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    public function register($input) {
        $validator = new Validator($input);
        $validator
            ->required('name')
            ->email('email') // Email is optional but must be valid if provided
            ->required('phone')->phone('phone')
            ->required('password')->minLength('password', 6)
            ->required('user_type')->in('user_type', ['renter', 'owner', 'office', 'car_lessor'])
            ->required('region_id')
            ->required('city_id')
            ->unique('phone', 'users');
        
        // Only check email uniqueness if email is provided
        if (!empty($input['email'])) {
            $validator->unique('email', 'users');
        }
        
        $validator->validate();
        
        $hashedPassword = password_hash($input['password'], PASSWORD_DEFAULT);
        
        $userId = $this->db->insert('users', [
            'name' => $input['name'],
            'company_name' => $input['company_name'] ?? null,
            'email' => !empty($input['email']) ? $input['email'] : null,
            'phone' => $input['phone'],
            'password' => $hashedPassword,
            'user_type' => $input['user_type'],
            'region_id' => $input['region_id'],
            'city_id' => $input['city_id'],
            'preferred_language' => $input['language'] ?? 'ar'
        ]);
        
        $user = $this->db->fetch("SELECT * FROM users WHERE id = ?", [$userId]);
        unset($user['password']);
        
        $token = JWT::encode(['user_id' => $userId, 'type' => 'user']);
        
        // Generate OTP for phone verification
        $this->generateOtp($userId, $user['phone'], 'phone');
        
        // Give welcome bonus subscriptions (one for each category if available)
        $this->grantWelcomeBonusSubscriptions($userId);
        
        Response::success([
            'user' => $user,
            'token' => $token,
            'requires_verification' => true
        ], 'Registration successful. Please verify your phone.');
    }
    
    public function login($input) {
        $validator = new Validator($input);
        $validator
            ->required('login')
            ->required('password')
            ->validate();
        
        $login = $input['login'];
        $user = $this->db->fetch(
            "SELECT * FROM users WHERE email = ? OR phone = ?",
            [$login, $login]
        );
        
        if (!$user || !password_verify($input['password'], $user['password'])) {
            Response::error('Invalid credentials', 401);
        }
        
        if ($user['is_blocked']) {
            Response::error('Your account has been blocked', 403);
        }
        
        unset($user['password']);
        
        $token = JWT::encode(['user_id' => $user['id'], 'type' => 'user']);
        
        // Update FCM token if provided
        if (!empty($input['fcm_token'])) {
            $this->db->update('users', ['fcm_token' => $input['fcm_token']], 'id = ?', [$user['id']]);
        }
        
        Response::success([
            'user' => $user,
            'token' => $token
        ], 'Login successful');
    }
    
    public function verifyPhone($input) {
        $validator = new Validator($input);
        $validator
            ->required('phone')
            ->required('code')
            ->validate();
        
        $otp = $this->db->fetch(
            "SELECT * FROM otp_codes WHERE phone = ? AND code = ? AND type = 'phone' AND is_used = 0 AND expires_at > NOW() ORDER BY id DESC LIMIT 1",
            [$input['phone'], $input['code']]
        );
        
        if (!$otp) {
            Response::error('Invalid or expired verification code', 400);
        }
        
        $this->db->update('otp_codes', ['is_used' => 1], 'id = ?', [$otp['id']]);
        
        if ($otp['user_id']) {
            $this->db->update('users', ['is_verified_phone' => 1], 'id = ?', [$otp['user_id']]);
        }
        
        Response::success(null, 'Phone verified successfully');
    }
    
    public function verifyEmail($input) {
        $validator = new Validator($input);
        $validator
            ->required('email')
            ->required('code')
            ->validate();
        
        $otp = $this->db->fetch(
            "SELECT * FROM otp_codes WHERE email = ? AND code = ? AND type = 'email' AND is_used = 0 AND expires_at > NOW() ORDER BY id DESC LIMIT 1",
            [$input['email'], $input['code']]
        );
        
        if (!$otp) {
            Response::error('Invalid or expired verification code', 400);
        }
        
        $this->db->update('otp_codes', ['is_used' => 1], 'id = ?', [$otp['id']]);
        
        if ($otp['user_id']) {
            $this->db->update('users', ['is_verified_email' => 1], 'id = ?', [$otp['user_id']]);
        }
        
        Response::success(null, 'Email verified successfully');
    }
    
    public function forgotPassword($input) {
        $validator = new Validator($input);
        $validator->required('email')->email('email')->validate();
        
        $user = $this->db->fetch("SELECT id, email FROM users WHERE email = ?", [$input['email']]);
        
        if ($user) {
            $this->generateOtp($user['id'], null, 'password_reset', $user['email']);
        }
        
        // Always return success for security
        Response::success(null, 'If the email exists, a reset code has been sent');
    }
    
    public function resetPassword($input) {
        $validator = new Validator($input);
        $validator
            ->required('email')
            ->required('code')
            ->required('password')->minLength('password', 6)
            ->validate();
        
        $otp = $this->db->fetch(
            "SELECT * FROM otp_codes WHERE email = ? AND code = ? AND type = 'password_reset' AND is_used = 0 AND expires_at > NOW() ORDER BY id DESC LIMIT 1",
            [$input['email'], $input['code']]
        );
        
        if (!$otp) {
            Response::error('Invalid or expired reset code', 400);
        }
        
        $hashedPassword = password_hash($input['password'], PASSWORD_DEFAULT);
        
        $this->db->update('otp_codes', ['is_used' => 1], 'id = ?', [$otp['id']]);
        $this->db->update('users', ['password' => $hashedPassword], 'id = ?', [$otp['user_id']]);
        
        Response::success(null, 'Password reset successfully');
    }
    
    public function resendOtp($input) {
        $validator = new Validator($input);
        $validator
            ->required('type')->in('type', ['phone', 'email'])
            ->validate();
        
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $user = $this->db->fetch("SELECT * FROM users WHERE id = ?", [$auth['user_id']]);
        if (!$user) {
            Response::notFound('User not found');
        }
        
        if ($input['type'] === 'phone') {
            $this->generateOtp($user['id'], $user['phone'], 'phone');
        } else {
            $this->generateOtp($user['id'], null, 'email', $user['email']);
        }
        
        Response::success(null, 'Verification code sent');
    }
    
    private function generateOtp($userId, $phone = null, $type = 'phone', $email = null) {
        $code = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);
        $expiresAt = date('Y-m-d H:i:s', strtotime('+10 minutes'));
        
        $this->db->insert('otp_codes', [
            'user_id' => $userId,
            'phone' => $phone,
            'email' => $email,
            'code' => $code,
            'type' => $type,
            'expires_at' => $expiresAt
        ]);
        
        // In production, send SMS or email here
        // For development, log the code
        error_log("OTP for $type ($phone$email): $code");
        
        return $code;
    }
    
    /**
     * Delete user account (Apple requirement)
     */
    public function deleteAccount($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $userId = $auth['user_id'];
        
        // Verify password for security
        $validator = new Validator($input);
        $validator->required('password')->validate();
        
        $user = $this->db->fetch("SELECT * FROM users WHERE id = ?", [$userId]);
        if (!$user) {
            Response::notFound('User not found');
        }
        
        if (!password_verify($input['password'], $user['password'])) {
            Response::error('Invalid password', 401);
        }
        
        // Delete user's data
        // 1. Delete properties and their media
        $properties = $this->db->fetchAll("SELECT id FROM properties WHERE user_id = ?", [$userId]);
        foreach ($properties as $prop) {
            $this->db->delete('property_media', 'property_id = ?', [$prop['id']]);
        }
        $this->db->delete('properties', 'user_id = ?', [$userId]);
        
        // 2. Delete cars and their media
        $cars = $this->db->fetchAll("SELECT id FROM cars WHERE user_id = ?", [$userId]);
        foreach ($cars as $car) {
            $this->db->delete('car_media', 'car_id = ?', [$car['id']]);
        }
        $this->db->delete('cars', 'user_id = ?', [$userId]);
        
        // 3. Delete conversations and messages
        $this->db->delete('messages', 'sender_id = ?', [$userId]);
        $this->db->query(
            "DELETE FROM conversations WHERE user1_id = ? OR user2_id = ?",
            [$userId, $userId]
        );
        
        // 4. Delete favorites
        $this->db->delete('favorites', 'user_id = ?', [$userId]);
        
        // 5. Delete notifications
        $this->db->delete('notifications', 'user_id = ?', [$userId]);
        
        // 6. Delete subscriptions and payments
        $this->db->delete('subscriptions', 'user_id = ?', [$userId]);
        $this->db->delete('payments', 'user_id = ?', [$userId]);
        $this->db->delete('subscription_requests', 'user_id = ?', [$userId]);
        
        // 7. Delete OTP codes
        $this->db->delete('otp_codes', 'user_id = ?', [$userId]);
        
        // 8. Finally, delete the user
        $this->db->delete('users', 'id = ?', [$userId]);
        
        Response::success(null, 'Account deleted successfully');
    }
    
    private function grantWelcomeBonusSubscriptions($userId) {
        // Get all welcome bonus plans
        $welcomePlans = $this->db->fetchAll(
            "SELECT * FROM plans WHERE is_welcome_bonus = 1 AND is_active = 1"
        );
        
        if (empty($welcomePlans)) {
            return;
        }
        
        foreach ($welcomePlans as $plan) {
            // Create subscription for this welcome bonus plan
            $expiresAt = date('Y-m-d H:i:s', strtotime('+' . $plan['duration_days'] . ' days'));
            
            $this->db->insert('subscriptions', [
                'user_id' => $userId,
                'plan_id' => $plan['id'],
                'category' => $plan['category'] ?? null,
                'listings_limit' => $plan['listings_count'] ?? 1,
                'listings_used' => 0,
                'is_unlimited' => $plan['is_unlimited'] ?? 0,
                'starts_at' => date('Y-m-d H:i:s'),
                'expires_at' => $expiresAt,
                'status' => 'active',
                'payment_method' => 'welcome_bonus',
                'payment_reference' => 'WELCOME_BONUS_' . $userId
            ]);
        }
        
        // Mark user as received welcome bonus
        $this->db->update('users', ['has_received_welcome_bonus' => 1], 'id = ?', [$userId]);
    }
}
