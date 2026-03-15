import 'package:flutter/services.dart';

class ScreenSecurityService {
  ScreenSecurityService._();

  static const MethodChannel _channel =
      MethodChannel('com.innoplix.erupaiya/screen_security');

  static Future<void> enableSecure() async {
    try {
      await _channel.invokeMethod('enableSecure');
    } catch (_) {}
  }

  static Future<void> disableSecure() async {
    try {
      await _channel.invokeMethod('disableSecure');
    } catch (_) {}
  }
}
