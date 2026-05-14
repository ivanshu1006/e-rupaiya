import 'notification_item.dart';

class NotificationsFeed {
  const NotificationsFeed({
    required this.unreadCount,
    required this.updates,
    required this.notifications,
  });

  final int unreadCount;
  final List<NotificationItem> updates;
  final List<NotificationItem> notifications;
}

