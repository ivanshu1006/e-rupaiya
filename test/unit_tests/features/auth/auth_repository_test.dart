import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frappe_flutter_app/constants/api_constants.dart';
import 'package:frappe_flutter_app/features/auth/repositories/auth_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockHTTPClient extends Mock implements Dio {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late AuthRepository authRepository;
  late MockHTTPClient mockDioClient;
  late MockFlutterSecureStorage mockSecureStorage;

  setUp(() {
    mockDioClient = MockHTTPClient();
    mockSecureStorage = MockFlutterSecureStorage();
    authRepository = AuthRepository(
      dio: mockDioClient,
      secureStorage: mockSecureStorage,
    );
  });

  group('AuthRepository - login', () {
    test('stores tokens when login is successful', () async {
      const mobile = '9552529513';
      const pin = '1111';
      const responseData = {
        'success': true,
        'data': {
          'access_token': 'access-token',
          'refresh_token': 'refresh-token',
          'token_type': 'Bearer',
          'expires_in': 900,
        },
      };

      when(
        () => mockDioClient.post(
          ApiConstants.loginEndpoint,
          data: {'mobile': mobile, 'pin': pin},
        ),
      ).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ApiConstants.loginEndpoint),
        ),
      );

      when(
        () => mockSecureStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      await authRepository.login(mobile: mobile, pin: pin);

      verify(
        () => mockSecureStorage.write(
          key: 'accessToken',
          value: 'access-token',
        ),
      ).called(1);
      verify(
        () => mockSecureStorage.write(
          key: 'refreshToken',
          value: 'refresh-token',
        ),
      ).called(1);
      verify(
        () => mockSecureStorage.write(key: 'tokenType', value: 'Bearer'),
      ).called(1);
      verify(
        () => mockSecureStorage.write(
          key: 'tokenExpiresAt',
          value: any(named: 'value'),
        ),
      ).called(1);
      verify(() => mockSecureStorage.write(key: 'userId', value: mobile))
          .called(1);
    });

    test('throws when login fails', () async {
      const mobile = '9552529513';
      const pin = 'wrong_pin';

      const responseData = {
        'success': false,
        'message': 'Login failed',
      };

      when(
        () => mockDioClient.post(
          ApiConstants.loginEndpoint,
          data: {'mobile': mobile, 'pin': pin},
        ),
      ).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 401,
          requestOptions: RequestOptions(path: ApiConstants.loginEndpoint),
        ),
      );

      expect(
        () => authRepository.login(mobile: mobile, pin: pin),
        throwsException,
      );
    });
  });

  group('AuthRepository - logout', () {
    test('deletes all user-related keys from secure storage', () async {
      when(
        () => mockSecureStorage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async {});

      await authRepository.logout();

      verify(() => mockSecureStorage.delete(key: 'accessToken')).called(1);
      verify(() => mockSecureStorage.delete(key: 'refreshToken')).called(1);
      verify(() => mockSecureStorage.delete(key: 'tokenType')).called(1);
      verify(() => mockSecureStorage.delete(key: 'tokenExpiresAt')).called(1);
      verify(() => mockSecureStorage.delete(key: 'userId')).called(1);
      verifyNoMoreInteractions(mockSecureStorage);
    });
  });
}
