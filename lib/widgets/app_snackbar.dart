import 'package:e_rupaiya/constants/app_colors.dart';
import 'package:flutter/material.dart';

import 'k_dialog.dart';

class AppSnackbar {
  static final messengerKey = GlobalKey<ScaffoldMessengerState>();
  static OverlayEntry? _currentEntry;
  static bool _pending = false;

  static void show(
    String message, {
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 2),
    SnackBarBehavior? behavior,
    EdgeInsetsGeometry? margin,
    AppSnackbarType type = AppSnackbarType.info,
  }) {
    final context = navigatorKey.currentContext ?? messengerKey.currentContext;
    if (context == null) return;

    OverlayState? overlay;
    try {
      overlay = navigatorKey.currentState?.overlay ??
          Overlay.of(context, rootOverlay: true);
    } catch (_) {
      overlay = null;
    }

    if (overlay == null) {
      if (!_pending) {
        _pending = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _pending = false;
          show(
            message,
            backgroundColor: backgroundColor,
            textColor: textColor,
            duration: duration,
            behavior: behavior,
            margin: margin,
          );
        });
      }
      return;
    }

    _currentEntry?.remove();
    final resolved = _SnackbarTheme.resolve(
      type,
      backgroundOverride: backgroundColor,
      textOverride: textColor,
    );

    _currentEntry = OverlayEntry(
      builder: (_) => _TopSnackBar(
        message: message,
        backgroundColor: resolved.background,
        textColor: resolved.text,
        icon: resolved.icon,
        duration: duration,
        onDismissed: () {
          _currentEntry?.remove();
          _currentEntry = null;
        },
      ),
    );

    overlay.insert(_currentEntry!);
  }
}

class _TopSnackBar extends StatefulWidget {
  const _TopSnackBar({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    required this.icon,
    required this.duration,
    required this.onDismissed,
  });

  final String message;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;
  final Duration duration;
  final VoidCallback onDismissed;

  @override
  State<_TopSnackBar> createState() => _TopSnackBarState();
}

class _TopSnackBarState extends State<_TopSnackBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
      reverseDuration: const Duration(milliseconds: 320),
    );
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.35),
      end: Offset.zero,
    ).animate(curve);
    _fade = Tween<double>(begin: 0, end: 1).animate(curve);
    _scale = Tween<double>(begin: 0.96, end: 1).animate(curve);
    _glow = Tween<double>(begin: 0.2, end: 1).animate(curve);

    _controller.forward();
    Future.delayed(widget.duration, _hide);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _hide() async {
    if (!mounted) return;
    await _controller.reverse();
    if (mounted) widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final safeTop = topPadding + 10;
    return Positioned(
      top: safeTop,
      left: 16,
      right: 16,
      child: IgnorePointer(
        ignoring: false,
        child: SlideTransition(
          position: _slide,
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: AnimatedBuilder(
                animation: _glow,
                builder: (context, _) {
                  return Material(
                    color: Colors.transparent,
                    child: GestureDetector(
                      onTap: _hide,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          final sheenX = (width + 120) * _controller.value - 60;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.backgroundColor.withOpacity(0.98),
                                  widget.backgroundColor.withOpacity(0.9),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.backgroundColor
                                      .withOpacity(0.25 * _glow.value),
                                  blurRadius: 26,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 1,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  top: 8,
                                  bottom: 8,
                                  child: Container(
                                    width: 4,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withOpacity(0.55),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -40,
                                  left: sheenX,
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.white.withOpacity(0.08),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.12),
                                          blurRadius: 24,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.18),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        widget.icon,
                                        color: widget.textColor.withOpacity(0.95),
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        widget.message,
                                        style: TextStyle(
                                          color: widget.textColor,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14.5,
                                          height: 1.25,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum AppSnackbarType { info, success, error, warning }

class _SnackbarTheme {
  const _SnackbarTheme({
    required this.background,
    required this.text,
    required this.icon,
  });

  final Color background;
  final Color text;
  final IconData icon;

  static _SnackbarTheme resolve(
    AppSnackbarType type, {
    Color? backgroundOverride,
    Color? textOverride,
  }) {
    if (backgroundOverride != null || textOverride != null) {
      return _SnackbarTheme(
        background: backgroundOverride ?? AppColors.primary,
        text: textOverride ?? Colors.white,
        icon: _iconFor(type),
      );
    }
    switch (type) {
      case AppSnackbarType.success:
        return _SnackbarTheme(
          background: const Color(0xFF1E8E5A),
          text: Colors.white,
          icon: Icons.check_circle_outline,
        );
      case AppSnackbarType.error:
        return _SnackbarTheme(
          background: const Color(0xFFC62828),
          text: Colors.white,
          icon: Icons.error_outline,
        );
      case AppSnackbarType.warning:
        return _SnackbarTheme(
          background: const Color(0xFFF57C00),
          text: Colors.white,
          icon: Icons.warning_amber_outlined,
        );
      case AppSnackbarType.info:
      default:
        return _SnackbarTheme(
          background: AppColors.primary,
          text: Colors.white,
          icon: Icons.notifications_active_outlined,
        );
    }
  }

  static IconData _iconFor(AppSnackbarType type) {
    switch (type) {
      case AppSnackbarType.success:
        return Icons.check_circle_outline;
      case AppSnackbarType.error:
        return Icons.error_outline;
      case AppSnackbarType.warning:
        return Icons.warning_amber_outlined;
      case AppSnackbarType.info:
      default:
        return Icons.notifications_active_outlined;
    }
  }
}
