# Pulse

Instagram-style social app with **YouTube Shorts**, Stories, Chats & WebRTC calls.

## Features

- Premium dark Instagram UI
- **YouTube Shorts** (legal Data API) in Reels + Home feed
- Unlimited scroll
- Search YouTube channels → Instagram-style profile + Follow
- Stories (Firebase)
- Auth (Email / Guest)
- Chats + Instagram-style Call screen
- WebRTC ready with proper permissions

## Setup

1. Clone repo
2. Add YouTube Data API key as GitHub Secret `YOUTUBE_API_KEY` (or local `--dart-define`)
3. `google-services.json` already present for `com.pulse.instagram`
4. `flutter pub get && flutter run`

### Local run with API key
```bash
flutter run --dart-define=YOUTUBE_API_KEY=your_key_here
```

## Package
`com.pulse.instagram`

## Firebase
Project: `viewtube-v2`
