import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../features/auth/controllers/auth_controller.dart';
import '../features/auth/views/app_lock_view.dart';
import '../services/logger_service.dart';
import '../widgets/k_dialog.dart';

final appLockServiceProvider = Provider<AppLockService>((ref) {
  final service = AppLockService(ref);
  return service;
});

class AppLockService with WidgetsBindingObserver {
  AppLockService(this._ref);

  final Ref _ref;
  final Duration inactivityTimeout = const Duration(minutes: 2);
  static const _lastActiveKey = 'appLockLastActiveAt';
  static const _lockOnNextOpenKey = 'appLockOnNextOpen';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Timer? _timer;
  bool _shouldLock = false;
  bool _isShowing = false;
  DateTime _lastActivity = DateTime.now();

  void init() {
    WidgetsBinding.instance.addObserver(this);
    _resetTimer();
    _restoreLockState();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
  }

  void onUserActivity() {
    _resetTimer();
    _shouldLock = false;
    logger.debug('AppLock: user activity, reset timer');
  }

  void _resetTimer() {
    _timer?.cancel();
    _lastActivity = DateTime.now();
    _timer = Timer(inactivityTimeout, () {
      _shouldLock = true;
      logger.debug('AppLock: inactivity timeout reached, shouldLock=true');
    });
  }

  Future<void> _restoreLockState() async {
    try {
      final lockOnNextOpen =
          (await _storage.read(key: _lockOnNextOpenKey)) == 'true';
      final lastActiveRaw = await _storage.read(key: _lastActiveKey);
      if (lockOnNextOpen) {
        _shouldLock = true;
        logger.debug('AppLock: lockOnNextOpen=true, shouldLock=true');
        return;
      }
      if (lastActiveRaw != null && lastActiveRaw.isNotEmpty) {
        final lastActive = DateTime.tryParse(lastActiveRaw);
        if (lastActive != null) {
          final idleFor = DateTime.now().difference(lastActive);
          _shouldLock = idleFor >= inactivityTimeout;
          logger.debug(
            'AppLock: restored lastActive=$lastActive idleFor=${idleFor.inSeconds}s shouldLock=$_shouldLock',
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _persistBackgroundTimestamp() async {
    try {
      await _storage.write(
        key: _lastActiveKey,
        value: DateTime.now().toIso8601String(),
      );
      logger.debug('AppLock: persisted background timestamp');
    } catch (_) {}
  }

  Future<void> _markLockOnNextOpen() async {
    try {
      await _storage.write(key: _lockOnNextOpenKey, value: 'true');
      logger.debug('AppLock: mark lock on next open');
    } catch (_) {}
  }

  Future<void> _clearNextOpenLock() async {
    try {
      await _storage.write(key: _lockOnNextOpenKey, value: 'false');
      logger.debug('AppLock: clear lock on next open');
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _persistBackgroundTimestamp();
      _shouldLock = false;
      logger.debug('AppLock: paused');
    }
    if (state == AppLifecycleState.detached) {
      _persistBackgroundTimestamp();
      _markLockOnNextOpen();
      logger.debug('AppLock: detached');
    }
    // Avoid locking on brief inactive states (e.g., notification shade).
    if (state == AppLifecycleState.resumed) {
      logger.debug('AppLock: resumed');
      unawaited(_handleResume());
    }
  }

  Future<void> _handleResume() async {
    await _restoreLockState();
    await _showLockIfNeeded();
    _resetTimer();
  }

  Future<void> _showLockIfNeeded() async {
    if (_isShowing) return;
    final authState = _ref.read(authControllerProvider);
    if (!authState.isAuthenticated) return;
    if (!_shouldLock) return;
    final navigator = navigatorKey.currentState;
    final context = navigator?.overlay?.context;
    if (context == null) return;
    _isShowing = true;
    logger.debug('AppLock: showing lock screen');
    await navigator!.push(
      MaterialPageRoute(
        builder: (_) => const AppLockView(),
        fullscreenDialog: true,
      ),
    );
    _shouldLock = false;
    await _persistBackgroundTimestamp();
    _clearNextOpenLock();
    _isShowing = false;
    logger.debug('AppLock: lock screen dismissed');
  }
}
