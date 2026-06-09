import 'package:flutter/material.dart';

import '../data/cart_entry.dart';
import '../theme/apple_theme.dart';
import 'product_image.dart';

class CartItemTile extends StatelessWidget {
  final CartEntry entry;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.entry,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final product = entry.product;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.all(16),
      decoration: AppleDecorations.card,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppleRadius.tile),
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
                Text(product.name, style: AppleTextStyles.headline),
                const SizedBox(height: 4),
                Text(product.tagline, style: AppleTextStyles.footnote),
                const SizedBox(height: 10),
                Text(product.price, style: AppleTextStyles.price),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onTap: onDecrement,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        '${entry.quantity}',
                        style: AppleTextStyles.headline,
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      onTap: onIncrement,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: onRemove,
                      style: TextButton.styleFrom(
                        foregroundColor: AppleColors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppleColors.canvas,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, size: 18, color: AppleColors.label),
        ),
      ),
    );
  }
}
