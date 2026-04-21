<?php 
require_once __DIR__ . '/../config.php'; 
require_once __DIR__ . '/translations.php';

// Fallback for missing constants (backwards compatibility)
if (!defined('LANG_NAMES')) {
    define('LANG_NAMES', ['ar' => 'العربية', 'he' => 'עברית', 'en' => 'English']);
}
if (!defined('SUPPORTED_LANGS')) {
    define('SUPPORTED_LANGS', ['ar', 'he', 'en']);
}
?>
<!DOCTYPE html>
<html lang="<?= $lang ?>" dir="<?= $isRTL ? 'rtl' : 'ltr' ?>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="api-url" content="<?= API_URL ?>">
    <meta name="upload-url" content="<?= UPLOAD_URL ?>">
    <title><?= $pageTitle ?? SITE_NAME_AR ?> - <?= SITE_NAME ?></title>
    <meta name="description" content="<?= __('site_description') ?>">
    
    <?php if ($isRTL): ?>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.rtl.min.css" rel="stylesheet">
    <?php else: ?>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <?php endif; ?>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link href="<?= SITE_URL ?>/assets/css/style.css" rel="stylesheet">
    <?php if (isset($extraCss) && is_array($extraCss)): ?>
    <?php foreach ($extraCss as $css): ?>
    <link href="<?= SITE_URL ?>/<?= $css ?>" rel="stylesheet">
    <?php endforeach; ?>
    <?php endif; ?>
</head>
<body>
    <nav class="navbar navbar-expand-lg sticky-top">
        <div class="container">
            <a class="navbar-brand" href="<?= SITE_URL ?>">
                <img src="<?= SITE_URL ?>/assets/images/logo_light.png" alt="<?= SITE_NAME ?>" class="logo-light">
                <img src="<?= SITE_URL ?>/assets/images/logo_dark.png" alt="<?= SITE_NAME ?>" class="logo-dark">
            </a>
            
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link <?= basename($_SERVER['PHP_SELF']) == 'index.php' ? 'active' : '' ?>" href="<?= SITE_URL ?>"><?= __('home') ?></a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link <?= basename($_SERVER['PHP_SELF']) == 'properties.php' ? 'active' : '' ?>" href="<?= SITE_URL ?>/properties.php"><?= __('properties') ?></a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link <?= basename($_SERVER['PHP_SELF']) == 'cars.php' ? 'active' : '' ?>" href="<?= SITE_URL ?>/cars.php"><?= __('cars') ?></a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<?= SITE_URL ?>/about.php"><?= __('about') ?></a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="<?= SITE_URL ?>/contact.php"><?= __('contact') ?></a>
                    </li>
                </ul>
                
                <div class="d-flex align-items-center gap-2">
                    <div class="dropdown lang-switcher">
                        <button class="btn btn-sm dropdown-toggle" type="button" data-bs-toggle="dropdown">
                            <?= LANG_NAMES[$lang] ?? 'العربية' ?>
                        </button>
                        <ul class="dropdown-menu">
                            <?php foreach (SUPPORTED_LANGS as $langCode): ?>
                            <li><a class="dropdown-item <?= $lang == $langCode ? 'active' : '' ?>" href="?lang=<?= $langCode ?>"><?= LANG_NAMES[$langCode] ?></a></li>
                            <?php endforeach; ?>
                        </ul>
                    </div>
                    
                    <?php if (isset($_SESSION['user'])): ?>
                    <div class="dropdown">
                        <button class="btn btn-outline-primary btn-sm dropdown-toggle" type="button" data-bs-toggle="dropdown">
                            <i class="bi bi-person-circle me-1"></i>
                            <?= htmlspecialchars($_SESSION['user']['name'] ?? __('my_account')) ?>
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end">
                            <li><a class="dropdown-item" href="<?= SITE_URL ?>/profile.php"><i class="bi bi-person me-2"></i><?= __('my_account') ?></a></li>
                            <li><a class="dropdown-item" href="<?= SITE_URL ?>/packages.php"><i class="bi bi-box-seam me-2"></i><?= __('packages') ?></a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item text-danger" href="<?= SITE_URL ?>/profile.php?action=logout"><i class="bi bi-box-arrow-left me-2"></i><?= __('logout') ?></a></li>
                        </ul>
                    </div>
                    <?php else: ?>
                    <a href="<?= SITE_URL ?>/login.php" class="btn btn-outline-primary btn-sm">
                        <i class="bi bi-box-arrow-in-left me-1"></i><?= __('login') ?>
                    </a>
                    <?php endif; ?>
                    
                    <a href="<?= SITE_URL ?>/download.php" class="btn btn-primary btn-sm">
                        <i class="bi bi-download"></i>
                        <?= __('download_app') ?>
                    </a>
                </div>
            </div>
        </div>
    </nav>
