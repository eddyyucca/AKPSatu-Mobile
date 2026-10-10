import 'dart:math' as math;
import 'package:flutter/material.dart' hide Text;
import '../api/api.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

/// Animasi pembuka AKPSatu: latar berpola bergerak + logo muncul, lalu masuk ke Login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController intro = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
  late final AnimationController loop = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  bool left = false;

  @override
  void initState() {
    super.initState();
    intro.forward().whenComplete(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      _go();
    });
  }

  void _go() {
    if (left || !mounted) return;
    left = true;
    final signedIn = Session.instance.active && !Session.instance.mustChangePassword;
    final target = signedIn ? R.home : R.login;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      settings: RouteSettings(name: target),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (c, _, _) => routes[target]!(c),
      transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
    ));
  }

  @override
  void dispose() {
    intro.dispose();
    loop.dispose();
    super.dispose();
  }

  Animation<double> _iv(double a, double b, [Curve c = Curves.easeOut]) => CurvedAnimation(parent: intro, curve: Interval(a, b, curve: c));

  @override
  Widget build(BuildContext context) {
    final logoS = _iv(.04, .42, Curves.easeOutBack);
    final logoO = _iv(.04, .24);
    final titleA = _iv(.38, .66);
    final tagA = _iv(.52, .80);
    final barA = _iv(.40, .98, Curves.easeInOut);
    final verA = _iv(.70, 1);
    return Scaffold(
      backgroundColor: C.navy,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _go,
        child: Stack(children: [
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: Listenable.merge([intro, loop]),
                builder: (_, _) => CustomPaint(painter: _SplashBgPainter(loop.value, Curves.easeOutCubic.transform(math.min(1, intro.value * 1.6)))),
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([intro, loop]),
              builder: (_, _) {
                final pulse = .5 + .5 * math.sin(loop.value * 2 * math.pi * 1.5);
                return Column(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: Stack(alignment: Alignment.center, children: [
                      // Cahaya berdenyut di belakang logo.
                      Opacity(
                        opacity: logoO.value * (.35 + .25 * pulse),
                        child: Container(
                          width: 190 + 20 * pulse,
                          height: 190 + 20 * pulse,
                          decoration: const BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Color(0xFF3F86F0), Color(0x003F86F0)])),
                        ),
                      ),
                      Opacity(
                        opacity: logoO.value.clamp(0, 1),
                        child: Transform.scale(scale: .55 + .45 * logoS.value, child: const Logo(size: 130)),
                      ),
                    ]),
                  ),
                  const Gap(6),
                  Opacity(
                    opacity: titleA.value,
                    child: Transform.translate(offset: Offset(0, 16 * (1 - titleA.value)), child: Text('AKPSatu', style: ts(34, w: FontWeight.w800, c: Colors.white).copyWith(letterSpacing: -.3))),
                  ),
                  const Gap(8),
                  Opacity(
                    opacity: tagA.value,
                    child: Transform.translate(offset: Offset(0, 10 * (1 - tagA.value)), child: Text('Satu aplikasi untuk semua kebutuhan kerja', textAlign: TextAlign.center, style: ts(14, c: C.pale))),
                  ),
                  const Gap(34),
                  Opacity(
                    opacity: tagA.value,
                    child: Container(
                      width: 120,
                      height: 4,
                      decoration: BoxDecoration(color: const Color(0x26FFFFFF), borderRadius: BorderRadius.circular(2)),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: barA.value,
                        child: Container(decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2DD4BF), Color(0xFF3F86F0)]), borderRadius: BorderRadius.circular(2))),
                      ),
                    ),
                  ),
                ]);
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 28,
            child: SafeArea(
              top: false,
              child: FadeTransition(opacity: verA, child: Text('NICKEL MINING · v1.0.0', textAlign: TextAlign.center, style: ts(11, w: FontWeight.w600, c: C.pale.withValues(alpha: .7)).copyWith(letterSpacing: 1.2))),
            ),
          ),
        ]),
      ),
    );
  }
}

/// Latar bergerak: pita miring melayang & berkilau, kontur tambang membesar, titik berkelip.
class _SplashBgPainter extends CustomPainter {
  final double t; // 0..1 berulang
  final double e; // 0..1 intro
  _SplashBgPainter(this.t, this.e);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF1B4A7E), C.navy, Color(0xFF0A1F35)], stops: [0, .5, 1]).createShader(rect),
    );

    // Titik berkelip.
    for (double y = 12; y < h; y += 22) {
      for (double x = 12; x < w; x += 22) {
        final tw = .5 + .5 * math.sin(2 * math.pi * (t * 2 + (x * .013 + y * .009)));
        final a = (.03 + .16 * tw * tw) * e;
        canvas.drawCircle(Offset(x, y), 1.2, Paint()..color = Colors.white.withValues(alpha: a));
      }
    }

    // Kontur tambang membesar & bernapas dari kiri bawah.
    final contour = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    for (var i = 1; i <= 9; i++) {
      final breathe = 1 + .03 * math.sin(2 * math.pi * (t + i * .08));
      final r = 56.0 * i * (.35 + .65 * e) * breathe;
      contour.color = Colors.white.withValues(alpha: (.10 - i * .006).clamp(.02, .1) * e);
      canvas.drawOval(Rect.fromCenter(center: Offset(-w * .1, h * 1.05), width: r * 2.7, height: r * 1.8), contour);
    }

    // Pita miring (mengacu pada angka "1" di logo) melayang pelan.
    void band(double x, double width, double skew, Color c, double phase) {
      final dx = (1 - e) * 160 + 12 * math.sin(2 * math.pi * (t + phase));
      final p = Path()
        ..moveTo(x + dx, h)
        ..lineTo(x + dx + width, h)
        ..lineTo(x + dx + width + skew, 0)
        ..lineTo(x + dx + skew, 0)
        ..close();
      canvas.drawPath(p, Paint()..color = c.withValues(alpha: c.a * e));
    }

    final skew = h * .22;
    band(w * .62, 46, skew, const Color(0xFF2DD4BF).withValues(alpha: .20), 0);
    band(w * .62 + 64, 18, skew, const Color(0xFF3F86F0).withValues(alpha: .30), .15);
    band(w * .62 + 100, 80, skew, const Color(0xFF1E5BD7).withValues(alpha: .24), .3);
    band(w * .62 + 200, 12, skew, const Color(0xFF2DD4BF).withValues(alpha: .24), .45);
    band(w * .08, 26, skew, const Color(0xFF3F86F0).withValues(alpha: .12), .6);

    // Cincin di kanan atas.
    for (var i = 0; i < 2; i++) {
      canvas.drawCircle(
        Offset(w * .95, -h * .03),
        math.min(w, h) * (.62 - i * .22) * (.7 + .3 * e),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..color = (i == 0 ? const Color(0xFF3F86F0) : const Color(0xFF2DD4BF)).withValues(alpha: .28 * e),
      );
    }

    // Kilau cahaya menyapu miring.
    final sx = (t * (w + 400)) - 200;
    final shine = Path()
      ..moveTo(sx, h)
      ..lineTo(sx + 70, h)
      ..lineTo(sx + 70 + skew * 1.6, 0)
      ..lineTo(sx + skew * 1.6, 0)
      ..close();
    canvas.drawPath(
      shine,
      Paint()
        ..shader = LinearGradient(colors: [Colors.white.withValues(alpha: 0), Colors.white.withValues(alpha: .07 * e), Colors.white.withValues(alpha: 0)]).createShader(Rect.fromLTWH(sx, 0, 70 + skew * 1.6, h)),
    );

    // Vinyet halus agar fokus ke tengah.
    canvas.drawRect(
      rect,
      Paint()..shader = RadialGradient(radius: 1.1, colors: [Colors.transparent, const Color(0xFF06121F).withValues(alpha: .55)], stops: const [.55, 1]).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _SplashBgPainter old) => old.t != t || old.e != e;
}
