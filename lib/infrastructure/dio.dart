import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'dio.g.dart';

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  return Dio(BaseOptions(
    baseUrl: "https://jsonplaceholder.typicode.com/users",
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));
}
