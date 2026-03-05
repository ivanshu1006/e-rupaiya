class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.iconAsset,
    required this.section,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      actionLabel: (json['actionLabel'] ?? '').toString(),
      iconAsset: (json['iconAsset'] ?? '').toString(),
      section: (json['section'] ?? '').toString(),
    );
  }

  static List<NotificationItem> fromJsonList(List<dynamic> items) {
    return items
        .whereType<Map<String, dynamic>>()
        .map(NotificationItem.fromJson)
        .toList();
  }

  final String id;
  final String title;
  final String subtitle;
  final String actionLabel;
  final String iconAsset;
  final String section;
}
