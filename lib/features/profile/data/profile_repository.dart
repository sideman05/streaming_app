import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../shared/models/user.dart';

final profileRepositoryProvider = Provider((ref) {
  return ProfileRepository(ref.watch(dioProvider));
});

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<User> updateProfile({required String name}) async {
    final res = await _dio.put(ApiConstants.profile, data: {'name': name});
    return User.fromJson(res.data['data']);
  }
}
