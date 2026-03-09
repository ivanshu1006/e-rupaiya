class TransactionHistoryEntry {
  const TransactionHistoryEntry({
    required this.paymentStatus,
    required this.paymentType,
    required this.billerName,
    required this.amount,
    required this.iconUrl,
    required this.transactionId,
    required this.referenceId,
    required this.transactionTime,
  });

  final String paymentStatus;
  final String paymentType;
  final String billerName;
  final String amount;
  final String iconUrl;
  final String transactionId;
  final String referenceId;
  final String transactionTime;

  factory TransactionHistoryEntry.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryEntry(
      paymentStatus: (json['payment_status'] ?? '').toString(),
      paymentType: (json['payment_type'] ?? '').toString(),
      billerName: (json['biller_name'] ?? '').toString(),
      amount: (json['amount'] ?? '').toString(),
      iconUrl: (json['icon'] ?? '').toString(),
      transactionId: (json['transaction_id'] ?? '').toString(),
      referenceId: (json['reference_id'] ?? '').toString(),
      transactionTime: (json['transaction_time'] ?? '').toString(),
    );
  }
}
