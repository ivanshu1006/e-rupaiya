import 'package:dio/dio.dart';

import '../../../constants/api_constants.dart';
import '../../../services/dio_service.dart';
import '../../../services/logger_service.dart';
import '../models/notifications_feed.dart';
import '../models/notification_item.dart';

class NotificationsRepository {
  NotificationsRepository({Dio? dio})
      : _dio = dio ?? DioService.instance.client;

  final Dio _dio;

  Future<NotificationsFeed> fetchNotifications() async {
    try {
      final response = await _dio.get(ApiConstants.notificationsEndpoint);
      final payload = response.data as Map<String, dynamic>? ?? {};
      final unread = _parseCount(payload['unread_count']) ?? 0;

      final updatesRaw = payload['updates'];
      final notificationsRaw = payload['notifications'];
      if (updatesRaw is List || notificationsRaw is List) {
        final updates = (updatesRaw is List ? updatesRaw : const [])
            .whereType<Map<String, dynamic>>()
            .map(NotificationItem.fromApi)
            .toList();
        final notifications = (notificationsRaw is List ? notificationsRaw : const [])
            .whereType<Map<String, dynamic>>()
            .map(NotificationItem.fromApi)
            .toList();
        return NotificationsFeed(
          unreadCount: unread,
          updates: updates,
          notifications: notifications,
        );
      }

      // Backward compatibility: older API under `data: []`.
      final data = payload['data'];
      if (data is List) {
        final items = data
            .whereType<Map<String, dynamic>>()
            .map(NotificationItem.fromApi)
            .toList();
        final computedUnread =
            unread > 0 ? unread : items.where((n) => !n.isRead).length;
        return NotificationsFeed(
          unreadCount: computedUnread,
          updates: const [],
          notifications: items,
        );
      }

      return const NotificationsFeed(
        unreadCount: 0,
        updates: [],
        notifications: [],
      );
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
      final feed = await fetchNotifications();
      return feed.unreadCount;
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

  Future<bool> remindMeLater(String notificationId) async {
    final trimmed = notificationId.trim();
    if (trimmed.isEmpty) return false;
    try {
      final response = await _dio.post(
        ApiConstants.notificationRemindMeLaterEndpoint,
        data: {'notification_id': trimmed},
      );
      final payload = response.data as Map<String, dynamic>? ?? {};
      final success = payload['success'];
      if (success is bool) return success;
      return success?.toString().toLowerCase() == 'true';
    } catch (e, stackTrace) {
      logger.error(
        'Failed to remind me later',
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
