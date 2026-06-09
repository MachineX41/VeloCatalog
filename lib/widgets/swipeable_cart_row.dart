import 'package:flutter/material.dart';
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
  static const _actionWidth = 76.0;
  static const _totalActionsWidth = _actionWidth * 2;

  late final AnimationController _snapController;
  double _dragOffset = 0;
  double _startOffset = 0;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 240),
    )..addListener(() {
        setState(() {
          _dragOffset = _snapController.value * _totalActionsWidth;
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

  void _animateTo(double target) {
    _snapController.stop();
    final begin = _dragOffset;
    _snapController.value = begin / _totalActionsWidth;
    final end = target / _totalActionsWidth;
    _snapController.animateTo(
      end.clamp(0.0, 1.0),
      curve: Curves.easeOutCubic,
      duration: const Duration(milliseconds: 280),
    );
  }

  void _onDragStart(DragStartDetails details) {
    _snapController.stop();
    _startOffset = _dragOffset;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragOffset = (_startOffset - details.delta.dx).clamp(0, _totalActionsWidth);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -400) {
      _animateTo(_totalActionsWidth);
      return;
    }
    if (velocity > 400) {
      _animateTo(0);
      return;
    }
    if (_dragOffset > _totalActionsWidth * 0.42) {
      _animateTo(_totalActionsWidth);
    } else {
      _animateTo(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final revealProgress = (_dragOffset / _totalActionsWidth).clamp(0.0, 1.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppleRadius.card),
      child: Stack(
        children: [
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _SwipeActionButton(
                  label: 'Detail',
                  icon: Icons.info_outline_rounded,
                  color: AppleColors.blue,
                  width: _actionWidth,
                  progress: revealProgress,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _animateTo(0);
                    widget.onDetail();
                  },
                ),
                _SwipeActionButton(
                  label: 'Delete',
                  icon: Icons.delete_outline_rounded,
                  color: const Color(0xFFFF3B30),
                  width: _actionWidth,
                  progress: revealProgress,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _animateTo(0);
                    widget.onDelete();
                  },
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
              child: widget.child,
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
  final double progress;
  final VoidCallback onTap;

  const _SwipeActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.width,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: color,
        child: InkWell(
          onTap: onTap,
          child: Opacity(
            opacity: 0.35 + (progress * 0.65),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 22),
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
    );
  }
}
