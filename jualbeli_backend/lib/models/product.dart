class Product {
  final int id;
  final String name;
  final double price;
  final String? image;
  final String category;
  final String sellerName;
  final String sellerEmail;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.image,
    required this.category,
    required this.sellerName,
    required this.sellerEmail,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['Id'] as int,
      name: map['Name'] as String,
      price: (map['Price'] as num).toDouble(),
      image: map['Image'] as String?,
      category: map['Category'] as String,
      sellerName: map['SellerName'] as String,
      sellerEmail: map['SellerEmail'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'category': category,
      'sellerName': sellerName,
      'sellerEmail': sellerEmail,
    };
  }
}