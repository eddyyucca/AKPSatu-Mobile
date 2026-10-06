import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'theme.dart';

/// Header biru gelap bermotif khas AKPSatu: pita miring (mengacu pada angka "1" di logo),
/// garis kontur tambang, dan titik-titik halus. Memudar ke warna navy polos di tepi bawah
/// supaya menyatu dengan latar di belakangnya.
class BrandHeader extends StatelessWidget {
  final EdgeInsets padding;
  final Widget child;
  const BrandHeader({super.key, required this.padding, required this.child});

  @override
  Widget build(BuildContext context) => Stack(children: [
        Positioned.fill(child: CustomPaint(painter: BrandPatternPainter())),
        Padding(padding: padding, child: SizedBox(width: double.infinity, child: child)),
      ]);
}

class BrandPatternPainter extends CustomPainter {
  const BrandPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final rect = Offset.zero & size;

    // Dasar: gradasi navy -> sedikit lebih terang di kanan atas, kembali navy di bawah.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF16406E), C.navy, C.navy],
          stops: [0, .55, 1],
        ).createShader(rect),
    );

    canvas.save();
    canvas.clipRect(rect);

    // Titik-titik halus di pojok kanan atas.
    final dot = Paint()..color = Colors.white.withValues(alpha: .10);
    for (double y = 10; y < h * .7; y += 16) {
      for (double x = w * .45; x < w; x += 16) {
        final fade = (1 - (y / (h * .7))) * ((x - w * .45) / (w * .55));
        canvas.drawCircle(Offset(x, y), 1.1, dot..color = Colors.white.withValues(alpha: .22 * fade));
      }
    }

    // Garis kontur (topografi tambang) dari pojok kiri bawah.
    final contour = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: .09);
    for (var i = 1; i <= 7; i++) {
      final r = 46.0 * i;
      final path = Path()..addOval(Rect.fromCenter(center: Offset(-w * .05, h * 1.05), width: r * 2.6, height: r * 1.7));
      canvas.drawPath(path, contour);
    }

    // Pita miring bergaya logo "1" (teal & biru).
    void band(double x, double width, double skew, Color c) {
      final p = Path()
        ..moveTo(x, h)
        ..lineTo(x + width, h)
        ..lineTo(x + width + skew, 0)
        ..lineTo(x + skew, 0)
        ..close();
      canvas.drawPath(p, Paint()..color = c);
    }

    const skew = 70.0;
    band(w * .70, 34, skew, const Color(0xFF2DD4BF).withValues(alpha: .18));
    band(w * .70 + 46, 14, skew, const Color(0xFF3F86F0).withValues(alpha: .26));
    band(w * .70 + 72, 56, skew, const Color(0xFF1E5BD7).withValues(alpha: .24));
    band(w * .70 + 140, 10, skew, const Color(0xFF2DD4BF).withValues(alpha: .22));

    // Cincin besar halus di kanan atas.
    canvas.drawCircle(
      Offset(w * .92, -h * .05),
      math.min(w, h) * .55,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFF3F86F0).withValues(alpha: .30),
    );
    canvas.drawCircle(
      Offset(w * .92, -h * .05),
      math.min(w, h) * .36,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = const Color(0xFF2DD4BF).withValues(alpha: .24),
    );

    // Pemudaran ke navy polos di tepi bawah agar menyatu.
    canvas.drawRect(
      Rect.fromLTWH(0, h * .72, w, h * .28 + 1),
      Paint()
        ..shader = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [C.navy.withValues(alpha: 0), C.navy]).createShader(Rect.fromLTWH(0, h * .72, w, h * .28 + 1)),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
