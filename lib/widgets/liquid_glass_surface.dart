import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/apple_theme.dart';

class LiquidGlassSurface extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blurSigma;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const LiquidGlassSurface({
    super.key,
    required this.child,
    required this.borderRadius,
    this.padding,
    this.blurSigma = 18,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final surface = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppleColors.card.withValues(alpha: 0.88),
                AppleColors.card.withValues(alpha: 0.58),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.62),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: padding != null ? Padding(padding: padding!, child: child) : child,
        ),
      ),
    );

    final sized = SizedBox(width: width, height: height, child: surface);

    if (onTap == null) return sized;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        splashColor: AppleColors.blue.withValues(alpha: 0.08),
        highlightColor: AppleColors.blue.withValues(alpha: 0.04),
        child: sized,
      ),
    );
  }
}

class LiquidGlassCircleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double size;

  const LiquidGlassCircleButton({
    super.key,
    required this.child,
    this.onTap,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassSurface(
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
      blurSigma: 16,
      onTap: onTap,
      child: Center(child: child),
    );
  }
}

class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final Clip clipBehavior;
  final double blurSigma;
  final EdgeInsetsGeometry? padding;
  final bool opaque;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.borderRadius =
        const BorderRadius.all(Radius.circular(AppleRadius.card)),
    this.clipBehavior = Clip.antiAlias,
    this.blurSigma = 22,
    this.padding,
    this.opaque = false,
  });

  List<Color> get _gradientColors => opaque
      ? const [AppleColors.card, Color(0xFFF8F8FA)]
      : [
          AppleColors.card.withValues(alpha: 0.94),
          AppleColors.card.withValues(alpha: 0.66),
        ];

  Widget _buildSurface(Widget content) {
    final layers = Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _gradientColors,
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: opaque ? 0.9 : 0.74),
                  width: 1,
                ),
                left: BorderSide(
                  color: Colors.white.withValues(alpha: opaque ? 0.65 : 0.52),
                  width: 0.8,
                ),
                right: BorderSide(
                  color: Colors.white.withValues(alpha: opaque ? 0.35 : 0.2),
                  width: 0.6,
                ),
                bottom: BorderSide(
                  color: Colors.black.withValues(alpha: 0.06),
                  width: 0.6,
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: borderRadius,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: const Alignment(0.65, 0.85),
                  colors: [
                    Colors.white.withValues(alpha: opaque ? 0.22 : 0.32),
                    Colors.white.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.24, 0.58],
                ),
              ),
            ),
          ),
        ),
        content,
      ],
    );

    if (opaque) return layers;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
      child: layers,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 34,
            offset: const Offset(0, 16),
            spreadRadius: -8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        clipBehavior: clipBehavior,
        child: _buildSurface(
          padding != null ? Padding(padding: padding!, child: child) : child,
        ),
      ),
    );
  }
}

class LiquidGlassSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const LiquidGlassSearchBar({
    super.key,
    required this.controller,
    this.hintText = 'Search products',
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassSurface(
      borderRadius: BorderRadius.circular(AppleRadius.search),
      blurSigma: 20,
      child: TextField(
        controller: controller,
        style: AppleTextStyles.body.copyWith(
          fontSize: 16,
          color: AppleColors.label,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppleTextStyles.subheadline,
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppleColors.secondaryLabel,
            size: 22,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  onPressed: onClear,
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: AppleColors.secondaryLabel,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 4,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
