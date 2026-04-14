class DigitalGoldOtpResponse {
  const DigitalGoldOtpResponse({
    required this.refId,
    required this.stateResp,
  });

  factory DigitalGoldOtpResponse.fromJson(Map<String, dynamic> json) {
    return DigitalGoldOtpResponse(
      refId: json['refid']?.toString() ?? '',
      stateResp: json['stateresp']?.toString() ?? '',
    );
  }

  final String refId;
  final String stateResp;

  @override
  bool operator ==(Object other) {
    return other is DigitalGoldOtpResponse &&
        other.refId == refId &&
        other.stateResp == stateResp;
  }

  @override
  int get hashCode => Object.hash(refId, stateResp);
}