import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFFFDFDFD),
                  const Color(0xFFF3F3F3),
                  const Color(0xFFEDEDED),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),
        Positioned(
          top: -120,
          right: -120,
          child: _SoftOrb(
            color: Colors.black.withValues(alpha: 0.06),
            size: 280,
          ),
        ),
        Positioned(
          bottom: -150,
          left: -140,
          child: _SoftOrb(
            color: Colors.black.withValues(alpha: 0.05),
            size: 320,
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _SoftOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _SoftOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color, blurRadius: 120, spreadRadius: 26),
          ],
        ),
      ),
    );
  }
}
