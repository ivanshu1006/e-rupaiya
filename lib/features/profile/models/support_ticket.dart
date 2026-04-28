class SupportTicket {
  const SupportTicket({
    required this.id,
    required this.transactionId,
    required this.service,
    required this.issueType,
    required this.isTransactionRelated,
    required this.description,
    required this.status,
    required this.createdAtRaw,
    required this.screenshot,
  });

  final String id;
  final String transactionId;
  final String service;
  final String issueType;
  final bool isTransactionRelated;
  final String description;
  final String status;
  final String createdAtRaw;
  final String? screenshot;

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: (json['id'] ?? '').toString(),
      transactionId: (json['transaction_id'] ?? '').toString(),
      service: (json['service'] ?? '').toString(),
      issueType: (json['issue_type'] ?? '').toString(),
      isTransactionRelated:
          (json['is_transaction_related'] ?? '').toString().toUpperCase() ==
              'Y',
      description: (json['description'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAtRaw: (json['created_at'] ?? '').toString(),
      screenshot:
          json['screenshot'] == null ? null : json['screenshot'].toString(),
    );
  }
}
