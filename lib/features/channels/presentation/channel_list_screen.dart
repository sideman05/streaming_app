import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_states.dart';
import '../../favorites/presentation/favorites_controller.dart';
import 'channel_card.dart';
import 'channel_providers.dart';

class ChannelListScreen extends ConsumerWidget {
  final String? category;
  const ChannelListScreen({super.key, this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final channels = ref.watch(
      channelsProvider(ChannelQuery(category: category, page: 1)),
    );
    final favoriteCtrl = ref.watch(favoritesControllerProvider.notifier);
    ref.watch(favoritesControllerProvider);

    final title = category == null ? 'Live Channels' : '$category Channels';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE1E1E1)),
              ),
              onPressed: () => context.push('/search'),
              icon: const Icon(Icons.search),
            ),
          ),
        ],
      ),
      body: AppBackground(
        child: channels.when(
          data: (items) {
            if (items.isEmpty) {
              return const EmptyView(message: 'No channels found');
            }
            return RefreshIndicator(
              onRefresh: () async => ref.refresh(
                channelsProvider(
                  ChannelQuery(category: category, page: 1),
                ).future,
              ),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
                itemCount: items.length + 1,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return _ChannelsSummaryCard(
                      category: category,
                      count: items.length,
                    );
                  }
                  final c = items[i - 1];
                  return ChannelCard(
                    channel: c,
                    onTap: () => context.push('/player', extra: c),
                    onFavorite: () => favoriteCtrl.toggle(c),
                    isFavorite: favoriteCtrl.isFavorite(c.id),
                  );
                },
              ),
            );
          },
          error: (e, stackTrace) => ErrorView(
            message: e.toString(),
            onRetry: () => ref.refresh(
              channelsProvider(ChannelQuery(category: category, page: 1)),
            ),
          ),
          loading: () => const LoadingView(),
        ),
      ),
    );
  }
}

class _ChannelsSummaryCard extends StatelessWidget {
  final String? category;
  final int count;

  const _ChannelsSummaryCard({required this.category, required this.count});

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
            child: const Icon(Icons.live_tv_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category == null ? 'All live channels' : '$category channels',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$count available now',
                  style: const TextStyle(color: Color(0xFF656565)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
