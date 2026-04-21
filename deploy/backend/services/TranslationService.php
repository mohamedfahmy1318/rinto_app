<?php
/**
 * Translation Service using OpenRouter API (Gemini Flash 1.5)
 * Translates listing titles and descriptions to Arabic, Hebrew, and English
 */

class TranslationService {
    private const API_URL = 'https://openrouter.ai/api/v1/chat/completions';
    private const MODEL = 'google/gemini-2.0-flash-001';
    private const API_KEY = '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';
    
    /**
     * Detect the language of a given text
     */
    public static function detectLanguage(string $text): string {
        // Simple detection based on character ranges
        if (preg_match('/[\x{0590}-\x{05FF}]/u', $text)) {
            return 'he'; // Hebrew
        }
        if (preg_match('/[\x{0600}-\x{06FF}]/u', $text)) {
            return 'ar'; // Arabic
        }
        return 'en'; // Default to English
    }
    
    /**
     * Translate text to all three languages
     * 
     * @param string $title The title to translate
     * @param string $description The description to translate
     * @param string $sourceLang Source language code (ar, he, en)
     * @param string|null $model Car model name to translate (optional)
     * @return array ['title_ar' => ..., 'title_en' => ..., 'title_he' => ..., 
     *                'bio_ar' => ..., 'bio_en' => ..., 'bio_he' => ...,
     *                'model_ar' => ..., 'model_en' => ..., 'model_he' => ...]
     */
    public static function translateListing(string $title, string $description, string $sourceLang = null, ?string $model = null): array {
        // Auto-detect language if not provided
        if (!$sourceLang) {
            $sourceLang = self::detectLanguage($title . ' ' . $description);
        }
        
        // Build target languages (exclude source)
        $allLangs = ['ar', 'en', 'he'];
        $targetLangs = array_filter($allLangs, fn($l) => $l !== $sourceLang);
        
        // Prepare the translation prompt
        $langNames = [
            'ar' => 'Arabic',
            'en' => 'English', 
            'he' => 'Hebrew'
        ];
        
        $targetLangNames = implode(' and ', array_map(fn($l) => $langNames[$l], $targetLangs));
        
        $prompt = "Translate the following real estate/car listing to {$targetLangNames}.
Return ONLY a valid JSON object with no additional text or explanation.

Title: {$title}
Description: {$description}";
        
        if ($model) {
            $prompt .= "\nCar Model: {$model}";
        }
        
        $prompt .= "\n\nReturn JSON format:\n{\n";
        foreach ($targetLangs as $lang) {
            $prompt .= "  \"title_{$lang}\": \"translated title in {$langNames[$lang]}\",\n";
            $prompt .= "  \"bio_{$lang}\": \"translated description in {$langNames[$lang]}\",\n";
            if ($model) {
                $prompt .= "  \"model_{$lang}\": \"translated car model in {$langNames[$lang]}\",\n";
            }
        }
        $prompt = rtrim($prompt, ",\n") . "\n}";
        
        try {
            $response = self::callOpenRouter($prompt);
            
            if (!$response) {
                throw new Exception('Empty response from translation API');
            }
            
            // Parse the JSON response
            $translated = self::parseJsonResponse($response);
            
            // Add source language fields
            $result = [
                "title_{$sourceLang}" => $title,
                "bio_{$sourceLang}" => $description
            ];
            
            if ($model) {
                $result["model_{$sourceLang}"] = $model;
            }
            
            // Merge translated fields
            foreach ($targetLangs as $lang) {
                $result["title_{$lang}"] = $translated["title_{$lang}"] ?? '';
                $result["bio_{$lang}"] = $translated["bio_{$lang}"] ?? '';
                if ($model) {
                    $result["model_{$lang}"] = $translated["model_{$lang}"] ?? '';
                }
            }
            
            return $result;
            
        } catch (Exception $e) {
            error_log('Translation error: ' . $e->getMessage());
            
            // Return original text in source language, empty for others
            $result = [];
            foreach ($allLangs as $lang) {
                $result["title_{$lang}"] = ($lang === $sourceLang) ? $title : '';
                $result["bio_{$lang}"] = ($lang === $sourceLang) ? $description : '';
                if ($model) {
                    $result["model_{$lang}"] = ($lang === $sourceLang) ? $model : '';
                }
            }
            return $result;
        }
    }
    
    /**
     * Call OpenRouter API
     */
    private static function callOpenRouter(string $prompt): ?string {
        $data = [
            'model' => self::MODEL,
            'messages' => [
                [
                    'role' => 'system',
                    'content' => 'You are a professional translator specializing in real estate and automotive listings. Always respond with valid JSON only, no additional text.'
                ],
                [
                    'role' => 'user',
                    'content' => $prompt
                ]
            ],
            'temperature' => 0.3,
            'max_tokens' => 1000
        ];
        
        $ch = curl_init(self::API_URL);
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => json_encode($data),
            CURLOPT_HTTPHEADER => [
                'Content-Type: application/json',
                'Authorization: Bearer ' . self::API_KEY,
                'HTTP-Referer: https://rentogo.com',
                'X-Title: RentoGo Translation Service'
            ],
            CURLOPT_TIMEOUT => 30
        ]);
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);
        
        if ($error) {
            throw new Exception("cURL error: {$error}");
        }
        
        if ($httpCode !== 200) {
            throw new Exception("API returned HTTP {$httpCode}: {$response}");
        }
        
        $result = json_decode($response, true);
        
        if (!isset($result['choices'][0]['message']['content'])) {
            throw new Exception('Invalid API response structure');
        }
        
        return $result['choices'][0]['message']['content'];
    }
    
    /**
     * Parse JSON from API response (handles markdown code blocks)
     */
    private static function parseJsonResponse(string $response): array {
        // Remove markdown code blocks if present
        $response = preg_replace('/^```json\s*/i', '', $response);
        $response = preg_replace('/^```\s*/m', '', $response);
        $response = preg_replace('/\s*```$/m', '', $response);
        $response = trim($response);
        
        $decoded = json_decode($response, true);
        
        if (json_last_error() !== JSON_ERROR_NONE) {
            throw new Exception('Failed to parse JSON: ' . json_last_error_msg() . ' - Response: ' . substr($response, 0, 200));
        }
        
        return $decoded;
    }
    
    /**
     * Translate a single text field
     */
    public static function translateText(string $text, string $targetLang, string $sourceLang = null): string {
        if (!$sourceLang) {
            $sourceLang = self::detectLanguage($text);
        }
        
        if ($sourceLang === $targetLang) {
            return $text;
        }
        
        $langNames = ['ar' => 'Arabic', 'en' => 'English', 'he' => 'Hebrew'];
        
        $prompt = "Translate the following text to {$langNames[$targetLang]}. Return ONLY the translated text, nothing else.\n\nText: {$text}";
        
        try {
            return self::callOpenRouter($prompt) ?? $text;
        } catch (Exception $e) {
            error_log('Translation error: ' . $e->getMessage());
            return $text;
        }
    }
}
