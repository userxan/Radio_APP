import 'package:flutter/material.dart';
import '../config/station_config.dart';

/// YOUR PRACTICE CLIENT CONFIG
/// Edit the values below and run `lib/main_my_station.dart` to see your changes!
const myStationConfig = StationConfig(
  // 1. Unique ID (lowercase, no spaces)
  clientId: 'my_station',

  // 2. Station Name, Tagline & Dial Badge
  stationName: 'My Radio Station',
  tagline: 'Edit me in my_station_config.dart!',
  frequencyBadge: '101.5 FM',

  // 3. Live Audio Stream URL (Icecast, Shoutcast, or HLS .m3u8)
  streamUrl: 'https://stream.zeno.fm/0r0xa792kwzuv',
  sourceType: StreamSourceType.icy,

  // 3b. Optional Website Feeds (leave '' if the station has no website feeds)
  newsFeedUrl: '',
  podcastFeedUrl: '',
  scheduleFeedUrl: '',

  // 4. Brand Colors (change the hex digits after 0xFF)
  primaryColor: Color(0xFF2563EB), // Royal Blue
  accentColor: Color(0xFF10B981), // Emerald Green

  // 5. Logo Path
  logoAssetPath: 'assets/clients/eden_fm/logo.png',

  // 6. Turn Tabs On / Off (true = show, false = hide)
  enableNews: true,
  enableSchedule: true,
  enablePodcasts: true,

  // 7. Studio & Contact Details (shown in the Info tab)
  aboutText: 'Your station bio goes here.',
  studioPhone: '+27 11 555 1015',
  studioWhatsapp: '+27 82 555 1015',
  studioSms: '31015',
  studioEmail: 'studio@mystation.example.com',
  newsDeskEmail: 'news@mystation.example.com',
  studioAddress: '123 Radio Lane, Johannesburg',

  // 8. Highlighted Competition / Promo Card (set to null to hide)
  promo: StationPromo(
    badgeText: 'COMPETITION',
    title: 'Win Concert Tickets!',
    subtitle: 'Message us on WhatsApp to enter.',
    actionUrl: 'https://wa.me/27825551015',
  ),

  // 9. News Stories (shown in the News tab)
  news: [
    NewsArticle(
      id: 'my-news-1',
      title: 'Welcome to Your New Radio App!',
      category: 'Local',
      publishedAt: 'Just now',
      summary: 'Edit this headline inside lib/clients/my_station_config.dart.',
      body:
          'You can add as many news articles, traffic alerts, or music updates as you like here, or load them live from a remote JSON file.',
    ),
  ],

  // 10. Show Schedule (shown in the Schedule tab)
  schedule: [
    RadioShow(
      id: 'my-show-1',
      title: 'Morning Drive',
      host: 'Your DJ Name',
      dayOfWeek: 'Weekdays',
      startTime: '06:00',
      endTime: '09:00',
      isLiveNow: true,
    ),
  ],

  // 11. Podcasts & Replays (shown in the Podcasts tab)
  podcasts: [
    PodcastEpisode(
      id: 'my-ep-1',
      title: 'Episode 1: Pilot Show Replay',
      showName: 'Morning Drive',
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      publishedDate: 'Today',
      duration: Duration(minutes: 30),
      description: 'Sample on-demand replay.',
    ),
  ],

  // 12. Social Links (shown in the Info tab)
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
  ],
);
