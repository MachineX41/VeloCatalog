import 'product.dart';

class CartEntry {
  final Product product;
  int quantity;

  CartEntry({
    required this.product,
    this.quantity = 1,
  });

  double get lineTotal => parsePrice(product.price) * quantity;
}

double parsePrice(String price) {
  return double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
}
