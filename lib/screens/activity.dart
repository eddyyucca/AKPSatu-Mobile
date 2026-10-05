import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

class _Task {
  final String id, cat, title, meta, due, pic;
  final Tone tone;
  const _Task(this.id, this.cat, this.title, this.meta, this.due, this.tone, this.pic);
}

class _Dept {
  final String name;
  final List<(String, String, IconData, Color, Color, int)> tools;
  final List<_Task> tasks;
  const _Dept(this.name, this.tools, this.tasks);
}

const _depts = {
  'IT': _Dept('IT Department', [
    ('Laporan Aktivitas IT', 'Catat pekerjaan harian, tiket, & maintenance', Icons.assignment_outlined, C.blueSoft, C.blue, 0),
  ], [
    _Task('i1', 'HELPDESK · HD-0921', 'Printer Finance tidak terdeteksi', 'SLA 1 hari terlewati', 'Lewat 2 hari', Tone.bad, 'Agus Salim'),
    _Task('i2', 'LISENSI', 'Perpanjangan lisensi antivirus (120 user)', 'Penawaran vendor masuk, perlu approval PR', '15 Okt', Tone.warn, 'Budi Santoso'),
    _Task('i3', 'MAINTENANCE', 'Penggantian baterai UPS ruang server', 'PTW-2026-10-0039 aktif', 'Hari ini', Tone.info, 'Budi Santoso'),
  ]),
  'GA': _Dept('General Affair', [
    ('Checklist Kebersihan Kamar', 'Inspeksi kamar mess per blok', Icons.bed_outlined, C.tealBg, C.teal, 4),
  ], [
    _Task('g1', 'MESS', 'Inspeksi kamar Blok C lantai 2', '8 kamar belum diperiksa', 'Hari ini', Tone.warn, 'Tim Housekeeping 2'),
    _Task('g2', 'LAPORAN', 'AC C-214 tidak dingin', 'Dilaporkan penghuni', 'Besok', Tone.info, 'Teknisi Mess'),
  ]),
  'Kantin': _Dept('Kantin', [
    ('Menu Harian', 'Publikasikan menu & jatah makan', Icons.restaurant_outlined, C.orangeBg, C.orangeFg, 0),
  ], [
    _Task('k1', 'MENU', 'Menu makan malam belum dipublikasi', 'Batas 15:00', 'Hari ini', Tone.warn, 'Chef Rudi'),
  ]),
  'Survey': _Dept('Survey', [
    ('Checklist Lapangan', 'Catat progres survey area', Icons.map_outlined, C.blueSoft, C.blue, 0),
    ('Peta Progres Tambang', 'Mine plan · tersedia offline', Icons.layers_outlined, C.purpleBg, C.purple, 0),
  ], [
    _Task('s1', 'MINE PLAN', 'Update peta progres Pit B', 'Hujan 3 hari menghambat', '6 Okt', Tone.warn, 'Tim Survey'),
  ]),
  'Enviro': _Dept('Environment', [
    ('Cek Nursery', 'Kondisi bibit & penyiraman', Icons.eco_outlined, C.greenBg, C.greenFg, 0),
    ('Sampling Air', 'Catat hasil sampling lokasi', Icons.water_drop_outlined, C.blueSoft, C.blue, 0),
  ], [
    _Task('e1', 'SAMPLING', 'Sampling air settling pond 2', 'Jadwal mingguan', 'Besok', Tone.info, 'Tim Enviro'),
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

  @override
  Widget build(BuildContext context) {
    final d = _depts[dept]!;
    return SubPage(
      title: 'My Activity',
      subtitle: d.name,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InkWell(
            onTap: () => setState(() => offline = !offline),
            child: Pill(offline ? 'Offline' : 'Online', tone: offline ? Tone.warn : Tone.ok),
          ),
        ),
      ],
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(offline ? 'Mode offline · 2 form menunggu dikirim' : 'Tersinkron 07:12', style: ts(12, c: C.muted)),
        const Gap(10),
        const Text('CONTOH DEPARTEMEN (DEMO)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: C.muted)),
        const Gap(8),
        FilterChips(items: _depts.keys.toList(), value: dept, onChange: (v) => setState(() => dept = v)),
        const Gap(14),
        Text('Form & alat kerja', style: ts(16, w: FontWeight.w800)),
        const Gap(8),
        for (final t in d.tools)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ChevronRow(
              onTap: () => Navigator.pushNamed(context, t.$1.contains('Peta') ? R.peta : R.formKerja, arguments: dept),
              leading: IconBox(t.$3, t.$4, t.$5, size: 42),
              title: t.$1,
              sub: t.$2,
            ),
          ),
        const Gap(8),
        Text('Tugas & follow-up', style: ts(16, w: FontWeight.w800)),
        const Gap(8),
        for (final it in d.tasks)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Expanded(child: Text(it.cat, style: ts(11, w: FontWeight.w800, c: C.muted))), Pill(done.contains(it.id) ? 'Selesai' : it.due, tone: done.contains(it.id) ? Tone.ok : it.tone)]),
                const Gap(4),
                Text(it.title, style: ts(14, w: FontWeight.w700, h: 1.3)),
                Text(it.meta, style: ts(13, c: C.muted)),
                const Gap(8),
                Row(children: [
                  Expanded(child: Text('PIC: ${it.pic}', style: ts(12, c: C.text2))),
                  SizedBox(
                    height: 40,
                    child: done.contains(it.id)
                        ? OutlinedButton(onPressed: () => setState(() => done.remove(it.id)), child: const Text('Buka lagi'))
                        : FilledButton(onPressed: () => setState(() => done.add(it.id)), child: const Text('Tandai selesai')),
                  ),
                ]),
              ]),
            ),
          ),
      ]),
    );
  }
}

class _Tpl {
  final String title, photo;
  final List<(String, String)> fields;
  final List<String> checks;
  const _Tpl(this.title, this.photo, this.fields, this.checks);
}

const _tpls = {
  'IT / HR · Laporan Aktivitas': _Tpl('Laporan Aktivitas', 'Lampiran / foto (opsional)', [], []),
  'GA · Checklist Kebersihan Kamar Mess': _Tpl('Checklist Kebersihan Kamar', 'Foto kamar (wajib)', [('Blok / kamar', 'Mess Blok C · C-214'), ('Petugas', 'Tim Housekeeping 2')], [
    'Lantai & kolong tempat tidur bersih', 'Kamar mandi bersih, tidak bocor', 'Sprei & handuk diganti', 'AC berfungsi normal', 'Tempat sampah dikosongkan', 'Lampu & stop kontak berfungsi',
  ]),
  'Kantin · Menu Harian': _Tpl('Menu Harian Kantin', 'Foto sampel menu', [('Waktu makan', 'Makan Malam'), ('Menu', 'Nasi, ikan kuah kuning, tumis kangkung')], ['Bahan segar & layak', 'Porsi sesuai standar', 'Area penyajian bersih']),
  'Survey · Checklist Lapangan': _Tpl('Checklist Lapangan', 'Foto lokasi', [('Area', 'Pit B'), ('Surveyor', 'Tim Survey 1')], ['Patok batas terpasang', 'Koordinat dicatat', 'Akses jalan aman']),
  'Enviro · Cek Nursery': _Tpl('Cek Nursery', 'Foto bibit', [('Blok bibit', 'Nursery 1'), ('Jumlah bibit', '2.400')], ['Penyiraman terjadwal', 'Tidak ada hama', 'Naungan memadai']),
  'Enviro · Sampling Air': _Tpl('Sampling Air', 'Foto lokasi sampling', [('Lokasi', 'Settling pond 2'), ('pH', '7,2')], ['Botol sampel steril', 'Label sampel terpasang', 'Cool box terisi es']),
};

class FormKerjaScreen extends StatefulWidget {
  const FormKerjaScreen({super.key});
  @override
  State<FormKerjaScreen> createState() => _FormKerjaScreenState();
}

class _FormKerjaScreenState extends State<FormKerjaScreen> {
  String tpl = _tpls.keys.first;
  bool offline = true, sent = false, photo = false;
  String kategori = 'Maintenance', status = 'Selesai', terkait = 'PTW-2026-10-0039';
  final ans = <int, bool>{}; // true = sesuai, false = temuan

  @override
  Widget build(BuildContext context) {
    final t = _tpls[tpl]!;
    final isIt = t.checks.isEmpty && t.fields.isEmpty;
    final findings = ans.values.where((v) => !v).length;
    if (sent) {
      return SubPage(
        title: 'Form Kerja Departemen',
        body: ResultView(
          icon: offline ? Icons.cloud_off : Icons.check_circle,
          color: offline ? C.orange : C.green,
          title: offline ? 'Disimpan di perangkat' : 'Form terkirim',
          text: offline ? 'Anda sedang offline. Form akan dikirim otomatis saat sinyal tersedia.' : 'Form ${t.title} berhasil dikirim.',
          children: [
            PrimaryButton('Kembali ke My Activity', onTap: () => Navigator.pop(context)),
            TextButton(onPressed: () => setState(() { sent = false; ans.clear(); photo = false; }), child: Text('Isi lagi (demo)', style: ts(13, c: C.muted))),
          ],
        ),
      );
    }
    return SubPage(
      title: 'Form Kerja Departemen',
      subtitle: t.title,
      actions: [Padding(padding: const EdgeInsets.only(right: 8), child: InkWell(onTap: () => setState(() => offline = !offline), child: Pill(offline ? 'Offline' : 'Online', tone: offline ? Tone.warn : Tone.ok)))],
      bottom: PrimaryButton(offline ? 'Simpan di Perangkat' : 'Kirim Form', icon: offline ? Icons.save_alt : Icons.send, onTap: () => setState(() => sent = true)),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        DropField<String>('Template form (demo)', value: tpl, items: _tpls.keys.toList(), onChanged: (v) => setState(() { tpl = v!; ans.clear(); })),
        Text('Template, field, pilihan dropdown, dan checklist diatur per departemen dari web AKPSatu', style: ts(11, c: C.muted)),
        const Gap(14),
        if (isIt) ...[
          DropField<String>('Kategori', value: kategori, items: const ['Helpdesk / Tiket', 'Maintenance', 'Instalasi Perangkat', 'Proyek', 'Meeting / Koordinasi', 'Administrasi', 'Lainnya'], onChanged: (v) => setState(() => kategori = v!)),
          const TextBox('Uraian aktivitas', initial: 'Penggantian baterai UPS ruang server (PTW-0039).', lines: 3),
          const Row(children: [Expanded(child: TextBox('Mulai', initial: '13:00')), Gap(0, w: 10), Expanded(child: TextBox('Selesai', initial: '15:30'))]),
          Row(children: [Text('Durasi ', style: ts(13, c: C.muted)), Text('2 jam 30 mnt', style: ts(14, w: FontWeight.w800))]),
          const Gap(14),
          LabeledField('Status', ChoiceRow(options: const ['Selesai', 'Dalam proses', 'Tertunda'], selected: status, onSelect: (v) => setState(() => status = v), wrap: true)),
          DropField<String>('Terkait (opsional)', value: terkait, items: const ['PTW-2026-10-0039', 'Tiket HD-0921', 'Proyek migrasi NAS', 'Tidak ada'], onChanged: (v) => setState(() => terkait = v!)),
        ] else ...[
          for (final f in t.fields) TextBox(f.$1, initial: f.$2),
          Row(children: [Expanded(child: Text('Checklist', style: ts(15, w: FontWeight.w800))), Text('${ans.length} / ${t.checks.length} · $findings temuan', style: ts(12, c: C.muted))]),
          const Gap(8),
          for (var i = 0; i < t.checks.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t.checks[i], style: ts(14, w: FontWeight.w600)),
                  const Gap(8),
                  Row(children: [
                    Expanded(child: _answer('Sesuai', ans[i] == true, C.green, () => setState(() => ans[i] = true))),
                    const Gap(0, w: 8),
                    Expanded(child: _answer('Temuan', ans[i] == false, C.red, () => setState(() => ans[i] = false))),
                  ]),
                ]),
              ),
            ),
        ],
        const Gap(8),
        InkWell(
          onTap: () => setState(() => photo = !photo),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 76,
            width: double.infinity,
            decoration: BoxDecoration(color: photo ? C.greenBg : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: photo ? C.green : C.input, style: BorderStyle.solid)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(photo ? Icons.check_circle : Icons.photo_camera_outlined, color: photo ? C.green : C.muted),
              const Gap(0, w: 8),
              Text(photo ? '1 foto terlampir' : t.photo, style: ts(14, w: FontWeight.w600, c: photo ? C.greenFg : C.text2)),
            ]),
          ),
        ),
        const Gap(8),
        Text('Lokasi & waktu kirim tercatat otomatis · akurasi 8 m', style: ts(12, c: C.muted)),
      ]),
    );
  }

  Widget _answer(String label, bool on, Color c, VoidCallback tap) => SizedBox(
        height: 44,
        child: OutlinedButton(
          onPressed: tap,
          style: OutlinedButton.styleFrom(
            backgroundColor: on ? c.withValues(alpha: .12) : Colors.white,
            foregroundColor: on ? c : C.text2,
            side: BorderSide(color: on ? c : C.input, width: on ? 2 : 1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(label, style: ts(14, w: FontWeight.w700, c: on ? c : C.text2)),
        ),
      );
}
