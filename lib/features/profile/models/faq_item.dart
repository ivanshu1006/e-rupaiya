class FaqItem {
  const FaqItem({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    return FaqItem(
      id: (json['id'] ?? '').toString(),
      question: (json['question'] ?? '').toString(),
      answer: (json['answer'] ?? '').toString(),
    );
  }

  static List<FaqItem> fromJsonList(List<dynamic> items) {
    return items
        .whereType<Map<String, dynamic>>()
        .map(FaqItem.fromJson)
        .toList();
  }

  final String id;
  final String question;
  final String answer;
}
