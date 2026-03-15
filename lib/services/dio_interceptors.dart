import 'dart:async';

import 'package:dio/dio.dart';
import 'package:e_rupaiya/constants/api_constants.dart';
import 'package:e_rupaiya/core/barrel_file.dart';
import 'package:e_rupaiya/features/auth/controllers/auth_controller.dart';
import 'package:e_rupaiya/widgets/k_dialog.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_snackbar.dart';

class DioInterceptors extends InterceptorsWrapper {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  static Completer<bool>? _refreshCompleter;

  Future<void> _clearSession() async {
    await secureStorage.delete(key: 'accessToken');
    await secureStorage.delete(key: 'refreshToken');
    await secureStorage.delete(key: 'tokenType');
    await secureStorage.delete(key: 'tokenExpiresAt');
    await secureStorage.delete(key: 'refreshTokenExpiresAt');
    await secureStorage.delete(key: 'userId');
    await secureStorage.delete(key: 'mobile');
  }

  Future<bool> _refreshAccessToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }
    _refreshCompleter = Completer<bool>();
    try {
      final refreshToken = await secureStorage.read(key: 'refreshToken');
      if (refreshToken == null || refreshToken.isEmpty) {
        _refreshCompleter!.complete(false);
        return _refreshCompleter!.future;
      }

      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      final response = await dio.post(
        ApiConstants.refreshTokenEndpoint,
        data: {'refresh_token': refreshToken},
      );
      final payload = response.data as Map<String, dynamic>?;
      final success = payload?['success'] == true;
      final data = payload?['data'] as Map<String, dynamic>? ?? {};
      final accessToken = data['access_token'] as String?;
      final tokenType = data['token_type'] as String?;
      final expiresIn = data['expires_in'] as int?;

      if (!success || accessToken == null || expiresIn == null) {
        _refreshCompleter!.complete(false);
        return _refreshCompleter!.future;
      }

      final expiresAt =
          DateTime.now().add(Duration(seconds: expiresIn)).toIso8601String();
      await secureStorage.write(key: 'accessToken', value: accessToken);
      await secureStorage.write(
        key: 'tokenType',
        value: tokenType ?? 'Bearer',
      );
      await secureStorage.write(key: 'tokenExpiresAt', value: expiresAt);
      final refreshExpiry = _resolveRefreshExpiry(data);
      if (refreshExpiry != null) {
        await secureStorage.write(
          key: 'refreshTokenExpiresAt',
          value: refreshExpiry.toIso8601String(),
        );
      }
      _refreshCompleter!.complete(true);
      return _refreshCompleter!.future;
    } catch (_) {
      _refreshCompleter?.complete(false);
      return _refreshCompleter!.future;
    } finally {
      _refreshCompleter = null;
    }
  }

  DateTime? _resolveRefreshExpiry(Map<String, dynamic> data) {
    final refreshExpiresAt = data['refresh_expires_at'];
    if (refreshExpiresAt is String && refreshExpiresAt.isNotEmpty) {
      return DateTime.tryParse(refreshExpiresAt);
    }
    final refreshExpiresIn =
        data['refresh_expires_in'] ?? data['refresh_token_expires_in'];
    if (refreshExpiresIn is int) {
      return DateTime.now().add(Duration(seconds: refreshExpiresIn));
    }
    if (refreshExpiresIn is String) {
      final parsed = int.tryParse(refreshExpiresIn);
      if (parsed != null) {
        return DateTime.now().add(Duration(seconds: parsed));
      }
    }
    return null;
  }

  Future<bool> _refreshAccessTokenWithRetry() async {
    final refreshed = await _refreshAccessToken();
    if (refreshed) return true;
    await Future.delayed(const Duration(milliseconds: 300));
    return _refreshAccessToken();
  }

  Future<bool?> _isRefreshTokenExpired() async {
    final refreshTokenExpiry = await Utils.getRefreshTokenExpiry();
    if (refreshTokenExpiry == null) {
      final storedRefresh = await secureStorage.read(key: 'refreshToken');
      if (storedRefresh == null || storedRefresh.isEmpty) return true;
      return null;
    }
    return refreshTokenExpiry.isBefore(DateTime.now());
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipAuthRefresh'] != true) {
      final expiresAt = await Utils.getAccessTokenExpiry();
      if (expiresAt != null &&
          expiresAt.isBefore(DateTime.now().add(const Duration(minutes: 1)))) {
        await _refreshAccessToken();
      }
    }
    final accessToken = await Utils.getAccessToken();
    final tokenType = await Utils.getTokenType();
    if (accessToken != null) {
      options.headers['Authorization'] =
          '${tokenType ?? 'Bearer'} $accessToken';
    }

    logger.info('Request: ${options.method} ${options.headers}');
    logger.info('Request payload: ${options.data}');
    if (options.queryParameters.isNotEmpty) {
      logger.info('Request query: ${options.queryParameters}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    // Handle response
    logger.info('Response: ${response.statusCode} ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    logger.error(
      'Error: ${err.message}',
      error: err,
      stackTrace: err.stackTrace,
    );
    if (err.response?.statusCode == 401) {
      final alreadyRetried = err.requestOptions.extra['retried'] == true;
      final isRefreshCall = err.requestOptions.extra['isRefresh'] == true;
      if (!alreadyRetried && !isRefreshCall) {
        final refreshed = await _refreshAccessTokenWithRetry();
        if (refreshed) {
          final options = err.requestOptions;
          options.extra['retried'] = true;
          final response = await DioService.instance.client.fetch(options);
          handler.resolve(response);
          return;
        }
      }
      final refreshExpired = await _isRefreshTokenExpired();
      if (refreshExpired == null || refreshExpired == true) {
        AppSnackbar.show(
          'Session Expired. Please login again.',
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
        final context = navigatorKey.currentContext;
        if (context != null) {
          try {
            await ProviderScope.containerOf(context)
                .read(authControllerProvider.notifier)
                .logout();
          } catch (_) {
            await _clearSession();
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            context.go(RouteConstants.login);
          });
        } else {
          await _clearSession();
        }
      } else {
        AppSnackbar.show(
          'Session refresh failed. Please try again.',
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    } else if (err.response?.statusCode == 403) {
      AppSnackbar.show(
        'Forbidden',
        textColor: Colors.white,
        backgroundColor: Colors.red,
      );
    } else if (err.response?.statusCode == 404) {
      AppSnackbar.show(
        'Session Expired. Please login again.',
        textColor: Colors.white,
        backgroundColor: Colors.red,
      );
      final context = navigatorKey.currentContext;
      if (context != null) {
        try {
          await ProviderScope.containerOf(context)
              .read(authControllerProvider.notifier)
              .logout();
        } catch (_) {
          await _clearSession();
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          context.go(RouteConstants.login);
        });
      } else {
        await _clearSession();
      }
    } else if (err.type == DioExceptionType.connectionTimeout) {
      AppSnackbar.show(
        'Connection timeout',
        textColor: Colors.white,
        backgroundColor: Colors.red,
      );
    } else if (err.type == DioExceptionType.badResponse) {
      final data = err.response?.data;
      final apiMessage =
          (data is Map ? data['message'] as String? : null) ?? 'Bad Response';
      AppSnackbar.show(
        apiMessage,
        textColor: Colors.white,
        backgroundColor: Colors.red,
      );
    } else if (err.type == DioExceptionType.cancel) {
      AppSnackbar.show(
        'Request Cancelled',
        textColor: Colors.white,
        backgroundColor: Colors.red,
      );
    } else {
      if (err.error.toString().contains('SocketException')) {
        AppSnackbar.show(
          'Please check your internet connection.',
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
      } else {
        AppSnackbar.show(
          'Unknown Error Occurred. Error: ${err.error.toString()}',
          textColor: Colors.white,
          backgroundColor: Colors.red,
        );
      }
    }
    super.onError(err, handler);
  }
}
