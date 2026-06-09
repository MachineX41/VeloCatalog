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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: AppleColors.card,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(
              color: AppleColors.separator.withValues(alpha: 0.55),
            ),
          ),
          child: InkWell(
            onTap: onPressed ?? () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(22),
            splashColor: AppleColors.blue.withValues(alpha: 0.08),
            highlightColor: AppleColors.canvas,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 16, 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: AppleColors.label,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: AppleTextStyles.footnote.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppleColors.label,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
