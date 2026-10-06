import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme.dart';
import '../widgets.dart';
import 'requests.dart';

const _barcodeSvg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 50" width="120" height="50"><path d="M4 2v46M9 2v46M12 2v46M18 2v46M22 2v46M27 2v46M33 2v46M36 2v46M41 2v46M47 2v46M50 2v46M56 2v46M61 2v46M64 2v46M70 2v46M75 2v46M78 2v46M84 2v46M89 2v46M93 2v46M98 2v46M103 2v46M106 2v46M112 2v46M116 2v46" stroke="#0B1520" stroke-width="2.2"/></svg>';

class P2hScreen extends StatefulWidget {
  const P2hScreen({super.key});
  @override
  State<P2hScreen> createState() => _P2hScreenState();
}

class _P2hScreenState extends State<P2hScreen> with SingleTickerProviderStateMixin {
  String stage = 'pick'; // pick | form | sent | scan
  String? unit;
  bool flash = false;
  late final AnimationController scan = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat(reverse: true);

  static const groups = <(String, List<(String, String, bool)>)>[
    ('DOKUMEN', [('doc1', 'STNK & kartu izin masuk tambang', false), ('doc2', 'SIMPER pengemudi berlaku', true)]),
    ('EKSTERIOR', [('ext1', 'Ban & tekanan angin', true), ('ext2', 'Lampu utama, sein, rem', true), ('ext3', 'Kaca & wiper', false), ('ext4', 'Bendera & lampu rotary', true)]),
    ('MESIN', [('eng1', 'Oli mesin', false), ('eng2', 'Air radiator', false), ('eng3', 'Tidak ada kebocoran oli / air', false)]),
    ('KESELAMATAN', [('saf1', 'Rem & rem tangan', true), ('saf2', 'Sabuk pengaman', true), ('saf3', 'APAR terisi & tidak kedaluwarsa', true), ('saf4', 'Klakson & alarm mundur', true), ('saf5', 'Kotak P3K', false), ('saf6', 'Radio komunikasi', true), ('saf7', 'Ganjal roda (wheel chock)', false)]),
  ];
  static const preset = {'doc1': 'ok', 'doc2': 'ok', 'ext1': 'ok', 'ext2': 'ok', 'ext3': 'ok', 'eng1': 'ok', 'eng2': 'ok', 'eng3': 'ok', 'saf1': 'ok', 'saf2': 'ok', 'saf3': 'ok', 'saf5': 'ok'};
  late Map<String, String> ans = {...preset};

  @override
  void dispose() {
    scan.dispose();
    super.dispose();
  }

  int get total => groups.fold(0, (a, g) => a + g.$2.length);
  int get badCount => ans.values.where((v) => v == 'bad').length;
  int get badCrit => [for (final g in groups) ...g.$2].where((i) => ans[i.$1] == 'bad' && i.$3).length;

  @override
  Widget build(BuildContext context) {
    final prev = unit != null ? 'form' : 'pick';
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Stack(children: [
          Column(children: [
            Container(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
              decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: C.line))),
              child: Row(children: [
                const BackBtn(label: 'Kembali ke beranda'),
                const Gap(0, w: 4),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('P2H Online', style: ts(18, w: FontWeight.w800, h: 1.3)),
                    Text('Pemeriksaan harian kendaraan LV', style: ts(12, c: C.muted, h: 1.3)),
                  ]),
                ),
              ]),
            ),
            Expanded(child: switch (stage) { 'pick' => _pick(), 'sent' => _sent(), _ => _form() }),
          ]),
          if (stage == 'scan') Positioned.fill(child: _scan(prev)),
        ]),
      ),
    );
  }

  Widget _pick() => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(children: [
          const Gap(24),
          Container(width: 96, height: 96, decoration: BoxDecoration(color: C.orangeBg, borderRadius: BorderRadius.circular(24)), child: const Center(child: Ic('scan', size: 48, stroke: 1.6, color: C.orangeFg))),
          const Gap(16),
          Text('Scan barcode unit', style: ts(20, w: FontWeight.w800)),
          const Gap(16),
          ConstrainedBox(constraints: const BoxConstraints(maxWidth: 290), child: Text('Arahkan kamera ke stiker barcode / QR yang terpasang di setiap unit LV (dashboard atau pintu pengemudi).', textAlign: TextAlign.center, style: ts(14, c: C.muted, h: 1.55))),
          const Gap(16),
          PrimaryButton('Buka Kamera', ic: 'camera', height: 54, onTap: () => setState(() => stage = 'scan')),
          const Gap(24),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('P2H TERAKHIR SAYA', style: ts(12, w: FontWeight.w800, c: C.muted)),
              const Gap(8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text.rich(TextSpan(children: [TextSpan(text: 'LV-12', style: ts(13, w: FontWeight.w700)), TextSpan(text: ' · 3 Okt 06:38', style: ts(13))])),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: C.greenBg, borderRadius: BorderRadius.circular(99)), child: Text('Layak', style: ts(13, w: FontWeight.w700, c: C.greenFg))),
                ]),
              ),
            ]),
          ),
        ]),
      );

  Widget _card(Widget child, {EdgeInsets pad = const EdgeInsets.all(14)}) => Container(
        width: double.infinity,
        padding: pad,
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
        child: child,
      );

  Widget _kv(String k, String v) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(k, style: ts(11, c: C.muted, h: 1.3)), Text(v, style: ts(14, w: FontWeight.w700, h: 1.3))]),
      );

  Widget _btn(String t, bool on, bool ok, VoidCallback tap) => Material(
        color: on ? (ok ? C.green : C.red) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9), side: on ? BorderSide.none : const BorderSide(color: C.input)),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: tap,
          child: Container(constraints: const BoxConstraints(minHeight: 40, minWidth: 62), padding: const EdgeInsets.symmetric(horizontal: 10), alignment: Alignment.center, child: Text(t, style: ts(13, w: FontWeight.w700, c: on ? Colors.white : C.text2))),
        ),
      );

  Widget _form() {
    final answered = ans.length;
    final ready = answered == total;
    final layak = badCrit == 0;
    final (vText, vBg, vFg) = !ready
        ? ('Lengkapi semua item untuk melihat hasil.', const Color(0xFFEEF1F5), const Color(0xFF3D4B5E))
        : layak
            ? (badCount > 0 ? ('Layak digunakan dengan catatan: $badCount temuan non-kritis dilaporkan ke workshop.', C.orangeBg, const Color(0xFF6B3A08)) : ('Semua item baik. Kendaraan layak digunakan.', C.greenBg, const Color(0xFF14532D)))
            : ('Ada $badCrit temuan KRITIS. Kendaraan TIDAK LAYAK digunakan.', C.redBg, const Color(0xFF7A1A12));
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _card(Column(children: [
          Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: C.orangeBg, borderRadius: BorderRadius.circular(12)), child: const Center(child: Ic('truck', size: 26, color: C.orangeFg))),
            const Gap(0, w: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Wrap(crossAxisAlignment: WrapCrossAlignment.center, runSpacing: 4,children: [
                  Text('LV-12', style: ts(18, w: FontWeight.w800, h: 1.35)),
                  const Gap(0, w: 6),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: C.greenBg, borderRadius: BorderRadius.circular(6)), child: Text('Terverifikasi scan', style: ts(11, w: FontWeight.w700, c: C.greenFg))),
                ]),
                Text('Double cabin 4x4 · DT 8123 KC', style: ts(13, c: C.muted, h: 1.35)),
              ]),
            ),
            Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: C.input)),
              child: InkWell(borderRadius: BorderRadius.circular(10), onTap: () => setState(() => stage = 'scan'), child: Container(constraints: const BoxConstraints(minHeight: 40), padding: const EdgeInsets.symmetric(horizontal: 10), alignment: Alignment.center, child: Text('Scan ulang', style: ts(12, w: FontWeight.w700)))),
            ),
          ]),
          const Gap(12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: C.bg, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Container(width: 36, height: 36, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFDCE7FB), shape: BoxShape.circle), child: Text('EA', style: ts(13, w: FontWeight.w800, c: C.blueFg))),
              const Gap(0, w: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Pengemudi (akun Anda)', style: ts(11, c: C.muted, h: 1.35)),
                  Text('Eddy Adha Saputra · 32601949', style: ts(14, w: FontWeight.w700, h: 1.35)),
                  Text('SIMPER LV berlaku s/d Mar 2027', style: ts(11, w: FontWeight.w600, c: C.greenFg, h: 1.35)),
                ]),
              ),
            ]),
          ),
          const Gap(12),
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: C.bg, borderRadius: BorderRadius.circular(10)), child: Row(children: [_kv('Tanggal', '4 Okt 2026 · 06:35'), const Gap(0, w: 8), _kv('Shift', 'Day')])),
          const Gap(12),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Fld44('Odometer (km)', const InpText(initial: '48.215', type: TextInputType.number, small: true))),
            const Gap(0, w: 10),
            Expanded(child: Fld44('Level BBM', _fuel())),
          ]),
        ])),
        const Gap(12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text('Checklist dari web · versi Sep 2026', style: ts(13, c: C.muted))),
          Text('$answered / $total diperiksa', style: ts(13, w: FontWeight.w800)),
        ]),
        const Gap(12),
        Semantics(
          label: 'Progres pemeriksaan',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(height: 6, color: C.line, alignment: Alignment.centerLeft, child: FractionallySizedBox(widthFactor: answered / total, child: Container(height: 6, color: C.blue))),
          ),
        ),
        for (final g in groups) ...[
          const Gap(12),
          Padding(padding: const EdgeInsets.fromLTRB(2, 4, 2, 0), child: Text(g.$1, style: ts(12, w: FontWeight.w800, c: C.muted).copyWith(letterSpacing: .4))),
          const Gap(6),
          _card(
            Column(children: [
              for (var i = 0; i < g.$2.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(border: i == 0 ? null : const Border(top: BorderSide(color: Color(0xFFEEF1F5)))),
                  child: Column(children: [
                    Row(children: [
                      Expanded(
                        child: Text.rich(TextSpan(children: [
                          TextSpan(text: '${g.$2[i].$2} ', style: ts(14, w: FontWeight.w600, h: 1.35)),
                          if (g.$2[i].$3) WidgetSpan(alignment: PlaceholderAlignment.middle, child: Container(margin: const EdgeInsets.only(left: 4), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: C.redBg, borderRadius: BorderRadius.circular(6)), child: Text('KRITIS', style: ts(10, w: FontWeight.w800, c: C.red)))),
                        ])),
                      ),
                      const Gap(0, w: 10),
                      _btn('Baik', ans[g.$2[i].$1] == 'ok', true, () => setState(() => ans[g.$2[i].$1] = 'ok')),
                      const Gap(0, w: 6),
                      _btn('Rusak', ans[g.$2[i].$1] == 'bad', false, () => setState(() => ans[g.$2[i].$1] = 'bad')),
                    ]),
                    if (ans[g.$2[i].$1] == 'bad') ...[
                      const Gap(6),
                      Row(children: [
                        Expanded(child: SizedBox(height: 40, child: InpText(hint: 'Keterangan kerusakan', small: true, height: 40, fontSize: 13))),
                        const Gap(0, w: 8),
                        Material(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: C.input)),
                          child: InkWell(borderRadius: BorderRadius.circular(10), onTap: () => toast(context, 'Tambah foto (demo)'), child: const SizedBox(width: 44, height: 40, child: Center(child: Ic('camera', size: 18, color: C.text2)))),
                        ),
                      ]),
                    ],
                  ]),
                ),
            ]),
            pad: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          ),
        ],
        const Gap(12),
        Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), decoration: BoxDecoration(color: vBg, borderRadius: BorderRadius.circular(12)), child: Text(vText, style: ts(13, w: FontWeight.w600, c: vFg, h: 1.5))),
        const Gap(12),
        PrimaryButton(ready ? 'Kirim P2H' : 'Kirim P2H (${total - answered} belum diperiksa)', height: 54, onTap: ready ? () => setState(() => stage = 'sent') : null),
      ]),
    );
  }

  String fuel = '3/4';
  Widget _fuel() => SelectInp<String>(value: fuel, height: 44, items: const ['Penuh', '3/4', '1/2', '1/4', 'Hampir habis'], onChanged: (v) => setState(() => fuel = v));

  Widget _sent() {
    final layak = badCrit == 0;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(children: [
        Container(width: 88, height: 88, decoration: BoxDecoration(color: layak ? C.greenBg : C.redBg, shape: BoxShape.circle), child: Center(child: Ic.path(layak ? 'M5 12l4.5 4.5L19 7' : 'M6 6l12 12M18 6L6 18', size: 44, stroke: 2.2, color: layak ? C.greenFg : C.red))),
        const Gap(14),
        Text(layak ? 'LAYAK' : 'TIDAK LAYAK', style: ts(26, w: FontWeight.w800, c: layak ? C.greenFg : C.red)),
        const Gap(14),
        ConstrainedBox(constraints: const BoxConstraints(maxWidth: 310), child: Text(layak ? 'LV-12 boleh digunakan hari ini oleh Eddy Adha Saputra. Hasil P2H tersimpan dan bisa dilihat pengawas di web.' : 'LV-12 ditandai tidak boleh digunakan. Supervisor dan workshop sudah menerima notifikasi untuk perbaikan.', textAlign: TextAlign.center, style: ts(15, c: C.text2, h: 1.55))),
        const Gap(14),
        _card(
          Column(children: [
            for (final r in [('No. P2H', 'P2H-LV12-20261004-D'), ('Unit', 'LV-12 · DT 8123 KC'), ('Pengemudi', 'Eddy Adha Saputra'), ('Temuan rusak', badCount == 0 ? 'Tidak ada' : '$badCount item')])
              Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(r.$1, style: ts(14, c: C.muted)), Text(r.$2, style: ts(14, w: FontWeight.w700))])),
          ]),
        ),
        const Gap(14),
        PrimaryButton('Kembali ke Beranda', onTap: () => Navigator.pop(context)),
        const Gap(14),
        InkWell(onTap: () => setState(() { stage = 'pick'; unit = null; ans = {...preset}; }), child: SizedBox(height: 44, child: Center(child: Text('P2H unit lain (demo)', style: ts(14, w: FontWeight.w700, c: C.blue))))),
      ]),
    );
  }

  Widget _corner(Alignment a) {
    final top = a.y < 0, left = a.x < 0;
    const b = BorderSide(color: Colors.white, width: 4);
    return Positioned(
      left: left ? 0 : null,
      right: left ? null : 0,
      top: top ? 0 : null,
      bottom: top ? null : 0,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          border: Border(left: left ? b : BorderSide.none, right: left ? BorderSide.none : b, top: top ? b : BorderSide.none, bottom: top ? BorderSide.none : b),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(top && left ? 12 : 0),
            topRight: Radius.circular(top && !left ? 12 : 0),
            bottomLeft: Radius.circular(!top && left ? 12 : 0),
            bottomRight: Radius.circular(!top && !left ? 12 : 0),
          ),
        ),
      ),
    );
  }

  Widget _cam(String label, Widget icon, VoidCallback tap) => Semantics(
        button: true,
        label: label,
        child: Material(color: const Color(0x26FFFFFF), shape: const CircleBorder(), child: InkWell(customBorder: const CircleBorder(), onTap: tap, child: SizedBox(width: 44, height: 44, child: Center(child: icon)))),
      );

  Widget _scan(String prev) => Container(
        color: const Color(0xFF0B1520),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              _cam('Tutup kamera', const Ic('close', size: 22, stroke: 2, color: Colors.white), () => setState(() => stage = prev)),
              Text('Scan barcode unit', style: ts(15, w: FontWeight.w700, c: Colors.white)),
              _cam('Senter', Ic('bolt', color: flash ? const Color(0xFFFDE68A) : Colors.white), () => setState(() => flash = !flash)),
            ]),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(gradient: RadialGradient(center: Alignment(0, -.1), radius: .75, colors: [Color(0xFF2A3B4D), Color(0xFF0B1520)])),
              child: Stack(alignment: Alignment.center, children: [
                SizedBox(
                  width: 250,
                  height: 250,
                  child: Stack(children: [
                    _corner(Alignment.topLeft),
                    _corner(Alignment.topRight),
                    _corner(Alignment.bottomLeft),
                    _corner(Alignment.bottomRight),
                    Positioned(
                      left: 50,
                      top: 70,
                      width: 150,
                      height: 110,
                      child: Opacity(
                        opacity: .9,
                        child: Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            SvgPicture.string(_barcodeSvg, width: 120, height: 50),
                            const Gap(6),
                            Text('AKP-LV-12', style: ts(11, w: FontWeight.w800, c: const Color(0xFF0B1520)).copyWith(letterSpacing: 1)),
                          ]),
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: scan,
                      builder: (_, _) => Positioned(
                        left: 14,
                        right: 14,
                        top: 250 * (.08 + .8 * Curves.easeInOut.transform(scan.value)),
                        child: Container(height: 2, decoration: const BoxDecoration(color: Color(0xFF4ADE80), boxShadow: [BoxShadow(color: Color(0xFF4ADE80), blurRadius: 12)])),
                      ),
                    ),
                  ]),
                ),
                Positioned(bottom: 24, left: 0, right: 0, child: Text('Arahkan kamera ke barcode di unit', textAlign: TextAlign.center, style: ts(14, c: const Color(0xFFD3DEEC)))),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            child: Column(children: [
              Material(
                color: const Color(0xFF4ADE80),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => setState(() { stage = 'form'; unit = 'LV-12'; }), child: SizedBox(height: 52, width: double.infinity, child: Center(child: Text('Simulasi: barcode terbaca', style: ts(15, w: FontWeight.w800, c: const Color(0xFF0B1520)))))),
              ),
              const Gap(10),
              Material(
                color: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0x55FFFFFF))),
                child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => setState(() { stage = 'form'; unit = 'LV-12'; }), child: SizedBox(height: 44, width: double.infinity, child: Center(child: Text('Masukkan kode unit manual', style: ts(14, w: FontWeight.w700, c: Colors.white))))),
              ),
            ]),
          ),
        ]),
      );
}

/// Label 12px + field (varian P2H: gap 4).
class Fld44 extends StatelessWidget {
  final String label;
  final Widget child;
  const Fld44(this.label, this.child, {super.key});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: ts(12, w: FontWeight.w600, c: C.text2)),
        const Gap(4),
        child,
      ]);
}
