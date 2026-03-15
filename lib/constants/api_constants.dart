class ApiConstants {
  static const String baseUrl = 'https://test.erupaiya.com';

  static const String loginEndpoint = '$baseUrl/api/auth/login';
  static const String checkLoginEndpoint = '$baseUrl/api/auth/check-login';
  static const String verifyOtpEndpoint = '$baseUrl/api/auth/verify-otp';
  static const String refreshTokenEndpoint = '$baseUrl/api/auth/refresh';
  static const String registerEndpoint = '$baseUrl/api/auth/register';
  static const String setPinEndpoint = '$baseUrl/api/auth/set-pin';
  static const String requestForgotPinOtpEndpoint =
      '$baseUrl/api/auth/request-forgot-pin-otp';
  static const String forgotPinEndpoint = '$baseUrl/api/auth/forgot-pin';
  static const String pinLockEndpoint = '$baseUrl/api/auth/pin-lock';
  static const String shareDownloadReceiptEndpoint =
      '$baseUrl/api/bill/share-download-receipt';
  static const String quickActionsEndpoint = '$baseUrl/api/quick-actions';
  static const String quickActionsDueEndpoint =
      '$baseUrl/api/quick-actions/due';
  static const String profileEndpoint = '$baseUrl/api/user/profile';
  static const String profileUpdateEndpoint =
      '$baseUrl/api/user/profile/update';
  static const String profileUpdateDeviceTokenEndpoint =
      '$baseUrl/api/user/profile/update-device-token';
  static const String profileVerifyContactUpdateEndpoint =
      '$baseUrl/api/user/profile/verify-contact-update';
  static const String logoutEndpoint = '$baseUrl/api/auth/logout';
  static const String billersEndpoint = '$baseUrl/api/billers';
  static const String billerDetailsEndpoint = '$baseUrl/api/biller/details';
  static const String billerParamsEndpoint = '$baseUrl/api/biller/params';
  static const String billerIconBaseUrl = '$baseUrl/storage/billers';
  static const String offersBannerBaseUrl = '$baseUrl/storage/offers';
  static const String fetchBillEndpoint = '$baseUrl/api/bill/fetch';
  static const String payBillEndpoint = '$baseUrl/api/bill/pay';
  static const String prepaidCheckOperatorEndpoint =
      '$baseUrl/api/prepaid/checkOprators';
  static const String prepaidFetchOperatorsEndpoint =
      '$baseUrl/api/prepaid/fetchOprators';
  static const String prepaidFetchRegionsEndpoint =
      '$baseUrl/api/prepaid/getAllRegions';
  static const String prepaidFetchPlansEndpoint =
      '$baseUrl/api/prepaid/fetchPlans';
  static const String prepaidRechargeEndpoint = '$baseUrl/api/prepaid/recharge';
  static const String prepaidTransactionHistoryEndpoint =
      '$baseUrl/api/prepaid/transaction-history';
  static const String spinEndpoint = '$baseUrl/api/spin';
  static const String spinOptionsEndpoint = '$baseUrl/api/spin/options';
  static const String offersEndpoint = '$baseUrl/api/offers';
  static const String notificationsEndpoint = '$baseUrl/api/notifications';
  static const String referralGenerateLinkEndpoint =
      '$baseUrl/api/referral/generate-link';
  static const String referralTrackEndpoint = '$baseUrl/api/referral/track';
  static const String referralWalletSummaryEndpoint =
      '$baseUrl/api/wallet/summary';
  static const String referralMilestonesEndpoint =
      '$baseUrl/api/referral/milestones';
  static const String withdrawEcoinsEndpoint =
      '$baseUrl/api/wallet/withdraw-ecoins';
  static const String bankVerifyEndpoint = '$baseUrl/api/bank/verify';
  static const String bankAddEndpoint = '$baseUrl/api/bank/add';
  static const String bankAccountsEndpoint = '$baseUrl/api/bank/accounts';
  static const String kycPanVerifyEndpoint = '$baseUrl/api/kyc/pan/verify';
  static const String kycAadhaarSendOtpEndpoint =
      '$baseUrl/api/kyc/aadhaar/send-otp';
  static const String kycAadhaarVerifyOtpEndpoint =
      '$baseUrl/api/kyc/aadhaar/verify-otp';
  static String notificationReadEndpoint(String id) =>
      '$baseUrl/api/notification/read/$id';
}
