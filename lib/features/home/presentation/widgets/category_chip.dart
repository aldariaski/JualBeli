import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        onTap?.call();
      },
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        color: selected ? Colors.white : Colors.black87,
      ),
      selectedColor: Theme.of(context).primaryColor,
      backgroundColor: Colors.grey.shade100,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}