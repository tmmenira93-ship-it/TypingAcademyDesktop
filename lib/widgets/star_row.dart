import 'package:flutter/material.dart';

class StarRow extends StatelessWidget {
  const StarRow({super.key, required this.count, this.size = 22, this.max = 5});

  final int count;
  final int max;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (index) {
        return Icon(
          index < count ? Icons.star_rounded : Icons.star_outline_rounded,
          color: const Color(0xFFF59E0B),
          size: size,
        );
      }),
    );
  }
}
