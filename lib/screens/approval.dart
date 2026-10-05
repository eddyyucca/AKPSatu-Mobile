import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

class ApprovalItem {
  final String type, ini, name, role, title, sub, when, hint;
  final Color avBg, avFg;
  final Tone hintTone;
  final List<(String, String)> fields;
  const ApprovalItem(this.type, this.ini, this.avBg, this.avFg, this.name, this.role, this.title, this.sub, this.when, this.hint, this.fields, {this.hintTone = Tone.neutral});
}

const _agus = ApprovalItem('Cuti', 'AS', Color(0xFFDCE7FB), C.blueFg, 'Agus Salim', 'IT Support · AKP014', 'Cuti Tahunan · 3 hari', '12 – 14 Okt 2026 · pengganti: Rina Kartika', '11:42', 'Mulai 8 hari lagi', [
  ('Jenis', 'Cuti Tahunan'),
  ('Periode', 'Sen – Rab, 12 – 14 Okt 2026'),
  ('Durasi', '3 hari'),
  ('Sisa cuti', '10 → 7 hari'),
  ('Alasan', 'Acara pernikahan saudara'),
  ('Pengganti', 'Rina Kartika'),
  ('Perjalanan', 'Tidak perlu tiket / jemputan'),
]);

const pendingItems = <ApprovalItem>[
  _agus,
  ApprovalItem('Lembur', 'FN', C.tealBg, C.teal, 'Fajar Nugroho', 'Network Engineer · AKP022', '3 jam', 'Sab, 3 Okt · 19:00 – 22:00 · Migrasi switch core', 'Kemarin', 'Sudah dikerjakan', [
    ('Tanggal', 'Sab, 3 Okt 2026'), ('Jam', '19:00 – 22:00'), ('Durasi', '3 jam'), ('Uraian', 'Migrasi switch core'), ('Lembur minggu ini', '8 / 18 jam'),
  ]),
  ApprovalItem('Cuti', 'RK', C.pinkBg, C.pink, 'Rina Kartika', 'IT Support · AKP031', 'Cuti Roster · 14 hari', '19 Okt – 1 Nov 2026 · + tiket & jemputan', 'Kemarin', 'Perlu diproses cepat: tiket dipesan GA', [
    ('Jenis', 'Cuti Roster'), ('Periode', '19 Okt – 1 Nov 2026'), ('Durasi', '14 hari'), ('Perjalanan', 'Tiket + jemputan · Makassar'),
  ], hintTone: Tone.warn),
  ApprovalItem('PTW', 'FN', C.tealBg, C.teal, 'Fajar Nugroho', 'Network Engineer · AKP022', 'Bekerja di ketinggian', 'Sel, 6 Okt · 13:00 – 16:00 · Penarikan kabel antena Pos 3', '10:05', 'Checklist lengkap · lanjut ke HSE setelah Anda setujui', [
    ('Jenis', 'Bekerja di ketinggian'), ('Waktu', 'Sel, 6 Okt · 13:00 – 16:00'), ('Lokasi', 'Pos 3'), ('Checklist', '6 / 6 lengkap'), ('APD', 'Helm, harness, sepatu safety'),
  ]),
  ApprovalItem('Lembur', 'DA', Color(0xFFECE5FB), C.purple, 'Dewi Anggraini', 'IT Programmer · AKP045', '2 jam', 'Jum, 2 Okt · 19:00 – 21:00 · Deploy aplikasi FTW', '2 Okt', '', [
    ('Tanggal', 'Jum, 2 Okt 2026'), ('Jam', '19:00 – 21:00'), ('Durasi', '2 jam'), ('Uraian', 'Deploy aplikasi FTW'),
  ]),
  ApprovalItem('Lembur', 'FN', C.tealBg, C.teal, 'Fajar Nugroho', 'Network Engineer · AKP022', '4 jam', 'Kam, 1 Okt · 18:00 – 22:00 · Backup NAS', '1 Okt', 'Menunggu 3 hari', [
    ('Tanggal', 'Kam, 1 Okt 2026'), ('Jam', '18:00 – 22:00'), ('Durasi', '4 jam'), ('Uraian', 'Backup NAS'),
  ], hintTone: Tone.bad),
];

const doneItems = <ApprovalItem>[
  ApprovalItem('Cuti', 'DA', Color(0xFFECE5FB), C.purple, 'Dewi Anggraini', 'IT Programmer · AKP045', 'Cuti Sakit · 1 hari', '28 Sep 2026', '28 Sep', 'Disetujui', [('Jenis', 'Cuti Sakit'), ('Tanggal', '28 Sep 2026')], hintTone: Tone.ok),
  ApprovalItem('Lembur', 'AS', Color(0xFFDCE7FB), C.blueFg, 'Agus Salim', 'IT Support · AKP014', '2 jam', 'Sel, 29 Sep · 19:00 – 21:00', '29 Sep', 'Disetujui', [('Tanggal', '29 Sep 2026'), ('Durasi', '2 jam')], hintTone: Tone.ok),
  ApprovalItem('Lembur', 'FN', C.tealBg, C.teal, 'Fajar Nugroho', 'Network Engineer · AKP022', '5 jam', 'Sen, 21 Sep · 18:00 – 23:00', '22 Sep', 'Ditolak · melebihi batas harian', [('Tanggal', '21 Sep 2026'), ('Durasi', '5 jam')], hintTone: Tone.bad),
];

class ApprovalInboxScreen extends StatefulWidget {
  const ApprovalInboxScreen({super.key});
  @override
  State<ApprovalInboxScreen> createState() => _ApprovalInboxScreenState();
}

class _ApprovalInboxScreenState extends State<ApprovalInboxScreen> {
  int tab = 0;
  String f = 'Semua';

  Color typeBg(String t) => t == 'Cuti' ? C.orangeBg : t == 'Lembur' ? C.blueSoft : C.redBg;
  Color typeFg(String t) => t == 'Cuti' ? C.orangeFg : t == 'Lembur' ? C.blueFg : const Color(0xFF9C2B1F);

  @override
  Widget build(BuildContext context) {
    final src = tab == 0 ? pendingItems : doneItems;
    final list = src.where((e) => f == 'Semua' || e.type == f).toList();
    return SubPage(
      title: 'Persetujuan',
      subtitle: 'Budi Santoso · Supervisor IT · 4 anggota tim',
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Seg(tabs: ['Menunggu (${pendingItems.length})', 'Selesai'], index: tab, onChange: (v) => setState(() => tab = v)),
        const Gap(12),
        FilterChips(items: const ['Semua', 'Cuti', 'Lembur', 'PTW'], value: f, onChange: (v) => setState(() => f = v)),
        const Gap(12),
        if (list.isEmpty) Padding(padding: const EdgeInsets.all(32), child: Center(child: Text('Tidak ada pengajuan di kategori ini.', style: ts(14, c: C.muted)))),
        for (final it in list)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              onTap: tab == 0 ? () => Navigator.pushNamed(context, R.approvalDetail, arguments: it) : null,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Avatar(it.ini, bg: it.avBg, fg: it.avFg),
                  const Gap(0, w: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(it.name, style: ts(14, w: FontWeight.w800)), Text(it.role, style: ts(12, c: C.muted))])),
                  Text(it.when, style: ts(12, c: C.muted)),
                ]),
                const Gap(10),
                Row(children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: typeBg(it.type), borderRadius: BorderRadius.circular(6)), child: Text(it.type, style: ts(11, w: FontWeight.w800, c: typeFg(it.type)))),
                  const Gap(0, w: 8),
                  Expanded(child: Text(it.title, style: ts(14, w: FontWeight.w700))),
                ]),
                const Gap(4),
                Text(it.sub, style: ts(13, c: C.text2, h: 1.4)),
                if (it.hint.isNotEmpty) ...[const Gap(6), Text(it.hint, style: ts(12, w: FontWeight.w600, c: it.hintTone == Tone.neutral ? C.text2 : toneFg(it.hintTone)))],
              ]),
            ),
          ),
      ]),
    );
  }
}

class ApprovalDetailScreen extends StatefulWidget {
  const ApprovalDetailScreen({super.key});
  @override
  State<ApprovalDetailScreen> createState() => _ApprovalDetailScreenState();
}

class _ApprovalDetailScreenState extends State<ApprovalDetailScreen> {
  String d = 'pending'; // pending | approved | rejected
  bool rejecting = false;
  String reason = '';
  final note = TextEditingController();

  static const reasons = ['Bentrok jadwal tim', 'Saldo / batas tidak mencukupi', 'Data belum lengkap', 'Lainnya'];

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final it = (ModalRoute.of(context)?.settings.arguments as ApprovalItem?) ?? _agus;
    final first = it.name.split(' ')[0];
    final isCuti = it.type == 'Cuti';
    final steps = switch (d) {
      'approved' => [
          StepItem(FlowState.ok, 'Diajukan', '${it.name} · ${it.when}'),
          const StepItem(FlowState.ok, 'Atasan langsung', 'Budi Santoso (Anda) · disetujui baru saja'),
          StepItem(FlowState.now, isCuti ? 'HR Department' : 'Tahap berikutnya', isCuti ? 'Menunggu verifikasi saldo · Siti Rahmawati' : 'Menunggu HSE Officer'),
          StepItem(FlowState.wait, 'Selesai', '$first menerima notifikasi'),
        ],
      'rejected' => [
          StepItem(FlowState.ok, 'Diajukan', '${it.name} · ${it.when}'),
          StepItem(FlowState.bad, 'Atasan langsung', 'Budi Santoso (Anda) · ditolak${reason.isEmpty ? '' : ' · $reason'}'),
          const StepItem(FlowState.wait, 'Selesai', 'Pengajuan dikembalikan ke pemohon'),
        ],
      _ => [
          StepItem(FlowState.ok, 'Diajukan', '${it.name} · ${it.when}'),
          const StepItem(FlowState.now, 'Atasan langsung', 'Budi Santoso (Anda) · menunggu keputusan'),
          StepItem(FlowState.wait, isCuti ? 'HR Department' : 'Tahap berikutnya', 'Verifikasi'),
          StepItem(FlowState.wait, 'Selesai', '$first menerima notifikasi'),
        ],
    };

    Widget? bottom;
    if (d == 'pending' && !rejecting) {
      bottom = Row(children: [
        Expanded(child: OutlineButton('Tolak', color: C.red, height: 52, onTap: () => setState(() => rejecting = true))),
        const Gap(0, w: 10),
        Expanded(child: PrimaryButton('Setujui', color: C.green, onTap: () => setState(() => d = 'approved'))),
      ]);
    } else if (rejecting) {
      bottom = Row(children: [
        Expanded(child: OutlineButton('Batal', height: 52, onTap: () => setState(() => rejecting = false))),
        const Gap(0, w: 10),
        Expanded(child: PrimaryButton('Kirim Penolakan', color: C.red, onTap: reason.isEmpty ? null : () => setState(() { d = 'rejected'; rejecting = false; }))),
      ]);
    } else {
      bottom = PrimaryButton('Kembali ke daftar (5 lagi)', onTap: () => Navigator.pop(context));
    }

    return SubPage(
      title: 'Detail Persetujuan',
      bottom: bottom,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Persetujuan ${it.type}', style: ts(20, w: FontWeight.w800)),
          const Spacer(),
          Pill(switch (d) { 'approved' => 'Disetujui', 'rejected' => 'Ditolak', _ => 'Menunggu' }, tone: switch (d) { 'approved' => Tone.ok, 'rejected' => Tone.bad, _ => Tone.warn }),
        ]),
        Text(isCuti ? 'CT-2026-10-0027' : '${it.type.toUpperCase()}-2026-10-0118', style: ts(12, c: C.muted)),
        const Gap(12),
        AppCard(
          child: Row(children: [
            Avatar(it.ini, bg: it.avBg, fg: it.avFg, size: 48),
            const Gap(0, w: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(it.name, style: ts(15, w: FontWeight.w800)), Text(it.role, style: ts(12, c: C.muted)), Text('Diajukan ${it.when}', style: ts(12, c: C.muted))])),
          ]),
        ),
        const Gap(10),
        SummaryBox(it.fields),
        if (isCuti) ...[
          const SectionLabel('DAMPAK KE TIM (12 – 14 OKT)'),
          const Notice('3 dari 4 anggota tim tetap bertugas', tone: Tone.info, icon: Icons.groups_outlined),
          const Gap(8),
          const Notice('Pengganti (Rina Kartika) masuk Day shift di tanggal tersebut', tone: Tone.ok, icon: Icons.check_circle_outline),
          const Gap(8),
          const Notice('Rina Kartika juga mengajukan Cuti Roster mulai 19 Okt (tidak bentrok)', tone: Tone.neutral, icon: Icons.event_available_outlined),
        ],
        const SectionLabel('ALUR PERSETUJUAN'),
        AppCard(child: FlowSteps(steps)),
        if (rejecting) ...[
          const SectionLabel('ALASAN PENOLAKAN (WAJIB)'),
          ChoiceRow(options: reasons, selected: reason, wrap: true, onSelect: (v) => setState(() => reason = v)),
          const Gap(12),
          TextBox('Keterangan', controller: note, lines: 3, hint: 'Tambahkan penjelasan untuk $first'),
        ] else if (d == 'pending') ...[
          const Gap(8),
          TextBox('Catatan untuk $first (opsional)', lines: 2, hint: 'Catatan persetujuan'),
        ],
        if (d != 'pending')
          Center(child: TextButton(onPressed: () => setState(() { d = 'pending'; reason = ''; }), child: Text('Batalkan keputusan (demo)', style: ts(13, c: C.muted)))),
      ]),
    );
  }
}
