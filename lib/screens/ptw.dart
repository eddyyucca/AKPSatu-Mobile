import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';
import 'requests.dart';

class _Step {
  final String state, role, sub; // ok | now | rev | next
  final int n;
  const _Step(this.state, this.role, this.sub, [this.n = 0]);
}

class _Ptw {
  final String id, no, type, title, where, when, status, alert;
  final Color badgeBg, badgeFg, border, alertBg, alertFg;
  final List<_Step> steps;
  final List<(String, bool, String?)> actions; // label, primary, route
  const _Ptw(this.id, this.no, this.type, this.title, this.where, this.when, this.status, this.badgeBg, this.badgeFg, this.border, this.alert, this.alertBg, this.alertFg, this.steps, this.actions);
}

const _active = <_Ptw>[
  _Ptw('p39', 'PTW-2026-10-0039', 'LISTRIK / LOTO', 'Penggantian baterai UPS ruang server', 'Ruang Server, Kantor Site', 'Hari ini 13:00 – 17:00', 'AKTIF', C.greenBg, C.greenFg, Color(0xFFBFE3CC),
      'Permit berlaku 2 jam 15 menit lagi. Tutup permit setelah pekerjaan selesai & isolasi dilepas.', C.greenBg, Color(0xFF14532D), [
    _Step('ok', 'Pemohon', 'Eddy Adha Saputra · 2 Okt 10:20'),
    _Step('ok', 'Atasan langsung', 'Rudi Hartono · 2 Okt 13:05'),
    _Step('ok', 'HSE Officer', 'Rizky Maulana · 3 Okt 08:40'),
    _Step('ok', 'Area Owner', 'Site Services · 3 Okt 15:10'),
  ], [('Tutup Permit', true, null), ('Lihat checklist', false, null)]),
  _Ptw('p45', 'PTW-2026-10-0045', 'BEKERJA DI KETINGGIAN', 'Pemasangan access point & antena di tiang Mess Blok C', 'Mess Blok C', 'Sel, 6 Okt 08:00 – 12:00', 'Menunggu HSE', C.orangeBg, C.orangeFg, C.line, '', Colors.transparent, Colors.transparent, [
    _Step('ok', 'Pemohon', 'Eddy Adha Saputra · 3 Okt 16:12'),
    _Step('ok', 'Atasan langsung', 'Rudi Hartono · 4 Okt 09:30'),
    _Step('now', 'HSE Officer', 'Rizky Maulana · sedang ditinjau', 3),
    _Step('next', 'Area Owner', 'GA / Camp Management', 4),
  ], [('Lihat detail', false, null)]),
  _Ptw('p47', 'PTW-2026-10-0047', 'PENGGALIAN', 'Penggalian jalur kabel fiber optic ke Pos 2', 'Jalan akses Pos 2', 'Kam, 8 Okt 07:00 – 16:00', 'Perlu revisi', C.redBg, C.red, Color(0xFFF2C4C0),
      'HSE Officer: lampirkan gambar jalur utilitas bawah tanah & hasil pengecekan kabel eksisting.', C.redBg, Color(0xFF7A1A12), [
    _Step('ok', 'Pemohon', 'Eddy Adha Saputra · 4 Okt 08:15'),
    _Step('ok', 'Atasan langsung', 'Rudi Hartono · 4 Okt 10:02'),
    _Step('rev', 'HSE Officer', 'Revisi diminta · 4 Okt 13:20'),
    _Step('next', 'Area Owner', 'Mine Operation', 4),
  ], [('Revisi & Kirim Ulang', true, R.ptwForm)]),
];

const _hist = <_Ptw>[
  _Ptw('h1', 'PTW-2026-09-0031', 'BEKERJA DI KETINGGIAN', 'Perbaikan CCTV pos jaga utama', 'Pos Security Utama', '29 Sep 08:00 – 11:00', 'Ditutup', Color(0xFFEEF1F5), Color(0xFF3D4B5E), C.line, '', Colors.transparent, Colors.transparent, [
    _Step('ok', 'Pemohon', 'Eddy Adha Saputra'),
    _Step('ok', 'Atasan langsung', 'Rudi Hartono'),
    _Step('ok', 'HSE Officer', 'Rizky Maulana'),
    _Step('ok', 'Ditutup', '29 Sep 11:20 · area aman'),
  ], []),
  _Ptw('h2', 'PTW-2026-09-0024', 'PEKERJAAN PANAS', 'Pengelasan bracket rak server', 'Workshop Plant', '20 Sep 09:00 – 12:00', 'Ditolak', C.redBg, C.red, C.line, 'Ditolak HSE: pekerjaan dipindahkan ke workshop vendor.', C.bg, Color(0xFF3D4B5E), [
    _Step('ok', 'Pemohon', 'Eddy Adha Saputra'),
    _Step('ok', 'Atasan langsung', 'Rudi Hartono'),
    _Step('rev', 'HSE Officer', 'Ditolak · 19 Sep'),
  ], []),
];

class PtwScreen extends StatefulWidget {
  const PtwScreen({super.key});
  @override
  State<PtwScreen> createState() => _PtwScreenState();
}

class _PtwScreenState extends State<PtwScreen> {
  bool active = true;
  String open = 'p45';

  Widget _dot(_Step s) {
    final (bg, fg, t) = switch (s.state) {
      'ok' => (C.green, Colors.white, '✓'),
      'now' => (C.orange, Colors.white, '${s.n}'),
      'rev' => (C.red, Colors.white, '!'),
      _ => (const Color(0xFFEEF1F5), C.muted, '${s.n}'),
    };
    return Container(width: 24, height: 24, alignment: Alignment.center, decoration: BoxDecoration(color: bg, shape: BoxShape.circle), child: Text(t, style: ts(12, w: FontWeight.w800, c: fg)));
  }

  @override
  Widget build(BuildContext context) {
    final list = active ? _active : _hist;
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
            child: Row(children: [
              const BackBtn(label: 'Kembali ke beranda'),
              const Gap(0, w: 4),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('PTW Online', style: ts(18, w: FontWeight.w800, h: 1.3)),
                  Text('Permit to Work · pekerjaan risiko khusus', style: ts(12, c: C.muted, h: 1.3)),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Material(
                  color: C.blue,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => Navigator.pushNamed(context, R.ptwForm),
                    child: Container(height: 40, padding: const EdgeInsets.symmetric(horizontal: 14), child: Row(mainAxisSize: MainAxisSize.min, children: [const Ic('plus', size: 16, stroke: 2.2, color: Colors.white), const Gap(0, w: 6), Text('Buat PTW', style: ts(13, w: FontWeight.w700, c: Colors.white))])),
                  ),
                ),
              ),
            ]),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: C.line))),
            child: Seg(tabs: const ['Aktif & proses (3)', 'Riwayat'], index: active ? 0 : 1, onChange: (v) => setState(() => active = v == 0), gap: 4),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              child: Column(children: [
                for (var i = 0; i < list.length; i++) ...[
                  if (i > 0) const Gap(10),
                  _card(list[i]),
                ],
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _card(_Ptw p) {
    final isOpen = open == p.id;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: p.border), borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        InkWell(
          onTap: () => setState(() => open = isOpen ? '' : p.id),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              width: double.infinity,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Flexible(child: Text(p.no, style: ts(12, w: FontWeight.w600, c: C.muted))),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: p.badgeBg, borderRadius: BorderRadius.circular(99)), child: Text(p.status, style: ts(12, w: FontWeight.w700, c: p.badgeFg))),
                ]),
                const Gap(6),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: C.redBg, borderRadius: BorderRadius.circular(6)), child: Text(p.type, style: ts(11, w: FontWeight.w800, c: const Color(0xFF9C2B1F)))),
                const Gap(6),
                Text(p.title, style: ts(15, w: FontWeight.w700, h: 1.35)),
                const Gap(6),
                Text('${p.where} · ${p.when}', style: ts(12, c: C.muted)),
                if (p.alert.isNotEmpty) ...[
                  const Gap(6),
                  Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: p.alertBg, borderRadius: BorderRadius.circular(8)), child: Text(p.alert, style: ts(12, w: FontWeight.w600, c: p.alertFg, h: 1.45))),
                ],
              ]),
            ),
          ),
        ),
        if (isOpen)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFFEEF1F5)))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Gap(12),
              Text('ALUR PERSETUJUAN', style: ts(12, w: FontWeight.w800, c: C.muted)),
              for (final s in p.steps) ...[
                const Gap(10),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _dot(s),
                  const Gap(0, w: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.role, style: ts(13, w: FontWeight.w700, h: 1.35)), Text(s.sub, style: ts(12, c: C.muted, h: 1.35))])),
                ]),
              ],
              if (p.actions.isNotEmpty) ...[
                const Gap(10),
                Row(children: [
                  for (var i = 0; i < p.actions.length; i++) ...[
                    if (i > 0) const Gap(0, w: 8),
                    Expanded(
                      child: Material(
                        color: p.actions[i].$2 ? C.blue : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: p.actions[i].$2 ? BorderSide.none : const BorderSide(color: C.input)),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () => p.actions[i].$3 != null ? Navigator.pushNamed(context, p.actions[i].$3!) : toast(context, '${p.actions[i].$1} (demo)'),
                          child: SizedBox(height: 44, child: Center(child: Text(p.actions[i].$1, style: ts(14, w: FontWeight.w700, c: p.actions[i].$2 ? Colors.white : C.text)))),
                        ),
                      ),
                    ),
                  ],
                ]),
              ],
            ]),
          ),
      ]),
    );
  }
}

class _Jenis {
  final String label;
  final List<String> checks, apd;
  final (String, String)? extra;
  const _Jenis(this.label, this.checks, this.apd, this.extra);
}

const _jenisData = <String, _Jenis>{
  'height': _Jenis('Bekerja di Ketinggian', ['Full body harness & lanyard sudah diperiksa', 'Titik angkur kuat dan tersertifikasi', 'Area bawah dibarikade & diberi rambu', 'Cuaca dan angin aman untuk bekerja', 'Pekerja memiliki sertifikat bekerja di ketinggian', 'Rencana penyelamatan (rescue plan) tersedia'], ['Helm + chin strap', 'Full body harness', 'Sepatu safety', 'Sarung tangan', 'Rompi reflektif'], null),
  'hot': _Jenis('Pekerjaan Panas', ['APAR tersedia di lokasi kerja', 'Fire watch ditunjuk dan siaga', 'Material mudah terbakar disingkirkan', 'Gas test dilakukan sebelum mulai', 'Welding screen terpasang'], ['Helm', 'Kedok las', 'Apron kulit', 'Sarung tangan las', 'Sepatu safety'], ('Fire Watch', 'Ditunjuk sebelum permit aktif')),
  'confined': _Jenis('Ruang Terbatas', ['Gas test O₂, LEL, H₂S, CO dilakukan', 'Ventilasi tersedia selama pekerjaan', 'Standby person di pintu masuk', 'Peralatan penyelamatan siap', 'Komunikasi dua arah berfungsi'], ['Helm', 'Respirator / SCBA', 'Full body harness', 'Gas detector personal', 'Sepatu safety'], ('Gas Tester', 'Verifikasi hasil gas test')),
  'loto': _Jenis('Listrik / LOTO', ['Sumber energi sudah diisolasi', 'Gembok & tag LOTO terpasang', 'Tes zero energy dilakukan', 'Alat ukur terkalibrasi', 'Pekerja kompeten di bidang listrik'], ['Helm', 'Sarung tangan isolasi', 'Sepatu safety dielektrik', 'Kacamata safety'], null),
  'dig': _Jenis('Penggalian', ['Pengecekan utilitas bawah tanah dilakukan', 'Area galian dibarikade', 'Penahan dinding / kemiringan galian sesuai', 'Akses keluar-masuk galian tersedia', 'Inspeksi oleh orang yang kompeten'], ['Helm', 'Sepatu safety', 'Rompi reflektif', 'Sarung tangan'], null),
};

const _jenisLabels = {'height': 'Bekerja di Ketinggian', 'hot': 'Pekerjaan Panas (Hot Work)', 'confined': 'Ruang Terbatas (Confined Space)', 'loto': 'Listrik / LOTO', 'dig': 'Penggalian'};

class PtwFormScreen extends StatefulWidget {
  const PtwFormScreen({super.key});
  @override
  State<PtwFormScreen> createState() => _PtwFormScreenState();
}

class _PtwFormScreenState extends State<PtwFormScreen> {
  String jenis = 'height';
  bool sent = false;
  DateTime tgl = DateTime(2026, 10, 6);
  final ck = <String, Set<int>>{};
  final workers = <String>['Eddy Adha Saputra (PIC)', 'Fajar Nugroho', 'Rina Kartika'];

  Widget _chip(String t, {Color bg = const Color(0xFFEEF1F5), Color fg = C.text2}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
        child: Text(t, style: ts(13, w: FontWeight.w600, c: fg)),
      );

  Widget _card(Widget child, {EdgeInsets pad = const EdgeInsets.all(14)}) => Container(
        width: double.infinity,
        padding: pad,
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
        child: child,
      );

  @override
  Widget build(BuildContext context) {
    final def = _jenisData[jenis]!;
    final done = ck.putIfAbsent(jenis, () => {});
    final ready = done.length == def.checks.length;
    final flow = <(String, String)>[
      ('Atasan langsung', 'Rudi Hartono · IT Manager'),
      ('HSE Officer', 'Verifikasi checklist & JSA'),
      if (def.extra != null) def.extra!,
      ('Area Owner', 'Pemilik area kerja'),
      ('Permit aktif', 'Berlaku sesuai jam kerja yang diajukan'),
    ];
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(children: [
          const PageHeader('Buat Permit to Work'),
          Expanded(
            child: sent
                ? SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                    child: Column(children: [
                      Container(width: 84, height: 84, decoration: const BoxDecoration(color: C.blueSoft, shape: BoxShape.circle), child: const Center(child: Ic('send', size: 40, stroke: 2, color: C.blue))),
                      const Gap(14),
                      Text('PTW diajukan', style: ts(24, w: FontWeight.w800)),
                      const Gap(14),
                      Text.rich(
                        TextSpan(children: [TextSpan(text: 'PTW-2026-10-0048 · ${def.label}. Menunggu persetujuan '), TextSpan(text: 'Rudi Hartono', style: ts(15, w: FontWeight.w700, c: C.text2, h: 1.5)), const TextSpan(text: ', lalu diteruskan ke HSE Officer.')]),
                        textAlign: TextAlign.center,
                        style: ts(15, c: C.text2, h: 1.5),
                      ),
                      const Gap(14),
                      PrimaryButton('Lihat status PTW', onTap: () => Navigator.pop(context)),
                      const Gap(14),
                      InkWell(onTap: () => setState(() { sent = false; ck.clear(); }), child: SizedBox(height: 44, child: Center(child: Text('Buat lagi (demo)', style: ts(14, w: FontWeight.w700, c: C.blue))))),
                    ]),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Fld('Jenis pekerjaan', SelectInp<String>(value: jenis, items: _jenisLabels.keys.toList(), text: (k) => _jenisLabels[k]!, onChanged: (v) => setState(() => jenis = v)), hint: 'Jenis, checklist, dan APD mengikuti form PTW di web'),
                      const Gap(14),
                      const Fld('Uraian pekerjaan', TaField('Pemasangan access point & antena di tiang Mess Blok C.')),
                      const Gap(14),
                      const Fld('Lokasi', InpText(initial: 'Mess Blok C')),
                      const Gap(14),
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(child: Fld('Tanggal', DateInp(tgl, (d) => setState(() => tgl = d), fontSize: 14, padX: 10))),
                        const Gap(0, w: 10),
                        const Expanded(child: Fld('Jam', InpText(initial: '08:00 – 12:00'))),
                      ]),
                      const Gap(14),
                      Text('Pekerja terlibat', style: ts(13, w: FontWeight.w600, c: C.text2)),
                      const Gap(6),
                      Wrap(spacing: 6, runSpacing: 6, children: [
                        for (final w in workers) _chip(w),
                        InkWell(
                          borderRadius: BorderRadius.circular(99),
                          onTap: () => setState(() => workers.add('Pekerja ${workers.length + 1}')),
                          child: SizedBox(width: 88, child: DashedRRect(height: 34, radius: 17, color: const Color(0xFF8FA6C3), strokeWidth: 1, child: Center(child: Text('+ Tambah', style: ts(13, w: FontWeight.w700, c: C.blue))))),
                        ),
                      ]),
                      const Gap(14),
                      _card(
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Flexible(child: Text('Checklist ${def.label}', style: ts(14, w: FontWeight.w800))),
                              Text('${done.length} / ${def.checks.length}', style: ts(12, w: FontWeight.w700, c: ready ? C.greenFg : C.orangeFg)),
                            ]),
                          ),
                          for (var i = 0; i < def.checks.length; i++)
                            InkWell(
                              onTap: () => setState(() => done.contains(i) ? done.remove(i) : done.add(i)),
                              child: Container(
                                constraints: const BoxConstraints(minHeight: 44),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(border: i == 0 ? null : const Border(top: BorderSide(color: Color(0xFFEEF1F5)))),
                                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 1),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Checkbox(value: done.contains(i), onChanged: (v) => setState(() => v == true ? done.add(i) : done.remove(i)), activeColor: C.blue, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact, side: const BorderSide(color: Color(0xFF767676), width: 2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
                                    ),
                                  ),
                                  const Gap(0, w: 12),
                                  Expanded(child: Text(def.checks[i], style: ts(14, h: 1.4))),
                                ]),
                              ),
                            ),
                        ]),
                        pad: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      ),
                      const Gap(14),
                      _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('APD wajib', style: ts(14, w: FontWeight.w800)),
                        const Gap(8),
                        Wrap(spacing: 6, runSpacing: 6, children: [for (final a in def.apd) _chip(a, bg: C.orangeBg, fg: const Color(0xFF6B3A08))]),
                      ])),
                      const Gap(14),
                      Fld(
                        'Lampiran JSA / gambar kerja',
                        InkWell(
                          onTap: () => toast(context, 'Pilih berkas (demo)'),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.centerLeft,
                            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.input), borderRadius: BorderRadius.circular(10)),
                            child: Text('Pilih File  Tidak ada file yang dipilih', style: ts(14, w: FontWeight.w400)),
                          ),
                        ),
                      ),
                      const Gap(14),
                      _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Alur persetujuan', style: ts(14, w: FontWeight.w800)),
                        for (var i = 0; i < flow.length; i++) ...[
                          const Gap(10),
                          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(width: 24, height: 24, alignment: Alignment.center, decoration: const BoxDecoration(color: C.blueSoft, shape: BoxShape.circle), child: Text('${i + 1}', style: ts(12, w: FontWeight.w800, c: C.blueFg))),
                            const Gap(0, w: 10),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(flow[i].$1, style: ts(14, w: FontWeight.w700, h: 1.35)), Text(flow[i].$2, style: ts(12, c: C.muted, h: 1.35))])),
                          ]),
                        ],
                        const Gap(10),
                        Text('Notifikasi dikirim ke Anda di setiap tahap persetujuan.', style: ts(12, c: C.muted)),
                      ])),
                      const Gap(14),
                      PrimaryButton(ready ? 'Ajukan PTW' : 'Lengkapi checklist (${def.checks.length - done.length} lagi)', height: 54, onTap: ready ? () => setState(() => sent = true) : null),
                    ]),
                  ),
          ),
        ]),
      ),
    );
  }
}
