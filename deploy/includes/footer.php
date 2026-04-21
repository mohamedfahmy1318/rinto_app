    <footer class="footer">
        <div class="container">
            <div class="row">
                <div class="col-lg-4 mb-4">
                    <h5><i class="bi bi-house-heart-fill"></i> <?= SITE_NAME ?></h5>
                    <p><?= __('site_description') ?></p>
                    <div class="social-links mt-3">
                        <a href="#"><i class="bi bi-facebook"></i></a>
                        <a href="#"><i class="bi bi-instagram"></i></a>
                        <a href="#"><i class="bi bi-twitter-x"></i></a>
                        <a href="#"><i class="bi bi-youtube"></i></a>
                    </div>
                </div>
                
                <div class="col-lg-2 col-md-4 mb-4">
                    <h5><?= __('quick_links') ?></h5>
                    <ul class="footer-links">
                        <li><a href="<?= SITE_URL ?>"><?= __('home') ?></a></li>
                        <li><a href="<?= SITE_URL ?>/properties.php"><?= __('properties') ?></a></li>
                        <li><a href="<?= SITE_URL ?>/cars.php"><?= __('cars') ?></a></li>
                        <li><a href="<?= SITE_URL ?>/download.php"><?= __('download_app') ?></a></li>
                    </ul>
                </div>
                
                <div class="col-lg-2 col-md-4 mb-4">
                    <h5><?= __('properties') ?></h5>
                    <ul class="footer-links">
                        <li><a href="<?= SITE_URL ?>/properties.php?type=apartment"><?= __('apartments') ?></a></li>
                        <li><a href="<?= SITE_URL ?>/properties.php?type=villa_chalet"><?= __('villas_chalets') ?></a></li>
                        <li><a href="<?= SITE_URL ?>/properties.php?type=shop_office"><?= __('shops_offices') ?></a></li>
                        <li><a href="<?= SITE_URL ?>/properties.php?type=student_housing"><?= __('student_housing') ?></a></li>
                    </ul>
                </div>
                
                <div class="col-lg-2 col-md-4 mb-4">
                    <h5><?= __('cars') ?></h5>
                    <ul class="footer-links">
                        <li><a href="<?= SITE_URL ?>/cars.php?type=daily"><?= __('daily_use') ?></a></li>
                        <li><a href="<?= SITE_URL ?>/cars.php?type=wedding"><?= __('wedding') ?></a></li>
                        <li><a href="<?= SITE_URL ?>/cars.php?type=tourism"><?= __('tourism') ?></a></li>
                    </ul>
                </div>
                
                <div class="col-lg-2 col-md-4 mb-4">
                    <h5><?= __('contact') ?></h5>
                    <ul class="footer-links">
                        <li><a href="<?= SITE_URL ?>/about.php"><?= __('about') ?></a></li>
                        <li><a href="<?= SITE_URL ?>/contact.php"><?= __('contact') ?></a></li>
                        <li><a href="<?= SITE_URL ?>/privacy.php"><?= __('privacy_policy') ?></a></li>
                        <li><a href="<?= SITE_URL ?>/terms.php"><?= __('terms') ?></a></li>
                    </ul>
                </div>
            </div>
            
            <div class="footer-bottom">
                <p>&copy; <?= date('Y') ?> <?= SITE_NAME ?>. <?= __('all_rights_reserved') ?></p>
            </div>
        </div>
    </footer>
    
    <a href="https://wa.me/972501234567" class="whatsapp-float" target="_blank">
        <i class="bi bi-whatsapp"></i>
    </a>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    <script src="<?= SITE_URL ?>/assets/js/main.js"></script>
    <?php if (isset($extraJs) && is_array($extraJs)): ?>
    <?php foreach ($extraJs as $js): ?>
    <script src="<?= SITE_URL ?>/<?= $js ?>"></script>
    <?php endforeach; ?>
    <?php endif; ?>
</body>
</html>
