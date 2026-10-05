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
  bool sent = false;

  static const qs = [
    ('tidur', 'Berapa jam Anda tidur dalam 24 jam terakhir?', ['< 4 jam', '4 – 6 jam', '> 6 jam'], 'Jam tidur'),
    ('kondisi', 'Bagaimana kondisi badan Anda saat ini?', ['Sehat', 'Kurang fit', 'Sakit'], 'Kondisi badan'),
    ('obat', 'Apakah Anda minum obat yang menyebabkan kantuk?', ['Ya', 'Tidak'], 'Obat penyebab kantuk'),
    ('alkohol', 'Apakah Anda minum alkohol dalam 24 jam terakhir?', ['Ya', 'Tidak'], 'Alkohol'),
  ];

  String get level {
    if (ans['tidur'] == '< 4 jam' || ans['kondisi'] == 'Sakit' || ans['alkohol'] == 'Ya') return 'unfit';
    if (ans['kondisi'] == 'Kurang fit' || ans['tidur'] == '4 – 6 jam' || ans['obat'] == 'Ya') return 'caution';
    return 'fit';
  }

  @override
  Widget build(BuildContext context) {
    final ready = qs.every((q) => ans.containsKey(q.$1));
    if (sent) {
      final (icon, color, title, text) = switch (level) {
        'unfit' => (Icons.cancel, C.red, 'Belum layak bekerja', 'Jawaban Anda menunjukkan kondisi tidak fit. Hubungi atasan dan klinik sebelum memulai shift.'),
        'caution' => (Icons.warning_amber_rounded, C.orange, 'Fit dengan catatan', 'Atasan akan mendapat notifikasi. Tetap waspada dan laporkan bila kondisi memburuk.'),
        _ => (Icons.check_circle, C.green, 'Anda fit untuk bekerja', 'Terima kasih sudah mengisi. Selamat bekerja dan tetap utamakan keselamatan.'),
      };
      return SubPage(
        title: 'Fit To Work',
        body: ResultView(icon: icon, color: color, title: title, text: text, children: [
          SummaryBox([for (final q in qs) (q.$4, ans[q.$1] ?? '-'), ('Waktu kirim', '06:40')]),
          const Gap(16),
          PrimaryButton('Kembali ke Beranda', onTap: () => Navigator.pop(context)),
          TextButton(onPressed: () => setState(() { sent = false; ans.clear(); }), child: Text('Isi ulang (demo)', style: ts(13, c: C.muted))),
        ]),
      );
    }
    return SubPage(
      title: 'Pengisian Fit To Work',
      bottom: PrimaryButton(ready ? 'Kirim Fit To Work' : 'Jawab semua pertanyaan', onTap: ready ? () => setState(() => sent = true) : null),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Fit To Work', style: ts(22, w: FontWeight.w800)),
        Text('Sabtu, 3 Oktober 2026 · Day shift · 07:00 – 19:00', style: ts(13, c: C.muted)),
        const Gap(14),
        AppCard(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            for (final w in const [('Sab', 1), ('Min', 1), ('Sen', 1), ('Sel', 1), ('Rab', 1), ('Kam', 1), ('Hari ini', 0)])
              Expanded(
                child: Column(children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: w.$2 == 1 ? C.greenBg : C.chip, shape: BoxShape.circle),
                    child: Text(w.$2 == 1 ? '✓' : '?', style: ts(12, w: FontWeight.w800, c: w.$2 == 1 ? C.greenFg : C.muted)),
                  ),
                  const Gap(4),
                  Text(w.$1, style: ts(10, c: C.muted), textAlign: TextAlign.center),
                ]),
              ),
          ]),
        ),
        const Gap(4),
        Text('7 hari terakhir', style: ts(11, c: C.muted)),
        const Gap(14),
        for (var i = 0; i < qs.length; i++)
          LabeledField('${i + 1}. ${qs[i].$2}', ChoiceRow(options: qs[i].$3, selected: ans[qs[i].$1] ?? '', onSelect: (v) => setState(() => ans[qs[i].$1] = v))),
        const TextBox('5. Keluhan lain (opsional)', lines: 3, hint: 'Tuliskan bila ada'),
      ]),
    );
  }
}
