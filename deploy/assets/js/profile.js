/**
 * Profile Page - JavaScript
 * Rento Go
 */

document.addEventListener('DOMContentLoaded', function() {
    // Initialize components
    initTabs();
    initListingCards();
    initSettings();
    initAnimations();
});

/**
 * Tab Navigation
 */
function initTabs() {
    const tabLinks = document.querySelectorAll('[data-bs-toggle="list"]');
    const tabPanes = document.querySelectorAll('.tab-pane');
    
    tabLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            
            // Remove active from all
            tabLinks.forEach(l => l.classList.remove('active'));
            tabPanes.forEach(p => {
                p.classList.remove('show', 'active');
            });
            
            // Add active to clicked
            this.classList.add('active');
            
            // Show target pane
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.classList.add('show', 'active');
                
                // Animate cards in the tab
                animateCardsIn(target);
            }
            
            // Update URL hash
            history.replaceState(null, null, this.getAttribute('href'));
        });
    });
    
    // Check URL hash on load
    const hash = window.location.hash;
    if (hash) {
        const targetTab = document.querySelector(`[href="${hash}"]`);
        if (targetTab) {
            targetTab.click();
        }
    }
}

/**
 * Listing Cards Interactions
 */
function initListingCards() {
    const cards = document.querySelectorAll('.listing-card-profile');
    
    cards.forEach(card => {
        // Delete button (if exists)
        const deleteBtn = card.querySelector('.btn-delete');
        if (deleteBtn) {
            deleteBtn.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                
                if (confirm('هل أنت متأكد من حذف هذا الإعلان؟')) {
                    deleteListingCard(card);
                }
            });
        }
    });
}

/**
 * Delete listing card with animation
 */
function deleteListingCard(card) {
    card.style.transform = 'scale(0.8)';
    card.style.opacity = '0';
    
    setTimeout(() => {
        card.remove();
        updateListingsCount();
    }, 300);
}

/**
 * Update listings count
 */
function updateListingsCount() {
    const countEl = document.querySelector('.listings-count');
    const cards = document.querySelectorAll('.listing-card-profile');
    
    if (countEl) {
        countEl.textContent = cards.length;
    }
    
    // Show empty state if no cards
    if (cards.length === 0) {
        const container = document.querySelector('.listings-grid');
        if (container) {
            container.innerHTML = `
                <div class="col-12">
                    <div class="empty-state">
                        <div class="empty-state-icon">
                            <i class="bi bi-inbox"></i>
                        </div>
                        <h6>لا توجد إعلانات حالياً</h6>
                    </div>
                </div>
            `;
        }
    }
}

/**
 * Settings interactions
 */
function initSettings() {
    const API_URL = document.querySelector('meta[name="api-url"]')?.content || '/backend/api';
    
    // Edit Profile Form
    const editProfileForm = document.querySelector('#editProfileForm');
    if (editProfileForm) {
        editProfileForm.addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const formData = new FormData(this);
            const data = Object.fromEntries(formData.entries());
            const btn = this.querySelector('button[type="submit"]');
            const originalText = btn.innerHTML;
            
            btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> جاري الحفظ...';
            btn.disabled = true;
            
            try {
                const response = await fetch('/profile-action.php', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ action: 'update_profile', ...data })
                });
                
                const result = await response.json();
                
                if (result.success) {
                    showToast('تم حفظ التغييرات بنجاح', 'success');
                    // Update displayed name
                    const nameEl = document.querySelector('.profile-name');
                    if (nameEl && data.name) nameEl.textContent = data.name;
                } else {
                    showToast(result.message || 'حدث خطأ', 'error');
                }
            } catch (error) {
                showToast('حدث خطأ في الاتصال', 'error');
            } finally {
                btn.innerHTML = originalText;
                btn.disabled = false;
            }
        });
    }
    
    // Change Password Form
    const changePasswordForm = document.querySelector('#changePasswordForm');
    if (changePasswordForm) {
        changePasswordForm.addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const formData = new FormData(this);
            const data = Object.fromEntries(formData.entries());
            
            // Validate passwords match
            if (data.new_password !== data.confirm_password) {
                showToast('كلمات المرور غير متطابقة', 'error');
                return;
            }
            
            if (data.new_password.length < 6) {
                showToast('كلمة المرور يجب أن تكون 6 أحرف على الأقل', 'error');
                return;
            }
            
            const btn = this.querySelector('button[type="submit"]');
            const originalText = btn.innerHTML;
            
            btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> جاري التغيير...';
            btn.disabled = true;
            
            try {
                const response = await fetch('/profile-action.php', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ action: 'change_password', ...data })
                });
                
                const result = await response.json();
                
                if (result.success) {
                    showToast('تم تغيير كلمة المرور بنجاح', 'success');
                    this.reset();
                } else {
                    showToast(result.message || 'حدث خطأ', 'error');
                }
            } catch (error) {
                showToast('حدث خطأ في الاتصال', 'error');
            } finally {
                btn.innerHTML = originalText;
                btn.disabled = false;
            }
        });
    }
    
    // Notification toggle
    const notifToggle = document.querySelector('#notificationToggle');
    if (notifToggle) {
        notifToggle.addEventListener('change', async function() {
            const enabled = this.checked;
            
            try {
                await fetch('/profile-action.php', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ action: 'toggle_notifications', enabled })
                });
                showToast(enabled ? 'تم تفعيل الإشعارات' : 'تم إيقاف الإشعارات');
            } catch (error) {
                showToast('حدث خطأ', 'error');
            }
        });
    }
}

/**
 * Animations
 */
function initAnimations() {
    // Only animate profile-card on initial load, not listing cards
    const profileCards = document.querySelectorAll('#profile .profile-card');
    
    profileCards.forEach((el, index) => {
        el.style.opacity = '0';
        el.style.transform = 'translateY(20px)';
        
        setTimeout(() => {
            el.style.transition = 'all 0.4s ease';
            el.style.opacity = '1';
            el.style.transform = 'translateY(0)';
        }, index * 100);
    });
}

/**
 * Animate cards when tab becomes visible
 */
function animateCardsIn(container) {
    // Don't animate listing cards to avoid image flickering
    const cards = container.querySelectorAll('.profile-card');
    
    cards.forEach((card, index) => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        
        setTimeout(() => {
            card.style.transition = 'all 0.4s ease';
            card.style.opacity = '1';
            card.style.transform = 'translateY(0)';
        }, index * 100);
    });
}

/**
 * Show toast notification
 */
function showToast(message, type = 'success') {
    // Remove existing toast
    const existingToast = document.querySelector('.profile-toast');
    if (existingToast) {
        existingToast.remove();
    }
    
    // Create toast
    const toast = document.createElement('div');
    toast.className = `profile-toast toast-${type}`;
    toast.innerHTML = `
        <i class="bi bi-${type === 'success' ? 'check-circle' : 'exclamation-circle'}"></i>
        <span>${message}</span>
    `;
    
    // Style toast
    Object.assign(toast.style, {
        position: 'fixed',
        bottom: '20px',
        right: '20px',
        background: type === 'success' ? '#4CAF50' : '#F44336',
        color: 'white',
        padding: '15px 25px',
        borderRadius: '12px',
        boxShadow: '0 5px 20px rgba(0,0,0,0.2)',
        display: 'flex',
        alignItems: 'center',
        gap: '10px',
        zIndex: '9999',
        animation: 'slideInRight 0.3s ease'
    });
    
    document.body.appendChild(toast);
    
    // Remove after 3 seconds
    setTimeout(() => {
        toast.style.animation = 'slideOutRight 0.3s ease';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

/**
 * Add CSS animations dynamically
 */
const style = document.createElement('style');
style.textContent = `
    @keyframes slideInRight {
        from {
            transform: translateX(100%);
            opacity: 0;
        }
        to {
            transform: translateX(0);
            opacity: 1;
        }
    }
    
    @keyframes slideOutRight {
        from {
            transform: translateX(0);
            opacity: 1;
        }
        to {
            transform: translateX(100%);
            opacity: 0;
        }
    }
    
    .animate-in {
        opacity: 1 !important;
        transform: translateY(0) !important;
        transition: all 0.5s ease;
    }
`;
document.head.appendChild(style);

/**
 * Image upload preview (for future use)
 */
function previewImage(input, previewElement) {
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        
        reader.onload = function(e) {
            previewElement.src = e.target.result;
            previewElement.style.display = 'block';
        };
        
        reader.readAsDataURL(input.files[0]);
    }
}

/**
 * Copy to clipboard utility
 */
function copyToClipboard(text) {
    navigator.clipboard.writeText(text).then(() => {
        showToast('تم النسخ بنجاح');
    }).catch(() => {
        showToast('فشل النسخ', 'error');
    });
}
