import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/apple_theme.dart';

class GlassBar extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const GlassBar({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(22, 14, 22, 22),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppleColors.card.withValues(alpha: 0.82),
            border: const Border(
              top: BorderSide(color: Color(0x33D2D2D7)),
            ),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
