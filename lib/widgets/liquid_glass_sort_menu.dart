import 'dart:math' as math;
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
  static const optionHeight = 44.0;

  final String selectedValue;
  final ValueChanged<String> onSelected;
  final List<SortMenuOption> options;
  final ValueChanged<bool>? onOpenChanged;

  const LiquidGlassSortMenu({
    super.key,
    required this.selectedValue,
    required this.onSelected,
    required this.options,
    this.onOpenChanged,
  });

  @override
  State<LiquidGlassSortMenu> createState() => LiquidGlassSortMenuState();
}

class LiquidGlassSortMenuState extends State<LiquidGlassSortMenu>
    with SingleTickerProviderStateMixin {
  static const _buttonSize = 44.0;
  static const _expandedWidth = 272.0;
  static const _headerHeight = 44.0;

  late final AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _expandedHeight {
    final dividerCount =
        widget.options.length > 1 ? widget.options.length - 1 : 0;
    return _headerHeight +
        widget.options.length * LiquidGlassSortMenu.optionHeight +
        dividerCount +
        10;
  }

  double get _raw => _controller.value;
  double get _t => _raw.clamp(0.0, 1.0);

  double _widthProgress(double raw) =>
      Curves.easeOutBack.transform(raw.clamp(0.0, 1.0));

  double _heightProgress(double raw) {
    final delayed = ((raw - 0.14) / 0.86).clamp(0.0, 1.0);
    return Curves.easeOutBack.transform(delayed);
  }

  BorderRadius _borderRadius(double raw) {
    if (raw < 0.02) {
      return BorderRadius.circular(_buttonSize / 2);
    }

    final w = _widthProgress(raw);
    final h = _heightProgress(raw);
    final topR = lerpDouble(_buttonSize / 2, 22, w)!;
    final bottomR = lerpDouble(_buttonSize / 2, 22, h)!;
    final bulge = math.sin(raw * math.pi) * 5;

    return BorderRadius.only(
      topLeft: Radius.circular(topR),
      topRight: Radius.circular(topR),
      bottomRight: Radius.circular(bottomR),
      bottomLeft: Radius.circular(bottomR + bulge),
    );
  }

  Future<void> _animateTo(double target) async {
    _controller.stop();
    final opening = target > _t;
    final simulation = SpringSimulation(
      SpringDescription(
        mass: opening ? 1.35 : 1.2,
        stiffness: opening ? 120 : 150,
        damping: opening ? 17 : 20,
      ),
      _raw,
      target,
      _controller.velocity,
    );
    await _controller.animateWith(simulation);
    if (!mounted) return;
    if (target == 0 && _t < 0.02) {
      _controller.value = 0;
    } else if (target == 1 && _t > 0.98) {
      _controller.value = 1;
    }
  }

  Future<void> _toggle() async {
    HapticFeedback.selectionClick();
    _isOpen = !_isOpen;
    widget.onOpenChanged?.call(_isOpen);
    await _animateTo(_isOpen ? 1 : 0);
  }

  Future<void> close() async {
    if (!_isOpen) return;
    _isOpen = false;
    widget.onOpenChanged?.call(false);
    await _animateTo(0);
    if (mounted) _controller.value = 0;
  }

  void _select(String value) {
    HapticFeedback.selectionClick();
    widget.onSelected(value);
    close();
  }

  @override
  Widget build(BuildContext context) {
    final raw = _t;
    final widthP = _widthProgress(raw);
    final heightP = _heightProgress(raw);
    final width = lerpDouble(_buttonSize, _expandedWidth, widthP)!;
    final height = lerpDouble(_buttonSize, _expandedHeight, heightP)!;
    final radius = _borderRadius(raw);
    final blur = lerpDouble(16, 24, math.max(widthP, heightP))!;
    final menuOpacity = Curves.easeIn.transform(((raw - 0.42) / 0.45).clamp(0.0, 1.0));
    final showMenu = raw > 0.4 && height > _buttonSize + 20;

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  AppleColors.card.withValues(alpha: 0.9),
                  AppleColors.card.withValues(alpha: 0.64),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.64),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05 + widthP * 0.06),
                  blurRadius: 14 + widthP * 12,
                  offset: Offset(0, 5 + heightP * 8),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            Colors.white.withValues(alpha: 0.28 * widthP),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.55],
                        ),
                      ),
                    ),
                  ),
                ),
                if (showMenu)
                  Opacity(
                    opacity: menuOpacity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: _headerHeight,
                          child: const Padding(
                            padding: EdgeInsets.only(left: 18, right: 48),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Sort',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppleColors.label,
                                ),
                              ),
                            ),
                          ),
                        ),
                        for (var i = 0; i < widget.options.length; i++) ...[
                          if (i > 0)
                            Divider(
                              height: 1,
                              thickness: 0.6,
                              color: Colors.white.withValues(alpha: 0.45),
                              indent: 16,
                              endIndent: 16,
                            ),
                          _SortOptionTile(
                            label: widget.options[i].label,
                            isSelected:
                                widget.options[i].value == widget.selectedValue,
                            onTap: () => _select(widget.options[i].value),
                          ),
                        ],
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                Positioned(
                  top: 0,
                  right: 0,
                  width: _buttonSize,
                  height: _buttonSize,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _toggle,
                      customBorder: const CircleBorder(),
                      child: Icon(
                        _isOpen ? Icons.close_rounded : Icons.tune_rounded,
                        size: 20,
                        color:
                            _isOpen ? AppleColors.blue : AppleColors.label,
                      ),
                    ),
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
        child: SizedBox(
          height: LiquidGlassSortMenu.optionHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: AppleTextStyles.footnote.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
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
      ),
    );
  }
}
