import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class FtwScreen extends StatefulWidget {
  const FtwScreen({super.key});
  @override
  State<FtwScreen> createState() => _FtwScreenState();
}

class _FtwScreenState extends State<FtwScreen> {
  final ans = <String, String>{};
  bool done = false;

  static const defs = [
    ('tidur', 'Berapa jam Anda tidur dalam 24 jam terakhir?', ['< 4 jam', '4 – 6 jam', '> 6 jam'], 'Jam tidur'),
    ('kondisi', 'Bagaimana kondisi badan Anda saat ini?', ['Sehat', 'Kurang fit', 'Sakit'], 'Kondisi badan'),
    ('obat', 'Apakah Anda minum obat yang menyebabkan kantuk?', ['Ya', 'Tidak'], 'Obat penyebab kantuk'),
    ('alkohol', 'Apakah Anda minum alkohol dalam 24 jam terakhir?', ['Ya', 'Tidak'], 'Alkohol'),
  ];

  String get level {
    if (ans['tidur'] == '< 4 jam' || ans['kondisi'] == 'Sakit' || ans['alkohol'] == 'Ya') return 'unfit';
    if (ans['kondisi'] == 'Kurang fit' || ans['obat'] == 'Ya' || ans['tidur'] == '4 – 6 jam') return 'check';
    return 'fit';
  }

  Widget _card(Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
        child: child,
      );

  Widget _opt(String label, bool on, VoidCallback tap) => Expanded(
        child: Material(
          color: on ? C.blueSoft : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(color: on ? C.blue : C.input, width: on ? 2 : 1)),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: tap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Center(child: Text(label, textAlign: TextAlign.center, style: ts(14, w: on ? FontWeight.w700 : FontWeight.w600, c: on ? C.blueFg : C.text2))),
              ),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final ready = defs.every((q) => ans.containsKey(q.$1));
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(children: [
          const PageHeader('Fit To Work'),
          Expanded(child: done ? _result() : _form(ready)),
        ]),
      ),
    );
  }

  Widget _form(bool ready) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Sabtu, 3 Oktober 2026', style: ts(13, c: C.muted, h: 1.45)),
          Text('Day shift · 07:00 – 19:00', style: ts(15, w: FontWeight.w700, h: 1.45)),
          for (var i = 0; i < defs.length; i++) ...[
            const Gap(14),
            _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${i + 1}. ${defs[i].$2}', style: ts(15, w: FontWeight.w700, h: 1.4)),
              const Gap(10),
              Row(children: [
                for (var k = 0; k < defs[i].$3.length; k++) ...[
                  if (k > 0) const Gap(0, w: 8),
                  _opt(defs[i].$3[k], ans[defs[i].$1] == defs[i].$3[k], () => setState(() => ans[defs[i].$1] = defs[i].$3[k])),
                ],
              ]),
            ])),
          ],
          const Gap(14),
          _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('5. Keluhan lain (opsional)', style: ts(15, w: FontWeight.w700)),
            const Gap(8),
            TextField(
              minLines: 2,
              maxLines: 2,
              style: ts(15),
              decoration: InputDecoration(
                hintText: 'Contoh: pusing, nyeri punggung',
                hintStyle: ts(15, c: const Color(0xFF757575)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: C.input)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: C.input)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: C.blue, width: 2)),
              ),
            ),
          ])),
          const Gap(14),
          PrimaryButton(ready ? 'Kirim Fit To Work' : 'Jawab semua pertanyaan', height: 54, onTap: ready ? () => setState(() => done = true) : null),
          const Gap(14),
          _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('7 hari terakhir', style: ts(14, w: FontWeight.w800)),
            const Gap(12),
            Row(children: [
              for (final d in const ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum'])
                Expanded(
                  child: Column(children: [
                    Container(width: 32, height: 32, decoration: const BoxDecoration(color: C.greenBg, shape: BoxShape.circle), child: const Center(child: Ic('check', size: 16, stroke: 2.4, color: C.greenFg))),
                    const Gap(4),
                    Text(d, style: ts(11, c: C.muted)),
                  ]),
                ),
              Expanded(
                child: Column(children: [
                  Container(width: 32, height: 32, alignment: Alignment.center, decoration: const BoxDecoration(color: C.orangeBg, shape: BoxShape.circle), child: Text('?', style: ts(14, w: FontWeight.w800, c: C.orangeFg))),
                  const Gap(4),
                  Text('Hari ini', style: ts(11, c: C.muted)),
                ]),
              ),
            ]),
          ])),
        ]),
      );

  Widget _result() {
    final (t, c, bg, p, x) = switch (level) {
      'unfit' => ('TIDAK FIT', C.red, C.redBg, 'M6 6l12 12M18 6L6 18', 'Anda belum boleh bekerja. Segera laporkan ke atasan dan petugas medis.'),
      'check' => ('PERLU PEMERIKSAAN', C.orangeFg, C.orangeBg, 'M12 7v6M12 17h.01', 'Silakan temui petugas medis di klinik sebelum memulai shift. Atasan Anda sudah diberi tahu.'),
      _ => ('FIT', C.greenFg, C.greenBg, 'M5 12l4.5 4.5L19 7', 'Anda dinyatakan fit untuk bekerja hari ini. Selamat bekerja dan utamakan keselamatan.'),
    };
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(children: [
        Container(width: 88, height: 88, decoration: BoxDecoration(color: bg, shape: BoxShape.circle), child: Center(child: Ic.path(p, size: 44, stroke: 2.2, color: c))),
        const Gap(14),
        Text(t, style: ts(26, w: FontWeight.w800, c: c)),
        const Gap(14),
        ConstrainedBox(constraints: const BoxConstraints(maxWidth: 300), child: Text(x, textAlign: TextAlign.center, style: ts(15, c: C.text2, h: 1.55))),
        const Gap(14),
        _card(Column(children: [
          for (final q in defs)
            Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(q.$4, style: ts(14, c: C.muted)), Text(ans[q.$1] ?? '-', style: ts(14, w: FontWeight.w700))])),
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFEEF1F5)))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Waktu kirim', style: ts(14, c: C.muted)), Text('06:40', style: ts(14, w: FontWeight.w700))]),
          ),
        ])),
        const Gap(22),
        PrimaryButton('Kembali ke Beranda', onTap: () => Navigator.pop(context)),
        const Gap(14),
        InkWell(onTap: () => setState(() { done = false; ans.clear(); }), child: SizedBox(height: 44, child: Center(child: Text('Isi ulang (demo)', style: ts(14, w: FontWeight.w700, c: C.blue))))),
      ]),
    );
  }
}
