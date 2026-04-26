import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/app_constants.dart';
import 'api_client.dart';

part 'auth_service.g.dart';

/// Supabase 客户端是否可用；前端不再依赖它做鉴权，但保留初始化能力以便未来直连读数据。
bool get supabaseEnabled =>
    AppConstants.supabaseUrl.isNotEmpty &&
    AppConstants.supabaseAnonKey.isNotEmpty;

/// 初始化 Supabase；未配置则跳过（不再阻塞登录流程）。
Future<void> initSupabase() async {
  if (!supabaseEnabled) return;
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );
}

enum AuthStatus { unknown, unauthenticated, authenticated, guest }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? phone;
  final String? email;
  final String? accessToken;
  final int? expiresAt; // unix seconds

  const AuthState({
    required this.status,
    this.userId,
    this.phone,
    this.email,
    this.accessToken,
    this.expiresAt,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? phone,
    String? email,
    String? accessToken,
    int? expiresAt,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      accessToken: accessToken ?? this.accessToken,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}

class _StoredAuth {
  final String userId;
  final String? phone;
  final String? email;
  final String accessToken;
  final int expiresAt;

  const _StoredAuth({
    required this.userId,
    required this.accessToken,
    required this.expiresAt,
    this.phone,
    this.email,
  });
}

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  static const _internalAppleEmailDomain = '@apple.health-clock.local';
  static const _tokenKey = 'auth.accessToken';
  static const _expiresAtKey = 'auth.expiresAt';
  static const _userIdKey = 'auth.userId';
  static const _phoneKey = 'auth.phone';
  static const _emailKey = 'auth.email';
  static const _refreshWindowSeconds = 60 * 60 * 24;

  @override
  AuthState build() {
    _restoreSession();
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  Dio get _dio => ref.read(dioProvider);

  /// 通过后端发送阿里云短信验证码。
  ///
  /// [phone] 可传 `13800138000` 或 `+8613800138000`，后端会自动归一化。
  Future<void> sendPhoneOtp(String phone) async {
    try {
      await _dio.post<dynamic>(
        '/auth/send-sms-code',
        data: {'phone': phone},
      );
    } on DioException catch (e) {
      throw Exception(_extractError(e, '验证码发送失败'));
    }
  }

  /// 校验验证码；成功后写入 access_token 并切到 authenticated 状态。
  Future<void> verifyPhoneOtp(String phone, String code) async {
    try {
      final resp = await _dio.post<dynamic>(
        '/auth/verify-sms-code',
        data: {'phone': phone, 'code': code},
      );
      final data = (resp.data is Map<String, dynamic>)
          ? (resp.data as Map<String, dynamic>)['data'] as Map<String, dynamic>?
          : null;
      if (data == null) {
        throw Exception('服务端返回数据格式异常');
      }
      final token = data['access_token'] as String?;
      final expiresAt = data['expires_at'] as int?;
      final user = data['user'] as Map<String, dynamic>? ?? const {};
      if (token == null || token.isEmpty) {
        throw Exception('未获取到 access_token');
      }

      await _setAuthenticated(
        AuthState(
          status: AuthStatus.authenticated,
          userId: user['id'] as String?,
          phone: user['phone'] as String?,
          email: _publicEmail(user['email'] as String?),
          accessToken: token,
          expiresAt: expiresAt,
        ),
      );
    } on DioException catch (e) {
      throw Exception(_extractError(e, '验证码校验失败'));
    }
  }

  /// 使用 Apple 登录；后端验证 identity token 后签发应用自己的 access_token。
  Future<void> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final identityToken = credential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        throw Exception('Apple 未返回 identity token');
      }

      final fullName = [
        credential.givenName,
        credential.familyName,
      ].where((part) => part != null && part.trim().isNotEmpty).join('');

      final resp = await _dio.post<dynamic>(
        '/auth/apple',
        data: {
          'identity_token': identityToken,
          'authorization_code': credential.authorizationCode,
          if (fullName.isNotEmpty) 'full_name': fullName,
        },
      );
      final data = (resp.data is Map<String, dynamic>)
          ? (resp.data as Map<String, dynamic>)['data'] as Map<String, dynamic>?
          : null;
      if (data == null) {
        throw Exception('服务端返回数据格式异常');
      }
      final token = data['access_token'] as String?;
      final expiresAt = data['expires_at'] as int?;
      final user = data['user'] as Map<String, dynamic>? ?? const {};
      if (token == null || token.isEmpty) {
        throw Exception('未获取到 access_token');
      }

      await _setAuthenticated(
        AuthState(
          status: AuthStatus.authenticated,
          userId: user['id'] as String?,
          phone: user['phone'] as String?,
          email: _publicEmail(user['email'] as String?),
          accessToken: token,
          expiresAt: expiresAt,
        ),
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        throw Exception('已取消 Apple 登录');
      }
      throw Exception('Apple 登录失败：${e.message}');
    } on DioException catch (e) {
      throw Exception(_extractError(e, 'Apple 登录失败'));
    }
  }

  /// 使用当前仍有效的 token 续签，避免 7 天过期后突然掉线。
  Future<void> refreshSession() async {
    final token = state.accessToken;
    if (token == null || token.isEmpty) return;

    ref.read(authTokenProvider.notifier).state = token;
    try {
      final resp = await _dio.post<dynamic>('/auth/refresh');
      final data = (resp.data is Map<String, dynamic>)
          ? (resp.data as Map<String, dynamic>)['data'] as Map<String, dynamic>?
          : null;
      if (data == null) {
        throw Exception('服务端返回数据格式异常');
      }
      final newToken = data['access_token'] as String?;
      final expiresAt = data['expires_at'] as int?;
      final user = data['user'] as Map<String, dynamic>? ?? const {};
      if (newToken == null || newToken.isEmpty) {
        throw Exception('未获取到 access_token');
      }

      await _setAuthenticated(
        AuthState(
          status: AuthStatus.authenticated,
          userId: user['id'] as String? ?? state.userId,
          phone: user['phone'] as String? ?? state.phone,
          email: _publicEmail(user['email'] as String?) ?? state.email,
          accessToken: newToken,
          expiresAt: expiresAt,
        ),
      );
    } catch (_) {
      await signOut();
    }
  }

  Future<void> _restoreSession() async {
    final stored = await _readStoredAuth();
    if (stored == null) return;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (stored.expiresAt <= now) {
      await _clearStoredAuth();
      return;
    }

    final restored = AuthState(
      status: AuthStatus.authenticated,
      userId: stored.userId,
      phone: stored.phone,
      email: stored.email,
      accessToken: stored.accessToken,
      expiresAt: stored.expiresAt,
    );
    ref.read(authTokenProvider.notifier).state = stored.accessToken;
    state = restored;

    if (stored.expiresAt - now <= _refreshWindowSeconds) {
      await refreshSession();
    }
  }

  /// 进入测试模式（跳过登录）；仅本地状态可用，所有后端调用会因缺少 token 失败。
  void enterGuestMode() {
    state = const AuthState(status: AuthStatus.guest);
  }

  Future<void> signOut() async {
    state = const AuthState(status: AuthStatus.unauthenticated);
    ref.read(authTokenProvider.notifier).state = null;
    await _clearStoredAuth();
  }

  Future<void> _setAuthenticated(AuthState next) async {
    final token = next.accessToken;
    final expiresAt = next.expiresAt;
    final userId = next.userId;
    if (token == null || token.isEmpty || expiresAt == null || userId == null) {
      throw Exception('登录状态数据不完整');
    }

    ref.read(authTokenProvider.notifier).state = token;
    state = next;
    await _saveAuth(next);
  }

  Future<_StoredAuth?> _readStoredAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final expiresAt = prefs.getInt(_expiresAtKey);
    final userId = prefs.getString(_userIdKey);
    if (token == null || token.isEmpty || expiresAt == null || userId == null) {
      return null;
    }

    return _StoredAuth(
      userId: userId,
      accessToken: token,
      expiresAt: expiresAt,
      phone: prefs.getString(_phoneKey),
      email: _publicEmail(prefs.getString(_emailKey)),
    );
  }

  Future<void> _saveAuth(AuthState auth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, auth.accessToken!);
    await prefs.setInt(_expiresAtKey, auth.expiresAt!);
    await prefs.setString(_userIdKey, auth.userId!);

    final phone = auth.phone;
    if (phone == null || phone.isEmpty) {
      await prefs.remove(_phoneKey);
    } else {
      await prefs.setString(_phoneKey, phone);
    }

    final email = auth.email;
    if (email == null || email.isEmpty) {
      await prefs.remove(_emailKey);
    } else {
      await prefs.setString(_emailKey, email);
    }
  }

  Future<void> _clearStoredAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_expiresAtKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_emailKey);
  }

  String _extractError(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['detail'] is String) {
      return data['detail'] as String;
    }
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return e.message ?? fallback;
  }

  String? _publicEmail(String? email) {
    if (email == null || email.isEmpty) return null;
    if (email.endsWith(_internalAppleEmailDomain)) return null;
    return email;
  }
}
