import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import '../config/station_config.dart';
import '../services/metadata_adapter.dart';
import '../services/radio_audio_handler.dart';
import '../theme/glass_theme.dart';
import 'live_player_screen.dart';
import 'podcasts_screen.dart';
import 'schedule_screen.dart';

class HomeShell extends StatefulWidget {
  final StationConfig config;
  final RadioAudioHandler audioHandler;

  const HomeShell({
    super.key,
    required this.config,
    required this.audioHandler,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = <_NavTab>[
      _NavTab(
        label: 'Listen',
        icon: Icons.radio_rounded,
        screen: LivePlayerScreen(
          config: widget.config,
          audioHandler: widget.audioHandler,
        ),
      ),
      if (widget.config.enableSchedule)
        _NavTab(
          label: 'Schedule',
          icon: Icons.calendar_month_rounded,
          screen: ScheduleScreen(config: widget.config),
        ),
      if (widget.config.enablePodcasts)
        _NavTab(
          label: 'Podcasts',
          icon: Icons.headphones_rounded,
          screen: PodcastsScreen(
            config: widget.config,
            audioHandler: widget.audioHandler,
            onEpisodeSelected: () => setState(() => _currentIndex = 0),
          ),
        ),
    ];

    final safeIndex = _currentIndex.clamp(0, tabs.length - 1);

    return Scaffold(
      body: ValueListenableBuilder<NowPlayingInfo>(
        valueListenable: widget.audioHandler.nowPlaying,
        builder: (context, info, _) {
          return AmbientBackdrop(
            artworkUrl: info.artworkUrl,
            primaryColor: widget.config.primaryColor,
            accentColor: widget.config.accentColor,
            child: Stack(
              children: [
                IndexedStack(
                  index: safeIndex,
                  children: tabs.map((t) => t.screen).toList(),
                ),
                // Persistent mini-player when browsing Schedule or Podcasts
                if (safeIndex != 0)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 88,
                    child: _MiniPlayerBar(
                      config: widget.config,
                      audioHandler: widget.audioHandler,
                      info: info,
                      onTap: () => setState(() => _currentIndex = 0),
                    ),
                  ),
                // Floating glass bottom navigation (shown if 2+ tabs are enabled)
                if (tabs.length > 1)
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 18,
                    child: SafeArea(
                      top: false,
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        borderRadius: BorderRadius.circular(28),
                        opacity: 0.11,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: List.generate(tabs.length, (index) {
                            final tab = tabs[index];
                            final selected = index == safeIndex;
                            return Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () =>
                                    setState(() => _currentIndex = index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 220),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? widget.config.primaryColor
                                            .withValues(alpha: 0.28)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        tab.icon,
                                        size: 18,
                                        color: selected
                                            ? Colors.white
                                            : Colors.white
                                                .withValues(alpha: 0.55),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        tab.label,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: selected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          color: selected
                                              ? Colors.white
                                              : Colors.white
                                                  .withValues(alpha: 0.55),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MiniPlayerBar extends StatelessWidget {
  final StationConfig config;
  final RadioAudioHandler audioHandler;
  final NowPlayingInfo info;
  final VoidCallback onTap;

  const _MiniPlayerBar({
    required this.config,
    required this.audioHandler,
    required this.info,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderRadius: BorderRadius.circular(20),
      opacity: 0.14,
      onTap: onTap,
      child: Row(
        children: [
          ArtworkBox(
            artworkUrl: info.artworkUrl,
            primaryColor: config.primaryColor,
            accentColor: config.accentColor,
            size: 42,
            radius: 12,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  info.title,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  info.artist,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.65),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          StreamBuilder<PlaybackState>(
            stream: audioHandler.playbackState,
            builder: (context, snapshot) {
              final playing = snapshot.data?.playing ?? false;
              return IconButton(
                onPressed: () =>
                    playing ? audioHandler.pause() : audioHandler.play(),
                icon: Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _NavTab {
  final String label;
  final IconData icon;
  final Widget screen;

  const _NavTab({
    required this.label,
    required this.icon,
    required this.screen,
  });
}
