class RecentPurchase {
  final String txnRefId;
  final String metalType;
  final String txnType;
  final String amount;
  final String date;
  final String status;

  RecentPurchase({
    required this.txnRefId,
    required this.metalType,
    required this.txnType,
    required this.amount,
    required this.date,
    required this.status,
  });

  factory RecentPurchase.fromJson(Map<String, dynamic> json) {
    return RecentPurchase(
      txnRefId: json['txn_ref_id'],
      metalType: json['metal_type'],
      txnType: json['txn_type'],
      amount: json['amount'],
      date: json['date'],
      status: json['status'],
    );
  }
}

class RecentPurchasesResponse {
  final bool status;
  final String message;
  final List<RecentPurchase> data;

  RecentPurchasesResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RecentPurchasesResponse.fromJson(Map<String, dynamic> json) {
    return RecentPurchasesResponse(
      status: json['status'],
      message: json['message'],
      data: (json['data'] as List)
          .map((e) => RecentPurchase.fromJson(e))
          .toList(),
    );
  }
}
