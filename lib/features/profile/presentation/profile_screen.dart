import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_background.dart';
import '../../auth/presentation/auth_controller.dart';
import 'profile_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const AppBackground(
          child: Center(child: Text('No user session')),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _ProfileHeader(
              name: user.name,
              email: user.email,
              subscriptionStatus: user.subscriptionStatus ?? 'free',
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text('Edit name'),
                    subtitle: const Text('Update the name on your profile'),
                    onTap: () async {
                      final controller = TextEditingController(text: user.name);
                      final newName = await showDialog<String>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Update name'),
                          content: TextField(
                            controller: controller,
                            decoration: const InputDecoration(
                              hintText: 'Enter your name',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(
                                context,
                                controller.text.trim(),
                              ),
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      );
                      if ((newName ?? '').isEmpty) return;
                      await ref
                          .read(profileUpdateProvider.notifier)
                          .updateName(newName!);
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFE8E8E8)),
                  ListTile(
                    leading: const Icon(Icons.workspace_premium_outlined),
                    title: const Text('Manage subscription'),
                    subtitle: const Text('Review and change your plan'),
                    onTap: () => context.push('/subscription'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                subtitle: const Text('Sign out of your account'),
                onTap: () async {
                  await ref.read(authControllerProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String subscriptionStatus;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.subscriptionStatus,
  });

  @override
  Widget build(BuildContext context) {
    final plan = subscriptionStatus.toLowerCase();
    final isPremium = plan == 'premium';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF111111),
            child: Text(
              name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF666666)),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isPremium ? const Color(0xFF111111) : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isPremium
                          ? const Color(0xFF111111)
                          : const Color(0xFFD6D6D6),
                    ),
                  ),
                  child: Text(
                    isPremium ? 'Premium' : 'Free Plan',
                    style: TextStyle(
                      color: isPremium ? Colors.white : const Color(0xFF555555),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
