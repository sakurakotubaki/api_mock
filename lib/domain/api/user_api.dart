import 'package:api_mock/domain/model/user_state.dart';
import 'package:api_mock/infrastructure/dio.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'user_api.g.dart';

@Riverpod(keepAlive: true)
UserApi userApi(Ref ref) => UserApi(ref);

class UserApi {
  UserApi(this.ref);
  Ref ref;

  Future<List<UserState>> getUserApi() async {
    final response =
        await ref.read(dioProvider).get('/', options: Options(method: 'GET'));

    if (response.statusCode == 200) {
      // レスポンスがリストの場合の処理
      if (response.data is List) {
        return (response.data as List)
            .map((json) => UserState.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      // レスポンスがMapで、dataキーにリストがある場合の処理
      if (response.data is Map && response.data['data'] is List) {
        final List<dynamic> dataList = response.data['data'];
        return dataList
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
  }
}
