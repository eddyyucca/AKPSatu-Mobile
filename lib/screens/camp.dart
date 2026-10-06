import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

class CampScreen extends StatelessWidget {
  const CampScreen({super.key});

  Widget _row(String k, String v, {bool first = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(border: first ? null : const Border(top: BorderSide(color: Color(0xFFEEF1F5)))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(k, style: ts(14, c: C.muted)),
          const Gap(0, w: 16),
          Flexible(child: Text(v, textAlign: TextAlign.right, style: ts(14, w: FontWeight.w600))),
        ]),
      );

  Widget _chip(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: const Color(0xFFEEF1F5), borderRadius: BorderRadius.circular(99)),
        child: Text(t, style: ts(12, w: FontWeight.w600, c: C.text2)),
      );

  Widget _darkChip(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: C.navy2, borderRadius: BorderRadius.circular(99)),
        child: Text(t, style: ts(12, w: FontWeight.w600, c: const Color(0xFFDCE7FB))),
      );

  Widget _tile(String l, String v) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(color: C.bg, borderRadius: BorderRadius.circular(10)),
          child: Column(children: [
            Text(l, style: ts(11, c: C.muted, h: 1.3)),
            Text(v, style: ts(15, w: FontWeight.w800, h: 1.3)),
          ]),
        ),
      );

  Widget _fac(String ic, Color bg, Color fg, String t, String s, {bool first = false, double sw = 1.8}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(border: first ? null : const Border(top: BorderSide(color: Color(0xFFEEF1F5)))),
        child: Row(children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)), child: Center(child: Ic(ic, size: 18, color: fg, stroke: sw))),
          const Gap(0, w: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t, style: ts(14, w: FontWeight.w700, h: 1.4)),
              Text(s, style: ts(12, c: C.muted, h: 1.4)),
            ]),
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: C.bg,
        body: SafeArea(
          child: Column(children: [
            const PageHeader('Camp Facility'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    decoration: BoxDecoration(color: C.navy, borderRadius: BorderRadius.circular(16)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Container(width: 44, height: 44, decoration: BoxDecoration(color: C.navy2, borderRadius: BorderRadius.circular(12)), child: const Center(child: Ic('camp', size: 24, color: Color(0xFF5B95F5)))),
                        const Gap(0, w: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Mess saya', style: ts(13, c: C.pale, h: 1.35)),
                          Text('Blok C · Kamar C-214', style: ts(20, w: FontWeight.w800, c: Colors.white, h: 1.35)),
                        ])),
                      ]),
                      const Gap(12),
                      Wrap(spacing: 8, runSpacing: 8, children: [_darkChip('Tipe Supervisor'), _darkChip('2 penghuni'), _darkChip('Lantai 2')]),
                    ]),
                  ),
                  const Gap(14),
                  Card14(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      _row('Teman sekamar', 'Hendra Wijaya', first: true),
                      _row('Menempati sejak', '21 Sep 2026'),
                      _row('Jadwal laundry', 'Senin & Kamis'),
                      _row('Ambil laundry', '17:00 · Pos Laundry C'),
                      Padding(padding: const EdgeInsets.fromLTRB(0, 6, 0, 8), child: Text('Fasilitas kamar', style: ts(13, c: C.muted))),
                      Wrap(spacing: 6, runSpacing: 6, children: [_chip('AC'), _chip('Wi-Fi'), _chip('Kamar mandi dalam'), _chip('Lemari'), _chip('Air panas')]),
                    ]),
                  ),
                  const Gap(14),
                  Card14(
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Pengelola Mess Blok C', style: ts(12, c: C.muted, h: 1.45)),
                          Text('Pos Mess C · 24 jam', style: ts(14, w: FontWeight.w700, h: 1.45)),
                          Text('0811 •••• 4402', style: ts(13, c: C.muted, h: 1.45)),
                        ]),
                      ),
                      const Gap(0, w: 12),
                      Semantics(
                        button: true,
                        label: 'Telepon pengelola mess',
                        child: Material(
                          color: C.greenBg,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => toast(context, 'Menelepon pengelola mess (demo)'), child: const SizedBox(width: 44, height: 44, child: Center(child: Ic('phone', color: C.greenFg)))),
                        ),
                      ),
                    ]),
                  ),
                  const Gap(14),
                  Material(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: C.input)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => sheet(
                        context,
                        (ctx) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Lapor Kerusakan Kamar', style: ts(18, w: FontWeight.w800)),
                          const Gap(14),
                          const TextBox('Kerusakan', lines: 3, hint: 'Contoh: AC tidak dingin'),
                          PrimaryButton('Kirim Laporan', onTap: () {
                            Navigator.pop(ctx);
                            toast(context, 'Laporan terkirim ke pengelola mess');
                          }),
                        ]),
                      ),
                      child: SizedBox(
                        height: 48,
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Ic('wrench', size: 18),
                          const Gap(0, w: 8),
                          Text('Lapor Kerusakan Kamar', style: ts(15, w: FontWeight.w700)),
                        ]),
                      ),
                    ),
                  ),
                  const Gap(14),
                  Padding(padding: const EdgeInsets.fromLTRB(4, 6, 4, 0), child: Text('Perjalanan cuti', style: ts(15, w: FontWeight.w800))),
                  const Gap(14),
                  Card14(
                    onTap: () => Navigator.pushNamed(context, R.itinerary),
                    child: Column(children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Flexible(child: Text('Off roster 5 – 11 Okt 2026', style: ts(14, w: FontWeight.w700))),
                        const Pill('Terkonfirmasi', tone: Tone.ok),
                      ]),
                      const Gap(10),
                      Row(children: [_tile('Jemput', '05:30'), const Gap(0, w: 8), _tile('Unit', 'BUS-07'), const Gap(0, w: 8), _tile('Kursi', '14')]),
                      const Gap(10),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Flexible(child: Text('Pesawat KDI → UPG · 09:40', style: ts(13, c: C.muted))),
                        Text('Lihat itinerary', style: ts(13, w: FontWeight.w700, c: C.blue)),
                      ]),
                    ]),
                  ),
                  const Gap(14),
                  Padding(padding: const EdgeInsets.fromLTRB(4, 6, 4, 0), child: Text('Fasilitas camp', style: ts(15, w: FontWeight.w800))),
                  const Gap(14),
                  Card14(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Column(children: [
                      _fac('food', C.blueSoft, C.blue, 'Kantin', '05:30 – 20:30 · Gedung Serbaguna', first: true),
                      _fac('plus', C.redBg, C.red, 'Klinik', '24 jam · samping Pos Security', sw: 2),
                      _fac('dumbbell', C.greenBg, C.greenFg, 'Fitness center', '05:00 – 22:00'),
                      _fac('bag', C.orangeBg, C.orange, 'Minimarket', '07:00 – 21:00'),
                    ]),
                  ),
                ]),
              ),
            ),
          ]),
        ),
      );
}
