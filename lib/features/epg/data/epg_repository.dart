import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../shared/models/epg_program.dart';

final epgRepositoryProvider = Provider((ref) {
  return EpgRepository(ref.watch(dioProvider));
});

class EpgRepository {
  final Dio _dio;

  EpgRepository(this._dio);

  Future<List<EpgProgram>> byChannel(int channelId) async {
    final res = await _dio.get(
      ApiConstants.epg,
      queryParameters: {'channel_id': channelId},
    );
    return (res.data['data'] as List)
        .map((e) => EpgProgram.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
