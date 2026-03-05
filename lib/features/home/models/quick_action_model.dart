class QuickActionService {
  const QuickActionService({required this.name, this.offers});

  factory QuickActionService.fromJson(Map<String, dynamic> json) {
    return QuickActionService(
      name: json['name'] as String? ?? '',
      offers: json['Offers'] as int?,
    );
  }

  final String name;
  final int? offers;
}

class QuickActionCategory {
  const QuickActionCategory({
    required this.category,
    required this.services,
  });

  factory QuickActionCategory.fromJson(Map<String, dynamic> json) {
    final rawServices = json['services'];
    List<dynamic> servicesList = const [];
    if (rawServices is List) {
      servicesList = rawServices;
    } else if (rawServices is Map) {
      servicesList = rawServices.values.toList();
    }
    return QuickActionCategory(
      category: json['category'] as String? ?? '',
      services: servicesList
          .map((e) => QuickActionService.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String category;
  final List<QuickActionService> services;
}
