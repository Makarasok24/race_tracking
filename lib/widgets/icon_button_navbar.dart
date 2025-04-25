import 'package:flutter/material.dart';
import 'package:race_tracking/theme/theme.dart';

class IconButtonNavBar extends StatelessWidget {
  const IconButtonNavBar({
    super.key,
    required this.icon,
    required this.isSelected, // Changed from currentIndex to a boolean for clarity
    this.selectedColor = const Color(0xFFECB476),
    this.unselectedColor = Colors.grey,
  });

  final IconData icon;
  final bool isSelected; // Determines if the icon is in selected state
  final Color selectedColor;
  final Color unselectedColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:
            isSelected
                ? selectedColor.withOpacity(0.2)
                : unselectedColor.withOpacity(0.2),
      ),
      child: Icon(icon, color: isSelected ? selectedColor : unselectedColor),
    );
  }
}
