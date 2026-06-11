import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/services.dart';

import '../liquid_glass/liquid_glass_capture.dart';
import '../liquid_glass/liquid_glass_lens_shader.dart';
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
  final GlobalKey? backgroundKey;

  const LiquidGlassSortMenu({
    super.key,
    required this.selectedValue,
    required this.onSelected,
    required this.options,
    this.onOpenChanged,
    this.backgroundKey,
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
  late final LiquidGlassLensShader _lensShader;
  bool _isOpen = false;
  bool _shaderReady = false;

  @override
  void initState() {
    super.initState();
    _lensShader = LiquidGlassLensShader()..initialize().then((_) {
      if (mounted) setState(() => _shaderReady = true);
    });
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
    final delayed = ((raw - 0.16) / 0.84).clamp(0.0, 1.0);
    return Curves.easeOutBack.transform(delayed);
  }

  BorderRadius _dropletRadius(double raw) {
    if (raw < 0.02) {
      return BorderRadius.circular(_buttonSize / 2);
    }

    final w = _widthProgress(raw);
    final h = _heightProgress(raw);
    final topR = lerpDouble(_buttonSize / 2, 24, w)!;
    final sideR = lerpDouble(_buttonSize / 2, 24, h)!;
    final bulge = math.sin(raw * math.pi) * 8;

    return BorderRadius.only(
      topLeft: Radius.circular(topR),
      topRight: Radius.circular(topR),
      bottomRight: Radius.circular(sideR),
      bottomLeft: Radius.circular(sideR + bulge),
    );
  }

  Future<void> _animateTo(double target) async {
    _controller.stop();
    final opening = target > _t;
    final simulation = SpringSimulation(
      SpringDescription(
        mass: opening ? 1.4 : 1.25,
        stiffness: opening ? 110 : 140,
        damping: opening ? 16 : 19,
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

  bool get _useShader =>
      widget.backgroundKey != null && _shaderReady && _lensShader.isLoaded;

  @override
  Widget build(BuildContext context) {
    final raw = _t;
    final widthP = _widthProgress(raw);
    final heightP = _heightProgress(raw);
    final width = lerpDouble(_buttonSize, _expandedWidth, widthP)!;
    final height = lerpDouble(_buttonSize, _expandedHeight, heightP)!;
    final radius = _dropletRadius(raw);
    final menuOpacity =
        Curves.easeIn.transform(((raw - 0.4) / 0.48).clamp(0.0, 1.0));
    final showMenu = raw > 0.38 && height > _buttonSize + 20;
    final haloStrength = lerpDouble(0.04, 0.12, raw)!;

    final panelContent = _buildPanelContent(
      radius: radius,
      menuOpacity: menuOpacity,
      showMenu: showMenu,
    );

    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: AppleColors.blue.withValues(alpha: haloStrength * 0.35),
              blurRadius: 20 + raw * 16,
              spreadRadius: raw * 2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04 + raw * 0.06),
              blurRadius: 10 + raw * 18,
              offset: Offset(0, 4 + heightP * 10),
            ),
          ],
        ),
        child: _useShader
            ? LiquidGlassCapture(
                width: width,
                height: height,
                backgroundKey: widget.backgroundKey,
                borderRadius: radius,
                shader: _lensShader,
                child: panelContent,
              )
            : ClipRRect(
                borderRadius: radius,
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 16 + raw * 6,
                    sigmaY: 16 + raw * 6,
                  ),
                  child: panelContent,
                ),
              ),
      ),
    );
  }

  Widget _buildPanelContent({
    required BorderRadius radius,
    required double menuOpacity,
    required bool showMenu,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.78),
            width: 1.1,
          ),
          left: BorderSide(
            color: Colors.white.withValues(alpha: 0.5),
            width: 0.8,
          ),
          right: BorderSide(
            color: Colors.white.withValues(alpha: 0.28),
            width: 0.6,
          ),
          bottom: BorderSide(
            color: _useShader
                ? Colors.white.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.04),
            width: 0.5,
          ),
        ),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: _useShader
              ? [
                  Colors.white.withValues(alpha: 0.10),
                  Colors.white.withValues(alpha: 0.03),
                ]
              : [
                  AppleColors.card.withValues(alpha: 0.94),
                  AppleColors.card.withValues(alpha: 0.72),
                ],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          if (!_useShader)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    gradient: RadialGradient(
                      center: const Alignment(0.85, -0.75),
                      radius: 1.1,
                      colors: [
                        Colors.white.withValues(alpha: 0.32),
                        Colors.transparent,
                      ],
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
                    child: Padding(
                      padding: const EdgeInsets.only(left: 18, right: 48),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Sort',
                          style: AppleTextStyles.footnote.copyWith(
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
                        color: Colors.white.withValues(alpha: 0.4),
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
                  color: _isOpen ? AppleColors.blue : AppleColors.label,
                ),
              ),
            ),
          ),
        ],
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
