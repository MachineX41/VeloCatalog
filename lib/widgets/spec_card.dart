import 'package:flutter/material.dart';

import '../theme/apple_theme.dart';
import 'liquid_glass_surface.dart';

class SpecCard extends StatelessWidget {
  final String label;
  final String value;

  const SpecCard({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LiquidGlassCard(
        borderRadius: BorderRadius.circular(AppleRadius.tile),
        blurSigma: 18,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        child: Column(
          children: [
            Text(label.toUpperCase(), style: AppleTextStyles.cardCategory),
            const SizedBox(height: 10),
            Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppleTextStyles.footnote.copyWith(
                fontWeight: FontWeight.w600,
                color: AppleColors.label,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
