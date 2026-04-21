<?php
/**
 * Upload Controller
 */

class UploadController {
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    public function uploadImages($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        if (!isset($_FILES['images'])) {
            Response::error('No images uploaded', 400);
        }
        
        $listingType = $input['listing_type'] ?? 'property';
        $listingId = $input['listing_id'] ?? null;
        
        if (!$listingId) {
            Response::error('Listing ID is required', 400);
        }
        
        // Verify ownership
        $table = $listingType === 'car' ? 'cars' : 'properties';
        $listing = $this->db->fetch("SELECT user_id, subscription_id FROM $table WHERE id = ?", [$listingId]);
        
        if (!$listing || $listing['user_id'] != $auth['user_id']) {
            Response::forbidden('Not authorized to upload to this listing');
        }
        
        // Get max images limit from subscription plan
        $maxImages = MAX_IMAGES_PER_LISTING; // Default
        if ($listing['subscription_id']) {
            $plan = $this->db->fetch(
                "SELECT p.max_images FROM subscriptions s 
                 JOIN plans p ON s.plan_id = p.id 
                 WHERE s.id = ?",
                [$listing['subscription_id']]
            );
            if ($plan && $plan['max_images']) {
                $maxImages = (int)$plan['max_images'];
            }
        }
        
        // Check existing media count
        $mediaTable = $listingType === 'car' ? 'car_media' : 'property_media';
        $foreignKey = $listingType === 'car' ? 'car_id' : 'property_id';
        
        $existingCount = $this->db->fetch(
            "SELECT COUNT(*) as count FROM $mediaTable WHERE $foreignKey = ? AND media_type = 'image'",
            [$listingId]
        )['count'];
        
        $remainingSlots = $maxImages - $existingCount;
        
        if ($remainingSlots <= 0) {
            Response::error('Maximum images limit reached (' . $maxImages . ')', 400);
        }
        
        $folder = 'images/' . ($listingType === 'car' ? 'cars' : 'properties');
        $results = Upload::multipleImages($_FILES['images'], $folder, $remainingSlots);
        
        $uploaded = [];
        $errors = [];
        
        // Get current max sort order
        $maxSort = $this->db->fetch(
            "SELECT MAX(sort_order) as max_sort FROM $mediaTable WHERE $foreignKey = ?",
            [$listingId]
        )['max_sort'] ?? 0;
        
        foreach ($results as $i => $result) {
            if (isset($result['error'])) {
                $errors[] = $result;
            } else {
                $maxSort++;
                $mediaId = $this->db->insert($mediaTable, [
                    $foreignKey => $listingId,
                    'media_type' => 'image',
                    'file_path' => $result['path'],
                    'file_name' => $result['filename'],
                    'sort_order' => $maxSort
                ]);
                
                $uploaded[] = [
                    'id' => $mediaId,
                    'url' => $result['url'],
                    'path' => $result['path']
                ];
            }
        }
        
        Response::success([
            'uploaded' => $uploaded,
            'errors' => $errors,
            'total_uploaded' => count($uploaded)
        ], count($uploaded) . ' image(s) uploaded');
    }
    
    public function uploadBase64Image($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $listingType = $input['listing_type'] ?? 'property';
        $listingId = $input['listing_id'] ?? null;
        $base64Image = $input['image'] ?? null;
        $sortOrder = $input['sort_order'] ?? 0;
        
        if (!$listingId) {
            Response::error('Listing ID is required', 400);
        }
        
        if (!$base64Image) {
            Response::error('Image data is required', 400);
        }
        
        // Verify ownership
        $table = $listingType === 'car' ? 'cars' : 'properties';
        $listing = $this->db->fetch("SELECT user_id, subscription_id FROM $table WHERE id = ?", [$listingId]);
        
        if (!$listing || $listing['user_id'] != $auth['user_id']) {
            Response::forbidden('Not authorized to upload to this listing');
        }
        
        // Get max images limit from subscription plan
        $maxImages = MAX_IMAGES_PER_LISTING; // Default
        if ($listing['subscription_id']) {
            $plan = $this->db->fetch(
                "SELECT p.max_images FROM subscriptions s 
                 JOIN plans p ON s.plan_id = p.id 
                 WHERE s.id = ?",
                [$listing['subscription_id']]
            );
            if ($plan && $plan['max_images']) {
                $maxImages = (int)$plan['max_images'];
            }
        }
        
        // Check existing media count
        $mediaTable = $listingType === 'car' ? 'car_media' : 'property_media';
        $foreignKey = $listingType === 'car' ? 'car_id' : 'property_id';
        
        $existingCount = $this->db->fetch(
            "SELECT COUNT(*) as count FROM $mediaTable WHERE $foreignKey = ? AND media_type = 'image'",
            [$listingId]
        )['count'];
        
        if ($existingCount >= $maxImages) {
            Response::error('Maximum images limit reached (' . $maxImages . ')', 400);
        }
        
        // Decode base64 image
        $imageData = $base64Image;
        if (strpos($base64Image, 'base64,') !== false) {
            $imageData = explode('base64,', $base64Image)[1];
        }
        $decodedImage = base64_decode($imageData);
        
        if (!$decodedImage) {
            Response::error('Invalid image data', 400);
        }
        
        // Generate filename and save
        $folder = 'images/' . ($listingType === 'car' ? 'cars' : 'properties');
        $uploadDir = UPLOAD_PATH . '/' . $folder;
        
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0755, true);
        }
        
        $filename = uniqid() . '_' . time() . '.jpg';
        $filePath = $folder . '/' . $filename;
        $fullPath = $uploadDir . '/' . $filename;
        
        if (!file_put_contents($fullPath, $decodedImage)) {
            Response::error('Failed to save image', 500);
        }
        
        // Insert to database
        $mediaId = $this->db->insert($mediaTable, [
            $foreignKey => $listingId,
            'media_type' => 'image',
            'file_path' => $filePath,
            'file_name' => $filename,
            'sort_order' => $sortOrder
        ]);
        
        Response::success([
            'id' => $mediaId,
            'url' => UPLOAD_URL . $filePath,
            'path' => $filePath
        ], 'Image uploaded successfully');
    }

    public function uploadVideo($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        if (!isset($_FILES['video'])) {
            Response::error('No video uploaded', 400);
        }
        
        $listingType = $input['listing_type'] ?? 'property';
        $listingId = $input['listing_id'] ?? null;
        
        if (!$listingId) {
            Response::error('Listing ID is required', 400);
        }
        
        // Verify ownership
        $table = $listingType === 'car' ? 'cars' : 'properties';
        $listing = $this->db->fetch("SELECT user_id FROM $table WHERE id = ?", [$listingId]);
        
        if (!$listing || $listing['user_id'] != $auth['user_id']) {
            Response::forbidden('Not authorized to upload to this listing');
        }
        
        // Check existing video
        $mediaTable = $listingType === 'car' ? 'car_media' : 'property_media';
        $foreignKey = $listingType === 'car' ? 'car_id' : 'property_id';
        
        $existingVideo = $this->db->fetch(
            "SELECT * FROM $mediaTable WHERE $foreignKey = ? AND media_type = 'video'",
            [$listingId]
        );
        
        if ($existingVideo) {
            // Delete old video
            Upload::delete($existingVideo['file_path']);
            $this->db->delete($mediaTable, 'id = ?', [$existingVideo['id']]);
        }
        
        $folder = 'videos/' . ($listingType === 'car' ? 'cars' : 'properties');
        $result = Upload::video($_FILES['video'], $folder);
        
        if (isset($result['error'])) {
            Response::error($result['error'], 400);
        }
        
        $mediaId = $this->db->insert($mediaTable, [
            $foreignKey => $listingId,
            'media_type' => 'video',
            'file_path' => $result['path'],
            'file_name' => $result['filename'],
            'sort_order' => 999
        ]);
        
        Response::success([
            'id' => $mediaId,
            'url' => $result['url'],
            'path' => $result['path']
        ], 'Video uploaded successfully');
    }
}
