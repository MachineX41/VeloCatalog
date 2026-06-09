import 'package:flutter/material.dart';

import '../data/product.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_back_button.dart';
import '../widgets/apple_primary_button.dart';
import '../widgets/product_image.dart';
import '../widgets/spec_card.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final void Function(Product product) onAddToCart;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final specs = product.specEntries.take(3).toList();

    return Scaffold(
      backgroundColor: AppleColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, top: 4),
              child: AppleBackButton(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
                      child: Hero(
                        tag: 'product-${product.id}',
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppleRadius.card),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: DecoratedBox(
                              decoration: AppleDecorations.card,
                              child: ProductImage(
                                imageUrl: product.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppleSpacing.screen,
                        AppleSpacing.section,
                        AppleSpacing.screen,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.categoryLabel.toUpperCase(),
                            style: AppleTextStyles.cardCategory,
                          ),
                          const SizedBox(height: 12),
                          Text(product.name, style: AppleTextStyles.largeTitle),
                          const SizedBox(height: 10),
                          Text(product.tagline, style: AppleTextStyles.callout),
                          const SizedBox(height: 12),
                          Text(product.price, style: AppleTextStyles.title3),
                          const SizedBox(height: AppleSpacing.section),
                          Text('Overview', style: AppleTextStyles.title3),
                          const SizedBox(height: 12),
                          Text(
                            product.description,
                            style: AppleTextStyles.body,
                          ),
                          const SizedBox(height: AppleSpacing.section),
                          Text('Specifications', style: AppleTextStyles.title3),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              for (var i = 0; i < specs.length; i++) ...[
                                if (i > 0) const SizedBox(width: 10),
                                SpecCard(
                                  label: specs[i].key,
                                  value: specs[i].value,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            DecoratedBox(
              decoration: const BoxDecoration(
                color: AppleColors.card,
                border: Border(
                  top: BorderSide(color: Color(0x33D2D2D7)),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
                child: ApplePrimaryButton(
                  label: 'Add to Cart — ${product.price}',
                  onPressed: () {
                    onAddToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.name} added to your bag'),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
