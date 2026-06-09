import 'package:flutter_test/flutter_test.dart';
import 'package:velo_catalog/data/product.dart';

void main() {
  test('Product fromJson and toJson', () {
    final json = {
      'id': 1,
      'name': 'AirPods Pro (2nd Gen)',
      'tagline': 'Adaptive Audio.',
      'description': 'Test description',
      'price': '\$249',
      'currency': 'USD',
      'image': 'https://example.com/airpods.png',
      'specs': {
        'chip': 'H2',
        'audio': 'Spatial Audio',
        'case': 'USB-C',
      },
    };

    final product = Product.fromJson(json);
    expect(product.name, 'AirPods Pro (2nd Gen)');
    expect(product.specs['chip'], 'H2');

    final encoded = product.toJson();
    expect(encoded['name'], 'AirPods Pro (2nd Gen)');
    expect(encoded['specs'], isA<Map<String, String>>());
  });
}
