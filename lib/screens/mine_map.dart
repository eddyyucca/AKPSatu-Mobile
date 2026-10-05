import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class MineMapScreen extends StatefulWidget {
  const MineMapScreen({super.key});
  @override
  State<MineMapScreen> createState() => _MineMapScreenState();
}

class _MineMapScreenState extends State<MineMapScreen> {
  String layer = 'prog';
  final shares = <(String, String)>[('PT Karya Mandiri (kontraktor)', 'Lihat saja · s/d 6 Okt 18:00')];

  static const pits = [
    ('A', 'Pit A', 78, 75, 'Pengupasan OB di atas rencana'),
    ('B', 'Pit B', 54, 60, 'Tertinggal 6% · hujan 3 hari'),
    ('C', 'Pit C', 22, 25, 'Tahap awal land clearing'),
    ('D', 'Disposal D1', 90, 85, 'Mendekati kapasitas desain'),
  ];

  static Color col(int v) => v >= 75 ? const Color(0xFF1F7A47) : v >= 40 ? const Color(0xFFE7A23B) : const Color(0xFFD96B5A);

  @override
  Widget build(BuildContext context) => SubPage(
        title: 'Peta Progres Tambang',
        subtitle: 'Mine Plan · update 3 Okt 2026',
        actions: [
          TextButton.icon(onPressed: _share, icon: const Icon(Icons.ios_share, size: 18), label: const Text('Bagikan')),
        ],
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Notice('Tersimpan offline · diunduh 06:00', tone: Tone.info, icon: Icons.cloud_done_outlined),
          const Gap(12),
          Seg(tabs: const ['Progres', 'Rencana'], index: layer == 'prog' ? 0 : 1, onChange: (v) => setState(() => layer = v == 0 ? 'prog' : 'plan')),
          const Gap(12),
          AspectRatio(
            aspectRatio: 1.15,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: InteractiveViewer(
                maxScale: 4,
                child: CustomPaint(painter: _MapPainter(layer == 'plan'), child: const SizedBox.expand()),
              ),
            ),
          ),
          const Gap(8),
          Row(children: [
            for (final l in [(const Color(0xFF1F7A47), '≥ 75%'), (const Color(0xFFE7A23B), '40 – 74%'), (const Color(0xFFD96B5A), '< 40%')])
              Padding(padding: const EdgeInsets.only(right: 14), child: Row(children: [Container(width: 12, height: 12, decoration: BoxDecoration(color: l.$1, borderRadius: BorderRadius.circular(3))), const Gap(0, w: 6), Text(l.$2, style: ts(12, c: C.text2))])),
          ]),
          const SectionLabel('PROGRES VS RENCANA OKTOBER'),
          for (final p in pits)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(p.$2, style: ts(14, w: FontWeight.w800))),
                    Text('${p.$3}% / rencana ${p.$4}%', style: ts(13, w: FontWeight.w700, c: p.$3 >= p.$4 ? C.greenFg : C.orangeFg)),
                  ]),
                  const Gap(8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Stack(children: [
                      Container(height: 8, color: C.chip),
                      FractionallySizedBox(widthFactor: p.$3 / 100, child: Container(height: 8, color: col(p.$3))),
                      Positioned(left: (MediaQuery.of(context).size.width - 64) * p.$4 / 100, child: Container(width: 2, height: 8, color: C.navy)),
                    ]),
                  ),
                  const Gap(6),
                  Text(p.$5, style: ts(12, c: C.muted)),
                ]),
              ),
            ),
          const SectionLabel('BAGIKAN PETA DENGAN TOKEN'),
          Text('Beri akses lihat peta ke pihak lain (mis. kontraktor) tanpa akun AKPSatu, dengan masa berlaku.', style: ts(13, c: C.muted, h: 1.4)),
          const Gap(10),
          PrimaryButton('Bagikan Peta', icon: Icons.ios_share, onTap: _share),
          const SectionLabel('AKSES AKTIF'),
          for (final s in shares)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.$1, style: ts(14, w: FontWeight.w700)), Text(s.$2, style: ts(12, c: C.muted))])),
                  TextButton(onPressed: () => setState(() => shares.remove(s)), child: Text('Cabut', style: ts(13, w: FontWeight.w700, c: C.red))),
                ]),
              ),
            ),
        ]),
      );

  void _share() {
    String who = '';
    String valid = '7 hari';
    String acc = 'Lihat saja';
    bool made = false;
    sheet(context, (ctx) => StatefulBuilder(
          builder: (ctx, set) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Bagikan Peta', style: ts(18, w: FontWeight.w800)),
            const Gap(14),
            if (!made) ...[
              TextBox('Penerima', hint: 'Nama / perusahaan', onChanged: (v) => who = v),
              LabeledField('Berlaku', ChoiceRow(options: const ['24 jam', '3 hari', '7 hari'], selected: valid, onSelect: (v) => set(() => valid = v))),
              LabeledField('Akses', ChoiceRow(options: const ['Lihat saja', 'Lihat + unduh'], selected: acc, onSelect: (v) => set(() => acc = v))),
              PrimaryButton('Buat token akses', onTap: () => set(() => made = true)),
            ] else ...[
              Text('Token akses · berlaku s/d 7 Okt 15:24', style: ts(13, c: C.muted)),
              const Gap(8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(color: C.bg, borderRadius: BorderRadius.circular(12)),
                child: Text('MAP-7K2Q-91XD', textAlign: TextAlign.center, style: ts(24, w: FontWeight.w800).copyWith(letterSpacing: 2)),
              ),
              const Gap(12),
              Row(children: [
                Expanded(child: OutlineButton('Salin token', onTap: () => toast(context, 'Token disalin'))),
                const Gap(0, w: 10),
                Expanded(child: OutlineButton('Salin link', onTap: () => toast(context, 'Link disalin'))),
              ]),
              const Gap(10),
              PrimaryButton('Selesai', onTap: () {
                Navigator.pop(ctx);
                setState(() => shares.add((who.isEmpty ? 'Penerima baru' : who, '$acc · $valid')));
              }),
            ],
          ]),
        ));
  }
}

class _MapPainter extends CustomPainter {
  final bool plan;
  _MapPainter(this.plan);

  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawRect(Offset.zero & s, Paint()..color = const Color(0xFFE9EEE4));
    final grid = Paint()..color = Colors.black.withValues(alpha: .05)..strokeWidth = 1;
    for (var i = 1; i < 8; i++) {
      canvas.drawLine(Offset(0, s.height * i / 8), Offset(s.width, s.height * i / 8), grid);
      canvas.drawLine(Offset(s.width * i / 8, 0), Offset(s.width * i / 8, s.height), grid);
    }
    Path blob(double cx, double cy, double rx, double ry) => Path()..addOval(Rect.fromCenter(center: Offset(s.width * cx, s.height * cy), width: s.width * rx, height: s.height * ry));
    void zone(String label, Path p, int v, {bool dashed = false}) {
      canvas.drawPath(p, Paint()..color = plan ? const Color(0xFFC9D8F5) : _MineMapScreenState.col(v));
      canvas.drawPath(p, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
      final tp = TextPainter(text: TextSpan(text: label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)), textDirection: TextDirection.ltr)..layout();
      final b = p.getBounds();
      tp.paint(canvas, b.center - Offset(tp.width / 2, tp.height / 2));
    }

    zone('Pit A', blob(.28, .3, .36, .3), 78);
    zone('Pit B', blob(.7, .28, .32, .26), 54);
    zone('Pit C', blob(.3, .74, .3, .24), 22);
    zone('D1', blob(.74, .72, .26, .24), 90);
    final road = Path()..moveTo(0, s.height * .52)..quadraticBezierTo(s.width * .5, s.height * .46, s.width, s.height * .55);
    canvas.drawPath(road, Paint()..color = const Color(0xFF8A94A3)..style = PaintingStyle.stroke..strokeWidth = 5);
    canvas.drawCircle(Offset(s.width * .5, s.height * .5), 9, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(s.width * .5, s.height * .5), 6, Paint()..color = C.navy);
    final tp = TextPainter(text: const TextSpan(text: 'ROM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: C.navy)), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(s.width * .5 + 12, s.height * .5 - 6));
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => old.plan != plan;
}
