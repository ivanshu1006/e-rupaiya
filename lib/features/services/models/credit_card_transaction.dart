class CreditCardTransaction {
  const CreditCardTransaction({
    required this.paymentStatus,
    required this.billerName,
    required this.maskedIdentifier,
    required this.amount,
    required this.platformFees,
    required this.totalAmountCharged,
    required this.paymentTransactionId,
    required this.bankReferenceId,
    required this.transactionTime,
    required this.method,
    required this.methodIcon,
    required this.paymentMode,
    required this.vpa,
    required this.rrn,
    required this.icon,
  });

  factory CreditCardTransaction.fromJson(Map<String, dynamic> json) {
    return CreditCardTransaction(
      paymentStatus: json['payment_status']?.toString() ?? '',
      billerName: json['biller_name']?.toString() ?? '',
      maskedIdentifier: json['masked_identifier']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '',
      platformFees: json['platform_fees']?.toString() ?? '',
      totalAmountCharged: json['total_amount_charged']?.toString() ?? '',
      paymentTransactionId: json['payment_transaction_id']?.toString() ?? '',
      bankReferenceId: json['bank_reference_id']?.toString() ?? '',
      transactionTime: json['transaction_time']?.toString() ?? '',
      method: json['method']?.toString() ?? '',
      methodIcon: json['method_icon']?.toString() ?? '',
      paymentMode: json['payment_mode']?.toString() ?? '',
      vpa: json['vpa']?.toString() ?? '',
      rrn: json['rrn']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
    );
  }

  final String paymentStatus;
  final String billerName;
  final String maskedIdentifier;
  final String amount;
  final String platformFees;
  final String totalAmountCharged;
  final String paymentTransactionId;
  final String bankReferenceId;
  final String transactionTime;
  final String method;
  final String methodIcon;
  final String paymentMode;
  final String vpa;
  final String rrn;
  final String icon;
}
