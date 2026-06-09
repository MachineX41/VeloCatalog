import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/cart_entry.dart';
import '../theme/apple_theme.dart';
import 'liquid_glass_surface.dart';
import 'product_image.dart';

class CartItemTile extends StatelessWidget {
  final CartEntry entry;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;
  final bool showCloseButton;
  final bool flatTrailingEdge;

  const CartItemTile({
    super.key,
    required this.entry,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    this.showCloseButton = true,
    this.flatTrailingEdge = false,
  });

  @override
  Widget build(BuildContext context) {
    final product = entry.product;

    final borderRadius = flatTrailingEdge
        ? const BorderRadius.only(
            topLeft: Radius.circular(AppleRadius.card),
            bottomLeft: Radius.circular(AppleRadius.card),
          )
        : BorderRadius.circular(AppleRadius.card);

    return LiquidGlassCard(
      borderRadius: borderRadius,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              14,
              14,
              showCloseButton ? 44 : 14,
              52,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: ProductImage(
                      imageUrl: product.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppleTextStyles.headline.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.tagline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppleTextStyles.footnote,
                      ),
                      const SizedBox(height: 10),
                      Text(product.price, style: AppleTextStyles.price),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (showCloseButton)
            Positioned(
              top: 10,
              right: 10,
              child: _IconAction(
                icon: Icons.close_rounded,
                onTap: onRemove,
                size: 15,
              ),
            ),
          Positioned(
            bottom: 12,
            right: 12,
            child: _QuantityStepper(
              quantity: entry.quantity,
              onIncrement: onIncrement,
              onDecrement: onDecrement,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantityStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return LiquidGlassSurface(
      borderRadius: BorderRadius.circular(18),
      blurSigma: 16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperTap(
            icon: Icons.remove_rounded,
            onTap: onDecrement,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            child: SizedBox(
              key: ValueKey<int>(quantity),
              width: 28,
              child: Text(
                '$quantity',
                textAlign: TextAlign.center,
                style: AppleTextStyles.footnote.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppleColors.label,
                ),
              ),
            ),
          ),
          _StepperTap(
            icon: Icons.add_rounded,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _StepperTap extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _StepperTap({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, size: 16, color: AppleColors.label),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _IconAction({
    required this.icon,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppleColors.canvas,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(icon, size: size, color: AppleColors.secondaryLabel),
        ),
      ),
    );
  }
}
