<?php
/**
 * CMS Page Controller
 */

class PageController {
    private $db;
    
    public function __construct() {
        $this->db = Database::getInstance();
    }
    
    public function show($slug, $input) {
        $page = $this->db->fetch(
            "SELECT * FROM cms_pages WHERE slug = ? AND is_active = 1",
            [$slug]
        );
        
        if (!$page) {
            Response::notFound('Page not found');
        }
        
        // Get preferred language
        $lang = $input['lang'] ?? 'ar';
        if (!in_array($lang, SUPPORTED_LANGUAGES)) {
            $lang = 'ar';
        }
        
        $response = [
            'slug' => $page['slug'],
            'title' => $page['title_' . $lang],
            'content' => $page['content_' . $lang],
            'titles' => [
                'ar' => $page['title_ar'],
                'en' => $page['title_en'],
                'he' => $page['title_he']
            ],
            'contents' => [
                'ar' => $page['content_ar'],
                'en' => $page['content_en'],
                'he' => $page['content_he']
            ]
        ];
        
        Response::success($response);
    }
}
