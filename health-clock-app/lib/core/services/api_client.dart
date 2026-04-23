import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/app_constants.dart';

part 'api_client.g.dart';

@riverpod
Dio dio(DioRef ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  // 添加拦截器
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 添加认证 token
        final token = ref.read(authTokenProvider);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // 统一错误处理
        if (error.response?.statusCode == 401) {
          // Token 过期，清除登录状态
          ref.read(authTokenProvider.notifier).state = null;
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
}

// 认证 token provider
final authTokenProvider = StateProvider<String?>((ref) => null);
