import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:e_rupaiya/features/home/models/quick_actions_model.dart';

import '../../../constants/api_constants.dart';
import '../../../services/dio_service.dart';
import '../../../services/logger_service.dart';
import '../models/quick_action_model.dart';

class HomeRepository {
  HomeRepository({Dio? dio}) : _dio = dio ?? DioService.instance.client;

  final Dio _dio;

  Future<List<QuickActionCategory>> fetchQuickActions({String? search}) async {
    try {
      final response = await _dio.get(
        ApiConstants.quickActionsEndpoint,
        queryParameters:
            (search == null || search.isEmpty) ? null : {'search': search},
      );
      final payload = response.data as Map<String, dynamic>?;
      final success = payload?['success'] == true;
      if (!success) {
        final message =
            payload?['message'] as String? ?? 'Failed to fetch quick actions';
        throw Exception(message);
      }
      final dataList = payload?['data'] as List<dynamic>? ?? [];
      return dataList
          .map((e) => QuickActionCategory.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      logger.error('Failed to fetch quick actions: $e', error: e);
      rethrow;
    }
  }

  Future<QuickActionModel> fetchAllQuickAction(String userId) async {
    try {
      final response = await _dio.get(
        ApiConstants.quickActionsDueEndpoint,
        queryParameters: {'user_id': 1},
      );

      final payload = response.data;
      Map<String, dynamic> json;
      if (payload is String) {
        json = jsonDecode(payload) as Map<String, dynamic>;
      } else if (payload is Map<String, dynamic>) {
        json = payload;
      } else {
        json = Map<String, dynamic>.from(payload as Map);
      }
      return QuickActionModel.fromJson(json);
    } catch (e) {
      logger.error('Failed to fetch all quick actions: $e', error: e);
      rethrow;
    }
  }

  Future<List<Data>> fetchCreditCardActions(String userId) async {
    try {
      final response = await _dio.get(
        ApiConstants.quickActionsDueEndpoint,
        queryParameters: {
          'user_id': 1,
          'payment_type': 'Credit Card',
        },
      );
      final payload = response.data;
      Map<String, dynamic> json;
      if (payload is String) {
        json = jsonDecode(payload) as Map<String, dynamic>;
      } else if (payload is Map<String, dynamic>) {
        json = payload;
      } else {
        json = Map<String, dynamic>.from(payload as Map);
      }
      return QuickActionModel.fromJson(json).data ?? [];
    } catch (e) {
      logger.error('Failed to fetch credit card actions: $e', error: e);
      rethrow;
    }
  }

  Future<List<Data>> fetchRechargeActions(String userId) async {
    try {
      final response = await _dio.get(
        ApiConstants.quickActionsDueEndpoint,
        queryParameters: {
          'user_id': 1,
          'payment_type': 'RECHARGE',
        },
      );
      final payload = response.data;
      Map<String, dynamic> json;
      if (payload is String) {
        json = jsonDecode(payload) as Map<String, dynamic>;
      } else if (payload is Map<String, dynamic>) {
        json = payload;
      } else {
        json = Map<String, dynamic>.from(payload as Map);
      }
      return QuickActionModel.fromJson(json).data ?? [];
    } catch (e) {
      logger.error('Failed to fetch recharge actions: $e', error: e);
      rethrow;
    }
  }
}
