# Pulse Instagram

Professional **Instagram-style** social media app built with Flutter.

> Custom premium UI shell (inspired by Pulse YouTube player).  
> **Own data only** — No Instagram scraping, no unofficial APIs, fully legal.

## Features

- Premium dark Instagram-like UI
- Stories bar
- Infinite scroll Feed + Reels/Shorts
- Comments, Like, Share, Follow
- Real-time Chats
- WebRTC Voice + Video Calling (Instagram-style call screen)
- Profile, Explore, Notifications
- No ads

## Tech Stack

| Layer | Technology |
|-------|------------|
| Frontend | Flutter 3.x |
| State | Riverpod |
| Backend | Firebase / Supabase (planned) |
| Realtime Chat | Firestore / Supabase Realtime |
| WebRTC | flutter_webrtc |
| Video | media_kit / video_player |

## Getting Started

```bash
git clone https://github.com/anjalifredy-ai/pulse-instagram.git
cd pulse-instagram
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── theme/
│   ├── constants/
│   └── utils/
├── models/
├── services/
├── providers/
├── screens/
│   ├── home/
│   ├── reels/
│   ├── chat/
│   ├── call/
│   ├── profile/
│   └── explore/
└── widgets/
```

## Current Status

- [x] Project scaffolding
- [x] Premium dark theme
- [x] Bottom navigation (Home / Reels / Chat / Profile)
- [x] Stories + Feed UI skeleton
- [ ] Real-time chat
- [ ] WebRTC calling
- [ ] Backend integration
- [ ] Story upload
- [ ] Reels player

## Legal Note

This is a **custom UI shell** with your own content.  
It does **not** fetch, scrape, or display any Instagram data.

---

Made with ❤️ for learning & portfolio.
