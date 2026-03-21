import 'package:dio/dio.dart';

import '../../../constants/api_constants.dart';
import '../../../services/dio_service.dart';
import '../../../services/logger_service.dart';

class ReferralRepository {
  ReferralRepository({Dio? dio}) : _dio = dio ?? DioService.instance.client;

  final Dio _dio;

  Future<ReferralLinkResponse> generateLink() async {
    try {
      final response =
          await _dio.post(ApiConstants.referralGenerateLinkEndpoint);
      final payload = response.data as Map<String, dynamic>? ?? {};
      return ReferralLinkResponse.fromJson(payload);
    } catch (e, stackTrace) {
      logger.error(
        'Failed to generate referral link',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<ReferralRegisterResponse> registerReferral({
    required String newUserId,
    required String referralCode,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.referralRegisterEndpoint,
        data: {
          'new_user_id': newUserId,
          'referral_code': referralCode,
        },
      );
      final payload = response.data as Map<String, dynamic>? ?? {};
      return ReferralRegisterResponse.fromJson(payload);
    } catch (e, stackTrace) {
      logger.error(
        'Failed to register referral',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

class ReferralLinkResponse {
  const ReferralLinkResponse({
    required this.status,
    required this.referralCode,
    required this.referralLink,
  });

  factory ReferralLinkResponse.fromJson(Map<String, dynamic> json) {
    return ReferralLinkResponse(
      status: json['status'] == true,
      referralCode: (json['referral_code'] ?? '').toString(),
      referralLink: (json['referral_link'] ?? '').toString(),
    );
  }

  final bool status;
  final String referralCode;
  final String referralLink;
}

class ReferralRegisterResponse {
  const ReferralRegisterResponse({
    required this.status,
    required this.message,
  });

  factory ReferralRegisterResponse.fromJson(Map<String, dynamic> json) {
    return ReferralRegisterResponse(
      status: json['status'] == true,
      message: (json['message'] ?? '').toString(),
    );
  }

  final bool status;
  final String message;
}
