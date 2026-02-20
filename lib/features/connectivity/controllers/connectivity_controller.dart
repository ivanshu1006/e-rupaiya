import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

final connectivityStatusProvider =
    StreamProvider.autoDispose<bool>((ref) async* {
  final checker = InternetConnectionChecker.createInstance();
  yield await checker.hasConnection;

  await for (final _ in Connectivity().onConnectivityChanged) {
    yield await checker.hasConnection;
  }
});
