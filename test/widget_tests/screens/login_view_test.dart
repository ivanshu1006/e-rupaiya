// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:frappe_flutter_app/constants/routes_constant.dart';
// import 'package:frappe_flutter_app/features/auth/controllers/auth_controller.dart';
// import 'package:frappe_flutter_app/features/auth/repositories/auth_repository.dart';
// import 'package:frappe_flutter_app/features/auth/views/login_view.dart';
// import 'package:frappe_flutter_app/widgets/custom_elevated_button.dart';
// import 'package:frappe_flutter_app/widgets/snack_bar.dart';
// import 'package:go_router/go_router.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:package_info_plus/package_info_plus.dart';

// class MockAuthRepository extends Mock implements AuthRepository {}

// void main() {
//   late MockAuthRepository mockAuthRepository;

//   setUp(() {
//     mockAuthRepository = MockAuthRepository();
//     PackageInfo.setMockInitialValues(
//       appName: 'appName',
//       packageName: 'packageName',
//       version: '1.0.0',
//       buildNumber: '1',
//       buildSignature: 'signature',
//     );
//   });

//   Widget createTestWidget(Widget child) {
//     return ProviderScope(
//       overrides: [
//         authControllerProvider.overrideWith(
//           (ref) => AuthController(
//             repository: mockAuthRepository,
//             shouldCheckInitialAuth: false,
//           ),
//         ),
//       ],
//       child: MaterialApp(
//         scaffoldMessengerKey: SnackbarGlobal.key,
//         home: _TestHarness(child: child),
//       ),
//     );
//   }

//   Widget createRouterTestWidget(GoRouter router) {
//     return ProviderScope(
//       overrides: [
//         authControllerProvider.overrideWith(
//           (ref) => AuthController(
//             repository: mockAuthRepository,
//             shouldCheckInitialAuth: false,
//           ),
//         ),
//       ],
//       child: MaterialApp.router(
//         scaffoldMessengerKey: SnackbarGlobal.key,
//         routerConfig: router,
//       ),
//     );
//   }

//   group('LoginView Tests', () {
//     testWidgets('renders login form correctly', (tester) async {
//       await tester.pumpWidget(createTestWidget(const LoginView()));

//       expect(find.byType(CustomElevatedButton), findsOneWidget);
//     });

//     testWidgets('shows snackbar when mobile is empty', (tester) async {
//       await tester.pumpWidget(createTestWidget(const LoginView()));

//       await tester.tap(find.byType(CustomElevatedButton));
//       await tester.pump();

//       expect(find.text('Please enter mobile number'), findsOneWidget);
//     });

//     testWidgets('navigates to OTP view on valid mobile input', (tester) async {
//       const phone = '9876543210';
//       var navigatedToOtp = false;

//       final router = GoRouter(
//         initialLocation: '/',
//         routes: [
//           GoRoute(
//             path: '/',
//             builder: (context, state) => const _TestHarness(
//               child: LoginView(),
//             ),
//           ),
//           GoRoute(
//             path: RouteConstants.otp,
//             builder: (context, state) {
//               navigatedToOtp = true;
//               return const _TestHarness(child: SizedBox());
//             },
//           ),
//         ],
//       );

//       await tester.pumpWidget(createRouterTestWidget(router));

//       await tester.enterText(find.byType(TextFormField).first, phone);
//       await tester.tap(find.byType(CustomElevatedButton));
//       await tester.pumpAndSettle();

//       expect(navigatedToOtp, isTrue);
//     });
//   });
// }

// class _TestHarness extends StatelessWidget {
//   const _TestHarness({required this.child});

//   final Widget child;

//   @override
//   Widget build(BuildContext context) {
//     ScreenUtil.init(
//       context,
//       designSize: const Size(375, 812),
//     );
//     return Scaffold(
//       body: MediaQuery(
//         data: MediaQuery.of(context).copyWith(),
//         child: child,
//       ),
//     );
//   }
// }
