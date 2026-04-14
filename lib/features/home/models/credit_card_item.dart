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
    this.dueDate,
    this.isDue,
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
      dueDate: json['due_date'] as String?,
      isDue: _parseIsDue(json['is_due']),
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
  final String? dueDate;
  final bool? isDue;

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

  static bool? _parseIsDue(dynamic raw) {
    if (raw == null) return null;
    if (raw is bool) return raw;
    if (raw is num) return raw != 0;
    if (raw is String) {
      final value = raw.trim().toLowerCase();
      if (value.isEmpty) return null;
      return value == '1' || value == 'true' || value == 'yes';
    }
    return null;
  }
}
