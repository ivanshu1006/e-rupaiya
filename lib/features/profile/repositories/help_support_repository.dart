import 'package:dio/dio.dart';

import '../../../constants/api_constants.dart';
import '../../../services/dio_service.dart';
import '../../../services/logger_service.dart';
import '../models/help_topic.dart';
import '../models/support_dashboard_data.dart';
import '../models/support_latest_transaction.dart';

class HelpSupportRepository {
  HelpSupportRepository({Dio? dio}) : _dio = dio ?? DioService.instance.client;

  final Dio _dio;

  Future<SupportDashboardData> fetchLatestTransactionsAndTopics() async {
    try {
      final response = await _dio.get(
        ApiConstants.supportLatestTransactionsEndpoint,
      );
      final payload = response.data as Map<String, dynamic>? ?? {};
      final data = payload['data'] as Map<String, dynamic>? ?? {};

      final latestRaw = data['latest_transactions'];
      final topicsRaw = data['help_topics'];

      final latest = latestRaw is List
          ? SupportLatestTransaction.fromJsonList(latestRaw)
          : const <SupportLatestTransaction>[];
      final topics = topicsRaw is List
          ? HelpTopic.fromJsonList(topicsRaw)
          : const <HelpTopic>[];

      return SupportDashboardData(
        latestTransactions: latest,
        helpTopics: topics,
      );
    } catch (e, stackTrace) {
      logger.error(
        'Failed to fetch help & support dashboard data',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
