import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../shared/models/channel.dart';

final favoritesRepositoryProvider = Provider((ref) {
  return FavoritesRepository(ref.watch(dioProvider));
});

class FavoritesRepository {
  final Dio _dio;

  FavoritesRepository(this._dio);

  Future<List<Channel>> all() async {
    final res = await _dio.get(ApiConstants.favorites);
    return (res.data['data'] as List)
        .map((e) => Channel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> add(int channelId) async {
    await _dio.post(ApiConstants.favorites, data: {'channel_id': channelId});
  }

  Future<void> remove(int channelId) async {
    await _dio.delete('${ApiConstants.favorites}/$channelId');
  }
}
