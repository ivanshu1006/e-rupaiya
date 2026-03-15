import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../constants/api_constants.dart';
import '../../../services/dio_service.dart';
import '../../../services/logger_service.dart';

class BankAccountsRepository {
  BankAccountsRepository({Dio? dio}) : _dio = dio ?? DioService.instance.client;

  final Dio _dio;

  Future<List<BankAccountEntry>> fetchAccounts() async {
    try {
      final response = await _dio.get(ApiConstants.bankAccountsEndpoint);
      final payload = _asMap(response.data);
      final data = payload['data'];
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(BankAccountEntry.fromJson)
            .toList();
      }
      return const <BankAccountEntry>[];
    } catch (e, stackTrace) {
      logger.error(
        'Failed to fetch bank accounts',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}

class BankAccountEntry {
  const BankAccountEntry({
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    required this.verified,
  });

  factory BankAccountEntry.fromJson(Map<String, dynamic> json) {
    return BankAccountEntry(
      bankName: (json['bank_name'] ?? '').toString(),
      accountNumber: (json['account_number'] ?? '').toString(),
      accountHolderName: (json['account_holder_name'] ?? '').toString(),
      verified: json['verified'] == true,
    );
  }

  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final bool verified;
}

Map<String, dynamic> _asMap(dynamic data) {
  if (data is Map<String, dynamic>) return data;
  if (data is String && data.isNotEmpty) {
    final decoded = jsonDecode(data);
    if (decoded is Map<String, dynamic>) return decoded;
  }
  return <String, dynamic>{};
}
