import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Pastel colour per finger, shared by the keyboard and any legend.
class FingerColors {
  static const Map<String, Color> map = {
    'LP': Color(0xFFF9A8D4),
    'LR': Color(0xFFFDBA74),
    'LM': Color(0xFFFDE047),
    'LI': Color(0xFF86EFAC),
    'RI': Color(0xFF7DD3FC),
    'RM': Color(0xFFA5B4FC),
    'RR': Color(0xFFD8B4FE),
    'RP': Color(0xFFFCA5A5),
    'T': Color(0xFFD1D5DB),
  };
}

class _Loc {
  const _Loc(this.row, this.col, this.shifted);

  final int row;
  final int col;
  final bool shifted;
}

/// On-screen QWERTY keyboard. Keys are coloured by the finger that types them,
/// the next key is outlined, and the opposite Shift key lights up for capitals
/// and symbols. Drawn with a single [CustomPainter] so a key press costs one
/// cheap repaint instead of rebuilding ~60 widgets.
class KeyboardGuide extends StatelessWidget {
  const KeyboardGuide({super.key, required this.target, this.error = false});

  /// The next character the learner has to type (null = nothing highlighted).
  final String? target;

  /// Outline the target key in red (the last key press was wrong).
  final bool error;

  static const List<String> _base = [
    '`1234567890-=',
    'qwertyuiop[]',
    "asdfghjkl;'",
    'zxcvbnm,./',
  ];
  static const List<String> _shift = [
    r'~!@#$%^&*()_+',
    'QWERTYUIOP{}',
    'ASDFGHJKL:"',
    'ZXCVBNM<>?',
  ];
  static const List<List<String>> _fingers = [
    ['LP', 'LP', 'LR', 'LM', 'LI', 'LI', 'RI', 'RI', 'RM', 'RR', 'RP', 'RP', 'RP'],
    ['LP', 'LR', 'LM', 'LI', 'LI', 'RI', 'RI', 'RM', 'RR', 'RP', 'RP', 'RP'],
    ['LP', 'LR', 'LM', 'LI', 'LI', 'RI', 'RI', 'RM', 'RR', 'RP', 'RP'],
    ['LP', 'LR', 'LM', 'LI', 'LI', 'RI', 'RI', 'RM', 'RR', 'RP'],
  ];
  static const List<double> _rowOffsets = [0, 0.5, 0.75, 1.25];

  /// Finger code (LP, LR, LM, LI, RI, RM, RR, RP or T for thumb) that types [ch],
  /// or null when the character is not on the guide.
  static String? fingerFor(String ch) {
    if (ch == ' ') {
      return 'T';
    }
    final loc = _locate(ch);
    return loc == null ? null : _fingers[loc.row][loc.col];
  }

  static _Loc? _locate(String ch) {
    if (ch.isEmpty) {
      return null;
    }
    for (var r = 0; r < _base.length; r++) {
      var c = _base[r].indexOf(ch);
      if (c >= 0) {
        return _Loc(r, c, false);
      }
      c = _shift[r].indexOf(ch);
      if (c >= 0) {
        return _Loc(r, c, true);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return RepaintBoundary(
      child: SizedBox.expand(
        child: CustomPaint(
          painter: _KeyboardPainter(
            target: target,
            error: error,
            highlight: scheme.primary,
            errorColor: AppTheme.danger,
          ),
        ),
      ),
    );
  }
}

class _KeyboardPainter extends CustomPainter {
  _KeyboardPainter({
    required this.target,
    required this.error,
    required this.highlight,
    required this.errorColor,
  });

  final String? target;
  final bool error;
  final Color highlight;
  final Color errorColor;

  static const double _units = 13.6;
  static const double _rows = 5.2;
  static const Color _ink = Color(0xFF1F2937);

  @override
  void paint(Canvas canvas, Size size) {
    final u = math.min(size.width / _units, size.height / _rows);
    if (u <= 0) {
      return;
    }
    final dx = (size.width - _units * u) / 2;
    final dy = (size.height - _rows * u) / 2;
    final gap = u * 0.05;
    final radius = Radius.circular(u * 0.16);

    final spaceTarget = target == ' ';
    final loc = (target == null || spaceTarget) ? null : KeyboardGuide._locate(target!);
    final hasTarget = spaceTarget || loc != null;
    final shiftOnLeft = loc != null && loc.shifted && KeyboardGuide._fingers[loc.row][loc.col].startsWith('R');
    final shiftOnRight = loc != null && loc.shifted && KeyboardGuide._fingers[loc.row][loc.col].startsWith('L');

    void drawKey(Rect rect, String finger, bool hit, {String? main, String? sub}) {
      final rrect = RRect.fromRectAndRadius(rect, radius);
      final base = FingerColors.map[finger] ?? const Color(0xFFD1D5DB);
      if (hit) {
        final ring = error ? errorColor : highlight;
        canvas.drawRRect(
          rrect.inflate(u * 0.08),
          Paint()..color = ring.withOpacity(0.35),
        );
        canvas.drawRRect(rrect, Paint()..color = base);
        canvas.drawRRect(
          rrect,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(2.5, u * 0.07)
            ..color = ring,
        );
      } else {
        canvas.drawRRect(rrect, Paint()..color = hasTarget ? base.withOpacity(0.7) : base);
      }
      if (main != null) {
        if (sub != null) {
          _label(canvas, sub, rect.center + Offset(0, -rect.height * 0.2), u * 0.26, _ink.withOpacity(0.7));
          _label(canvas, main, rect.center + Offset(0, rect.height * 0.16), u * 0.34, _ink);
        } else {
          _label(canvas, main, rect.center, u * 0.4, _ink);
        }
      }
    }

    for (var r = 0; r < KeyboardGuide._base.length; r++) {
      final baseRow = KeyboardGuide._base[r];
      final shiftRow = KeyboardGuide._shift[r];
      for (var c = 0; c < baseRow.length; c++) {
        final rect = Rect.fromLTWH(
          dx + (KeyboardGuide._rowOffsets[r] + c) * u + gap,
          dy + r * u + gap,
          u - 2 * gap,
          u - 2 * gap,
        );
        final b = baseRow[c];
        final s = shiftRow[c];
        final isLetter = b.toUpperCase() != b;
        final hit = loc != null && loc.row == r && loc.col == c;
        drawKey(
          rect,
          KeyboardGuide._fingers[r][c],
          hit,
          main: isLetter ? s : b,
          sub: isLetter ? null : s,
        );
        // small tactile bumps on F and J, like a real keyboard
        if (r == 2 && (c == 3 || c == 6)) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: rect.bottomCenter - Offset(0, u * 0.14), width: u * 0.3, height: u * 0.05),
              Radius.circular(u * 0.03),
            ),
            Paint()..color = _ink.withOpacity(0.5),
          );
        }
      }
    }

    // Shift keys (the opposite hand to the key being typed lights up)
    drawKey(
      Rect.fromLTWH(dx + gap, dy + 3 * u + gap, 1.25 * u - 2 * gap, u - 2 * gap),
      'LP',
      shiftOnLeft,
      main: 'Shift',
    );
    drawKey(
      Rect.fromLTWH(dx + 11.25 * u + gap, dy + 3 * u + gap, 2.3 * u - 2 * gap, u - 2 * gap),
      'RP',
      shiftOnRight,
      main: 'Shift',
    );

    // Space bar
    drawKey(
      Rect.fromLTWH(dx + 3.0 * u + gap, dy + 4 * u + gap, 7.0 * u - 2 * gap, u - 2 * gap),
      'T',
      spaceTarget,
    );
  }

  static void _label(Canvas canvas, String text, Offset center, double fontSize, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, color: color, fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, center - Offset(painter.width / 2, painter.height / 2));
    painter.dispose();
  }

  @override
  bool shouldRepaint(_KeyboardPainter old) {
    return old.target != target || old.error != error || old.highlight != highlight || old.errorColor != errorColor;
  }
}
