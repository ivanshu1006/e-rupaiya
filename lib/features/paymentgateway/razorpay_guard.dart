import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../widgets/app_snackbar.dart';
import '../profile/controllers/profile_controller.dart';

class RazorpayGuard {
  static const pausedMessage =
      'Oops! Payments are paused right now. We’ll be back shortly.';

  static bool isPaused(WidgetRef ref) {
    return ref.read(profileControllerProvider).profile?.isRazorpayDisabled ??
        false;
  }

  static bool ensureNotPaused(WidgetRef ref) {
    if (!isPaused(ref)) return true;
    AppSnackbar.show(
      pausedMessage,
      type: AppSnackbarType.warning,
    );
    return false;
  }
}
