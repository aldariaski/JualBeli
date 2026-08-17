import 'package:flutter/material.dart';

import '../../../auth/data/auth_storage.dart';
import '../../data/cart_item.dart';
import '../../data/cart_service.dart';
import '../../../product/data/price_formatter.dart';
import '../../../checkout/presentation/pages/checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({
    super.key,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final CartService _cartService =
      CartService.instance;

  late Future<List<CartItem>> _cartFuture;

  // Products currently being updated.
  //
  // This prevents multiple PUT requests for the
  // same product from being sent simultaneously.
  final Set<int> _updatingProducts = {};

  @override
  void initState() {
    super.initState();

    _cartFuture = _loadCart();
  }

  Future<List<CartItem>> _loadCart() async {
    final email =
        await AuthStorage.getCurrentUserEmail();

    if (email == null || email.isEmpty) {
      throw Exception(
        'User email not found.',
      );
    }

    return await _cartService.getCart(email);
  }

  Future<void> _refreshCart() async {
    final future = _loadCart();

    setState(() {
      _cartFuture = future;
    });

    try {
      await future;
    } catch (_) {
      // FutureBuilder will display the error.
    }
  }

  Future<void> _changeQuantity(
    CartItem item,
    int newQuantity,
  ) async {
    final productId = item.product.id;

    // Prevent another request for this product
    // while the previous request is still running.
    if (_updatingProducts.contains(productId)) {
      return;
    }

    final email =
        await AuthStorage.getCurrentUserEmail();

    if (email == null || email.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'User email not found.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _updatingProducts.add(productId);
    });

    try {
      // Wait for PUT /cart/<productId> to finish.
      await _cartService.updateQuantity(
        email,
        productId,
        newQuantity,
      );

      // IMPORTANT:
      //
      // Wait for GET /cart/ to completely finish
      // before allowing another + or - operation.
      //
      // This prevents rapid clicks from creating
      // overlapping SQL requests.
      await _refreshCart();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update cart: $e',
          ),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _updatingProducts.remove(productId);
      });
    }
  }

  Future<void> _removeProduct(
    CartItem item,
  ) async {
    final productId = item.product.id;

    if (_updatingProducts.contains(productId)) {
      return;
    }

    final email =
        await AuthStorage.getCurrentUserEmail();

    if (email == null || email.isEmpty) {
      return;
    }

    setState(() {
      _updatingProducts.add(productId);
    });

    try {
      await _cartService.removeProduct(
        email,
        productId,
      );

      await _refreshCart();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to remove product: $e',
          ),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _updatingProducts.remove(productId);
      });
    }
  }

  Future<void> _clearCart() async {
    final email =
        await AuthStorage.getCurrentUserEmail();

    if (email == null || email.isEmpty) {
      return;
    }

    try {
      await _cartService.clearCart(email);

      await _refreshCart();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to clear cart: $e',
          ),
        ),
      );
    }
  }

  double _calculateTotal(
    List<CartItem> items,
  ) {
    double total = 0;

    for (final item in items) {
      total +=
          item.product.price * item.quantity;
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        actions: [
          FutureBuilder<List<CartItem>>(
            future: _cartFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                ),
                tooltip: 'Clear cart',
                onPressed: _clearCart,
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<CartItem>>(
        future: _cartFuture,
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load cart.',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign:
                          TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _refreshCart,
                      child: const Text(
                        'Retry',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final items =
              snapshot.data ?? [];

          // Empty cart
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 72,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Your cart is empty.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          final total =
              _calculateTotal(items);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder:
                      (context, index) {
                    final item = items[index];

                    final product =
                        item.product;

                    final productId =
                        product.id;

                    final isUpdating =
                        _updatingProducts
                            .contains(
                      productId,
                    );

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.all(
                          12,
                        ),
                        child: Row(
                          children: [
                            // Product image
                            Container(
                              width: 80,
                              height: 80,
                              decoration:
                                  BoxDecoration(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  8,
                                ),
                                color: Colors
                                    .grey
                                    .shade200,
                              ),
                              child:
                                  product.image !=
                                          null &&
                                      product
                                          .image!
                                          .isNotEmpty
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                            8,
                                          ),
                                          child:
                                              Image.network(
                                            product
                                                .image!,
                                            fit: BoxFit
                                                .cover,
                                            errorBuilder:
                                                (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return const Icon(
                                                Icons
                                                    .image_not_supported,
                                              );
                                            },
                                          ),
                                        )
                                      : const Icon(
                                          Icons
                                              .image_outlined,
                                          size: 32,
                                        ),
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            // Product information
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    product.name,
                                    maxLines: 2,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                    style:
                                        const TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 6,
                                  ),

                                  Text(
                                    formatPrice(
                                      product.price,
                                    ),
                                    style:
                                        TextStyle(
                                      fontSize: 14,
                                      color: Colors
                                          .green
                                          .shade700,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 10,
                                  ),

                                  Row(
                                    children: [
                                      // Minus
                                      IconButton(
                                        onPressed:
                                            isUpdating
                                                ? null
                                                : () {
                                                    _changeQuantity(
                                                      item,
                                                      item.quantity -
                                                          1,
                                                    );
                                                  },
                                        icon:
                                            const Icon(
                                          Icons
                                              .remove,
                                        ),
                                        visualDensity:
                                            VisualDensity
                                                .compact,
                                      ),

                                      // Quantity
                                      SizedBox(
                                        width: 32,
                                        child:
                                            Center(
                                          child:
                                              isUpdating
                                                  ? const SizedBox(
                                                      width:
                                                          18,
                                                      height:
                                                          18,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth:
                                                            2,
                                                      ),
                                                    )
                                                  : Text(
                                                      '${item.quantity}',
                                                      style:
                                                          const TextStyle(
                                                        fontSize:
                                                            16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                        ),
                                      ),

                                      // Plus
                                      IconButton(
                                        onPressed:
                                            isUpdating
                                                ? null
                                                : () {
                                                    _changeQuantity(
                                                      item,
                                                      item.quantity +
                                                          1,
                                                    );
                                                  },
                                        icon:
                                            const Icon(
                                          Icons.add,
                                        ),
                                        visualDensity:
                                            VisualDensity
                                                .compact,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Remove button
                            IconButton(
                              onPressed:
                                  isUpdating
                                      ? null
                                      : () {
                                          _removeProduct(
                                            item,
                                          );
                                        },
                              icon: const Icon(
                                Icons
                                    .delete_outline,
                              ),
                              tooltip:
                                  'Remove',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom total
              SafeArea(
                child: Container(
                  padding:
                      const EdgeInsets.all(16),
                  decoration:
                      BoxDecoration(
                    color:
                        Theme.of(context)
                            .cardColor,
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 8,
                        offset:
                            Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            const Text(
                              'Total',
                              style:
                                  TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              formatPrice(total),
                              style:
                                  const TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CheckoutPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Checkout',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}