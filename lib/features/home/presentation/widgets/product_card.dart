import 'package:flutter/material.dart';

import '../../../product/data/product_model.dart';
import '../../../product/data/price_formatter.dart';
import '../../../product/presentation/pages/product_detail_page.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  final Product product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailPage(
                  product: product,
                ),
              ),
            );
          },
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: product.image != null &&
                        product.image!.isNotEmpty
                    ? Image.network(
                        product.image!,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                      )
                    : const SizedBox(
                        width: double.infinity,
                        height: 150,
                        child: Icon(
                          Icons.image,
                          size: 60,
                        ),
                      ),
              ),

              const SizedBox(height: 12),

              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                formatPrice(product.price),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}