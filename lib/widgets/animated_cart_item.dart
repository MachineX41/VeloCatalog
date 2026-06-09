import 'package:flutter/material.dart';

import '../data/cart_entry.dart';
import '../data/product.dart';
import '../screens/product_detail_screen.dart';
import '../theme/apple_theme.dart';
import 'apple_toast.dart';
import 'cart_item_tile.dart';
import 'swipeable_cart_row.dart';

class AnimatedCartItem extends StatefulWidget {
  final CartEntry entry;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemoved;
  final void Function(Product product) onAddToCart;

  const AnimatedCartItem({
    super.key,
    required this.entry,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemoved,
    required this.onAddToCart,
  });

  @override
  State<AnimatedCartItem> createState() => _AnimatedCartItemState();
}

class _AnimatedCartItemState extends State<AnimatedCartItem>
    with SingleTickerProviderStateMixin {
  final GlobalKey<SwipeableCartRowState> _swipeKey = GlobalKey();
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _size;
  late final Animation<Offset> _slide;
  bool _isRemoving = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _size = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0.08, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));
    _controller.value = 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRemove() async {
    if (_isRemoving) return;
    _isRemoving = true;
    _swipeKey.currentState?.close();

    final product = widget.entry.product;
    AppleToast.show(
      context,
      title: 'Removed from Bag',
      subtitle: product.name,
      imageUrl: product.image,
      kind: AppleToastKind.removed,
    );

    await _controller.reverse();
    if (mounted) widget.onRemoved();
  }

  void _openDetail() {
    _swipeKey.currentState?.close();
    Navigator.push(
      context,
      createAppleRoute(
        ProductDetailScreen(
          product: widget.entry.product,
          onAddToCart: widget.onAddToCart,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SizeTransition(
        sizeFactor: _size,
        axisAlignment: -1,
        child: SlideTransition(
          position: _slide,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: SwipeableCartRow(
              key: _swipeKey,
              onDelete: _handleRemove,
              onDetail: _openDetail,
              child: CartItemTile(
                entry: widget.entry,
                showCloseButton: false,
                flatTrailingEdge: true,
                onIncrement: widget.onIncrement,
                onDecrement: widget.onDecrement,
                onRemove: _handleRemove,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
