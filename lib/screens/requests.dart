import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

const _mon = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
String fmtDate(DateTime d) => '${d.day} ${_mon[d.month - 1]} ${d.year}';

class DateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  const DateField(this.label, this.value, this.onChanged, {super.key});
  @override
  Widget build(BuildContext context) => LabeledField(
        label,
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final d = await showDatePicker(context: context, initialDate: value, firstDate: DateTime(2026, 1, 1), lastDate: DateTime(2027, 12, 31));
            if (d != null) onChanged(d);
          },
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.input)),
            child: Row(children: [Expanded(child: Text(fmtDate(value), style: ts(15))), const Icon(Icons.calendar_today_outlined, size: 18, color: C.muted)]),
          ),
        ),
      );
}

class SwitchRow extends StatelessWidget {
  final String title, sub;
  final bool value;
  final ValueChanged<bool> onChanged;
  const SwitchRow(this.title, this.sub, this.value, this.onChanged, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: ts(14, w: FontWeight.w700)), Text(sub, style: ts(12, c: C.muted))])),
          Toggle(value, onChanged),
        ]),
      );
}

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});
  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  String jenis = 'Cuti Tahunan';
  DateTime start = DateTime(2026, 11, 9), end = DateTime(2026, 11, 11);
  String pengganti = 'Fajar Nugroho · Network Engineer';
  String kota = 'Makassar (UPG)';
  bool tiket = false, jemput = false, sent = false;

  static const jenisList = ['Cuti Tahunan', 'Cuti Roster', 'Cuti Sakit', 'Cuti Melahirkan', 'Cuti Menikah', 'Cuti Duka', 'Cuti Khusus'];

  int get days => end.difference(start).inDays + 1;
  bool get validRange => days >= 1;
  bool get over => validRange && jenis == 'Cuti Tahunan' && days > 9;
  bool get travel => tiket || jemput;

  @override
  Widget build(BuildContext context) {
    if (sent) {
      return SubPage(
        title: 'Pengajuan Cuti',
        body: ResultView(icon: Icons.check_circle, color: C.green, title: 'Pengajuan terkirim', text: 'Menunggu persetujuan Rudi Hartono (IT Manager). Anda akan menerima notifikasi setiap ada perubahan status.', children: [
          SummaryBox([
            ('No. pengajuan', 'CT-2026-11-0031'),
            ('Jenis', jenis),
            ('Periode', '${fmtDate(start)} – ${fmtDate(end)}'),
            ('Durasi', '$days hari'),
            ('Perjalanan', travel ? [if (tiket) 'Tiket', if (jemput) 'Jemputan'].join(' + ') : 'Tidak perlu'),
          ]),
          const Gap(16),
          PrimaryButton('Lihat Cuti Tahunan', onTap: () => Navigator.pop(context)),
          TextButton(onPressed: () => setState(() => sent = false), child: Text('Ajukan lagi (demo)', style: ts(13, c: C.muted))),
        ]),
      );
    }
    final ok = validRange && !over;
    return SubPage(
      title: 'Pengajuan Cuti',
      bottom: PrimaryButton(ok ? 'Kirim Pengajuan' : 'Periksa tanggal cuti', onTap: ok ? () => setState(() => sent = true) : null),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Ajukan Cuti', style: ts(22, w: FontWeight.w800)),
        const Gap(10),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(children: [Expanded(child: Text('Sisa cuti tahunan', style: ts(14, c: C.muted))), Text('9 hari', style: ts(20, w: FontWeight.w800))]),
        ),
        const Gap(14),
        DropField<String>('Jenis cuti', value: jenis, items: jenisList, onChanged: (v) => setState(() {
              jenis = v!;
              if (v == 'Cuti Roster') { tiket = true; jemput = true; }
              if (v == 'Cuti Sakit') { tiket = false; jemput = false; }
            })),
        Text('Daftar jenis cuti diatur HR dari web AKPSatu', style: ts(11, c: C.muted)),
        const Gap(14),
        Row(children: [
          Expanded(child: DateField('Tanggal mulai', start, (d) => setState(() => start = d))),
          const Gap(0, w: 10),
          Expanded(child: DateField('Tanggal selesai', end, (d) => setState(() => end = d))),
        ]),
        if (!validRange) const Notice('Tanggal selesai harus sama atau setelah tanggal mulai.', tone: Tone.bad, icon: Icons.error_outline)
        else if (over) const Notice('Durasi melebihi sisa cuti tahunan (9 hari).', tone: Tone.bad, icon: Icons.error_outline)
        else Row(children: [Text('Total $days hari', style: ts(14, w: FontWeight.w800)), const Spacer(), if (jenis == 'Cuti Tahunan') Text('Sisa setelah cuti: ${9 - days} hari', style: ts(13, c: C.muted))]),
        const Gap(14),
        const TextBox('Alasan', initial: 'Acara keluarga di Makassar.', lines: 3),
        DropField<String>('Pengganti tugas', value: pengganti, items: const ['Fajar Nugroho · Network Engineer', 'Agus Salim · IT Support', 'Rina Kartika · IT Support'], onChanged: (v) => setState(() => pengganti = v!)),
        const TextBox('Alamat selama cuti', hint: 'Alamat lengkap'),
        const TextBox('No. darurat', hint: '08xx xxxx xxxx', type: TextInputType.phone),
        if (jenis == 'Cuti Sakit')
          LabeledField('Surat dokter', OutlineButton('Unggah foto surat dokter', onTap: () => toast(context, 'Pilih foto (demo)'))),
        const SectionLabel('KEBUTUHAN PERJALANAN'),
        AppCard(
          child: Column(children: [
            SwitchRow('Tiket pesawat', 'Dipesankan oleh GA / Travel', tiket, (v) => setState(() => tiket = v)),
            const Divider(color: C.line),
            SwitchRow('Jemputan bandara', 'Mess ↔ bandara, berangkat & kembali', jemput, (v) => setState(() => jemput = v)),
          ]),
        ),
        if (travel) ...[
          const Gap(14),
          DropField<String>('Kota tujuan', value: kota, items: const ['Makassar (UPG)', 'Jakarta (CGK)', 'Surabaya (SUB)', 'Kota lain'], onChanged: (v) => setState(() => kota = v!)),
        ],
        const SectionLabel('ALUR PERSETUJUAN'),
        AppCard(
          child: FlowSteps([
            const StepItem(FlowState.now, 'Rudi Hartono', 'IT Manager · atasan langsung'),
            const StepItem(FlowState.wait, 'HR Department', 'Verifikasi saldo cuti & data'),
            if (travel) const StepItem(FlowState.wait, 'GA / Travel', 'Pesan tiket & jadwalkan jemputan'),
          ]),
        ),
      ]),
    );
  }
}

class OvertimeScreen extends StatefulWidget {
  const OvertimeScreen({super.key});
  @override
  State<OvertimeScreen> createState() => _OvertimeScreenState();
}

class _OvertimeScreenState extends State<OvertimeScreen> {
  String start = '19:00', end = '22:00', hari = 'Hari kerja';
  DateTime tgl = DateTime(2026, 10, 4);
  bool sent = false;
  static const starts = ['16:00', '16:30', '17:00', '17:30', '18:00', '18:30', '19:00', '19:30', '20:00', '20:30', '21:00', '21:30', '22:00'];
  static const ends = ['17:00', '18:00', '19:00', '20:00', '20:30', '21:00', '21:30', '22:00', '22:30', '23:00', '23:30', '24:00', '01:00 (+1)', '02:00 (+1)'];

  int toMin(String t) {
    final p = t.split(' ')[0].split(':');
    return int.parse(p[0]) * 60 + int.parse(p[1]);
  }

  double get dur {
    final a = toMin(start);
    var b = toMin(end);
    if (b <= a) b += 1440;
    return (b - a) / 60;
  }

  String get durLabel {
    final m = (dur * 60).round();
    return '${m ~/ 60} jam${m % 60 > 0 ? ' ${m % 60} mnt' : ''}';
  }

  static const used = 5.0;
  bool get warnDay => hari == 'Hari kerja' && dur > 4;
  bool get warnWeek => used + dur > 18;

  @override
  Widget build(BuildContext context) {
    if (sent) {
      return SubPage(
        title: 'Pengajuan Lembur',
        body: ResultView(icon: Icons.check_circle, color: C.green, title: 'Pengajuan lembur terkirim', text: 'Menunggu persetujuan Rudi Hartono. Setelah disetujui, jam lembur masuk ke perhitungan payroll oleh HR.', children: [
          SummaryBox([('No. pengajuan', 'LB-2026-10-0118'), ('Tanggal', '${fmtDate(tgl)} · $hari'), ('Jam', '$start – $end'), ('Durasi', durLabel)]),
          const Gap(16),
          PrimaryButton('Kembali ke Beranda', onTap: () => Navigator.pop(context)),
          TextButton(onPressed: () => setState(() => sent = false), child: Text('Ajukan lagi (demo)', style: ts(13, c: C.muted))),
        ]),
      );
    }
    final ok = !warnDay && !warnWeek;
    final total = (used + dur).clamp(0, 99).toDouble();
    Widget hist(String t, String s, String p, Tone tone) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(child: Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: ts(14, w: FontWeight.w800)), Text(s, style: ts(13, c: C.muted))])), Pill(p, tone: tone)])),
        );
    return SubPage(
      title: 'Pengajuan Lembur',
      bottom: PrimaryButton(ok ? 'Kirim Pengajuan Lembur' : 'Sesuaikan jam lembur', onTap: ok ? () => setState(() => sent = true) : null),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Ajukan Lembur', style: ts(22, w: FontWeight.w800)),
        const Gap(10),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text('Lembur minggu ini (28 Sep – 4 Okt)', style: ts(13, c: C.muted))), Text('${(total * 10).round() / 10} / 18 jam', style: ts(13, w: FontWeight.w800, c: warnWeek ? C.red : C.text))]),
            const Gap(8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(children: [
                Container(height: 10, color: C.chip),
                FractionallySizedBox(widthFactor: (total / 18).clamp(0, 1), child: Container(height: 10, color: warnWeek ? C.red : C.blue)),
                FractionallySizedBox(widthFactor: used / 18, child: Container(height: 10, color: C.navy)),
              ]),
            ),
            const Gap(6),
            Text('Sudah: 5 jam · Pengajuan ini: $durLabel', style: ts(12, c: C.muted)),
          ]),
        ),
        const Gap(14),
        DateField('Tanggal lembur', tgl, (d) => setState(() => tgl = d)),
        LabeledField('Jenis hari', ChoiceRow(options: const ['Hari kerja', 'Hari off / libur'], selected: hari, onSelect: (v) => setState(() => hari = v))),
        Row(children: [
          Expanded(child: DropField<String>('Jam mulai', value: start, items: starts, onChanged: (v) => setState(() => start = v!))),
          const Gap(0, w: 10),
          Expanded(child: DropField<String>('Jam selesai', value: end, items: ends, onChanged: (v) => setState(() => end = v!))),
        ]),
        Row(children: [Text('Durasi ', style: ts(13, c: C.muted)), Text(durLabel, style: ts(14, w: FontWeight.w800))]),
        const Gap(8),
        if (warnDay) const Notice('Melebihi batas lembur hari kerja (4 jam per hari).', tone: Tone.bad, icon: Icons.error_outline),
        if (warnWeek) const Padding(padding: EdgeInsets.only(top: 6), child: Notice('Total minggu ini melebihi batas 18 jam.', tone: Tone.bad, icon: Icons.error_outline)),
        const Gap(14),
        const TextBox('Uraian pekerjaan', initial: 'Migrasi file server ke NAS baru dan pengecekan backup.', lines: 3),
        const TextBox('Lokasi', initial: 'Ruang Server, Kantor Site'),
        const TextBox('Diperintahkan oleh', initial: 'Rudi Hartono'),
        const SectionLabel('RIWAYAT LEMBUR'),
        hist('3 Okt · 19:00 – 22:00', '3 jam · Update firewall', 'Disetujui', Tone.ok),
        hist('29 Sep · 19:00 – 21:00', '2 jam · Instalasi CCTV pos', 'Disetujui', Tone.ok),
        hist('22 Sep · 18:00 – 23:00', '5 jam · Melebihi batas harian', 'Ditolak', Tone.bad),
      ]),
    );
  }
}
