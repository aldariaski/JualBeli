import 'package:flutter/material.dart';

import '../../../auth/data/auth_storage.dart';
import '../../../product/data/price_formatter.dart';
import '../../../cart/data/cart_item.dart';
import '../../../cart/data/cart_service.dart';
import '../../data/checkout_service.dart';
import 'order_success_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({
    super.key,
  });

  @override
  State<CheckoutPage> createState() =>
      _CheckoutPageState();
}

class _CheckoutPageState
    extends State<CheckoutPage> {
  final CartService _cartService =
      CartService.instance;

  final CheckoutService _checkoutService =
      CheckoutService.instance;

  late Future<List<CartItem>> _cartFuture;

  bool _placingOrder = false;

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

    return _cartService.getCart(email);
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

  Future<void> _placeOrder() async {
      if (_placingOrder) {
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
        _placingOrder = true;
      });

      try {
        final orderId =
            await _checkoutService.placeOrder(
          email: email,
        );

        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OrderSuccessPage(
              orderId: orderId,
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to place order: $e',
            ),
          ),
        );
      } finally {
        if (!mounted) return;

        setState(() {
          _placingOrder = false;
        });
      }
    }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
        ),
      ),
      body: FutureBuilder<List<CartItem>>(
        future: _cartFuture,
        builder: (
          context,
          snapshot,
        ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(24),
                child: Text(
                  'Failed to load checkout:\n'
                  '${snapshot.error}',
                  textAlign:
                      TextAlign.center,
                ),
              ),
            );
          }

          final items =
              snapshot.data ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Your cart is empty.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
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
                    final item =
                        items[index];

                    final product =
                        item.product;

                    final itemTotal =
                        product.price *
                            item.quantity;

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
                            Container(
                              width: 70,
                              height: 70,
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
                                        ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
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
                                    '${item.quantity} × '
                                    '${formatPrice(product.price)}',
                                    style:
                                        const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    formatPrice(
                                      itemTotal,
                                    ),
                                    style:
                                        TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                      color: Colors
                                          .green
                                          .shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

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
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style:
                                TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          Text(
                            formatPrice(total),
                            style:
                                const TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      SizedBox(
                        width:
                            double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _placingOrder
                                  ? null
                                  : _placeOrder,
                          child:
                              _placingOrder
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth:
                                            2,
                                      ),
                                    )
                                  : const Text(
                                      'Place Order',
                                    ),
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