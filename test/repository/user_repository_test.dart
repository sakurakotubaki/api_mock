// test/repository/user_repository_test.dart
import 'package:api_mock/domain/repository/user_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:riverpod/riverpod.dart';
import 'package:api_mock/domain/model/user_state.dart';
import 'package:api_mock/infrastructure/dio.dart';

@GenerateMocks([Dio])
import 'user_repository_test.mocks.dart';

void main() {
  late MockDio mockDio;
  late ProviderContainer container;

  setUp(() {
    mockDio = MockDio();
    container = ProviderContainer(
      overrides: [
        dioProvider.overrideWithValue(mockDio),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('UserRepository', () {
    test('getUsers returns list of users on successful response', () async {
      final mockResponse = [
        {'id': 1, 'name': 'Test User 1', 'email': 'test1@example.com'},
        {'id': 2, 'name': 'Test User 2', 'email': 'test2@example.com'},
      ];

      when(mockDio.get(
        any,
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
            data: mockResponse,
            statusCode: 200,
            requestOptions: RequestOptions(path: '/'),
          ));

      final repository = container.read(userRepositoryProvider);
      final result = await repository.getUsers();

      expect(result, isA<List<UserState>>());
      expect(result.length, 2);
      expect(result[0].name, 'Test User 1');
      expect(result[1].name, 'Test User 2');

      verify(mockDio.get(
        any,
        options: anyNamed('options'),
      )).called(1);
    });

    test('getUsers throws exception on error response', () async {
      when(mockDio.get(
        any,
        options: anyNamed('options'),
      )).thenAnswer((_) async => Response(
            statusCode: 404,
            requestOptions: RequestOptions(path: '/'),
          ));

      final repository = container.read(userRepositoryProvider);

      expect(
        () => repository.getUsers(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
