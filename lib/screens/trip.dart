import 'dart:math' as math;
import 'package:flutter/material.dart' hide Text;
import '../theme.dart';
import '../widgets.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key});
  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  bool back = false;

  Widget _sec(String icon, String t) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
        child: Row(children: [
          Ic(icon, size: 16, stroke: 2, color: C.muted),
          const Gap(0, w: 8),
          Text(t, style: ts(13, w: FontWeight.w800, c: C.muted).copyWith(letterSpacing: .3)),
        ]),
      );

  Widget _kv(String k, String v) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(k, style: ts(11, c: C.muted, h: 1.35)),
        Text(v, style: ts(14, w: FontWeight.w700, h: 1.35)),
      ]);

  Widget _kvGrid(List<(String, String)> items, int cols, {double gap = 12}) => Column(children: [
        for (var r = 0; r < items.length; r += cols) ...[
          if (r > 0) Gap(gap),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (var c = r; c < r + cols; c++) ...[
              if (c > r) Gap(0, w: gap),
              Expanded(child: c < items.length ? _kv(items[c].$1, items[c].$2) : const SizedBox()),
            ],
          ]),
        ],
      ]);

  Widget _seatMap(int mine) {
    var n = 1;
    final cells = <Widget>[];
    for (var r = 0; r < 5; r++) {
      for (var c = 0; c < 5; c++) {
        if (c == 2) {
          cells.add(const SizedBox());
          continue;
        }
        final me = n == mine;
        cells.add(Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(color: me ? C.blue : const Color(0xFFEEF1F5), borderRadius: BorderRadius.circular(6)),
          child: Text('$n', style: ts(12, w: FontWeight.w700, c: me ? Colors.white : C.muted)),
        ));
        n++;
      }
    }
    return Semantics(
      label: 'Denah kursi, kursi Anda nomor $mine',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Denah kursi (depan di atas)', style: ts(12, c: C.muted)),
        const Gap(6),
        for (var r = 0; r < 5; r++) ...[
          if (r > 0) const Gap(6),
          SizedBox(height: 30, child: Row(children: [for (var c = 0; c < 5; c++) ...[if (c > 0) const Gap(0, w: 6), Expanded(child: cells[r * 5 + c])]])),
        ],
      ]),
    );
  }

  Widget _pickup({required String date, required String title, required String note, required String seat, required String unit, required String plate, required String dest, required String ini, required Color avBg, required Color avFg, required String driver, required String phone}) =>
      Card14(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(date, style: ts(12, c: C.muted, h: 1.4)),
                Text(title, style: ts(22, w: FontWeight.w800, h: 1.4)),
                Text(note, style: ts(13, c: C.text2, h: 1.4)),
              ]),
            ),
            const Gap(0, w: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: C.blue, borderRadius: BorderRadius.circular(12)),
              child: Column(children: [Text('Kursi', style: ts(11, c: const Color(0xFFDCE7FB), h: 1.1)), Text(seat, style: ts(28, w: FontWeight.w800, c: Colors.white, h: 1.1))]),
            ),
          ]),
          const Gap(14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: C.bg, borderRadius: BorderRadius.circular(10)),
            child: _kvGrid([('No. unit', unit), ('No. polisi', plate), ('Jenis', 'Bus 20 kursi'), ('Tujuan', dest)], 2, gap: 10),
          ),
          const Gap(14),
          _seatMap(int.parse(seat)),
          const Gap(14),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFEEF1F5)))),
            child: Row(children: [
              Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(color: avBg, shape: BoxShape.circle), child: Text(ini, style: ts(14, w: FontWeight.w800, c: avFg))),
              const Gap(0, w: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Driver', style: ts(12, c: C.muted, h: 1.4)),
                  Text(driver, style: ts(15, w: FontWeight.w700, h: 1.4)),
                  Text(phone, style: ts(13, c: C.muted, h: 1.4)),
                ]),
              ),
              Semantics(
                button: true,
                label: 'Telepon driver $driver',
                child: Material(
                  color: C.greenBg,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => toast(context, 'Menelepon $driver (demo)'), child: const SizedBox(width: 44, height: 44, child: Center(child: Ic('phone', color: C.greenFg)))),
                ),
              ),
            ]),
          ),
        ]),
      );

  Widget _ticket({required String from, required String fromCity, required String fromT, required String to, required String toCity, required String toT, required List<(String, String)> kv}) => Container(
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          Container(
            color: C.navy,
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(from, style: ts(28, w: FontWeight.w800, c: Colors.white, h: 1.2)),
                Text(fromCity, style: ts(12, c: C.pale, h: 1.2)),
                const Gap(4),
                Text(fromT, style: ts(15, w: FontWeight.w700, c: Colors.white, h: 1.2)),
              ]),
              Expanded(child: Column(children: [Transform.rotate(angle: math.pi / 4, child: const Ic('plane', size: 22, color: Color(0xFF5B95F5))), const Gap(4), Text('1 j 15 m', style: ts(11, c: C.pale))])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(to, style: ts(28, w: FontWeight.w800, c: Colors.white, h: 1.2)),
                Text(toCity, style: ts(12, c: C.pale, h: 1.2)),
                const Gap(4),
                Text(toT, style: ts(15, w: FontWeight.w700, c: Colors.white, h: 1.2)),
              ]),
            ]),
          ),
          Padding(padding: const EdgeInsets.fromLTRB(16, 14, 16, 14), child: _kvGrid(kv, 3)),
          const DashedLine(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              Expanded(child: _btn('Lihat e-tiket', true)),
              const Gap(0, w: 10),
              Expanded(child: _btn('Unduh PDF', false)),
            ]),
          ),
        ]),
      );

  Widget _btn(String t, bool primary) => Material(
        color: primary ? C.blue : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: primary ? BorderSide.none : const BorderSide(color: C.input)),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => toast(context, '$t (demo)'),
          child: SizedBox(height: 44, child: Center(child: Text(t, style: ts(14, w: FontWeight.w700, c: primary ? Colors.white : C.text)))),
        ),
      );

  Widget _tab(String t, bool on, VoidCallback tap) => Expanded(
        child: Material(
          color: on ? C.blue : const Color(0xFFEEF1F5),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(borderRadius: BorderRadius.circular(10), onTap: tap, child: SizedBox(height: 44, child: Center(child: Text(t, style: ts(14, w: on ? FontWeight.w700 : FontWeight.w600, c: on ? Colors.white : C.text2))))),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: C.bg,
        body: SafeArea(
          child: Column(children: [
            const PageHeader('Perjalanan Cuti', border: false),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: C.line))),
              child: Row(children: [_tab('Berangkat · 5 Okt', !back, () => setState(() => back = false)), const Gap(0, w: 6), _tab('Kembali · 11 Okt', back, () => setState(() => back = true))]),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Flexible(child: Text('Off roster 5 – 11 Okt 2026', style: ts(13, c: C.muted))),
                    const Pill('Terkonfirmasi', tone: Tone.ok),
                  ]),
                  const Gap(12),
                  if (!back) ...[
                    _sec('bus', '1 · JEMPUTAN KE BANDARA'),
                    const Gap(12),
                    _pickup(date: 'Senin, 5 Okt 2026', title: 'Jemput 05:30', note: 'Titik kumpul: Lobby Mess Blok C', seat: '14', unit: 'BUS-07', plate: 'DT 7421 KB', dest: 'Bandara KDI', ini: 'RH', avBg: const Color(0xFFDCE7FB), avFg: C.blueFg, driver: 'Rahmat Hidayat', phone: '0813 •••• 2210'),
                    const Gap(12),
                    _sec('plane', '2 · TIKET PESAWAT'),
                    const Gap(12),
                    _ticket(from: 'KDI', fromCity: 'Kendari', fromT: '09:40', to: 'UPG', toCity: 'Makassar', toT: '10:55', kv: const [('Tanggal', '5 Okt 2026'), ('Penerbangan', 'XX 1234'), ('Kursi', '12A'), ('Kode booking', 'K7P2QD'), ('Bagasi', '20 kg'), ('Kelas', 'Ekonomi')]),
                  ] else ...[
                    _sec('plane', '1 · TIKET PESAWAT'),
                    const Gap(12),
                    _ticket(from: 'UPG', fromCity: 'Makassar', fromT: '07:10', to: 'KDI', toCity: 'Kendari', toT: '08:25', kv: const [('Tanggal', '11 Okt 2026'), ('Penerbangan', 'XX 1231'), ('Kursi', '8C'), ('Kode booking', 'M3RX8T'), ('Bagasi', '20 kg'), ('Kelas', 'Ekonomi')]),
                    const Gap(12),
                    _sec('bus', '2 · JEMPUTAN KE SITE'),
                    const Gap(12),
                    _pickup(date: 'Minggu, 11 Okt 2026', title: 'Jemput 08:45', note: 'Titik kumpul: Bandara KDI, pintu kedatangan', seat: '6', unit: 'BUS-03', plate: 'DT 7188 KB', dest: 'Mess Blok C', ini: 'YR', avBg: C.tealBg, avFg: C.teal, driver: 'Yusuf Rahman', phone: '0812 •••• 5531'),
                  ],
                ]),
              ),
            ),
          ]),
        ),
      );
}
