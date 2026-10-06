import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});
  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  bool ls = false;

  Widget _day(String t) => Padding(padding: const EdgeInsets.fromLTRB(0, 10, 0, 2), child: Text(t, style: ts(12, w: FontWeight.w800, c: C.muted).copyWith(letterSpacing: .4)));

  Widget _chip(String t, Color bg, Color fg, {bool bold = true}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Text(t, style: ts(12, w: bold ? FontWeight.w700 : FontWeight.w600, c: fg)),
      );

  Widget _ev({
    required String time,
    required Color dot,
    required Widget box,
    bool line = true,
    String? route,
    bool dashed = false,
  }) =>
      IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(width: 42, child: Padding(padding: const EdgeInsets.only(top: 15), child: Text(time, textAlign: TextAlign.right, style: ts(12, w: FontWeight.w800, c: C.text2)))),
          const Gap(0, w: 10),
          SizedBox(
            width: 14,
            child: Column(children: [
              Padding(padding: const EdgeInsets.only(top: 17), child: Container(width: 12, height: 12, decoration: BoxDecoration(color: dot, shape: BoxShape.circle))),
              if (line) Expanded(child: Container(width: 2, color: C.input)),
            ]),
          ),
          const Gap(0, w: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: dashed ? const Color(0xFFF8FAFC) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: C.line)),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: route == null ? null : () => Navigator.pushNamed(context, route),
                  child: SizedBox(width: double.infinity, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), child: box)),
                ),
              ),
            ),
          ),
        ]),
      );

  Widget _b(String t) => Text(t, style: ts(14, w: FontWeight.w700));
  Widget _s(String t) => Text(t, style: ts(13, c: C.muted, h: 1.45));

  Widget _rd(String t) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
          decoration: BoxDecoration(color: C.navy2, borderRadius: BorderRadius.circular(10)),
          child: Column(children: [
            const Ic('check', size: 18, stroke: 2.4, color: Color(0xFF7FE0A6)),
            const Gap(4),
            Text(t, textAlign: TextAlign.center, style: ts(11, w: FontWeight.w600, c: const Color(0xFFDCE7FB))),
          ]),
        ),
      );

  Widget _lsr(String a, String b) => Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFEEF1F5)))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(a, style: ts(13, c: C.muted))),
          const Gap(0, w: 12),
          Text(b, style: ts(13, w: FontWeight.w700)),
        ]),
      );

  Widget _dotRow(String t) => Row(children: [
        Container(width: 8, height: 8, decoration: const BoxDecoration(color: C.green, shape: BoxShape.circle)),
        const Gap(0, w: 8),
        Expanded(child: Text(t, style: ts(12, c: C.text2))),
      ]);

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: C.bg,
        body: SafeArea(
          child: Column(children: [
            const PageHeader('Itinerary Cuti'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: C.navy, borderRadius: BorderRadius.circular(16)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Cuti Roster · CT-2026-09-0214', style: ts(12, c: C.pale, h: 1.35)),
                      Text('5 – 11 Oktober 2026', style: ts(22, w: FontWeight.w800, c: Colors.white, h: 1.35)),
                      Text('7 hari · Kendari ⇄ Makassar', style: ts(13, c: const Color(0xFFDCE7FB), h: 1.35)),
                      const Gap(14),
                      IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [_rd('Cuti disetujui'), const Gap(0, w: 6), _rd('Lumpsum ditransfer'), const Gap(0, w: 6), _rd('Tiket terbit'), const Gap(0, w: 6), _rd('Jemputan terjadwal')])),
                      const Gap(14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 10),
                        decoration: const BoxDecoration(border: Border(top: BorderSide(color: C.navy2))),
                        child: Text('Kembali kerja: Sen, 12 Okt · Night shift 19:00', style: ts(12, c: C.pale)),
                      ),
                    ]),
                  ),
                  _day('SEBELUM BERANGKAT'),
                  _ev(time: '1 Okt', dot: C.green, box: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_b('Cuti disetujui'), _s('Rudi Hartono (IT Manager) · 1 Okt 09:12'), _s('HR Department · 1 Okt 14:30')])),
                  _ev(
                    time: '2 Okt',
                    dot: C.green,
                    box: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_b('Lumpsum cuti ditransfer'), _s('Diajukan oleh HR · LS-​2026-​09-​0142')])),
                        const Gap(0, w: 8),
                        const Pill('Ditransfer', tone: Tone.ok),
                      ]),
                      const Gap(8),
                      Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Flexible(child: Text('Rp 1.750.000', style: ts(22, w: FontWeight.w800))),
                        Text('BRI •••• 4521', style: ts(12, c: C.muted)),
                      ]),
                      if (ls) ...[
                        const Gap(8),
                        _lsr('Tunjangan cuti roster', 'Rp 1.250.000'),
                        _lsr('Uang makan perjalanan (2 × Rp 150.000)', 'Rp 300.000'),
                        _lsr('Transport lokal kota tujuan', 'Rp 200.000'),
                        const Gap(10),
                        _dotRow('Diajukan HR (Siti Rahmawati) · 28 Sep'),
                        const Gap(6),
                        _dotRow('Disetujui Finance · 30 Sep'),
                        const Gap(6),
                        _dotRow('Ditransfer ke BRI •••• 4521 a.n. Eddy Adha Saputra · 2 Okt 10:15'),
                      ],
                      const Gap(6),
                      InkWell(onTap: () => setState(() => ls = !ls), child: SizedBox(height: 40, child: Align(alignment: Alignment.centerLeft, child: Text(ls ? 'Sembunyikan rincian' : 'Lihat rincian lumpsum', style: ts(13, w: FontWeight.w700, c: C.blue))))),
                    ]),
                  ),
                  _day('SENIN, 5 OKT · BERANGKAT'),
                  _ev(
                    time: '05:30',
                    dot: C.blue,
                    route: R.perjalanan,
                    box: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _b('Jemputan ke bandara'),
                      _s('Lobby Mess Blok C → Bandara KDI'),
                      const Gap(8),
                      Wrap(spacing: 6, runSpacing: 6, children: [_chip('BUS-07', C.blueSoft, C.blueFg), _chip('Kursi 14', C.blueSoft, C.blueFg), _chip('Rahmat Hidayat', const Color(0xFFEEF1F5), C.text2, bold: false)]),
                    ]),
                  ),
                  _ev(
                    time: '09:40',
                    dot: C.blue,
                    route: R.perjalanan,
                    box: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _b('Penerbangan KDI → UPG'),
                      _s('XX 1234 · tiba 10:55 · booking K7P2QD'),
                      const Gap(8),
                      Wrap(spacing: 6, runSpacing: 6, children: [_chip('Kursi 12A', C.purpleBg, C.purple), _chip('Bagasi 20 kg', const Color(0xFFEEF1F5), C.text2, bold: false)]),
                    ]),
                  ),
                  _day('5 – 10 OKT · MASA OFF'),
                  _ev(time: '', dot: const Color(0xFFC4CDD9), dashed: true, box: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_b('Istirahat di Makassar'), _s('Hubungi HR bila ada perubahan jadwal kembali.')])),
                  _day('MINGGU, 11 OKT · KEMBALI'),
                  _ev(
                    time: '07:10',
                    dot: C.blue,
                    route: R.perjalanan,
                    box: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _b('Penerbangan UPG → KDI'),
                      _s('XX 1231 · tiba 08:25 · booking M3RX8T'),
                      const Gap(8),
                      Wrap(spacing: 6, runSpacing: 6, children: [_chip('Kursi 8C', C.purpleBg, C.purple)]),
                    ]),
                  ),
                  _ev(
                    time: '08:45',
                    dot: C.blue,
                    route: R.perjalanan,
                    box: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _b('Jemputan ke site'),
                      _s('Bandara KDI (kedatangan) → Mess Blok C'),
                      const Gap(8),
                      Wrap(spacing: 6, runSpacing: 6, children: [_chip('BUS-03', C.blueSoft, C.blueFg), _chip('Kursi 6', C.blueSoft, C.blueFg), _chip('Yusuf Rahman', const Color(0xFFEEF1F5), C.text2, bold: false)]),
                    ]),
                  ),
                  _day('SENIN, 12 OKT · MASUK KERJA'),
                  _ev(time: '18:00', dot: C.orange, route: R.ftw, box: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_b('Isi Fit To Work'), _s('Wajib sebelum shift dimulai')])),
                  _ev(time: '19:00', dot: C.navy, line: false, route: R.roster, box: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_b('Night shift dimulai'), _s('12 – 25 Okt · 19:00 – 07:00')])),
                ]),
              ),
            ),
          ]),
        ),
      );
}
