import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/station_config.dart';

/// Unified Now Playing metadata regardless of stream backend.
class NowPlayingInfo {
  final String title;
  final String artist;
  final String? artworkUrl;
  final String? showName;
  final bool isLive;

  const NowPlayingInfo({
    required this.title,
    required this.artist,
    this.artworkUrl,
    this.showName,
    this.isLive = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NowPlayingInfo &&
          title == other.title &&
          artist == other.artist &&
          artworkUrl == other.artworkUrl &&
          showName == other.showName &&
          isLive == other.isLive;

  @override
  int get hashCode => Object.hash(title, artist, artworkUrl, showName, isLive);
}

/// Flexible metadata adapter supporting ICY, HLS, AzuraCast, and Radio.co.
class MetadataAdapter {
  final StationConfig config;
  Timer? _pollTimer;
  final _controller = StreamController<NowPlayingInfo>.broadcast();

  Stream<NowPlayingInfo> get stream => _controller.stream;

  NowPlayingInfo _latest;
  NowPlayingInfo get latest => _latest;

  MetadataAdapter(this.config)
      : _latest = NowPlayingInfo(
          title: config.stationName,
          artist: config.tagline,
          artworkUrl: config.defaultArtworkUrl,
          isLive: true,
        );

  /// Starts polling external APIs (AzuraCast / Radio.co) if configured.
  void startPolling({Duration interval = const Duration(seconds: 15)}) {
    stopPolling();
    if (config.sourceType == StreamSourceType.azuracast ||
        config.sourceType == StreamSourceType.radioco) {
      _fetchExternalMetadata();
      _pollTimer = Timer.periodic(interval, (_) => _fetchExternalMetadata());
    }
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Parses raw ICY metadata string (typically "Artist - Song Title").
  void updateFromIcyTitle(String? rawTitle) {
    if (config.sourceType == StreamSourceType.azuracast ||
        config.sourceType == StreamSourceType.radioco) {
      return; // External API provides richer data + artwork.
    }
    if (rawTitle == null || rawTitle.trim().isEmpty) return;

    final cleaned = rawTitle.trim();
    final separatorIndex = cleaned.indexOf(' - ');
    final String artist;
    final String title;

    if (separatorIndex != -1) {
      artist = cleaned.substring(0, separatorIndex).trim();
      title = cleaned.substring(separatorIndex + 3).trim();
    } else {
      artist = config.stationName;
      title = cleaned;
    }

    _emit(NowPlayingInfo(
      title: title.isEmpty ? config.stationName : title,
      artist: artist.isEmpty ? config.tagline : artist,
      artworkUrl: config.defaultArtworkUrl,
      isLive: true,
    ));
  }

  Future<void> _fetchExternalMetadata() async {
    final url = config.metadataApiUrl;
    if (url == null || url.isEmpty) return;

    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (config.sourceType == StreamSourceType.azuracast) {
        final nowPlaying = data['now_playing'] as Map<String, dynamic>?;
        final song = nowPlaying?['song'] as Map<String, dynamic>?;
        final live = data['live'] as Map<String, dynamic>?;

        final isLiveStreamer = live != null && live['is_live'] == true;
        _emit(NowPlayingInfo(
          title: (song != null ? song['title']?.toString() : null) ?? config.stationName,
          artist: (song != null ? song['artist']?.toString() : null) ?? config.tagline,
          artworkUrl: (song != null ? song['art']?.toString() : null) ?? config.defaultArtworkUrl,
          showName: isLiveStreamer ? live['streamer_name']?.toString() : null,
          isLive: true,
        ));
      } else if (config.sourceType == StreamSourceType.radioco) {
        final currentTrack = data['current_track'] as Map<String, dynamic>?;
        final rawTitle = currentTrack?['title']?.toString() ?? '';
        final parts = rawTitle.split(' - ');
        _emit(NowPlayingInfo(
          title: parts.length > 1 ? parts.sublist(1).join(' - ') : rawTitle,
          artist: parts.isNotEmpty ? parts.first : config.stationName,
          artworkUrl: currentTrack?['artwork_url_large']?.toString() ??
              currentTrack?['artwork_url']?.toString() ??
              config.defaultArtworkUrl,
          isLive: true,
        ));
      }
    } catch (_) {
      // Keep last known metadata silently on transient network errors.
    }
  }

  void _emit(NowPlayingInfo info) {
    if (info != _latest) {
      _latest = info;
      if (!_controller.isClosed) {
        _controller.add(info);
      }
    }
  }

  void dispose() {
    stopPolling();
    _controller.close();
  }
}
