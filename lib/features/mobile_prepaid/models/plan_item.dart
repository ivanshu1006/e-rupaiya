class PlanItem {
  const PlanItem({
    required this.amount,
    required this.validity,
    required this.description,
    this.data = '',
    this.planName = '',
    this.eCoins = 0,
    this.benefitImages = const [],
    this.additionalBenefits = const [],
  });

  final int amount;
  final String validity;
  final String description;
  final String data;
  final String planName;
  final int eCoins;
  final List<String> benefitImages;
  final List<AdditionalBenefit> additionalBenefits;

  factory PlanItem.fromJson(Map<String, dynamic> json) {
    final rsValue = json['rs'];
    final amount =
        rsValue is num ? rsValue.toInt() : int.tryParse('$rsValue') ?? 0;
    final eCoinsValue = json['ecoins'] ?? json['reward'] ?? json['e_coins'];
    final eCoins = eCoinsValue is num
        ? eCoinsValue.toInt()
        : int.tryParse('$eCoinsValue') ?? 0;
    final rawImages = json['benefit_images'];
    final benefitImages = rawImages is List
        ? rawImages.map((e) => e.toString()).toList()
        : <String>[];
    final rawAdditionalBenefits = json['additional_benefits'];
    final additionalBenefits = rawAdditionalBenefits is List
        ? rawAdditionalBenefits
            .whereType<Map>()
            .map((item) => AdditionalBenefit.fromJson(
                  item.map(
                    (key, value) => MapEntry('$key', value),
                  ),
                ))
            .toList()
        : <AdditionalBenefit>[];
    return PlanItem(
      amount: amount,
      validity: (json['validity'] ?? '').toString(),
      description: (json['desc'] ?? '').toString(),
      data: (json['data'] ?? '').toString(),
      planName: (json['planname'] ?? json['plan_name'] ?? '').toString(),
      eCoins: eCoins,
      benefitImages: benefitImages,
      additionalBenefits: additionalBenefits,
    );
  }
}

class AdditionalBenefit {
  const AdditionalBenefit({
    required this.text,
    this.image,
  });

  final String text;
  final String? image;

  factory AdditionalBenefit.fromJson(Map<String, dynamic> json) {
    final image = json['image']?.toString().trim();
    return AdditionalBenefit(
      text: (json['text'] ?? '').toString(),
      image: (image?.isEmpty ?? true) ? null : image,
    );
  }
}
