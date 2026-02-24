import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../constants/api_constants.dart';
import '../../../services/dio_service.dart';
import '../../../services/logger_service.dart';
import '../models/bill_pay_response_model.dart';
import '../models/bill_response_model.dart';
import '../models/biller_detail_model.dart';
import '../models/biller_model.dart';

class BillerRepository {
  BillerRepository({Dio? dio}) : _dio = dio ?? DioService.instance.client;

  final Dio _dio;

  Future<List<Biller>> fetchBillers({required String categoryName}) async {
    try {
      final response = await _dio.get(
        ApiConstants.billersEndpoint,
        queryParameters: {'category_name': categoryName},
      );
      final payload = response.data as Map<String, dynamic>? ?? {};
      final parsed = BillerListResponse.fromJson(payload);
      return parsed.billers;
    } catch (e) {
      logger.error('Failed to fetch billers: $e', error: e);
      rethrow;
    }
  }

  Future<BillerDetail> fetchBillerDetails({required String billerId}) async {
    try {
      final response = await _dio.get(
        ApiConstants.billerParamsEndpoint,
        queryParameters: {'biller_id': billerId},
      );
      final payload = response.data as Map<String, dynamic>? ?? {};
      return BillerDetail.fromJson(payload);
    } catch (e) {
      logger.error('Failed to fetch biller details: $e', error: e);
      rethrow;
    }
  }

  Future<BillResponse> fetchBill({
    required String billerId,
    required Map<String, String> customerParams,
    required String planMdmRequirement,
  }) async {
    try {
      final data = <String, dynamic>{
        'billerid': billerId,
        'planMdmRequirement': planMdmRequirement,
      };
      for (final entry in customerParams.entries) {
        final key = _buildCustomerParamKey(entry.key);
        if (key.isNotEmpty) {
          data[key] = entry.value;
        }
      }
      final response = await _dio.post(
        ApiConstants.fetchBillEndpoint,
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          validateStatus: (status) => status != null && status < 600,
        ),
      );
      final payload = response.data as Map<String, dynamic>? ?? {};
      final status = (payload['status'] ?? '').toString().toUpperCase();
      if (status != 'SUCCESS') {
        throw BillerApiException(_extractBillFetchErrorMessage(payload));
      }
      return BillResponse.fromJson(payload);
    } catch (e) {
      logger.error('Failed to fetch bill: $e', error: e);
      rethrow;
    }
  }

  Future<BillPayResponse> payBill({
    required String billerId,
    required Map<String, String> customerParams,
    required String amount,
    required String refId,
    required List<String> paymentModes,
  }) async {
    try {
      final data = <String, dynamic>{
        'billerid': billerId,
        'amount': amount,
        'ref_id': refId,
        'arr_bill_payment_modes': paymentModes.join(','),
      };
      for (final entry in customerParams.entries) {
        final key = _buildCustomerParamKey(entry.key);
        if (key.isNotEmpty) {
          data[key] = entry.value;
        }
      }

      logger.info('Bill payment request payload: $data');

      log(data.toString(), name: 'Bill Payment Request Data');

      final response = await _dio.post(
        ApiConstants.payBillEndpoint,
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          validateStatus: (status) => status != null && status < 600,
        ),
      );
      final payload = response.data as Map<String, dynamic>? ?? {};
      log(
        'status=${response.statusCode} body=$payload',
        name: 'Bill Payment Response Data',
      );
      return BillPayResponse.fromJson(payload);
    } catch (e, stackTrace) {
      logger.error('Failed to pay bill: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  String _buildCustomerParamKey(String paramName) {
    final trimmed = paramName.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.toLowerCase().endsWith('parameter')) {
      return trimmed;
    }
    return '${trimmed}_parameter';
  }

  String _extractBillFetchErrorMessage(Map<String, dynamic> payload) {
    final body = payload['payload'] as Map<String, dynamic>? ?? {};
    final message = body['message']?.toString().trim();
    if (message != null && message.isNotEmpty) return message;
    final errors = body['errors'];
    if (errors is List && errors.isNotEmpty) {
      final first = errors.first;
      if (first is Map) {
        final reason = first['reason']?.toString().trim();
        if (reason != null && reason.isNotEmpty) return reason;
        final fallback = first['message']?.toString().trim();
        if (fallback != null && fallback.isNotEmpty) return fallback;
      }
    }
    final code = payload['code']?.toString();
    if (code != null && code.isNotEmpty) {
      return 'Failed to fetch bill (code $code).';
    }
    return 'Failed to fetch bill. Please try again.';
  }
}

class BillerApiException implements Exception {
  BillerApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
