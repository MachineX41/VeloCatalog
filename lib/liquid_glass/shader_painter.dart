import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ShaderPainter extends CustomPainter {
  ShaderPainter(this.shader);

  final ui.FragmentShader shader;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    try {
      final paint = Paint()..shader = shader;
      canvas.drawRect(Offset.zero & size, paint);
    } catch (_) {
      final paint = Paint()..color = Colors.transparent;
      canvas.drawRect(Offset.zero & size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ShaderPainter oldDelegate) => true;
}
