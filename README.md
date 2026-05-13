# StreamHub IPTV (Flutter + PHP + MySQL)

Production-style mobile IPTV/live TV app scaffold with:
- Flutter frontend (Riverpod + GoRouter + secure token storage)
- PHP REST backend (PDO, token auth, prepared statements)
- MySQL relational schema with indexes and sample seed data

## 1) Project Structure

```text
streaming/
  lib/
    app/
      app.dart
      router.dart
    core/
      constants/api_constants.dart
      network/api_client.dart
      storage/secure_storage_service.dart
      theme/app_theme.dart
      widgets/app_states.dart
      widgets/app_background.dart
    features/
      auth/
        data/auth_repository.dart
        presentation/auth_controller.dart
        presentation/login_screen.dart
        presentation/register_screen.dart
        presentation/splash_screen.dart
      home/presentation/home_screen.dart
      channels/
        data/channel_repository.dart
        presentation/channel_providers.dart
        presentation/channel_list_screen.dart
        presentation/channel_card.dart
        presentation/search_screen.dart
        presentation/player_screen.dart
      categories/presentation/categories_screen.dart
      favorites/
        data/favorites_repository.dart
        presentation/favorites_controller.dart
        presentation/favorites_screen.dart
      epg/
        data/epg_repository.dart
        presentation/epg_providers.dart
      subscription/
        data/subscription_repository.dart
        presentation/subscription_controller.dart
        presentation/subscription_screen.dart
      profile/
        data/profile_repository.dart
        presentation/profile_controller.dart
        presentation/profile_screen.dart
      shared/models/
        user.dart
        category.dart
        channel.dart
        epg_program.dart
        plan.dart
  backend/
    Dockerfile
    apache-vhost.conf
    public/
      index.php
      .htaccess
    src/
      config/config.php
      config/Database.php
      helpers/{Auth.php,Request.php,Response.php}
      middleware/AuthMiddleware.php
      controllers/
        AuthController.php
        UserController.php
        ChannelController.php
        CategoryController.php
        FavoriteController.php
        EpgController.php
        SubscriptionController.php
  database/
    schema.sql
    custom_channels_seed.sql
    sample_responses.md
  render.yaml
```

## 2) Flutter Features Included

- Splash session bootstrapping
- Login / Register / Logout
- Token persistence in `flutter_secure_storage`
- Home: featured + latest channels + subscription status
- Channel list by category + dynamic API fetch
- Search channels by name/category
- Favorites add/remove synced with backend
- Video player screen:
  - HLS stream playback (`video_player`)
  - play/pause, mute/unmute, fullscreen orientation support
  - retry on failure
  - related channels
- EPG display: now playing and up next
- Subscription plans and activation
- Profile view + edit name
- Dark modern theme and clean scalable folder structure

## 3) Backend API Endpoints

Base URL example:
- `https://your-domain/public/`

Auth:
- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/logout`

User:
- `GET /user/profile`
- `PUT /user/profile`

Channels:
- `GET /channels?page=1&category=Sports&q=news`
- `GET /channels/{id}`
- `POST /admin/channels` (admin-ready endpoint)

Categories:
- `GET /categories`

Favorites:
- `GET /favorites`
- `POST /favorites`
- `DELETE /favorites/{channel_id}`

EPG:
- `GET /epg?channel_id=1`

Subscription:
- `GET /subscription/plans`
- `POST /subscription/assign`

Health:
- `GET /health`

## 4) Database Setup

1. Create DB + tables + seed data:
```bash
mysql -u root -p < database/schema.sql
```

2. Optional custom channel seed:
```bash
mysql -u root -p iptv_app < database/custom_channels_seed.sql
```

## 5) Local Backend Run

Option A (Apache/XAMPP style):
- Place `backend/` as `htdocs/backend/`.
- Access API via `http://localhost/backend/public`.

Option B (PHP built-in server):
```bash
cd backend/public
php -S 127.0.0.1:8080
```

## 6) Render Deployment (Recommended)

This project is now Render-ready with Docker and `render.yaml`.

Important: Render does not provide native MySQL in the same way as Postgres. Use an external MySQL provider (e.g., Aiven, PlanetScale, Railway MySQL, Neon + proxy if needed).

### Deploy Steps

1. Push this repo to GitHub.
2. In Render dashboard, choose `New +` → `Blueprint`.
3. Select your repo containing this project.
4. Render will detect `render.yaml` and create web service `streamhub-api`.
5. Set these environment variables in Render (or via Blueprint env vars):
   - `DB_HOST`
   - `DB_PORT` (usually `3306`)
   - `DB_NAME`
   - `DB_USER`
   - `DB_PASS`
   - `JWT_SECRET`
   - `CORS_ORIGIN` (for testing you can keep `*`)
6. Deploy.
7. Verify health:
   - `https://<your-render-service>.onrender.com/health`
8. Verify API route:
   - `https://<your-render-service>.onrender.com/categories`

### Flutter Base URL for Render

If `/categories` works directly on render domain, set:
```dart
static const baseUrl = 'https://<your-render-service>.onrender.com/';
```

## 7) Flutter Connection Setup

1. Install Flutter deps:
```bash
flutter pub get
```

If you run the app on Linux desktop, install the system package required by `flutter_secure_storage` first:
- `libsecret-1-dev` (package name may vary by distro)

Also make sure an LLVM linker is installed for Linux desktop builds:
- `lld-21` or the distro equivalent that provides `ld.lld`

2. Configure API base URL:
- File: `lib/core/constants/api_constants.dart`

3. Run app:
```bash
flutter run
```

## 8) Security Notes

- Token auth implemented with signed JWT-like tokens + DB session tracking (`auth_tokens`).
- All DB access uses prepared statements.
- Premium channel guard is enforced in backend channel details endpoint.
- Change `JWT_SECRET` before production.
- Restrict `CORS_ORIGIN` to your app domains in production.

## 9) Legal Stream Placeholder

This project uses legal test HLS placeholder URLs:
- `https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8`

Replace with authorized licensed streams in production.

## 10) Example Responses

See:
- `database/sample_responses.md`

## 11) Validation Status

- Flutter static analysis: `No issues found`.
- PHP syntax lint: backend files pass `php -l`.

# streaming_app
# streaming_app
