import 'package:flutter/services.dart';

class PhoneHintService {
  PhoneHintService._();

  static const MethodChannel _channel =
      MethodChannel('com.innoplix.erupaiya/phone_hint');

  static Future<String?> getPhoneNumberHint() async {
    try {
      final result = await _channel.invokeMethod<String>('getPhoneNumberHint');
      final value = result?.trim();
      return (value == null || value.isEmpty) ? null : value;
    } on PlatformException {
      return null;
    } catch (_) {
      return null;
    }
  }
}

