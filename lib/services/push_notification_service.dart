import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../features/profile/repositories/profile_repository.dart';
import 'logger_service.dart';

const String _defaultChannelId = 'default_notifications';
const String _defaultChannelName = 'General Notifications';
const String _defaultChannelDescription = 'General app notifications.';

final FlutterLocalNotificationsPlugin _localNotifications =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  logger.info('FCM background message: ${message.messageId}');
}

class PushNotificationService {
  PushNotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _requestPermissions();
    await _initLocalNotifications();

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    final token = await _messaging.getToken();
    final tokenMessage = 'FCM token: $token';
    developer.log(tokenMessage, name: 'PushNotificationService');
    logger.info(tokenMessage);
    if (token != null && token.isNotEmpty) {
      await _sendTokenToServer(token);
    }

    _messaging.onTokenRefresh.listen((newToken) async {
      await _sendTokenToServer(newToken);
    });
  }

  static Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    logger.info('Notification permission: ${settings.authorizationStatus}');

    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
  }

  static Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        logger.info('Local notification tapped: ${response.payload}');
      },
    );

    const androidChannel = AndroidNotificationChannel(
      _defaultChannelId,
      _defaultChannelName,
      description: _defaultChannelDescription,
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    logger.info('FCM foreground message: ${message.messageId}');
    await _showLocalNotification(message);
  }

  static void _handleMessageOpenedApp(RemoteMessage message) {
    logger.info('FCM opened app message: ${message.messageId}');
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      _defaultChannelId,
      _defaultChannelName,
      channelDescription: _defaultChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.isNotEmpty ? message.data.toString() : null,
    );
  }

  static Future<void> _sendTokenToServer(String token) async {
    try {
      final response = await ProfileRepository().updateDeviceToken(token);
      final message =
          'Device token update: ${response.success} - ${response.message}';
      logger.info(message);
      developer.log(message, name: 'PushNotificationService');
    } catch (e, stackTrace) {
      logger.error(
        'Failed to update device token: $e',
        error: e,
        stackTrace: stackTrace,
      );
      developer.log(
        'Failed to update device token: $e',
        name: 'PushNotificationService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
