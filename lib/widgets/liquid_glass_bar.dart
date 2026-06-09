import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/apple_theme.dart';

class LiquidGlassBar extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  const LiquidGlassBar({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(22, 16, 22, 24),
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(28)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppleColors.card.withValues(alpha: 0.72),
                AppleColors.card.withValues(alpha: 0.88),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.65),
                width: 0.8,
              ),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 24,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
