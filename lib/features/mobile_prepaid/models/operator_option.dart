class OperatorOption {
  const OperatorOption({
    required this.name,
    required this.iconUrl,
  });

  final String name;
  final String iconUrl;

  factory OperatorOption.fromJson(Map<String, dynamic> json) {
    return OperatorOption(
      name: (json['operator'] ?? '').toString(),
      iconUrl: (json['icon'] ?? '').toString(),
    );
  }
}
