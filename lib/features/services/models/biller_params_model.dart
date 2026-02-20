class BillerCustomerParam {
  const BillerCustomerParam({
    required this.paramName,
    required this.dataType,
    this.optional = false,
    this.minLength,
    this.maxLength,
    this.regex,
    this.visibility = true,
  });

  factory BillerCustomerParam.fromJson(Map<String, dynamic> json) {
    return BillerCustomerParam(
      paramName: json['paramName'] as String? ?? '',
      dataType: json['dataType'] as String? ?? '',
      optional: json['optional'] == 'true',
      minLength: int.tryParse(json['minLength']?.toString() ?? ''),
      maxLength: int.tryParse(json['maxLength']?.toString() ?? ''),
      regex: json['regex'] as String?,
      visibility: json['visibility'] != 'false',
    );
  }

  final String paramName;
  final String dataType;
  final bool optional;
  final int? minLength;
  final int? maxLength;
  final String? regex;
  final bool visibility;
}

class BillerParamsResponse {
  const BillerParamsResponse({
    required this.fetchRequirement,
    required this.customerParams,
  });

  factory BillerParamsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final params = data['billerCustomerParams'] as List<dynamic>? ?? [];
    return BillerParamsResponse(
      fetchRequirement: data['fetchRequirement'] as String? ?? '',
      customerParams: params
          .map((e) => BillerCustomerParam.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final String fetchRequirement;
  final List<BillerCustomerParam> customerParams;
}
