import 'package:flutter/material.dart';

class AnimatedProductGridItem extends StatefulWidget {
  final int index;
  final int animationTick;
  final Widget child;

  const AnimatedProductGridItem({
    super.key,
    required this.index,
    required this.animationTick,
    required this.child,
  });

  @override
  State<AnimatedProductGridItem> createState() =>
      _AnimatedProductGridItemState();
}

class _AnimatedProductGridItemState extends State<AnimatedProductGridItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _scale = Tween<double>(begin: 0.96, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _playEntrance();
  }

  @override
  void didUpdateWidget(AnimatedProductGridItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationTick != widget.animationTick) {
      _controller.reset();
      _playEntrance();
    }
  }

  void _playEntrance() {
    final delay = Duration(milliseconds: 28 * widget.index.clamp(0, 8));
    Future<void>.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(
          scale: _scale,
          child: widget.child,
        ),
      ),
    );
  }
}
