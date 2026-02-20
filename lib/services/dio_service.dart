import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import 'dio_interceptors.dart';

class DioService {
  // Private static instance
  static DioService? _instance;

  // Private late Dio instance
  late Dio _dio;

  // Private constructor
  DioService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 5000),
        receiveTimeout: const Duration(seconds: 3000),
      ),
    );
    _dio.interceptors.add(DioInterceptors());
  }

  // Singleton getter
  static DioService get instance {
    _instance ??= DioService._internal();
    return _instance!;
  }

  // Getter for the Dio client
  Dio get client => _dio;
}
