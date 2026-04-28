class RechargeResult {
  const RechargeResult({
    required this.status,
    required this.message,
    required this.transactionId,
    required this.dateTime,
    required this.isSuccess,
  });

  final String status;
  final String message;
  final String transactionId;
  final String dateTime;
  final bool isSuccess;
}
