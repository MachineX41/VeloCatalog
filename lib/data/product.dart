class Product {
  final int id;
  final String name;
  final String tagline;
  final String description;
  final String price;
  final String currency;
  final String image;
  final Map<String, String> specs;

  const Product({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.price,
    required this.currency,
    required this.image,
    required this.specs,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final specsJson = json['specs'] as Map<String, dynamic>? ?? {};
    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      tagline: json['tagline'] as String,
      description: json['description'] as String,
      price: json['price'] as String,
      currency: json['currency'] as String,
      image: json['image'] as String,
      specs: specsJson.map((key, value) => MapEntry(key, value.toString())),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tagline': tagline,
      'description': description,
      'price': price,
      'currency': currency,
      'image': image,
      'specs': specs,
    };
  }

  List<MapEntry<String, String>> get specEntries => specs.entries.toList();

  String get categoryLabel {
    if (name.startsWith('iPhone')) return 'iPhone';
    if (name.startsWith('MacBook')) return 'MacBook';
    if (name.startsWith('iPad')) return 'iPad';
    if (name.startsWith('AirPods')) return 'AirPods';
    if (name.startsWith('HomePod')) return 'HomePod';
    if (name.startsWith('Apple Watch')) return 'Apple Watch';
    if (name.startsWith('Apple Vision')) return 'Apple Vision';
    if (name.startsWith('iMac')) return 'iMac';
    return 'Apple';
  }

  double get priceValue {
    return double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
  }
}
