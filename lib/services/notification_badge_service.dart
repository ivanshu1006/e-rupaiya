import 'package:flutter/foundation.dart';

import '../features/home/repositories/notifications_repository.dart';
import 'logger_service.dart';

class NotificationBadgeService {
  NotificationBadgeService._();

  static final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);
  static final NotificationsRepository _repository = NotificationsRepository();

  static int get current => unreadCount.value;

  static void setCount(int count) {
    final next = count < 0 ? 0 : count;
    if (unreadCount.value != next) {
      unreadCount.value = next;
    }
  }

  static void decrement() {
    if (unreadCount.value > 0) {
      unreadCount.value -= 1;
    }
  }

  static void syncFromList(int count) {
    setCount(count);
  }

  static Future<void> refreshCount() async {
    try {
      final count = await _repository.fetchUnreadCount();
      setCount(count);
    } catch (e, stackTrace) {
      logger.error(
        'Failed to refresh notification count',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
