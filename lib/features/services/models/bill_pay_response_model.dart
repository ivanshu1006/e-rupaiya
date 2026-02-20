class BillPayResponse {
  const BillPayResponse({
    required this.code,
    required this.status,
    required this.message,
    required this.transactionId,
    required this.payload,
  });

  factory BillPayResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};
    final payload = data['payload'] as Map<String, dynamic>? ?? const {};

    // The server uses 'message' on success and 'messages.error' on failure.
    var message = json['message']?.toString() ?? '';
    if (message.isEmpty) {
      final messages = json['messages'] as Map<String, dynamic>? ?? const {};
      message = messages['error']?.toString() ?? '';
    }

    return BillPayResponse(
      code: json['code'] as int? ?? json['error'] as int? ?? 0,
      status: json['status']?.toString() ?? '',
      message: message,
      transactionId: json['transactionId']?.toString() ?? '',
      payload: payload,
    );
  }

  final int code;
  final String status;
  final String message;
  final String transactionId;
  final Map<String, dynamic> payload;

  bool get isSuccess =>
      code == 200 || status.toLowerCase() == 'success' || status == 'SUCCESS';
}
