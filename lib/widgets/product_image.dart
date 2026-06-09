import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.contain,
  });

  String get _assetPath {
    final filename = imageUrl.split('/').last;
    return 'assets/images/products/$filename';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.asset(
        _assetPath,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Image.network(
            imageUrl,
            fit: fit,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) => const Icon(
              Icons.image_not_supported_outlined,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }
}
