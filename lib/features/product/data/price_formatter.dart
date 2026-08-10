String formatPrice(double price) {
  return 'Rp ' + price
      .toStringAsFixed(0)
      .replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => '.',
      );
}