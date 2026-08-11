import '../models/product.dart';
import '../repositories/product_repository.dart';

class ProductService {
  final ProductRepository _productRepository;

  ProductService({
    ProductRepository? productRepository,
  }) : _productRepository =
            productRepository ?? ProductRepository();

  Future<List<Product>> getProducts() {
    return _productRepository.getAll();
  }

  Future<Product> getProduct(int id) async {
    final product = await _productRepository.findById(id);

    if (product == null) {
      throw Exception('Product not found.');
    }

    return product;
  }
}