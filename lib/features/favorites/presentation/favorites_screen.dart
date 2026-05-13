import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_states.dart';
import '../../channels/presentation/channel_card.dart';
import 'favorites_controller.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesControllerProvider);
    final controller = ref.watch(favoritesControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: AppBackground(
        child: favorites.when(
          data: (items) {
            if (items.isEmpty) {
              return const EmptyView(message: 'No favorite channels yet');
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: items.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return _FavoritesHeader(count: items.length);
                }
                final c = items[i - 1];
                return ChannelCard(
                  channel: c,
                  onTap: () => context.push('/player', extra: c),
                  onFavorite: () => controller.toggle(c),
                  isFavorite: true,
                );
              },
            );
          },
          error: (e, stackTrace) => ErrorView(message: e.toString()),
          loading: () => const LoadingView(),
        ),
      ),
    );
  }
}

class _FavoritesHeader extends StatelessWidget {
  final int count;

  const _FavoritesHeader({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.favorite, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saved channels',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$count in your list',
                  style: const TextStyle(color: Color(0xFF646464)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
