# Overseerr API Documentation

Base URL: `http://localhost:5055/api/v1`

## Authentication

Two primary authentication methods are supported:
- **Cookie Authentication**: Sign in to `/auth/plex` or `/auth/local` generates an authentication cookie
- **API Key Authentication**: Pass `X-Api-Key` header with a valid API key

---

## 1. STATUS & SYSTEM ENDPOINTS

### GET `/status`
Get application status and version information.

**Response:**
```json
{
  "version": "1.33.2",
  "commitTag": "abc123",
  "updateAvailable": false,
  "commitsBehind": 0,
  "restartRequired": false
}
```

### GET `/status/appdata`
Get application data directory status.

**Response:**
```json
{
  "appData": "ok",
  "appDataPath": "/app/config"
}
```

---

## 2. AUTHENTICATION ENDPOINTS

### GET `/auth/me`
Get currently authenticated user information.

**Auth Required:** Yes

**Response:** User object

### POST `/auth/plex`
Authenticate with Plex account.

**Request Body:**
```json
{
  "authToken": "string"
}
```

**Response:** User object

### POST `/auth/local`
Authenticate with local credentials.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password"
}
```

**Response:** User object

### POST `/auth/logout`
Log out current user.

**Response:**
```json
{
  "status": "ok"
}
```

### POST `/auth/reset-password`
Request password reset link.

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response:**
```json
{
  "status": "ok"
}
```

### POST `/auth/reset-password/{guid}`
Reset password using recovery link.

**Request Body:**
```json
{
  "password": "newpassword"
}
```

**Response:**
```json
{
  "status": "ok"
}
```

---

## 3. USER MANAGEMENT ENDPOINTS

### GET `/user`
Get all users (paginated).

**Auth Required:** Yes

**Query Parameters:**
- `take` (number, optional): Page size (default: 10)
- `skip` (number, optional): Offset (default: 0)
- `sort` (string, optional): Sort order

**Response:**
```json
{
  "pageInfo": {
    "pages": 1,
    "pageSize": 10,
    "results": 5,
    "page": 1
  },
  "results": [/* User objects */]
}
```

### POST `/user/import-from-plex`
Import users from Plex.

**Auth Required:** Admin

**Response:** Array of imported User objects

### GET `/user/{userId}`
Get specific user by ID.

**Auth Required:** Yes

**Response:** User object

### PUT `/user/{userId}`
Update user information.

**Auth Required:** Yes (own user) or Admin

**Request Body:** User object with updates

**Response:** Updated User object

### DELETE `/user/{userId}`
Delete a user.

**Auth Required:** Admin

**Response:** 204 No Content

### GET `/user/{userId}/requests`
Get requests for a specific user.

**Auth Required:** Yes

**Query Parameters:**
- `take` (number): Page size
- `skip` (number): Offset

**Response:** Paginated requests list

### GET `/user/{userId}/quota`
Get user's quota information.

**Auth Required:** Yes

**Response:**
```json
{
  "movie": {
    "used": 5,
    "limit": 10,
    "remaining": 5
  },
  "tv": {
    "used": 3,
    "limit": 10,
    "remaining": 7
  }
}
```

### GET `/user/{userId}/watchlist`
Get user's Plex watchlist.

**Auth Required:** Yes

**Response:** Array of media items

### GET `/user/{userId}/settings/main`
Get user's main settings.

**Auth Required:** Yes

**Response:** UserSettings object

### POST `/user/{userId}/settings/main`
Update user's main settings.

**Auth Required:** Yes

**Request Body:** UserSettings object

**Response:** Updated UserSettings object

### POST `/user/{userId}/settings/password`
Change user password.

**Auth Required:** Yes

**Request Body:**
```json
{
  "currentPassword": "string",
  "newPassword": "string"
}
```

**Response:**
```json
{
  "status": "ok"
}
```

### GET `/user/{userId}/settings/notifications`
Get user's notification settings.

**Auth Required:** Yes

**Response:** NotificationSettings object

### POST `/user/{userId}/settings/notifications`
Update user's notification settings.

**Auth Required:** Yes

**Request Body:** NotificationSettings object

**Response:** Updated NotificationSettings object

### GET `/user/{userId}/settings/permissions`
Get user permissions.

**Auth Required:** Admin

**Response:** Permissions object

### POST `/user/{userId}/settings/permissions`
Update user permissions.

**Auth Required:** Admin

**Request Body:** Permissions object

**Response:** Updated Permissions object

### GET `/user/{userId}/watch_data`
Get watch data/statistics for user.

**Auth Required:** Admin

**Response:** Watch statistics

### POST `/user/registerPushSubscription`
Register web push notification subscription.

**Auth Required:** Yes

**Request Body:** PushSubscription object

**Response:** Registered subscription

### GET `/user/{userId}/pushSubscriptions`
Get user's push subscriptions.

**Auth Required:** Yes

**Response:** Array of PushSubscription objects

### DELETE `/user/{userId}/pushSubscription/{endpoint}`
Delete a push subscription.

**Auth Required:** Yes

**Response:** 204 No Content

---

## 4. SEARCH ENDPOINTS

### GET `/search`
Search for movies, TV shows, and people.

**Auth Required:** Yes

**Query Parameters:**
- `query` (string, required): Search query
- `page` (number, optional): Page number
- `language` (string, optional): Language code

**Response:**
```json
{
  "page": 1,
  "totalPages": 10,
  "totalResults": 100,
  "results": [/* Mixed media results */]
}
```

### GET `/search/keyword`
Search for keywords.

**Auth Required:** Yes

**Query Parameters:**
- `query` (string, required): Keyword search query
- `page` (number, optional): Page number

**Response:** Paginated keyword results

### GET `/search/company`
Search for production companies.

**Auth Required:** Yes

**Query Parameters:**
- `query` (string, required): Company search query
- `page` (number, optional): Page number

**Response:** Paginated company results

---

## 5. DISCOVER/BROWSE ENDPOINTS

### GET `/discover/movies`
Discover movies with filters.

**Auth Required:** Yes

**Query Parameters:**
- `page` (number): Page number
- `sortBy` (string): Sort option (e.g., 'popularity.desc', 'vote_average.desc')
- `primaryReleaseDateGte` (string): Minimum release date
- `primaryReleaseDateLte` (string): Maximum release date
- `genre` (string): Genre ID(s)
- `studio` (string): Studio/company ID
- `keywords` (string): Keyword ID(s)
- `language` (string): Language code
- `withRuntimeGte` (number): Minimum runtime
- `withRuntimeLte` (number): Maximum runtime
- `voteAverageGte` (number): Minimum vote average
- `voteAverageLte` (number): Maximum vote average
- `voteCountGte` (number): Minimum vote count
- `voteCountLte` (number): Maximum vote count
- `watchProviders` (string): Watch provider IDs
- `watchRegion` (string): Watch region code

**Response:** Paginated movie results with media status

### GET `/discover/movies/genre/{genreId}`
Discover movies by genre.

**Auth Required:** Yes

**Query Parameters:** `page`, `language`

**Response:** Paginated movie results

### GET `/discover/movies/language/{language}`
Discover movies by language.

**Auth Required:** Yes

**Query Parameters:** `page`, `language`

**Response:** Paginated movie results

### GET `/discover/movies/studio/{studioId}`
Discover movies by studio.

**Auth Required:** Yes

**Query Parameters:** `page`, `language`

**Response:** Paginated movie results

### GET `/discover/movies/upcoming`
Get upcoming movies.

**Auth Required:** Yes

**Query Parameters:** `page`, `language`

**Response:** Paginated upcoming movie results

### GET `/discover/tv`
Discover TV series with filters.

**Auth Required:** Yes

**Query Parameters:** Similar to `/discover/movies` but for TV:
- `firstAirDateGte`, `firstAirDateLte` instead of primaryReleaseDate
- `network` instead of studio

**Response:** Paginated TV results

### GET `/discover/tv/genre/{genreId}`
Discover TV series by genre.

**Auth Required:** Yes

**Query Parameters:** `page`, `language`

**Response:** Paginated TV results

### GET `/discover/tv/language/{language}`
Discover TV series by language.

**Auth Required:** Yes

**Query Parameters:** `page`, `language`

**Response:** Paginated TV results

### GET `/discover/tv/network/{networkId}`
Discover TV series by network.

**Auth Required:** Yes

**Query Parameters:** `page`, `language`

**Response:** Paginated TV results

### GET `/discover/tv/upcoming`
Get upcoming TV series.

**Auth Required:** Yes

**Query Parameters:** `page`, `language`

**Response:** Paginated upcoming TV results

### GET `/discover/trending`
Get trending movies and TV shows.

**Auth Required:** Yes

**Query Parameters:**
- `page` (number): Page number
- `language` (string): Language code

**Response:** Paginated trending results

### GET `/discover/keyword/{keywordId}/movies`
Discover movies by keyword.

**Auth Required:** Yes

**Query Parameters:** `page`, `language`

**Response:** Paginated movie results

### GET `/discover/genreslider/movie`
Get movie genre slider data.

**Auth Required:** Yes

**Response:** Array of genre slider items with movie counts

### GET `/discover/genreslider/tv`
Get TV genre slider data.

**Auth Required:** Yes

**Response:** Array of genre slider items with TV counts

### GET `/discover/watchlist`
Get current user's watchlist.

**Auth Required:** Yes

**Query Parameters:** `page`

**Response:** Paginated watchlist results

---

## 6. MOVIE ENDPOINTS

### GET `/movie/{movieId}`
Get movie details by TMDB ID.

**Auth Required:** Yes

**Query Parameters:**
- `language` (string, optional): Language code

**Response:** Detailed movie object with media status, requests, cast, crew, etc.

### GET `/movie/{movieId}/recommendations`
Get movie recommendations.

**Auth Required:** Yes

**Query Parameters:**
- `page` (number): Page number
- `language` (string): Language code

**Response:** Paginated recommended movies

### GET `/movie/{movieId}/similar`
Get similar movies.

**Auth Required:** Yes

**Query Parameters:**
- `page` (number): Page number
- `language` (string): Language code

**Response:** Paginated similar movies

### GET `/movie/{movieId}/ratings`
Get Rotten Tomatoes ratings for movie.

**Auth Required:** Yes

**Response:**
```json
{
  "title": "Movie Title",
  "url": "https://...",
  "criticsRating": "Certified Fresh",
  "criticsScore": 95,
  "audienceRating": "Upright",
  "audienceScore": 87
}
```

### GET `/movie/{movieId}/ratingscombined`
Get combined ratings (RT + IMDB) for movie.

**Auth Required:** Yes

**Response:**
```json
{
  "rt": {/* Rotten Tomatoes ratings */},
  "imdb": {
    "title": "Movie Title",
    "url": "https://...",
    "rating": 8.5,
    "votes": 1000000
  }
}
```

---

## 7. TV SERIES ENDPOINTS

### GET `/tv/{tvId}`
Get TV series details by TMDB ID.

**Auth Required:** Yes

**Query Parameters:**
- `language` (string, optional): Language code

**Response:** Detailed TV series object with seasons, media status, requests, etc.

### GET `/tv/{tvId}/season/{seasonId}`
Get season details with episodes.

**Auth Required:** Yes

**Query Parameters:**
- `language` (string, optional): Language code

**Response:** Season object with episode list

### GET `/tv/{tvId}/recommendations`
Get TV series recommendations.

**Auth Required:** Yes

**Query Parameters:**
- `page` (number): Page number
- `language` (string): Language code

**Response:** Paginated recommended TV series

### GET `/tv/{tvId}/similar`
Get similar TV series.

**Auth Required:** Yes

**Query Parameters:**
- `page` (number): Page number
- `language` (string): Language code

**Response:** Paginated similar TV series

### GET `/tv/{tvId}/ratings`
Get Rotten Tomatoes ratings for TV series.

**Auth Required:** Yes

**Response:** Rotten Tomatoes rating object

---

## 8. PERSON ENDPOINTS

### GET `/person/{personId}`
Get person details by TMDB ID.

**Auth Required:** Yes

**Query Parameters:**
- `language` (string, optional): Language code

**Response:** Person object with biography, images, etc.

### GET `/person/{personId}/combined_credits`
Get person's combined movie and TV credits.

**Auth Required:** Yes

**Query Parameters:**
- `language` (string, optional): Language code

**Response:**
```json
{
  "cast": [/* Movie and TV credits */],
  "crew": [/* Movie and TV credits */]
}
```

---

## 9. MEDIA MANAGEMENT ENDPOINTS

### GET `/media`
Get all media (movies and TV shows).

**Auth Required:** Yes

**Query Parameters:**
- `take` (number): Page size (default: 20)
- `skip` (number): Offset (default: 0)
- `filter` (string): Status filter ('available', 'partial', 'allavailable', 'processing', 'pending')
- `sort` (string): Sort option ('modified', 'mediaAdded')

**Response:**
```json
{
  "pageInfo": {
    "pages": 10,
    "pageSize": 20,
    "results": 200,
    "page": 1
  },
  "results": [/* Media objects */]
}
```

### GET `/media/{mediaId}`
Get specific media by ID.

**Auth Required:** Yes

**Response:** Media object

### POST `/media/{mediaId}/{status}`
Update media status.

**Auth Required:** Admin (MANAGE_REQUESTS permission)

**Path Parameters:**
- `mediaId` (number): Media ID
- `status` (string): New status ('available', 'partial', 'processing', 'pending', 'unknown')

**Request Body:**
```json
{
  "is4k": false,
  "seasons": [/* For TV shows */]
}
```

**Response:** Updated Media object

### DELETE `/media/{mediaId}`
Delete media.

**Auth Required:** Admin (MANAGE_REQUESTS permission)

**Response:** 204 No Content

### GET `/media/{mediaId}/watch_data`
Get watch statistics for media (requires Tautulli).

**Auth Required:** Admin

**Response:**
```json
{
  "data": {
    "users": [/* User objects */],
    "playCount": 100,
    "playCount7Days": 20,
    "playCount30Days": 50
  },
  "data4k": {/* Same structure for 4K version */}
}
```

---

## 10. REQUEST MANAGEMENT ENDPOINTS

### GET `/request`
Get all media requests.

**Auth Required:** Yes

**Query Parameters:**
- `take` (number): Page size (default: 10)
- `skip` (number): Offset (default: 0)
- `filter` (string): Status filter ('approved', 'pending', 'available', 'processing', 'unavailable', 'failed', 'completed', 'deleted')
- `sort` (string): Sort option ('modified')
- `requestedBy` (number): Filter by user ID

**Response:**
```json
{
  "pageInfo": {
    "pages": 5,
    "pageSize": 10,
    "results": 50,
    "page": 1
  },
  "results": [/* MediaRequest objects */]
}
```

### POST `/request`
Create a new media request.

**Auth Required:** Yes

**Request Body:**
```json
{
  "mediaType": "movie",  // or "tv"
  "mediaId": 12345,
  "is4k": false,
  "serverId": 1,
  "profileId": 1,
  "rootFolder": "/movies",
  "languageProfileId": 1,  // TV only
  "tags": [1, 2],
  "seasons": [1, 2, 3]  // TV only
}
```

**Response:** Created MediaRequest object

**Status Codes:**
- 201: Created successfully
- 202: No seasons available to request
- 403: Permission denied or quota exceeded
- 409: Duplicate request

### GET `/request/count`
Get request counts by status and type.

**Auth Required:** Yes

**Response:**
```json
{
  "total": 100,
  "movie": 60,
  "tv": 40,
  "pending": 10,
  "approved": 20,
  "declined": 5,
  "processing": 15,
  "available": 50
}
```

### GET `/request/{requestId}`
Get specific request by ID.

**Auth Required:** Yes (own request) or MANAGE_REQUESTS permission

**Response:** MediaRequest object

### PUT `/request/{requestId}`
Update a request.

**Auth Required:** Yes (own request) or MANAGE_REQUESTS permission

**Request Body:** Updated request fields (similar to POST)

**Response:** Updated MediaRequest object

### DELETE `/request/{requestId}`
Delete a request.

**Auth Required:** Yes (own pending request) or MANAGE_REQUESTS permission

**Response:** 204 No Content

### POST `/request/{requestId}/retry`
Retry a failed request.

**Auth Required:** MANAGE_REQUESTS permission

**Response:** Updated MediaRequest object

### POST `/request/{requestId}/{status}`
Change request status.

**Auth Required:** MANAGE_REQUESTS permission

**Path Parameters:**
- `requestId` (number): Request ID
- `status` (string): New status ('pending', 'approve', 'decline')

**Response:** Updated MediaRequest object

---

## 11. COLLECTION ENDPOINTS

### GET `/collection/{collectionId}`
Get collection details by TMDB ID.

**Auth Required:** Yes

**Query Parameters:**
- `language` (string, optional): Language code

**Response:** Collection object with movies and media status

---

## 12. SERVICE ENDPOINTS (Radarr/Sonarr)

### GET `/service/radarr`
Get all configured Radarr instances.

**Auth Required:** Admin

**Response:** Array of Radarr configuration objects

### GET `/service/radarr/{radarrId}`
Get specific Radarr instance.

**Auth Required:** Admin

**Response:** Radarr configuration object

### GET `/service/sonarr`
Get all configured Sonarr instances.

**Auth Required:** Admin

**Response:** Array of Sonarr configuration objects

### GET `/service/sonarr/{sonarrId}`
Get specific Sonarr instance.

**Auth Required:** Admin

**Response:** Sonarr configuration object

### GET `/service/sonarr/lookup/{tmdbId}`
Look up TV series in Sonarr by TMDB ID.

**Auth Required:** Admin

**Response:** Sonarr series information

---

## 13. TMDB DATA ENDPOINTS

### GET `/regions`
Get available regions.

**Auth Required:** Yes

**Response:** Array of region objects

### GET `/languages`
Get available languages.

**Auth Required:** Yes

**Response:** Array of language objects

### GET `/studio/{studioId}`
Get production company/studio details.

**Auth Required:** Yes

**Response:** Studio object

### GET `/network/{networkId}`
Get TV network details.

**Auth Required:** Yes

**Response:** Network object

### GET `/genres/movie`
Get movie genres.

**Auth Required:** Yes

**Query Parameters:**
- `language` (string, optional): Language code

**Response:** Array of genre objects

### GET `/genres/tv`
Get TV genres.

**Auth Required:** Yes

**Query Parameters:**
- `language` (string, optional): Language code

**Response:** Array of genre objects

### GET `/backdrops`
Get random backdrop images from trending content.

**Auth Required:** Yes

**Response:** Array of backdrop image paths

### GET `/keyword/{keywordId}`
Get keyword details.

**Auth Required:** Yes

**Response:** Keyword object

### GET `/watchproviders/regions`
Get available watch provider regions.

**Auth Required:** Yes

**Response:** Array of region codes

### GET `/watchproviders/movies`
Get movie watch providers.

**Auth Required:** Yes

**Query Parameters:**
- `watchRegion` (string, optional): Region code

**Response:** Array of watch provider objects

### GET `/watchproviders/tv`
Get TV watch providers.

**Auth Required:** Yes

**Query Parameters:**
- `watchRegion` (string, optional): Region code

**Response:** Array of watch provider objects

---

## 14. ISSUE TRACKING ENDPOINTS

### GET `/issue`
Get all issues.

**Auth Required:** MANAGE_ISSUES permission

**Query Parameters:**
- `take` (number): Page size
- `skip` (number): Offset
- `filter` (string): Status filter
- `sort` (string): Sort option

**Response:** Paginated issue list

### POST `/issue`
Create a new issue.

**Auth Required:** Yes (CREATE_ISSUES permission)

**Request Body:**
```json
{
  "issueType": 1,
  "message": "Issue description",
  "mediaId": 123
}
```

**Response:** Created Issue object

### GET `/issue/count`
Get issue counts by status.

**Auth Required:** MANAGE_ISSUES permission

**Response:**
```json
{
  "total": 50,
  "open": 20,
  "resolved": 30
}
```

### GET `/issue/{issueId}`
Get specific issue by ID.

**Auth Required:** Yes

**Response:** Issue object with comments

### PUT `/issue/{issueId}`
Update an issue.

**Auth Required:** MANAGE_ISSUES permission

**Request Body:** Updated issue fields

**Response:** Updated Issue object

### DELETE `/issue/{issueId}`
Delete an issue.

**Auth Required:** MANAGE_ISSUES permission

**Response:** 204 No Content

### POST `/issue/{issueId}/{status}`
Change issue status.

**Auth Required:** MANAGE_ISSUES permission

**Path Parameters:**
- `issueId` (number): Issue ID
- `status` (string): New status ('open', 'resolved')

**Response:** Updated Issue object

### POST `/issue/{issueId}/comment`
Add comment to issue.

**Auth Required:** Yes

**Request Body:**
```json
{
  "message": "Comment text"
}
```

**Response:** Created IssueComment object

### GET `/issueComment/{commentId}`
Get specific comment.

**Auth Required:** Yes

**Response:** IssueComment object

### PUT `/issueComment/{commentId}`
Update a comment.

**Auth Required:** Yes (own comment) or MANAGE_ISSUES permission

**Request Body:**
```json
{
  "message": "Updated comment text"
}
```

**Response:** Updated IssueComment object

### DELETE `/issueComment/{commentId}`
Delete a comment.

**Auth Required:** Yes (own comment) or MANAGE_ISSUES permission

**Response:** 204 No Content

---

## 15. SETTINGS ENDPOINTS

All settings endpoints require Admin (ADMIN permission) authentication.

### GET `/settings/main`
Get main settings.

**Response:** MainSettings object

### POST `/settings/main`
Update main settings.

**Request Body:** MainSettings object

**Response:** Updated MainSettings object

### POST `/settings/main/regenerate`
Regenerate API key.

**Response:** New MainSettings with regenerated API key

### GET `/settings/public`
Get public settings (no authentication required).

**Response:** Public portion of settings

### POST `/settings/initialize`
Initialize application settings (first-time setup).

**Request Body:** Initial settings configuration

**Response:** Initialized settings

### GET `/settings/plex`
Get Plex settings.

**Response:** PlexSettings object

### POST `/settings/plex`
Update Plex settings.

**Request Body:** PlexSettings object

**Response:** Updated PlexSettings object

### GET `/settings/plex/library`
Get Plex libraries.

**Response:** Array of PlexLibrary objects

### GET `/settings/plex/sync`
Get Plex sync status.

**Response:** Sync status information

### POST `/settings/plex/sync`
Trigger Plex library sync.

**Response:** Sync job information

### GET `/settings/plex/devices/servers`
Get available Plex servers.

**Response:** Array of Plex server objects

### GET `/settings/plex/users`
Get Plex users.

**Response:** Array of Plex user objects

### GET `/settings/tautulli`
Get Tautulli settings.

**Response:** TautulliSettings object

### POST `/settings/tautulli`
Update Tautulli settings.

**Request Body:** TautulliSettings object

**Response:** Updated TautulliSettings object

### GET `/settings/radarr`
Get all Radarr configurations.

**Response:** Array of RadarrSettings objects

### POST `/settings/radarr`
Add Radarr configuration.

**Request Body:** RadarrSettings object

**Response:** Created RadarrSettings object

### POST `/settings/radarr/test`
Test Radarr connection.

**Request Body:** RadarrSettings object

**Response:** Test result

### PUT `/settings/radarr/{radarrId}`
Update Radarr configuration.

**Request Body:** RadarrSettings object

**Response:** Updated RadarrSettings object

### DELETE `/settings/radarr/{radarrId}`
Delete Radarr configuration.

**Response:** 204 No Content

### GET `/settings/radarr/{radarrId}/profiles`
Get Radarr quality profiles.

**Response:** Array of quality profile objects

### GET `/settings/sonarr`
Get all Sonarr configurations.

**Response:** Array of SonarrSettings objects

### POST `/settings/sonarr`
Add Sonarr configuration.

**Request Body:** SonarrSettings object

**Response:** Created SonarrSettings object

### POST `/settings/sonarr/test`
Test Sonarr connection.

**Request Body:** SonarrSettings object

**Response:** Test result

### PUT `/settings/sonarr/{sonarrId}`
Update Sonarr configuration.

**Request Body:** SonarrSettings object

**Response:** Updated SonarrSettings object

### DELETE `/settings/sonarr/{sonarrId}`
Delete Sonarr configuration.

**Response:** 204 No Content

### GET `/settings/jobs`
Get scheduled jobs.

**Response:** Array of job objects

### POST `/settings/jobs/{jobId}/run`
Manually run a job.

**Response:** Job execution result

### POST `/settings/jobs/{jobId}/cancel`
Cancel a running job.

**Response:** Job cancellation result

### POST `/settings/jobs/{jobId}/schedule`
Update job schedule.

**Request Body:** Schedule configuration

**Response:** Updated job object

### GET `/settings/cache`
Get cache information.

**Response:** Array of cache objects

### POST `/settings/cache/{cacheId}/flush`
Flush specific cache.

**Response:** Flush result

### GET `/settings/logs`
Get application logs.

**Query Parameters:**
- `take` (number): Number of log entries
- `skip` (number): Offset
- `filter` (string): Log level filter

**Response:** Paginated log entries

### GET `/settings/notifications/email`
Get email notification settings.

**Response:** EmailSettings object

### POST `/settings/notifications/email`
Update email notification settings.

**Request Body:** EmailSettings object

**Response:** Updated EmailSettings object

### POST `/settings/notifications/email/test`
Test email notification.

**Response:** Test result

### GET `/settings/notifications/discord`
Get Discord notification settings.

**Response:** DiscordSettings object

### POST `/settings/notifications/discord`
Update Discord notification settings.

**Request Body:** DiscordSettings object

**Response:** Updated DiscordSettings object

### POST `/settings/notifications/discord/test`
Test Discord notification.

**Response:** Test result

### GET `/settings/notifications/lunasea`
Get LunaSea notification settings.

**Response:** LunaSeaSettings object

### POST `/settings/notifications/lunasea`
Update LunaSea notification settings.

**Request Body:** LunaSeaSettings object

**Response:** Updated LunaSeaSettings object

### POST `/settings/notifications/lunasea/test`
Test LunaSea notification.

**Response:** Test result

### GET `/settings/notifications/pushbullet`
Get Pushbullet notification settings.

**Response:** PushbulletSettings object

### POST `/settings/notifications/pushbullet`
Update Pushbullet notification settings.

**Request Body:** PushbulletSettings object

**Response:** Updated PushbulletSettings object

### POST `/settings/notifications/pushbullet/test`
Test Pushbullet notification.

**Response:** Test result

### GET `/settings/notifications/pushover`
Get Pushover notification settings.

**Response:** PushoverSettings object

### POST `/settings/notifications/pushover`
Update Pushover notification settings.

**Request Body:** PushoverSettings object

**Response:** Updated PushoverSettings object

### POST `/settings/notifications/pushover/test`
Test Pushover notification.

**Response:** Test result

### GET `/settings/notifications/pushover/sounds`
Get available Pushover sounds.

**Query Parameters:**
- `token` (string, required): Pushover application token

**Response:** Array of sound objects

### GET `/settings/notifications/gotify`
Get Gotify notification settings.

**Response:** GotifySettings object

### POST `/settings/notifications/gotify`
Update Gotify notification settings.

**Request Body:** GotifySettings object

**Response:** Updated GotifySettings object

### POST `/settings/notifications/gotify/test`
Test Gotify notification.

**Response:** Test result

### GET `/settings/notifications/slack`
Get Slack notification settings.

**Response:** SlackSettings object

### POST `/settings/notifications/slack`
Update Slack notification settings.

**Request Body:** SlackSettings object

**Response:** Updated SlackSettings object

### POST `/settings/notifications/slack/test`
Test Slack notification.

**Response:** Test result

### GET `/settings/notifications/telegram`
Get Telegram notification settings.

**Response:** TelegramSettings object

### POST `/settings/notifications/telegram`
Update Telegram notification settings.

**Request Body:** TelegramSettings object

**Response:** Updated TelegramSettings object

### POST `/settings/notifications/telegram/test`
Test Telegram notification.

**Response:** Test result

### GET `/settings/notifications/webpush`
Get Web Push notification settings.

**Response:** WebPushSettings object

### POST `/settings/notifications/webpush`
Update Web Push notification settings.

**Request Body:** WebPushSettings object

**Response:** Updated WebPushSettings object

### POST `/settings/notifications/webpush/test`
Test Web Push notification.

**Response:** Test result

### GET `/settings/notifications/webhook`
Get Webhook notification settings.

**Response:** WebhookSettings object

### POST `/settings/notifications/webhook`
Update Webhook notification settings.

**Request Body:** WebhookSettings object

**Response:** Updated WebhookSettings object

### POST `/settings/notifications/webhook/test`
Test Webhook notification.

**Response:** Test result

### GET `/settings/discover`
Get discover page slider configuration.

**Auth Required:** Yes

**Response:** Array of DiscoverSlider objects

### POST `/settings/discover/add`
Add new discover slider.

**Auth Required:** Admin

**Request Body:** DiscoverSlider object

**Response:** Created DiscoverSlider object

### PUT `/settings/discover/{sliderId}`
Update discover slider.

**Auth Required:** Admin

**Request Body:** DiscoverSlider object

**Response:** Updated DiscoverSlider object

### DELETE `/settings/discover/{sliderId}`
Delete discover slider.

**Auth Required:** Admin

**Response:** 204 No Content

### POST `/settings/discover/reset`
Reset discover sliders to default.

**Auth Required:** Admin

**Response:** Array of default DiscoverSlider objects

### GET `/settings/about`
Get application version and build information.

**Response:**
```json
{
  "version": "1.33.2",
  "nodeVersion": "16.13.0",
  "commitTag": "abc123",
  "buildDate": "2023-01-01T00:00:00Z"
}
```

---

## Common Data Structures

### User Object
```json
{
  "id": 1,
  "email": "user@example.com",
  "username": "username",
  "plexId": 123456,
  "plexToken": "token",
  "plexUsername": "plexuser",
  "userType": 1,
  "permissions": 2,
  "avatar": "https://...",
  "createdAt": "2023-01-01T00:00:00Z",
  "updatedAt": "2023-01-01T00:00:00Z",
  "requestCount": 5,
  "settings": {/* UserSettings */}
}
```

### MediaRequest Object
```json
{
  "id": 1,
  "status": 2,
  "createdAt": "2023-01-01T00:00:00Z",
  "updatedAt": "2023-01-01T00:00:00Z",
  "type": "movie",
  "is4k": false,
  "serverId": 1,
  "profileId": 1,
  "rootFolder": "/movies",
  "languageProfileId": 1,
  "tags": [1, 2],
  "seasons": [/* For TV */],
  "media": {/* Media object */},
  "requestedBy": {/* User object */},
  "modifiedBy": {/* User object */}
}
```

### Media Object
```json
{
  "id": 1,
  "mediaType": "movie",
  "tmdbId": 12345,
  "tvdbId": null,
  "imdbId": "tt1234567",
  "status": 5,
  "status4k": 1,
  "createdAt": "2023-01-01T00:00:00Z",
  "updatedAt": "2023-01-01T00:00:00Z",
  "lastSeasonChange": "2023-01-01T00:00:00Z",
  "mediaAddedAt": "2023-01-01T00:00:00Z",
  "serviceId": 1,
  "serviceId4k": null,
  "externalServiceId": 1,
  "externalServiceId4k": null,
  "externalServiceSlug": "slug",
  "externalServiceSlug4k": null,
  "ratingKey": "12345",
  "ratingKey4k": null,
  "requests": [/* MediaRequest objects */],
  "seasons": [/* Season objects for TV */]
}
```

### Movie Details Object
```json
{
  "id": 12345,
  "imdbId": "tt1234567",
  "adult": false,
  "budget": 100000000,
  "genres": [{"id": 28, "name": "Action"}],
  "originalLanguage": "en",
  "originalTitle": "Original Title",
  "overview": "Movie overview...",
  "popularity": 45.6,
  "releaseDate": "2023-01-01",
  "revenue": 500000000,
  "runtime": 120,
  "status": "Released",
  "tagline": "Movie tagline",
  "title": "Movie Title",
  "video": false,
  "voteAverage": 7.5,
  "voteCount": 10000,
  "backdropPath": "/backdrop.jpg",
  "posterPath": "/poster.jpg",
  "credits": {
    "cast": [/* Cast members */],
    "crew": [/* Crew members */]
  },
  "productionCompanies": [/* Companies */],
  "productionCountries": [/* Countries */],
  "spokenLanguages": [/* Languages */],
  "keywords": [/* Keywords */],
  "recommendations": {/* Related movies */},
  "similar": {/* Similar movies */},
  "releases": {/* Release info */},
  "watchProviders": [/* Watch providers */],
  "mediaInfo": {/* Media object if exists */}
}
```

### TV Details Object
```json
{
  "id": 12345,
  "name": "Series Name",
  "originalName": "Original Name",
  "overview": "Series overview...",
  "firstAirDate": "2023-01-01",
  "lastAirDate": "2023-12-31",
  "originalLanguage": "en",
  "status": "Returning Series",
  "voteAverage": 8.0,
  "voteCount": 5000,
  "popularity": 50.5,
  "backdropPath": "/backdrop.jpg",
  "posterPath": "/poster.jpg",
  "genres": [{"id": 18, "name": "Drama"}],
  "networks": [/* Networks */],
  "productionCompanies": [/* Companies */],
  "seasons": [/* Season objects */],
  "credits": {
    "cast": [/* Cast members */],
    "crew": [/* Crew members */]
  },
  "keywords": [/* Keywords */],
  "recommendations": {/* Related series */},
  "similar": {/* Similar series */},
  "watchProviders": [/* Watch providers */],
  "mediaInfo": {/* Media object if exists */}
}
```

---

## Permission Flags

Permissions are stored as bitwise flags:
- `NONE` = 0
- `ADMIN` = 2
- `MANAGE_USERS` = 8
- `MANAGE_REQUESTS` = 4
- `REQUEST` = 16
- `REQUEST_MOVIE` = 512
- `REQUEST_TV` = 1024
- `REQUEST_4K` = 2048
- `REQUEST_4K_MOVIE` = 4096
- `REQUEST_4K_TV` = 8192
- `REQUEST_ADVANCED` = 32
- `REQUEST_VIEW` = 64
- `AUTO_APPROVE` = 128
- `AUTO_APPROVE_MOVIE` = 256
- `AUTO_APPROVE_TV` = 1024 (overlaps, check docs)
- `AUTO_APPROVE_4K` = 16384
- `AUTO_APPROVE_4K_MOVIE` = 32768
- `AUTO_APPROVE_4K_TV` = 65536
- `MANAGE_ISSUES` = 131072
- `CREATE_ISSUES` = 262144
- `VIEW_ISSUES` = 524288

---

## Media Status Codes

- `UNKNOWN` = 1
- `PENDING` = 2
- `PROCESSING` = 3
- `PARTIALLY_AVAILABLE` = 4
- `AVAILABLE` = 5
- `DELETED` = 6

## Request Status Codes

- `PENDING` = 1
- `APPROVED` = 2
- `DECLINED` = 3
- `FAILED` = 4
- `COMPLETED` = 5

---

## Notes

- All timestamps are in ISO 8601 format
- Pagination typically uses `take` and `skip` query parameters
- Most endpoints support `language` query parameter for localization
- Admin endpoints require `ADMIN` permission (value: 2)
- Default base URL is `http://localhost:5055/api/v1` but can be configured
