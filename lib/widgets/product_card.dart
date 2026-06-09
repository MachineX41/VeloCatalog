import 'package:flutter/material.dart';

import '../data/product.dart';
import '../theme/apple_theme.dart';
import 'product_image.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          decoration: AppleDecorations.card,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 58,
                child: Hero(
                  tag: 'product-${widget.product.id}',
                  child: DecoratedBox(
                    decoration: AppleDecorations.imageWell,
                    child: ProductImage(
                      imageUrl: widget.product.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 42,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.categoryLabel.toUpperCase(),
                        style: AppleTextStyles.cardCategory,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppleTextStyles.cardTitle.copyWith(fontSize: 14),
                      ),
                      const Spacer(),
                      Text(
                        widget.product.tagline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppleTextStyles.cardSubtitle,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.product.price,
                        style: AppleTextStyles.price.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
