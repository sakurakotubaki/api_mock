import 'package:api_mock/domain/model/user_state.dart';
import 'package:api_mock/infrastructure/dio.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'user_repository.g.dart';

abstract class UserRepository {
  Future<List<UserState>> getUsers();
  Future<UserState> createUser(UserState user);
}

@Riverpod(keepAlive: true)
UserRepository userRepository(Ref ref) {
  return UserRepositoryImpl(ref);
}

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this.ref);
  final Ref ref;

  @override
  Future<List<UserState>> getUsers() async {
    try {
      final response = await ref.read(dioProvider).get(
            '/',
            options: Options(method: 'GET'),
          );

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List)
              .map((json) => UserState.fromJson(json as Map<String, dynamic>))
              .toList();
        }

        throw Exception('Unexpected response format');
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: '/'),
          response: response,
          error: 'Failed to fetch users: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<UserState> createUser(UserState user) async {
    try {
      final response = await ref.read(dioProvider).post(
            '/',
            data: user.toJson(),
            options: Options(
              headers: {'Content-Type': 'application/json'},
            ),
          );

      if (response.statusCode == 201) {
        return UserState.fromJson(response.data);
      }

      if (response.statusCode == 422) {
        // バリデーションエラーの処理
        final errors = response.data['errors'];
        throw Exception('Validation failed: $errors');
      }

      throw Exception('Failed to create user');
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }
}
