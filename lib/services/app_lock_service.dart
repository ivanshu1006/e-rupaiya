import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../features/auth/controllers/auth_controller.dart';
import '../widgets/k_dialog.dart';
import '../features/auth/views/app_lock_view.dart';

final appLockServiceProvider = Provider<AppLockService>((ref) {
  final service = AppLockService(ref);
  return service;
});

class AppLockService with WidgetsBindingObserver {
  AppLockService(this._ref);

  final Ref _ref;
  final Duration inactivityTimeout = const Duration(minutes: 1);

  Timer? _timer;
  bool _shouldLock = false;
  bool _isShowing = false;

  void init() {
    WidgetsBinding.instance.addObserver(this);
    _resetTimer();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
  }

  void onUserActivity() {
    _resetTimer();
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = Timer(inactivityTimeout, () {
      _shouldLock = true;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _shouldLock = true;
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
    _isShowing = false;
  }
}
