import 'package:flutter/material.dart';
import 'package:race_tracking/theme/theme.dart';

class TopButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const TopButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: RTAColors.primary.withOpacity(0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}