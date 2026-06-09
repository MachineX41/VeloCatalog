import 'dart:convert';

import 'package:flutter/services.dart';

import 'product.dart';

class ProductRepository {
  static Future<List<Product>> loadProducts() async {
    final jsonString =
        await rootBundle.loadString('assets/data/products.json');
    final decoded = json.decode(jsonString) as Map<String, dynamic>;
    final data = decoded['data'] as List<dynamic>;

    return data
        .map((item) => Product.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
