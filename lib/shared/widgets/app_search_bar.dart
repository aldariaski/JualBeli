import 'package:flutter/material.dart';

import 'app_logo.dart';
import '../../features/auth/data/auth_storage.dart';
import '../../app/router.dart';
import 'package:go_router/go_router.dart';

class AppSearchBar extends StatefulWidget {
  const AppSearchBar({
    super.key,
    this.onChanged,
    this.onProductPageReturned,
  });

  final ValueChanged<String>? onChanged;

  final Future<void> Function()? onProductPageReturned;

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.green.shade50,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const AppLogo(size: 30),

          const SizedBox(width: 12),

          Expanded(
            child: TextField(
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 4),

          IconButton(
            onPressed: () {
              context.push('/cart');
            },
            icon: const Icon(
              Icons.shopping_cart_outlined,
              size: 24,
            ),
          ),

          IconButton(
            onPressed: () {
              context.push('/orders');
            },
            icon: const Icon(
              Icons.receipt_long_outlined,
              size: 24,
            ),
          ),

          IconButton(
            onPressed: () async {
              await context.push('/products/add');

              if (!context.mounted) return;

              await widget.onProductPageReturned?.call();
            },
            icon: const Icon(
              Icons.add_box_outlined,
              size: 24,
            ),
          ),

          FutureBuilder<String?>(
            future: AuthStorage.getCurrentUserName(),
            builder: (context, snapshot) {
              print('Username: ${snapshot.data}');
              print('Error: ${snapshot.error}');
              print(
                'Connection: ${snapshot.connectionState}',
              );

              final userName =
                  snapshot.data ?? 'User (Hi)';

              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                child: Text(userName),
              );
            },
          ),

          IconButton(
            onPressed: () async {
              await AuthStorage.logout();

              if (!context.mounted) return;

              context.go(AppRouter.login);
            },
            icon: const Icon(
              Icons.logout,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}