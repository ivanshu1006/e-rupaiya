class LatestTransaction {
  const LatestTransaction({
    required this.id,
    required this.paymentType,
    required this.billerName,
    required this.amount,
    required this.status,
    required this.transactionRef,
    required this.serviceNo,
    required this.icon,
  });

  final String id;
  final String paymentType;
  final String billerName;
  final num amount;
  final String status;
  final String transactionRef;
  final String serviceNo;
  final String icon;

  factory LatestTransaction.fromJson(Map<String, dynamic> json) {
    return LatestTransaction(
      id: (json['id'] ?? '').toString(),
      paymentType: (json['payment_type'] ?? '').toString(),
      billerName: (json['biller_name'] ?? '').toString(),
      amount: json['amount'] is num
          ? (json['amount'] as num)
          : num.tryParse((json['amount'] ?? '0').toString()) ?? 0,
      status: (json['status'] ?? '').toString(),
      transactionRef: (json['transaction_ref'] ?? '').toString(),
      serviceNo: (json['service_no'] ?? '').toString(),
      icon: (json['icon'] ?? '').toString(),
    );
  }

  bool get isSuccess => status.trim().toLowerCase() == 'success';
}
