import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../features/auth/controllers/auth_controller.dart';
import '../features/auth/views/app_lock_view.dart';
import '../widgets/k_dialog.dart';

final appLockServiceProvider = Provider<AppLockService>((ref) {
  final service = AppLockService(ref);
  return service;
});

class AppLockService with WidgetsBindingObserver {
  AppLockService(this._ref);

  final Ref _ref;
  final Duration inactivityTimeout = const Duration(minutes: 1);
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
  }

  void _resetTimer() {
    _timer?.cancel();
    _lastActivity = DateTime.now();
    _timer = Timer(inactivityTimeout, () {
      _shouldLock = true;
    });
  }

  Future<void> _restoreLockState() async {
    try {
      final lockOnNextOpen =
          (await _storage.read(key: _lockOnNextOpenKey)) == 'true';
      final lastActiveRaw = await _storage.read(key: _lastActiveKey);
      if (lockOnNextOpen) {
        _shouldLock = true;
        return;
      }
      if (lastActiveRaw != null && lastActiveRaw.isNotEmpty) {
        final lastActive = DateTime.tryParse(lastActiveRaw);
        if (lastActive != null) {
          final idleFor = DateTime.now().difference(lastActive);
          _shouldLock = idleFor >= inactivityTimeout;
        }
      }
    } catch (_) {}
  }

  Future<void> _persistBackgroundState() async {
    try {
      await _storage.write(
        key: _lastActiveKey,
        value: DateTime.now().toIso8601String(),
      );
      await _storage.write(key: _lockOnNextOpenKey, value: 'true');
    } catch (_) {}
  }

  Future<void> _clearNextOpenLock() async {
    try {
      await _storage.write(key: _lockOnNextOpenKey, value: 'false');
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _shouldLock = true;
      _persistBackgroundState();
    }
    if (state == AppLifecycleState.resumed) {
      _showLockIfNeeded();
      _resetTimer();
    }
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
    await navigator!.push(
      MaterialPageRoute(
        builder: (_) => const AppLockView(),
        fullscreenDialog: true,
      ),
    );
    _shouldLock = false;
    _clearNextOpenLock();
    _isShowing = false;
  }
}
