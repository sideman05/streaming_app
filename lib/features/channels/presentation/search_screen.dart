import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_states.dart';
import '../../favorites/presentation/favorites_controller.dart';
import 'channel_card.dart';
import 'channel_providers.dart';

final searchTextProvider = StateProvider<String>((ref) => '');

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchTextProvider);
    final results = ref.watch(
      channelsProvider(ChannelQuery(q: query, page: 1)),
    );
    final favCtrl = ref.watch(favoritesControllerProvider.notifier);
    ref.watch(favoritesControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Search Channels')),
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                onChanged: (v) =>
                    ref.read(searchTextProvider.notifier).state = v,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search by name or category',
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: query.trim().isEmpty
                    ? const EmptyView(message: 'Type to search channels')
                    : results.when(
                        data: (items) {
                          if (items.isEmpty) {
                            return const EmptyView(
                              message: 'No matching channels',
                            );
                          }
                          return ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, i) => ChannelCard(
                              channel: items[i],
                              onTap: () =>
                                  context.push('/player', extra: items[i]),
                              onFavorite: () => favCtrl.toggle(items[i]),
                              isFavorite: favCtrl.isFavorite(items[i].id),
                            ),
                          );
                        },
                        error: (e, stackTrace) =>
                            ErrorView(message: e.toString()),
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
