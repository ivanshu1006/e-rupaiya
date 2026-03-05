import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'constants/routes_constant.dart';
import 'features/auth/controllers/auth_controller.dart';
import 'features/auth/models/auth_state.dart';
import 'features/auth/views/login_view.dart';
import 'features/auth/views/otp_success_view.dart';
import 'features/auth/views/otp_verification_view.dart';
import 'features/auth/views/pin_setup_view.dart';
import 'features/auth/views/splash_view.dart';
import 'features/home/views/home_view.dart';
import 'features/home/views/notifications_screen.dart';
import 'features/mobile_prepaid/views/mobile_prepaid_view.dart';
import 'features/mobile_prepaid/views/mobile_recent_recharges_view.dart';
import 'features/mobile_prepaid/models/recharge_quick_action_payload.dart';
import 'features/onboarding/views/aadhaar_verification_view.dart';
import 'features/onboarding/views/kyc_overview_view.dart';
import 'features/onboarding/views/language_selection_view.dart';
import 'features/onboarding/views/pan_verification_view.dart';
import 'features/onboarding/views/verification_result_view.dart';
import 'features/home/views/quick_actions_view.dart';
import 'features/profile/views/about_us_screen.dart';
import 'features/profile/views/faq_screen.dart';
import 'features/profile/views/help_center_chat_screen.dart';
import 'features/profile/views/help_support_screen.dart';
import 'features/profile/views/my_qr_screen.dart';
import 'features/profile/views/transaction_detail_screen.dart';
import 'features/profile/views/transaction_history_screen.dart';
import 'features/profile/views/terms_privacy_screen.dart';
import 'features/profile/views/offers_view.dart';
import 'features/services/views/biller_detail_view.dart';
import 'features/services/views/biller_listing_view.dart';
import 'features/services/views/credit_card_intro_view.dart';
import 'features/services/views/credit_card_listing_view.dart';
import 'features/services/views/credit_card_my_cards_view.dart';
import 'features/spinandear/views/spin_and_win_view.dart';
import 'services/logger_service.dart';
import 'widgets/k_dialog.dart';
import 'features/profile/models/transaction_item.dart';
import 'features/services/models/biller_detail_args.dart';
import 'features/services/models/biller_model.dart';

final routerProvider = Provider<GoRouter>(
  (ref) {
    final router = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: RouteConstants.splash,
      redirect: (context, state) {
        logger.info('Redirecting to ${state.matchedLocation}');
        final authState = ref.read(authControllerProvider);

        // While still checking stored tokens, don't redirect.
        if (authState.isLoading) return null;

        final isAuthenticated = authState.isAuthenticated;
        final location = state.matchedLocation;

        // Auth screens that unauthenticated users may visit.
        const authRoutes = [
          RouteConstants.splash,
          RouteConstants.login,
          RouteConstants.register,
          RouteConstants.otp,
          RouteConstants.otpSuccess,
          RouteConstants.addPin,
        ];
        final isOnAuthRoute = authRoutes.contains(location);

        // If authenticated and on an auth screen → send to home.
        if (isAuthenticated && isOnAuthRoute) {
          return RouteConstants.home;
        }

        // If not authenticated and on a protected screen → send to login.
        if (!isAuthenticated && !isOnAuthRoute) {
          return RouteConstants.login;
        }

        return null;
      },
      routes: <GoRoute>[
        GoRoute(
          path: RouteConstants.splash,
          builder: (context, state) => const SplashView(),
        ),
        GoRoute(
          path: RouteConstants.home,
          builder: (context, state) => const HomeView(),
        ),
        GoRoute(
          path: RouteConstants.login,
          builder: (context, state) => const LoginView(),
        ),
        GoRoute(
          path: RouteConstants.register,
          builder: (context, state) => const LoginView(),
        ),
        GoRoute(
          path: RouteConstants.otp,
          builder: (context, state) => OtpVerificationView(
            phoneNumber: state.extra as String?,
          ),
        ),
        GoRoute(
          path: RouteConstants.otpSuccess,
          builder: (context, state) => const OtpSuccessView(),
        ),
        GoRoute(
          path: RouteConstants.addPin,
          builder: (context, state) => const PinSetupView(),
        ),
        GoRoute(
          path: RouteConstants.languageSelection,
          builder: (context, state) => const LanguageSelectionView(),
        ),
        GoRoute(
          path: RouteConstants.kycOverview,
          builder: (context, state) => KycOverviewView(
            selectedLanguage: state.extra as String?,
          ),
        ),
        GoRoute(
          path: RouteConstants.panVerification,
          builder: (context, state) => const PanVerificationView(),
        ),
        GoRoute(
          path: RouteConstants.aadhaarVerification,
          builder: (context, state) => const AadhaarVerificationView(),
        ),
        GoRoute(
          path: RouteConstants.verificationResult,
          builder: (context, state) => VerificationResultView(
            isSuccess: state.extra as bool? ?? false,
          ),
        ),
        GoRoute(
          path: RouteConstants.billerListing,
          builder: (context, state) => BillerListingView(
            categoryName: state.extra as String? ?? '',
          ),
        ),
        GoRoute(
          path: RouteConstants.billerDetail,
          builder: (context, state) {
            final extra = state.extra;
            BillerDetailArgs? args;
            if (extra is BillerDetailArgs) {
              args = extra;
            } else if (extra is Biller) {
              args = BillerDetailArgs(biller: extra, isCreditCard: false);
            }
            return BillerDetailView(args: args);
          },
        ),
        GoRoute(
          path: RouteConstants.creditCardIntro,
          builder: (context, state) => const CreditCardIntroView(),
        ),
        GoRoute(
          path: RouteConstants.creditCardListing,
          builder: (context, state) => const CreditCardListingView(),
        ),
        GoRoute(
          path: RouteConstants.creditCardMyCards,
          builder: (context, state) => const CreditCardMyCardsView(),
        ),
        GoRoute(
          path: RouteConstants.spinAndWin,
          builder: (context, state) => const SpinAndWinView(),
        ),
        GoRoute(
          path: RouteConstants.mobileRecentRecharges,
          builder: (context, state) => const MobileRecentRechargesView(),
        ),
        GoRoute(
          path: RouteConstants.mobilePrepaid,
          builder: (context, state) => MobilePrepaidView(
            quickAction: state.extra as RechargeQuickActionPayload?,
          ),
        ),
        GoRoute(
          path: RouteConstants.aboutUs,
          builder: (context, state) => const AboutUsScreen(),
        ),
        GoRoute(
          path: RouteConstants.termsPrivacy,
          builder: (context, state) => const TermsPrivacyScreen(),
        ),
        GoRoute(
          path: RouteConstants.helpSupport,
          builder: (context, state) => const HelpSupportScreen(),
        ),
        GoRoute(
          path: RouteConstants.helpCenterChat,
          builder: (context, state) => const HelpCenterChatScreen(),
        ),
        GoRoute(
          path: RouteConstants.faq,
          builder: (context, state) => const FaqScreen(),
        ),
        GoRoute(
          path: RouteConstants.transactions,
          builder: (context, state) => const TransactionHistoryScreen(),
        ),
        GoRoute(
          path: RouteConstants.transactionDetail,
          builder: (context, state) => TransactionDetailScreen(
            item: state.extra as TransactionItem?,
          ),
        ),
        GoRoute(
          path: RouteConstants.notifications,
          builder: (context, state) => const NotificationsScreen(),
        ),
        GoRoute(
          path: RouteConstants.myQr,
          builder: (context, state) => const MyQrScreen(),
        ),
        GoRoute(
          path: RouteConstants.quickActions,
          builder: (context, state) => const QuickActionsView(),
        ),
        GoRoute(
          path: RouteConstants.offers,
          builder: (context, state) => const OffersView(),
        ),
      ],
    );

    ref.listen<AuthState>(
      authControllerProvider,
      (_, __) => router.refresh(),
    );

    return router;
  },
);
