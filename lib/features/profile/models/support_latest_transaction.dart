class SupportLatestTransaction {
  const SupportLatestTransaction({
    required this.id,
    required this.paymentType,
    required this.billerName,
    required this.amount,
    required this.status,
    required this.date,
    required this.type,
    required this.transactionId,
  });

  factory SupportLatestTransaction.fromJson(Map<String, dynamic> json) {
    return SupportLatestTransaction(
      id: (json['id'] ?? '').toString(),
      paymentType: (json['payment_type'] ?? '').toString(),
      billerName: (json['biller_name'] ?? '').toString(),
      amount: (json['amount'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      transactionId: (json['transaction_id'] ?? '').toString(),
    );
  }

  static List<SupportLatestTransaction> fromJsonList(List<dynamic> items) {
    return items
        .whereType<Map<String, dynamic>>()
        .map(SupportLatestTransaction.fromJson)
        .toList();
  }

  final String id;
  final String paymentType;
  final String billerName;
  final String amount;
  final String status;
  final String date;
  final String type;
  final String transactionId;

  DateTime? get dateTime {
    final trimmed = date.trim();
    if (trimmed.isEmpty) return null;
    return DateTime.tryParse(trimmed.replaceFirst(' ', 'T'));
  }

  String get serviceCode {
    final normalized = type.trim().toUpperCase();
    if (normalized == 'METAL') return 'METAL';
    if (normalized == 'EDUCATION') return 'EDUCATION';
    return 'BBPS';
  }

  String get faqCategory {
    final payment = paymentType.trim().toLowerCase();
    if (payment.contains('education')) return 'education_payments';
    if (payment == 'gold' ||
        payment == 'silver' ||
        payment.contains('metal')) {
      return 'metal_payments';
    }

    final normalized = type.trim().toUpperCase();
    if (normalized == 'METAL') return 'metal_payments';
    if (normalized == 'EDUCATION') return 'education_payments';
    return 'bbps_payments';
  }
}
