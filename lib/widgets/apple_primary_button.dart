import 'package:flutter/material.dart';

import '../theme/apple_theme.dart';

class ApplePrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool accent;

  const ApplePrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.accent = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: onPressed == null ? 0.55 : 1,
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                accent ? AppleColors.blue : AppleColors.label,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppleColors.fill,
            disabledForegroundColor: AppleColors.secondaryLabel,
            elevation: 0,
            shadowColor: accent
                ? AppleColors.blue.withValues(alpha: 0.28)
                : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 28),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppleRadius.button),
            ),
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
