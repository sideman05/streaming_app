import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/category.dart';
import '../../shared/models/channel.dart';
import '../data/channel_repository.dart';

class ChannelQuery {
  final String? category;
  final String? q;
  final int page;

  const ChannelQuery({this.category, this.q, this.page = 1});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChannelQuery &&
        other.category == category &&
        other.q == q &&
        other.page == page;
  }

  @override
  int get hashCode => Object.hash(category, q, page);
}

final channelsProvider = FutureProvider.family<List<Channel>, ChannelQuery>((
  ref,
  query,
) {
  return ref
      .read(channelRepositoryProvider)
      .channels(page: query.page, category: query.category, query: query.q);
});

final featuredChannelsProvider = FutureProvider<List<Channel>>((ref) async {
  final all = await ref.read(channelRepositoryProvider).channels(page: 1);
  return all.take(8).toList();
});

final latestChannelsProvider = FutureProvider<List<Channel>>((ref) async {
  return ref.read(channelRepositoryProvider).channels(page: 1);
});

final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.read(channelRepositoryProvider).categories();
});
