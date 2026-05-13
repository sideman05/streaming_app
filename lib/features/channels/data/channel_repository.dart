import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../shared/models/category.dart';
import '../../shared/models/channel.dart';

final channelRepositoryProvider = Provider((ref) {
  return ChannelRepository(ref.watch(dioProvider));
});

class ChannelRepository {
  final Dio _dio;

  ChannelRepository(this._dio);

  Future<List<Channel>> channels({
    int page = 1,
    String? category,
    String? query,
  }) async {
    final res = await _dio.get(
      ApiConstants.channels,
      queryParameters: {
        'page': page,
        if (category != null && category.isNotEmpty) 'category': category,
        if (query != null && query.isNotEmpty) 'q': query,
      },
    );
    return (res.data['data']['items'] as List)
        .map((e) => Channel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Channel> channelDetails(int id) async {
    final res = await _dio.get('${ApiConstants.channels}/$id');
    return Channel.fromJson(res.data['data']);
  }

  Future<List<Category>> categories() async {
    final res = await _dio.get(ApiConstants.categories);
    return (res.data['data'] as List)
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
