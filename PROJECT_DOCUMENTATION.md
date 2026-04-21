# Rento Go — Project Documentation

> **منصة إيجار العقارات والسيارات**
> A trilingual (Arabic, English, Hebrew) property and car rental marketplace for the Palestinian and Israeli market.

---

## 1. Project Overview

### Project Name
**Rento Go** (`rento_go`)

### One-Line Pitch
A mobile-first classified marketplace where property owners, car lessors, and real estate offices list properties and vehicles for rent, and renters browse, search, and contact listers — with a subscription-based monetization model and admin-controlled approval workflow.

### Purpose
Rento Go aggregates the fragmented rental market (apartments, villas, student housing, commercial spaces, land, and cars) into a single trilingual platform. It replaces informal WhatsApp groups and Facebook marketplace posts with a structured, searchable, and administered listing system.

### Problem It Solves
- **Fragmentation**: Rental listings are scattered across social media, paper flyers, and word-of-mouth.
- **No trilingual support**: Existing platforms rarely support Arabic, Hebrew, and English simultaneously with proper RTL layout.
- **No quality control**: No admin approval workflow means spam and fraudulent listings proliferate.
- **No monetization layer**: Existing solutions lack a structured subscription/packaging model for listers.

### Target Users / Personas

| Persona | Arabic Name | Description |
|---------|-------------|-------------|
| **Renter** (مستأجر) | مستأجر | Individuals looking to rent apartments, student housing, or cars. Browse-only until they register. |
| **Property Owner** (مالك عقار) | مالك عقار | Individuals who own one or more properties and want to list them for rent. |
| **Car Lessor** (مؤجر سيارات) | مؤجر سيارات | Individuals or small businesses renting out vehicles (daily, wedding, tourism). |
| **Real Estate Office** (مكتب عقارات) | مكتب عقارات | Professional agencies managing multiple property and car listings. |
| **Admin** | مدير النظام | Platform administrators who approve listings, manage users, and configure plans. |

### Current Status
**Beta** — Version `1.1.0+19`. The app is being submitted to both Apple App Store and Google Play Store. A production backend is live at `rento-go.com`. Real users and seed data exist in the database.

---

## 2. Business Context

### Business Model & Revenue Strategy
Rento Go uses a **freemium/subscription model**:

1. **Free tier**: Any user can register and browse all listings. Creating a listing is free, but the listing stays in `draft` status.
2. **Paid subscription**: To activate/publish a listing, the user must purchase a subscription plan. Plans are sold as:
   - **Single listing plans**: One listing of a specific type (e.g., "Single Apartment Ad" — 50 ₪ for 30 days).
   - **Package plans**: Bundles of multiple listings with badge tiers (Bronze/Silver/Gold) and volume discounts (e.g., "Gold Package" — 500 ₪ for unlimited listings for 30 days).
3. **Platform revenue**: 100% of subscription fees. No commission on rental transactions.
4. **Payment channels**: In-app purchase (Apple App Store / Google Play) and admin-verified manual payments.

### Key Stakeholders

| Stakeholder | Role |
|-------------|------|
| Product Owner | Defines feature priorities, manages business relationships, and oversees content moderation. |
| Super Admin | Full system access: user management, listing approval, plan configuration, financial reports. |
| Moderators | Review and approve/reject listings; handle user reports. |
| Mobile Developers | Build and maintain the Flutter app. |
| Backend Developer | Maintain the PHP API, admin dashboard, and database. |

### Success Metrics & KPIs

| Metric | Target |
|--------|--------|
| Monthly Active Users (MAU) | Growth-stage — tracking user registrations per week. |
| Listings created per month | Baseline being established. |
| Subscription conversion rate | % of registered users who purchase at least one plan. |
| Listing approval turnaround time | < 24 hours from submission to admin review. |
| App Store rating | ≥ 4.0 stars. |
| Churn rate | < 15% monthly for subscribed users. |

### Constraints

| Constraint | Details |
|------------|---------|
| **Budget** | Bootstrapped; shared hosting (cPanel), no cloud autoscaling. |
| **Timeline** | Store submission imminent; app must pass Apple/Google review. |
| **Compliance** | Apple requires account deletion capability (implemented). GDPR-adjacent privacy requirements for data deletion. |
| **Legal** | Platform is an advertising platform only — no involvement in contracts or payments between renters and listers (see CMS Disclaimer page). |
| **Currency** | All prices in Israeli New Shekel (ILS / ₪). |

### Competitive Landscape

| Competitor | Type | Differentiator vs. Rento Go |
|------------|------|----------------------------|
| **Facebook Marketplace** | Indirect | Generic; no trilingual support, no admin review, no structured data. |
| **WhatsApp Groups** | Indirect | Unstructured; no search/filter, no media gallery. |
| **Yad2** | Direct (Israel) | Hebrew-only; no Arabic/RTL-first experience; not mobile-native. |
| **OpenSooq** | Direct (Arab world) | Pan-Arab; not focused on local Palestinian/Israeli market; no Hebrew. |
| **Agoda/Booking** | Indirect (tourism) | Hotel-focused; not peer-to-peer rental. |

---

## 3. Functional Requirements

### Feature List

#### P0 — Must Have (Shipped)

| # | Feature | Status |
|---|---------|--------|
| 1 | User registration (name, email, phone, password, user_type, optional region/city) | ✅ |
| 2 | User login (phone or email + password) | ✅ |
| 3 | JWT-based authentication with token persistence | ✅ |
| 4 | Browse property listings with pagination & infinite scroll | ✅ |
| 5 | Browse car listings with pagination & infinite scroll | ✅ |
| 6 | Search listings by keyword (title, bio, model) | ✅ |
| 7 | Filter by region, city, property type, car usage type | ✅ |
| 8 | Listing detail view with image gallery, price, contact info | ✅ |
| 9 | Create property listing (title, type, location, price, bedrooms, bio, images) | ✅ |
| 10 | Create car listing (model, year, gearbox, usage type, price, driver option, images) | ✅ |
| 11 | Edit own listing | ✅ |
| 12 | Delete own listing | ✅ |
| 13 | My Listings management (view all own listings with status) | ✅ |
| 14 | Favorites (add/remove, view list) | ✅ |
| 15 | Subscription plans browse & purchase flow | ✅ |
| 16 | In-app purchase (iOS via StoreKit, Android via Google Play Billing) | ✅ |
| 17 | Admin-verified manual subscription requests | ✅ |
| 18 | Push notifications via Firebase Cloud Messaging (FCM) | ✅ |
| 19 | Light/Dark theme toggle with persistence | ✅ |
| 20 | Language switching (Arabic, English, Hebrew) with RTL support | ✅ |
| 21 | Admin dashboard with listing approval workflow | ✅ |
| 22 | Admin user management (block, trust, approve) | ✅ |
| 23 | Admin notification system (direct, broadcast, segment) | ✅ |
| 24 | CMS pages (Privacy Policy, Terms of Service, Disclaimer) | ✅ |
| 25 | Account deletion (App Store requirement) | ✅ |

#### P1 — Should Have (Partially Shipped)

| # | Feature | Status |
|---|---------|--------|
| 26 | In-app chat (conversations between users about listings) | ✅ Basic |
| 27 | Realtime message polling | ✅ Polling-based |
| 28 | Banner/featured listings on home screen | ✅ |
| 29 | Listing pause/resume toggle | ✅ |
| 30 | Listing renewal after expiry | ✅ |
| 31 | Listing "rented" toggle | ✅ |
| 32 | Report listing/user | ✅ |
| 33 | OTP phone verification | ✅ |
| 34 | Forgot/reset password flow | ✅ |
| 35 | Profile editing (name, phone, email, password, profile image) | ✅ |

#### P2 — Nice to Have (Planned / Partial)

| # | Feature | Status |
|---|---------|--------|
| 36 | WebSocket-based realtime chat | 🔧 Server file exists, not integrated |
| 37 | Map view for listings | ❌ Not implemented |
| 38 | Advanced search (price range, area, bedrooms) | ❌ Not implemented |
| 39 | User reviews/ratings | ❌ Not implemented |
| 40 | Email verification with OTP | 🔧 Endpoint exists, not enforced |

### User Stories

**Renter**:
- "As a renter, I want to search for apartments in Ramallah so that I can find affordable housing near my workplace."
- "As a renter, I want to save listings to favorites so that I can compare them later."
- "As a renter, I want to contact the property owner via phone or WhatsApp so that I can schedule a viewing."
- "As a renter, I want to switch the app to Hebrew so that I can read listings in my preferred language."

**Property Owner**:
- "As a property owner, I want to create a listing with photos and description so that renters can find my property."
- "As a property owner, I want to purchase a subscription plan so that my listing becomes visible to all users."
- "As a property owner, I want to mark my property as rented so that I stop receiving inquiries."
- "As a property owner, I want to renew my expired listing so that it becomes active again without re-creating it."

**Car Lessor**:
- "As a car lessor, I want to list my wedding car with a 'with driver' option so that clients know the service includes a driver."
- "As a car lessor, I want to see how many views my listing has so that I can gauge interest."

**Admin**:
- "As an admin, I want to review pending listings and approve or reject them with a reason so that only quality content appears on the platform."
- "As an admin, I want to send push notifications to all users so that I can announce platform updates."
- "As an admin, I want to manage subscription plans (pricing, duration, limits) so that I can adjust the business model."

### Out-of-Scope Items
- **Direct payment between renter and lister**: The platform does not process rental payments.
- **Booking/calendar system**: No date-based availability or reservation system.
- **Multi-currency**: Only ILS (₪) is supported.
- **Geolocation/GPS**: No map pins or proximity search.
- **Social login**: No Google/Apple/Facebook sign-in.
- **Multi-tenant white-labeling**: Single-brand platform only.

### Edge Cases & Known Limitations
- A user can have multiple pending subscription requests for different plan categories but only one pending request per category.
- Listings without a linked subscription remain in `draft` status indefinitely.
- Image upload uses base64 encoding from the mobile app, which limits file size to the PHP `max_upload_size` and `post_max_size` settings.
- Conversations link to a specific listing; if the listing is deleted, the conversation persists but with a broken reference.
- FCM notifications are only initialized on Android; iOS notification permissions are requested but FCM token saving is Android-only in the current implementation.

---

## 4. Technical Architecture

### Tech Stack

| Layer | Technology | Version / Notes |
|-------|-----------|-----------------|
| **Mobile App** | Flutter (Dart) | SDK ≥ 3.8.1, v1.1.0+19 |
| **State Management** | Provider (ChangeNotifier) | `provider: ^6.1.1` |
| **Navigation** | go_router | `^13.0.0` (declared; screens use Navigator push) |
| **Backend API** | PHP | 8.4.x (production) |
| **Database** | MariaDB | 10.11.15 |
| **Admin Dashboard** | PHP + HTML/CSS/JS | Server-rendered pages |
| **Web Frontend** | PHP + HTML/CSS/JS | Public-facing website |
| **Push Notifications** | Firebase Cloud Messaging | `firebase_messaging: ^14.7.15` |
| **In-App Purchase** | StoreKit (iOS) + Google Play Billing (Android) | `in_app_purchase: ^3.1.13` |
| **Image Handling** | `image_picker`, `flutter_image_compress`, `cached_network_image` | Client-side compress, server-side file storage |
| **Hosting** | Shared cPanel hosting | Apache + MariaDB |
| **Domain** | `rento-go.com` | Production API + uploads |
| **Local Dev** | XAMPP | Apache + MySQL on localhost |

### System Architecture (Component Diagram)

```
┌─────────────────────────────────────────────────────────┐
│                    MOBILE APP (Flutter)                   │
│  ┌──────────┐  ┌──────────┐  ┌───────────┐  ┌────────┐ │
│  │ Screens  │  │Providers │  │ Services  │  │ Models │ │
│  │ (UI)     │←→│ (State)  │←→│ (API/FCM) │  │ (Data) │ │
│  └──────────┘  └──────────┘  └─────┬─────┘  └────────┘ │
└────────────────────────────────────┬────────────────────┘
                                     │ HTTPS (REST JSON)
                                     ▼
┌─────────────────────────────────────────────────────────┐
│               BACKEND API (PHP / Apache)                 │
│  ┌──────────┐  ┌────────────┐  ┌──────────────────────┐│
│  │ Router   │→ │Controllers │→ │ Helpers              ││
│  │(index.php│  │(Auth,List, │  │(JWT, Response,       ││
│  │ switch)  │  │ Plan, etc.)│  │ Validator, Upload)   ││
│  └──────────┘  └─────┬──────┘  └──────────────────────┘│
│                      │ PDO                               │
│                      ▼                                   │
│            ┌─────────────────┐                           │
│            │   MariaDB       │                           │
│            │   (rentogo_1)   │                           │
│            └─────────────────┘                           │
└─────────────────────────────────────────────────────────┘
           ▲                         ▲
           │ HTTP (browser)          │ FCM (HTTP v1)
           │                         │
┌──────────┴───────┐      ┌─────────┴──────────┐
│  Admin Dashboard │      │  Firebase Cloud     │
│  (PHP/HTML)      │      │  Messaging          │
│  /admin/         │      │  (Google servers)   │
└──────────────────┘      └────────────────────┘
```

### Data Flow: User Creates a Property Listing

```
1. User fills form in AddListingScreen (Flutter)
2. Images are picked via image_picker, compressed via flutter_image_compress
3. Images uploaded as base64 to POST /uploads/image → returns file_path
4. Form data + file_paths POST to /properties → PropertyController::store()
5. Controller validates input, authenticates user via JWT
6. INSERT into `properties` table with status='draft'
7. INSERT each image into `property_media` table
8. API returns { success: true, data: { id, status: 'draft' } }
9. User is prompted to purchase a subscription plan
10. User selects plan → POST /subscriptions/requests (or IAP flow)
11. Admin reviews request in admin dashboard → approves
12. Backend creates `subscriptions` row, links to listing, sets status='active', sets expires_at
13. FCM notification sent to user: "Your listing is approved"
14. Listing appears in public feed (GET /listings?tab=properties)
```

### API Design: Key Endpoints

#### Authentication

```
POST /auth/register
  Body: { name, company_name?, email, phone, password, user_type, region_id?, city_id? }
  Response: { success, data: { token, user, requires_approval?, requires_verification? } }

POST /auth/login
  Body: { login (phone or email), password }
  Response: { success, data: { token, user } }

POST /auth/forgot-password
  Body: { phone }

POST /auth/reset-password
  Body: { phone, otp, password }

POST /auth/verify-phone
  Body: { phone, otp }

POST /auth/resend-otp
  Body: { phone, type }

POST /auth/delete-account
  Headers: Authorization: Bearer <token>
```

#### Listings (Unified Feed)

```
GET /listings?tab=properties|cars&page=1&lang=ar&region_id=1&city_id=2&type=apartment&search=فاخرة
  Response: { success, data: [ListingModel...], pagination: { page, per_page, total, has_more } }

GET /listings/{id}?type=property|car
  Response: { success, data: ListingModel (full detail with media, owner info) }

POST /listings/{id}/pause
POST /listings/{id}/resume
POST /listings/{id}/renew       Body: { subscription_id }
POST /listings/{id}/republish   Body: { subscription_id }
POST /listings/{id}/toggle-rented Body: { type }
DELETE /listings/{id}?type=property|car
```

#### Properties CRUD

```
GET    /properties?region_id=1&city_id=2&type=apartment&page=1
POST   /properties     Body: { title, property_type, region_id, city_id, price, bedrooms, ... }
GET    /properties/{id}
PUT    /properties/{id} Body: { ...updated fields }
DELETE /properties/{id}
```

#### Cars CRUD

```
GET    /cars?region_id=1&type=daily&page=1
POST   /cars           Body: { title, usage_type, model, year, gearbox, with_driver, price, ... }
GET    /cars/{id}
PUT    /cars/{id}       Body: { ...updated fields }
DELETE /cars/{id}
```

#### Favorites

```
GET    /favorites
POST   /favorites/{listing_id}     Body: { type: 'property'|'car' }
DELETE /favorites/{listing_id}?type=property|car
```

#### Plans & Subscriptions

```
GET  /plans?category=properties|cars
GET  /plans/{id}

GET  /subscriptions/me
GET  /subscriptions/active?category=properties|cars
GET  /subscriptions/can-add?category=properties|cars
GET  /subscriptions/available-for-listing?listing_type=property|car
GET  /subscriptions/warnings
GET  /subscriptions/requests
POST /subscriptions/requests         Body: { plan_id }
POST /subscriptions/purchase         Body: { plan_id, receipt_data?, transaction_id?, platform }
POST /subscriptions/verify-apple-purchase   Body: { receipt_data, product_id, transaction_id, plan_id }
POST /subscriptions/verify-google-purchase  Body: { purchase_token, product_id, plan_id }
```

#### Regions & Cities

```
GET /regions
GET /regions/{id}
GET /regions/{id}/cities
GET /cities
```

#### Chat

```
GET  /chat/conversations
POST /chat/conversation         Body: { user_id, listing_type?, listing_id? }
GET  /chat/conversation/{id}?page=1
POST /chat/send                 Body: { conversation_id, message }
GET  /chat/unread
```

#### Notifications

```
GET    /notifications?page=1
GET    /notifications/unread-count
POST   /notifications/{id}/read
POST   /notifications/all/read
DELETE /notifications/{id}
```

#### Other

```
GET  /me                        → Current authenticated user
POST /users/fcm-token           Body: { fcm_token, user_id }
PUT  /users/profile             Body: { name, email, phone, ... }
POST /users/change-password     Body: { current_password, new_password }
GET  /users/my-listings?tab=properties|cars

GET  /pages/{slug}?lang=ar      → CMS page (privacy, terms, disclaimer)
GET  /settings/terms?lang=ar
GET  /settings/privacy?lang=ar
GET  /settings/payment-methods

GET  /banners
GET  /banners/{id}

GET  /types/properties
GET  /types/cars
GET  /types

POST /uploads/image             Body: { image (base64), type (properties|cars|profiles) }
POST /uploads/images            Multipart form
POST /uploads/video             Multipart form

POST /reports                   Body: { listing_type, listing_id, reason }
```

### Authentication & Authorization Strategy

1. **Authentication**: JWT (JSON Web Token) with HMAC-SHA256 signing.
   - Token issued on login/register, includes `user_id` and `exp` (expiration).
   - Token stored client-side in `SharedPreferences` (key: `auth_token`).
   - Sent via `Authorization: Bearer <token>` header on every authenticated request.
   - Secret key configured in `backend/config/constants.php` (`JWT_SECRET`).

2. **Authorization**:
   - All users can browse listings (no auth required for `GET /listings`, `GET /regions`, etc.).
   - Creating/editing/deleting listings requires auth (JWT validated server-side).
   - Users can only modify their own listings (`user_id` check in controllers).
   - Admin routes are separate (admin session-based auth, not JWT).
   - User blocking: `is_blocked=1` prevents login.
   - User approval: Non-renter types require `is_approved=1` to log in.

3. **Password hashing**: bcrypt (`$2y$10$` prefix) via PHP's `password_hash()`.

### Scalability & Performance Considerations

| Area | Current Approach | Limitation |
|------|-----------------|------------|
| **Database** | Single MariaDB instance on shared hosting | No replication, no connection pooling beyond hosting defaults |
| **API** | Stateless PHP (no framework), single `index.php` router | Scales horizontally if moved to a load-balanced setup |
| **Images** | Stored on server filesystem (`uploads/` directory) | Disk-bound; no CDN |
| **Caching** | None | No Redis/Memcached; every request hits the database |
| **Pagination** | Server-side, 20 items per page | Prevents over-fetching |
| **Image compression** | Client-side (Flutter `flutter_image_compress`) before upload | Reduces upload size, but base64 encoding adds ~33% overhead |

---

## 5. Data Model

### Entity-Relationship Overview

```
regions ──< cities
  │            │
  └──┐    ┌───┘
     ▼    ▼
    users ─────< properties ──< property_media
      │    │         │
      │    │    ┌────┘
      │    ▼    ▼
      ├──< cars ──────< car_media
      │
      ├──< favorites
      │
      ├──< subscriptions ──< subscription_requests
      │         │
      │         ▼
      │       plans
      │
      ├──< payments
      │
      ├──< notifications
      │
      ├──< conversations ──< messages
      │
      ├──< reports
      │
      └──< otp_codes

admin_users ──< audit_logs
```

### Entities Detail

#### `users`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INT UNSIGNED | PK, AUTO_INCREMENT | |
| `name` | VARCHAR(255) | NOT NULL | Display name |
| `company_name` | VARCHAR(255) | NULLABLE | For office type users |
| `email` | VARCHAR(255) | UNIQUE, NOT NULL | Login identifier |
| `phone` | VARCHAR(20) | UNIQUE, NOT NULL | Login identifier, contact |
| `password` | VARCHAR(255) | NOT NULL | bcrypt hash |
| `user_type` | ENUM('renter','owner','office','car_lessor') | DEFAULT 'renter' | |
| `profile_image` | VARCHAR(500) | NULLABLE | Path to uploaded image |
| `is_verified_phone` | TINYINT(1) | DEFAULT 0 | OTP verified |
| `is_verified_email` | TINYINT(1) | DEFAULT 0 | OTP verified |
| `is_trusted` | TINYINT(1) | DEFAULT 0 | Admin-granted badge |
| `trusted_until` | DATE | NULLABLE | Trust expiry date |
| `is_active` | TINYINT(1) | DEFAULT 1 | Soft disable |
| `is_blocked` | TINYINT(1) | DEFAULT 0 | Admin block |
| `is_approved` | TINYINT(1) | DEFAULT 1 | Required for non-renter login |
| `preferred_language` | ENUM('ar','en','he') | DEFAULT 'ar' | |
| `fcm_token` | VARCHAR(500) | NULLABLE | Firebase push token |
| `region_id` | INT UNSIGNED | FK → regions.id, NULLABLE | User's base region |
| `city_id` | INT UNSIGNED | FK → cities.id, NULLABLE | User's base city |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | |
| `updated_at` | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | |

#### `properties`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INT UNSIGNED | PK, AUTO_INCREMENT | |
| `user_id` | INT UNSIGNED | FK → users.id (CASCADE) | Owner |
| `title` | VARCHAR(255) | NULLABLE | Listing title (user's content language) |
| `property_type` | ENUM('apartment','shop_office','villa_chalet','student_housing','land') | NOT NULL | |
| `region_id` | INT UNSIGNED | FK → regions.id | |
| `city_id` | INT UNSIGNED | FK → cities.id | |
| `address_text` | VARCHAR(500) | NULLABLE | Free-form address |
| `price_type` | ENUM('fixed','range','negotiable') | DEFAULT 'fixed' | |
| `price` | DECIMAL(12,2) | NULLABLE | Fixed price |
| `price_from` | DECIMAL(12,2) | NULLABLE | Range min |
| `price_to` | DECIMAL(12,2) | NULLABLE | Range max |
| `currency` | VARCHAR(10) | DEFAULT 'ILS' | |
| `bedrooms` | INT | NULLABLE | |
| `bathrooms` | INT | NULLABLE | |
| `floor` | INT | NULLABLE | |
| `area_m2` | DECIMAL(10,2) | NULLABLE | Square meters |
| `bio` | TEXT | NULLABLE | Description (user's content language) |
| `language` | ENUM('ar','he') | DEFAULT 'ar' | The language the content was written in |
| `contact_phone` | VARCHAR(20) | NOT NULL | |
| `whatsapp` | VARCHAR(20) | NULLABLE | |
| `status` | ENUM('draft','pending_payment','pending_admin_review','active','expired','paused','rejected') | DEFAULT 'draft' | |
| `reject_reason` | TEXT | NULLABLE | Admin rejection note |
| `views_count` | INT | DEFAULT 0 | |
| `subscription_id` | INT UNSIGNED | NULLABLE | FK to the subscription that activated this listing |
| `expires_at` | TIMESTAMP | NULLABLE | Listing expiry date (from subscription) |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | |
| `updated_at` | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | |

#### `cars`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | INT UNSIGNED | PK, AUTO_INCREMENT | |
| `user_id` | INT UNSIGNED | FK → users.id (CASCADE) | Owner |
| `title` | VARCHAR(255) | NULLABLE | |
| `usage_type` | ENUM('daily','wedding','tourism') | NOT NULL | |
| `model` | VARCHAR(255) | NOT NULL | Car model name |
| `year` | INT | NULLABLE | Manufacture year |
| `gearbox` | ENUM('manual','automatic') | DEFAULT 'automatic' | |
| `with_driver` | TINYINT(1) | DEFAULT 0 | |
| `duration_type` | ENUM('daily','weekly','monthly') | DEFAULT 'daily' | |
| `plate_color` | ENUM('yellow','white') | DEFAULT 'yellow' | License plate color (region indicator) |
| `region_id` | INT UNSIGNED | FK → regions.id | |
| `city_id` | INT UNSIGNED | FK → cities.id | |
| `address_text` | VARCHAR(500) | NULLABLE | |
| `price_type` | ENUM('fixed','range','negotiable') | DEFAULT 'fixed' | |
| `price` | DECIMAL(12,2) | NULLABLE | |
| `price_from` | DECIMAL(12,2) | NULLABLE | |
| `price_to` | DECIMAL(12,2) | NULLABLE | |
| `currency` | VARCHAR(10) | DEFAULT 'ILS' | |
| `bio` | TEXT | NULLABLE | |
| `language` | ENUM('ar','he') | DEFAULT 'ar' | |
| `contact_phone` | VARCHAR(20) | NOT NULL | |
| `whatsapp` | VARCHAR(20) | NULLABLE | |
| `status` | ENUM('draft','pending_payment','pending_admin_review','active','expired','paused','rejected') | DEFAULT 'draft' | |
| `reject_reason` | TEXT | NULLABLE | |
| `views_count` | INT | DEFAULT 0 | |
| `subscription_id` | INT UNSIGNED | NULLABLE | |
| `expires_at` | TIMESTAMP | NULLABLE | |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | |
| `updated_at` | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | |

#### `property_media` / `car_media`

| Column | Type | Description |
|--------|------|-------------|
| `id` | INT UNSIGNED | PK |
| `property_id` / `car_id` | INT UNSIGNED | FK (CASCADE delete) |
| `media_type` | ENUM('image','video') | DEFAULT 'image' |
| `file_path` | VARCHAR(500) | Relative path in `uploads/` |
| `file_name` | VARCHAR(255) | Original file name |
| `sort_order` | INT | Display ordering |
| `created_at` | TIMESTAMP | |

#### `plans`

| Column | Type | Description |
|--------|------|-------------|
| `id` | INT UNSIGNED | PK |
| `category` | ENUM('properties','cars') | Plan applies to which listing type |
| `name_ar` / `name_en` / `name_he` | VARCHAR(255) | Trilingual plan name |
| `description_ar` / `description_en` / `description_he` | TEXT | Optional description |
| `plan_type` | ENUM('single','package') | Single listing vs. bundle |
| `property_type` | ENUM(...) | NULLABLE — if single, restricts to this property type |
| `car_usage_type` | ENUM(...) | NULLABLE — if single, restricts to this car usage type |
| `listings_count` | INT | Max listings allowed (NULL if unlimited) |
| `is_unlimited` | TINYINT(1) | TRUE = no listing limit |
| `duration_days` | INT | DEFAULT 30 |
| `price` | DECIMAL(10,2) | Selling price in ILS |
| `original_price` | DECIMAL(10,2) | Before-discount price (for display) |
| `discount_percent` | INT | Displayed discount badge |
| `currency` | VARCHAR(10) | DEFAULT 'ILS' |
| `badge` | ENUM('bronze','silver','gold') | Visual badge tier |
| `is_featured` | TINYINT(1) | Highlight in plan list |
| `is_active` | TINYINT(1) | Admin can deactivate |
| `sort_order` | INT | Display ordering |
| `ios_product_id` | VARCHAR — _from Flutter model_ | App Store product ID |
| `android_product_id` | VARCHAR — _from Flutter model_ | Google Play product ID |

#### `subscriptions`

| Column | Type | Description |
|--------|------|-------------|
| `id` | INT UNSIGNED | PK |
| `user_id` | INT UNSIGNED | FK → users.id |
| `plan_id` | INT UNSIGNED | FK → plans.id |
| `category` | ENUM('properties','cars') | |
| `listings_used` | INT | Counter of listings activated under this subscription |
| `listings_limit` | INT | Max listings allowed |
| `is_unlimited` | TINYINT(1) | |
| `status` | ENUM('active','expired','cancelled') | |
| `starts_at` | TIMESTAMP | |
| `expires_at` | TIMESTAMP | |
| `created_at` | TIMESTAMP | |

#### `subscription_requests`

| Column | Type | Description |
|--------|------|-------------|
| `id` | INT UNSIGNED | PK |
| `user_id` | INT UNSIGNED | FK → users.id |
| `plan_id` | INT UNSIGNED | FK → plans.id |
| `status` | ENUM('pending','approved','rejected') | |
| `admin_notes` | TEXT | Admin feedback |
| `reviewed_by` | INT UNSIGNED | FK → admin_users.id |
| `reviewed_at` | TIMESTAMP | |

#### `payments`

| Column | Type | Description |
|--------|------|-------------|
| `id` | INT UNSIGNED | PK |
| `user_id` | INT UNSIGNED | FK → users.id |
| `plan_id` | INT UNSIGNED | FK → plans.id |
| `subscription_id` | INT UNSIGNED | FK → subscriptions.id |
| `amount` | DECIMAL(10,2) | |
| `currency` | VARCHAR(10) | DEFAULT 'ILS' |
| `platform` | ENUM('ios','android','web') | Where the payment was made |
| `transaction_id` | VARCHAR(255) | Store transaction ID |
| `receipt_data` | TEXT | Store receipt for verification |
| `status` | ENUM('pending','completed','failed','refunded') | |
| `verified_at` | TIMESTAMP | |
| `verified_by` | INT UNSIGNED | FK → admin_users.id |
| `notes` | TEXT | |

#### Other Tables

| Table | Purpose |
|-------|---------|
| `regions` | Geographic regions (West Bank, Jerusalem, Israel, Negev) with trilingual names |
| `cities` | Cities belonging to regions (21 cities) |
| `favorites` | User ↔ Listing many-to-many (unique composite: user_id, listing_type, listing_id) |
| `conversations` | Chat threads between two users, optionally linked to a listing |
| `messages` | Chat messages within a conversation |
| `notifications` | Push notifications stored for in-app notification center (trilingual title/body) |
| `otp_codes` | Phone/email OTP codes with expiry and usage tracking |
| `reports` | User reports on listings/users with admin review workflow |
| `cms_pages` | Content-managed pages (privacy, terms, disclaimer) with trilingual content |
| `app_settings` | Key-value configuration (terms_of_service, privacy_policy content) |
| `admin_users` | Admin panel users with roles (super_admin, admin, moderator) |
| `audit_logs` | Admin action tracking (entity_type, entity_id, old_data, new_data, IP) |
| `realtime_messages` | Polling-based message queue for chat delivery |

### Key Business Rules at the Data Layer

1. **UNIQUE constraint on favorites**: `(user_id, listing_type, listing_id)` — prevents duplicate favorites.
2. **CASCADE delete on users**: Deleting a user cascades to their properties, cars, favorites, messages, notifications, OTP codes, subscriptions, and reports.
3. **CASCADE delete on listings**: Deleting a property/car cascades to its media files.
4. **Foreign key on cities → regions**: Ensures referential integrity; deleting a region cascades to its cities.
5. **Status enum constraints**: Both `properties` and `cars` use the same 7-value status enum enforced at the database level.

### Data Retention & Privacy

- **Account deletion**: Implemented via `POST /auth/delete-account`. Triggers CASCADE deletes across all user data.
- **OTP codes**: Stored with `expires_at`; no automated cleanup cron exists (manual or application-level expiry check).
- **Audit logs**: Retained indefinitely for admin accountability.
- **Chat messages**: Retained indefinitely; no auto-deletion policy exists.
- **Privacy policy**: Managed via CMS (`app_settings.privacy_policy`); states that users can request data deletion at any time.

---

## 6. Business Logic & Rules

### Core Logic Flows

#### Listing Lifecycle State Machine

```
                    ┌──────────────┐
              ┌────→│    draft      │←────────────────────┐
              │     └──────┬───────┘                      │
              │            │ (user submits for review)     │ (admin rejects)
              │            ▼                               │
              │     ┌──────────────────────┐              │
              │     │ pending_admin_review  │──────────────┘
              │     └──────────┬───────────┘
              │                │ (admin approves, subscription linked)
              │                ▼
              │     ┌──────────────┐
    (renew)   │     │   active     │←──────────┐
    ──────────┘     └──┬───┬───┬──┘            │
                       │   │   │               │ (user resumes)
            (expires)  │   │   │ (user pauses) │
                       │   │   └──►┌────────┐  │
                       │   │       │ paused  │──┘
                       │   │       └────────┘
                       │   │
                       │   └──►┌──────────┐
                       │       │ rejected  │
                       │       └──────────┘
                       ▼
                ┌──────────┐
                │ expired   │
                └──────────┘
```

#### Subscription Purchase Flow (In-App Purchase — iOS)

1. User taps "Purchase" on a plan card.
2. `AppleIAPService.loadProducts()` queries App Store for matching `ios_product_id`.
3. `AppleIAPService.purchaseProduct(productId, planId)` initiates StoreKit purchase.
4. Apple payment sheet appears → user authenticates with Face ID / passcode.
5. On `PurchaseStatus.purchased`, `_verifyAndCompletePurchase()` sends receipt to backend:
   - `POST /subscriptions/verify-apple-purchase` with `receipt_data`, `product_id`, `transaction_id`, `plan_id`.
6. Backend verifies receipt with Apple servers, creates `subscriptions` and `payments` rows.
7. Backend returns `subscription_id`.
8. App calls `onPurchaseSuccess` callback, navigates user back to listings.

#### Subscription Purchase Flow (Manual / Admin-Verified)

1. User taps "Request Subscription" on a plan card.
2. `POST /subscriptions/requests` with `plan_id`.
3. Backend creates `subscription_requests` row with `status='pending'`.
4. Admin sees request in dashboard → reviews → approves with optional notes.
5. Backend creates `subscriptions` row, sets `starts_at`, calculates `expires_at`.
6. FCM notification sent to user: "Your subscription has been activated."
7. User's listings can now be linked to this subscription and activated.

### Validation Rules

| Entity | Rule | Enforcement |
|--------|------|-------------|
| **Registration** | Email must be unique across `users.email` | DB UNIQUE + API check |
| **Registration** | Phone must be unique across `users.phone` | DB UNIQUE + API check |
| **Registration** | Password minimum 6 characters | API-side validation |
| **Registration** | `user_type` must be one of: renter, owner, office, car_lessor | ENUM constraint |
| **Listing** | `contact_phone` is required | API NOT NULL check |
| **Listing** | `region_id` and `city_id` are required | API validation + FK |
| **Listing** | At least 1 image (from pre-uploaded media) | API check on store |
| **Listing** | Maximum 5 images, 1 video | Client-side enforcement (`maxImages=5`, `maxVideos=1`) |
| **Listing** | `bio` maximum 500 characters | Client-side (`maxBioLength=500`) |
| **Favorite** | Cannot duplicate (same user, listing_type, listing_id) | DB UNIQUE composite key |
| **Subscription request** | One pending request per plan category per user | API-level check |
| **OTP** | 6-digit code with time-based expiry | DB `expires_at` check |

### Error Handling Strategy

- **API responses** follow a consistent JSON envelope: `{ success: bool, message: string, data: any, pagination: object? }`.
- **HTTP status codes**: 200 (success), 400 (validation error), 401 (unauthorized), 404 (not found), 500 (server error).
- **Client-side translation**: The `ApiService._translateMessage()` method maps common English API error messages to Arabic equivalents for display.
- **Client-side error display**: Providers throw `Exception` with translated messages; UI catches and shows `SnackBar` or dialog.
- **Missing data gracefully handled**: All model `fromJson` methods use null-safe parsing (`??`, `int.tryParse`, `double.tryParse`) to avoid crashes on unexpected API data.

### Integration with Third-Party Services

| Service | Integration Point | Purpose |
|---------|-------------------|---------|
| **Firebase Cloud Messaging (FCM)** | `lib/services/fcm_service.dart`, `backend/config/firebase-service-account.json` | Push notifications (listing approved, subscription activated, admin messages, broadcasts) |
| **Apple App Store (StoreKit)** | `lib/services/apple_iap_service.dart` | iOS in-app purchases for subscription plans |
| **Google Play Billing** | `lib/services/google_iap_service.dart` | Android in-app purchases for subscription plans |
| **Apple Receipt Verification** | `POST /subscriptions/verify-apple-purchase` | Server-side receipt validation |
| **Google Purchase Verification** | `POST /subscriptions/verify-google-purchase` | Server-side token validation |

---

## 7. Non-Functional Requirements

### Performance Targets

| Metric | Target |
|--------|--------|
| API response time (p95) | < 500ms for list endpoints, < 200ms for single-item endpoints |
| App cold start | < 3 seconds to splash screen |
| Image load time | Cached after first load (`cached_network_image`); shimmer placeholder during load |
| Pagination | 20 items per page; infinite scroll with `has_more` flag |
| Connection timeout | 30 seconds (hardcoded in `ApiService`) |

### Security Requirements

| Requirement | Implementation |
|-------------|----------------|
| Password hashing | bcrypt (`password_hash()` / `password_verify()`) |
| Token security | JWT with configurable secret (`JWT_SECRET`); change in production |
| HTTPS | Required in production; enforced via hosting SSL |
| CORS | Configured in API `.htaccess` — currently `Access-Control-Allow-Origin: *` (should be restricted in production) |
| Input sanitization | PHP `Validator` helper class; parameterized PDO queries |
| File upload security | `Upload` helper validates MIME types and file sizes |
| Admin authentication | Session-based; separate from user JWT system |
| Sensitive data storage | `flutter_secure_storage` available (declared in dependencies) |
| Config protection | `.htaccess Deny from all` on `backend/config/` directory |
| Account deletion | GDPR-adjacent; `POST /auth/delete-account` triggers CASCADE deletion |

### Accessibility Standards

- **RTL support**: Full RTL layout for Arabic and Hebrew via Flutter's `Directionality` widget.
- **Theme support**: Light and dark themes with system-following option.
- **Font scaling**: Uses Material Design defaults which respect OS text size preferences.
- **Color contrast**: Uses Material theme tokens; no explicit WCAG audit has been performed.

### Internationalization / Localization

| Language | Code | Direction | Status |
|----------|------|-----------|--------|
| Arabic (العربية) | `ar` | RTL | ✅ Primary |
| Hebrew (עברית) | `he` | RTL | ✅ |
| English | `en` | LTR | ✅ |

- **App UI strings**: Managed via `AppLocalizations` (Flutter's built-in `flutter_localizations` + custom delegate).
- **Database content**: All content entities (plans, regions, cities, notifications, CMS pages) store trilingual fields (`name_ar`, `name_en`, `name_he`).
- **User-generated content**: Stored in the user's content language (`language` field: `ar` or `he`). API can return localized content via `?lang=` parameter.
- **Listing titles/bios**: Support separate `title_ar`, `title_en`, `title_he` fields; API resolves based on `lang` parameter.

---

## 8. Deployment & Infrastructure

### Environments

| Environment | URL | Database | Purpose |
|-------------|-----|----------|---------|
| **Local Development** | `http://localhost/rento_go/backend/api` | `rento_go` (XAMPP MySQL) | Developer testing |
| **Production** | `https://rento-go.com/backend/api` | `rentogo_1` (MariaDB on shared hosting) | Live users |

> **Note**: There is no dedicated staging environment. Testing is done locally before deploying to production.

### CI/CD Pipeline

Currently **manual deployment**:

1. Developer makes changes locally and tests.
2. Files are uploaded to production via cPanel File Manager or FTP.
3. Database migrations are applied manually via phpMyAdmin.
4. Flutter app is built with `flutter build apk` (Android) and `flutter build ios` (iOS).
5. App binaries are submitted to Google Play Console and App Store Connect.

### Hosting & Cloud Services

| Service | Provider | Details |
|---------|----------|---------|
| **Web hosting** | Shared cPanel hosting | Apache 2.x, PHP 8.4.x, MariaDB 10.11.x |
| **Domain** | `rento-go.com` | DNS pointing to shared hosting IP |
| **SSL** | Let's Encrypt (via cPanel) | Free, auto-renewing |
| **File storage** | Server filesystem | `uploads/` directory with `755` permissions |
| **Firebase** | Google Firebase (free tier) | FCM for push notifications |
| **App Store** | Apple App Store Connect | iOS distribution |
| **Play Store** | Google Play Console | Android distribution |

### Deployment Structure (Production)

```
rento-go.com/
├── backend/
│   ├── api/          → PHP API (index.php router + controllers)
│   ├── config/       → database.php, constants.php, firebase creds
│   ├── database/     → SQL schema files
│   ├── helpers/      → Response, JWT, Validator, Upload classes
│   ├── migrations/   → Database migration scripts
│   └── services/     → Backend service classes
├── admin/            → Admin dashboard (PHP/HTML)
├── web/              → Public website (PHP/HTML)
│   ├── assets/       → CSS, JS, images
│   └── includes/     → Header, footer partials
├── uploads/          → User-uploaded media
│   ├── images/
│   │   ├── properties/
│   │   ├── cars/
│   │   └── profiles/
│   └── videos/
└── index.php         → Redirect to /web/
```

### Monitoring, Logging, & Alerting

| Area | Current Approach |
|------|-----------------|
| **API logging** | PHP `error_log()` + Apache error logs (cPanel → Error Log) |
| **App logging** | `debugPrint()` statements in Flutter (dev only, stripped in release) |
| **Audit trail** | `audit_logs` table records admin actions with IP address |
| **Uptime monitoring** | None (no third-party monitoring like UptimeRobot) |
| **Error alerting** | None (no Sentry, Crashlytics, or email alerts) |
| **FCM delivery tracking** | Firebase Console shows delivery stats |

---

## 9. Open Questions & Risks

### Unresolved Decisions

| Decision | Options | Impact |
|----------|---------|--------|
| **Staging environment** | (A) Set up a subdomain staging server. (B) Continue with local-only testing. | Risk of production bugs without pre-prod validation. |
| **CORS restriction** | (A) Lock `Access-Control-Allow-Origin` to app's user-agent only. (B) Keep wildcard `*`. | Security risk with wildcard CORS in production. |
| **WebSocket chat** | (A) Deploy `websocket-server.php` for real-time chat. (B) Keep polling-based approach. | User experience vs. server complexity. |
| **CDN for images** | (A) Move uploads to S3/Cloudflare R2 + CDN. (B) Keep serving from origin. | Performance and scalability vs. cost. |
| **iOS FCM tokens** | (A) Enable FCM token saving on iOS. (B) Rely on APNs via Firebase topic subscriptions. | iOS users currently don't receive targeted push notifications. |
| **Payment integration** | (A) Add direct payment gateway (Stripe, PayPal) for subscriptions. (B) Keep manual admin approval + IAP only. | Conversion rate vs. implementation effort. |

### Known Technical Debt

| Item | Severity | Description |
|------|----------|-------------|
| No automated tests | High | Zero unit, integration, or E2E tests exist. |
| No staging environment | Medium | All testing happens locally; changes go directly to production. |
| No error monitoring | Medium | No Crashlytics, Sentry, or structured logging in production. |
| No database migrations tool | Medium | Schema changes are applied manually via phpMyAdmin. |
| Hardcoded translations in Dart | Low | Some UI strings are hardcoded in Arabic (e.g., `'قابل للتفاوض'` in `ListingModel.getPrice()`). |
| Base64 image uploads | Low | ~33% bandwidth overhead vs. multipart upload; limits practical file size. |
| `go_router` declared but unused | Low | Navigation uses `Navigator.push()` directly; `go_router` dependency is unused. |
| Wildcard CORS | Medium | `Access-Control-Allow-Origin: *` should be restricted to app domains. |
| FCM Android-only | Medium | iOS users miss targeted notifications (topic broadcasts still work). |
| No cron jobs | Low | Expired subscriptions and OTP codes are not automatically cleaned up. |

### Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| **App Store rejection** (missing privacy compliance, permissions) | Medium | High | Account deletion implemented; Info.plist keys configured; privacy policy CMS page exists. |
| **Database loss** (no automated backups) | Low | Critical | Set up automated daily cPanel backups; export SQL dumps regularly. |
| **JWT secret compromise** | Low | Critical | Change `JWT_SECRET` from default; rotate periodically; store in environment variable. |
| **Shared hosting limits** (CPU, memory, storage) | Medium | Medium | Monitor cPanel resource usage; plan migration to VPS/cloud if user growth exceeds limits. |
| **Image storage filling disk** | Medium | Medium | Monitor disk usage; implement image size limits server-side; consider CDN offloading. |
| **Listing spam** | Medium | Low | Admin approval workflow mitigates; consider rate limiting API endpoints. |
| **API downtime** (shared hosting) | Low-Medium | High | No redundancy; consider health-check monitoring and failover. |
| **Currency regulation changes** | Low | Medium | ILS-only; would require schema/model changes to support additional currencies. |

---

## 10. Glossary

| Term | Definition |
|------|-----------|
| **Listing** | A unified term for either a property listing or a car listing on the platform. |
| **Property** | A real estate rental listing (apartment, villa/chalet, shop/office, student housing, or land). |
| **Car** | A vehicle rental listing categorized by usage type (daily, wedding, tourism). |
| **Plan** | A subscription plan that users purchase to activate their listings. Plans have a category (properties or cars), a type (single or package), a price, and a duration. |
| **Subscription** | An active instance of a plan purchased by a user, with a start date, expiry date, and listing usage counter. |
| **Subscription Request** | A manual request from a user to subscribe to a plan, pending admin approval (alternative to in-app purchase). |
| **Badge** | A visual tier indicator on plans and listings: Bronze, Silver, or Gold. |
| **Trusted User** | A user flagged by an admin as trustworthy, displayed with a trust badge on their listings. |
| **OTP** | One-Time Password — a 6-digit code sent via SMS for phone verification or password reset. |
| **FCM** | Firebase Cloud Messaging — Google's push notification service used to deliver notifications to the mobile app. |
| **JWT** | JSON Web Token — a stateless authentication token issued on login and sent with each API request. |
| **IAP** | In-App Purchase — purchasing a subscription plan through the Apple App Store or Google Play Store billing system. |
| **CMS Page** | Content-managed page (privacy, terms, disclaimer) with trilingual content editable from the admin dashboard. |
| **RTL** | Right-to-Left — text direction used by Arabic and Hebrew. The app dynamically switches between RTL and LTR based on the selected language. |
| **Region** | A geographic area containing multiple cities (e.g., West Bank, Jerusalem, Israel, Negev). |
| **City** | A specific city within a region (e.g., Ramallah, Nablus, Haifa). |
| **Banner** | A featured/promoted listing displayed prominently on the home screen. |
| **Views Count** | The number of times a listing's detail page has been viewed. |
| **Listing Status** | The current state of a listing: `draft`, `pending_payment`, `pending_admin_review`, `active`, `expired`, `paused`, or `rejected`. |
| **Plate Color** | A car attribute indicating the license plate color: yellow (Palestinian Authority) or white (Israeli). |
| **ILS** | Israeli New Shekel — the sole currency used on the platform (symbol: ₪). |
| **cPanel** | A web hosting control panel used to manage the production server, database, files, and SSL certificates. |
| **Audit Log** | A record of admin actions (approve, reject, block, etc.) stored with timestamps and IP addresses for accountability. |
