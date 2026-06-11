import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'base_shader.dart';
import 'shader_painter.dart';

/// Captures the region behind this widget and renders a liquid glass shader lens.
class LiquidGlassCapture extends StatefulWidget {
  const LiquidGlassCapture({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    required this.shader,
    this.backgroundKey,
    this.borderRadius = BorderRadius.zero,
    this.captureInterval = const Duration(milliseconds: 32),
  });

  final Widget child;
  final double width;
  final double height;
  final BaseShader shader;
  final GlobalKey? backgroundKey;
  final BorderRadius borderRadius;
  final Duration captureInterval;

  @override
  State<LiquidGlassCapture> createState() => _LiquidGlassCaptureState();
}

class _LiquidGlassCaptureState extends State<LiquidGlassCapture> {
  Timer? _timer;
  bool _isCapturing = false;
  ui.Image? _capturedBackground;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.captureInterval, (_) {
      if (mounted && !_isCapturing) {
        _captureBackground();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _captureBackground());
  }

  @override
  void didUpdateWidget(covariant LiquidGlassCapture oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.width != widget.width ||
        oldWidget.height != widget.height) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _captureBackground());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _capturedBackground?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.shader.isLoaded && _capturedBackground != null) {
      widget.shader.updateShaderUniforms(
        width: widget.width,
        height: widget.height,
        backgroundImage: _capturedBackground,
        cornerRadius: _effectiveCornerRadius(),
      );
      return Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: Color(0xFFF2F2F7)),
          CustomPaint(
            painter: ShaderPainter(widget.shader.shader),
          ),
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0x80FFFFFF),
                    const Color(0x4DFFFFFF),
                  ],
                ),
              ),
            ),
          ),
          widget.child,
        ],
      );
    }

    return widget.child;
  }

  double _effectiveCornerRadius() {
    final br = widget.borderRadius;
    final maxR = math.max(
      math.max(br.topLeft.x, br.topRight.x),
      math.max(br.bottomLeft.x, br.bottomRight.x),
    );
    return maxR.clamp(0.0, math.min(widget.width, widget.height) / 2);
  }

  Future<void> _captureBackground() async {
    if (_isCapturing || !mounted) return;
    _isCapturing = true;

    try {
      final boundary = widget.backgroundKey?.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      final ourBox = context.findRenderObject() as RenderBox?;

      if (boundary == null ||
          !boundary.attached ||
          ourBox == null ||
          !ourBox.hasSize) {
        return;
      }

      final boundaryBox = boundary;
      if (!boundaryBox.hasSize || widget.width <= 0 || widget.height <= 0) {
        return;
      }

      final topLeft = boundaryBox.globalToLocal(
        ourBox.localToGlobal(Offset.zero),
      );
      final bottomRight = boundaryBox.globalToLocal(
        ourBox.localToGlobal(ourBox.size.bottomRight(Offset.zero)),
      );
      final widgetRect = Rect.fromPoints(topLeft, bottomRight);
      final boundaryRect = Offset.zero & boundaryBox.size;
      final region = widgetRect.intersect(boundaryRect);

      if (region.isEmpty) return;

      final pixelRatio = MediaQuery.devicePixelRatioOf(context);
      final fullImage = await boundary.toImage(pixelRatio: pixelRatio);

      final src = Rect.fromLTWH(
        region.left * pixelRatio,
        region.top * pixelRatio,
        region.width * pixelRatio,
        region.height * pixelRatio,
      );
      final dst = Rect.fromLTWH(
        0,
        0,
        region.width * pixelRatio,
        region.height * pixelRatio,
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawRect(
        dst,
        Paint()..color = const Color(0xFFF2F2F7),
      );
      canvas.drawImageRect(fullImage, src, dst, Paint());
      fullImage.dispose();

      final picture = recorder.endRecording();
      final cropped = await picture.toImage(
        (region.width * pixelRatio).round(),
        (region.height * pixelRatio).round(),
      );
      picture.dispose();

      if (mounted) {
        setState(() {
          _capturedBackground?.dispose();
          _capturedBackground = cropped;
        });
      } else {
        cropped.dispose();
      }
    } catch (e) {
      debugPrint('Liquid glass capture error: $e');
    } finally {
      if (mounted) _isCapturing = false;
    }
  }
}
