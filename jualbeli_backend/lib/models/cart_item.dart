class CartItem {
  final int id;
  final String userEmail;
  final int productId;
  final int quantity;

  final String productName;
  final double price;
  final String? image;
  final String category;
  final String sellerName;
  final String sellerEmail;

  const CartItem({
    required this.id,
    required this.userEmail,
    required this.productId,
    required this.quantity,
    required this.productName,
    required this.price,
    this.image,
    required this.category,
    required this.sellerName,
    required this.sellerEmail,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userEmail': userEmail,
      'productId': productId,
      'quantity': quantity,
      'productName': productName,
      'price': price,
      'image': image,
      'category': category,
      'sellerName': sellerName,
      'sellerEmail': sellerEmail,
    };
  }
}