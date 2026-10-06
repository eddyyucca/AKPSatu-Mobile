import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import 'shell.dart';

class BarcodePage extends StatelessWidget {
  const BarcodePage({super.key});

  static List<List<bool>> _matrix() {
    const n = 25;
    var seed = 1749;
    double rnd() {
      seed = (seed * 9301 + 49297) % 233280;
      return seed / 233280;
    }

    int finder(int r, int c) {
      for (final o in [(0, 0), (0, n - 7), (n - 7, 0)]) {
        final dr = r - o.$1, dc = c - o.$2;
        if (dr >= -1 && dr <= 7 && dc >= -1 && dc <= 7) {
          if (dr < 0 || dr > 6 || dc < 0 || dc > 6) return 0;
          final ring = dr == 0 || dr == 6 || dc == 0 || dc == 6;
          final core = dr >= 2 && dr <= 4 && dc >= 2 && dc <= 4;
          return ring || core ? 1 : 0;
        }
      }
      return -1;
    }

    return [
      for (var r = 0; r < n; r++)
        [
          for (var c = 0; c < n; c++)
            () {
              var v = finder(r, c);
              if (v == -1) v = (r == 6 || c == 6) ? ((r + c) % 2 == 0 ? 1 : 0) : (rnd() > .52 ? 1 : 0);
              return v == 1;
            }()
        ]
    ];
  }

  Widget _meal(String t, String menu, String time, String badge, Tone tone, {bool first = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: first ? null : const Border(top: BorderSide(color: Color(0xFFEEF1F5)))),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t, style: ts(14, w: FontWeight.w700, h: 1.4)),
              Text(menu, style: ts(12, c: C.text2, h: 1.4)),
              Text(time, style: ts(12, c: C.muted, h: 1.4)),
            ]),
          ),
          const Gap(0, w: 12),
          Pill(badge, tone: tone),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final m = _matrix();
    return Column(children: [
      const TabHeader('Barcode Makan'),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
              child: Column(children: [
                Text('Eddy Adha Saputra', style: ts(17, w: FontWeight.w800, h: 1.4)),
                Text('NIK 32601949 · IT Department', style: ts(13, c: C.muted, h: 1.4)),
                const Gap(14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(12)),
                  child: Semantics(
                    label: 'QR code makan untuk NIK 32601949',
                    child: CustomPaint(size: const Size(225, 225), painter: _QrPainter(m)),
                  ),
                ),
                const Gap(14),
                Text('Tunjukkan QR ini ke kiosk kantin.\nNaikkan kecerahan layar bila sulit terbaca.', textAlign: TextAlign.center, style: ts(14, c: C.text2, h: 1.5)),
              ]),
            ),
            const Gap(14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Gap(12),
                Text('Menu & jatah makan hari ini', style: ts(14, w: FontWeight.w800)),
                Text('Menu dipublikasikan Dept. Kantin', style: ts(12, c: C.muted)),
                const Gap(4),
                _meal('Sarapan', 'Nasi kuning, telur balado, buah', '05:30 – 08:00 · diambil 06:12', 'Sudah diambil', Tone.ok, first: true),
                _meal('Makan Siang', 'Nasi, ayam bakar, sayur asem, tempe', '11:00 – 13:30 · diambil 12:05', 'Sudah diambil', Tone.ok),
                _meal('Makan Malam', 'Nasi, ikan kuah kuning, tumis kangkung', '17:30 – 20:30', 'Tersedia', Tone.info),
              ]),
            ),
          ]),
        ),
      ),
    ]);
  }
}

class _QrPainter extends CustomPainter {
  final List<List<bool>> m;
  _QrPainter(this.m);
  @override
  void paint(Canvas canvas, Size size) {
    final n = m.length;
    const cell = 9.0;
    final p = Paint()..color = C.navy..isAntiAlias = false;
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        if (m[r][c]) canvas.drawRect(Rect.fromLTWH(c * cell, r * cell, cell, cell), p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
