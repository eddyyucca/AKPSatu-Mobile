import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';
import 'shell.dart';

class _Rec {
  final String d, wd, inT, outT;
  final bool late;
  const _Rec(this.d, this.wd, this.inT, this.outT, {this.late = false});
}

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});
  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  int i = 1;
  static const months = [
    ('September 2026', 23, 2, 0, '7 catatan terakhir', [
      _Rec('30', 'Rab', '06:48', '19:05'),
      _Rec('29', 'Sel', '07:12', '19:02', late: true),
      _Rec('28', 'Sen', '06:55', '19:10'),
      _Rec('27', 'Min', '06:50', '19:01'),
      _Rec('26', 'Sab', '06:46', '19:00'),
      _Rec('25', 'Jum', '07:05', '19:03', late: true),
      _Rec('24', 'Kam', '06:52', '19:06'),
    ]),
    ('Oktober 2026', 2, 0, 0, 'Hari ini belum ada catatan absen', [
      _Rec('02', 'Jum', '06:51', '19:04'),
      _Rec('01', 'Kam', '06:58', '19:02'),
    ]),
  ];

  Widget _navBtn(String label, VoidCallback onTap, {bool flip = false}) => Semantics(
        button: true,
        label: label,
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: C.input)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: SizedBox(width: 44, height: 44, child: Center(child: Transform.flip(flipX: flip, child: const Ic('back', size: 20, stroke: 2)))),
          ),
        ),
      );

  // Mockup: angka dibungkus <span> yang terkena `.sm span` (12px, abu-abu) di dalam <b> setinggi 28px,
  // lalu label di baris 21px.
  Widget _sm(int v, String l, Color c) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            SizedBox(height: 28, child: Padding(padding: const EdgeInsets.only(top: 10), child: Text('$v', style: ts(12, w: FontWeight.w800, c: C.muted)))),
            Padding(padding: const EdgeInsets.only(top: 5, bottom: 1), child: Text(l, style: ts(12, c: C.muted))),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final m = months[i];
    return Column(children: [
      TabHeader('Riwayat Absensi',
          extra: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _navBtn('Bulan sebelumnya', () => setState(() => i = (i - 1).clamp(0, months.length - 1))),
            Text(m.$1, style: ts(16, w: FontWeight.w700)),
            _navBtn('Bulan berikutnya', () => setState(() => i = (i + 1).clamp(0, months.length - 1)), flip: true),
          ])),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [_sm(m.$2, 'Hadir', C.greenFg), const Gap(0, w: 10), _sm(m.$3, 'Terlambat', C.orangeFg), const Gap(0, w: 10), _sm(m.$4, 'Tidak hadir', C.red)]),
            const Gap(16),
            Text(m.$5, style: ts(13, c: C.muted)),
            for (final r in m.$6)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
                  child: IntrinsicHeight(
                    child: Row(children: [
                      SizedBox(
                        width: 48,
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Text(r.d, style: ts(20, w: FontWeight.w800, h: 1.15)),
                          Text(r.wd, style: ts(12, c: C.muted, h: 1.15)),
                        ]),
                      ),
                      const Gap(0, w: 14),
                      Container(width: 1, color: const Color(0xFFEEF1F5)),
                      const Gap(0, w: 14),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text('Day shift · 07:00 – 19:00', style: ts(13, c: C.muted, h: 18.85 / 13)),
                          Text('Masuk ${r.inT} · Pulang ${r.outT}', style: ts(14, w: FontWeight.w700, h: 20.3 / 14)),
                        ]),
                      ),
                      const Gap(0, w: 14),
                      Center(child: Pill(r.late ? 'Terlambat' : 'Tepat waktu', tone: r.late ? Tone.warn : Tone.ok)),
                    ]),
                  ),
                ),
              ),
          ]),
        ),
      ),
    ]);
  }
}
