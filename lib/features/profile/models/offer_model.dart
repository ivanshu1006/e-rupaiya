class OfferModel {
  const OfferModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.banner,
    required this.cashbackValue,
    required this.cashbackType,
    required this.termsConditions,
    required this.howToClaim,
    required this.startDate,
    required this.endDate,
    required this.iconType,
  });

  final String id;
  final String title;
  final String summary;
  final String banner;
  final String cashbackValue;
  final String cashbackType;
  final String termsConditions;
  final String howToClaim;
  final String startDate;
  final String endDate;
  final OfferIconType iconType;

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: (json['id'] ?? '').toString(),
      title: json['category'] as String? ?? '',
      summary: json['description'] as String? ?? '',
      banner: json['banner'] as String? ?? '',
      cashbackValue: json['cashback_value'] as String? ?? '',
      cashbackType: json['cashback_type'] as String? ?? '',
      termsConditions: json['terms_conditions'] as String? ?? '',
      howToClaim: json['how_to_claim'] as String? ?? '',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['valid_until'] as String? ?? '',
      iconType: OfferIconType.values.firstWhere(
        (e) => e.name == (json['icon_type'] as String? ?? ''),
        orElse: () => OfferIconType.generic,
      ),
    );
  }

  factory OfferModel.fromApi(Map<String, dynamic> json) {
    return OfferModel(
      id: (json['id'] ?? '').toString(),
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      banner: json['banner'] as String? ?? '',
      cashbackValue: json['cashback_value'] as String? ?? '',
      cashbackType: json['cashback_type'] as String? ?? '',
      termsConditions: json['terms_conditions'] as String? ?? '',
      howToClaim: json['how_to_claim'] as String? ?? '',
      startDate: (json['start_date'] as String?) ?? '',
      endDate: (json['end_date'] as String?) ?? '',
      iconType: OfferIconType.generic,
    );
  }
}

enum OfferIconType { mobile, creditCard, dth, wallet, generic }

const List<Map<String, dynamic>> kMockOffers = [
  {
    'id': '1',
    'category': 'Mobile Recharge Reward',
    'valid_until': 'DEC 31, 2025',
    'description': 'Get \u20B925 Cashback On Mobile Recharge',
    'icon_type': 'mobile',
  },
  {
    'id': '2',
    'category': 'Credit Card Reward',
    'valid_until': 'DEC 31, 2025',
    'description': 'Earn \u20B9100 Cashback On DTH Recharge',
    'icon_type': 'creditCard',
  },
  {
    'id': '3',
    'category': 'Cashback On DTH',
    'valid_until': 'DEC 31, 2025',
    'description': 'Earn \u20B9100 Cashback On DTH Recharge',
    'icon_type': 'dth',
  },
  {
    'id': '4',
    'category': 'Credit Card Reward',
    'valid_until': 'DEC 31, 2025',
    'description': 'Get \u20B925 Cashback On Mobile Recharge',
    'icon_type': 'creditCard',
  },
  {
    'id': '5',
    'category': 'Wallet Cashback',
    'valid_until': 'JAN 15, 2026',
    'description': 'Get \u20B950 Cashback On Wallet Top-Up',
    'icon_type': 'wallet',
  },
];
