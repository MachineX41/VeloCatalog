import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../theme/apple_theme.dart';

class SwipeableCartRow extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelete;
  final VoidCallback onDetail;

  const SwipeableCartRow({
    super.key,
    required this.child,
    required this.onDelete,
    required this.onDetail,
  });

  @override
  State<SwipeableCartRow> createState() => SwipeableCartRowState();
}

class SwipeableCartRowState extends State<SwipeableCartRow>
    with SingleTickerProviderStateMixin {
  static const _actionWidth = 72.0;
  static const _totalActionsWidth = _actionWidth * 2;

  late final AnimationController _snapController;
  double _dragOffset = 0;
  double _startOffset = 0;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController.unbounded(vsync: this)
      ..addListener(() {
        setState(() {
          _dragOffset = _snapController.value.clamp(0, _totalActionsWidth);
        });
      });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void close() {
    _animateTo(0);
  }

  Future<void> _animateTo(double target) async {
    _snapController.stop();
    final simulation = SpringSimulation(
      SpringDescription(
        mass: 0.85,
        stiffness: target > _dragOffset ? 280 : 320,
        damping: target > _dragOffset ? 22 : 26,
      ),
      _dragOffset,
      target,
      _snapController.velocity,
    );
    await _snapController.animateWith(simulation);
    if (mounted && target == 0 && _dragOffset < 0.5) {
      _snapController.value = 0;
      setState(() => _dragOffset = 0);
    }
  }

  void _onDragStart(DragStartDetails details) {
    _snapController.stop();
    _startOffset = _dragOffset;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset =
          (_startOffset - details.delta.dx).clamp(0, _totalActionsWidth);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -500) {
      _animateTo(_totalActionsWidth);
      return;
    }
    if (velocity > 500) {
      _animateTo(0);
      return;
    }
    if (_dragOffset > _totalActionsWidth * 0.38) {
      _animateTo(_totalActionsWidth);
    } else {
      _animateTo(0);
    }
  }

  double _staggeredReveal(double offsetStart) {
    return Curves.easeOutCubic
        .transform(((_dragOffset - offsetStart) / _actionWidth).clamp(0.0, 1.0));
  }

  BorderRadius get _foregroundRadius {
    final isOpen = _dragOffset > 1;
    return BorderRadius.only(
      topLeft: const Radius.circular(AppleRadius.card),
      bottomLeft: const Radius.circular(AppleRadius.card),
      topRight: Radius.circular(isOpen ? 0 : AppleRadius.card),
      bottomRight: Radius.circular(isOpen ? 0 : AppleRadius.card),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailReveal = _staggeredReveal(0);
    final deleteReveal = _staggeredReveal(_actionWidth);
    final showActions = _dragOffset > 0.5;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppleRadius.card),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          if (showActions)
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _SwipeActionButton(
                    label: 'Detail',
                    icon: Icons.info_outline_rounded,
                    color: AppleColors.blue,
                    width: _actionWidth,
                    reveal: detailReveal,
                    onTap: detailReveal > 0.85
                        ? () {
                            HapticFeedback.selectionClick();
                            _animateTo(0);
                            widget.onDetail();
                          }
                        : null,
                  ),
                  _SwipeActionButton(
                    label: 'Delete',
                    icon: Icons.delete_outline_rounded,
                    color: const Color(0xFFFF3B30),
                    width: _actionWidth,
                    reveal: deleteReveal,
                    onTap: deleteReveal > 0.85
                        ? () {
                            HapticFeedback.mediumImpact();
                            _animateTo(0);
                            widget.onDelete();
                          }
                        : null,
                  ),
                ],
              ),
            ),
          GestureDetector(
            onHorizontalDragStart: _onDragStart,
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            child: Transform.translate(
              offset: Offset(-_dragOffset, 0),
              child: ClipRRect(
                borderRadius: _foregroundRadius,
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwipeActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final double width;
  final double reveal;
  final VoidCallback? onTap;

  const _SwipeActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.width,
    required this.reveal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (reveal <= 0.001) {
      return SizedBox(width: width);
    }

    final bounce = Curves.easeOutBack.transform(reveal);
    final slideX = lerpDouble(18, 0, bounce)!;

    return SizedBox(
      width: width,
      child: ClipRect(
        child: Align(
          alignment: Alignment.centerRight,
          widthFactor: bounce.clamp(0.001, 1.0),
          child: Transform.translate(
            offset: Offset(slideX, 0),
            child: Opacity(
              opacity: reveal.clamp(0.0, 1.0),
              child: Material(
                color: color,
                child: InkWell(
                  onTap: onTap,
                  child: SizedBox(
                    width: width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.scale(
                          scale: 0.82 + (bounce * 0.18),
                          child: Icon(icon, color: Colors.white, size: 21),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }
}
