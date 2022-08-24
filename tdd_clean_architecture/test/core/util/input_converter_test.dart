import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdd_clean_architecture/core/util/input_converter.dart';

void main() {
  late InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });
  group('StringToUnsignedInt', () {
    test(
        'should return an integer when the string represents an unsigned integer',
        () async {
      const str = '123';

      final result = inputConverter.stringToUnsignedInteger(str);

      expect(result, const Right(123));
    });

    test('should return a failure when the string is not an integer', () {
      const str = 'abc';

      final result = inputConverter.stringToUnsignedInteger(str);

      expect(result, Left(InvalidInputFailure()));
    });

    test('should return a failure when the string is a negative integer', () {
      const str = '-123';

      final result = inputConverter.stringToUnsignedInteger(str);

      expect(result, Left(InvalidInputFailure()));
    });
  });
}
