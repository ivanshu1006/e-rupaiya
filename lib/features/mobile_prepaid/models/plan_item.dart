class PlanItem {
  const PlanItem({
    required this.amount,
    required this.validity,
    required this.description,
    this.data = '',
    this.planName = '',
    this.eCoins = 0,
  });

  final int amount;
  final String validity;
  final String description;
  final String data;
  final String planName;
  final int eCoins;

  factory PlanItem.fromJson(Map<String, dynamic> json) {
    final rsValue = json['rs'];
    final amount =
        rsValue is num ? rsValue.toInt() : int.tryParse('$rsValue') ?? 0;
    final eCoinsValue = json['ecoins'] ?? json['reward'] ?? json['e_coins'];
    final eCoins = eCoinsValue is num
        ? eCoinsValue.toInt()
        : int.tryParse('$eCoinsValue') ?? 0;
    return PlanItem(
      amount: amount,
      validity: (json['validity'] ?? '').toString(),
      description: (json['desc'] ?? '').toString(),
      data: (json['data'] ?? '').toString(),
      planName: (json['planname'] ?? json['plan_name'] ?? '').toString(),
      eCoins: eCoins,
    );
  }
}
