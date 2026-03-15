import 'package:dio/dio.dart';

import '../../../constants/api_constants.dart';
import '../../../services/dio_service.dart';
import '../../../services/logger_service.dart';
import '../models/notification_item.dart';

class NotificationsRepository {
  NotificationsRepository({Dio? dio})
      : _dio = dio ?? DioService.instance.client;

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

  Future<int> fetchUnreadCount() async {
    try {
      final response = await _dio.get(ApiConstants.notificationsEndpoint);
      final payload = response.data as Map<String, dynamic>? ?? {};
      final unread = _parseCount(payload['unread_count']);
      if (unread != null) return unread;

      final data = payload['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .where((item) => (item['is_read'] ?? '').toString() == '0')
            .length;
      }
      return 0;
    } catch (e, stackTrace) {
      logger.error(
        'Failed to fetch notification count',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<bool> markNotificationRead(String id) async {
    final trimmed = id.trim();
    if (trimmed.isEmpty) return false;
    try {
      final response =
          await _dio.post(ApiConstants.notificationReadEndpoint(trimmed));
      final payload = response.data as Map<String, dynamic>? ?? {};
      final success = payload['success'];
      if (success is bool) return success;
      return success?.toString().toLowerCase() == 'true';
    } catch (e, stackTrace) {
      logger.error(
        'Failed to mark notification read',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}

int? _parseCount(dynamic raw) {
  if (raw == null) return null;
  if (raw is num) return raw.toInt();
  return int.tryParse(raw.toString());
}
