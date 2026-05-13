import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/channel.dart';
import '../data/favorites_repository.dart';

final favoritesControllerProvider =
    AsyncNotifierProvider<FavoritesController, List<Channel>>(
      FavoritesController.new,
    );

class FavoritesController extends AsyncNotifier<List<Channel>> {
  @override
  Future<List<Channel>> build() async {
    return ref.read(favoritesRepositoryProvider).all();
  }

  Future<void> toggle(Channel channel) async {
    final current = state.valueOrNull ?? [];
    final exists = current.any((e) => e.id == channel.id);
    if (exists) {
      await ref.read(favoritesRepositoryProvider).remove(channel.id);
      state = AsyncData(current.where((e) => e.id != channel.id).toList());
    } else {
      await ref.read(favoritesRepositoryProvider).add(channel.id);
      state = AsyncData([...current, channel]);
    }
  }

  bool isFavorite(int id) {
    final current = state.valueOrNull ?? [];
    return current.any((e) => e.id == id);
  }
}
