import '../../../constants/api_constants.dart';

class PolicyPageResponse {
  const PolicyPageResponse({
    required this.status,
    this.message,
    this.data,
  });

  final bool status;
  final String? message;
  final PolicyPageData? data;

  factory PolicyPageResponse.fromJson(Map<String, dynamic> json) {
    return PolicyPageResponse(
      status: json['status'] == true,
      message: json['message'] as String?,
      data: json['data'] is Map<String, dynamic>
          ? PolicyPageData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PolicyPageData {
  const PolicyPageData({
    required this.slug,
    required this.lang,
    required this.content,
    required this.banners,
  });

  final String slug;
  final String lang;
  final String content;
  final List<PolicyPageBanner> banners;

  factory PolicyPageData.fromJson(Map<String, dynamic> json) {
    final bannersRaw = json['banners'];
    final banners = bannersRaw is List
        ? bannersRaw
            .map(PolicyPageBanner.fromJson)
            .whereType<PolicyPageBanner>()
        : const Iterable<PolicyPageBanner>.empty();

    return PolicyPageData(
      slug: (json['slug'] as String?)?.trim() ?? '',
      lang: (json['lang'] as String?)?.trim() ?? '',
      content: (json['content'] as String?) ?? '',
      banners: banners.toList(),
    );
  }
}

class PolicyPageBanner {
  const PolicyPageBanner({required this.imageUrl});

  final String imageUrl;

  static PolicyPageBanner? fromJson(dynamic json) {
    if (json is String) {
      final url = _normalizeUrl(json);
      return url == null ? null : PolicyPageBanner(imageUrl: url);
    }
    if (json is Map<String, dynamic>) {
      final candidate = _firstNonEmptyString(
        json,
        const [
          'image_url',
          'imageUrl',
          'image',
          'banner',
          'url',
          'path',
          'src',
        ],
      );
      final url = _normalizeUrl(candidate);
      return url == null ? null : PolicyPageBanner(imageUrl: url);
    }
    return null;
  }

  static String? _firstNonEmptyString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    for (final key in keys) {
      final value = json[key];
      if (value is String) {
        final trimmed = value.trim();
        if (trimmed.isNotEmpty) return trimmed;
      }
    }
    return null;
  }

  static String? _normalizeUrl(String? input) {
    final raw = input?.trim();
    if (raw == null || raw.isEmpty) return null;
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    if (raw.startsWith('/')) return '${ApiConstants.baseUrl}$raw';
    return '${ApiConstants.baseUrl}/$raw';
  }
}
