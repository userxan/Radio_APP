import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/station_config.dart';
import 'screens/home_shell.dart';
import 'services/radio_audio_handler.dart';
import 'services/remote_config_service.dart';
import 'theme/glass_theme.dart';

/// Shared entry point used by every client flavor (`main_<client>.dart`).
Future<void> runWhiteLabelRadioApp(StationConfig localConfig) async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: GlassTheme.obsidian,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize OS background audio & lock-screen controls
  final audioHandler = await AudioService.init(
    builder: () => RadioAudioHandler(localConfig),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.whitelabel.${localConfig.clientId}.audio',
      androidNotificationChannelName: '${localConfig.stationName} Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  runApp(WhiteLabelRadioApp(
    initialConfig: localConfig,
    audioHandler: audioHandler,
  ));
}

class WhiteLabelRadioApp extends StatefulWidget {
  final StationConfig initialConfig;
  final RadioAudioHandler audioHandler;

  const WhiteLabelRadioApp({
    super.key,
    required this.initialConfig,
    required this.audioHandler,
  });

  @override
  State<WhiteLabelRadioApp> createState() => _WhiteLabelRadioAppState();
}

class _WhiteLabelRadioAppState extends State<WhiteLabelRadioApp> {
  late StationConfig _activeConfig;
  final _remoteConfigService = RemoteConfigService();

  @override
  void initState() {
    super.initState();
    _activeConfig = widget.initialConfig;
    _refreshRemoteConfig();
  }

  Future<void> _refreshRemoteConfig() async {
    final updated = await _remoteConfigService.loadConfig(widget.initialConfig);
    if (!mounted) return;
    setState(() => _activeConfig = updated);
    widget.audioHandler.updateConfig(updated);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: _activeConfig.stationName,
      theme: GlassTheme.build(_activeConfig),
      home: HomeShell(
        config: _activeConfig,
        audioHandler: widget.audioHandler,
      ),
    );
  }
}
