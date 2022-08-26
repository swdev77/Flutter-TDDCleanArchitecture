import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tdd_clean_architecture/core/error/failures.dart';
import 'package:tdd_clean_architecture/core/usecases/usecase.dart';
import 'package:tdd_clean_architecture/core/util/input_converter.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:tdd_clean_architecture/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:tdd_clean_architecture/features/number_trivia/presentation/bloc/bloc/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

class FakeParams extends Fake implements Params {}

class FakeNoParams extends Fake implements NoParams {}

void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUpAll(() {
    registerFallbackValue(FakeParams());
    registerFallbackValue(FakeNoParams());
  });

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      concrete: mockGetConcreteNumberTrivia,
      random: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  blocTest<NumberTriviaBloc, NumberTriviaState>(
    'initialState should be Empty',
    build: () {
      return bloc;
    },
    expect: () => [],
  );

  group('GetTriviaForConcreteNumber', () {
    const numberString = '1';
    final numberParsed = int.parse(numberString);
    const numberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    setUpMockInputConverterSuccess() =>
        when(() => mockInputConverter.stringToUnsignedInteger(any()))
            .thenReturn(Right(numberParsed));

    setUpMockGetConcreteNumberTriviaSuccess() =>
        when(() => mockGetConcreteNumberTrivia(any()))
            .thenAnswer((_) async => const Right(numberTrivia));

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should call the InputConverter to validate and convert the string to an unsigned integer',
      build: () {
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteNumberTriviaSuccess();
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(numberString)),
      verify: (_) => verify(
          () => mockInputConverter.stringToUnsignedInteger(numberString)),
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Empty, Error] when the input is invalid',
      build: () {
        when(() => mockInputConverter.stringToUnsignedInteger(any()))
            .thenReturn(Left(InvalidInputFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(numberString)),
      expect: () => [Empty(), Error(message: invalidInputFailureMessage)],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should get data from the concrete use case',
      build: () {
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteNumberTriviaSuccess();
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(numberString)),
      verify: (_) => verify(() => mockGetConcreteNumberTrivia(any())),
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Empty, Loading, Loaded] when data is gotten successfully',
      build: () {
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteNumberTriviaSuccess();
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(numberString)),
      expect: () => [
        Empty(),
        Loading(),
        Loaded(trivia: numberTrivia),
      ],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Empty, Loading, Error] when getting data fails',
      build: () {
        setUpMockInputConverterSuccess();
        when(() => mockGetConcreteNumberTrivia(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(numberString)),
      expect: () => [
        Empty(),
        Loading(),
        Error(message: serverFailureMessage),
      ],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Empty, Loading, Error] with proper message for the error when getting data fails',
      build: () {
        setUpMockInputConverterSuccess();
        when(() => mockGetConcreteNumberTrivia(any()))
            .thenAnswer((_) async => Left(CacheFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForConcreteNumber(numberString)),
      expect: () => [
        Empty(),
        Loading(),
        Error(message: cachFailureMessage),
      ],
    );
  });

  group('GetTriviaForRandomNumber', () {
    const numberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    setUpMockGetRandomTriviaSuccess() =>
        when(() => mockGetRandomNumberTrivia(any()))
            .thenAnswer((_) async => const Right(numberTrivia));

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should get datat from the random use case',
      build: () {
        setUpMockGetRandomTriviaSuccess();
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      verify: (_) => mockGetRandomNumberTrivia(NoParams()),
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Loading, Loaded] when data is gotten successfully',
      build: () {
        setUpMockGetRandomTriviaSuccess();
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      expect: () => [
        Empty(),
        Loading(),
        Loaded(trivia: numberTrivia),
      ],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Loading, Error] when getting data fails',
      build: () {
        when(() => mockGetRandomNumberTrivia(any()))
            .thenAnswer((_) async => Left(ServerFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      expect: () => [
        Empty(),
        Loading(),
        Error(message: serverFailureMessage),
      ],
    );

    blocTest<NumberTriviaBloc, NumberTriviaState>(
      'should emit [Loading, Error] with proper message for the error when getting data fails',
      build: () {
        when(() => mockGetRandomNumberTrivia(any()))
            .thenAnswer((_) async => Left(CacheFailure()));
        return bloc;
      },
      act: (bloc) => bloc.add(GetTriviaForRandomNumber()),
      expect: () => [
        Empty(),
        Loading(),
        Error(message: cachFailureMessage),
      ],
    );
  });
}
