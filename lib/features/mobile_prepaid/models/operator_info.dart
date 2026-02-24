class OperatorInfo {
  const OperatorInfo({
    required this.operatorName,
    required this.circle,
    required this.circleCode,
    this.iconUrl,
  });

  final String operatorName;
  final String circle;
  final String circleCode;
  final String? iconUrl;

  factory OperatorInfo.fromJson(Map<String, dynamic> json) {
    return OperatorInfo(
      operatorName: (json['operator'] ?? '').toString(),
      circle: (json['circle'] ?? '').toString(),
      circleCode: (json['circlecode'] ?? '').toString(),
      iconUrl: (json['icon'] ?? '').toString(),
    );
  }
}
