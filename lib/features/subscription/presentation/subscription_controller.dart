import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../shared/models/plan.dart';
import '../data/subscription_repository.dart';

final plansProvider = FutureProvider<List<Plan>>((ref) {
  return ref.read(subscriptionRepositoryProvider).plans();
});

final subscriptionActionProvider =
    AsyncNotifierProvider<SubscriptionActionController, void>(
      SubscriptionActionController.new,
    );

class SubscriptionActionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> subscribe(int planId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(subscriptionRepositoryProvider).assignPlan(planId);
      await ref.read(authControllerProvider.notifier).refreshProfile();
    });
  }
}
