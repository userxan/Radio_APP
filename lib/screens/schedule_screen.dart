import 'package:flutter/material.dart';
import '../config/station_config.dart';
import '../theme/glass_theme.dart';

class ScheduleScreen extends StatefulWidget {
  final StationConfig config;

  const ScheduleScreen({super.key, required this.config});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String _selectedDay = 'All';

  @override
  Widget build(BuildContext context) {
    final days = <String>{
      'All',
      ...widget.config.schedule.map((s) => s.dayOfWeek),
    }.toList();

    final filtered = _selectedDay == 'All'
        ? widget.config.schedule
        : widget.config.schedule
            .where((s) => s.dayOfWeek == _selectedDay)
            .toList();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 4),
            child: Text(
              'Show Schedule',
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
              'Lineup & DJs on ${widget.config.stationName}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final day = days[index];
                final selected = day == _selectedDay;
                return ChoiceChip(
                  label: Text(day),
                  selected: selected,
                  selectedColor: widget.config.primaryColor,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  side: BorderSide(
                    color: selected
                        ? widget.config.primaryColor
                        : Colors.white.withValues(alpha: 0.12),
                  ),
                  labelStyle: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: Colors.white,
                  ),
                  onSelected: (_) => setState(() => _selectedDay = day),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No shows scheduled for $_selectedDay.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 160),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final show = filtered[index];
                      return _ShowCard(show: show, config: widget.config);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ShowCard extends StatelessWidget {
  final RadioShow show;
  final StationConfig config;

  const _ShowCard({required this.show, required this.config});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: BorderRadius.circular(22),
      opacity: show.isLiveNow ? 0.14 : 0.07,
      child: Row(
        children: [
          ArtworkBox(
            artworkUrl: show.artworkUrl ?? config.defaultArtworkUrl,
            primaryColor: config.primaryColor,
            accentColor: config.accentColor,
            size: 64,
            radius: 16,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (show.isLiveNow)
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF22C55E)),
                        ),
                        child: const Text(
                          'ON AIR',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF22C55E),
                          ),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        '${show.dayOfWeek} • ${show.startTime} - ${show.endTime}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: config.accentColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  show.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.mic_rounded,
                        size: 13, color: Colors.white.withValues(alpha: 0.6)),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        show.host,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
