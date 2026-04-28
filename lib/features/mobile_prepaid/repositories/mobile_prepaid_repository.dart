import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../constants/api_constants.dart';
import '../../../services/dio_service.dart';
import '../../../services/logger_service.dart';
import '../models/operator_info.dart';
import '../models/operator_option.dart';
import '../models/latest_transaction.dart';
import '../models/plan_item.dart';
import '../models/recharge_result.dart';
import '../models/region_option.dart';

class MobilePrepaidRepository {
  MobilePrepaidRepository({Dio? dio})
      : _dio = dio ?? DioService.instance.client;

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

  Future<List<OperatorOption>> fetchOperators() async {
    try {
      final response = await _dio.get(
        ApiConstants.prepaidFetchOperatorsEndpoint,
      );
      final payload = _normalizePayload(response.data);
      final data = payload['data'] as Map<String, dynamic>? ?? {};
      final operators = data['operators'];
      if (operators is List) {
        return operators
            .map((item) =>
                OperatorOption.fromJson(item as Map<String, dynamic>? ?? {}))
            .toList();
      }
      return [];
    } catch (e, stackTrace) {
      logger.error(
        'Failed to fetch operators',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<List<RegionOption>> fetchRegions() async {
    try {
      final response = await _dio.get(
        ApiConstants.prepaidFetchRegionsEndpoint,
      );
      final payload = _normalizePayload(response.data);
      final data = payload['data'] as Map<String, dynamic>? ?? {};
      final regions = data['regions'];
      if (regions is List) {
        return regions
            .map((item) =>
                RegionOption.fromJson(item as Map<String, dynamic>? ?? {}))
            .toList();
      }
      return [];
    } catch (e, stackTrace) {
      logger.error(
        'Failed to fetch regions',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<RechargeResult> recharge({
    required String mobile,
    required int amount,
    required String operatorName,
    required String desc,
    String? referenceId,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.prepaidRechargeEndpoint,
        data: {
          'mobile': mobile,
          'amount': amount.toString(),
          'operator': operatorName,
          'desc': desc,
          // if (referenceId != null && referenceId.isNotEmpty)
          'reference_id': referenceId,
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          validateStatus: (status) => status != null && status < 600,
        ),
      );
      final payload = response.data as Map<String, dynamic>? ?? {};
      final statusValue =
          payload['status'] ?? payload['code'] ?? payload['error'];
      final statusText = statusValue?.toString() ?? '';
      final message = _extractRechargeMessage(payload);
      final isSuccess = _isRechargeSuccess(statusValue, statusText);
      final transactionId = (payload['transaction_id'] ??
              payload['transactionId'] ??
              payload['transaction_id'.toUpperCase()] ??
              '')
          .toString()
          .trim();
      final dateTime =
          (payload['dateDate'] ?? payload['date_time'] ?? payload['date'] ?? '')
              .toString()
              .trim();

      return RechargeResult(
        status: statusText,
        message: message.isNotEmpty
            ? message
            : (isSuccess ? 'Recharge completed.' : 'Recharge failed.'),
        transactionId: transactionId,
        dateTime: dateTime,
        isSuccess: isSuccess,
      );
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
    if (normalized == 'failed' || normalized == 'failure') return false;
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

  Future<List<LatestTransaction>> fetchLatestTransactions({
    required String service,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.latestTransactionsEndpoint(service: service),
      );
      final payload = _normalizePayload(response.data);
      final data = payload['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => LatestTransaction.fromJson(
                  e.map((key, value) => MapEntry(key.toString(), value)),
                ))
            .toList();
      }
      if (data is List<dynamic>) {
        return data
            .map((e) =>
                LatestTransaction.fromJson(e as Map<String, dynamic>? ?? {}))
            .toList();
      }
      return [];
    } catch (e, stackTrace) {
      logger.error(
        'Failed to fetch latest transactions',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
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
