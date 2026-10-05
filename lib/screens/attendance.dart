import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});
  @override
  Widget build(BuildContext context) => const SubPage(title: 'Riwayat Absensi', body: AttendanceBody());
}

class AttendanceBody extends StatefulWidget {
  const AttendanceBody({super.key});
  @override
  State<AttendanceBody> createState() => _AttendanceBodyState();
}

class _Rec {
  final String d, wd, inT, outT;
  final bool late;
  const _Rec(this.d, this.wd, this.inT, this.outT, {this.late = false});
}

class _AttendanceBodyState extends State<AttendanceBody> {
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

  @override
  Widget build(BuildContext context) {
    final m = months[i];
    Widget stat(int v, String l, Color c) => Expanded(
          child: AppCard(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(children: [
              Text('$v', style: ts(22, w: FontWeight.w800, c: c)),
              Text(l, style: ts(12, c: C.muted)),
            ]),
          ),
        );
    return Column(children: [
      Row(children: [
        IconButton(tooltip: 'Bulan sebelumnya', onPressed: i > 0 ? () => setState(() => i--) : null, icon: const Icon(Icons.chevron_left)),
        Expanded(child: Text(m.$1, textAlign: TextAlign.center, style: ts(16, w: FontWeight.w800))),
        IconButton(tooltip: 'Bulan berikutnya', onPressed: i < months.length - 1 ? () => setState(() => i++) : null, icon: const Icon(Icons.chevron_right)),
      ]),
      Row(children: [
        stat(m.$2, 'Hadir', C.green),
        const Gap(0, w: 10),
        stat(m.$3, 'Terlambat', C.orange),
        const Gap(0, w: 10),
        stat(m.$4, 'Tidak hadir', C.red),
      ]),
      const Gap(14),
      Align(alignment: Alignment.centerLeft, child: Text(m.$5, style: ts(13, c: C.muted))),
      const Gap(8),
      for (final r in m.$6)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 48,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(color: C.bg, borderRadius: BorderRadius.circular(10)),
                child: Column(children: [
                  Text(r.d, style: ts(18, w: FontWeight.w800)),
                  Text(r.wd, style: ts(11, c: C.muted)),
                ]),
              ),
              const Gap(0, w: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Day shift · 07:00 – 19:00', style: ts(13, w: FontWeight.w600)),
                  Text('Masuk ${r.inT} · Pulang ${r.outT}', style: ts(13, c: C.muted)),
                ]),
              ),
              Pill(r.late ? 'Terlambat' : 'Tepat waktu', tone: r.late ? Tone.warn : Tone.ok),
            ]),
          ),
        ),
    ]);
  }
}
