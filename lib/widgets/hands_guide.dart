import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'keyboard_guide.dart';

/// Two hands (seen from above) with the finger that has to press the next key
/// filled in its colour. [finger] uses the same codes as [KeyboardGuide.fingerFor]:
/// LP LR LM LI RI RM RR RP, or T for the thumbs (space bar).
class HandsGuide extends StatelessWidget {
  const HandsGuide({super.key, required this.finger});

  final String? finger;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _HandsPainter(
            finger: finger,
            base: scheme.surfaceContainerHighest,
            outline: scheme.outline,
            highlight: scheme.primary,
          ),
        ),
      ),
    );
  }
}

class _HandsPainter extends CustomPainter {
  _HandsPainter({
    required this.finger,
    required this.base,
    required this.outline,
    required this.highlight,
  });

  final String? finger;
  final Color base;
  final Color outline;
  final Color highlight;

  static const double _unitsW = 5.4;
  static const double _unitsH = 6.2;

  // Left hand, in units: [finger code, left, top, right, bottom].
  static const List<(String, double, double, double, double)> _fingers = [
    ('LP', 0.0, 2.3, 0.95, 4.2),
    ('LR', 1.0, 1.2, 1.95, 4.2),
    ('LM', 2.0, 0.6, 2.95, 4.2),
    ('LI', 3.0, 1.1, 3.95, 4.2),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final u = math.min(size.width * 0.45 / _unitsW, size.height / _unitsH);
    if (u <= 0) {
      return;
    }
    final oy = (size.height - _unitsH * u) / 2;
    final leftOrigin = size.width / 2 - 0.7 * u - _unitsW * u;
    final rightOrigin = size.width / 2 + 0.7 * u;
    _hand(canvas, u, leftOrigin, oy, mirrored: false);
    _hand(canvas, u, rightOrigin, oy, mirrored: true);
  }

  void _hand(Canvas canvas, double u, double ox, double oy, {required bool mirrored}) {
    Rect rect(double l, double t, double r, double b) {
      final left = mirrored ? _unitsW - r : l;
      final right = mirrored ? _unitsW - l : r;
      return Rect.fromLTRB(ox + left * u, oy + t * u, ox + right * u, oy + b * u);
    }

    final palm = RRect.fromRectAndRadius(rect(0.0, 3.3, 3.95, 6.0), Radius.circular(u * 0.6));
    _shape(canvas, palm, fill: base, active: false);

    for (final item in _fingers) {
      final code = mirrored ? 'R${item.$1.substring(1)}' : item.$1;
      final shape = RRect.fromRectAndRadius(rect(item.$2, item.$3, item.$4, item.$5), Radius.circular(u * 0.45));
      final active = finger == code;
      _shape(canvas, shape, fill: active ? (FingerColors.map[code] ?? highlight) : base, active: active);
    }

    final thumb = RRect.fromRectAndRadius(rect(4.1, 3.6, 5.3, 5.1), Radius.circular(u * 0.45));
    final thumbActive = finger == 'T';
    _shape(canvas, thumb, fill: thumbActive ? FingerColors.map['T']! : base, active: thumbActive);
  }

  void _shape(Canvas canvas, RRect shape, {required Color fill, required bool active}) {
    canvas.drawRRect(shape, Paint()..color = fill);
    canvas.drawRRect(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = active ? 3 : 1.2
        ..color = active ? highlight : outline.withOpacity(0.6),
    );
  }

  @override
  bool shouldRepaint(_HandsPainter old) {
    return old.finger != finger || old.base != base || old.outline != outline || old.highlight != highlight;
  }
}
