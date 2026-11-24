import 'package:flutter/material.dart';
import 'package:food_app/app_colors.dart';

class ProductSearchField extends StatelessWidget {
  final FocusNode? focusNode;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const ProductSearchField({
    super.key,
    this.focusNode,
    this.readOnly = false,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        focusNode: focusNode,
        readOnly: readOnly,
        onChanged: onChanged,
        onTap: onTap,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search products...',
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search, color: AppColors.textPrimary),
          enabledBorder: border,
          focusedBorder: border,
          border: border,
        ),
      ),
    );
  }
}
