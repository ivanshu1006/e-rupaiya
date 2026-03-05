import 'package:dio/dio.dart';

import '../../../constants/api_constants.dart';
import '../../../helpers/date_helpers.dart';
import '../../../services/dio_service.dart';
import '../../../services/logger_service.dart';
import '../models/transaction_history_entry.dart';

class TransactionHistoryRepository {
  TransactionHistoryRepository({Dio? dio})
      : _dio = dio ?? DioService.instance.client;

  final Dio _dio;

  Future<List<TransactionHistoryEntry>> fetchHistory({
    int? days,
    int? page,
    int? limit,
    DateTime? fromDate,
    DateTime? toDate,
    int? lastYears,
  }) async {
    try {
      final query = <String, dynamic>{};
      if (fromDate != null && toDate != null) {
        query['from_date'] = DateHelpers.formatYmd(fromDate);
        query['to_date'] = DateHelpers.formatYmd(toDate);
      } else if (lastYears != null) {
        query['last_years'] = lastYears;
      } else if (days != null) {
        query['days'] = days;
      }
      if (page != null) query['page'] = page;
      if (limit != null) query['limit'] = limit;

      final response = await _dio.get(
        ApiConstants.prepaidTransactionHistoryEndpoint,
        queryParameters: query,
      );
      final payload = response.data as Map<String, dynamic>? ?? {};
      final data = payload['data'];
      if (data is List) {
        return data
            .map((item) => TransactionHistoryEntry.fromJson(
                item as Map<String, dynamic>? ?? {}))
            .toList();
      }
      return [];
    } catch (e, stackTrace) {
      logger.error(
        'Failed to fetch transaction history',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
