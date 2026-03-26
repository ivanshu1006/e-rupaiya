import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../constants/api_constants.dart';
import '../../../services/dio_service.dart';
import '../../../services/logger_service.dart';
import '../models/credit_card_transaction.dart';

class CreditCardTransactionsRepository {
  CreditCardTransactionsRepository({Dio? dio})
      : _dio = dio ?? DioService.instance.client;

  final Dio _dio;

  Future<CreditCardTransactionsResponse> fetchTransactions({
    required String maskedIdentifier,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.creditCardTransactionsEndpoint,
        queryParameters: {
          'masked_identifier': maskedIdentifier,
          'page': page,
          'limit': limit,
        },
      );
      final payload = response.data;
      Map<String, dynamic> json;
      if (payload is String) {
        json = jsonDecode(payload) as Map<String, dynamic>;
      } else if (payload is Map<String, dynamic>) {
        json = payload;
      } else {
        json = Map<String, dynamic>.from(payload as Map);
      }
      return CreditCardTransactionsResponse.fromJson(json);
    } catch (e) {
      logger.error('Failed to fetch credit card transactions: $e', error: e);
      rethrow;
    }
  }
}

class CreditCardTransactionsResponse {
  CreditCardTransactionsResponse({
    required this.success,
    required this.message,
    required this.items,
    required this.currentPage,
    required this.totalPages,
    required this.totalRecords,
  });

  factory CreditCardTransactionsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final items = data is List
        ? data
            .whereType<Map<String, dynamic>>()
            .map(CreditCardTransaction.fromJson)
            .toList()
        : <CreditCardTransaction>[];
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};
    return CreditCardTransactionsResponse(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      items: items,
      currentPage: pagination['current_page'] as int? ?? 1,
      totalPages: pagination['total_pages'] as int? ?? 1,
      totalRecords: pagination['total_records'] as int? ?? items.length,
    );
  }

  final bool success;
  final String message;
  final List<CreditCardTransaction> items;
  final int currentPage;
  final int totalPages;
  final int totalRecords;
}
