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
        'description': '',
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
    if (!ApiConstants.hasYoutubeKey) return _workingShorts();
    try {
      final channelUrl = Uri.parse(
        '${ApiConstants.youtubeBaseUrl}/channels'
        '?part=contentDetails&id=$channelId&key=${ApiConstants.youtubeApiKey}',
      );
      final channelRes = await http.get(channelUrl);
      if (channelRes.statusCode != 200) return _workingShorts();
      final channelData = jsonDecode(channelRes.body);
      final uploadsId = channelData['items']?[0]?['contentDetails']?['relatedPlaylists']?['uploads'];
      if (uploadsId == null) return _workingShorts();

      final playlistUrl = Uri.parse(
        '${ApiConstants.youtubeBaseUrl}/playlistItems'
        '?part=snippet,contentDetails&playlistId=$uploadsId'
        '&maxResults=$maxResults&key=${ApiConstants.youtubeApiKey}',
      );
      final res = await http.get(playlistUrl);
      if (res.statusCode != 200) return _workingShorts();
      final data = jsonDecode(res.body);
      final items = data['items'] as List? ?? [];
      if (items.isEmpty) return _workingShorts();

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
      }).where((e) => (e['videoId'] as String).isNotEmpty).toList();
    } catch (_) {
      return _workingShorts();
    }
  }

  Future<List<Map<String, dynamic>>> getTrendingShorts({String? pageToken}) async {
    if (!ApiConstants.hasYoutubeKey) return _workingShorts();

    try {
      // Popular videos (more often embeddable than random #shorts)
      final url = Uri.parse(
        '${ApiConstants.youtubeBaseUrl}/videos'
        '?part=snippet,contentDetails,status'
        '&chart=mostPopular'
        '&maxResults=20'
        '&regionCode=IN'
        '&videoCategoryId=24'
        '${pageToken != null ? '&pageToken=$pageToken' : ''}'
        '&key=${ApiConstants.youtubeApiKey}',
      );
      var res = await http.get(url);

      if (res.statusCode != 200) {
        // fallback no category
        final url2 = Uri.parse(
          '${ApiConstants.youtubeBaseUrl}/videos'
          '?part=snippet,contentDetails,status'
          '&chart=mostPopular'
          '&maxResults=20'
          '&regionCode=IN'
          '&key=${ApiConstants.youtubeApiKey}',
        );
        res = await http.get(url2);
      }

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final items = data['items'] as List? ?? [];
        final list = <Map<String, dynamic>>[];
        for (final item in items) {
          final snippet = item['snippet'] ?? {};
          final status = item['status'] ?? {};
          // prefer embeddable
          if (status['embeddable'] == false) continue;
          list.add({
            'videoId': item['id'] ?? '',
            'title': snippet['title'] ?? '',
            'thumbnail': snippet['thumbnails']?['high']?['url'] ??
                snippet['thumbnails']?['medium']?['url'] ?? '',
            'channelTitle': snippet['channelTitle'] ?? '',
            'channelId': snippet['channelId'] ?? '',
            'nextPageToken': data['nextPageToken'],
          });
        }
        if (list.isNotEmpty) return list;
      }

      // Second try: search shorts from known embeddable channels / general
      final searchUrl = Uri.parse(
        '${ApiConstants.youtubeBaseUrl}/search'
        '?part=snippet&type=video&videoEmbeddable=true&videoSyndicated=true'
        '&q=${Uri.encodeComponent("shorts")}'
        '&videoDuration=medium'
        '&order=viewCount&maxResults=15'
        '&key=${ApiConstants.youtubeApiKey}',
      );
      final res2 = await http.get(searchUrl);
      if (res2.statusCode == 200) {
        final data = jsonDecode(res2.body);
        final items = data['items'] as List? ?? [];
        final list = items.map((item) {
          final snippet = item['snippet'] ?? {};
          final id = item['id'] ?? {};
          return {
            'videoId': id['videoId'] ?? '',
            'title': snippet['title'] ?? '',
            'thumbnail': snippet['thumbnails']?['high']?['url'] ??
                snippet['thumbnails']?['medium']?['url'] ?? '',
            'channelTitle': snippet['channelTitle'] ?? '',
            'channelId': snippet['channelId'] ?? '',
            'nextPageToken': data['nextPageToken'],
          };
        }).where((e) => (e['videoId'] as String).isNotEmpty).toList();
        if (list.isNotEmpty) return list;
      }

      return _workingShorts();
    } catch (_) {
      return _workingShorts();
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
          'title': query.isEmpty ? 'Google for Developers' : query,
          'description': 'Sample',
          'thumbnail': '',
        },
      ];

  /// Known publicly embeddable short-ish videos that always work
  List<Map<String, dynamic>> _workingShorts() => [
        {
          'videoId': 'jNQXAC9IVRw',
          'title': 'Me at the zoo',
          'thumbnail': 'https://i.ytimg.com/vi/jNQXAC9IVRw/hqdefault.jpg',
          'channelTitle': 'jawed',
          'channelId': 'UC4QobU6STFB0P71PPvEX1Sg',
        },
        {
          'videoId': 'aqz-KE-bpKQ',
          'title': 'Big Buck Bunny',
          'thumbnail': 'https://i.ytimg.com/vi/aqz-KE-bpKQ/hqdefault.jpg',
          'channelTitle': 'Blender Foundation',
          'channelId': 'UCSMOQeBJ2RAnuFungnQOxLn',
        },
        {
          'videoId': 'LXb3EKWsInQ',
          'title': 'Costa Rica in 4K',
          'thumbnail': 'https://i.ytimg.com/vi/LXb3EKWsInQ/hqdefault.jpg',
          'channelTitle': 'Jacob + Katie Schwarz',
          'channelId': 'UCz0PbBzqTLW1J1ADr34XjlQ',
        },
        {
          'videoId': 'hY7m5jjJ9mM',
          'title': 'Cat vibing',
          'thumbnail': 'https://i.ytimg.com/vi/hY7m5jjJ9mM/hqdefault.jpg',
          'channelTitle': 'Welcome to the Zoo',
          'channelId': 'UC6uKrU_WqJ1R2WKRvUYLKLg',
        },
        {
          'videoId': 'C0DPdy98e4c',
          'title': 'Test Video',
          'thumbnail': 'https://i.ytimg.com/vi/C0DPdy98e4c/hqdefault.jpg',
          'channelTitle': 'Dummy',
          'channelId': 'UC_dummy',
        },
      ];
}
