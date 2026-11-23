import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/station_config.dart';

/// Pulls live News, Podcasts, and Schedule from a station's existing website
/// (supporting RSS/Podcast XML, WordPress REST JSON, AzuraCast, or custom JSON).
class LiveContentService {
  static const _cachePrefix = 'live_feed_';

  Future<List<NewsArticle>> fetchNews(StationConfig config) async {
    final url = config.newsFeedUrl?.trim();
    if (url == null || url.isEmpty) return config.news;

    final body = await _fetchWithCache('${config.clientId}_news', url);
    if (body == null) return config.news;

    final parsed = parseNewsBody(body, fallbackStation: config.stationName);
    return parsed.isNotEmpty ? parsed : config.news;
  }

  Future<List<PodcastEpisode>> fetchPodcasts(StationConfig config) async {
    final url = config.podcastFeedUrl?.trim();
    if (url == null || url.isEmpty) return config.podcasts;

    final body = await _fetchWithCache('${config.clientId}_podcasts', url);
    if (body == null) return config.podcasts;

    final parsed = parsePodcastBody(body, fallbackShow: config.stationName);
    return parsed.isNotEmpty ? parsed : config.podcasts;
  }

  Future<List<RadioShow>> fetchSchedule(StationConfig config) async {
    final url = config.scheduleFeedUrl?.trim();
    if (url == null || url.isEmpty) return config.schedule;

    final body = await _fetchWithCache('${config.clientId}_schedule', url);
    if (body == null) return config.schedule;

    final parsed = parseScheduleBody(body);
    return parsed.isNotEmpty ? parsed : config.schedule;
  }

  Future<String?> _fetchWithCache(String key, String url) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cachePrefix$key';

    try {
      final res =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200 && res.body.trim().isNotEmpty) {
        await prefs.setString(cacheKey, res.body);
        return res.body;
      }
    } catch (_) {
      // Network error: fall back to cache.
    }
    return prefs.getString(cacheKey);
  }

  /// Parses JSON (custom or WordPress REST API) or RSS/Atom XML into [NewsArticle]s.
  static List<NewsArticle> parseNewsBody(
    String body, {
    String fallbackStation = 'Station',
  }) {
    final trimmed = body.trim();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      try {
        final decoded = jsonDecode(trimmed);
        final list = decoded is List
            ? decoded
            : (decoded as Map<String, dynamic>)['news'] as List<dynamic>? ??
                const [];
        return list.map((item) {
          final map = item as Map<String, dynamic>;
          // Detect WordPress REST API post format (`title.rendered`).
          if (map['title'] is Map<String, dynamic>) {
            final title = _stripHtml(
                (map['title'] as Map<String, dynamic>)['rendered']?.toString() ??
                    '');
            final excerpt = _stripHtml(
                (map['excerpt'] as Map<String, dynamic>?)?['rendered']
                        ?.toString() ??
                    '');
            final content = _stripHtml(
                (map['content'] as Map<String, dynamic>?)?['rendered']
                        ?.toString() ??
                    '');
            final embedded = map['_embedded'] as Map<String, dynamic>?;
            final mediaList = embedded?['wp:featuredmedia'] as List<dynamic>?;
            final imageUrl = mediaList != null && mediaList.isNotEmpty
                ? (mediaList.first as Map<String, dynamic>)['source_url']
                    ?.toString()
                : null;
            return NewsArticle(
              id: map['id']?.toString() ?? title,
              title: title,
              category: 'News',
              summary: excerpt.isNotEmpty ? excerpt : content,
              body: content.isNotEmpty ? content : excerpt,
              publishedAt: _shortDate(map['date']?.toString() ?? ''),
              imageUrl: imageUrl,
              articleUrl: map['link']?.toString(),
            );
          }
          return NewsArticle.fromJson(map);
        }).toList();
      } catch (_) {
        return const [];
      }
    }

    // RSS XML fallback
    final items = _extractXmlBlocks(trimmed, 'item');
    return items.map((xml) {
      final title = _stripHtml(_xmlTag(xml, 'title'));
      final desc = _stripHtml(_xmlTag(xml, 'description'));
      final link = _xmlTag(xml, 'link');
      final cat = _stripHtml(_xmlTag(xml, 'category'));
      final pubDate = _shortDate(_xmlTag(xml, 'pubDate'));
      final image = _xmlAttr(xml, 'enclosure', 'url') ??
          _xmlAttr(xml, 'media:content', 'url');
      return NewsArticle(
        id: link.isNotEmpty ? link : title,
        title: title.isEmpty ? '$fallbackStation Update' : title,
        category: cat.isEmpty ? 'News' : cat,
        summary: desc,
        body: desc,
        publishedAt: pubDate,
        imageUrl: image,
        articleUrl: link.isNotEmpty ? link : null,
      );
    }).toList();
  }

  /// Parses JSON or standard Podcast RSS XML into [PodcastEpisode]s.
  static List<PodcastEpisode> parsePodcastBody(
    String body, {
    String fallbackShow = 'Podcast',
  }) {
    final trimmed = body.trim();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      try {
        final decoded = jsonDecode(trimmed);
        final list = decoded is List
            ? decoded
            : (decoded as Map<String, dynamic>)['podcasts'] as List<dynamic>? ??
                const [];
        return list
            .map((e) => PodcastEpisode.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return const [];
      }
    }

    // Standard Podcast RSS XML (`<item>` + `<enclosure url="...mp3">`)
    final channelImage = _xmlAttr(trimmed, 'itunes:image', 'href');
    final items = _extractXmlBlocks(trimmed, 'item');
    final episodes = <PodcastEpisode>[];
    for (final xml in items) {
      final audioUrl = _xmlAttr(xml, 'enclosure', 'url') ?? '';
      if (audioUrl.isEmpty) continue;
      final title = _stripHtml(_xmlTag(xml, 'title'));
      final desc = _stripHtml(_xmlTag(xml, 'description'));
      final pubDate = _shortDate(_xmlTag(xml, 'pubDate'));
      final img = _xmlAttr(xml, 'itunes:image', 'href') ?? channelImage;
      final durStr = _xmlTag(xml, 'itunes:duration');

      episodes.add(PodcastEpisode(
        id: audioUrl,
        title: title.isEmpty ? 'Episode' : title,
        showName: fallbackShow,
        audioUrl: audioUrl,
        artworkUrl: img,
        publishedDate: pubDate,
        duration: _parseDuration(durStr),
        description: desc,
      ));
    }
    return episodes;
  }

  /// Parses JSON (custom or AzuraCast schedule) into [RadioShow]s.
  static List<RadioShow> parseScheduleBody(String body) {
    final trimmed = body.trim();
    if (!trimmed.startsWith('{') && !trimmed.startsWith('[')) return const [];
    try {
      final decoded = jsonDecode(trimmed);
      final list = decoded is List
          ? decoded
          : (decoded as Map<String, dynamic>)['schedule'] as List<dynamic>? ??
              const [];
      return list.map((item) {
        final map = item as Map<String, dynamic>;
        // AzuraCast `/api/station/1/schedule` support
        if (map.containsKey('start') && map.containsKey('name')) {
          return RadioShow(
            id: map['id']?.toString() ?? map['name'].toString(),
            title: map['name']?.toString() ?? 'Show',
            host: map['streamer']?.toString() ?? '',
            dayOfWeek: 'Today',
            startTime: _extractTime(map['start']?.toString() ?? ''),
            endTime: _extractTime(map['end']?.toString() ?? ''),
            isLiveNow: map['is_now'] == true,
          );
        }
        return RadioShow.fromJson(map);
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  static List<String> _extractXmlBlocks(String xml, String tag) {
    final reg = RegExp('<$tag\\b[^>]*>([\\s\\S]*?)</$tag>', caseSensitive: false);
    return reg.allMatches(xml).map((m) => m.group(1) ?? '').toList();
  }

  static String _xmlTag(String xml, String tag) {
    final reg = RegExp('<$tag\\b[^>]*>([\\s\\S]*?)</$tag>', caseSensitive: false);
    final raw = reg.firstMatch(xml)?.group(1) ?? '';
    return raw
        .replaceAll(RegExp(r'<!\[CDATA\['), '')
        .replaceAll(']]>', '')
        .trim();
  }

  static String? _xmlAttr(String xml, String tag, String attr) {
    final reg = RegExp(
      '<$tag\\b[^>]*$attr=["\']([^"\']+)["\']',
      caseSensitive: false,
    );
    return reg.firstMatch(xml)?.group(1);
  }

  static String _stripHtml(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _shortDate(String raw) {
    if (raw.isEmpty) return '';
    if (raw.length >= 16) return raw.substring(0, 16).trim();
    return raw;
  }

  static String _extractTime(String iso) {
    final match = RegExp(r'T(\d{2}:\d{2})').firstMatch(iso);
    return match?.group(1) ?? iso;
  }

  static Duration _parseDuration(String raw) {
    if (raw.isEmpty) return Duration.zero;
    final secsOnly = int.tryParse(raw);
    if (secsOnly != null) return Duration(seconds: secsOnly);
    final parts = raw.split(':').map(int.tryParse).toList();
    if (parts.length == 2 && parts[0] != null && parts[1] != null) {
      return Duration(minutes: parts[0]!, seconds: parts[1]!);
    }
    if (parts.length == 3 &&
        parts[0] != null &&
        parts[1] != null &&
        parts[2] != null) {
      return Duration(
          hours: parts[0]!, minutes: parts[1]!, seconds: parts[2]!);
    }
    return Duration.zero;
  }
}
