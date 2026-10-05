import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class RosterScreen extends StatefulWidget {
  const RosterScreen({super.key});
  @override
  State<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends State<RosterScreen> {
  int idx = 1;
  static const names = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
  static const List<(int, int, List<(String, String)>, String?)> defs = [
    (2026, 8, [], null),
    (2026, 9, [('5 & 11 Okt', 'Perjalanan cuti (lihat itinerary)'), ('13 Okt', 'Training Cyber Security Awareness')], null),
    (2026, 10, [('9 – 11 Nov', 'Cuti tahunan menunggu persetujuan')], 'Jadwal 2 – 15 Nov diperbarui Admin Roster dari web · 3 Okt 16:05'),
    (2026, 11, [('25 Des', 'Libur Natal (tetap mengikuti roster)')], null),
  ];
  static const events = {'2026-10-5', '2026-10-11', '2026-10-13', '2026-11-9', '2026-11-10', '2026-11-11', '2026-12-25'};

  String typeOf(int y, int mo, int d) {
    final base = DateTime.utc(2026, 8, 31);
    final n = DateTime.utc(y, mo + 1, d).difference(base).inDays;
    final cyc = (n / 21).floor();
    final pos = ((n % 21) + 21) % 21;
    if (pos >= 14) return 'O';
    return cyc % 2 == 0 ? 'N' : 'D';
  }

  @override
  Widget build(BuildContext context) {
    final (y, mo, notes, change) = defs[idx];
    final lead = DateTime.utc(y, mo + 1, 1).weekday - 1;
    final dim = DateTime.utc(y, mo + 2, 0).day;
    final cnt = {'D': 0, 'N': 0, 'O': 0};
    final cells = <Widget>[];
    for (var i = 0; i < lead; i++) {
      cells.add(const SizedBox());
    }
    for (var d = 1; d <= dim; d++) {
      final t = typeOf(y, mo, d);
      cnt[t] = cnt[t]! + 1;
      final (bg, fg, label) = switch (t) {
        'D' => (const Color(0xFFDCE7FB), C.blueFg, 'Day shift'),
        'N' => (C.navy, Colors.white, 'Night shift'),
        _ => (C.chip, C.muted, 'Off'),
      };
      final today = mo == 9 && d == 4;
      final ev = events.contains('$y-${mo + 1}-$d');
      cells.add(Semantics(
        label: '$d ${names[mo]} · $label',
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(9),
            border: today ? Border.all(color: C.orange, width: 2) : null,
          ),
          child: Stack(alignment: Alignment.center, children: [
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('$d', style: ts(14, w: FontWeight.w800, c: fg, h: 1.1)),
              Text(t == 'O' ? 'OFF' : t, style: ts(10, w: FontWeight.w700, c: fg.withValues(alpha: .8), h: 1.1)),
            ]),
            if (ev) Positioned(top: 4, right: 4, child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: C.orange, shape: BoxShape.circle))),
          ]),
        ),
      ));
    }
    Widget legend(Color bg, String t) => Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Row(children: [
            Container(width: 14, height: 14, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4))),
            const Gap(0, w: 6),
            Text(t, style: ts(12, c: C.text2)),
          ]),
        );
    return SubPage(
      title: 'Jadwal Kerja',
      actions: [
        TextButton(onPressed: () => setState(() => idx = 1), child: Text('Hari ini', style: ts(13, w: FontWeight.w700, c: C.blue))),
      ],
      body: GestureDetector(
        onHorizontalDragEnd: (d) {
          final v = d.primaryVelocity ?? 0;
          if (v < -200 && idx < defs.length - 1) setState(() => idx++);
          if (v > 200 && idx > 0) setState(() => idx--);
        },
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Sinkron dari web · diperbarui 15:40 · pola 14/7', style: ts(12, c: C.muted)),
          const Gap(10),
          Row(children: [legend(const Color(0xFFDCE7FB), 'Day 07–19'), legend(C.navy, 'Night 19–07'), legend(C.chip, 'Off')]),
          const Gap(10),
          AppCard(
            child: Column(children: [
              Row(children: [
                IconButton(tooltip: 'Bulan sebelumnya', onPressed: idx > 0 ? () => setState(() => idx--) : null, icon: const Icon(Icons.chevron_left)),
                Expanded(
                  child: Column(children: [
                    Text('${names[mo]} $y', style: ts(16, w: FontWeight.w800)),
                    Text('Day ${cnt['D']} · Night ${cnt['N']} · Off ${cnt['O']}', style: ts(12, c: C.muted)),
                  ]),
                ),
                IconButton(tooltip: 'Bulan berikutnya', onPressed: idx < defs.length - 1 ? () => setState(() => idx++) : null, icon: const Icon(Icons.chevron_right)),
              ]),
              const Gap(8),
              Row(children: [for (final w in ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']) Expanded(child: Center(child: Text(w, style: ts(11, w: FontWeight.w700, c: C.muted))))]),
              const Gap(6),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: .95,
                children: cells,
              ),
            ]),
          ),
          const Gap(6),
          Center(child: Text('Geser kiri / kanan untuk ganti bulan', style: ts(11, c: C.muted))),
          const Gap(10),
          if (change != null) ...[Notice(change, tone: Tone.info, icon: Icons.sync), const Gap(12)],
          SectionLabel('AGENDA ${names[mo].toUpperCase()}'),
          if (notes.isEmpty) Text('Tidak ada agenda.', style: ts(13, c: C.muted)),
          for (final n in notes)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: C.orange, shape: BoxShape.circle)),
                  const Gap(0, w: 10),
                  Text(n.$1, style: ts(13, w: FontWeight.w800)),
                  const Gap(0, w: 8),
                  Expanded(child: Text(n.$2, style: ts(13, c: C.text2))),
                ]),
              ),
            ),
        ]),
      ),
    );
  }
}
