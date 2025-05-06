import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:race_tracking/presentation/theme/theme.dart';

class Search_widget extends StatelessWidget {
  const Search_widget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        hintText: "Search", // Changed from labelText for a cleaner UI
        prefixIcon: Icon(
          Iconsax.search_normal_1, // Use outline variant
          color: RTAColors.neutralLight,
        ),
        filled: true,
        fillColor:
            Colors.grey.shade100, // Light background for clean look
        contentPadding: EdgeInsets.symmetric(
          vertical: 0,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none, // Remove border for cleaner look
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: RTAColors.primary),
        ),
      ),
    );
  }
}