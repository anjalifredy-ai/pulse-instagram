import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

class YoutubeService {
  static final YoutubeService _instance = YoutubeService._();
  factory YoutubeService() => _instance;
  YoutubeService._();

  /// Search YouTube channels (for Instagram-style search)
  Future<List<Map<String, dynamic>>> searchChannels(String query, {int maxResults = 20}) async {
    if (ApiConstants.youtubeApiKey == 'YOUR_YOUTUBE_DATA_API_KEY_HERE') {
      return _dummyChannels(query);
    }

    final url = Uri.parse(
      '${ApiConstants.youtubeBaseUrl}/search'
      '?part=snippet'
      '&type=channel'
      '&q=${Uri.encodeComponent(query)}'
      '&maxResults=$maxResults'
      '&key=${ApiConstants.youtubeApiKey}',
    );

    final res = await http.get(url);
    if (res.statusCode != 200) return _dummyChannels(query);

    final data = jsonDecode(res.body);
    final items = data['items'] as List? ?? [];

    return items.map((item) {
      final snippet = item['snippet'];
      return {
        'channelId': item['snippet']['channelId'] ?? item['id']['channelId'],
        'title': snippet['title'] ?? '',
        'description': snippet['description'] ?? '',
        'thumbnail': snippet['thumbnails']?['high']?['url'] ??
            snippet['thumbnails']?['default']?['url'] ?? '',
        'publishedAt': snippet['publishedAt'] ?? '',
      };
    }).toList();
  }

  /// Get channel details
  Future<Map<String, dynamic>?> getChannelDetails(String channelId) async {
    if (ApiConstants.youtubeApiKey == 'YOUR_YOUTUBE_DATA_API_KEY_HERE') {
      return {
        'channelId': channelId,
        'title': 'Sample Channel',
        'description': 'This is a sample channel. Add your YouTube API key for real data.',
        'thumbnail': '',
        'subscriberCount': '1.2M',
        'videoCount': '240',
      };
    }

    final url = Uri.parse(
      '${ApiConstants.youtubeBaseUrl}/channels'
      '?part=snippet,statistics'
      '&id=$channelId'
      '&key=${ApiConstants.youtubeApiKey}',
    );

    final res = await http.get(url);
    if (res.statusCode != 200) return null;

    final data = jsonDecode(res.body);
    final items = data['items'] as List? ?? [];
    if (items.isEmpty) return null;

    final item = items.first;
    final snippet = item['snippet'];
    final stats = item['statistics'];

    return {
      'channelId': channelId,
      'title': snippet['title'] ?? '',
      'description': snippet['description'] ?? '',
      'thumbnail': snippet['thumbnails']?['high']?['url'] ?? '',
      'subscriberCount': _formatCount(stats['subscriberCount']),
      'videoCount': stats['videoCount'] ?? '0',
    };
  }

  /// Get Shorts / videos from a channel (for profile + feed)
  Future<List<Map<String, dynamic>>> getChannelShorts(String channelId, {int maxResults = 30}) async {
    if (ApiConstants.youtubeApiKey == 'YOUR_YOUTUBE_DATA_API_KEY_HERE') {
      return _dummyShorts();
    }

    // First get uploads playlist
    final channelUrl = Uri.parse(
      '${ApiConstants.youtubeBaseUrl}/channels'
      '?part=contentDetails'
      '&id=$channelId'
      '&key=${ApiConstants.youtubeApiKey}',
    );

    final channelRes = await http.get(channelUrl);
    if (channelRes.statusCode != 200) return _dummyShorts();

    final channelData = jsonDecode(channelRes.body);
    final uploadsId = channelData['items']?[0]?['contentDetails']?['relatedPlaylists']?['uploads'];
    if (uploadsId == null) return _dummyShorts();

    final playlistUrl = Uri.parse(
      '${ApiConstants.youtubeBaseUrl}/playlistItems'
      '?part=snippet,contentDetails'
      '&playlistId=$uploadsId'
      '&maxResults=$maxResults'
      '&key=${ApiConstants.youtubeApiKey}',
    );

    final res = await http.get(playlistUrl);
    if (res.statusCode != 200) return _dummyShorts();

    final data = jsonDecode(res.body);
    final items = data['items'] as List? ?? [];

    return items.map((item) {
      final snippet = item['snippet'];
      final videoId = item['contentDetails']?['videoId'] ?? snippet['resourceId']?['videoId'];
      return {
        'videoId': videoId,
        'title': snippet['title'] ?? '',
        'description': snippet['description'] ?? '',
        'thumbnail': snippet['thumbnails']?['high']?['url'] ??
            snippet['thumbnails']?['medium']?['url'] ?? '',
        'channelTitle': snippet['channelTitle'] ?? '',
        'channelId': snippet['channelId'] ?? channelId,
        'publishedAt': snippet['publishedAt'] ?? '',
      };
    }).toList();
  }

  /// Popular / trending Shorts for Home feed (unlimited scroll base)
  Future<List<Map<String, dynamic>>> getTrendingShorts({String? pageToken}) async {
    if (ApiConstants.youtubeApiKey == 'YOUR_YOUTUBE_DATA_API_KEY_HERE') {
      return _dummyShorts();
    }

    final url = Uri.parse(
      '${ApiConstants.youtubeBaseUrl}/search'
      '?part=snippet'
      '&type=video'
      '&videoDuration=short'
      '&order=viewCount'
      '&maxResults=20'
      '${pageToken != null ? '&pageToken=$pageToken' : ''}'
      '&key=${ApiConstants.youtubeApiKey}',
    );

    final res = await http.get(url);
    if (res.statusCode != 200) return _dummyShorts();

    final data = jsonDecode(res.body);
    final items = data['items'] as List? ?? [];

    return items.map((item) {
      final snippet = item['snippet'];
      return {
        'videoId': item['id']['videoId'],
        'title': snippet['title'] ?? '',
        'description': snippet['description'] ?? '',
        'thumbnail': snippet['thumbnails']?['high']?['url'] ?? '',
        'channelTitle': snippet['channelTitle'] ?? '',
        'channelId': snippet['channelId'] ?? '',
        'publishedAt': snippet['publishedAt'] ?? '',
        'nextPageToken': data['nextPageToken'],
      };
    }).toList();
  }

  String _formatCount(dynamic count) {
    if (count == null) return '0';
    final n = int.tryParse(count.toString()) ?? 0;
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  List<Map<String, dynamic>> _dummyChannels(String query) {
    return [
      {
        'channelId': 'UC_dummy1',
        'title': query.isEmpty ? 'Senpai Spider' : '$query Official',
        'description': 'Sample channel. Add YouTube API key for real results.',
        'thumbnail': '',
        'publishedAt': '',
      },
      {
        'channelId': 'UC_dummy2',
        'title': 'SpaceX',
        'description': 'SpaceX official channel',
        'thumbnail': '',
        'publishedAt': '',
      },
    ];
  }

  List<Map<String, dynamic>> _dummyShorts() {
    return [
      {
        'videoId': 'dQw4w9WgXcQ',
        'title': 'Sample Short 1 - Add API key for real Shorts',
        'description': '',
        'thumbnail': 'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
        'channelTitle': 'Sample',
        'channelId': 'UC_dummy',
        'publishedAt': '',
      },
      {
        'videoId': 'jNQXAC9IVRw',
        'title': 'Sample Short 2',
        'description': '',
        'thumbnail': 'https://i.ytimg.com/vi/jNQXAC9IVRw/hqdefault.jpg',
        'channelTitle': 'Sample',
        'channelId': 'UC_dummy',
        'publishedAt': '',
      },
    ];
  }
}
