import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../services/logger_service.dart';

class Utils {
  static Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  static Future<String?> getAccessToken() {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    return secureStorage.read(key: 'accessToken');
  }

  static Future<String?> getTokenType() {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    return secureStorage.read(key: 'tokenType');
  }

  static Future<String?> getUserId() {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    return secureStorage.read(key: 'userId');
  }

  static Future<DateTime?> getAccessTokenExpiry() async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    final expiryValue = await secureStorage.read(key: 'tokenExpiresAt');
    if (expiryValue == null) {
      return null;
    }
    return DateTime.tryParse(expiryValue);
  }

  static Future<DateTime?> getRefreshTokenExpiry() async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    final expiryValue = await secureStorage.read(key: 'refreshTokenExpiresAt');
    if (expiryValue == null) {
      return null;
    }
    return DateTime.tryParse(expiryValue);
  }

  static Future<bool> checkAuthentication() async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    final accessToken = await secureStorage.read(key: 'accessToken');
    final tokenExpiry = await secureStorage.read(key: 'tokenExpiresAt');

    logger.info('Checking authentication');
    logger.info('accessToken: $accessToken');
    logger.info('tokenExpiresAt: $tokenExpiry');

    if (accessToken == null || tokenExpiry == null) {
      logger.info('User is not logged in');
      return false;
    }

    final expiryDateTime = DateTime.tryParse(tokenExpiry);
    if (expiryDateTime == null) {
      logger.info('User is not logged in');
      return false;
    }

    if (expiryDateTime.isAfter(DateTime.now())) {
      logger.info('User is logged in');
      return true;
    }

    logger.info('User is not logged in');
    return false; // User is not logged in
  }
}
