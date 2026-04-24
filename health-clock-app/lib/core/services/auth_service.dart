import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  AuthState build() {
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

      ref.read(authTokenProvider.notifier).state = token;
      state = AuthState(
        status: AuthStatus.authenticated,
        userId: user['id'] as String?,
        phone: user['phone'] as String?,
        email: user['email'] as String?,
        accessToken: token,
        expiresAt: expiresAt,
      );
    } on DioException catch (e) {
      throw Exception(_extractError(e, '验证码校验失败'));
    }
  }

  /// 进入测试模式（跳过登录）；仅本地状态可用，所有后端调用会因缺少 token 失败。
  void enterGuestMode() {
    state = const AuthState(status: AuthStatus.guest);
  }

  Future<void> signOut() async {
    state = const AuthState(status: AuthStatus.unauthenticated);
    ref.read(authTokenProvider.notifier).state = null;
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
}
