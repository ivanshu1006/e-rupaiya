import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../constants/api_constants.dart';
import '../../../services/dio_service.dart';
import '../../../services/logger_service.dart';

class BankAccountRepository {
  BankAccountRepository({Dio? dio}) : _dio = dio ?? DioService.instance.client;

  final Dio _dio;

  Future<BankVerifyResponse> verifyBank({
    required String accountNo,
    required String ifsc,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.bankVerifyEndpoint,
        data: {
          'account_no': accountNo,
          'ifsc': ifsc,
        },
      );
      final payload = _asMap(response.data);
      return BankVerifyResponse.fromJson(payload);
    } catch (e, stackTrace) {
      logger.error(
        'Failed to verify bank account',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<BankAddResponse> addBank({
    required String userId,
    required String accountNo,
    required String ifsc,
    required String accountHolderName,
    required String bankName,
    required String referenceId,
    String? branchName,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.bankAddEndpoint,
        data: {
          'user_id': userId,
          'account_no': accountNo,
          'ifsc': ifsc,
          'account_holder_name': accountHolderName,
          'bank_name': bankName,
          'reference_id': referenceId,
          if (branchName != null && branchName.isNotEmpty)
            'branch_name': branchName,
        },
      );
      final payload = _asMap(response.data);
      return BankAddResponse.fromJson(payload);
    } catch (e, stackTrace) {
      logger.error(
        'Failed to add bank account',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

class BankVerifyResponse {
  const BankVerifyResponse({
    required this.status,
    required this.message,
    required this.creditorName,
    required this.accountNumber,
    required this.ifsc,
    required this.transactionReferenceNumber,
  });

  factory BankVerifyResponse.fromJson(Map<String, dynamic> json) {
    return BankVerifyResponse(
      status: (json['status'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      creditorName: (json['creditorName'] ?? '').toString(),
      accountNumber: (json['accountNumber'] ?? '').toString(),
      ifsc: (json['ifsc'] ?? '').toString(),
      transactionReferenceNumber:
          (json['transactionReferenceNumber'] ?? '').toString(),
    );
  }

  final String status;
  final String message;
  final String creditorName;
  final String accountNumber;
  final String ifsc;
  final String transactionReferenceNumber;

  bool get isSuccess => status.toUpperCase() == 'SUCCESS';
}

class BankAddResponse {
  const BankAddResponse({
    required this.status,
    required this.message,
    required this.accountNumber,
  });

  factory BankAddResponse.fromJson(Map<String, dynamic> json) {
    return BankAddResponse(
      status: json['status'] == true,
      message: (json['message'] ?? '').toString(),
      accountNumber: (json['account_number'] ?? '').toString(),
    );
  }

  final bool status;
  final String message;
  final String accountNumber;
}

Map<String, dynamic> _asMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is String && data.isNotEmpty) {
    final decoded = jsonDecode(data);
    if (decoded is Map<String, dynamic>) return decoded;
  }
  return <String, dynamic>{};
}
