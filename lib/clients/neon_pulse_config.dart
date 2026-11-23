import 'package:flutter/material.dart';
import '../config/station_config.dart';

/// Client Flavor #2: Neon Pulse (Example of a second white-label client)
const neonPulseConfig = StationConfig(
  clientId: 'neon_pulse',
  stationName: 'Neon Pulse Radio',
  tagline: 'Non-Stop Electronic & House',
  frequencyBadge: 'DIGITAL',
  streamUrl: 'https://stream.zeno.fm/0r0xa792kwzuv',
  sourceType: StreamSourceType.hls,
  primaryColor: Color(0xFFEC4899), // Hot Magenta
  accentColor: Color(0xFFF59E0B), // Amber Gold
  logoAssetPath: 'assets/clients/neon_pulse/logo.png',
  enableSchedule: true,
  enablePodcasts: false, // Podcasts tab automatically hidden for this client!
  enableNews: true,
  aboutText: '24/7 underground house, melodic techno, and festival mixes.',
  studioWhatsapp: '+27 82 555 1047',
  studioEmail: 'hello@neonpulse.example.com',
  news: [
    NewsArticle(
      id: 'np-news-1',
      title: 'Resident DJ Elena V Drops New Rooftop Set',
      category: 'Music',
      publishedAt: '1h ago',
      summary: 'Catch the full 90-minute sunset session this Friday night.',
    ),
  ],
  schedule: [
    RadioShow(
      id: 'np-1',
      title: 'Afterhours Deep House',
      host: 'Elena V',
      dayOfWeek: 'Daily',
      startTime: '22:00',
      endTime: '02:00',
      isLiveNow: true,
    ),
    RadioShow(
      id: 'np-2',
      title: 'Synthwave Sunset',
      host: 'Koda',
      dayOfWeek: 'Weekends',
      startTime: '18:00',
      endTime: '22:00',
    ),
  ],
  socialLinks: [
    SocialLink(
      label: 'YouTube Live',
      url: 'https://youtube.com',
      iconKey: 'youtube',
    ),
  ],
);
