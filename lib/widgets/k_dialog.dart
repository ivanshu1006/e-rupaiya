import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../constants/app_colors.dart';

/// Global navigator key used by [KDialog] to show dialogs/sheets
/// without needing a BuildContext. Must be attached to the router.
final navigatorKey = GlobalKey<NavigatorState>();

final dialogProvider = Provider<KDialog>((ref) {
  return KDialog.instance;
});

class KDialog {
  static final KDialog instance = KDialog._();
  KDialog._();

  BuildContext get _context => navigatorKey.currentState!.overlay!.context;

  Future<void> openCupertinoSheet({
    required Widget dialog,
    bool barrierDismissible = true,
  }) async {
    showCupertinoModalPopup(
      context: _context,
      barrierDismissible: barrierDismissible,
      builder: (context) => dialog,
    );
  }

  Future<void> openDialog({
    required Widget dialog,
    bool barrierDismissible = true,
  }) async {
    showDialog(
      context: _context,
      barrierDismissible: barrierDismissible,
      builder: (context) => dialog,
    );
  }

  Future<void> openSheet({
    required Widget dialog,
    bool barrierDismissible = true,
  }) async {
    final context = _context;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (isMobile) {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) {
          return SafeArea(
            top: false,
            left: false,
            right: false,
            child: dialog,
          );
        },
      );
    } else {
      showDialog(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550),
              child: dialog,
            ),
          );
        },
      );
    }
  }

  Future<void> openConstraintsSheet({
    required Widget dialog,
    double? maxHeight,
  }) async {
    final context = _context;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: maxHeight ?? screenHeight * 0.65,
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          left: false,
          right: false,
          child: dialog,
        );
      },
    );
  }
}

class HeadingH extends StatelessWidget {
  const HeadingH({required this.title, this.color, super.key});

  final String title;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.textPrimary,
            ),
      ),
    );
  }
}
