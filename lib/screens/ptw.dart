import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

class _Ptw {
  final String id, no, type, title, where, when, status;
  final Tone tone;
  final String alert;
  final Tone alertTone;
  final List<StepItem> steps;
  final List<String> actions;
  const _Ptw(this.id, this.no, this.type, this.title, this.where, this.when, this.status, this.tone, this.alert, this.alertTone, this.steps, this.actions);
}

const _active = [
  _Ptw('p39', 'PTW-2026-10-0039', 'LISTRIK / LOTO', 'Penggantian baterai UPS ruang server', 'Ruang Server, Kantor Site', 'Hari ini 13:00 – 17:00', 'AKTIF', Tone.ok,
      'Permit berlaku 2 jam 15 menit lagi. Tutup permit setelah pekerjaan selesai & isolasi dilepas.', Tone.ok, [
    StepItem(FlowState.ok, 'Pemohon', 'Budi Santoso · 2 Okt 10:20'),
    StepItem(FlowState.ok, 'Atasan langsung', 'Rudi Hartono · 2 Okt 13:05'),
    StepItem(FlowState.ok, 'HSE Officer', 'Rizky Maulana · 3 Okt 08:40'),
    StepItem(FlowState.ok, 'Area Owner', 'Site Services · 3 Okt 15:10'),
  ], ['Tutup Permit', 'Lihat checklist']),
  _Ptw('p45', 'PTW-2026-10-0045', 'BEKERJA DI KETINGGIAN', 'Pemasangan access point & antena di tiang Mess Blok C', 'Mess Blok C', 'Sel, 6 Okt 08:00 – 12:00', 'Menunggu HSE', Tone.warn, '', Tone.neutral, [
    StepItem(FlowState.ok, 'Pemohon', 'Budi Santoso · 3 Okt 16:12'),
    StepItem(FlowState.ok, 'Atasan langsung', 'Rudi Hartono · 3 Okt 17:30'),
    StepItem(FlowState.now, 'HSE Officer', 'Menunggu · Rizky Maulana'),
    StepItem(FlowState.wait, 'Area Owner', 'Site Services'),
  ], ['Lihat checklist']),
  _Ptw('p47', 'PTW-2026-10-0047', 'PENGGALIAN', 'Penggalian kabel FO ke Pos 2', 'Jalur Mess – Pos 2', 'Kam, 8 Okt 07:00 – 15:00', 'Perlu revisi', Tone.bad,
      'HSE Officer meminta lampiran gambar jalur utilitas. Lengkapi lalu ajukan ulang.', Tone.bad, [
    StepItem(FlowState.ok, 'Pemohon', 'Budi Santoso · 2 Okt 09:00'),
    StepItem(FlowState.ok, 'Atasan langsung', 'Rudi Hartono · 2 Okt 11:10'),
    StepItem(FlowState.bad, 'HSE Officer', 'Revisi diminta · 4 Okt 13:20'),
    StepItem(FlowState.wait, 'Area Owner', 'Site Services'),
  ], ['Perbaiki & ajukan ulang']),
];

const _history = [
  ('PTW-2026-09-0031', 'PEKERJAAN PANAS', 'Pengelasan bracket rak server', 'Workshop · 24 Sep', 'Ditutup', Tone.neutral),
  ('PTW-2026-09-0022', 'LISTRIK / LOTO', 'Pemeriksaan panel distribusi Mess C', 'Mess Blok C · 15 Sep', 'Ditutup', Tone.neutral),
  ('PTW-2026-09-0018', 'RUANG TERBATAS', 'Inspeksi tangki air bersih', 'Pos Air · 9 Sep', 'Ditolak', Tone.bad),
];

class PtwScreen extends StatefulWidget {
  const PtwScreen({super.key});
  @override
  State<PtwScreen> createState() => _PtwScreenState();
}

class _PtwScreenState extends State<PtwScreen> {
  int tab = 0;
  String? open = 'p45';

  @override
  Widget build(BuildContext context) => SubPage(
        title: 'PTW Online',
        subtitle: 'Permit to Work · pekerjaan risiko khusus',
        bottom: PrimaryButton('Buat PTW', icon: Icons.add, onTap: () => Navigator.pushNamed(context, R.ptwForm)),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Seg(tabs: const ['Aktif & proses (3)', 'Riwayat'], index: tab, onChange: (v) => setState(() => tab = v)),
          const Gap(14),
          if (tab == 0)
            for (final p in _active) _card(p)
          else
            for (final h in _history)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Expanded(child: Text(h.$1, style: ts(12, w: FontWeight.w700, c: C.muted))), Pill(h.$5, tone: h.$6)]),
                    const Gap(4),
                    Text(h.$2, style: ts(11, w: FontWeight.w800, c: C.red)),
                    Text(h.$3, style: ts(14, w: FontWeight.w700)),
                    Text(h.$4, style: ts(12, c: C.muted)),
                  ]),
                ),
              ),
        ]),
      );

  Widget _card(_Ptw p) {
    final isOpen = open == p.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () => setState(() => open = isOpen ? null : p.id),
        border: p.tone == Tone.ok ? const Color(0xFFBFE3CC) : C.line,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(p.no, style: ts(12, w: FontWeight.w700, c: C.muted))), Pill(p.status, tone: p.tone)]),
          const Gap(4),
          Text(p.type, style: ts(11, w: FontWeight.w800, c: C.red)),
          Text(p.title, style: ts(14, w: FontWeight.w800, h: 1.3)),
          Text('${p.where} · ${p.when}', style: ts(12, c: C.muted)),
          if (p.alert.isNotEmpty) ...[const Gap(10), Notice(p.alert, tone: p.alertTone, icon: p.alertTone == Tone.bad ? Icons.error_outline : Icons.timer_outlined)],
          if (isOpen) ...[
            const Divider(color: C.line, height: 24),
            const Text('ALUR PERSETUJUAN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: C.muted)),
            const Gap(10),
            FlowSteps(p.steps),
            Row(children: [
              for (var i = 0; i < p.actions.length; i++) ...[
                if (i > 0) const Gap(0, w: 8),
                Expanded(child: i == 0 && p.actions.length > 1 || p.actions.length == 1 && p.tone != Tone.warn ? PrimaryButton(p.actions[i], height: 44, onTap: () => toast(context, '${p.actions[i]} (demo)')) : OutlineButton(p.actions[i], height: 44, onTap: () => toast(context, '${p.actions[i]} (demo)'))),
              ],
            ]),
          ],
        ]),
      ),
    );
  }
}

class PtwFormScreen extends StatefulWidget {
  const PtwFormScreen({super.key});
  @override
  State<PtwFormScreen> createState() => _PtwFormScreenState();
}

class _PtwFormScreenState extends State<PtwFormScreen> {
  String jenis = 'height';
  bool sent = false, attached = false;
  final checked = <int>{};
  final workers = <String>['Budi Santoso (PIC)', 'Fajar Nugroho', 'Rina Kartika'];

  static const D = {
    'height': ('Bekerja di Ketinggian', ['Full body harness & lanyard sudah diperiksa', 'Titik angkur kuat dan tersertifikasi', 'Area bawah dibarikade & diberi rambu', 'Cuaca dan angin aman untuk bekerja', 'Pekerja memiliki sertifikat bekerja di ketinggian', 'Rencana penyelamatan (rescue plan) tersedia'], ['Helm + chin strap', 'Full body harness', 'Sepatu safety', 'Sarung tangan', 'Rompi reflektif']),
    'hot': ('Pekerjaan Panas (Hot Work)', ['APAR tersedia di lokasi kerja', 'Fire watch ditunjuk dan siaga', 'Material mudah terbakar disingkirkan', 'Gas test dilakukan sebelum mulai', 'Welding screen terpasang'], ['Helm', 'Kedok las', 'Apron kulit', 'Sarung tangan las', 'Sepatu safety']),
    'confined': ('Ruang Terbatas (Confined Space)', ['Gas test O₂, LEL, H₂S dilakukan', 'Ventilasi / blower terpasang', 'Pengawas luar (standby man) ditunjuk', 'Rencana penyelamatan tersedia', 'Komunikasi dua arah teruji'], ['Helm', 'Gas detector personal', 'Harness + tali penyelamat', 'Sepatu safety']),
    'loto': ('Listrik / LOTO', ['Isolasi energi dilakukan (lockout)', 'Tagout terpasang dengan nama pekerja', 'Tegangan nol diverifikasi', 'Alat uji terkalibrasi', 'Pekerja kompeten listrik'], ['Helm', 'Sarung tangan isolasi', 'Sepatu dielektrik', 'Face shield']),
    'dig': ('Penggalian', ['Jalur utilitas bawah tanah dipetakan', 'Area galian diberi barikade', 'Kemiringan / shoring sesuai kedalaman', 'Akses keluar-masuk galian aman', 'Alat berat dipandu spotter'], ['Helm', 'Sepatu safety', 'Sarung tangan', 'Rompi reflektif']),
  };

  @override
  Widget build(BuildContext context) {
    final d = D[jenis]!;
    if (sent) {
      return SubPage(
        title: 'Buat PTW',
        body: ResultView(icon: Icons.check_circle, color: C.green, title: 'PTW diajukan', text: 'PTW-2026-10-0048 · ${d.$1}. Menunggu persetujuan Rudi Hartono, lalu diteruskan ke HSE Officer.', children: [
          PrimaryButton('Lihat status PTW', onTap: () => Navigator.pop(context)),
          TextButton(onPressed: () => setState(() { sent = false; checked.clear(); }), child: Text('Buat lagi (demo)', style: ts(13, c: C.muted))),
        ]),
      );
    }
    final ready = checked.length == d.$2.length;
    return SubPage(
      title: 'Buat PTW',
      bottom: PrimaryButton(ready ? 'Ajukan PTW' : 'Lengkapi checklist (${checked.length}/${d.$2.length})', onTap: ready ? () => setState(() => sent = true) : null),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Buat Permit to Work', style: ts(22, w: FontWeight.w800)),
        const Gap(12),
        DropField<String>('Jenis pekerjaan', value: jenis, items: D.keys.toList(), text: (k) => D[k]!.$1, onChanged: (v) => setState(() { jenis = v!; checked.clear(); })),
        Text('Jenis, checklist, dan APD mengikuti form PTW di web', style: ts(11, c: C.muted)),
        const Gap(14),
        const TextBox('Uraian pekerjaan', initial: 'Pemasangan access point & antena di tiang Mess Blok C.', lines: 3),
        const TextBox('Lokasi', initial: 'Mess Blok C'),
        const Row(children: [Expanded(child: TextBox('Tanggal', initial: '6 Okt 2026')), Gap(0, w: 10), Expanded(child: TextBox('Jam', initial: '08:00 – 12:00'))]),
        LabeledField('Pekerja terlibat', Wrap(spacing: 8, runSpacing: 8, children: [
          for (final w in workers) InputChip(label: Text(w), onDeleted: workers.indexOf(w) == 0 ? null : () => setState(() => workers.remove(w))),
          ActionChip(avatar: const Icon(Icons.add, size: 18), label: const Text('Tambah'), onPressed: () => setState(() => workers.add('Pekerja ${workers.length + 1}'))),
        ])),
        Row(children: [Expanded(child: Text('Checklist ${d.$1}', style: ts(15, w: FontWeight.w800))), Text('${checked.length} / ${d.$2.length}', style: ts(12, c: C.muted))]),
        const Gap(8),
        for (var i = 0; i < d.$2.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              onTap: () => setState(() => checked.contains(i) ? checked.remove(i) : checked.add(i)),
              child: Row(children: [
                Checkbox(value: checked.contains(i), onChanged: (v) => setState(() => v == true ? checked.add(i) : checked.remove(i)), activeColor: C.green),
                Expanded(child: Text(d.$2[i], style: ts(14, h: 1.3))),
              ]),
            ),
          ),
        const SectionLabel('APD WAJIB'),
        Wrap(spacing: 6, runSpacing: 6, children: [for (final a in d.$3) Pill(a, tone: Tone.info)]),
        const Gap(16),
        InkWell(
          onTap: () => setState(() => attached = !attached),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 64,
            decoration: BoxDecoration(color: attached ? C.greenBg : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: attached ? C.green : C.input)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(attached ? Icons.check_circle : Icons.attach_file, color: attached ? C.green : C.muted),
              const Gap(0, w: 8),
              Text(attached ? 'JSA-Pos3.pdf terlampir' : 'Lampiran JSA / gambar kerja', style: ts(14, w: FontWeight.w600)),
            ]),
          ),
        ),
        const SectionLabel('ALUR PERSETUJUAN'),
        AppCard(child: FlowSteps([
          const StepItem(FlowState.now, 'Rudi Hartono', 'Atasan langsung'),
          const StepItem(FlowState.wait, 'HSE Officer', 'Rizky Maulana'),
          if (jenis == 'hot') const StepItem(FlowState.wait, 'Fire Watch', 'Ditunjuk sebelum permit aktif'),
          const StepItem(FlowState.wait, 'Area Owner', 'Site Services'),
        ])),
        const Gap(6),
        Text('Notifikasi dikirim ke Anda di setiap tahap persetujuan.', style: ts(12, c: C.muted)),
      ]),
    );
  }
}
