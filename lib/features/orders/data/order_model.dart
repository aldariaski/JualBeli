class Order {
  final int id;
  final String email;
  final double totalAmount;
  final String status;
  final DateTime? createdAt;

  const Order({required this.id, required this.email, required this.totalAmount,
    required this.status, required this.createdAt});

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: (json['id'] as num).toInt(),
    email: json['email']?.toString() ?? '',
    totalAmount: (json['totalAmount'] as num).toDouble(),
    status: json['status']?.toString() ?? '',
    createdAt: json['createdAt'] == null ? null : DateTime.tryParse(json['createdAt'].toString()),
  );
}

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double price;
  final String name;
  final String? image;

  const OrderItem({required this.id, required this.orderId, required this.productId,
    required this.quantity, required this.price, required this.name, required this.image});

  double get subtotal => price * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: (json['id'] as num).toInt(),
    orderId: (json['orderId'] as num).toInt(),
    productId: (json['productId'] as num).toInt(),
    quantity: (json['quantity'] as num).toInt(),
    price: (json['price'] as num).toDouble(),
    name: json['name']?.toString() ?? 'Product unavailable',
    image: json['image']?.toString(),
  );
}
