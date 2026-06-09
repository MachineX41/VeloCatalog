import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/apple_theme.dart';
import 'product_image.dart';

enum AppleToastKind {
  bag,
  success,
  removed,
}

class AppleToast {
  static OverlayEntry? _entry;

  static void show(
    BuildContext context, {
    required String title,
    required String subtitle,
    String? imageUrl,
    AppleToastKind kind = AppleToastKind.bag,
  }) {
    _entry?.remove();
    _entry = null;

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayContext) => _AppleToastOverlay(
        title: title,
        subtitle: subtitle,
        imageUrl: imageUrl,
        kind: kind,
        onDismissed: () {
          if (_entry == entry) {
            entry.remove();
            _entry = null;
          }
        },
      ),
    );

    _entry = entry;
    overlay.insert(entry);
  }
}

class _AppleToastOverlay extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final AppleToastKind kind;
  final VoidCallback onDismissed;

  const _AppleToastOverlay({
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.kind,
    required this.onDismissed,
  });

  @override
  State<_AppleToastOverlay> createState() => _AppleToastOverlayState();
}

class _AppleToastOverlayState extends State<_AppleToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    HapticFeedback.mediumImpact();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
      reverseDuration: const Duration(milliseconds: 360),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    _scale = Tween<double>(begin: 0.94, end: 1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    ));

    _controller.forward();

    Future<void>.delayed(const Duration(milliseconds: 2400), _dismiss);
  }

  Future<void> _dismiss() async {
    if (_isClosing || !mounted) return;
    _isClosing = true;
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildLeading() {
    if (widget.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 44,
          height: 44,
          child: ProductImage(
            imageUrl: widget.imageUrl!,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _accentColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        _leadingFallbackIcon,
        color: _accentColor,
        size: 24,
      ),
    );
  }

  Color get _accentColor {
    switch (widget.kind) {
      case AppleToastKind.success:
        return const Color(0xFF34C759);
      case AppleToastKind.removed:
        return const Color(0xFFFF3B30);
      case AppleToastKind.bag:
        return AppleColors.blue;
    }
  }

  IconData get _leadingFallbackIcon {
    switch (widget.kind) {
      case AppleToastKind.success:
        return Icons.check_rounded;
      case AppleToastKind.removed:
        return Icons.delete_outline_rounded;
      case AppleToastKind.bag:
        return Icons.shopping_bag_outlined;
    }
  }

  IconData get _trailingIcon {
    switch (widget.kind) {
      case AppleToastKind.success:
        return Icons.verified_rounded;
      case AppleToastKind.removed:
        return Icons.close_rounded;
      case AppleToastKind.bag:
        return Icons.shopping_bag_outlined;
    }
  }

  Color get _trailingColor => _accentColor;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top + 12;

    return Positioned(
      top: top,
      left: 18,
      right: 18,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: GestureDetector(
              onTap: _dismiss,
              onVerticalDragEnd: (details) {
                if (details.primaryVelocity != null &&
                    details.primaryVelocity! < -120) {
                  _dismiss();
                }
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppleColors.card.withValues(alpha: 0.9),
                          AppleColors.card.withValues(alpha: 0.78),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 28,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          _buildLeading(),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: AppleTextStyles.footnote.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppleColors.label,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.subtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppleTextStyles.caption.copyWith(
                                    color: AppleColors.bodySecondary,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            _trailingIcon,
                            size: 18,
                            color: _trailingColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
