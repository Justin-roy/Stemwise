import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'network/api_client.dart';
import 'storage/secure_storage.dart';

/// Overridden at app startup with the resolved instance.
final sharedPrefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPrefsProvider must be overridden'),
);

final secureStorageProvider = Provider<SecureStorage>(
  (ref) => SecureStorage(const FlutterSecureStorage()),
);

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(secureStorageProvider));
});
