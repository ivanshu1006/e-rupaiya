class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    this.isVerified = false,
    this.walletBalance = 0.0,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      email: json['email'] as String?,
      isVerified: json['is_verified'] == '1',
      walletBalance:
          double.tryParse(json['wallet_balance']?.toString() ?? '') ?? 0.0,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  final String id;
  final String name;
  final String mobile;
  final String? email;
  final bool isVerified;
  final double walletBalance;
  final String? createdAt;
  final String? updatedAt;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '';
  }
}
