import 'package:flutter/material.dart';

import 'data/cart_entry.dart';
import 'data/product.dart';
import 'screens/cart_screen.dart';
import 'screens/discover_screen.dart';
import 'theme/apple_theme.dart';

void main() {
  runApp(const VeloCatalogApp());
}

class VeloCatalogApp extends StatefulWidget {
  const VeloCatalogApp({super.key});

  @override
  State<VeloCatalogApp> createState() => _VeloCatalogAppState();
}

class _VeloCatalogAppState extends State<VeloCatalogApp> {
  final List<CartEntry> _cartEntries = [];

  int get _cartCount =>
      _cartEntries.fold(0, (sum, entry) => sum + entry.quantity);

  void _addToCart(Product product) {
    setState(() {
      final existing = _cartEntries
          .where((entry) => entry.product.id == product.id)
          .firstOrNull;
      if (existing != null) {
        existing.quantity++;
      } else {
        _cartEntries.add(CartEntry(product: product));
      }
    });
  }

  void _incrementQuantity(Product product) {
    setState(() {
      final entry = _cartEntries
          .where((item) => item.product.id == product.id)
          .firstOrNull;
      entry?.quantity++;
    });
  }

  void _decrementQuantity(Product product) {
    setState(() {
      final entry = _cartEntries
          .where((item) => item.product.id == product.id)
          .firstOrNull;
      if (entry == null) return;
      if (entry.quantity > 1) {
        entry.quantity--;
      } else {
        _cartEntries.remove(entry);
      }
    });
  }

  void _removeFromCart(Product product) {
    setState(() {
      _cartEntries.removeWhere((entry) => entry.product.id == product.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VeloCatalog',
      debugShowCheckedModeBanner: false,
      theme: buildAppleTheme(),
      home: DiscoverScreen(
        cartCount: _cartCount,
        cartEntries: _cartEntries,
        onAddToCart: _addToCart,
        onIncrement: _incrementQuantity,
        onDecrement: _decrementQuantity,
        onRemoveFromCart: _removeFromCart,
      ),
      routes: {
        '/cart': (context) => CartScreen(
              cartEntries: _cartEntries,
              onIncrement: _incrementQuantity,
              onDecrement: _decrementQuantity,
              onRemove: _removeFromCart,
            ),
      },
    );
  }
}
