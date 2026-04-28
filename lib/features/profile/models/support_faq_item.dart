class SupportFaqItem {
  const SupportFaqItem({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    this.video,
  });

  factory SupportFaqItem.fromJson(Map<String, dynamic> json) {
    return SupportFaqItem(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      imageUrl: _nullIfEmpty(json['image']?.toString()),
      video: _nullIfEmpty(json['video']?.toString()),
    );
  }

  static List<SupportFaqItem> fromJsonList(List<dynamic> items) {
    return items
        .whereType<Map<String, dynamic>>()
        .map(SupportFaqItem.fromJson)
        .toList();
  }

  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String? video;
}

String? _nullIfEmpty(String? input) {
  final value = input?.trim();
  if (value == null || value.isEmpty || value.toLowerCase() == 'null') {
    return null;
  }
  return value;
}

