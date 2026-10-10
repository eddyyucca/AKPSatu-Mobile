import 'package:flutter/material.dart' hide Text;
import '../l10n/lang.dart';
import '../api/api.dart';
import '../theme.dart';
import '../widgets.dart';
import 'roster_live.dart';

class RosterScreen extends StatefulWidget {
  const RosterScreen({super.key});
  @override
  State<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends State<RosterScreen> {
  int idx = 1;
  final ctrl = PageController(initialPage: 1);

  static const names = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
  static const List<(int, int, List<(String, String)>, String)> defs = [
    (2026, 8, [], ''),
    (2026, 9, [('5 & 11 Okt', 'Perjalanan cuti (lihat itinerary)'), ('13 Okt', 'Training Cyber Security Awareness')], ''),
    (2026, 10, [('9 – 11 Nov', 'Cuti tahunan menunggu persetujuan')], 'Jadwal 2 – 15 Nov diperbarui Admin Roster dari web · 3 Okt 16:05'),
    (2026, 11, [('25 Des', 'Libur Natal (tetap mengikuti roster)')], ''),
  ];
  static const events = {'2026-10-5', '2026-10-11', '2026-10-13', '2026-11-9', '2026-11-10', '2026-11-11', '2026-12-25'};

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  String typeOf(int y, int mo, int d) {
    final base = DateTime.utc(2026, 8, 31);
    final n = DateTime.utc(y, mo + 1, d).difference(base).inDays;
    final cyc = (n / 21).floor();
    final pos = ((n % 21) + 21) % 21;
    if (pos >= 14) return 'O';
    return cyc % 2 == 0 ? 'N' : 'D';
  }

  Map<String, int> counts(int y, int mo) {
    final dim = DateTime.utc(y, mo + 2, 0).day;
    final c = {'D': 0, 'N': 0, 'O': 0};
    for (var d = 1; d <= dim; d++) {
      final t = typeOf(y, mo, d);
      c[t] = c[t]! + 1;
    }
    return c;
  }

  void go(int i) {
    final j = i.clamp(0, defs.length - 1);
    ctrl.animateToPage(j, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    setState(() => idx = j);
  }

  Widget _legend(Widget sw, String t) => Row(mainAxisSize: MainAxisSize.min, children: [sw, const Gap(0, w: 6), Text(t, style: ts(12, c: C.text2))]);

  Widget _navBtn(String label, String icon, VoidCallback onTap) => Semantics(
        button: true,
        label: label,
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: C.input)),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: SizedBox(width: 40, height: 40, child: Center(child: Ic(icon, size: 18, stroke: 2))),
          ),
        ),
      );

  Widget _cell(int y, int mo, int d) {
    final t = typeOf(y, mo, d);
    final (bg, fg) = switch (t) {
      'D' => (const Color(0xFFDCE7FB), C.blueFg),
      'N' => (C.navy, Colors.white),
      _ => (const Color(0xFFEEF1F5), C.muted),
    };
    final today = mo == 9 && d == 4;
    final ev = events.contains('$y-${mo + 1}-$d');
    final label = switch (t) { 'D' => 'Day shift', 'N' => 'Night shift', _ => 'Off' };
    return Semantics(
      label: '$d ${names[mo]} · $label',
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(9)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('$d', style: ts(13, w: FontWeight.w700, c: fg, h: 1.1)),
              Text(t == 'O' ? 'OFF' : t, style: ts(9, w: FontWeight.w800, c: fg.withValues(alpha: .85), h: 1.1)),
            ]),
          ),
        ),
        if (today)
          Positioned(
            left: -3,
            top: -3,
            right: -3,
            bottom: -3,
            child: IgnorePointer(child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: C.orange, width: 2)))),
          ),
        if (ev) Positioned(top: 3, right: 3, child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: C.orange, shape: BoxShape.circle))),
      ]),
    );
  }

  Widget _pane(int k) {
    final (y, mo, _, _) = defs[k];
    final lead = DateTime.utc(y, mo + 1, 1).weekday - 1;
    final dim = DateTime.utc(y, mo + 2, 0).day;
    final rows = <Widget>[];
    for (var r = 0; r < 6; r++) {
      rows.add(SizedBox(
        height: 44,
        child: Row(children: [
          for (var c = 0; c < 7; c++) ...[
            if (c > 0) const Gap(0, w: 5),
            Expanded(
              child: () {
                final d = r * 7 + c - lead + 1;
                if (d < 1 || d > dim) return const SizedBox();
                return _cell(y, mo, d);
              }(),
            ),
          ],
        ]),
      ));
    }
    return MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling), child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(children: [
        Row(children: [
          for (var c = 0; c < 7; c++) ...[
            if (c > 0) const Gap(0, w: 5),
            Expanded(child: Center(child: Text(['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'][c], style: ts(11, w: FontWeight.w700, c: C.muted)))),
          ],
        ]),
        const Gap(6),
        for (var r = 0; r < rows.length; r++) ...[if (r > 0) const Gap(5), rows[r]],
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    L.watch(context);
    // Sudah login: tampilkan roster sungguhan dari HRIS (sama dengan web). Tanpa sesi: tampilan contoh.
    if (Session.instance.active) return const LiveRosterScreen();
    final (y, mo, notes, change) = defs[idx];
    final cnt = counts(y, mo);
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(children: [
          PageHeader('Jadwal Kerja',
              border: false,
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(99),
                  onTap: () => go(1),
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(99), border: Border.all(color: C.input)),
                    child: Text('Hari ini', style: ts(13, w: FontWeight.w700)),
                  ),
                ),
              )),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: C.line))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: C.green, shape: BoxShape.circle)),
                const Gap(0, w: 8),
                Expanded(child: Text('Sinkron dari web · diperbarui 15:40 · pola 14/7', style: ts(12, w: FontWeight.w600, c: C.greenFg))),
              ]),
              const Gap(8),
              Wrap(spacing: 14, runSpacing: 14, children: [
                _legend(Container(width: 14, height: 14, decoration: BoxDecoration(color: const Color(0xFFDCE7FB), borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFF9DB9EE)))), 'Day 07–19'),
                _legend(Container(width: 14, height: 14, decoration: BoxDecoration(color: C.navy, borderRadius: BorderRadius.circular(4))), 'Night 19–07'),
                _legend(Container(width: 14, height: 14, decoration: BoxDecoration(color: const Color(0xFFEEF1F5), borderRadius: BorderRadius.circular(4), border: Border.all(color: C.input))), 'Off'),
                _legend(Container(width: 8, height: 8, decoration: const BoxDecoration(color: C.orange, shape: BoxShape.circle)), 'Agenda'),
              ]),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              child: Column(children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(0, 12, 0, 14),
                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(16)),
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        _navBtn('Bulan sebelumnya', 'back', () => go(idx - 1)),
                        Column(children: [
                          Text(L.instance.monthYear(DateTime(y, mo + 1)), style: ts(17, w: FontWeight.w800, h: 1.3)),
                          Text('Day ${cnt['D']} · Night ${cnt['N']} · Off ${cnt['O']}', style: ts(12, c: C.muted, h: 1.3)),
                        ]),
                        _navBtn('Bulan berikutnya', 'chevron', () => go(idx + 1)),
                      ]),
                    ),
                    const Gap(10),
                    SizedBox(
                      height: 19 + 6 + 289 - 6,
                      child: PageView.builder(
                        controller: ctrl,
                        itemCount: defs.length,
                        onPageChanged: (i) => setState(() => idx = i),
                        itemBuilder: (_, k) => _pane(k),
                      ),
                    ),
                    const Gap(10),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      for (var i = 0; i < defs.length; i++) ...[
                        if (i > 0) const Gap(0, w: 6),
                        Container(width: i == idx ? 18 : 6, height: 6, decoration: BoxDecoration(color: i == idx ? C.blue : const Color(0xFFC4CDD9), borderRadius: BorderRadius.circular(3))),
                      ],
                    ]),
                    const Gap(10),
                    Text('Geser kiri / kanan untuk ganti bulan', style: ts(11, c: C.muted)),
                  ]),
                ),
                const Gap(12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${tr('Agenda')} ${L.instance.monthYear(DateTime(y, mo + 1))}', style: ts(14, w: FontWeight.w800)),
                    for (final n in notes) ...[
                      const Gap(8),
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(padding: const EdgeInsets.only(top: 6), child: Container(width: 7, height: 7, decoration: const BoxDecoration(color: C.orange, shape: BoxShape.circle))),
                        const Gap(0, w: 8),
                        Expanded(
                          child: Text.rich(
                            TextSpan(children: [TextSpan(text: n.$1, style: ts(13, w: FontWeight.w700, c: C.text2, h: 1.4)), TextSpan(text: ' · ${n.$2}', style: ts(13, c: C.text2, h: 1.4))]),
                          ),
                        ),
                      ]),
                    ],
                    if (notes.isEmpty) ...[const Gap(8), Text('Tidak ada agenda.', style: ts(13, c: C.muted))],
                    if (change.isNotEmpty) ...[
                      const Gap(8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(color: C.blueSoft, borderRadius: BorderRadius.circular(8)),
                        child: Text(change, style: ts(12, c: C.blueFg)),
                      ),
                    ],
                  ]),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
