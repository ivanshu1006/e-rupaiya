import 'package:dio/dio.dart';

import '../../../constants/api_constants.dart';
import '../../../services/dio_service.dart';
import '../../../services/logger_service.dart';
import '../models/notification_item.dart';

class NotificationsRepository {
  NotificationsRepository({Dio? dio}) : _dio = dio ?? DioService.instance.client;

  final Dio _dio;

  Future<List<NotificationItem>> fetchNotifications() async {
    try {
      final response = await _dio.get(ApiConstants.notificationsEndpoint);
      final payload = response.data as Map<String, dynamic>? ?? {};
      final data = payload['data'];
      if (data is List) {
        return data
            .map(
              (item) => NotificationItem.fromApi(
                item as Map<String, dynamic>? ?? {},
              ),
            )
            .toList();
      }
      return [];
    } catch (e, stackTrace) {
      logger.error(
        'Failed to fetch notifications',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
