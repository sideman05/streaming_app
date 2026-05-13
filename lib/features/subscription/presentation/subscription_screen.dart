import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_states.dart';
import '../../auth/presentation/auth_controller.dart';
import 'subscription_controller.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(plansProvider);
    final action = ref.watch(subscriptionActionProvider);
    final user = ref.watch(authControllerProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Subscription Plans')),
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Plan: ${user?.subscriptionStatus ?? 'free'}'),
              const SizedBox(height: 12),
              Expanded(
                child: plans.when(
                  data: (items) {
                    if (items.isEmpty) {
                      return const EmptyView(message: 'No plans available');
                    }
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, i) {
                        final p = items[i];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(p.description),
                                const SizedBox(height: 8),
                                Text(
                                  '\$${p.price.toStringAsFixed(2)} / ${p.durationDays} days',
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: action.isLoading
                                        ? null
                                        : () async {
                                            await ref
                                                .read(
                                                  subscriptionActionProvider
                                                      .notifier,
                                                )
                                                .subscribe(p.id);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Plan activated successfully',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                    child: action.isLoading
                                        ? const Text('Processing...')
                                        : const Text('Choose Plan'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  error: (e, stackTrace) => ErrorView(message: e.toString()),
                  loading: () => const LoadingView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
