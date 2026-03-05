class RegionOption {
  const RegionOption({
    required this.code,
    required this.name,
  });

  final String code;
  final String name;

  factory RegionOption.fromJson(Map<String, dynamic> json) {
    final rawNames = json['circle_name'];
    final names = <String>[];
    if (rawNames is List) {
      for (final item in rawNames) {
        final value = item?.toString().trim();
        if (value != null && value.isNotEmpty) {
          names.add(value);
        }
      }
    } else {
      final value = rawNames?.toString().trim();
      if (value != null && value.isNotEmpty) {
        names.add(value);
      }
    }
    final displayName =
        names.isEmpty ? '' : (names.length == 1 ? names.first : '${names[0]} & ${names[1]}');
    return RegionOption(
      code: (json['circle_code'] ?? '').toString(),
      name: displayName,
    );
  }
}
