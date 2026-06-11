import 'package:flutter/material.dart';

import '../data/cart_entry.dart';
import '../data/product.dart';
import '../theme/apple_theme.dart';
import '../widgets/animated_cart_item.dart';
import '../widgets/apple_back_button.dart';
import '../widgets/apple_primary_button.dart';
import '../widgets/apple_toast.dart';
import '../widgets/liquid_glass_bar.dart';

class CartScreen extends StatefulWidget {
  final List<CartEntry> cartEntries;
  final void Function(Product product) onAddToCart;
  final void Function(Product product) onIncrement;
  final void Function(Product product) onDecrement;
  final void Function(Product product) onRemove;
  final bool showBackButton;
  final double bottomInset;

  const CartScreen({
    super.key,
    required this.cartEntries,
    required this.onAddToCart,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
    this.showBackButton = true,
    this.bottomInset = 0,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  void _refresh() => setState(() {});

  double get _total =>
      widget.cartEntries.fold(0, (sum, entry) => sum + entry.lineTotal);

  int get _itemCount =>
      widget.cartEntries.fold(0, (sum, entry) => sum + entry.quantity);

  @override
  Widget build(BuildContext context) {
    final isEmpty = widget.cartEntries.isEmpty;

    return Scaffold(
      backgroundColor: AppleColors.canvas,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: widget.bottomInset),
          child: Column(
            children: [
              if (widget.showBackButton)
                const Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 4),
                  child: AppleBackButton(label: 'Bag'),
                )
              else
                const Padding(
                  padding: EdgeInsets.fromLTRB(22, 12, 22, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Bag', style: AppleTextStyles.largeTitle),
                  ),
                ),
              Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: isEmpty
                    ? Center(
                        key: const ValueKey('empty-bag'),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 56,
                              color: AppleColors.fill,
                            ),
                            const SizedBox(height: 22),
                            Text(
                              'Your bag is empty',
                              style: AppleTextStyles.title2,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Add items to start shopping.',
                              style: AppleTextStyles.subheadline,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        key: ValueKey<int>(widget.cartEntries.length),
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          AppleSpacing.screen,
                          8,
                          AppleSpacing.screen,
                          120,
                        ),
                        itemCount: widget.cartEntries.length,
                        itemBuilder: (context, index) {
                          final entry = widget.cartEntries[index];
                          return AnimatedCartItem(
                            key: ValueKey<int>(entry.product.id),
                            entry: entry,
                            onAddToCart: widget.onAddToCart,
                            onIncrement: () {
                              widget.onIncrement(entry.product);
                              _refresh();
                            },
                            onDecrement: () {
                              widget.onDecrement(entry.product);
                              _refresh();
                            },
                            onRemoved: () {
                              widget.onRemove(entry.product);
                              _refresh();
                            },
                          );
                        },
                      ),
              ),
            ),
            LiquidGlassBar(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!isEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal · $_itemCount items',
                          style: AppleTextStyles.subheadline,
                        ),
                        Text(
                          formatPrice(_total),
                          style: AppleTextStyles.title3,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                  ApplePrimaryButton(
                    label: isEmpty
                        ? 'Check Out'
                        : 'Check Out — ${formatPrice(_total)}',
                    onPressed: isEmpty
                        ? null
                        : () {
                            AppleToast.show(
                              context,
                              title: 'Order Confirmed',
                              subtitle:
                                  '${formatPrice(_total)} · $_itemCount items',
                              kind: AppleToastKind.success,
                            );
                          },
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}
