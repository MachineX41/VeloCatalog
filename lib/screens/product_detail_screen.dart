import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/product.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_back_button.dart';
import '../widgets/apple_primary_button.dart';
import '../widgets/apple_toast.dart';
import '../widgets/liquid_glass_bar.dart';
import '../widgets/product_image.dart';
import '../widgets/spec_card.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final void Function(Product product) onAddToCart;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isAdding = false;

  Future<void> _handleAddToCart() async {
    if (_isAdding) return;

    setState(() => _isAdding = true);
    HapticFeedback.mediumImpact();
    widget.onAddToCart(widget.product);

    AppleToast.show(
      context,
      title: 'Added to Bag',
      subtitle: widget.product.name,
      imageUrl: widget.product.image,
    );

    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (mounted) setState(() => _isAdding = false);
  }

  @override
  Widget build(BuildContext context) {
    final specs = widget.product.specEntries.take(3).toList();

    return Scaffold(
      backgroundColor: AppleColors.canvas,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 4),
              child: AppleBackButton(),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
                      child: Hero(
                        tag: 'product-${widget.product.id}',
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppleRadius.card),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: DecoratedBox(
                              decoration: AppleDecorations.card,
                              child: ProductImage(
                                imageUrl: widget.product.image,
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
                            widget.product.categoryLabel.toUpperCase(),
                            style: AppleTextStyles.cardCategory,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.product.name,
                            style: AppleTextStyles.largeTitle,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.product.tagline,
                            style: AppleTextStyles.callout,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.product.price,
                            style: AppleTextStyles.title3,
                          ),
                          const SizedBox(height: AppleSpacing.section),
                          Text('Overview', style: AppleTextStyles.title3),
                          const SizedBox(height: 12),
                          Text(
                            widget.product.description,
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
          ],
        ),
      ),
      bottomNavigationBar: LiquidGlassBar(
        child: AnimatedScale(
          scale: _isAdding ? 0.97 : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: ApplePrimaryButton(
            label: _isAdding
                ? 'Added — ${widget.product.price}'
                : 'Add to Cart — ${widget.product.price}',
            onPressed: _isAdding ? null : _handleAddToCart,
          ),
        ),
      ),
    );
  }
}
