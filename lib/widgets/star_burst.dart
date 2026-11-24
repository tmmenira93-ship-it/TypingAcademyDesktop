import 'package:flutter/material.dart';

/// Stars that pop in one after another (used on the results screen).
class StarBurst extends StatefulWidget {
  const StarBurst({super.key, required this.count, this.max = 5, this.size = 52});

  final int count;
  final int max;
  final double size;

  @override
  State<StarBurst> createState() => _StarBurstState();
}

class _StarBurstState extends State<StarBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.max; i++)
          ScaleTransition(
            scale: CurvedAnimation(
              parent: _controller,
              curve: Interval(0.1 * i, (0.1 * i + 0.5).clamp(0.0, 1.0).toDouble(), curve: Curves.elasticOut),
            ),
            child: Icon(
              i < widget.count ? Icons.star_rounded : Icons.star_border_rounded,
              size: widget.size,
              color: i < widget.count ? const Color(0xFFF59E0B) : scheme.outline,
            ),
          ),
      ],
    );
  }
}
