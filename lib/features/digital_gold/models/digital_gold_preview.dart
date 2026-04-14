class DigitalGoldPreview {
  const DigitalGoldPreview({
    required this.kycStatus,
    required this.isUserRegistered,
    required this.myGoldBalance,
    required this.taxAmt1,
    required this.taxAmt2,
    required this.preTaxAmount,
    required this.totalAmount,
    this.customerId,
    this.billingAddressId,
    this.quoteId,
  });

  factory DigitalGoldPreview.fromJson(Map<String, dynamic> json) {
    return DigitalGoldPreview(
      kycStatus: _parseBool(json['kyc_status']),
      isUserRegistered: _parseBool(json['is_user_gold_sil_register']),
      myGoldBalance: _parseDouble(json['my_gold_balance']),
      taxAmt1: _parseDouble(json['tax_amt_1']),
      taxAmt2: _parseDouble(json['tax_amt_2']),
      preTaxAmount: _parseDouble(json['pre_tax_amount']),
      totalAmount: _parseDouble(json['total_amount']),
      customerId: json['customer_id']?.toString(),
      billingAddressId: json['billing_address_id']?.toString(),
      quoteId: json['quote_id']?.toString(),
    );
  }

  final bool kycStatus;
  final bool isUserRegistered;
  final double myGoldBalance;
  final double taxAmt1;
  final double taxAmt2;
  final double preTaxAmount;
  final double totalAmount;
  final String? customerId;
  final String? billingAddressId;
  final String? quoteId;

  double get gstAmount => taxAmt1 + taxAmt2;

  @override
  bool operator ==(Object other) {
    return other is DigitalGoldPreview &&
        other.kycStatus == kycStatus &&
        other.isUserRegistered == isUserRegistered &&
        other.myGoldBalance == myGoldBalance &&
        other.taxAmt1 == taxAmt1 &&
        other.taxAmt2 == taxAmt2 &&
        other.preTaxAmount == preTaxAmount &&
        other.totalAmount == totalAmount &&
        other.customerId == customerId &&
        other.billingAddressId == billingAddressId &&
        other.quoteId == quoteId;
  }

  @override
  int get hashCode => Object.hash(
        kycStatus,
        isUserRegistered,
        myGoldBalance,
        taxAmt1,
        taxAmt2,
        preTaxAmount,
        totalAmount,
        customerId,
        billingAddressId,
        quoteId,
      );

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value == 1;
    final text = value?.toString().trim().toLowerCase();
    return text == '1' || text == 'true' || text == 'yes' || text == 'verified';
  }

  static double _parseDouble(dynamic value) {
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}
