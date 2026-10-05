import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class P2hScreen extends StatefulWidget {
  const P2hScreen({super.key});
  @override
  State<P2hScreen> createState() => _P2hScreenState();
}

class _P2hScreenState extends State<P2hScreen> {
  String stage = 'pick'; // pick | form | result
  bool scanning = false;
  String fuel = 'Penuh';
  final ans = <String, bool>{}; // true baik

  static const groups = <(String, List<(String, String, bool)>)>[
    ('DOKUMEN', [('doc1', 'STNK & kartu izin masuk tambang', false), ('doc2', 'SIMPER pengemudi berlaku', true)]),
    ('EKSTERIOR', [('ext1', 'Ban & tekanan angin', true), ('ext2', 'Lampu utama, sein, rem', true), ('ext3', 'Kaca & wiper', false), ('ext4', 'Bendera & lampu rotary', true)]),
    ('MESIN', [('eng1', 'Oli mesin', false), ('eng2', 'Air radiator', false), ('eng3', 'Tidak ada kebocoran oli / air', false)]),
    ('KESELAMATAN', [('saf1', 'Rem & rem tangan', true), ('saf2', 'Sabuk pengaman', true), ('saf3', 'APAR terisi & tidak kedaluwarsa', true), ('saf4', 'Klakson & alarm mundur', true), ('saf5', 'Kotak P3K', false), ('saf6', 'Radio komunikasi berfungsi', false)]),
  ];

  List<(String, String, bool)> get all => [for (final g in groups) ...g.$2];
  int get total => all.length;
  int get bad => all.where((i) => ans[i.$1] == false).length;
  int get badCritical => all.where((i) => ans[i.$1] == false && i.$3).length;

  @override
  Widget build(BuildContext context) {
    if (stage == 'pick') return _pick();
    if (stage == 'result') return _result();
    return _form();
  }

  Widget _pick() => SubPage(
        title: 'P2H Online',
        subtitle: 'Pemeriksaan harian kendaraan LV',
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(color: scanning ? const Color(0xFF1B2433) : C.chip, borderRadius: BorderRadius.circular(14)),
                child: scanning
                    ? Stack(alignment: Alignment.center, children: [
                        const Positioned(top: 14, child: Text('AKP-LV-12', style: TextStyle(color: Colors.white54, fontSize: 12))),
                        Container(width: 150, height: 150, decoration: BoxDecoration(border: Border.all(color: const Color(0xFF6FA0F5), width: 3), borderRadius: BorderRadius.circular(14))),
                        Container(width: 150, height: 2, color: C.red),
                        const Positioned(bottom: 12, child: Text('Arahkan kamera ke barcode di unit', style: TextStyle(color: Colors.white70, fontSize: 12))),
                      ])
                    : const Icon(Icons.qr_code_scanner, size: 72, color: C.muted),
              ),
              const Gap(14),
              Text('Scan barcode unit', style: ts(17, w: FontWeight.w800)),
              const Gap(4),
              Text('Arahkan kamera ke stiker barcode / QR yang terpasang di setiap unit LV (dashboard atau pintu pengemudi).', textAlign: TextAlign.center, style: ts(13, c: C.muted, h: 1.5)),
              const Gap(14),
              if (!scanning)
                PrimaryButton('Buka Kamera', icon: Icons.photo_camera_outlined, onTap: () => setState(() => scanning = true))
              else
                PrimaryButton('Simulasi: barcode terbaca', color: C.green, icon: Icons.check, onTap: () => setState(() { scanning = false; stage = 'form'; })),
              TextButton(
                onPressed: () => sheet(context, (ctx) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Masukkan kode unit manual', style: ts(18, w: FontWeight.w800)),
                      const Gap(14),
                      const TextBox('Kode unit', initial: 'AKP-LV-12'),
                      PrimaryButton('Lanjut', onTap: () { Navigator.pop(ctx); setState(() => stage = 'form'); }),
                    ])),
                child: Text('Masukkan kode unit manual', style: ts(13, w: FontWeight.w600, c: C.blue)),
              ),
            ]),
          ),
          const SectionLabel('P2H TERAKHIR SAYA'),
          AppCard(child: Row(children: [
            const IconBox(Icons.local_shipping_outlined, C.orangeBg, C.orangeFg, size: 42),
            const Gap(0, w: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('LV-12 · 3 Okt 06:38', style: ts(14, w: FontWeight.w700)), Text('Double cabin 4x4 · DT 8123 KC', style: ts(12, c: C.muted))])),
            const Pill('Layak', tone: Tone.ok),
          ])),
        ]),
      );

  Widget _form() {
    final answered = ans.length;
    final ready = answered == total;
    return SubPage(
      title: 'P2H Online',
      bottom: PrimaryButton(ready ? 'Kirim P2H' : 'Periksa semua item ($answered/$total)', onTap: ready ? () => setState(() => stage = 'result') : null),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AppCard(child: Row(children: [
          const IconBox(Icons.verified_outlined, C.greenBg, C.greenFg, size: 42),
          const Gap(0, w: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('LV-12', style: ts(16, w: FontWeight.w800)),
            Text('Terverifikasi scan · Double cabin 4x4 · DT 8123 KC', style: ts(12, c: C.muted)),
          ])),
          TextButton(onPressed: () => setState(() { stage = 'pick'; ans.clear(); }), child: const Text('Scan ulang')),
        ])),
        const Gap(10),
        AppCard(child: Row(children: [
          const Avatar('BS'),
          const Gap(0, w: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Pengemudi (akun Anda)', style: ts(11, c: C.muted)),
            Text('Budi Santoso · AKP001', style: ts(14, w: FontWeight.w700)),
            Text('SIMPER LV berlaku s/d Mar 2027', style: ts(12, c: C.muted)),
          ])),
        ])),
        const Gap(10),
        const SummaryBox([('Tanggal', '4 Okt 2026 · 06:35'), ('Shift', 'Day')]),
        const Gap(12),
        const TextBox('Odometer (km)', initial: '48.210', type: TextInputType.number),
        LabeledField('Level BBM', ChoiceRow(options: const ['Penuh', '3/4', '1/2', '1/4', 'Hampir habis'], selected: fuel, wrap: true, onSelect: (v) => setState(() => fuel = v))),
        const Gap(4),
        Row(children: [
          Expanded(child: Text('Checklist dari web · versi Sep 2026', style: ts(12, c: C.muted))),
          Text('$answered / $total diperiksa', style: ts(12, w: FontWeight.w700)),
        ]),
        const Gap(8),
        for (final g in groups) ...[
          SectionLabel(g.$1),
          for (final it in g.$2)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(it.$2, style: ts(14, w: FontWeight.w600))),
                    if (it.$3) const Pill('KRITIS', tone: Tone.bad),
                  ]),
                  const Gap(8),
                  Row(children: [
                    Expanded(child: _ans('Baik', ans[it.$1] == true, C.green, () => setState(() => ans[it.$1] = true))),
                    const Gap(0, w: 8),
                    Expanded(child: _ans('Rusak', ans[it.$1] == false, C.red, () => setState(() => ans[it.$1] = false))),
                  ]),
                ]),
              ),
            ),
        ],
        const Gap(8),
        if (ans.length == total)
          Notice(
            badCritical > 0 ? 'Ada $badCritical item kritis rusak. Unit TIDAK LAYAK dioperasikan.' : bad > 0 ? 'Ada $bad item rusak (non-kritis). Unit layak dengan catatan.' : 'Semua item baik. Unit layak dioperasikan.',
            tone: badCritical > 0 ? Tone.bad : bad > 0 ? Tone.warn : Tone.ok,
            icon: badCritical > 0 ? Icons.block : Icons.check_circle_outline,
          ),
      ]),
    );
  }

  Widget _result() {
    final (icon, color, title, text) = badCritical > 0
        ? (Icons.cancel, C.red, 'Unit tidak layak', 'Ada item kritis yang rusak. Jangan operasikan unit dan laporkan ke Workshop.')
        : bad > 0
            ? (Icons.warning_amber_rounded, C.orange, 'Layak dengan catatan', 'Temuan sudah diteruskan ke Workshop untuk perbaikan.')
            : (Icons.check_circle, C.green, 'Unit layak dioperasikan', 'P2H tercatat. Selamat bekerja dan tetap utamakan keselamatan.');
    return SubPage(
      title: 'P2H Online',
      body: ResultView(icon: icon, color: color, title: title, text: text, children: [
        SummaryBox([('No. P2H', 'P2H-LV12-20261004-D'), ('Unit', 'LV-12 · DT 8123 KC'), ('Pengemudi', 'Budi Santoso'), ('Temuan rusak', '$bad')]),
        const Gap(16),
        PrimaryButton('Kembali ke Beranda', onTap: () => Navigator.pop(context)),
        TextButton(onPressed: () => setState(() { stage = 'pick'; ans.clear(); }), child: Text('P2H unit lain (demo)', style: ts(13, c: C.muted))),
      ]),
    );
  }

  Widget _ans(String label, bool on, Color c, VoidCallback tap) => SizedBox(
        height: 44,
        child: OutlinedButton(
          onPressed: tap,
          style: OutlinedButton.styleFrom(
            backgroundColor: on ? c.withValues(alpha: .12) : Colors.white,
            side: BorderSide(color: on ? c : C.input, width: on ? 2 : 1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(label, style: ts(14, w: FontWeight.w700, c: on ? c : C.text2)),
        ),
      );
}
