
class ProductOld {
  final String name;
  final double price;
  final String image;
  final String category;

  static const shopCategories = [
    'All',
    'Electronics',
    'Fashion',
    'Shoes',
    'Beauty',
    'Health',
    'Home & Living',
    'Furniture',
    'Sports',
    'Toys',
    'Books',
    'Food & Beverages',
    'Automotive',
    'Accessories',
    'Pet Supplies',
    'Baby & Kids',
    'Groceries',
    'Office & Stationery',
    'Tools & Hardware',
    'Other',
  ];

  const ProductOld({
    required this.name,
    required this.price,
    required this.image,
    required this.category,
  });
}

const products = [
  ProductOld(
    name: 'iPhone 16',
    price: 15999000,
    image: 'https://picsum.photos/200?1',
    category: 'Electronics',
  ),
  ProductOld(
    name: 'AirPods Pro',
    price: 3999000,
    image: 'https://picsum.photos/200?2',
    category: 'Electronics',
  ),
  ProductOld(
    name: 'MacBook Air',
    price: 18999000,
    image: 'https://picsum.photos/200?3',
    category: 'Electronics',
  ),
];