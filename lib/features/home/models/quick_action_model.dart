class QuickActionService {
  const QuickActionService({required this.name});

  factory QuickActionService.fromJson(Map<String, dynamic> json) {
    return QuickActionService(
      name: json['name'] as String? ?? '',
    );
  }

  final String name;
}

class QuickActionCategory {
  const QuickActionCategory({
    required this.category,
    required this.services,
  });

  factory QuickActionCategory.fromJson(Map<String, dynamic> json) {
    final servicesList = json['services'] as List<dynamic>? ?? [];
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
