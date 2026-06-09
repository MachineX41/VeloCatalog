import 'package:flutter/material.dart';

import 'data/product.dart';
import 'screens/cart_screen.dart';
import 'screens/discover_screen.dart';

void main() {
  runApp(const VeloCatalogApp());
}

class VeloCatalogApp extends StatefulWidget {
  const VeloCatalogApp({super.key});

  @override
  State<VeloCatalogApp> createState() => _VeloCatalogAppState();
}

class _VeloCatalogAppState extends State<VeloCatalogApp> {
  final List<Product> _cartItems = [];

  void _addToCart(Product product) {
    setState(() => _cartItems.add(product));
  }

  void _removeFromCart(Product product) {
    setState(() {
      final index = _cartItems.indexOf(product);
      if (index != -1) {
        _cartItems.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VeloCatalog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: DiscoverScreen(
        cartItems: _cartItems,
        onAddToCart: _addToCart,
        onRemoveFromCart: _removeFromCart,
      ),
      routes: {
        '/cart': (context) => CartScreen(
              cartItems: _cartItems,
              onRemove: _removeFromCart,
            ),
      },
    );
  }
}
