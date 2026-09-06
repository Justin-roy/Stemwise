import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/providers.dart';
import '../../core/storage/secure_storage.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

@immutable
class AuthUser {
  final String id;
  final String email;
  final String role;
  const AuthUser({required this.id, required this.email, required this.role});
  factory AuthUser.fromJson(Map<String, dynamic> j) =>
      AuthUser(id: j['id'] as String, email: j['email'] as String, role: j['role'] as String);
}

@immutable
class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  const AuthState(this.status, {this.user});
  bool get isAuthenticated => status == AuthStatus.authenticated;
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._api, this._storage)
      : super(const AuthState(AuthStatus.unknown)) {
    _api.onAuthFailure = () => state = const AuthState(AuthStatus.unauthenticated);
    _bootstrap();
  }

  final ApiClient _api;
  final SecureStorage _storage;

  Future<void> _bootstrap() async {
    final token = await _storage.accessToken;
    if (token == null) {
      state = const AuthState(AuthStatus.unauthenticated);
      return;
    }
    try {
      final data = await _api.get('/profile');
      // Profile exists → session valid. We don't have user email here, keep minimal.
      state = AuthState(AuthStatus.authenticated,
          user: AuthUser(
            id: (data is Map ? (data['userId']?.toString() ?? '') : ''),
            email: '',
            role: 'user',
          ));
    } catch (_) {
      await _storage.clear();
      state = const AuthState(AuthStatus.unauthenticated);
    }
  }

  Future<void> _completeAuth(dynamic data) async {
    final map = data as Map<String, dynamic>;
    await _storage.saveTokens(
        map['accessToken'] as String, map['refreshToken'] as String);
    state = AuthState(AuthStatus.authenticated,
        user: AuthUser.fromJson(map['user'] as Map<String, dynamic>));
  }

  Future<void> login(String email, String password) async {
    final data = await _api.post('/auth/login',
        body: {'email': email, 'password': password});
    await _completeAuth(data);
  }

  Future<void> register(String email, String password, String name) async {
    final data = await _api.post('/auth/register',
        body: {'email': email, 'password': password, 'name': name});
    await _completeAuth(data);
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {}
    await _storage.clear();
    state = const AuthState(AuthStatus.unauthenticated);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(apiClientProvider), ref.watch(secureStorageProvider));
});
