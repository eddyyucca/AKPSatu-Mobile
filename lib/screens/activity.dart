import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';
import 'requests.dart';

class _Tool {
  final String title, sub, icon, route;
  final Color bg, fg;
  final int count;
  const _Tool(this.title, this.sub, this.icon, this.bg, this.fg, {this.route = R.formKerja, this.count = 0});
}

class _Task {
  final String id, st, cat, title, meta, due, lvl, pic;
  const _Task(this.id, this.st, this.cat, this.title, this.meta, this.due, this.lvl, this.pic);
}

class _Dept {
  final String name;
  final List<_Tool> tools;
  final List<_Task> items;
  const _Dept(this.name, this.tools, this.items);
}

const _iForm = 'M6 3h9l4 4v14H6zM15 3v4h4M9 12l2 2 4-4M9 17h6';
const _iBed = 'M3 18V7M3 13h18v5M21 13a3 3 0 0 0-3-3h-7v3M7 11a1.5 1.5 0 1 0 0-.01';
const _iFood = 'M7 3v8M5 3v5a2 2 0 0 0 4 0V3M7 11v10M17 3c-2 2-2.5 5-2.5 8h3V21';
const _iMap = 'M9 4L3 6v14l6-2 6 2 6-2V4l-6 2zM9 4v14M15 6v14';
const _iShare = 'M18 8a3 3 0 1 0 0-.01M6 12a3 3 0 1 0 0-.01M18 16a3 3 0 1 0 0-.01M8.6 13.5l6.8 4M15.4 6.5l-6.8 4';
const _iLeaf = 'M5 19c0-8 6-14 14-14 0 8-6 14-14 14zM5 19l7-7';
const _iDrop = 'M12 3s6 6.5 6 11a6 6 0 0 1-12 0c0-4.5 6-11 6-11z';
const _iTarget = 'M12 3v3M12 18v3M3 12h3M18 12h3M12 8a4 4 0 1 0 0 8 4 4 0 0 0 0-8z';
const _iDoc = 'M6 3h9l4 4v14H6zM15 3v4h4M9 13h6M9 17h4';
const _iPeople = 'M9 8a3.5 3.5 0 1 0 0-.01M2.5 20c.8-3.6 3.4-5.5 6.5-5.5s5.7 1.9 6.5 5.5M16 4.5a3.5 3.5 0 0 1 0 7';

const _depts = <String, _Dept>{
  'IT': _Dept('IT Department', [
    _Tool('Laporan Aktivitas IT', 'Catat pekerjaan harian, tiket, & maintenance', _iForm, Color(0xFFE6EEFD), Color(0xFF1E5BD7)),
  ], [
    _Task('i1', 'follow', 'HELPDESK · HD-0921', 'Printer Finance tidak terdeteksi', 'SLA 1 hari terlewati', 'Lewat 2 hari', 'red', 'Agus Salim'),
    _Task('i2', 'follow', 'LISENSI', 'Perpanjangan lisensi antivirus (120 user)', 'Penawaran vendor masuk, perlu approval PR', '15 Okt', 'orange', 'Eddy Adha Saputra'),
    _Task('i3', 'pend', 'PROYEK', 'Migrasi file server ke NAS', 'Progres 70%', '20 Okt', 'grey', 'Eddy Adha Saputra'),
  ]),
  'HR': _Dept('HR Department', [
    _Tool('Laporan Aktivitas HR', 'Rekrutmen, onboarding, administrasi karyawan', _iForm, Color(0xFFE6EEFD), Color(0xFF1E5BD7)),
  ], [
    _Task('h1', 'follow', 'KONTRAK', 'Kontrak PKWT 4 karyawan berakhir', 'Perlu keputusan perpanjangan dari user', '20 Okt', 'orange', 'Siti Rahmawati'),
    _Task('h2', 'pend', 'ONBOARDING', 'Onboarding 3 karyawan baru', 'Induksi K3 & pembuatan ID card', '12 Okt', 'grey', 'Maria Ulfa'),
  ]),
  'GA': _Dept('General Affairs', [
    _Tool('Checklist Kebersihan Kamar Mess', '12 kamar Blok C belum dicek hari ini', _iBed, Color(0xFFE2F4E8), Color(0xFF1A6B3A), count: 12),
    _Tool('Konfirmasi Ruangan', 'Permintaan ruang training dari Learning Center', _iPeople, Color(0xFFEFE9FD), Color(0xFF5B32B8), route: R.learning, count: 1),
  ], [
    _Task('g1', 'follow', 'RUANGAN', 'Konfirmasi Training Room B · 15 Okt', 'Diminta HSE untuk Defensive Driving LV', '6 Okt', 'orange', 'Tim GA'),
    _Task('g2', 'pend', 'MESS', 'Perbaikan AC kamar C-208', 'Laporan kerusakan dari penghuni', '7 Okt', 'grey', 'Teknisi Mess'),
  ]),
  'Kantin': _Dept('Kantin', [
    _Tool('Input Menu Harian', 'Menu besok belum diinput', _iFood, Color(0xFFFFF1E0), Color(0xFFC2610C), count: 1),
  ], [
    _Task('k1', 'follow', 'MENU', 'Menu Senin, 5 Okt belum dipublikasikan', 'Menu tampil di layar Barcode Makan karyawan', 'Hari ini 17:00', 'red', 'Koordinator Kantin'),
    _Task('k2', 'pend', 'STOK', 'Stok beras & minyak di bawah minimum', 'Ajukan permintaan ke Purchasing', '6 Okt', 'grey', 'Gudang Kantin'),
  ]),
  'Survey': _Dept('Survey', [
    _Tool('Checklist Lapangan Survey', 'Persiapan alat & keselamatan sebelum ke lapangan', _iTarget, Color(0xFFD8F1F0), Color(0xFF14655F)),
  ], [
    _Task('s1', 'pend', 'PENGUKURAN', 'Survey volume stockpile ROM-2', 'Data untuk rekonsiliasi produksi mingguan', '5 Okt', 'orange', 'Tim Survey'),
    _Task('s2', 'pend', 'PENGUKURAN', 'Pick-up progres Pit B', 'Update peta progres Mine Plan', '7 Okt', 'grey', 'Tim Survey'),
  ]),
  'Mine Plan': _Dept('Mine Plan', [
    _Tool('Peta Progres Tambang', 'Update 3 Okt · tersedia offline', _iMap, Color(0xFFE3E8EF), Color(0xFF0E2A47), route: R.peta),
    _Tool('Bagikan Peta', '2 akses token aktif', _iShare, Color(0xFFE6EEFD), Color(0xFF1E5BD7), route: R.peta),
  ], [
    _Task('m1', 'follow', 'LAPORAN', 'Progres mingguan Pit B di bawah rencana', 'Aktual 54% vs rencana 60%', '6 Okt', 'orange', 'Engineer Mine Plan'),
    _Task('m2', 'pend', 'PETA', 'Revisi desain disposal D1', 'Menunggu data survey terbaru', '10 Okt', 'grey', 'Engineer Mine Plan'),
  ]),
  'Enviro': _Dept('Environment', [
    _Tool('Cek Nursery (Pembibitan)', 'Pemeriksaan harian bibit', _iLeaf, Color(0xFFE2F4E8), Color(0xFF1A6B3A), count: 1),
    _Tool('Sampling Air', 'Settling pond & titik pantau', _iDrop, Color(0xFFE6EEFD), Color(0xFF1E5BD7), count: 2),
  ], [
    _Task('e1', 'follow', 'SAMPLING', 'Sampling outlet settling pond SP-2', 'Jadwal pemantauan bulanan', 'Hari ini', 'red', 'Officer Enviro'),
    _Task('e2', 'pend', 'REKLAMASI', 'Penanaman 500 bibit di area reklamasi R-3', 'Bibit siap tanam dari nursery', '15 Okt', 'grey', 'Tim Reklamasi'),
  ]),
  'Compliance': _Dept('Compliance', [
    _Tool('Dokumen & Sertifikat', 'Pengingat masa berlaku', _iDoc, Color(0xFFFDE8E8), Color(0xFFB42318), count: 3),
  ], [
    _Task('c1', 'follow', 'SERTIFIKAT K3', 'Sertifikat Ahli K3 Umum · 2 orang', 'Jadwalkan resertifikasi', 'Habis 8 Okt', 'red', 'Sri Wahyuni'),
    _Task('c2', 'follow', 'SIMPER', 'SIMPER operator · 12 karyawan', 'Kirim daftar untuk ujian ulang', 'Habis 18 Okt', 'orange', 'Ketut Arsana'),
    _Task('c3', 'pend', 'PERIZINAN', '[Nama izin usaha] · perpanjangan', 'Dokumen persyaratan dari Legal', '30 Nov', 'grey', 'Tim Legal'),
  ]),
};

class MyActivityScreen extends StatefulWidget {
  const MyActivityScreen({super.key});
  @override
  State<MyActivityScreen> createState() => _MyActivityScreenState();
}

class _MyActivityScreenState extends State<MyActivityScreen> {
  String dept = 'IT';
  bool offline = false;
  final done = <String>{};

  (Color, Color) _lv(String l) => switch (l) {
        'red' => (C.redBg, C.red),
        'orange' => (C.orangeBg, C.orangeFg),
        'green' => (C.greenBg, C.greenFg),
        _ => (const Color(0xFFEEF1F5), const Color(0xFF3D4B5E)),
      };

  @override
  Widget build(BuildContext context) {
    final d = _depts[dept]!;
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
                  Text('My Activity', style: ts(18, w: FontWeight.w800, h: 1.3)),
                  Text('${d.name} · tampilan otomatis sesuai departemen', style: ts(12, c: C.muted, h: 1.3)),
                ]),
              ),
            ]),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: C.line))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: offline ? C.orangeBg : C.greenBg, borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: offline ? C.orange : C.green, shape: BoxShape.circle)),
                  const Gap(0, w: 8),
                  Expanded(child: Text(offline ? 'Mode offline · 3 data menunggu dikirim' : 'Online · semua data tersinkron 15:20', style: ts(12, w: FontWeight.w600, c: offline ? const Color(0xFF6B3A08) : const Color(0xFF14532D)))),
                  InkWell(onTap: () => setState(() => offline = !offline), child: Container(constraints: const BoxConstraints(minHeight: 32), alignment: Alignment.center, child: Text(offline ? 'Simulasi online' : 'Simulasi offline', style: ts(12, w: FontWeight.w700, c: C.blue)))),
                ]),
              ),
              const Gap(10),
              Text('CONTOH DEPARTEMEN (DEMO)', style: ts(11, w: FontWeight.w700, c: C.muted)),
              const Gap(6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(children: [
                  for (final k in _depts.keys) ...[
                    if (k != _depts.keys.first) const Gap(0, w: 6),
                    Material(
                      color: k == dept ? C.navy : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99), side: BorderSide(color: k == dept ? C.navy : C.input)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(99),
                        onTap: () => setState(() => dept = k),
                        child: Container(height: 36, padding: const EdgeInsets.symmetric(horizontal: 12), alignment: Alignment.center, child: Text(k, style: ts(13, w: k == dept ? FontWeight.w700 : FontWeight.w600, c: k == dept ? Colors.white : C.text2))),
                      ),
                    ),
                  ],
                ]),
              ),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(padding: const EdgeInsets.fromLTRB(2, 6, 2, 0), child: Text(dept == 'Mine Plan' ? 'Alat kerja' : 'Form kerja', style: ts(15, w: FontWeight.w800))),
                for (final t in d.tools) ...[
                  const Gap(10),
                  Material(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: C.line)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.pushNamed(context, t.route),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(children: [
                          Container(width: 42, height: 42, decoration: BoxDecoration(color: t.bg, borderRadius: BorderRadius.circular(12)), child: Center(child: Ic.path(t.icon, size: 22, color: t.fg))),
                          const Gap(0, w: 12),
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(t.title, style: ts(14, w: FontWeight.w700, h: 1.4)),
                              Text(t.sub, style: ts(12, c: C.muted, h: 1.4)),
                            ]),
                          ),
                          if (t.count > 0) ...[
                            const Gap(0, w: 12),
                            Container(constraints: const BoxConstraints(minWidth: 24), height: 24, padding: const EdgeInsets.symmetric(horizontal: 7), alignment: Alignment.center, decoration: BoxDecoration(color: C.redBg, borderRadius: BorderRadius.circular(12)), child: Text('${t.count}', style: ts(12, w: FontWeight.w800, c: C.red))),
                          ],
                          const Gap(0, w: 12),
                          const Ic('chevron', size: 18, stroke: 2, color: C.muted),
                        ]),
                      ),
                    ),
                  ),
                ],
                const Gap(10),
                Padding(padding: const EdgeInsets.fromLTRB(2, 6, 2, 0), child: Text('Tugas & follow-up', style: ts(15, w: FontWeight.w800))),
                for (final it in d.items) ...[
                  const Gap(10),
                  Opacity(
                    opacity: done.contains(it.id) ? .75 : 1,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: it.st == 'follow' && !done.contains(it.id) ? const Color(0xFFF2C4C0) : C.line), borderRadius: BorderRadius.circular(14)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(it.cat, style: ts(11, w: FontWeight.w700, c: C.muted).copyWith(letterSpacing: .3)),
                        const Gap(2),
                        Text(it.title, style: ts(14, w: FontWeight.w700, h: 1.35)),
                        const Gap(2),
                        Text(it.meta, style: ts(12, c: C.muted)),
                        const Gap(10),
                        Row(children: [
                          Builder(builder: (_) {
                            final (bg, fg) = _lv(done.contains(it.id) ? 'green' : it.lvl);
                            return Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)), child: Text(done.contains(it.id) ? 'Selesai' : it.due, style: ts(12, w: FontWeight.w700, c: fg)));
                          }),
                          const Gap(0, w: 8),
                          Expanded(child: Text('PIC: ${it.pic}', style: ts(12, c: C.muted))),
                          Material(
                            color: done.contains(it.id) ? Colors.white : C.blue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: done.contains(it.id) ? const BorderSide(color: C.input) : BorderSide.none),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => setState(() => done.contains(it.id) ? done.remove(it.id) : done.add(it.id)),
                              child: Container(constraints: const BoxConstraints(minHeight: 40), padding: const EdgeInsets.symmetric(horizontal: 12), alignment: Alignment.center, child: Text(done.contains(it.id) ? 'Buka lagi' : 'Selesai', style: ts(13, w: FontWeight.w700, c: done.contains(it.id) ? C.text2 : Colors.white))),
                            ),
                          ),
                        ]),
                      ]),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Fld {
  final String id, label, value;
  final bool area;
  const _Fld(this.id, this.label, this.value, {this.area = false});
}

class _Tpl {
  final String title, photo;
  final List<_Fld> fields;
  final List<String> checks;
  const _Tpl(this.title, this.photo, this.fields, this.checks);
}

const _tpls = <String, _Tpl>{
  'it': _Tpl('Laporan Aktivitas', 'Lampiran / foto (opsional)', [], []),
  'ga': _Tpl('Checklist Kebersihan Kamar', 'Foto kamar (wajib)', [_Fld('km', 'Blok / kamar', 'Mess Blok C · C-214'), _Fld('pt', 'Petugas', 'Tim Housekeeping 2')], [
    'Lantai & kolong tempat tidur bersih', 'Kamar mandi bersih, tidak bocor', 'Sprei & handuk diganti', 'AC berfungsi normal', 'Tempat sampah dikosongkan', 'Lampu & stop kontak berfungsi',
  ]),
  'kantin': _Tpl('Menu Harian Kantin', 'Foto sampel menu', [
    _Fld('tg', 'Tanggal', 'Senin, 5 Okt 2026'),
    _Fld('sp', 'Sarapan', 'Nasi kuning, telur balado, buah'),
    _Fld('ms', 'Makan siang', 'Nasi, ayam bakar, sayur asem, tempe'),
    _Fld('mm', 'Makan malam', 'Nasi, ikan kuah kuning, tumis kangkung'),
    _Fld('pr', 'Estimasi porsi per waktu makan', '850'),
  ], ['Sampel makanan disimpan', 'Suhu penyimpanan bahan sesuai', 'Kebersihan dapur dicek']),
  'survey': _Tpl('Checklist Lapangan Survey', 'Foto lokasi / alat', [_Fld('lk', 'Lokasi pengukuran', 'Stockpile ROM-2'), _Fld('al', 'Alat', 'GNSS RTK · unit 02')], [
    'Alat dikalibrasi / dicek akurasi', 'Titik referensi (BM) dicek', 'Baterai & controller cukup', 'Izin masuk area tambang', 'Komunikasi radio dengan dispatcher', 'APD lengkap',
  ]),
  'nursery': _Tpl('Cek Nursery (Pembibitan)', 'Foto kondisi bibit', [
    _Fld('bd', 'Bedeng / blok', 'Nursery Utama · Bedeng 3'),
    _Fld('jb', 'Bibit siap tanam (batang)', '520'),
    _Fld('jm', 'Bibit mati / layu (batang)', '6'),
  ], ['Penyiraman pagi dilakukan', 'Media tanam cukup', 'Bebas hama / penyakit', 'Naungan (paranet) dalam kondisi baik', 'Label jenis bibit lengkap']),
  'sampling': _Tpl('Sampling Air', 'Foto titik sampling', [
    _Fld('tt', 'Titik sampling', 'SP-2 · outlet settling pond'),
    _Fld('ph', 'pH lapangan', '7,2'),
    _Fld('kk', 'Kekeruhan / catatan visual', 'Agak keruh setelah hujan', area: true),
  ], ['Botol sampel berlabel', 'Pengawet ditambahkan sesuai parameter', 'Sampel disimpan di cool box', 'Formulir chain of custody diisi']),
};

const _tplLabels = {
  'it': 'IT / HR · Laporan Aktivitas',
  'ga': 'GA · Checklist Kebersihan Kamar Mess',
  'kantin': 'Kantin · Menu Harian',
  'survey': 'Survey · Checklist Lapangan',
  'nursery': 'Enviro · Cek Nursery',
  'sampling': 'Enviro · Sampling Air',
};

class FormKerjaScreen extends StatefulWidget {
  const FormKerjaScreen({super.key});
  @override
  State<FormKerjaScreen> createState() => _FormKerjaScreenState();
}

class _FormKerjaScreenState extends State<FormKerjaScreen> {
  String tpl = 'it';
  bool offline = true, sent = false;
  String kat = 'Maintenance', status = 'Selesai', terkait = 'PTW-2026-10-0039';
  DateTime start = DateTime(2026, 10, 4, 13, 0), end = DateTime(2026, 10, 4, 16, 30);
  final ans = <String, Map<int, String>>{};

  String _p2(int n) => n < 10 ? '0$n' : '$n';
  String _fmt(DateTime d) => '${_p2(d.day)}/${_p2(d.month)}/${d.year} ${_p2(d.hour)}:${_p2(d.minute)}';

  Future<DateTime?> _pick(DateTime cur) async {
    final d = await showDatePicker(context: context, initialDate: cur, firstDate: DateTime(2026), lastDate: DateTime(2027, 12, 31));
    if (d == null || !mounted) return null;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(cur));
    if (t == null) return null;
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  Widget _card(Widget child, {EdgeInsets pad = const EdgeInsets.all(14)}) => Container(
        width: double.infinity,
        padding: pad,
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
        child: child,
      );

  Widget _dtInp(DateTime v, ValueChanged<DateTime> on) => InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () async {
          final r = await _pick(v);
          if (r != null) on(r);
        },
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.input), borderRadius: BorderRadius.circular(10)),
          child: Row(children: [Expanded(child: Text(_fmt(v), style: ts(14, w: FontWeight.w400))), const Ic('leave', size: 16, color: C.text2)]),
        ),
      );

  Widget _answer(String label, bool on, Color c, VoidCallback tap) => Material(
        color: on ? c : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9), side: on ? BorderSide.none : const BorderSide(color: C.input)),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: tap,
          child: Container(constraints: const BoxConstraints(minHeight: 40), padding: const EdgeInsets.symmetric(horizontal: 10), alignment: Alignment.center, child: Text(label, style: ts(13, w: FontWeight.w700, c: on ? Colors.white : C.text2))),
        ),
      );

  Widget _inp46(String initial, {bool area = false}) => area
      ? TaField(initial)
      : SizedBox(
          height: 46,
          child: TextFormField(
            initialValue: initial,
            style: ts(15, w: FontWeight.w400),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.fromLTRB(9, 0, 9, 0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: C.input)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: C.input)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: C.blue, width: 2)),
            ),
          ),
        );

  @override
  Widget build(BuildContext context) {
    final t = _tpls[tpl]!;
    final isAct = tpl == 'it';
    final mins = end.difference(start).inMinutes;
    final durOk = mins > 0;
    final durLabel = durOk ? '${mins ~/ 60} jam${mins % 60 > 0 ? ' ${mins % 60} mnt' : ''}' : 'Selesai harus setelah mulai';
    final a = ans.putIfAbsent(tpl, () => {});
    final answered = a.length;
    final findings = a.values.where((v) => v == 'bad').length;
    final ready = isAct ? durOk : answered == t.checks.length;
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
            decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: C.line))),
            child: Row(children: [
              const BackBtn(label: 'Kembali ke My Activity'),
              const Gap(0, w: 4),
              Expanded(child: Text(t.title, style: ts(17, w: FontWeight.w800, h: 1.25))),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Semantics(
                  button: true,
                  label: 'Ganti status sinyal (demo)',
                  child: Material(
                    color: offline ? C.orangeBg : C.greenBg,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99), side: BorderSide(color: offline ? const Color(0xFFF6D2A8) : const Color(0xFFBFE3CC))),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(99),
                      onTap: () => setState(() => offline = !offline),
                      child: Container(
                        height: 34,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(width: 8, height: 8, decoration: BoxDecoration(color: offline ? C.orange : C.green, shape: BoxShape.circle)),
                          const Gap(0, w: 6),
                          Text(offline ? 'Offline' : 'Online', style: ts(12, w: FontWeight.w700, c: offline ? const Color(0xFF6B3A08) : const Color(0xFF14532D))),
                        ]),
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          ),
          Expanded(child: sent ? _result() : _form(t, isAct, durOk, durLabel, answered, findings, ready)),
        ]),
      ),
    );
  }

  Widget _form(_Tpl t, bool isAct, bool durOk, String durLabel, int answered, int findings, bool ready) {
    final a = ans[tpl]!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Fld('Template form (demo)', SelectInp<String>(value: tpl, height: 46, items: _tplLabels.keys.toList(), text: (k) => _tplLabels[k]!, onChanged: (v) => setState(() => tpl = v)), hint: 'Template, field, pilihan dropdown, dan checklist diatur per departemen dari web AKPSatu'),
        const Gap(12),
        if (isAct)
          _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Fld('Kategori', SelectInp<String>(value: kat, height: 46, items: const ['Helpdesk / Tiket', 'Maintenance', 'Instalasi Perangkat', 'Proyek', 'Meeting / Koordinasi', 'Administrasi', 'Lainnya'], onChanged: (v) => setState(() => kat = v))),
            const Gap(12),
            const Fld('Uraian aktivitas', TaField('Penggantian baterai UPS ruang server (PTW-0039).', rows: 3)),
            const Gap(12),
            Fld('Mulai', _dtInp(start, (v) => setState(() => start = v))),
            const Gap(12),
            Fld('Selesai', _dtInp(end, (v) => setState(() => end = v))),
            const Gap(12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: durOk ? C.blueSoft : C.redBg, borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Durasi', style: ts(14, c: durOk ? C.blueFg : C.red)), Text(durLabel, style: ts(17, w: FontWeight.w700, c: durOk ? C.blueFg : C.red))]),
            ),
            const Gap(12),
            Fld('Status', SelectInp<String>(value: status, height: 46, items: const ['Selesai', 'Dalam proses', 'Tertunda'], onChanged: (v) => setState(() => status = v))),
            const Gap(12),
            Fld('Terkait (opsional)', SelectInp<String>(value: terkait, height: 46, items: const ['PTW-2026-10-0039', 'Tiket HD-0921', 'Proyek migrasi NAS', 'Tidak ada'], onChanged: (v) => setState(() => terkait = v))),
          ]))
        else
          _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            for (var i = 0; i < t.fields.length; i++) ...[
              if (i > 0) const Gap(12),
              Fld(t.fields[i].label, _inp46(t.fields[i].value, area: t.fields[i].area)),
            ],
          ])),
        if (t.checks.isNotEmpty) ...[
          const Gap(12),
          _card(
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Checklist', style: ts(14, w: FontWeight.w800)),
                  Text('$answered / ${t.checks.length} · $findings temuan', style: ts(12, w: FontWeight.w700, c: C.muted)),
                ]),
              ),
              for (var i = 0; i < t.checks.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(border: i == 0 ? null : const Border(top: BorderSide(color: Color(0xFFEEF1F5)))),
                  child: Row(children: [
                    Expanded(child: Text(t.checks[i], style: ts(14, h: 1.35))),
                    const Gap(0, w: 10),
                    _answer('Sesuai', a[i] == 'ok', C.green, () => setState(() => a[i] = 'ok')),
                    const Gap(0, w: 6),
                    _answer('Temuan', a[i] == 'bad', C.orange, () => setState(() => a[i] = 'bad')),
                  ]),
                ),
            ]),
            pad: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          ),
        ],
        const Gap(12),
        _card(Column(children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => toast(context, 'Ambil foto (demo)'),
            child: DashedRRect(
              fill: const Color(0xFFF8FAFC),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Ic('camera', size: 20, color: C.text2), const Gap(4), Text(t.photo, style: ts(13, w: FontWeight.w700, c: C.text2))]),
            ),
          ),
          const Gap(10),
          Row(children: [const Ic.path('M12 21s7-6.2 7-12a7 7 0 0 0-14 0c0 5.8 7 12 7 12zM12 6.5a2.5 2.5 0 1 0 0 5 2.5 2.5 0 0 0 0-5z', size: 16, stroke: 2, color: C.green), const Gap(0, w: 8), Expanded(child: Text('Lokasi & waktu kirim tercatat otomatis · akurasi 8 m', style: ts(12, c: C.text2)))]),
        ])),
        const Gap(12),
        PrimaryButton(
          !ready ? (isAct ? 'Periksa jam mulai & selesai' : 'Lengkapi checklist (${t.checks.length - answered} lagi)') : offline ? 'Simpan (kirim saat ada sinyal)' : 'Kirim',
          height: 54,
          onTap: ready ? () => setState(() => sent = true) : null,
        ),
      ]),
    );
  }

  Widget _result() => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: Column(children: [
          Container(width: 84, height: 84, decoration: BoxDecoration(color: offline ? C.orangeBg : C.greenBg, shape: BoxShape.circle), child: Center(child: Ic.path(offline ? 'M12 4v10M8 10l4 4 4-4M5 20h14' : 'M5 12l4.5 4.5L19 7', size: 40, stroke: 2, color: offline ? C.orange : C.greenFg))),
          const Gap(14),
          Text(offline ? 'Tersimpan di perangkat' : 'Terkirim ke server', style: ts(22, w: FontWeight.w800)),
          const Gap(14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 310),
            child: Text(offline ? 'Belum ada sinyal. Data masuk antrean sinkron dan akan dikirim otomatis saat perangkat kembali online.' : 'Data sudah diterima server dan bisa dilihat atasan serta departemen terkait di web AKPSatu.', textAlign: TextAlign.center, style: ts(15, c: C.text2, h: 1.55)),
          ),
          const Gap(14),
          PrimaryButton('Kembali ke My Activity', onTap: () => Navigator.pop(context)),
          const Gap(14),
          InkWell(onTap: () => setState(() { sent = false; ans[tpl] = {}; }), child: SizedBox(height: 44, child: Center(child: Text('Isi lagi (demo)', style: ts(14, w: FontWeight.w700, c: C.blue))))),
        ]),
      );
}
