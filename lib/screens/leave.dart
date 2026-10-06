import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

class LeaveScreen extends StatelessWidget {
  const LeaveScreen({super.key});

  Widget _card(Widget child, {EdgeInsets padding = const EdgeInsets.all(16)}) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
        child: child,
      );

  Widget _st(String v, String l, {Color vc = C.text, bool borders = false}) => Expanded(
        child: Container(
          decoration: BoxDecoration(border: borders ? const Border(left: BorderSide(color: Color(0xFFEEF1F5)), right: BorderSide(color: Color(0xFFEEF1F5))) : null),
          child: Column(children: [
            Text(v, style: ts(18, w: FontWeight.w800, c: vc, h: 1.3)),
            Text(l, style: ts(12, c: C.muted, h: 20.8 / 12)),
          ]),
        ),
      );

  Widget _hist(String title, String sub, String meta, String pill, Tone tone) => Padding(
        padding: const EdgeInsets.only(top: 14),
        child: _card(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: ts(15, w: FontWeight.w700, h: 1.45)),
              Text(sub, style: ts(13, c: C.text2, h: 1.45)),
              Text(meta, style: ts(12, c: C.muted, h: 1.45)),
            ]),
          ),
          const Gap(0, w: 12),
          Pill(pill, tone: tone),
        ])),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: C.bg,
        body: SafeArea(
          child: Column(children: [
            const PageHeader('Cuti Tahunan'),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: C.navy, borderRadius: BorderRadius.circular(16)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Sisa cuti tahunan 2026', style: ts(13, c: C.pale)),
                      const Gap(14),
                      Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                        Text('9', style: ts(44, w: FontWeight.w800, c: Colors.white, h: 1)),
                        const Gap(0, w: 8),
                        Text('dari 12 hari', style: ts(16, c: const Color(0xFFDCE7FB))),
                      ]),
                      const Gap(14),
                      Semantics(
                        label: 'Terpakai 3 dari 12 hari',
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(color: C.navy2, borderRadius: BorderRadius.circular(4)),
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(widthFactor: .25, child: Container(height: 8, decoration: BoxDecoration(color: const Color(0xFF5B95F5), borderRadius: BorderRadius.circular(4)))),
                        ),
                      ),
                      const Gap(14),
                      Text('Berlaku sampai 31 Des 2026', style: ts(12, c: C.pale)),
                    ]),
                  ),
                  const Gap(14),
                  _card(
                    IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [_st('12', 'Hak cuti'), _st('3', 'Terpakai', borders: true), _st('3', 'Menunggu', vc: C.orangeFg)])),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                  ),
                  const Gap(14),
                  Material(
                    color: C.blue,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.pushNamed(context, R.pengajuanCuti),
                      child: SizedBox(
                        height: 52,
                        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Ic('plus', size: 20, stroke: 2, color: Colors.white),
                          const Gap(0, w: 8),
                          Text('Ajukan Cuti', style: ts(16, w: FontWeight.w700, c: Colors.white)),
                        ]),
                      ),
                    ),
                  ),
                  const Gap(14),
                  Padding(padding: const EdgeInsets.fromLTRB(4, 6, 4, 0), child: Text('Riwayat pengajuan', style: ts(15, w: FontWeight.w800))),
                  _hist('19 – 21 Okt 2026', '3 hari · Keperluan keluarga', 'Diajukan 01 Okt 2026 · menunggu atasan', 'Pending', Tone.warn),
                  _hist('10 – 11 Agu 2026', '2 hari · Urusan pribadi', 'Bentrok dengan jadwal shutdown', 'Ditolak', Tone.bad),
                  _hist('02 – 04 Jun 2026', '3 hari · Liburan keluarga', 'Disetujui 25 Mei 2026', 'Disetujui', Tone.ok),
                ]),
              ),
            ),
          ]),
        ),
      );
}
