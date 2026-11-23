import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_whitelabel/clients/eden_fm_config.dart';
import 'package:radio_whitelabel/services/live_content_service.dart';
import 'package:radio_whitelabel/services/metadata_adapter.dart';

void main() {
  test('StationConfig.copyWithRemoteJson overrides fields cleanly', () {
    final updated = edenFmConfig.copyWithRemoteJson({
      'stationName': 'Eden FM Live',
      'primaryColorHex': '#FF5500',
      'enablePodcasts': false,
    });

    expect(updated.stationName, 'Eden FM Live');
    expect(updated.primaryColor, const Color(0xFFFF5500));
    expect(updated.enablePodcasts, false);
    expect(updated.clientId, edenFmConfig.clientId);
  });

  test('MetadataAdapter parses ICY Artist - Title strings', () async {
    final adapter = MetadataAdapter(edenFmConfig);
    final futureInfo = adapter.stream.first;

    adapter.updateFromIcyTitle('Daft Punk - Midnight City');
    final info = await futureInfo;

    expect(info.artist, 'Daft Punk');
    expect(info.title, 'Midnight City');
    adapter.dispose();
  });

  test('LiveContentService parses RSS news and podcast XML feeds', () {
    const rssXml = '''
      <rss><channel>
        <item>
          <title>Local Concert Tonight</title>
          <description>Live music at the park.</description>
          <enclosure url="https://example.com/audio.mp3" type="audio/mpeg" />
          <itunes:duration>12:30</itunes:duration>
        </item>
      </channel></rss>
    ''';

    final news = LiveContentService.parseNewsBody(rssXml);
    final podcasts = LiveContentService.parsePodcastBody(rssXml);

    expect(news.length, 1);
    expect(news.first.title, 'Local Concert Tonight');
    expect(podcasts.length, 1);
    expect(podcasts.first.audioUrl, 'https://example.com/audio.mp3');
    expect(podcasts.first.duration, const Duration(minutes: 12, seconds: 30));
  });
}
