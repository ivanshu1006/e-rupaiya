import 'dart:ui';

class BannerModel {
  final int id;
  final String title;
  final String image;
  final Color? colorStart;
  final Color? colorEnd;

  BannerModel({
    required this.id,
    required this.title,
    required this.image,
    this.colorStart,
    this.colorEnd,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    final colorStartHex = json['color_start'] as String?;
    final colorEndHex = json['color_end'] as String?;
    return BannerModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      image: json['image'] as String? ?? '',
      colorStart: _parseHexColor(colorStartHex),
      colorEnd: _parseHexColor(colorEndHex),
    );
  }

  static Color? _parseHexColor(String? input) {
    if (input == null) return null;
    final value = input.trim();
    if (value.isEmpty) return null;
    final normalized = value.startsWith('#') ? value.substring(1) : value;
    if (normalized.length == 6) {
      final parsed = int.tryParse('FF$normalized', radix: 16);
      return parsed == null ? null : Color(parsed);
    }
    if (normalized.length == 8) {
      final parsed = int.tryParse(normalized, radix: 16);
      return parsed == null ? null : Color(parsed);
    }
    return null;
  }
}
