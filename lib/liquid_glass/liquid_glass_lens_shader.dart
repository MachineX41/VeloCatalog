import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import 'base_shader.dart';

class LiquidGlassLensShader extends BaseShader {
  LiquidGlassLensShader()
      : super(shaderAssetPath: 'shaders/liquid_glass_lens.frag');

  @override
  void updateShaderUniforms({
    required double width,
    required double height,
    required ui.Image? backgroundImage,
    double cornerRadius = 0,
  }) {
    if (!isLoaded) return;

    shader.setFloat(0, width);
    shader.setFloat(1, height);
    shader.setFloat(2, cornerRadius);
    shader.setFloat(3, 4.5);
    shader.setFloat(4, 0.08);

    if (backgroundImage != null &&
        backgroundImage.width > 0 &&
        backgroundImage.height > 0) {
      try {
        shader.setImageSampler(0, backgroundImage);
      } catch (e) {
        debugPrint('Error setting background texture: $e');
      }
    }
  }
}
