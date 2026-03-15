import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// import 'package:no_screenshot/no_screenshot.dart';

import 'router.dart';
import 'services/app_lock_service.dart';
import 'services/location_service.dart';
import 'services/push_notification_service.dart';
import 'widgets/app_snackbar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // NoScreenshot.instance.screenshotOff();
  await dotenv.load(fileName: '.env');
  await PushNotificationService.initialize();
  await LocationService.initialize();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final appLockService = ref.read(appLockServiceProvider);
    useEffect(() {
      appLockService.init();
      // ScreenSecurityService.enableSecure();
      return appLockService.dispose;
    }, const []);
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp.router(
        builder: (context, child) {
          return Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) => appLockService.onUserActivity(),
            child: child ?? const SizedBox.shrink(),
          );
        },
        scaffoldMessengerKey: AppSnackbar.messengerKey,
        title: 'E-Rupaiya',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          textTheme: GoogleFonts.plusJakartaSansTextTheme(),
          fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
          useMaterial3: true,
        ),
        routerConfig: router,
      ),
    );
  }
}
