class HelpCenterOption {
  const HelpCenterOption({
    required this.id,
    required this.label,
  });

  factory HelpCenterOption.fromJson(Map<String, dynamic> json) {
    return HelpCenterOption(
      id: (json['id'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
    );
  }

  static List<HelpCenterOption> fromJsonList(List<dynamic> items) {
    return items
        .whereType<Map<String, dynamic>>()
        .map(HelpCenterOption.fromJson)
        .toList();
  }

  final String id;
  final String label;
}
