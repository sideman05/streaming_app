import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../shared/models/user.dart';

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(
    ref.watch(dioProvider),
    ref.watch(secureStorageProvider),
  );
});

class AuthRepository {
  final Dio _dio;
  final SecureStorageService _storage;

  AuthRepository(this._dio, this._storage);

  Future<User> login(String email, String password) async {
    try {
      final res = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      final token = res.data['data']['token'] as String;
      await _storage.saveToken(token);
      return User.fromJson(res.data['data']['user']);
    } on DioException catch (e) {
      throw AuthException(_friendlyMessage(e, action: 'login'));
    }
  }

  Future<User> register(String name, String email, String password) async {
    try {
      final res = await _dio.post(
        ApiConstants.register,
        data: {'name': name, 'email': email, 'password': password},
      );
      final token = res.data['data']['token'] as String;
      await _storage.saveToken(token);
      return User.fromJson(res.data['data']['user']);
    } on DioException catch (e) {
      throw AuthException(_friendlyMessage(e, action: 'register'));
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } catch (_) {}
    await _storage.clearToken();
  }

  Future<User> profile() async {
    final res = await _dio.get(ApiConstants.profile);
    return User.fromJson(res.data['data']);
  }

  Future<User?> bootstrapSession() async {
    final token = await _storage.readToken();
    if (token == null || token.isEmpty) return null;
    try {
      return await profile();
    } catch (_) {
      await _storage.clearToken();
      return null;
    }
  }

  String _friendlyMessage(DioException e, {required String action}) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    switch (status) {
      case 401:
        return 'Invalid email or password.';
      case 409:
        return 'Email already exists.';
      case 422:
        return 'Please check your input and try again.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'Unable to $action right now. Check your network and try again.';
    }
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
