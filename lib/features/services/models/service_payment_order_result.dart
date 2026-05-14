class ServicePaymentOrderResult {
  const ServicePaymentOrderResult({
    required this.isSuccess,
    required this.message,
    required this.transactionRef,
    required this.txnId,
    required this.orderId,
    required this.key,
  });

  final bool isSuccess;
  final String message;
  final String transactionRef;
  final int txnId;
  final String orderId;
  final String key;

  factory ServicePaymentOrderResult.fromJson(Map<String, dynamic> json) {
    final statusValue = json['status'];
    final isSuccess =
        statusValue == true || statusValue?.toString().toLowerCase() == 'true';
    return ServicePaymentOrderResult(
      isSuccess: isSuccess,
      message: (json['message'] ?? '').toString().trim(),
      transactionRef: (json['transaction_ref'] ?? '').toString().trim(),
      txnId: int.tryParse((json['txn_id'] ?? '').toString()) ?? 0,
      orderId: (json['order_id'] ?? '').toString().trim(),
      key: (json['key'] ?? '').toString().trim(),
    );
  }
}

