import 'package:flutter/material.dart';
import '../config/station_config.dart';

/// Client Flavor #1: Eden FM
const edenFmConfig = StationConfig(
  clientId: 'eden_fm',
  stationName: 'Eden FM 98.4',
  tagline: 'Your Sound. Your City.',
  frequencyBadge: '98.4 FM',
  streamUrl: 'https://stream.zeno.fm/0r0xa792kwzuv',
  sourceType: StreamSourceType.icy,
  // Optional: point to your hosted JSON to update streamUrl/schedule/news remotely
  // remoteConfigUrl: 'https://cdn.youragency.com/configs/eden_fm.json',
  primaryColor: Color(0xFF7C3AED), // Electric Violet
  accentColor: Color(0xFF06B6D4), // Cyan Glow
  logoAssetPath: 'assets/clients/eden_fm/logo.png',
  enableSchedule: true,
  enablePodcasts: true,
  enableNews: true,
  aboutText:
      'Broadcasting live 24/7 with the biggest hits, local stories, live traffic updates, and community voices across the Garden Route.',
  studioPhone: '+27 44 801 0984',
  studioWhatsapp: '+27 82 555 0984',
  studioSms: '37984',
  studioEmail: 'studio@edenfm.example.com',
  newsDeskEmail: 'news@edenfm.example.com',
  studioAddress: 'Broadcast House, 14 York Street, George',
  promo: StationPromo(
    badgeText: 'ON-AIR COMPETITION',
    title: 'Win R10,000 on The Morning Rise!',
    subtitle: 'Send a WhatsApp voice note with #EdenMorning to enter.',
    actionUrl: 'https://wa.me/27825550984',
  ),
  news: [
    NewsArticle(
      id: 'news-1',
      title: 'Summer Music Festival Lineup Announced for December',
      category: 'Music',
      publishedAt: '2h ago',
      summary:
          'Over 15 local and national artists are set to headline the open-air stage this summer.',
      body:
          'Over 15 local and national artists are set to headline the open-air stage this summer. Gates open at 14:00, with live broadcasts from the Eden FM studio bus all weekend long.',
    ),
    NewsArticle(
      id: 'news-2',
      title: 'N2 Highway Morning Traffic Advisory Near Airport Turnoff',
      category: 'Traffic',
      publishedAt: '3h ago',
      summary:
          'Expect 15-minute delays eastbound due to scheduled roadworks until 11:00.',
      body:
          'Expect 15-minute delays eastbound due to scheduled roadworks until 11:00. Commuters are advised to use the alternate coastal route.',
    ),
    NewsArticle(
      id: 'news-3',
      title: 'Local Youth Charity Drive Reaches R250,000 Milestone',
      category: 'Local',
      publishedAt: 'Yesterday',
      summary:
          'Thank you to every listener who donated school supplies and winter kits.',
      body:
          'Thank you to every listener who donated school supplies and winter kits during our 12-hour radiothon. Deliveries begin this Monday across 12 local schools.',
    ),
  ],
  schedule: [
    RadioShow(
      id: 'show-1',
      title: 'The Morning Rise',
      host: 'DJ Maya & Leo',
      dayOfWeek: 'Weekdays',
      startTime: '06:00',
      endTime: '10:00',
      isLiveNow: true,
    ),
    RadioShow(
      id: 'show-2',
      title: 'Midday Acoustic Lounge',
      host: 'Sarah Jenkins',
      dayOfWeek: 'Weekdays',
      startTime: '10:00',
      endTime: '14:00',
    ),
    RadioShow(
      id: 'show-3',
      title: 'Drive Time Beats',
      host: 'Marcus Cole',
      dayOfWeek: 'Weekdays',
      startTime: '16:00',
      endTime: '19:00',
    ),
    RadioShow(
      id: 'show-4',
      title: 'Saturday Club Mix',
      host: 'DJ Kairo',
      dayOfWeek: 'Weekends',
      startTime: '21:00',
      endTime: '01:00',
    ),
  ],
  podcasts: [
    PodcastEpisode(
      id: 'ep-101',
      title: 'Behind the Scenes: Summer Festival Special',
      showName: 'The Morning Rise',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      publishedDate: 'Nov 20, 2026',
      duration: Duration(minutes: 42),
      description: 'Full replay of our live backstage interviews.',
    ),
    PodcastEpisode(
      id: 'ep-102',
      title: 'Top 20 Indie Tracks of the Month',
      showName: 'Midday Acoustic Lounge',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      publishedDate: 'Nov 16, 2026',
      duration: Duration(minutes: 55),
      description: 'Curated countdown with artist stories.',
    ),
  ],
  socialLinks: [
    SocialLink(
      label: 'Instagram',
      url: 'https://instagram.com',
      iconKey: 'instagram',
    ),
    SocialLink(
      label: 'YouTube',
      url: 'https://youtube.com',
      iconKey: 'youtube',
    ),
    SocialLink(
      label: 'Official Website',
      url: 'https://example.com',
      iconKey: 'website',
    ),
  ],
);
