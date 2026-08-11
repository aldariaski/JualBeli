import '../../product/data/product_model.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice {
    return product.price * quantity;
  }

  factory CartItem.fromJson(
    Map<String, dynamic> json,
  ) {
    final product = Product(
      id: json['productId'] as int,
      name: json['productName'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String?,
      category: json['category'] as String,
      sellerName:
          json['sellerName'] as String,
      sellerEmail:
          json['sellerEmail'] as String,
    );

    return CartItem(
      product: product,
      quantity: json['quantity'] as int,
    );
  }
}