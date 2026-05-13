import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_states.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../channels/presentation/channel_card.dart';
import '../../channels/presentation/channel_providers.dart';
import '../../favorites/presentation/favorites_controller.dart';
import '../../shared/models/channel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featured = ref.watch(featuredChannelsProvider);
    final latest = ref.watch(latestChannelsProvider);
    final auth = ref.watch(authControllerProvider);
    final user = auth.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('StreamHub'),
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
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _WelcomeCard(name: user?.name),
              const SizedBox(height: 12),
              _PlanBanner(
                status: user?.subscriptionStatus ?? 'free',
                onManage: () => context.push('/subscription'),
              ),
              const SizedBox(height: 20),
              _SectionHeader(
                title: 'Featured Live',
                actionLabel: 'See all',
                onAction: () => context.go('/channels'),
              ),
              const SizedBox(height: 10),
              featured.when(
                data: (channels) {
                  if (channels.isEmpty) {
                    return const SizedBox(
                      height: 120,
                      child: EmptyView(message: 'No featured channels'),
                    );
                  }
                  return SizedBox(
                    height: 198,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: channels.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final channel = channels[i];
                        return _FeaturedCard(
                          channel: channel,
                          onTap: () => context.push('/player', extra: channel),
                        );
                      },
                    ),
                  );
                },
                error: (e, stackTrace) => ErrorView(message: e.toString()),
                loading: () =>
                    const SizedBox(height: 120, child: LoadingView()),
              ),
              const SizedBox(height: 20),
              _SectionHeader(
                title: 'Fresh Picks',
                actionLabel: 'Browse',
                onAction: () => context.go('/channels'),
              ),
              const SizedBox(height: 10),
              latest.when(
                data: (channels) {
                  if (channels.isEmpty) {
                    return const EmptyView(message: 'No channels available');
                  }
                  final favCtrl = ref.watch(
                    favoritesControllerProvider.notifier,
                  );
                  ref.watch(favoritesControllerProvider);
                  return Column(
                    children: channels.take(8).map((channel) {
                      return ChannelCard(
                        channel: channel,
                        onTap: () => context.push('/player', extra: channel),
                        onFavorite: () => favCtrl.toggle(channel),
                        isFavorite: favCtrl.isFavorite(channel.id),
                      );
                    }).toList(),
                  );
                },
                error: (e, stackTrace) => ErrorView(message: e.toString()),
                loading: () => const LoadingView(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final String? name;

  const _WelcomeCard({this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back${(name ?? '').trim().isEmpty ? '' : ', ${name!.trim()}'}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your channels are live and ready. Discover what is streaming right now.',
            style: TextStyle(color: Color(0xFF5A5A5A), height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111111),
              letterSpacing: -0.2,
            ),
          ),
        ),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  final Channel channel;
  final VoidCallback onTap;

  const _FeaturedCard({required this.channel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE3E3E3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  channel.logo,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFF2F2F2),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.live_tv_rounded,
                      size: 36,
                      color: Color(0xFF7A7A7A),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              channel.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF111111),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              channel.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF666666), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanBanner extends StatelessWidget {
  final String status;
  final VoidCallback onManage;

  const _PlanBanner({required this.status, required this.onManage});

  @override
  Widget build(BuildContext context) {
    final premium = status.toLowerCase() == 'premium';
    final bgColor = premium ? const Color(0xFF111111) : Colors.white;
    final titleColor = premium ? Colors.white : const Color(0xFF111111);
    final subtitleColor = premium ? Colors.white70 : const Color(0xFF666666);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: premium ? const Color(0xFF111111) : const Color(0xFFE0E0E0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: premium
                  ? Colors.white.withValues(alpha: 0.16)
                  : const Color(0xFFF2F2F2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.workspace_premium,
              color: premium ? Colors.white : const Color(0xFF111111),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  premium ? 'Premium Plan Active' : 'Free Plan Active',
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  premium
                      ? 'Everything unlocked for your account.'
                      : 'Upgrade to unlock premium live channels.',
                  style: TextStyle(color: subtitleColor, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: premium ? Colors.white : const Color(0xFF111111),
              side: BorderSide(
                color: premium
                    ? const Color(0xFF666666)
                    : const Color(0xFFD3D3D3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onManage,
            child: Text(premium ? 'Manage' : 'Upgrade'),
          ),
        ],
      ),
    );
  }
}
