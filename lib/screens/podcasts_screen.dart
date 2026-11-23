import 'package:flutter/material.dart';
import '../config/station_config.dart';
import '../services/radio_audio_handler.dart';
import '../theme/glass_theme.dart';

class PodcastsScreen extends StatelessWidget {
  final StationConfig config;
  final RadioAudioHandler audioHandler;
  final VoidCallback onEpisodeSelected;

  const PodcastsScreen({
    super.key,
    required this.config,
    required this.audioHandler,
    required this.onEpisodeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final episodes = config.podcasts;

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 4),
            child: Text(
              'Podcasts & Replays',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Listen on demand anytime',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: episodes.isEmpty
                ? Center(
                    child: Text(
                      'No podcast episodes available yet.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    ),
                  )
                : ValueListenableBuilder<PodcastEpisode?>(
                    valueListenable: audioHandler.activeEpisode,
                    builder: (context, active, _) {
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 4, 24, 160),
                        itemCount: episodes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final ep = episodes[index];
                          final isPlayingThis = active?.id == ep.id;

                          return GlassCard(
                            padding: const EdgeInsets.all(14),
                            borderRadius: BorderRadius.circular(22),
                            opacity: isPlayingThis ? 0.14 : 0.07,
                            onTap: () {
                              audioHandler.playEpisode(ep);
                              onEpisodeSelected();
                            },
                            child: Row(
                              children: [
                                ArtworkBox(
                                  artworkUrl:
                                      ep.artworkUrl ?? config.defaultArtworkUrl,
                                  primaryColor: config.primaryColor,
                                  accentColor: config.accentColor,
                                  size: 64,
                                  radius: 16,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${ep.showName} • ${ep.publishedDate}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: config.accentColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        ep.title,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (ep.description.isNotEmpty) ...[
                                        const SizedBox(height: 3),
                                        Text(
                                          ep.description,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white
                                                .withValues(alpha: 0.6),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isPlayingThis
                                        ? config.primaryColor
                                        : Colors.white.withValues(alpha: 0.12),
                                  ),
                                  child: Icon(
                                    isPlayingThis
                                        ? Icons.volume_up_rounded
                                        : Icons.play_arrow_rounded,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
