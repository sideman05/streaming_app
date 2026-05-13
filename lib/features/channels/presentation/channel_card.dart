import 'package:flutter/material.dart';
import '../../shared/models/channel.dart';

class ChannelCard extends StatelessWidget {
  final Channel channel;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final bool isFavorite;

  const ChannelCard({
    super.key,
    required this.channel,
    required this.onTap,
    required this.onFavorite,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _ChannelLogo(url: channel.logo),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      channel.currentProgram ?? channel.category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF666666)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _TagChip(label: channel.category, isInverted: false),
                        if (channel.isPremium)
                          const _TagChip(label: 'Premium', isInverted: true),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: const Color(0xFF111111),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChannelLogo extends StatelessWidget {
  final String url;

  const _ChannelLogo({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E2E2)),
        color: const Color(0xFFF8F8F8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.live_tv_rounded, color: Color(0xFF6E6E6E)),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final bool isInverted;

  const _TagChip({required this.label, required this.isInverted});

  @override
  Widget build(BuildContext context) {
    final textColor = isInverted ? Colors.white : const Color(0xFF2D2D2D);
    final bgColor = isInverted ? const Color(0xFF111111) : Colors.white;
    final borderColor = isInverted
        ? const Color(0xFF111111)
        : const Color(0xFFD8D8D8);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
