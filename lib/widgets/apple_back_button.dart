import 'package:flutter/material.dart';

import '../theme/apple_theme.dart';

class AppleBackButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const AppleBackButton({
    super.key,
    this.label = 'Back',
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onPressed ?? () => Navigator.pop(context),
        icon: const Icon(Icons.chevron_left, size: 30),
        label: Text(
          label,
          style: AppleTextStyles.headline.copyWith(fontWeight: FontWeight.w400),
        ),
        style: TextButton.styleFrom(
          foregroundColor: AppleColors.label,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
      ),
    );
  }
}
