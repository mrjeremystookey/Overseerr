# Overseerr iOS App Feature Breakdown

## 1. Core User Experience (Discovery & Requesting)
This is the "Storefront" of the app where users spend 90% of their time.

### Home Dashboard
*   **Trending & Popular**: Carousels for Trending Movies/TV and Popular content (using `/discover/trending`).
*   **Upcoming**: A section for "Coming Soon" to generate hype (using `/discover/movies/upcoming`).
*   **Continue Watching / Watchlist**: Integration with the Plex Watchlist for easy access (`/user/{userId}/watchlist`).
*   **Featured Sliders**: Configurable sliders (Recently Added, Staff Picks) if set up in settings.

### Unified Search
*   A powerful search bar that hits the `/search` endpoint to return Movies, TV Shows, and People.
*   **Voice Search** using iOS Speech recognition for easier input.

### Rich Media Details
*   **Header**: Hero image/backdrop with a Play/Request button.
*   **Status Indicators**: Clearly show if an item is `Available`, `Pending`, `Processing`, or `Requested`.
*   **Metadata**: Synopsis, Cast & Crew (with clickable profiles), Studio, and Genres.
*   **Ratings**: Combined Rotten Tomatoes & IMDb scores (`/movie/{id}/ratingscombined`).
*   **Recommendations**: "Similar Content" and "Recommendations" horizontal lists at the bottom.

### Smart Request Flow
*   **One-Tap Request**: For standard users, a simple "Request" button.
*   **Advanced Options**: For power users/admins, a sheet to select `Quality Profile`, `Root Folder`, `Language Profile`, and `4K` toggle (`POST /request`).
*   **Season Selection**: For TV shows, a granular selector to request specific seasons or all seasons.

## 2. The "Activity" Hub (Status & History)
Users need to know *when* their stuff is ready.

*   **Request Feed**: A list of recent requests showing their state (Approved, Processing, Available).
*   **Issue Reporting**: Allow users to report audio/video issues directly from the media detail page (`/issue`).
*   **Push Notifications**:
    *   Native iOS notifications when content becomes available.
    *   Actionable notifications for Admins to "Approve" or "Deny" a request directly from the lock screen.

## 3. Admin & Power User Features
Give server owners control without needing the web UI.

*   **Request Management Queue**:
    *   A dedicated "Requests" tab for admins.
    *   Swipe actions: Swipe Left to **Deny**, Swipe Right to **Approve**.
    *   Filter by User, Status (Pending, Processing), or Media Type.
*   **User Management**:
    *   View user list and edit permissions/quotas (`/user/{id}/permissions`).
    *   Approve new users who sign up via Plex.
*   **Service Status**:
    *   A "Health" view showing if Radarr/Sonarr instances are online (`/status`).

## 4. iOS System Integration (The "Polish")
These features make it feel like a native app, not just a wrapper.

*   **Home Screen Widgets**:
    *   **"Up Next"**: What’s recently added to Plex.
    *   **"Pending Requests"**: A count for admins of requests needing approval.
*   **Shareplay / Link Handling**: Support universal links so sharing an Overseerr URL opens the app directly to that movie.
*   **Haptic Feedback**: Subtle vibrations when requesting or approving items.
*   **Dark Mode**: A true black (OLED) theme for browsing at night.
