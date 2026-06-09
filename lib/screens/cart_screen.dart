import 'package:flutter/material.dart';

import '../data/cart_entry.dart';
import '../data/product.dart';
import '../theme/apple_theme.dart';
import '../widgets/apple_back_button.dart';
import '../widgets/apple_primary_button.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/glass_bar.dart';

class CartScreen extends StatefulWidget {
  final List<CartEntry> cartEntries;
  final void Function(Product product) onIncrement;
  final void Function(Product product) onDecrement;
  final void Function(Product product) onRemove;

  const CartScreen({
    super.key,
    required this.cartEntries,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
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
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, top: 4),
              child: AppleBackButton(label: 'Bag'),
            ),
            Expanded(
              child: isEmpty
                  ? Center(
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
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: CartItemTile(
                            entry: entry,
                            onIncrement: () {
                              widget.onIncrement(entry.product);
                              _refresh();
                            },
                            onDecrement: () {
                              widget.onDecrement(entry.product);
                              _refresh();
                            },
                            onRemove: () {
                              widget.onRemove(entry.product);
                              _refresh();
                            },
                          ),
                        );
                      },
                    ),
            ),
            GlassBar(
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
                    label: isEmpty ? 'Check Out' : 'Check Out — ${formatPrice(_total)}',
                    accent: false,
                    onPressed: isEmpty
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Checkout simulation complete!'),
                              ),
                            );
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
