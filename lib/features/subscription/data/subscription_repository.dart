import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../shared/models/plan.dart';

final subscriptionRepositoryProvider = Provider((ref) {
  return SubscriptionRepository(ref.watch(dioProvider));
});

class SubscriptionRepository {
  final Dio _dio;

  SubscriptionRepository(this._dio);

  Future<List<Plan>> plans() async {
    final res = await _dio.get(ApiConstants.plans);
    return (res.data['data'] as List)
        .map((e) => Plan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> assignPlan(int planId) async {
    await _dio.post(ApiConstants.subscribe, data: {'plan_id': planId});
  }
}
