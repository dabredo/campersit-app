import 'package:flutter/material.dart';

class AppInlineSpinner extends StatelessWidget {
  const AppInlineSpinner({super.key, required this.color, this.size = 16});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(strokeWidth: 2, color: color),
    );
  }
}

