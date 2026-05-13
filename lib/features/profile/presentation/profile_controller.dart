import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/profile_repository.dart';

final profileUpdateProvider =
    AsyncNotifierProvider<ProfileUpdateController, void>(
      ProfileUpdateController.new,
    );

class ProfileUpdateController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateName(String name) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref
          .read(profileRepositoryProvider)
          .updateProfile(name: name);
      ref.read(authControllerProvider.notifier).patchUser(user);
    });
  }
}
