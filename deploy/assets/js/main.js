/**
 * Rento Go - Main JavaScript
 */

// API Configuration
const API_URL = document.querySelector('meta[name="api-url"]')?.content || '/rento_go/backend/api';
const UPLOAD_URL = document.querySelector('meta[name="upload-url"]')?.content || '/rento_go/uploads/';

// DOM Ready
document.addEventListener('DOMContentLoaded', function() {
    initNavbar();
    initSearch();
    initFilters();
    initGallery();
    initFavorites();
    initLoadMore();
});

// Navbar scroll effect
function initNavbar() {
    const navbar = document.querySelector('.navbar');
    if (!navbar) return;
    
    window.addEventListener('scroll', function() {
        if (window.scrollY > 50) {
            navbar.classList.add('shadow-sm');
        } else {
            navbar.classList.remove('shadow-sm');
        }
    });
}

// Search functionality
function initSearch() {
    const searchForm = document.getElementById('searchForm');
    if (!searchForm) return;
    
    searchForm.addEventListener('submit', function(e) {
        e.preventDefault();
        const formData = new FormData(this);
        const params = new URLSearchParams(formData).toString();
        
        const type = formData.get('type') || 'properties';
        window.location.href = `${type}.php?${params}`;
    });
}

// Filters
function initFilters() {
    const filterForm = document.getElementById('filterForm');
    if (!filterForm) return;
    
    // Auto-submit on change
    const autoSubmitElements = filterForm.querySelectorAll('.auto-submit');
    autoSubmitElements.forEach(el => {
        el.addEventListener('change', function() {
            filterForm.submit();
        });
    });
    
    // Region-City linking
    initRegionCityLink();
    
    // Price range
    const priceMin = document.getElementById('priceMin');
    const priceMax = document.getElementById('priceMax');
    
    if (priceMin && priceMax) {
        priceMin.addEventListener('change', validatePriceRange);
        priceMax.addEventListener('change', validatePriceRange);
    }
}

function initRegionCityLink() {
    const regionSelect = document.querySelector('select[name="region_id"]');
    const citySelect = document.getElementById('citySelect');
    if (!regionSelect || !citySelect) return;
    
    const allCityOptions = Array.from(citySelect.querySelectorAll('option[data-region]'));
    const defaultOption = citySelect.querySelector('option[value=""]');
    
    function filterCities() {
        const selectedRegion = regionSelect.value;
        const currentCityValue = citySelect.value;
        
        // Remove all city options except the default
        allCityOptions.forEach(opt => opt.remove());
        
        // Add back matching cities
        const matchingCities = selectedRegion 
            ? allCityOptions.filter(opt => opt.dataset.region === selectedRegion)
            : allCityOptions;
        
        matchingCities.forEach(opt => citySelect.appendChild(opt));
        
        // Reset city selection if current city doesn't belong to selected region
        if (selectedRegion && currentCityValue) {
            const cityExists = matchingCities.some(opt => opt.value === currentCityValue);
            if (!cityExists) {
                citySelect.value = '';
            }
        }
    }
    
    regionSelect.addEventListener('change', function() {
        filterCities();
        citySelect.value = '';
    });
    
    // Apply filter on page load
    filterCities();
}

function validatePriceRange() {
    const min = parseInt(document.getElementById('priceMin').value) || 0;
    const max = parseInt(document.getElementById('priceMax').value) || Infinity;
    
    if (min > max && max > 0) {
        document.getElementById('priceMax').value = min;
    }
}

// Image Gallery
function initGallery() {
    const mainImage = document.getElementById('mainImage');
    const thumbnails = document.querySelectorAll('.gallery-thumb');
    
    if (!mainImage || !thumbnails.length) return;
    
    thumbnails.forEach(thumb => {
        thumb.addEventListener('click', function() {
            const src = this.dataset.src;
            mainImage.src = src;
            
            thumbnails.forEach(t => t.classList.remove('active'));
            this.classList.add('active');
        });
    });
}

// Favorites
function initFavorites() {
    const favButtons = document.querySelectorAll('.favorite-btn');
    
    favButtons.forEach(btn => {
        btn.addEventListener('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            
            const listingId = this.dataset.id;
            const listingType = this.dataset.type;
            
            toggleFavorite(listingId, listingType, this);
        });
    });
}

async function toggleFavorite(id, type, btn) {
    try {
        const response = await fetch(`${API_URL}/favorites`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            credentials: 'include',
            body: JSON.stringify({
                listing_type: type,
                listing_id: id
            })
        });
        
        const data = await response.json();
        
        if (data.success) {
            btn.classList.toggle('active');
            const icon = btn.querySelector('i');
            if (btn.classList.contains('active')) {
                icon.classList.remove('bi-heart');
                icon.classList.add('bi-heart-fill');
            } else {
                icon.classList.remove('bi-heart-fill');
                icon.classList.add('bi-heart');
            }
        }
    } catch (error) {
        console.error('Error toggling favorite:', error);
    }
}

// Load More
function initLoadMore() {
    const loadMoreBtn = document.getElementById('loadMoreBtn');
    if (!loadMoreBtn) return;
    
    loadMoreBtn.addEventListener('click', function() {
        const currentPage = parseInt(this.dataset.page) || 1;
        const nextPage = currentPage + 1;
        const type = this.dataset.type;
        
        loadMoreListings(type, nextPage, this);
    });
}

async function loadMoreListings(type, page, btn) {
    btn.disabled = true;
    btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span> جاري التحميل...';
    
    try {
        const urlParams = new URLSearchParams(window.location.search);
        urlParams.set('page', page);
        
        const response = await fetch(`${API_URL}/${type}?${urlParams.toString()}`);
        const data = await response.json();
        
        if (data.success && data.data.length > 0) {
            const container = document.getElementById('listingsContainer');
            
            data.data.forEach(listing => {
                container.insertAdjacentHTML('beforeend', createListingCard(listing));
            });
            
            btn.dataset.page = page;
            btn.disabled = false;
            btn.innerHTML = 'تحميل المزيد';
            
            // Hide button if no more pages
            if (!data.pagination.has_more) {
                btn.style.display = 'none';
            }
            
            // Re-init favorites for new cards
            initFavorites();
        } else {
            btn.style.display = 'none';
        }
    } catch (error) {
        console.error('Error loading more:', error);
        btn.disabled = false;
        btn.innerHTML = 'تحميل المزيد';
    }
}

function createListingCard(listing) {
    const type = listing.type || 'property';
    const thumbnail = listing.thumbnail || 'assets/images/placeholder.jpg';
    const price = formatPrice(listing.price);
    const location = `${listing.city_name_ar || ''}, ${listing.region_name_ar || ''}`;
    
    let features = '';
    if (type === 'property') {
        if (listing.bedrooms) features += `<span><i class="bi bi-door-open"></i> ${listing.bedrooms}</span>`;
        if (listing.area_m2) features += `<span><i class="bi bi-arrows-angle-expand"></i> ${listing.area_m2} م²</span>`;
    } else {
        if (listing.model) features += `<span><i class="bi bi-car-front"></i> ${listing.model}</span>`;
        if (listing.year) features += `<span><i class="bi bi-calendar"></i> ${listing.year}</span>`;
    }
    
    return `
        <div class="col-md-6 col-lg-4 mb-4">
            <a href="details.php?type=${type}&id=${listing.id}" class="text-decoration-none">
                <div class="card listing-card">
                    <div class="card-img-container">
                        <img src="${thumbnail}" class="card-img-top" alt="${listing.title || 'إعلان'}">
                        <span class="badge-type">للإيجار</span>
                        <button class="favorite-btn" data-id="${listing.id}" data-type="${type}">
                            <i class="bi bi-heart"></i>
                        </button>
                    </div>
                    <div class="card-body">
                        <div class="listing-location">
                            <i class="bi bi-geo-alt"></i> ${location}
                        </div>
                        <div class="listing-price">${price} <small>/ شهري</small></div>
                        <div class="listing-features">${features}</div>
                    </div>
                </div>
            </a>
        </div>
    `;
}

// Utility Functions
function formatPrice(price) {
    if (!price) return 'اتصل للسعر';
    return new Intl.NumberFormat('ar-SA').format(price) + ' ₪';
}

function showToast(message, type = 'info') {
    const toastContainer = document.getElementById('toastContainer') || createToastContainer();
    
    const toast = document.createElement('div');
    toast.className = `toast align-items-center text-white bg-${type} border-0`;
    toast.setAttribute('role', 'alert');
    toast.innerHTML = `
        <div class="d-flex">
            <div class="toast-body">${message}</div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
        </div>
    `;
    
    toastContainer.appendChild(toast);
    
    const bsToast = new bootstrap.Toast(toast);
    bsToast.show();
    
    toast.addEventListener('hidden.bs.toast', () => toast.remove());
}

function createToastContainer() {
    const container = document.createElement('div');
    container.id = 'toastContainer';
    container.className = 'toast-container position-fixed bottom-0 end-0 p-3';
    document.body.appendChild(container);
    return container;
}

// Contact Actions
function callPhone(phone) {
    window.location.href = `tel:${phone}`;
}

function openWhatsApp(phone, message = '') {
    const cleanPhone = phone.replace(/[^0-9]/g, '');
    const url = `https://wa.me/${cleanPhone}?text=${encodeURIComponent(message)}`;
    window.open(url, '_blank');
}

// Share
function shareListing(title, url) {
    if (navigator.share) {
        navigator.share({
            title: title,
            url: url
        });
    } else {
        copyToClipboard(url);
        showToast('تم نسخ الرابط', 'success');
    }
}

function copyToClipboard(text) {
    navigator.clipboard.writeText(text);
}
