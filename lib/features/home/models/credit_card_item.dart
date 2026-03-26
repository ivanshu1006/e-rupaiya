class CreditCardItem {
  const CreditCardItem({
    this.billerName,
    this.maskedIdentifier,
    this.last4Digit,
    this.icon,
    this.billerId,
    this.registerMobNo,
    this.lastAmount,
    this.lastPaidDate,
  });

  factory CreditCardItem.fromJson(Map<String, dynamic> json) {
    return CreditCardItem(
      billerName: json['biller_name'] as String?,
      maskedIdentifier: json['masked_identifier'] as String?,
      last4Digit: json['last_4_digit']?.toString(),
      icon: json['icon'] as String?,
      billerId: json['biller_id'] as String?,
      registerMobNo: json['register_mob_no'] as String?,
      lastAmount: _parseAmount(json['last_amount']),
      lastPaidDate: json['last_paid_date'] as String?,
    );
  }

  final String? billerName;
  final String? maskedIdentifier;
  final String? last4Digit;
  final String? icon;
  final String? billerId;
  final String? registerMobNo;
  final double? lastAmount;
  final String? lastPaidDate;

  static double? _parseAmount(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    if (raw is String) {
      final cleaned = raw.replaceAll(',', '').trim();
      if (cleaned.isEmpty) return null;
      return double.tryParse(cleaned);
    }
    return null;
  }
}
