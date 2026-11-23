import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/station_config.dart';

/// Fetches and caches remote station configuration JSON,
/// falling back cleanly to the compiled local [StationConfig] if offline.
class RemoteConfigService {
  static const _cachePrefix = 'remote_station_config_';

  Future<StationConfig> loadConfig(StationConfig localFallback) async {
    final url = localFallback.remoteConfigUrl;
    if (url == null || url.isEmpty) {
      return localFallback;
    }

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = '$_cachePrefix${localFallback.clientId}';

    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        await prefs.setString(cacheKey, response.body);
        return localFallback.copyWithRemoteJson(decoded);
      }
    } catch (_) {
      // Network error or timeout: fall through to cached JSON.
    }

    final cachedBody = prefs.getString(cacheKey);
    if (cachedBody != null) {
      try {
        final decoded = jsonDecode(cachedBody) as Map<String, dynamic>;
        return localFallback.copyWithRemoteJson(decoded);
      } catch (_) {
        // Corrupt cache: fall through to local fallback.
      }
    }

    return localFallback;
  }
}
