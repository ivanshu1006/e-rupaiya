class OfferModel {
  const OfferModel({
    required this.category,
    required this.validUntil,
    required this.description,
    required this.iconType,
  });

  final String category;
  final String validUntil;
  final String description;
  final OfferIconType iconType;

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      category: json['category'] as String? ?? '',
      validUntil: json['valid_until'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconType: OfferIconType.values.firstWhere(
        (e) => e.name == (json['icon_type'] as String? ?? ''),
        orElse: () => OfferIconType.generic,
      ),
    );
  }
}

enum OfferIconType { mobile, creditCard, dth, wallet, generic }

const List<Map<String, dynamic>> kMockOffers = [
  {
    'category': 'Mobile Recharge Reward',
    'valid_until': 'DEC 31, 2025',
    'description': 'Get \u20B925 Cashback On Mobile Recharge',
    'icon_type': 'mobile',
  },
  {
    'category': 'Credit Card Reward',
    'valid_until': 'DEC 31, 2025',
    'description': 'Earn \u20B9100 Cashback On DTH Recharge',
    'icon_type': 'creditCard',
  },
  {
    'category': 'Cashback On DTH',
    'valid_until': 'DEC 31, 2025',
    'description': 'Earn \u20B9100 Cashback On DTH Recharge',
    'icon_type': 'dth',
  },
  {
    'category': 'Credit Card Reward',
    'valid_until': 'DEC 31, 2025',
    'description': 'Get \u20B925 Cashback On Mobile Recharge',
    'icon_type': 'creditCard',
  },
  {
    'category': 'Wallet Cashback',
    'valid_until': 'JAN 15, 2026',
    'description': 'Get \u20B950 Cashback On Wallet Top-Up',
    'icon_type': 'wallet',
  },
];
