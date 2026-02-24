class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.name,
    required this.mobile,
    this.email,
    this.address,
    this.isVerified = false,
    this.walletBalance = 0.0,
    this.dailyFreeSpin = 0,
    this.normalSpinRemaining = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      mobile: json['mobile'] as String? ?? '',
      email: json['email'] as String?,
      address: json['address'] as String?,
      isVerified: json['is_verified'] == '1',
      walletBalance:
          double.tryParse(json['wallet_balance']?.toString() ?? '') ?? 0.0,
      dailyFreeSpin:
          int.tryParse(json['daily_free_spin']?.toString() ?? '') ?? 0,
      normalSpinRemaining:
          int.tryParse(json['normal_spin_remaining']?.toString() ?? '') ?? 0,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  final String id;
  final String name;
  final String mobile;
  final String? email;
  final String? address;
  final bool isVerified;
  final double walletBalance;
  final int dailyFreeSpin;
  final int normalSpinRemaining;
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
