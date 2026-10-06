import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme.dart';
import '../widgets.dart';
import 'requests.dart';

class _Pit {
  final String k, name, note;
  final int actual, plan;
  const _Pit(this.k, this.name, this.actual, this.plan, this.note);
}

const _pits = [
  _Pit('A', 'Pit A', 78, 75, 'Pengupasan OB di atas rencana'),
  _Pit('B', 'Pit B', 54, 60, 'Tertinggal 6% · hujan 3 hari'),
  _Pit('C', 'Pit C', 22, 25, 'Tahap awal land clearing'),
  _Pit('D', 'Disposal D1', 90, 85, 'Mendekati kapasitas desain'),
];

Color _col(int v) => v >= 75 ? const Color(0xFF1F7A47) : v >= 40 ? const Color(0xFFE7A23B) : const Color(0xFFD96B5A);
String _hex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

String _mapSvg(Map<String, String> f, double roadOp) => '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 358 260" width="358" height="260">
<rect width="358" height="260" fill="#E9E2D3"/>
<path d="M0 40 C60 20 120 60 180 30 S300 10 358 30 L358 0 L0 0 Z" fill="#CFDCC2"/>
<path d="M0 230 C80 210 160 250 240 225 S330 215 358 230 L358 260 L0 260 Z" fill="#CFDCC2"/>
<path d="M20 200 L120 150 L180 160 L250 110 L330 90" stroke="#B7A98F" stroke-width="7" fill="none" stroke-linecap="round" opacity="$roadOp"/>
<path d="M120 150 L110 90 L150 60" stroke="#B7A98F" stroke-width="5" fill="none" stroke-linecap="round" opacity="$roadOp"/>
<polygon points="40,70 105,55 120,110 60,130" fill="${f['A']}" stroke="#7A5A2E" stroke-width="1.5"/>
<polygon points="165,70 240,60 255,105 180,125" fill="${f['B']}" stroke="#7A5A2E" stroke-width="1.5"/>
<polygon points="200,150 280,140 290,190 215,200" fill="${f['C']}" stroke="#7A5A2E" stroke-width="1.5"/>
<polygon points="40,165 95,155 100,195 45,205" fill="${f['D']}" stroke="#5A6B4A" stroke-width="1.5" stroke-dasharray="4 3"/>
<rect x="300" y="70" width="38" height="26" rx="4" fill="#9AA5B4"/>
</svg>''';

class MineMapScreen extends StatefulWidget {
  const MineMapScreen({super.key});
  @override
  State<MineMapScreen> createState() => _MineMapScreenState();
}

class _MineMapScreenState extends State<MineMapScreen> {
  String layer = 'prog';
  bool shareOpen = false, token = false, made = false;
  final revoked = <String>{};
  String valid = '3 hari', acc = 'Lihat saja';

  Widget _card(Widget child, {EdgeInsets pad = const EdgeInsets.all(14)}) => Container(
        width: double.infinity,
        padding: pad,
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
        child: child,
      );

  Widget _lbl(double x, double y, String t, {double size = 12, Color c = C.text}) => Positioned(left: x, top: y - size * .95, child: Text(t, style: ts(size, w: FontWeight.w800, c: c, h: 1)));

  Widget _legend(Color c, String t) => Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))), const Gap(0, w: 6), Text(t, style: ts(11, c: C.text2))]);

  @override
  Widget build(BuildContext context) {
    final fills = {for (final p in _pits) p.k: layer == 'plan' ? '#C9D8F5' : _hex(_col(p.actual))};
    final shares = <(String, String, String)>[
      if (made) ('s0', 'Kontraktor · PT [Nama Kontraktor]', 'Lihat saja · berlaku s/d 7 Okt 15:24 · baru dibuat'),
      ('s1', 'Kontraktor hauling', 'Lihat saja · berlaku s/d 5 Okt 18:00 · dibuka 4x'),
      ('s2', 'Konsultan geoteknik', 'Lihat + unduh · berlaku s/d 9 Okt · dibuka 1x'),
    ].where((x) => !revoked.contains(x.$1)).toList();
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Stack(children: [
          Column(children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
              child: Row(children: [
                const BackBtn(label: 'Kembali ke My Activity'),
                const Gap(0, w: 4),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Peta Progres Tambang', style: ts(17, w: FontWeight.w800, h: 1.3)),
                    Text('Mine Plan · update 3 Okt 2026', style: ts(12, c: C.muted, h: 1.3)),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Material(
                    color: C.blue,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => setState(() { shareOpen = true; token = false; }),
                      child: Container(height: 40, padding: const EdgeInsets.symmetric(horizontal: 12), child: Row(mainAxisSize: MainAxisSize.min, children: [const Ic('share', size: 16, stroke: 2, color: Colors.white), const Gap(0, w: 6), Text('Bagikan', style: ts(13, w: FontWeight.w700, c: Colors.white))])),
                    ),
                  ),
                ),
              ]),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: C.line))),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: C.orangeBg, borderRadius: BorderRadius.circular(8)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [const Ic('download', size: 14, stroke: 2, color: Color(0xFF6B3A08)), const Gap(0, w: 6), Flexible(child: Text('Tersimpan offline · diunduh 06:00', style: ts(12, w: FontWeight.w600, c: const Color(0xFF6B3A08))))]),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
                    for (final l in const [('prog', 'Progres'), ('plan', 'Rencana'), ('road', 'Jalan hauling')]) ...[
                      if (l.$1 != 'prog') const Gap(0, w: 6),
                      Material(
                        color: layer == l.$1 ? C.navy : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99), side: BorderSide(color: layer == l.$1 ? C.navy : C.input)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(99),
                          onTap: () => setState(() => layer = l.$1),
                          child: Container(height: 36, padding: const EdgeInsets.symmetric(horizontal: 12), alignment: Alignment.center, child: Text(l.$2, style: ts(12, w: layer == l.$1 ? FontWeight.w700 : FontWeight.w600, c: layer == l.$1 ? Colors.white : C.text2))),
                        ),
                      ),
                    ],
                  ])),
                  const Gap(12),
                  Semantics(
                    label: 'Peta area tambang dengan progres per pit',
                    child: Container(
                      width: double.infinity,
                      height: 262,
                      decoration: BoxDecoration(color: const Color(0xFFEDE6DA), border: Border.all(color: C.input), borderRadius: BorderRadius.circular(16)),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(children: [
                        Positioned(left: -1, top: -1, child: SvgPicture.string(_mapSvg(fills, layer == 'road' ? 1 : .35), width: 358, height: 260)),
                        _lbl(62, 96, 'Pit A'),
                        _lbl(188, 96, 'Pit B'),
                        _lbl(228, 176, 'Pit C'),
                        _lbl(52, 184, 'Disposal', size: 11),
                        _lbl(302, 88, 'ROM', size: 10, c: Colors.white),
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                              _legend(const Color(0xFF1F7A47), '≥ 75%'),
                              const Gap(3),
                              _legend(const Color(0xFFE7A23B), '40 – 74%'),
                              const Gap(3),
                              _legend(const Color(0xFFD96B5A), '< 40%'),
                            ]),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  const Gap(12),
                  _card(
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(padding: const EdgeInsets.fromLTRB(0, 10, 0, 2), child: Text('Progres vs rencana Oktober', style: ts(14, w: FontWeight.w800))),
                      for (var i = 0; i < _pits.length; i++)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(border: i == 0 ? null : const Border(top: BorderSide(color: Color(0xFFEEF1F5)))),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Flexible(child: Text(_pits[i].name, style: ts(14, w: FontWeight.w700))),
                              Text.rich(TextSpan(children: [
                                TextSpan(text: '${_pits[i].actual}% ', style: ts(14, w: FontWeight.w700, c: _pits[i].actual >= _pits[i].plan ? C.greenFg : C.orangeFg)),
                                TextSpan(text: '/ rencana ${_pits[i].plan}%', style: ts(14, c: C.muted)),
                              ])),
                            ]),
                            const Gap(6),
                            Semantics(
                              label: '${_pits[i].name} ${_pits[i].actual} persen dari rencana ${_pits[i].plan} persen',
                              child: LayoutBuilder(
                                builder: (_, b) => SizedBox(
                                  height: 8,
                                  child: Stack(clipBehavior: Clip.none, children: [
                                    Container(height: 8, decoration: BoxDecoration(color: const Color(0xFFEEF1F5), borderRadius: BorderRadius.circular(4))),
                                    Container(height: 8, width: b.maxWidth * _pits[i].actual / 100, decoration: BoxDecoration(color: _col(_pits[i].actual), borderRadius: BorderRadius.circular(4))),
                                    Positioned(top: -3, left: b.maxWidth * _pits[i].plan / 100, child: Container(width: 2, height: 14, color: C.text)),
                                  ]),
                                ),
                              ),
                            ),
                            const Gap(6),
                            Text(_pits[i].note, style: ts(12, c: C.muted)),
                          ]),
                        ),
                    ]),
                    pad: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  ),
                  const Gap(12),
                  _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Bagikan peta dengan token', style: ts(14, w: FontWeight.w800)),
                    const Gap(10),
                    Text('Beri akses lihat peta ke pihak lain (mis. kontraktor) tanpa akun AKPSatu, dengan masa berlaku.', style: ts(12, c: C.muted, h: 1.5)),
                    const Gap(10),
                    Material(
                      color: C.blue,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() { shareOpen = true; token = false; }),
                        child: SizedBox(height: 48, width: double.infinity, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Ic('share', size: 18, stroke: 2, color: Colors.white), const Gap(0, w: 8), Text('Bagikan Peta', style: ts(15, w: FontWeight.w700, c: Colors.white))])),
                      ),
                    ),
                    const Gap(10),
                    Padding(padding: const EdgeInsets.only(top: 4), child: Text('AKSES AKTIF (${shares.length})', style: ts(12, w: FontWeight.w700, c: C.muted))),
                    for (final s in shares) ...[
                      const Gap(10),
                      Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.$2, style: ts(14, w: FontWeight.w700, h: 1.4)), Text(s.$3, style: ts(12, c: C.muted, h: 1.4))])),
                        const Gap(0, w: 10),
                        Material(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9), side: const BorderSide(color: Color(0xFFF2C4C0))),
                          child: InkWell(borderRadius: BorderRadius.circular(9), onTap: () => setState(() => revoked.add(s.$1)), child: Container(constraints: const BoxConstraints(minHeight: 38), padding: const EdgeInsets.symmetric(horizontal: 10), alignment: Alignment.center, child: Text('Cabut', style: ts(12, w: FontWeight.w700, c: C.red)))),
                        ),
                      ]),
                    ],
                  ])),
                ]),
              ),
            ),
          ]),
          if (shareOpen) Positioned.fill(child: _sheet()),
        ]),
      ),
    );
  }

  Widget _outBtn(String t, VoidCallback tap) => Expanded(
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9), side: const BorderSide(color: C.input)),
          child: InkWell(borderRadius: BorderRadius.circular(9), onTap: tap, child: SizedBox(height: 40, child: Center(child: Text(t, style: ts(13, w: FontWeight.w700))))),
        ),
      );

  Widget _sheet() => GestureDetector(
        onTap: () => setState(() => shareOpen = false),
        child: Container(
          color: const Color(0x990B1520),
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: C.input, borderRadius: BorderRadius.circular(3)))),
                const Gap(12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Bagikan Peta', style: ts(17, w: FontWeight.w800)),
                  InkWell(borderRadius: BorderRadius.circular(10), onTap: () => setState(() => shareOpen = false), child: const SizedBox(width: 44, height: 44, child: Center(child: Ic('close', size: 20, stroke: 2)))),
                ]),
                const Gap(12),
                const Fld('Penerima', InpText(initial: 'Kontraktor · PT [Nama Kontraktor]', height: 44, fontSize: 14)),
                const Gap(10),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Fld('Berlaku', SelectInp<String>(value: valid, height: 44, items: const ['24 jam', '3 hari', '7 hari'], onChanged: (v) => setState(() => valid = v)))),
                  const Gap(0, w: 8),
                  Expanded(child: Fld('Akses', SelectInp<String>(value: acc, height: 44, items: const ['Lihat saja', 'Lihat + unduh'], onChanged: (v) => setState(() => acc = v)))),
                ]),
                const Gap(10),
                if (!token)
                  Material(
                    color: C.blue,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(borderRadius: BorderRadius.circular(10), onTap: () => setState(() { token = true; made = true; }), child: SizedBox(height: 46, width: double.infinity, child: Center(child: Text('Buat token akses', style: ts(14, w: FontWeight.w700, c: Colors.white))))),
                  )
                else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFC9D8F5)), borderRadius: BorderRadius.circular(10)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Token akses · berlaku s/d 7 Okt 15:24', style: ts(12, c: C.muted)),
                      const Gap(8),
                      Text('MAP-7K2Q-91XD', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 2, fontFamily: 'monospace', color: C.text)),
                      const Gap(8),
                      Row(children: [_outBtn('Salin token', () => toast(context, 'Token disalin')), const Gap(0, w: 8), _outBtn('Salin link', () => toast(context, 'Link disalin'))]),
                    ]),
                  ),
                  const Gap(10),
                  Material(
                    color: C.navy,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(borderRadius: BorderRadius.circular(10), onTap: () => setState(() => shareOpen = false), child: SizedBox(height: 46, width: double.infinity, child: Center(child: Text('Selesai', style: ts(14, w: FontWeight.w700, c: Colors.white))))),
                  ),
                ],
              ]),
            ),
          ),
        ),
      );
}
