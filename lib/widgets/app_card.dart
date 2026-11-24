import 'package:flutter/material.dart';

/// A flat, softly outlined card used for every panel in the app, so the whole UI shares
/// one shape, one border and one surface colour.
class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.color, this.margin});

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: margin ?? EdgeInsets.zero,
      color: color ?? scheme.surfaceContainerLow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: child,
    );
  }
}
