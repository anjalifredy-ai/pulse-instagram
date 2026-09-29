class ApiConstants {
  // Read from --dart-define=YOUTUBE_API_KEY=xxx (GitHub Secret or local)
  static const String youtubeApiKey = String.fromEnvironment(
    'YOUTUBE_API_KEY',
    defaultValue: '',
  );

  static bool get hasYoutubeKey => youtubeApiKey.isNotEmpty;

  static const String youtubeBaseUrl = 'https://www.googleapis.com/youtube/v3';
}
