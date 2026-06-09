import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../theme/apple_theme.dart';

class SortMenuOption {
  final String value;
  final String label;

  const SortMenuOption({required this.value, required this.label});
}

class LiquidGlassSortMenu extends StatefulWidget {
  final String selectedValue;
  final ValueChanged<String> onSelected;
  final List<SortMenuOption> options;

  const LiquidGlassSortMenu({
    super.key,
    required this.selectedValue,
    required this.onSelected,
    required this.options,
  });

  @override
  State<LiquidGlassSortMenu> createState() => _LiquidGlassSortMenuState();
}

class _LiquidGlassSortMenuState extends State<LiquidGlassSortMenu>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expand;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this)
      ..addListener(() => setState(() {}));
    _expand = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _selectedLabel {
    return widget.options
        .firstWhere((option) => option.value == widget.selectedValue)
        .label;
  }

  Future<void> _toggle() async {
    HapticFeedback.selectionClick();
    final target = _isOpen ? 0.0 : 1.0;
    _isOpen = !_isOpen;

    _controller.stop();
    final simulation = SpringSimulation(
      const SpringDescription(mass: 0.75, stiffness: 380, damping: 28),
      _expand.value.clamp(0, 1),
      target,
      0,
    );
    await _controller.animateWith(simulation);
  }

  Future<void> _close() async {
    if (!_isOpen) return;
    _isOpen = false;
    _controller.stop();
    final simulation = SpringSimulation(
      const SpringDescription(mass: 0.75, stiffness: 420, damping: 30),
      _expand.value.clamp(0, 1),
      0,
      0,
    );
    await _controller.animateWith(simulation);
  }

  void _select(String value) {
    HapticFeedback.selectionClick();
    widget.onSelected(value);
    _close();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _expand.value.clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _GlassSlice(
          borderRadius: BorderRadius.circular(18),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggle,
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      size: 17,
                      color: _isOpen ? AppleColors.blue : AppleColors.label,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedLabel,
                        style: AppleTextStyles.footnote.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppleColors.label,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AnimatedRotation(
                      turns: _isOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutBack,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: _isOpen ? AppleColors.blue : AppleColors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: progress,
            child: Opacity(
              opacity: progress,
              child: Padding(
                padding: EdgeInsets.only(top: 6 * progress),
                child: Transform.scale(
                  alignment: Alignment.topCenter,
                  scale: 0.92 + (progress * 0.08),
                  child: _GlassSlice(
                    borderRadius: BorderRadius.circular(18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < widget.options.length; i++) ...[
                          if (i > 0)
                            Divider(
                              height: 1,
                              thickness: 0.6,
                              color: Colors.white.withValues(alpha: 0.45),
                              indent: 14,
                              endIndent: 14,
                            ),
                          _SortOptionTile(
                            label: widget.options[i].label,
                            isSelected:
                                widget.options[i].value == widget.selectedValue,
                            onTap: () => _select(widget.options[i].value),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassSlice extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;

  const _GlassSlice({
    required this.child,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppleColors.card.withValues(alpha: 0.78),
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
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SortOptionTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppleTextStyles.footnote.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppleColors.blue : AppleColors.label,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: AppleColors.blue,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
