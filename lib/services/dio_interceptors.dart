import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../constants/routes_constant.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../utils/utils.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/k_dialog.dart';
import 'logger_service.dart';

class DioInterceptors extends InterceptorsWrapper {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  Future<void> _clearSession() async {
    await secureStorage.delete(key: 'accessToken');
    await secureStorage.delete(key: 'refreshToken');
    await secureStorage.delete(key: 'tokenType');
    await secureStorage.delete(key: 'tokenExpiresAt');
    await secureStorage.delete(key: 'userId');
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await Utils.getAccessToken();
    final tokenType = await Utils.getTokenType();
    if (accessToken != null) {
      options.headers['Authorization'] =
          '${tokenType ?? 'Bearer'} $accessToken';
    }

    logger.info('Request: ${options.method} ${options.headers}');
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
      AppSnackbar.show(
        'Incorrect username/password',
        textColor: Colors.white,
        backgroundColor: Colors.red,
      );
    } else if (err.response?.statusCode == 403) {
      try {
        final response = err.response?.data;
        if (response['session_expired'] == 1) {
          AppSnackbar.show(
            'Session Expired. Please login again.',
            textColor: Colors.white,
            backgroundColor: Colors.red,
          );
          await _clearSession();
        } else {
          AppSnackbar.show(
            'Forbidden',
            textColor: Colors.white,
            backgroundColor: Colors.red,
          );
        }
      } catch (e) {
        throw Exception('Error in Dio Error handler $e');
      }
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
      AppSnackbar.show(
        'Bad Response',
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
