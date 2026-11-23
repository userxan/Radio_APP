import 'package:flutter/material.dart';
import '../config/station_config.dart';

/// Client Flavor #1: Eden FM
const edenFmConfig = StationConfig(
  clientId: 'eden_fm',
  stationName: 'Eden FM 98.4',
  tagline: 'Your Sound. Your City.',
  streamUrl: 'https://stream.zeno.fm/0r0xa792kwzuv',
  sourceType: StreamSourceType.icy,
  // Optional: point to your hosted JSON to update streamUrl/schedule remotely
  // remoteConfigUrl: 'https://cdn.youragency.com/configs/eden_fm.json',
  primaryColor: Color(0xFF7C3AED), // Electric Violet
  accentColor: Color(0xFF06B6D4),  // Cyan Glow
  logoAssetPath: 'assets/clients/eden_fm/logo.png',
  enableSchedule: true,
  enablePodcasts: true,
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
      label: 'Website',
      url: 'https://example.com',
      iconKey: 'website',
    ),
    SocialLink(
      label: 'WhatsApp Studio',
      url: 'https://wa.me/1234567890',
      iconKey: 'whatsapp',
    ),
  ],
);
