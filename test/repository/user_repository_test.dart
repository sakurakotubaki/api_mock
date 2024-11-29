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

  // POSTメソッドのテスト
  test('createUser creates a new user on successful response', () async {
    final newUser = UserState(
      name: 'New User',
      email: 'newuser@example.com',
    );

    final mockResponse = {
      'id': 1,
      'name': 'New User',
      'email': 'newuser@example.com',
    };

    when(mockDio.post(
      any,
      data: anyNamed('data'),
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
          data: mockResponse,
          statusCode: 201,
          requestOptions: RequestOptions(path: '/'),
        ));

    final repository = container.read(userRepositoryProvider);
    final result = await repository.createUser(newUser);

    expect(result, isA<UserState>());
    expect(result.id, 1);
    expect(result.name, 'New User');
    expect(result.email, 'newuser@example.com');

    verify(mockDio.post(
      any,
      data: anyNamed('data'),
      options: anyNamed('options'),
    )).called(1);
  });

  test('createUser throws exception on error response', () async {
    final newUser = UserState(
      name: 'New User',
      email: 'newuser@example.com',
    );

    when(mockDio.post(
      any,
      data: anyNamed('data'),
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
          statusCode: 400,
          requestOptions: RequestOptions(path: '/'),
        ));

    final repository = container.read(userRepositoryProvider);

    expect(
      () => repository.createUser(newUser),
      throwsA(isA<Exception>()),
    );
  });

  test('createUser handles validation errors', () async {
    final newUser = UserState(
      name: '', // 無効な名前
      email: 'invalid-email', // 無効なメール
    );

    final mockResponse = {
      'errors': {
        'name': ['Name is required'],
        'email': ['Invalid email format'],
      }
    };

    when(mockDio.post(
      any,
      data: anyNamed('data'),
      options: anyNamed('options'),
    )).thenAnswer((_) async => Response(
          data: mockResponse,
          statusCode: 422,
          requestOptions: RequestOptions(path: '/'),
        ));

    final repository = container.read(userRepositoryProvider);

    expect(
      () => repository.createUser(newUser),
      throwsA(isA<Exception>()),
    );

    verify(mockDio.post(
      any,
      data: anyNamed('data'),
      options: anyNamed('options'),
    )).called(1);
  });
}
