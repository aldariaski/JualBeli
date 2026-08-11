import '../models/cart_item.dart';
import '../repositories/cart_repository.dart';

class CartService {
  final CartRepository _repository;

  CartService({
    CartRepository? repository,
  }) : _repository =
            repository ?? CartRepository();

  Future<List<CartItem>> getCart(
    String userEmail,
  ) {
    return _repository.findByUser(
      userEmail,
    );
  }

  Future<void> addToCart(
    String userEmail,
    int productId,
  ) {
    return _repository.addOrIncrease(
      userEmail,
      productId,
    );
  }

  Future<void> updateQuantity(
    String userEmail,
    int productId,
    int quantity,
  ) {
    return _repository.updateQuantity(
      userEmail,
      productId,
      quantity,
    );
  }

  Future<void> removeFromCart(
    String userEmail,
    int productId,
  ) {
    return _repository.remove(
      userEmail,
      productId,
    );
  }

  Future<void> clearCart(
    String userEmail,
  ) {
    return _repository.clear(
      userEmail,
    );
  }
}