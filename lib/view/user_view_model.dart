import 'package:api_mock/domain/api/user_api.dart';
import 'package:api_mock/domain/model/user_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'user_view_model.g.dart';

@riverpod
class UserViewModel extends _$UserViewModel {
  @override
  Future<List<UserState>> build() {
    return getUserApi();
  }

  Future<List<UserState>> getUserApi() async {
    final res = await ref.read(userApiProvider).getUserApi();
    return res;
  }
}
