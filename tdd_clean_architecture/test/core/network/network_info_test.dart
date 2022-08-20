import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdd_clean_architecture/core/network/network_info.dart';

class MockInternetConnectionChecker extends Mock
    implements InternetConnectionChecker {}

void main() {
  late NetworkInfoImpl networkInfo;
  late MockInternetConnectionChecker mockInternetConnectionChecker;

  setUp(() {
    mockInternetConnectionChecker = MockInternetConnectionChecker();
    networkInfo = NetworkInfoImpl(mockInternetConnectionChecker);
  });
  group('isConnected', () {
    test('should forward the call to DataConnectionChecker.hasConnection',
        () async {
      final hasConnectionFuture = Future.value(true);

      when(() => mockInternetConnectionChecker.hasConnection)
          .thenAnswer((_) => hasConnectionFuture);

      final result = networkInfo.isConnected;

      verify(() => mockInternetConnectionChecker.hasConnection);
      expect(result, hasConnectionFuture);
    });
  });
}
