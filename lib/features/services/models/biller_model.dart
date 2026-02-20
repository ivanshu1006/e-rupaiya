class Biller {
  const Biller({
    required this.billerId,
    required this.billerName,
  });

  factory Biller.fromJson(Map<String, dynamic> json) {
    return Biller(
      billerId: json['biller_id'] as String? ?? '',
      billerName: json['biller_name'] as String? ?? '',
    );
  }

  final String billerId;
  final String billerName;
}

class BillerListResponse {
  const BillerListResponse({
    required this.categoryName,
    required this.billers,
  });

  factory BillerListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final billersList = data['billers'] as List<dynamic>? ?? [];
    return BillerListResponse(
      categoryName: data['category_name'] as String? ?? '',
      billers: billersList
          .map((e) => Biller.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String categoryName;
  final List<Biller> billers;
}
