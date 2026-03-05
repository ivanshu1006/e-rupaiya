import 'dart:developer' as developer;
import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

import 'logger_service.dart';

class LocationService {
  LocationService._();

  static Future<void> initialize() async {
    await _requestPermission();
  }

  static Future<void> _requestPermission() async {
    final status = await Permission.locationWhenInUse.status;

    if (status.isGranted) {
      logger.info('Location permission already granted');
      return;
    }

    if (status.isPermanentlyDenied) {
      developer.log(
        'Location permission permanently denied',
        name: 'LocationService',
      );
      logger.info('Location permission permanently denied');
      return;
    }

    final result = await Permission.locationWhenInUse.request();

    final message = 'Location permission result: $result';
    developer.log(message, name: 'LocationService');
    logger.info(message);

    if (Platform.isAndroid && result.isGranted) {
      // Request precise location on Android 12+ (API 31+)
      final precise = await Permission.locationAlways.status;
      developer.log(
        'Precise location status: $precise',
        name: 'LocationService',
      );
    }
  }
}
