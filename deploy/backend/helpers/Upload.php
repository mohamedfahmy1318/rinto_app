<?php
/**
 * File Upload Helper
 */

class Upload {
    
    public static function init() {
        $dirs = [
            UPLOAD_PATH,
            UPLOAD_PATH . 'images/',
            UPLOAD_PATH . 'images/properties/',
            UPLOAD_PATH . 'images/cars/',
            UPLOAD_PATH . 'images/users/',
            UPLOAD_PATH . 'images/reports/',
            UPLOAD_PATH . 'images/banners/',
            UPLOAD_PATH . 'videos/',
            UPLOAD_PATH . 'videos/properties/',
            UPLOAD_PATH . 'videos/cars/',
        ];
        
        foreach ($dirs as $dir) {
            if (!is_dir($dir)) {
                mkdir($dir, 0755, true);
            }
        }
    }
    
    public static function image($file, $folder = 'images', $maxSize = null) {
        $maxSize = $maxSize ?? MAX_IMAGE_SIZE;
        
        if (!isset($file['tmp_name']) || !is_uploaded_file($file['tmp_name'])) {
            return ['error' => 'No file uploaded'];
        }
        
        if ($file['size'] > $maxSize) {
            return ['error' => 'File too large. Max size: ' . ($maxSize / 1024 / 1024) . 'MB'];
        }
        
        $mimeType = mime_content_type($file['tmp_name']);
        if (!in_array($mimeType, ALLOWED_IMAGE_TYPES)) {
            return ['error' => 'Invalid image type. Allowed: JPEG, PNG, WebP'];
        }
        
        $extension = pathinfo($file['name'], PATHINFO_EXTENSION);
        $filename = uniqid() . '_' . time() . '.' . strtolower($extension);
        $path = UPLOAD_PATH . $folder . '/' . $filename;
        
        if (!move_uploaded_file($file['tmp_name'], $path)) {
            return ['error' => 'Failed to save file'];
        }
        
        return [
            'success' => true,
            'filename' => $filename,
            'path' => $folder . '/' . $filename,
            'url' => UPLOAD_URL . $folder . '/' . $filename
        ];
    }
    
    public static function video($file, $folder = 'videos', $maxSize = null) {
        $maxSize = $maxSize ?? MAX_VIDEO_SIZE;
        
        if (!isset($file['tmp_name']) || !is_uploaded_file($file['tmp_name'])) {
            return ['error' => 'No file uploaded'];
        }
        
        if ($file['size'] > $maxSize) {
            return ['error' => 'File too large. Max size: ' . ($maxSize / 1024 / 1024) . 'MB'];
        }
        
        $mimeType = mime_content_type($file['tmp_name']);
        if (!in_array($mimeType, ALLOWED_VIDEO_TYPES)) {
            return ['error' => 'Invalid video type. Allowed: MP4, MOV, WebM'];
        }
        
        $extension = pathinfo($file['name'], PATHINFO_EXTENSION);
        $filename = uniqid() . '_' . time() . '.' . strtolower($extension);
        $path = UPLOAD_PATH . $folder . '/' . $filename;
        
        if (!move_uploaded_file($file['tmp_name'], $path)) {
            return ['error' => 'Failed to save file'];
        }
        
        return [
            'success' => true,
            'filename' => $filename,
            'path' => $folder . '/' . $filename,
            'url' => UPLOAD_URL . $folder . '/' . $filename
        ];
    }
    
    public static function multipleImages($files, $folder = 'images', $maxCount = null) {
        $maxCount = $maxCount ?? MAX_IMAGES_PER_LISTING;
        $results = [];
        
        if (!isset($files['tmp_name']) || !is_array($files['tmp_name'])) {
            return ['error' => 'No files uploaded'];
        }
        
        $count = min(count($files['tmp_name']), $maxCount);
        
        for ($i = 0; $i < $count; $i++) {
            if (!empty($files['tmp_name'][$i])) {
                $file = [
                    'name' => $files['name'][$i],
                    'type' => $files['type'][$i],
                    'tmp_name' => $files['tmp_name'][$i],
                    'error' => $files['error'][$i],
                    'size' => $files['size'][$i]
                ];
                
                $result = self::image($file, $folder);
                if (isset($result['error'])) {
                    $results[] = ['error' => $result['error'], 'index' => $i];
                } else {
                    $results[] = $result;
                }
            }
        }
        
        return $results;
    }
    
    public static function delete($path) {
        $fullPath = UPLOAD_PATH . $path;
        if (file_exists($fullPath)) {
            return unlink($fullPath);
        }
        return false;
    }
}
