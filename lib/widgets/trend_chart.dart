import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A small line chart (oldest value on the left) with a soft area fill and a light grid.
class TrendChart extends StatelessWidget {
  const TrendChart({super.key, required this.values, required this.color, this.maxY, this.height = 150});

  final List<double> values;
  final Color color;

  /// Fixed top of the axis (for example 100 for accuracy). Null = a bit above the highest value.
  final double? maxY;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _TrendPainter(
            values: values,
            color: color,
            grid: scheme.outlineVariant,
            labelColor: scheme.onSurfaceVariant,
            maxY: maxY,
          ),
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.values,
    required this.color,
    required this.grid,
    required this.labelColor,
    required this.maxY,
  });

  final List<double> values;
  final Color color;
  final Color grid;
  final Color labelColor;
  final double? maxY;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 38.0;
    const pad = 8.0;
    final plot = Rect.fromLTRB(left, pad, size.width - pad, size.height - pad);
    if (plot.width <= 0 || plot.height <= 0) {
      return;
    }
    final highest = values.isEmpty ? 1.0 : values.reduce(math.max);
    final top = maxY ?? math.max(1.0, highest * 1.15);
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = plot.bottom - plot.height * i / 3;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), gridPaint);
      _label(canvas, (top * i / 3).round().toString(), Offset(plot.left - 6, y));
    }
    if (values.isEmpty) {
      return;
    }
    Offset point(int i) {
      final x = values.length == 1 ? plot.center.dx : plot.left + plot.width * i / (values.length - 1);
      final y = plot.bottom - plot.height * (values[i] / top).clamp(0.0, 1.0).toDouble();
      return Offset(x, y);
    }

    if (values.length > 1) {
      final path = Path()..moveTo(point(0).dx, point(0).dy);
      for (var i = 1; i < values.length; i++) {
        path.lineTo(point(i).dx, point(i).dy);
      }
      final area = Path.from(path)
        ..lineTo(plot.right, plot.bottom)
        ..lineTo(plot.left, plot.bottom)
        ..close();
      canvas.drawPath(area, Paint()..color = color.withOpacity(0.12));
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = color,
      );
    }
    final dot = Paint()..color = color;
    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(point(i), 3.5, dot);
    }
  }

  void _label(Canvas canvas, String text, Offset rightCenter) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: 11, color: labelColor)),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, Offset(rightCenter.dx - painter.width, rightCenter.dy - painter.height / 2));
    painter.dispose();
  }

  @override
  bool shouldRepaint(_TrendPainter old) {
    return old.values != values || old.color != color || old.grid != grid || old.maxY != maxY;
  }
}
