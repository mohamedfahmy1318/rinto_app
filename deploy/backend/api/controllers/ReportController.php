<?php
/**
 * Report Controller
 */

class ReportController {
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    public function store($input) {
        $auth = JWT::authenticate();
        if (!$auth) {
            Response::unauthorized();
        }
        
        $validator = new Validator($input);
        $validator
            ->required('listing_type')->in('listing_type', ['property', 'car'])
            ->required('listing_id')
            ->required('reason')->minLength('reason', 10)->maxLength('reason', 1000)
            ->validate();
        
        // Get listing and owner
        $table = $input['listing_type'] === 'car' ? 'cars' : 'properties';
        $listing = $this->db->fetch("SELECT user_id FROM $table WHERE id = ?", [$input['listing_id']]);
        
        if (!$listing) {
            Response::notFound('Listing not found');
        }
        
        // Cannot report own listing
        if ($listing['user_id'] == $auth['user_id']) {
            Response::error('Cannot report your own listing', 400);
        }
        
        // Handle screenshot upload
        $screenshotPath = null;
        if (isset($_FILES['screenshot'])) {
            $result = Upload::image($_FILES['screenshot'], 'images/reports');
            if (!isset($result['error'])) {
                $screenshotPath = $result['path'];
            }
        }
        
        $reportId = $this->db->insert('reports', [
            'reporter_id' => $auth['user_id'],
            'listing_type' => $input['listing_type'],
            'listing_id' => $input['listing_id'],
            'reported_user_id' => $listing['user_id'],
            'reason' => $input['reason'],
            'screenshot' => $screenshotPath,
            'status' => 'pending'
        ]);
        
        Response::success(['report_id' => $reportId], 'Report submitted successfully', 201);
    }
}
