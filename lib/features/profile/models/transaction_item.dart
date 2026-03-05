class TransactionItem {
  const TransactionItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.dateTime,
    required this.status,
    required this.iconAsset,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      amount: (json['amount'] ?? '').toString(),
      dateTime: (json['dateTime'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      iconAsset: (json['iconAsset'] ?? '').toString(),
    );
  }

  static List<TransactionItem> fromJsonList(List<dynamic> items) {
    return items
        .whereType<Map<String, dynamic>>()
        .map(TransactionItem.fromJson)
        .toList();
  }

  final String id;
  final String title;
  final String subtitle;
  final String amount;
  final String dateTime;
  final String status;
  final String iconAsset;
}
