import 'package:flutter/material.dart';


class _SectionAPainter extends CustomPainter {
  final Color color;
  final Offset p1; // relative coords (0..1)
  final Offset p2;
  final Offset p3;
  final int cornerIndexToChop; // 0,1 or 2
  final double ratioToPrev; // 0..1 how far from corner toward previous vertex
  final double ratioToNext; // 0..1 how far from corner toward next vertex

  _SectionAPainter(
    this.color,
    this.p1,
    this.p2,
    this.p3, {
    this.cornerIndexToChop = 2,
    this.ratioToPrev = 0.15,
    this.ratioToNext = 0.15,
  });

  // linear interpolation helper
  Offset _lerp(Offset a, Offset b, double t) =>
      Offset(a.dx + (b.dx - a.dx) * t, a.dy + (b.dy - a.dy) * t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;

    // convert relative points to absolute coordinates
    final List<Offset> V = [
      Offset(p1.dx * size.width, p1.dy * size.height),
      Offset(p2.dx * size.width, p2.dy * size.height),
      Offset(p3.dx * size.width, p3.dy * size.height),
    ];

    final int c = cornerIndexToChop.clamp(0, 2);
    final int prev = (c - 1 + 3) % 3;
    final int next = (c + 1) % 3;

    // cut points are moved from the corner towards each adjacent vertex
    // note: we interpolate from corner -> adjacent, so use ratio t (0..1)
    final Offset corner = V[c];
    final Offset cutA = _lerp(corner, V[prev], ratioToPrev); // toward previous
    final Offset cutB = _lerp(corner, V[next], ratioToNext); // toward next

    // Build polygon replacing the corner vertex with cutA -> cutB
    final List<Offset> poly = [];
    for (int i = 0; i < 3; i++) {
      if (i == c) {
        poly.add(cutA);
        poly.add(cutB);
      } else {
        poly.add(V[i]);
      }
    }

    final path = Path()..moveTo(poly[0].dx, poly[0].dy);
    for (int i = 1; i < poly.length; i++) {
      path.lineTo(poly[i].dx, poly[i].dy);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SectionA extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final Offset p1;
  final Offset p2;
  final Offset p3;

  /// which corner to flatten: 0 => p1, 1 => p2, 2 => p3
  final int cornerIndexToChop;

  /// how far from the corner toward each neighboring vertex the cut starts (0..1)
  final double ratioToPrev;
  final double ratioToNext;

  const SectionA({
    super.key,
    required this.width,
    required this.height,
    required this.color,
    required this.p1,
    required this.p2,
    required this.p3,
    this.cornerIndexToChop = 2, // default chop top (p3)
    this.ratioToPrev = 0.15,
    this.ratioToNext = 0.15,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _SectionAPainter(
        color,
        p1,
        p2,
        p3,
        cornerIndexToChop: cornerIndexToChop,
        ratioToPrev: ratioToPrev,
        ratioToNext: ratioToNext,
      ),
    );
  }
}

class _SectionBPainter extends CustomPainter {
  final Color color;
  final bool directionRight; // true = right angle at bottom-right
  final double chopRatio;    // fraction of width/height to cut

  _SectionBPainter(this.color,
      {this.directionRight = true, this.chopRatio = 0.2});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    if (directionRight) {
      // Right angle at bottom-right
      final bottomLeft = Offset(0, size.height);
      final topLeft = Offset(0, 0);
      final bottomRight = Offset(size.width, size.height);

      // New points for a 90° chopped corner
      final cutLeft = bottomRight - Offset(size.width * chopRatio, 0); // horizontal
      final cutUp = bottomRight - Offset(0, size.height * chopRatio);  // vertical

      path
        ..moveTo(bottomLeft.dx, bottomLeft.dy)  // bottom-left
        ..lineTo(cutLeft.dx, cutLeft.dy)        // bottom edge after chop
        ..lineTo(cutUp.dx, cutUp.dy)            // vertical edge of chopped corner
        ..lineTo(topLeft.dx, topLeft.dy)        // top-left
        ..close();
    } else {
      // Right angle at bottom-left
      final bottomLeft = Offset(0, size.height);
      final topRight = Offset(size.width, 0);
      final bottomRight = Offset(size.width, size.height);

      final cutRight = bottomLeft + Offset(size.width * chopRatio, 0); // horizontal
      final cutUp = bottomLeft - Offset(0, size.height * chopRatio);   // vertical

      path
        ..moveTo(cutRight.dx, cutRight.dy)     // bottom edge after chop
        ..lineTo(bottomRight.dx, bottomRight.dy)// bottom-right
        ..lineTo(topRight.dx, topRight.dy)     // top-right
        ..lineTo(cutUp.dx, cutUp.dy)           // vertical edge of chopped corner
        ..close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SectionB extends StatelessWidget {
  final double base;
  final double height;
  final Color color;
  final bool directionRight; // now true = right corner
  final double chopRatio;

  const SectionB({
    super.key,
    required this.base,
    required this.height,
    required this.color,
    this.directionRight = true,
    this.chopRatio = 0.2,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(base, height),
      painter: _SectionBPainter(
        color,
        directionRight: directionRight,
        chopRatio: chopRatio,
      ),
    );
  }
}
