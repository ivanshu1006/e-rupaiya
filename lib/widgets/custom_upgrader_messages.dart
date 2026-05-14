import 'package:upgrader/upgrader.dart';

class CustomUpgraderMessages extends UpgraderMessages {
  @override
  String message(UpgraderMessage messageKey) {
    switch (messageKey) {
      case UpgraderMessage.title:
        return 'Update available';
      case UpgraderMessage.body:
        return 'A newer version of eRupaiya is available. Please update to continue with the best experience.';
      case UpgraderMessage.buttonTitleUpdate:
        return 'Update now';
      case UpgraderMessage.buttonTitleLater:
        return 'Later';
      case UpgraderMessage.buttonTitleIgnore:
        return 'Ignore';
      case UpgraderMessage.prompt:
        return 'Would you like to update now?';
      case UpgraderMessage.releaseNotes:
        return 'What’s new';
    }
  }
}

