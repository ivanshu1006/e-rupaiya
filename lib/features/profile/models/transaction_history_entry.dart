class TransactionHistoryEntry {
  const TransactionHistoryEntry({
    required this.paymentType,
    required this.billerName,
    required this.amount,
    required this.iconUrl,
  });

  final String paymentType;
  final String billerName;
  final String amount;
  final String iconUrl;

  factory TransactionHistoryEntry.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryEntry(
      paymentType: (json['payment_type'] ?? '').toString(),
      billerName: (json['biller_name'] ?? '').toString(),
      amount: (json['amount'] ?? '').toString(),
      iconUrl: (json['icon'] ?? '').toString(),
    );
  }
}
