class TransactionHistoryEntry {
  const TransactionHistoryEntry({
    required this.paymentStatus,
    required this.paymentType,
    required this.billerName,
    required this.maskedIdentifier,
    required this.amount,
    required this.platformFees,
    required this.totalAmountCharged,
    required this.customerMobile,
    required this.iconUrl,
    required this.transactionId,
    required this.bankReferenceId,
    required this.referenceId,
    required this.transactionTime,
    required this.method,
    required this.methodIcon,
    required this.paymentMode,
    required this.vpa,
    required this.rrn,
  });

  final String paymentStatus;
  final String paymentType;
  final String billerName;
  final String maskedIdentifier;
  final String amount;
  final String platformFees;
  final String totalAmountCharged;
  final String customerMobile;
  final String iconUrl;
  final String transactionId;
  final String bankReferenceId;
  final String referenceId;
  final String transactionTime;
  final String method;
  final String methodIcon;
  final String paymentMode;
  final String vpa;
  final String rrn;

  factory TransactionHistoryEntry.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryEntry(
      paymentStatus: _stringOrEmpty(json['payment_status']),
      paymentType: _stringOrEmpty(json['payment_type']),
      billerName: _stringOrEmpty(json['biller_name']),
      maskedIdentifier: _stringOrEmpty(json['masked_identifier']),
      amount: _stringOrEmpty(json['amount']),
      platformFees: _stringOrEmpty(json['platform_fees']),
      totalAmountCharged: _stringOrEmpty(json['total_amount_charged']),
      customerMobile: _stringOrEmpty(json['customer_mobile']),
      iconUrl: _stringOrEmpty(json['icon']),
      transactionId: _stringOrEmpty(
        json['payment_transaction_id'] ?? json['transaction_id'],
      ),
      bankReferenceId: _stringOrEmpty(
        json['bank_reference_id'] ?? json['bank_referenceId'],
      ),
      referenceId: _stringOrEmpty(json['org_ref_id'] ?? json['reference_id']),
      transactionTime: _stringOrEmpty(json['transaction_time']),
      method: _stringOrEmpty(json['method']),
      methodIcon: _stringOrEmpty(json['method_icon']),
      paymentMode: _stringOrEmpty(json['payment_mode']),
      vpa: _stringOrEmpty(json['vpa']),
      rrn: _stringOrEmpty(json['rrn']),
    );
  }
}

String _stringOrEmpty(dynamic value) {
  if (value == null) return '';
  final text = value.toString();
  return text == 'null' ? '' : text;
}
