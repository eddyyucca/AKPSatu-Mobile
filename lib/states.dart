import 'dart:math' as math;
import 'package:flutter/material.dart' hide Text;
import 'theme.dart';
import 'widgets.dart';

/// Cincin berputar bergradasi teal → biru (ciri khas AKPSatu).
class BrandSpinner extends StatefulWidget {
  final double size;
  final double stroke;
  const BrandSpinner({super.key, this.size = 28, this.stroke = 3});
  @override
  State<BrandSpinner> createState() => _BrandSpinnerState();
}

class _BrandSpinnerState extends State<BrandSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(animation: c, builder: (_, _) => CustomPaint(painter: _ArcPainter(c.value, widget.stroke))),
      );
}

class _ArcPainter extends CustomPainter {
  final double t, w;
  _ArcPainter(this.t, this.w);
  @override
  void paint(Canvas canvas, Size s) {
    final rect = Rect.fromLTWH(w / 2, w / 2, s.width - w, s.height - w);
    canvas.drawArc(rect, 0, math.pi * 2, false, Paint()..style = PaintingStyle.stroke..strokeWidth = w..color = C.blue.withValues(alpha: .10));
    final start = t * math.pi * 2;
    canvas.drawArc(
      rect,
      start,
      math.pi * 1.35,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(startAngle: start, endAngle: start + math.pi * 1.35, colors: const [Color(0x002DD4BF), Color(0xFF2DD4BF), Color(0xFF1E5BD7)], transform: GradientRotation(start)).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _ArcPainter old) => old.t != t;
}

/// Halaman/area pemuatan: logo berdenyut di dalam cincin berputar + teks "Memuat...".
/// [compact] = versi kecil (spinner + teks sebaris) untuk kartu atau bagian kecil.
class LoadingView extends StatefulWidget {
  final String? text;
  final bool compact;
  const LoadingView({super.key, this.text, this.compact = false});
  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.text ?? 'Memuat...';
    if (widget.compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Center(child: Row(mainAxisSize: MainAxisSize.min, children: [const BrandSpinner(size: 22, stroke: 2.6), const Gap(0, w: 10), Text(label, style: ts(13, w: FontWeight.w600, c: C.muted))])),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: 104,
            height: 104,
            child: Stack(alignment: Alignment.center, children: [
              const BrandSpinner(size: 104, stroke: 3.5),
              AnimatedBuilder(
                animation: c,
                builder: (_, _) => Transform.scale(scale: .92 + .08 * Curves.easeInOut.transform(c.value), child: Opacity(opacity: .75 + .25 * c.value, child: const Logo(size: 62))),
              ),
            ]),
          ),
          const Gap(18),
          Text(label, style: ts(14, w: FontWeight.w700, c: C.text2)),
          const Gap(4),
          AnimatedBuilder(
            animation: c,
            builder: (_, _) => Row(mainAxisSize: MainAxisSize.min, children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const Gap(0, w: 5),
                Opacity(
                  opacity: (.25 + .75 * math.max(0, math.sin((c.value * math.pi) - i * .5))).clamp(.25, 1),
                  child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: C.blue, shape: BoxShape.circle)),
                ),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Kotak kerangka berkilau (shimmer) sebagai pengganti konten saat memuat daftar.
class Skeleton extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;
  const Skeleton({super.key, this.width, this.height = 14, this.radius = 6});
  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..repeat();

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: c,
        builder: (_, _) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1.5 + c.value * 3, 0),
              end: Alignment(-.5 + c.value * 3, 0),
              colors: const [Color(0xFFE9EDF3), Color(0xFFF6F8FB), Color(0xFFE9EDF3)],
            ),
          ),
        ),
      );
}

/// Daftar kartu kerangka (avatar/ikon + beberapa baris) untuk daftar yang sedang dimuat.
class SkeletonCards extends StatelessWidget {
  final int count;
  const SkeletonCards({super.key, this.count = 3});
  @override
  Widget build(BuildContext context) => Column(children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const Gap(10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
            child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Skeleton(width: 42, height: 42, radius: 12),
              Gap(0, w: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Skeleton(height: 14, width: 150),
                  Gap(8),
                  Skeleton(height: 11),
                  Gap(6),
                  Skeleton(height: 11, width: 110),
                ]),
              ),
            ]),
          ),
        ],
      ]);
}

/// Tampilan data kosong: ikon dalam lingkaran berlapis + judul + keterangan (+ tombol opsional).
/// [icon] = nama ikon di kIcons (mis. 'bell') atau path SVG bila diawali 'M'. [compact] = versi ringkas untuk di dalam kartu.
class EmptyState extends StatelessWidget {
  final String icon;
  final String title;
  final String? text;
  final Color color;
  final Color bg;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.text,
    this.color = C.blue,
    this.bg = C.blueSoft,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  Widget _ic(double size) => icon.startsWith('M') ? Ic.path(icon, size: size, color: color, stroke: 1.8) : Ic(icon, size: size, color: color, stroke: 1.8);

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: bg, shape: BoxShape.circle), child: Center(child: _ic(20))),
          const Gap(0, w: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: ts(14, w: FontWeight.w700)),
              if (text != null) Text(text!, style: ts(12, c: C.muted, h: 1.4)),
            ]),
          ),
        ]),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: 116,
            height: 116,
            child: Stack(alignment: Alignment.center, children: [
              Container(width: 116, height: 116, decoration: BoxDecoration(shape: BoxShape.circle, color: bg.withValues(alpha: .45))),
              DashedCircle(size: 96, color: color.withValues(alpha: .35)),
              Container(width: 70, height: 70, decoration: BoxDecoration(shape: BoxShape.circle, color: bg, border: Border.all(color: Colors.white, width: 3), boxShadow: [BoxShadow(color: color.withValues(alpha: .18), blurRadius: 14, offset: const Offset(0, 4))]), child: Center(child: _ic(30))),
              Positioned(top: 8, right: 14, child: Container(width: 9, height: 9, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: .5)))),
              Positioned(bottom: 14, left: 8, child: Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: .35)))),
            ]),
          ),
          const Gap(14),
          Text(title, textAlign: TextAlign.center, style: ts(16, w: FontWeight.w800)),
          if (text != null) ...[
            const Gap(6),
            ConstrainedBox(constraints: const BoxConstraints(maxWidth: 270), child: Text(text!, textAlign: TextAlign.center, style: ts(13, c: C.muted, h: 1.5))),
          ],
          if (actionLabel != null) ...[
            const Gap(14),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(foregroundColor: color, side: BorderSide(color: color.withValues(alpha: .5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: Text(actionLabel!, style: ts(13, w: FontWeight.w700, c: color)),
            ),
          ],
        ]),
      ),
    );
  }
}

/// Lingkaran bertepi putus-putus.
class DashedCircle extends StatelessWidget {
  final double size;
  final Color color;
  const DashedCircle({super.key, required this.size, required this.color});
  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(size, size), painter: _DashCirclePainter(color));
}

class _DashCirclePainter extends CustomPainter {
  final Color color;
  _DashCirclePainter(this.color);
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = color..strokeCap = StrokeCap.round;
    final r = s.width / 2 - 1;
    const n = 28;
    for (var i = 0; i < n; i++) {
      final a = i * 2 * math.pi / n;
      canvas.drawArc(Rect.fromCircle(center: Offset(s.width / 2, s.height / 2), radius: r), a, 2 * math.pi / n * .55, false, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
