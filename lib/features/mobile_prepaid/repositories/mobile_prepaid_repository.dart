import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../constants/api_constants.dart';
import '../../../services/dio_service.dart';
import '../../../services/logger_service.dart';
import '../models/operator_info.dart';
import '../models/plan_item.dart';

class MobilePrepaidRepository {
  MobilePrepaidRepository({Dio? dio}) : _dio = dio ?? DioService.instance.client;

  final Dio _dio;

  Future<OperatorInfo> checkOperator({required String mobile}) async {
    try {
      final response = await _dio.post(
        ApiConstants.prepaidCheckOperatorEndpoint,
        data: {'mobile': mobile},
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      final payload = _normalizePayload(response.data);
      final data = payload['data'] as Map<String, dynamic>? ?? {};
      return OperatorInfo.fromJson(data);
    } catch (e, stackTrace) {
      logger.error(
        'Failed to check operator',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<Map<String, List<PlanItem>>> fetchPlans({
    required String mobile,
    required String operatorName,
    required String circleCode,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.prepaidFetchPlansEndpoint,
        data: {
          'mobile': mobile,
          'operator': operatorName,
          'circlecode': circleCode,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      final payload = _normalizePayload(response.data);
      final data = payload['data'] as Map<String, dynamic>? ?? {};
      final result = <String, List<PlanItem>>{};
      data.forEach((key, value) {
        if (value is List) {
          result[key] = value
              .map((item) =>
                  PlanItem.fromJson(item as Map<String, dynamic>? ?? {}))
              .toList();
        }
      });
      return result;
    } catch (e, stackTrace) {
      logger.error(
        'Failed to fetch plans',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<String> recharge({
    required String mobile,
    required int amount,
    required String operatorName,
    String? referenceId,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.prepaidRechargeEndpoint,
        data: {
          'mobile': mobile,
          'amount': amount.toString(),
          'operator': operatorName,
          if (referenceId != null && referenceId.isNotEmpty)
            'reference_id': referenceId,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          validateStatus: (status) => status != null && status < 600,
        ),
      );
      final payload = response.data as Map<String, dynamic>? ?? {};
      final statusValue = payload['status'] ?? payload['code'] ?? payload['error'];
      final statusText = statusValue?.toString() ?? '';
      final message = _extractRechargeMessage(payload);
      final isSuccess = _isRechargeSuccess(statusValue, statusText);

      if (!isSuccess) {
        throw Exception(
          message.isNotEmpty ? message : 'Recharge failed. Please try again.',
        );
      }

      if (message.isNotEmpty) return message;
      return 'Recharge completed.';
    } catch (e, stackTrace) {
      logger.error(
        'Failed to recharge',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  bool _isRechargeSuccess(Object? statusValue, String statusText) {
    final normalized = statusText.toLowerCase();
    if (normalized == 'success' || normalized == 'ok' || normalized == 'true') {
      return true;
    }
    if (statusValue is int) {
      return statusValue >= 200 && statusValue < 300;
    }
    final parsed = int.tryParse(statusText);
    if (parsed != null) {
      return parsed >= 200 && parsed < 300;
    }
    return false;
  }

  String _extractRechargeMessage(Map<String, dynamic> payload) {
    final messages = payload['messages'];
    if (messages is Map) {
      final err = messages['error']?.toString().trim() ?? '';
      if (err.isNotEmpty) return err;
    }

    final direct =
        (payload['message'] ?? payload['msg'] ?? payload['error'] ?? '')
            .toString()
            .trim();
    if (direct.isNotEmpty) return direct;
    return '';
  }

  Map<String, dynamic> _normalizePayload(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) {
      return data.map(
        (key, value) => MapEntry(key.toString(), value),
      );
    }
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) {
          return decoded.map(
            (key, value) => MapEntry(key.toString(), value),
          );
        }
      } catch (_) {
        return {};
      }
    }
    return {};
  }
}
