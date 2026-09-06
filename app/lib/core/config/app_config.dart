import 'package:flutter/foundation.dart';

/// App configuration (spec §84). API base URL can be overridden at build time:
///   flutter run --dart-define=API_BASE_URL=https://api.stemwise.app/api/v1
class AppConfig {
  AppConfig._();

  static const String _override =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String get apiBaseUrl {
    if (_override.isNotEmpty) return _override;
    // Android emulator reaches the host machine via 10.0.2.2.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api/v1';
    }
    return 'http://localhost:3000/api/v1';
  }
}
