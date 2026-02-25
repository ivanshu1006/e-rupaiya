class ApiConstants {
  static const String baseUrl = 'https://test.erupaiya.com';

  static const String loginEndpoint = '$baseUrl/api/auth/login';
  static const String checkLoginEndpoint = '$baseUrl/api/auth/check-login';
  static const String verifyOtpEndpoint = '$baseUrl/api/auth/verify-otp';
  static const String registerEndpoint = '$baseUrl/api/auth/register';
  static const String setPinEndpoint = '$baseUrl/api/auth/set-pin';
  static const String quickActionsEndpoint = '$baseUrl/api/quick-actions';
  static const String quickActionsDueEndpoint =
      '$baseUrl/api/quick-actions/due';
  static const String profileEndpoint = '$baseUrl/api/user/profile';
  static const String profileUpdateEndpoint =
      '$baseUrl/api/user/profile/update';
  static const String profileVerifyContactUpdateEndpoint =
      '$baseUrl/api/user/profile/verify-contact-update';
  static const String logoutEndpoint = '$baseUrl/api/auth/logout';
  static const String billersEndpoint = '$baseUrl/api/billers';
  static const String billerDetailsEndpoint = '$baseUrl/api/biller/details';
  static const String billerParamsEndpoint = '$baseUrl/api/biller/params';
  static const String fetchBillEndpoint = '$baseUrl/api/bill/fetch';
  static const String payBillEndpoint = '$baseUrl/api/bill/pay';
  static const String prepaidCheckOperatorEndpoint =
      '$baseUrl/api/prepaid/checkOprators';
  static const String prepaidFetchPlansEndpoint =
      '$baseUrl/api/prepaid/fetchPlans';
  static const String prepaidRechargeEndpoint = '$baseUrl/api/prepaid/recharge';
  static const String spinEndpoint = '$baseUrl/api/spin';
  static const String spinOptionsEndpoint = '$baseUrl/api/spin/options';
}
