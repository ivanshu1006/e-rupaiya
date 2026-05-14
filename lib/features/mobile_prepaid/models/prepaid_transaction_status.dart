class PrepaidTransactionStatus {
  const PrepaidTransactionStatus({
    required this.status,
    required this.message,
    required this.amount,
    required this.operatorName,
    required this.mobile,
    required this.paymentMode,
    required this.walletAmount,
    required this.razorpayAmount,
    required this.transactionId,
    required this.updatedAt,
  });

  final String status;
  final String message;
  final String amount;
  final String operatorName;
  final String mobile;
  final String paymentMode;
  final String walletAmount;
  final String razorpayAmount;
  final String transactionId;
  final String updatedAt;

  bool get isSuccess => status.trim().toUpperCase() == 'SUCCESS';
  bool get isFailed => status.trim().toUpperCase() == 'FAILED';
  bool get isPending => status.trim().toUpperCase() == 'PENDING';

  factory PrepaidTransactionStatus.fromJson(Map<String, dynamic> json) {
    String read(String key) => (json[key] ?? '').toString().trim();
    return PrepaidTransactionStatus(
      status: read('status'),
      message: read('message'),
      amount: read('amount'),
      operatorName: read('operator'),
      mobile: read('mobile'),
      paymentMode: read('payment_mode'),
      walletAmount: read('wallet_amount'),
      razorpayAmount: read('razorpay_amount'),
      transactionId: read('transaction_id').isNotEmpty
          ? read('transaction_id')
          : read('transactionId'),
      updatedAt: read('updated_at'),
    );
  }
}

