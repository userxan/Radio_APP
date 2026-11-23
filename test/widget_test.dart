import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radio_whitelabel/clients/eden_fm_config.dart';
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
}
