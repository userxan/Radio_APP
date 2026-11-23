import 'package:flutter/material.dart';

/// Supported streaming & metadata backends for the flexible adapter.
enum StreamSourceType {
  icy,
  hls,
  azuracast,
  radioco,
}

/// Represents a scheduled radio show or DJ slot.
class RadioShow {
  final String id;
  final String title;
  final String host;
  final String dayOfWeek; // e.g., 'Monday', 'Daily', 'Weekends'
  final String startTime; // e.g., '08:00'
  final String endTime; // e.g., '11:00'
  final String? artworkUrl;
  final String description;
  final bool isLiveNow;

  const RadioShow({
    required this.id,
    required this.title,
    required this.host,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.artworkUrl,
    this.description = '',
    this.isLiveNow = false,
  });

  factory RadioShow.fromJson(Map<String, dynamic> json) {
    return RadioShow(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Show',
      host: json['host']?.toString() ?? '',
      dayOfWeek: json['dayOfWeek']?.toString() ?? 'Daily',
      startTime: json['startTime']?.toString() ?? '00:00',
      endTime: json['endTime']?.toString() ?? '00:00',
      artworkUrl: json['artworkUrl']?.toString(),
      description: json['description']?.toString() ?? '',
      isLiveNow: json['isLiveNow'] == true,
    );
  }
}

/// Represents an on-demand podcast or show replay episode.
class PodcastEpisode {
  final String id;
  final String title;
  final String showName;
  final String audioUrl;
  final String? artworkUrl;
  final String publishedDate;
  final Duration duration;
  final String description;

  const PodcastEpisode({
    required this.id,
    required this.title,
    required this.showName,
    required this.audioUrl,
    this.artworkUrl,
    required this.publishedDate,
    required this.duration,
    this.description = '',
  });

  factory PodcastEpisode.fromJson(Map<String, dynamic> json) {
    return PodcastEpisode(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Episode',
      showName: json['showName']?.toString() ?? '',
      audioUrl: json['audioUrl']?.toString() ?? '',
      artworkUrl: json['artworkUrl']?.toString(),
      publishedDate: json['publishedDate']?.toString() ?? '',
      duration:
          Duration(seconds: (json['durationSeconds'] as num?)?.toInt() ?? 0),
      description: json['description']?.toString() ?? '',
    );
  }
}

/// Represents a news, traffic, sport, or entertainment story.
class NewsArticle {
  final String id;
  final String title;
  final String category; // e.g., 'Local', 'Music', 'Sport', 'Traffic'
  final String summary;
  final String body;
  final String publishedAt;
  final String? imageUrl;
  final String? articleUrl;

  const NewsArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    this.body = '',
    required this.publishedAt,
    this.imageUrl,
    this.articleUrl,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Station Update',
      category: json['category']?.toString() ?? 'Local',
      summary: json['summary']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      publishedAt: json['publishedAt']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      articleUrl: json['articleUrl']?.toString(),
    );
  }
}

/// Highlighted competition, event, or campaign card in the Station Info hub.
class StationPromo {
  final String title;
  final String subtitle;
  final String badgeText;
  final String? actionUrl;

  const StationPromo({
    required this.title,
    required this.subtitle,
    this.badgeText = 'COMPETITION',
    this.actionUrl,
  });

  factory StationPromo.fromJson(Map<String, dynamic> json) {
    return StationPromo(
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      badgeText: json['badgeText']?.toString() ?? 'COMPETITION',
      actionUrl: json['actionUrl']?.toString(),
    );
  }
}

/// Social or contact link displayed in the Station Info hub.
class SocialLink {
  final String label;
  final String url;
  final String iconKey; // 'instagram', 'website', 'whatsapp', 'youtube', 'x'

  const SocialLink({
    required this.label,
    required this.url,
    required this.iconKey,
  });

  factory SocialLink.fromJson(Map<String, dynamic> json) {
    return SocialLink(
      label: json['label']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      iconKey: json['iconKey']?.toString() ?? 'website',
    );
  }
}

/// Master white-label configuration for a radio client.
class StationConfig {
  final String clientId;
  final String stationName;
  final String tagline;
  final String frequencyBadge; // e.g., '98.4 FM' or 'DIGITAL'
  final String streamUrl;
  final StreamSourceType sourceType;

  /// Optional metadata API endpoint (e.g., AzuraCast or Radio.co status URL).
  final String? metadataApiUrl;

  /// Optional hosted JSON URL for Hybrid Remote Config updates.
  final String? remoteConfigUrl;

  /// Optional live website/feed URLs (RSS/Atom XML, WordPress JSON, or custom JSON).
  final String? newsFeedUrl;
  final String? podcastFeedUrl;
  final String? scheduleFeedUrl;

  // Branding & Theme
  final Color primaryColor;
  final Color accentColor;
  final String logoAssetPath;
  final String? defaultArtworkUrl;

  // Feature Flags (toggleable per client)
  final bool enableSchedule;
  final bool enablePodcasts;
  final bool enableNews;

  // Studio & Contact Details (for the reworked Station Info hub)
  final String aboutText;
  final String? studioPhone;
  final String? studioWhatsapp;
  final String? studioSms;
  final String? studioEmail;
  final String? newsDeskEmail;
  final String? studioAddress;
  final StationPromo? promo;

  // Content (can be populated locally or overridden via Remote JSON)
  final List<RadioShow> schedule;
  final List<PodcastEpisode> podcasts;
  final List<NewsArticle> news;
  final List<SocialLink> socialLinks;

  const StationConfig({
    required this.clientId,
    required this.stationName,
    required this.tagline,
    this.frequencyBadge = 'LIVE FM',
    required this.streamUrl,
    this.sourceType = StreamSourceType.icy,
    this.metadataApiUrl,
    this.remoteConfigUrl,
    this.newsFeedUrl,
    this.podcastFeedUrl,
    this.scheduleFeedUrl,
    required this.primaryColor,
    required this.accentColor,
    required this.logoAssetPath,
    this.defaultArtworkUrl,
    this.enableSchedule = true,
    this.enablePodcasts = true,
    this.enableNews = true,
    this.aboutText = '',
    this.studioPhone,
    this.studioWhatsapp,
    this.studioSms,
    this.studioEmail,
    this.newsDeskEmail,
    this.studioAddress,
    this.promo,
    this.schedule = const [],
    this.podcasts = const [],
    this.news = const [],
    this.socialLinks = const [],
  });

  /// Merges remote JSON overrides onto the compiled local flavor config.
  StationConfig copyWithRemoteJson(Map<String, dynamic> json) {
    final sourceStr = json['sourceType']?.toString().toLowerCase();
    final parsedSource = StreamSourceType.values.firstWhere(
      (e) => e.name == sourceStr,
      orElse: () => sourceType,
    );

    return StationConfig(
      clientId: clientId,
      stationName: json['stationName']?.toString() ?? stationName,
      tagline: json['tagline']?.toString() ?? tagline,
      frequencyBadge: json['frequencyBadge']?.toString() ?? frequencyBadge,
      streamUrl: json['streamUrl']?.toString() ?? streamUrl,
      sourceType: parsedSource,
      metadataApiUrl: json['metadataApiUrl']?.toString() ?? metadataApiUrl,
      remoteConfigUrl: remoteConfigUrl,
      newsFeedUrl: json['newsFeedUrl']?.toString() ?? newsFeedUrl,
      podcastFeedUrl: json['podcastFeedUrl']?.toString() ?? podcastFeedUrl,
      scheduleFeedUrl: json['scheduleFeedUrl']?.toString() ?? scheduleFeedUrl,
      primaryColor: _parseColor(json['primaryColorHex']) ?? primaryColor,
      accentColor: _parseColor(json['accentColorHex']) ?? accentColor,
      logoAssetPath: logoAssetPath,
      defaultArtworkUrl:
          json['defaultArtworkUrl']?.toString() ?? defaultArtworkUrl,
      enableSchedule: json['enableSchedule'] as bool? ?? enableSchedule,
      enablePodcasts: json['enablePodcasts'] as bool? ?? enablePodcasts,
      enableNews: json['enableNews'] as bool? ?? enableNews,
      aboutText: json['aboutText']?.toString() ?? aboutText,
      studioPhone: json['studioPhone']?.toString() ?? studioPhone,
      studioWhatsapp: json['studioWhatsapp']?.toString() ?? studioWhatsapp,
      studioSms: json['studioSms']?.toString() ?? studioSms,
      studioEmail: json['studioEmail']?.toString() ?? studioEmail,
      newsDeskEmail: json['newsDeskEmail']?.toString() ?? newsDeskEmail,
      studioAddress: json['studioAddress']?.toString() ?? studioAddress,
      promo: json['promo'] is Map<String, dynamic>
          ? StationPromo.fromJson(json['promo'] as Map<String, dynamic>)
          : promo,
      schedule: (json['schedule'] as List<dynamic>?)
              ?.map((e) => RadioShow.fromJson(e as Map<String, dynamic>))
              .toList() ??
          schedule,
      podcasts: (json['podcasts'] as List<dynamic>?)
              ?.map((e) => PodcastEpisode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          podcasts,
      news: (json['news'] as List<dynamic>?)
              ?.map((e) => NewsArticle.fromJson(e as Map<String, dynamic>))
              .toList() ??
          news,
      socialLinks: (json['socialLinks'] as List<dynamic>?)
              ?.map((e) => SocialLink.fromJson(e as Map<String, dynamic>))
              .toList() ??
          socialLinks,
    );
  }

  static Color? _parseColor(dynamic hexValue) {
    if (hexValue is! String || hexValue.isEmpty) return null;
    final cleaned = hexValue.replaceFirst('#', '');
    final buffer = StringBuffer();
    if (cleaned.length == 6) buffer.write('ff');
    buffer.write(cleaned);
    final parsed = int.tryParse(buffer.toString(), radix: 16);
    return parsed != null ? Color(parsed) : null;
  }
}
