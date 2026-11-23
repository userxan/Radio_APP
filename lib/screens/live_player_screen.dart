import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import '../config/station_config.dart';
import '../services/metadata_adapter.dart';
import '../services/radio_audio_handler.dart';
import '../theme/glass_theme.dart';

class LivePlayerScreen extends StatefulWidget {
  final StationConfig config;
  final RadioAudioHandler audioHandler;

  const LivePlayerScreen({
    super.key,
    required this.config,
    required this.audioHandler,
  });

  @override
  State<LivePlayerScreen> createState() => _LivePlayerScreenState();
}

class _LivePlayerScreenState extends State<LivePlayerScreen> {
  double _volume = 1.0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ValueListenableBuilder<NowPlayingInfo>(
        valueListenable: widget.audioHandler.nowPlaying,
        builder: (context, info, _) {
          return ValueListenableBuilder<PodcastEpisode?>(
            valueListenable: widget.audioHandler.activeEpisode,
            builder: (context, episode, _) {
              final isPodcast = episode != null;

              return LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 660;
                  final gap = compact ? 14.0 : 24.0;
                  final bottomPad = compact ? 96.0 : 110.0;

                  return Padding(
                    padding: EdgeInsets.fromLTRB(24, 12, 24, bottomPad),
                    child: Column(
                      children: [
                        _buildTopBar(context, isPodcast),
                        const Spacer(flex: 2),
                        _buildArtwork(info, maxHeight: constraints.maxHeight * 0.36),
                        const Spacer(flex: 2),
                        _buildTrackDetails(info, isPodcast),
                        SizedBox(height: gap),
                        if (isPodcast) _buildPodcastScrubber() else _buildLiveBar(),
                        SizedBox(height: gap),
                        _buildPrimaryControls(isPodcast),
                        SizedBox(height: gap),
                        _buildVolumeSlider(),
                        const Spacer(),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isPodcast) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.config.stationName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isPodcast
                          ? widget.config.accentColor
                          : const Color(0xFF22C55E),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isPodcast ? 'ON-DEMAND REPLAY' : 'LIVE ON AIR',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (isPodcast)
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            borderRadius: BorderRadius.circular(20),
            onTap: widget.audioHandler.playLive,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.radio_rounded, size: 15),
                SizedBox(width: 6),
                Text('Back to Live',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.config.primaryColor.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.config.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              widget.config.frequencyBadge,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: widget.config.accentColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildArtwork(NowPlayingInfo info, {double? maxHeight}) {
    return StreamBuilder<PlaybackState>(
      stream: widget.audioHandler.playbackState,
      builder: (context, snapshot) {
        final playing = snapshot.data?.playing ?? false;
        final width = MediaQuery.sizeOf(context).width;
        final maxAllowed = maxHeight ?? 310.0;
        final artSize = (width - 80).clamp(180.0, maxAllowed.clamp(180.0, 310.0));

        return AnimatedScale(
          scale: playing ? 1.0 : 0.93,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          child: ArtworkBox(
            artworkUrl: info.artworkUrl,
            primaryColor: widget.config.primaryColor,
            accentColor: widget.config.accentColor,
            size: artSize,
            radius: 32,
          ),
        );
      },
    );
  }

  Widget _buildTrackDetails(NowPlayingInfo info, bool isPodcast) {
    return Column(
      children: [
        if (info.showName != null && info.showName!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: widget.config.primaryColor.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.config.primaryColor.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                info.showName!,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        Text(
          info.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          info.artist,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveBar() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      borderRadius: BorderRadius.circular(18),
      child: Row(
        children: [
          Icon(
            Icons.radio_rounded,
            size: 16,
            color: widget.config.accentColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.config.tagline,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodcastScrubber() {
    return StreamBuilder<Duration?>(
      stream: widget.audioHandler.durationStream,
      builder: (context, durSnap) {
        final total = durSnap.data ?? Duration.zero;
        return StreamBuilder<Duration>(
          stream: widget.audioHandler.positionStream,
          builder: (context, posSnap) {
            final pos = posSnap.data ?? Duration.zero;
            final maxMs = total.inMilliseconds > 0 ? total.inMilliseconds.toDouble() : 1.0;
            final currentMs = pos.inMilliseconds.clamp(0, maxMs.toInt()).toDouble();

            return Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    activeTrackColor: widget.config.primaryColor,
                    inactiveTrackColor: Colors.white.withValues(alpha: 0.16),
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    value: currentMs,
                    max: maxMs,
                    onChanged: (val) {
                      widget.audioHandler.seek(Duration(milliseconds: val.toInt()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_formatDuration(pos),
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.6))),
                      Text(_formatDuration(total),
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPrimaryControls(bool isPodcast) {
    return StreamBuilder<PlaybackState>(
      stream: widget.audioHandler.playbackState,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final playing = state?.playing ?? false;
        final buffering = state?.processingState == AudioProcessingState.loading ||
            state?.processingState == AudioProcessingState.buffering;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isPodcast)
              IconButton(
                onPressed: widget.audioHandler.rewind,
                iconSize: 28,
                icon: const Icon(Icons.replay_10_rounded),
              ),
            if (isPodcast) const SizedBox(width: 20),
            GestureDetector(
              onTap: () {
                if (playing) {
                  widget.audioHandler.pause();
                } else {
                  widget.audioHandler.play();
                }
              },
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.config.primaryColor,
                      widget.config.accentColor,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.config.primaryColor.withValues(alpha: 0.45),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: buffering
                      ? const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.8,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 36,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
            if (isPodcast) const SizedBox(width: 20),
            if (isPodcast)
              IconButton(
                onPressed: widget.audioHandler.fastForward,
                iconSize: 28,
                icon: const Icon(Icons.forward_30_rounded),
              ),
          ],
        );
      },
    );
  }

  Widget _buildVolumeSlider() {
    return Row(
      children: [
        Icon(
          _volume == 0 ? Icons.volume_off_rounded : Icons.volume_down_rounded,
          size: 18,
          color: Colors.white.withValues(alpha: 0.6),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              activeTrackColor: Colors.white.withValues(alpha: 0.85),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.15),
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: _volume,
              onChanged: (v) {
                setState(() => _volume = v);
                widget.audioHandler.setVolume(v);
              },
            ),
          ),
        ),
        Icon(
          Icons.volume_up_rounded,
          size: 18,
          color: Colors.white.withValues(alpha: 0.6),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final mins = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final secs = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${d.inHours}:$mins:$secs';
    }
    return '$mins:$secs';
  }
}
