import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

class YoutubeService {
  static final YoutubeService _instance = YoutubeService._();
  factory YoutubeService() => _instance;
  YoutubeService._();

  Future<List<Map<String, dynamic>>> searchChannels(String query, {int maxResults = 20}) async {
    if (!ApiConstants.hasYoutubeKey) return _dummyChannels(query);

    try {
      final url = Uri.parse(
        '${ApiConstants.youtubeBaseUrl}/search'
        '?part=snippet&type=channel&q=${Uri.encodeComponent(query)}'
        '&maxResults=$maxResults&key=${ApiConstants.youtubeApiKey}',
      );
      final res = await http.get(url);
      if (res.statusCode != 200) return _dummyChannels(query);

      final data = jsonDecode(res.body);
      final items = data['items'] as List? ?? [];

      return items.map((item) {
        final snippet = item['snippet'] ?? {};
        final id = item['id'] ?? {};
        return {
          'channelId': id['channelId'] ?? snippet['channelId'] ?? '',
          'title': snippet['title'] ?? '',
          'description': snippet['description'] ?? '',
          'thumbnail': snippet['thumbnails']?['high']?['url'] ??
              snippet['thumbnails']?['medium']?['url'] ??
              snippet['thumbnails']?['default']?['url'] ?? '',
        };
      }).toList();
    } catch (_) {
      return _dummyChannels(query);
    }
  }

  Future<Map<String, dynamic>?> getChannelDetails(String channelId) async {
    if (!ApiConstants.hasYoutubeKey) {
      return {
        'channelId': channelId,
        'title': 'Sample Channel',
        'description': 'Add YouTube API key for real data',
        'thumbnail': '',
        'subscriberCount': '1.2M',
        'videoCount': '240',
      };
    }

    try {
      final url = Uri.parse(
        '${ApiConstants.youtubeBaseUrl}/channels'
        '?part=snippet,statistics&id=$channelId&key=${ApiConstants.youtubeApiKey}',
      );
      final res = await http.get(url);
      if (res.statusCode != 200) return null;

      final data = jsonDecode(res.body);
      final items = data['items'] as List? ?? [];
      if (items.isEmpty) return null;

      final item = items.first;
      final snippet = item['snippet'] ?? {};
      final stats = item['statistics'] ?? {};

      return {
        'channelId': channelId,
        'title': snippet['title'] ?? '',
        'description': snippet['description'] ?? '',
        'thumbnail': snippet['thumbnails']?['high']?['url'] ?? '',
        'subscriberCount': _formatCount(stats['subscriberCount']),
        'videoCount': stats['videoCount']?.toString() ?? '0',
      };
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getChannelShorts(String channelId, {int maxResults = 30}) async {
    if (!ApiConstants.hasYoutubeKey) return _dummyShorts();

    try {
      final channelUrl = Uri.parse(
        '${ApiConstants.youtubeBaseUrl}/channels'
        '?part=contentDetails&id=$channelId&key=${ApiConstants.youtubeApiKey}',
      );
      final channelRes = await http.get(channelUrl);
      if (channelRes.statusCode != 200) return _dummyShorts();

      final channelData = jsonDecode(channelRes.body);
      final uploadsId = channelData['items']?[0]?['contentDetails']?['relatedPlaylists']?['uploads'];
      if (uploadsId == null) return _dummyShorts();

      final playlistUrl = Uri.parse(
        '${ApiConstants.youtubeBaseUrl}/playlistItems'
        '?part=snippet,contentDetails&playlistId=$uploadsId'
        '&maxResults=$maxResults&key=${ApiConstants.youtubeApiKey}',
      );
      final res = await http.get(playlistUrl);
      if (res.statusCode != 200) return _dummyShorts();

      final data = jsonDecode(res.body);
      final items = data['items'] as List? ?? [];

      return items.map((item) {
        final snippet = item['snippet'] ?? {};
        final videoId = item['contentDetails']?['videoId'] ?? snippet['resourceId']?['videoId'];
        return {
          'videoId': videoId ?? '',
          'title': snippet['title'] ?? '',
          'thumbnail': snippet['thumbnails']?['high']?['url'] ??
              snippet['thumbnails']?['medium']?['url'] ?? '',
          'channelTitle': snippet['channelTitle'] ?? '',
          'channelId': snippet['channelId'] ?? channelId,
        };
      }).toList();
    } catch (_) {
      return _dummyShorts();
    }
  }

  Future<List<Map<String, dynamic>>> getTrendingShorts({String? pageToken}) async {
    if (!ApiConstants.hasYoutubeKey) return _dummyShorts();

    try {
      final url = Uri.parse(
        '${ApiConstants.youtubeBaseUrl}/search'
        '?part=snippet&type=video&videoDuration=short&order=viewCount'
        '&maxResults=15'
        '${pageToken != null ? '&pageToken=$pageToken' : ''}'
        '&key=${ApiConstants.youtubeApiKey}',
      );
      final res = await http.get(url);
      if (res.statusCode != 200) return _dummyShorts();

      final data = jsonDecode(res.body);
      final items = data['items'] as List? ?? [];

      return items.map((item) {
        final snippet = item['snippet'] ?? {};
        final id = item['id'] ?? {};
        return {
          'videoId': id['videoId'] ?? '',
          'title': snippet['title'] ?? '',
          'thumbnail': snippet['thumbnails']?['high']?['url'] ?? '',
          'channelTitle': snippet['channelTitle'] ?? '',
          'channelId': snippet['channelId'] ?? '',
          'nextPageToken': data['nextPageToken'],
        };
      }).toList();
    } catch (_) {
      return _dummyShorts();
    }
  }

  String _formatCount(dynamic count) {
    if (count == null) return '0';
    final n = int.tryParse(count.toString()) ?? 0;
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  List<Map<String, dynamic>> _dummyChannels(String query) => [
        {
          'channelId': 'UC_x5XG1OV2P6uZZ5FSM9Ttw',
          'title': query.isEmpty ? 'Google for Developers' : '$query',
          'description': 'Sample. API key missing or error.',
          'thumbnail': '',
        },
      ];

  List<Map<String, dynamic>> _dummyShorts() => [
        {
          'videoId': 'dQw4w9WgXcQ',
          'title': 'Sample Short - Add API key for real data',
          'thumbnail': 'https://i.ytimg.com/vi/dQw4w9WgXcQ/hqdefault.jpg',
          'channelTitle': 'Sample',
          'channelId': 'UC_dummy',
        },
      ];
}
