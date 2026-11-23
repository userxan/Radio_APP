# White-Label Flutter Radio App

A flagship **Dark Glassmorphic** radio app built with Flutter & Dart for rapid multi-client customization.

## Architecture Overview
- **Hybrid Config (`lib/config/station_config.dart` + `lib/services/remote_config_service.dart`)**:
  - **Local Flavor** compiles each client's branding, colors, app icon, and fallback defaults.
  - **Remote JSON** (`remoteConfigUrl`) optionally overrides `streamUrl`, `metadataApiUrl`, `schedule`, `podcasts`, and feature toggles live without an App Store / Play Store resubmission.
- **Flexible Audio & Metadata (`lib/services/radio_audio_handler.dart` & `lib/services/metadata_adapter.dart`)**:
  - Uses `just_audio` + `audio_service` for background playback and OS lock-screen controls.
  - Supports **Icecast / Shoutcast ICY**, **HLS (`.m3u8`)**, **AzuraCast**, and **Radio.co** metadata APIs.
- **Modular UI (`lib/screens/`)**:
  - **Live Player**: Dynamic blurred artwork backdrop, live/podcast mode switching, sleep timer, and station info sheet.
  - **Schedule**: Day-filterable DJ lineup with live `ON AIR` badge (auto-hidden if `enableSchedule: false`).
  - **Podcasts**: On-demand replays that play seamlessly in the same audio engine (auto-hidden if `enablePodcasts: false`).

## Getting Started (After Installing Flutter SDK)

1. **Generate platform folders** (Android / iOS / Windows) inside `Radio_APP`:
   ```bash
   flutter create .
   flutter pub get
   ```
2. **Run a specific client**:
   ```bash
   # Client 1: Eden FM
   flutter run -t lib/main_eden_fm.dart

   # Client 2: Neon Pulse (Podcasts disabled, Magenta/Gold theme)
   flutter run -t lib/main_neon_pulse.dart
   ```
3. **Add a New Client in 2 Minutes**:
   - Duplicate `lib/clients/eden_fm_config.dart` -> `lib/clients/new_client_config.dart`.
   - Create `lib/main_new_client.dart` calling `runWhiteLabelRadioApp(newClientConfig)`.
   - Place their logo in `assets/clients/new_client/logo.png`.
   - *(For App Store / Play Store builds)* Configure Android `productFlavors` and iOS schemes (or use `flutter_flavorizr`) so each client gets its own Bundle ID and App Icon.

> **Android / iOS Background Audio Note**: When you run `flutter create .`, remember to add `WAKE_LOCK` and `FOREGROUND_SERVICE` permissions in `android/app/src/main/AndroidManifest.xml` (per `audio_service` setup) and enable **Audio, AirPlay, and Picture in Picture** under iOS **Background Modes** in Xcode.
