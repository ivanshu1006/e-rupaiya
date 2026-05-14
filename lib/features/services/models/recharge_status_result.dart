class RechargeStatusResult {
  const RechargeStatusResult({
    required this.status,
    required this.message,
    required this.transactionId,
    required this.updatedAt,
    required this.raw,
  });

  final String status;
  final String message;
  final String transactionId;
  final String updatedAt;
  final Map<String, dynamic> raw;

  bool get isSuccess => status.trim().toUpperCase() == 'SUCCESS';
  bool get isFailed => status.trim().toUpperCase() == 'FAILED';
  bool get isPending => status.trim().toUpperCase() == 'PENDING';

  factory RechargeStatusResult.fromJson(Map<String, dynamic> json) {
    String read(String key) => (json[key] ?? '').toString().trim();
    return RechargeStatusResult(
      status: read('status'),
      message: read('message'),
      transactionId: read('transaction_id').isNotEmpty
          ? read('transaction_id')
          : (read('transactionId').isNotEmpty ? read('transactionId') : read('transaction_ref')),
      updatedAt: read('updated_at'),
      raw: json,
    );
  }
}

