import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../config/station_config.dart';
import 'metadata_adapter.dart';

/// Unified audio engine for both Live Radio streams and On-Demand Podcasts.
/// Integrates with iOS Control Center / Android Lock-Screen notifications.
class RadioAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player = AudioPlayer();
  StationConfig _config;
  late MetadataAdapter _metadataAdapter;

  final ValueNotifier<PodcastEpisode?> activeEpisode = ValueNotifier(null);
  final ValueNotifier<NowPlayingInfo> nowPlaying = ValueNotifier(
    const NowPlayingInfo(title: 'Loading...', artist: ''),
  );
  final ValueNotifier<Duration?> sleepTimerRemaining = ValueNotifier(null);

  Timer? _sleepTimer;
  Timer? _sleepTick;
  StreamSubscription<NowPlayingInfo>? _metaSub;
  StreamSubscription<IcyMetadata?>? _icySub;

  RadioAudioHandler(this._config) {
    _metadataAdapter = MetadataAdapter(_config);
    nowPlaying.value = _metadataAdapter.latest;
    _initAudioSession();
    _wirePlayerEvents();
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  void _wirePlayerEvents() {
    // Broadcast playback state to OS lock screen & UI
    _player.playbackEventStream.listen((event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          if (activeEpisode.value != null) MediaControl.rewind,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          if (activeEpisode.value != null) MediaControl.fastForward,
        ],
        systemActions: {
          if (activeEpisode.value != null) MediaAction.seek,
          MediaAction.playPause,
          MediaAction.stop,
        },
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
      ));
    });

    // Listen to ICY metadata from Icecast/Shoutcast streams
    _icySub = _player.icyMetadataStream.listen((icy) {
      if (activeEpisode.value == null) {
        _metadataAdapter.updateFromIcyTitle(icy?.info?.title);
      }
    });

    // Listen to unified metadata updates
    _metaSub = _metadataAdapter.stream.listen((info) {
      if (activeEpisode.value == null) {
        nowPlaying.value = info;
        _updateMediaItem(
          id: _config.streamUrl,
          title: info.title,
          artist: info.artist,
          artworkUrl: info.artworkUrl,
        );
      }
    });
  }

  void updateConfig(StationConfig updatedConfig) {
    final streamChanged = _config.streamUrl != updatedConfig.streamUrl;
    _config = updatedConfig;
    _metadataAdapter.dispose();
    _metadataAdapter = MetadataAdapter(_config);
    _metaSub?.cancel();
    _metaSub = _metadataAdapter.stream.listen((info) {
      if (activeEpisode.value == null) {
        nowPlaying.value = info;
        _updateMediaItem(
          id: _config.streamUrl,
          title: info.title,
          artist: info.artist,
          artworkUrl: info.artworkUrl,
        );
      }
    });

    if (activeEpisode.value == null) {
      nowPlaying.value = _metadataAdapter.latest;
      if (streamChanged && _player.playing) {
        playLive();
      }
    }
  }

  /// Starts or resumes the live radio stream.
  Future<void> playLive() async {
    activeEpisode.value = null;
    nowPlaying.value = _metadataAdapter.latest;
    _metadataAdapter.startPolling();

    _updateMediaItem(
      id: _config.streamUrl,
      title: _metadataAdapter.latest.title,
      artist: _metadataAdapter.latest.artist,
      artworkUrl: _metadataAdapter.latest.artworkUrl,
    );

    await _player.setAudioSource(
      AudioSource.uri(Uri.parse(_config.streamUrl)),
    );
    await _player.play();
  }

  /// Plays an on-demand podcast episode or show replay.
  Future<void> playEpisode(PodcastEpisode episode) async {
    _metadataAdapter.stopPolling();
    activeEpisode.value = episode;
    nowPlaying.value = NowPlayingInfo(
      title: episode.title,
      artist: episode.showName,
      artworkUrl: episode.artworkUrl ?? _config.defaultArtworkUrl,
      isLive: false,
    );

    _updateMediaItem(
      id: episode.id,
      title: episode.title,
      artist: episode.showName,
      artworkUrl: episode.artworkUrl ?? _config.defaultArtworkUrl,
      duration: episode.duration,
    );

    await _player.setAudioSource(
      AudioSource.uri(Uri.parse(episode.audioUrl)),
    );
    await _player.play();
  }

  @override
  Future<void> play() async {
    if (_player.audioSource == null) {
      await playLive();
    } else {
      await _player.play();
    }
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    _metadataAdapter.stopPolling();
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    if (activeEpisode.value != null) {
      await _player.seek(position);
    }
  }

  @override
  Future<void> rewind() async {
    if (activeEpisode.value != null) {
      final target = _player.position - const Duration(seconds: 15);
      await _player.seek(target < Duration.zero ? Duration.zero : target);
    }
  }

  @override
  Future<void> fastForward() async {
    if (activeEpisode.value != null) {
      await _player.seek(_player.position + const Duration(seconds: 30));
    }
  }

  Future<void> setVolume(double volume) => _player.setVolume(volume.clamp(0.0, 1.0));

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  /// Sets or cancels a sleep timer that pauses playback after [duration].
  void setSleepTimer(Duration? duration) {
    _sleepTimer?.cancel();
    _sleepTick?.cancel();

    if (duration == null) {
      sleepTimerRemaining.value = null;
      return;
    }

    var remaining = duration;
    sleepTimerRemaining.value = remaining;

    _sleepTick = Timer.periodic(const Duration(seconds: 1), (_) {
      remaining -= const Duration(seconds: 1);
      if (remaining <= Duration.zero) {
        sleepTimerRemaining.value = null;
        _sleepTick?.cancel();
      } else {
        sleepTimerRemaining.value = remaining;
      }
    });

    _sleepTimer = Timer(duration, () {
      pause();
      sleepTimerRemaining.value = null;
      _sleepTick?.cancel();
    });
  }

  void _updateMediaItem({
    required String id,
    required String title,
    required String artist,
    String? artworkUrl,
    Duration? duration,
  }) {
    mediaItem.add(MediaItem(
      id: id,
      album: _config.stationName,
      title: title,
      artist: artist,
      duration: duration,
      artUri: artworkUrl != null ? Uri.tryParse(artworkUrl) : null,
    ));
  }

  Future<void> disposeHandler() async {
    _sleepTimer?.cancel();
    _sleepTick?.cancel();
    await _metaSub?.cancel();
    await _icySub?.cancel();
    _metadataAdapter.dispose();
    await _player.dispose();
  }
}
