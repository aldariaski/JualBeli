import 'package:flutter/material.dart';

class CategoryChip extends StatefulWidget {
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
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(widget.label),
      selected: widget.selected,
      onSelected: (_) {
        widget.onTap?.call();
      },
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      labelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        color: widget.selected
            ? Colors.white
            : Colors.black87,
      ),
      selectedColor:
          Theme.of(context).primaryColor,
      backgroundColor: Colors.grey.shade100,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}