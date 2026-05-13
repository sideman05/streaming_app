import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/epg_program.dart';
import '../data/epg_repository.dart';

final channelEpgProvider = FutureProvider.family<List<EpgProgram>, int>((
  ref,
  channelId,
) {
  return ref.read(epgRepositoryProvider).byChannel(channelId);
});
