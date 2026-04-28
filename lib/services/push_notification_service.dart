import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';

import '../constants/routes_constant.dart';
import '../features/profile/repositories/profile_repository.dart';
import '../widgets/k_dialog.dart';
import 'logger_service.dart';
import 'notification_badge_service.dart';

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
  static String? _latestToken;
  static bool _initialized = false;
  static bool _permissionsRequested = false;
  static bool _uiReady = false;
  static String? _pendingLocation;
  static Object? _pendingExtra;

  static String? get latestToken => _latestToken;

  /// Call this once the app's `MaterialApp.router` is mounted (i.e. routing is ready).
  static void markUiReady() {
    _uiReady = true;
    _flushPendingNavigation();
  }

  static Future<void> initialize({bool requestPermissions = true}) async {
    if (_initialized) {
      if (requestPermissions) {
        await ensurePermissionsRequested();
      }
      return;
    }

    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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
      _latestToken = token;
      await _sendTokenToServer(token);
    }

    _messaging.onTokenRefresh.listen((newToken) async {
      _latestToken = newToken;
      await _sendTokenToServer(newToken);
    });

    _initialized = true;

    if (requestPermissions) {
      await ensurePermissionsRequested();
    }
  }

  static Future<void> ensurePermissionsRequested() async {
    if (_permissionsRequested) return;
    _permissionsRequested = true;
    await _requestPermissions();
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
        final payload = response.payload;
        if (payload == null || payload.trim().isEmpty) return;
        try {
          final decoded = jsonDecode(payload);
          if (decoded is Map) {
            final data = decoded['data'];
            _handleNotificationTap(
              data: data is Map
                  ? data.map((k, v) => MapEntry('$k', v))
                  : const <String, dynamic>{},
            );
          }
        } catch (e) {
          logger.error('Failed to parse local notification payload: $e');
        }
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
    _handleNotificationTap(
      data: message.data,
    );
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
      payload: jsonEncode({
        'title': notification.title,
        'body': notification.body,
        'data': message.data,
      }),
    );

    unawaited(NotificationBadgeService.refreshCount());
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

  static void _handleNotificationTap({
    required Map<String, dynamic> data,
  }) {
    final resolvedLocation = _resolveLocation(data: data);
    if (resolvedLocation == null) return;
    _navigateOrQueue(resolvedLocation);
  }

  static String? _resolveLocation({required Map<String, dynamic> data}) {
    final route = (data['route'] ?? data['screen'] ?? data['redirect'])
        ?.toString()
        .trim();
    if (route != null && route.isNotEmpty) {
      // Preferred: backend sends a full app route, e.g. "/mobile-prepaid".
      if (route.startsWith('/')) return route;
      // Backwards compat: allow shorthand identifiers.
      if (route == 'mobile_prepaid' || route == 'mobile-prepaid') {
        return RouteConstants.mobilePrepaid;
      }
      // Or a RouteConstants value itself.
      if (route == RouteConstants.mobilePrepaid) return route;
    }

    return null;
  }

  static void _navigateOrQueue(String location, {Object? extra}) {
    if (!_uiReady || navigatorKey.currentContext == null) {
      _pendingLocation = location;
      _pendingExtra = extra;
      logger.info('Queued navigation to $location (UI not ready yet).');
      return;
    }

    final context = navigatorKey.currentContext;
    if (context == null) return;
    try {
      context.go(location, extra: extra);
    } catch (e) {
      logger.error('Failed to navigate to $location: $e');
      _pendingLocation = location;
      _pendingExtra = extra;
    }
  }

  static void _flushPendingNavigation() {
    final location = _pendingLocation;
    if (!_uiReady || location == null) return;
    final context = navigatorKey.currentContext;
    if (context == null) return;
    final extra = _pendingExtra;
    _pendingLocation = null;
    _pendingExtra = null;
    try {
      context.go(location, extra: extra);
    } catch (e) {
      logger.error('Failed to flush pending navigation to $location: $e');
      _pendingLocation = location;
      _pendingExtra = extra;
    }
  }
}
