import 'package:dio/dio.dart';

import '../../../constants/api_constants.dart';
import '../../../services/dio_service.dart';
import '../../../services/logger_service.dart';
import '../models/offer_model.dart';

class OffersRepository {
  OffersRepository({Dio? dio}) : _dio = dio ?? DioService.instance.client;

  final Dio _dio;

  Future<List<OfferModel>> fetchOffers(String userId) async {
    try {
      final response = await _dio.get(
        ApiConstants.offersEndpoint,
        queryParameters: {'user_id': userId},
      );
      final payload = response.data as Map<String, dynamic>? ?? {};
      final data = payload['offers'];
      if (data is List) {
        return data
            .map(
              (item) => OfferModel.fromApi(
                item as Map<String, dynamic>? ?? {},
              ),
            )
            .toList();
      }
      return [];
    } catch (e, stackTrace) {
      logger.error(
        'Failed to fetch offers',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
