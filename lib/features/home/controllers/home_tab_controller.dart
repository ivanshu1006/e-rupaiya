import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

final homeTabControllerProvider = Provider<PersistentTabController>((ref) {
  final controller = PersistentTabController(initialIndex: 0);
  ref.onDispose(controller.dispose);
  return controller;
});
