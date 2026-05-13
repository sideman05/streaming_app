import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/app_states.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../epg/presentation/epg_providers.dart';
import '../../shared/models/channel.dart';
import 'channel_providers.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final Channel channel;

  const PlayerScreen({super.key, required this.channel});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  VideoPlayerController? _controller;
  bool _muted = false;
  bool _isFullscreen = false;
  String? _error;

  bool get _isInitialized => _controller?.value.isInitialized ?? false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final streamUrl = widget.channel.streamUrl.trim();
    if (streamUrl.isEmpty) {
      setState(() => _error = 'No stream URL is available for this channel.');
      return;
    }

    final previous = _controller;
    setState(() {
      _error = null;
      _controller = null;
      _muted = false;
    });

    await previous?.dispose();

    final controller = VideoPlayerController.networkUrl(Uri.parse(streamUrl));
    _controller = controller;

    try {
      await controller.initialize();
      await controller.setVolume(1);
      await controller.play();
      if (mounted) setState(() {});
    } catch (_) {
      await controller.dispose();
      if (!mounted) return;
      setState(() {
        if (identical(_controller, controller)) {
          _controller = null;
        }
        _error = 'Unable to load stream. Please retry.';
      });
    }
  }

  Future<void> _toggleMute() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    final next = !_muted;
    await controller.setVolume(next ? 0 : 1);
    if (mounted) {
      setState(() {
        _muted = next;
      });
    }
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }

    if (mounted) setState(() {});
  }

  Future<void> _toggleFullscreen() async {
    final entering = !_isFullscreen;

    if (entering) {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }

    if (mounted) {
      setState(() {
        _isFullscreen = entering;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).valueOrNull;

    if (widget.channel.isPremium && user?.subscriptionStatus != 'premium') {
      return Scaffold(
        appBar: AppBar(title: Text(widget.channel.name)),
        body: AppBackground(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE2E2E2)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFF111111),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Premium channel',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Subscription is required to watch this stream.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF676767)),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () => context.push('/subscription'),
                    child: const Text('View plans'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final epgAsync = ref.watch(channelEpgProvider(widget.channel.id));
    final relatedAsync = ref.watch(
      channelsProvider(ChannelQuery(category: widget.channel.category)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channel.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'Reload stream',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE1E1E1)),
              ),
              onPressed: _initPlayer,
              icon: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _buildPlayerPanel(),
            const SizedBox(height: 12),
            _ChannelSummaryCard(channel: widget.channel),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Program Guide',
              child: epgAsync.when(
                data: (programs) {
                  if (programs.isEmpty) {
                    return const Text(
                      'No EPG data available right now.',
                      style: TextStyle(color: Color(0xFF666666)),
                    );
                  }

                  final now = DateTime.now();
                  final current = programs.where(
                    (p) => p.startTime.isBefore(now) && p.endTime.isAfter(now),
                  );
                  final upNext = programs
                      .where((p) => p.startTime.isAfter(now))
                      .take(4)
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (current.isNotEmpty)
                        _ProgramItem(
                          label: 'Now',
                          title: current.first.title,
                          timeText:
                              '${DateFormat.Hm().format(current.first.startTime)} - ${DateFormat.Hm().format(current.first.endTime)}',
                          highlighted: true,
                        )
                      else
                        const Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            'No live program metadata at this moment.',
                            style: TextStyle(color: Color(0xFF666666)),
                          ),
                        ),
                      if (upNext.isNotEmpty)
                        ...upNext.map(
                          (p) => _ProgramItem(
                            label: 'Next',
                            title: p.title,
                            timeText: DateFormat.Hm().format(p.startTime),
                            highlighted: false,
                          ),
                        )
                      else
                        const Text(
                          'No upcoming schedule yet.',
                          style: TextStyle(color: Color(0xFF666666)),
                        ),
                    ],
                  );
                },
                error: (e, stackTrace) => Text(e.toString()),
                loading: () => const SizedBox(height: 80, child: LoadingView()),
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Related Channels',
              child: relatedAsync.when(
                data: (channels) {
                  final filtered = channels
                      .where((c) => c.id != widget.channel.id)
                      .take(8)
                      .toList();

                  if (filtered.isEmpty) {
                    return const Text(
                      'No related channels found.',
                      style: TextStyle(color: Color(0xFF666666)),
                    );
                  }

                  return SizedBox(
                    height: 154,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final c = filtered[i];
                        return _RelatedChannelCard(
                          channel: c,
                          onTap: () =>
                              context.pushReplacement('/player', extra: c),
                        );
                      },
                    ),
                  );
                },
                error: (e, stackTrace) => Text(e.toString()),
                loading: () => const SizedBox(height: 90, child: LoadingView()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerPanel() {
    final controller = _controller;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: AspectRatio(
        aspectRatio: _isInitialized
            ? (controller!.value.aspectRatio == 0
                  ? 16 / 9
                  : controller.value.aspectRatio)
            : 16 / 9,
        child: _buildPlayerBody(controller),
      ),
    );
  }

  Widget _buildPlayerBody(VideoPlayerController? controller) {
    if (controller == null || !controller.value.isInitialized) {
      if (_error != null) {
        return ColoredBox(
          color: const Color(0xFF111111),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: ErrorView(message: _error!, onRetry: _initPlayer),
            ),
          ),
        );
      }
      return const ColoredBox(color: Color(0xFF111111), child: LoadingView());
    }

    return Stack(
      children: [
        Positioned.fill(child: VideoPlayer(controller)),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.28),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.45),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          left: 12,
          top: 10,
          child: Row(
            children: [
              _OverlayChip(
                icon: Icons.circle,
                iconColor: const Color(0xFFFF3B30),
                label: 'LIVE',
              ),
              const SizedBox(width: 8),
              _OverlayChip(label: widget.channel.category),
            ],
          ),
        ),
        Positioned(
          left: 10,
          right: 10,
          bottom: 10,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.white,
                    bufferedColor: Color(0x66FFFFFF),
                    backgroundColor: Color(0x55FFFFFF),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.46),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0x33FFFFFF)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ControlButton(
                      icon: _muted ? Icons.volume_off : Icons.volume_up,
                      onPressed: _toggleMute,
                    ),
                    const SizedBox(width: 6),
                    _ControlButton(
                      icon: controller.value.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      onPressed: _togglePlayback,
                    ),
                    const SizedBox(width: 6),
                    _ControlButton(
                      icon: _isFullscreen
                          ? Icons.fullscreen_exit_rounded
                          : Icons.fullscreen_rounded,
                      onPressed: _toggleFullscreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ControlButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        style: IconButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black.withValues(alpha: 0.34),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
      ),
    );
  }
}

class _OverlayChip extends StatelessWidget {
  final IconData? icon;
  final Color? iconColor;
  final String label;

  const _OverlayChip({this.icon, this.iconColor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.44),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x2EFFFFFF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 10, color: iconColor ?? Colors.white),
          if (icon != null) const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelSummaryCard extends StatelessWidget {
  final Channel channel;

  const _ChannelSummaryCard({required this.channel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  channel.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (channel.isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Premium',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            channel.description?.trim().isNotEmpty == true
                ? channel.description!
                : 'No channel description available.',
            style: const TextStyle(color: Color(0xFF606060), height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF111111),
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ProgramItem extends StatelessWidget {
  final String label;
  final String title;
  final String timeText;
  final bool highlighted;

  const _ProgramItem({
    required this.label,
    required this.title,
    required this.timeText,
    required this.highlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFF0F0F0) : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E4E4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: highlighted ? const Color(0xFF111111) : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: highlighted
                    ? const Color(0xFF111111)
                    : const Color(0xFFD6D6D6),
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: highlighted ? Colors.white : const Color(0xFF555555),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeText,
                  style: const TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 12,
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

class _RelatedChannelCard extends StatelessWidget {
  final Channel channel;
  final VoidCallback onTap;

  const _RelatedChannelCard({required this.channel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 146,
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE4E4E4)),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  channel.logo,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFF0F0F0),
                    alignment: Alignment.center,
                    child: const Icon(Icons.live_tv_rounded),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              channel.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF111111),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              channel.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF676767), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
