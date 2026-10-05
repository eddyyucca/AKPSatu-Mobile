import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class _Tr {
  final String id, cat, title, trainer, when, room;
  final bool roomOk, mandatory;
  final int n, max;
  final String by, warn;
  const _Tr(this.id, this.cat, this.title, this.trainer, this.when, this.room, this.roomOk, this.n, this.max, {this.mandatory = false, this.by = '', this.warn = ''});
}

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});
  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  int tab = 0;
  final enr = <String>{'cyber', 'excel'};

  static const sched = [
    _Tr('fire', 'K3', 'Fire Fighting Dasar', 'Tim ERT · HSE Department', 'Kam, 8 Okt · 08:00 – 12:00', 'Training Room A', true, 18, 25, warn: 'Bentrok: Anda sedang off roster 5 – 11 Okt.'),
    _Tr('cyber', 'WAJIB UMUM', 'Cyber Security Awareness', 'IT Department', 'Sel, 13 Okt · 09:00 – 11:00', 'Ruang Meeting Lt. 2 + online', true, 32, 40, mandatory: true, by: 'HR'),
    _Tr('drive', 'K3', 'Defensive Driving LV', 'Instruktur eksternal', 'Kam, 15 Okt · 08:00 – 16:00', 'Training Room B', false, 9, 15),
    _Tr('excel', 'TEKNIS', 'Microsoft Excel Lanjutan', 'IT Department', 'Sel, 20 Okt · 13:00 – 16:00', 'Lab Komputer', true, 12, 20),
    _Tr('lead', 'SOFT SKILL', 'Leadership untuk Supervisor', 'HR Development', 'Sel, 27 Okt · 08:00 – 17:00', 'Aula Camp', true, 20, 30),
  ];
  static const past = [
    ('K3', 'First Aid & CPR', 'Klinik Site', '15 Sep 2026 · 8 jam', 'Training Room A', 'Lulus · 88', 'Berlaku s/d Sep 2028'),
    ('TEKNIS', 'Fortigate Firewall Administration', 'Vendor', '20 – 21 Agu 2026 · 16 jam', 'Lab Komputer', 'Lulus · 91', 'Berlaku s/d Agu 2029'),
    ('K3', 'Induksi Keselamatan Tambang', 'HSE Department', '3 Mar 2026 · 4 jam', 'Aula Camp', 'Lulus · 95', 'Berlaku s/d Mar 2027'),
  ];

  (Color, Color) catColor(String c) => switch (c) {
        'K3' => (C.redBg, const Color(0xFF9C2B1F)),
        'TEKNIS' => (C.blueSoft, C.blueFg),
        'SOFT SKILL' => (C.purpleBg, C.purple),
        _ => (C.chip, C.navy),
      };

  Widget catPill(String c) {
    final (bg, fg) = catColor(c);
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)), child: Text(c, style: ts(11, w: FontWeight.w800, c: fg)));
  }

  @override
  Widget build(BuildContext context) {
    Widget stat(String v, String l) => Expanded(child: Column(children: [Text(v, style: ts(20, w: FontWeight.w800, c: Colors.white)), Text(l, style: ts(11, c: C.pale))]));
    final mine = sched.where((t) => enr.contains(t.id)).toList();
    return SubPage(
      title: 'Learning Center',
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: C.navy, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [stat('5', 'Training 2026'), stat('32 j', 'Jam belajar'), stat('4', 'Sertifikat aktif')]),
        ),
        const Gap(14),
        Seg(tabs: const ['Jadwal', 'Saya', 'Selesai'], index: tab, onChange: (v) => setState(() => tab = v)),
        const Gap(14),
        if (tab == 0) for (final t in sched) _card(t),
        if (tab == 1) ...[
          if (mine.isEmpty) Padding(padding: const EdgeInsets.all(24), child: Center(child: Text('Belum ada training yang Anda ikuti. Pilih dari tab Jadwal.', textAlign: TextAlign.center, style: ts(14, c: C.muted)))),
          for (final t in mine) _card(t),
        ],
        if (tab == 2)
          for (final p in past)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [catPill(p.$1), const Spacer(), Pill(p.$6, tone: Tone.ok)]),
                  const Gap(6),
                  Text(p.$2, style: ts(14, w: FontWeight.w800)),
                  Text('${p.$3} · ${p.$5}', style: ts(12, c: C.muted)),
                  Text(p.$4, style: ts(12, c: C.muted)),
                  const Gap(8),
                  Row(children: [
                    const Icon(Icons.workspace_premium_outlined, size: 18, color: C.purple),
                    const Gap(0, w: 6),
                    Expanded(child: Text('Sertifikat · ${p.$7}', style: ts(12, w: FontWeight.w600, c: C.purple))),
                    TextButton(onPressed: () => toast(context, 'Mengunduh sertifikat (demo)'), child: const Text('Unduh')),
                  ]),
                ]),
              ),
            ),
        const Gap(8),
        Text('Jadwal training dan pemesanan ruangan dibuat penyelenggara di web AKPSatu. Ruangan dikonfirmasi oleh GA.', style: ts(12, c: C.muted, h: 1.4)),
      ]),
    );
  }

  Widget _card(_Tr t) {
    final on = enr.contains(t.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [catPill(t.cat), const Gap(0, w: 8), if (t.mandatory) Text('WAJIB · ditugaskan ${t.by}', style: ts(11, w: FontWeight.w800, c: C.red))]),
          const Gap(6),
          Text(t.title, style: ts(15, w: FontWeight.w800)),
          Text(t.trainer, style: ts(12, c: C.muted)),
          const Gap(6),
          Row(children: [const Icon(Icons.schedule, size: 16, color: C.muted), const Gap(0, w: 6), Expanded(child: Text(t.when, style: ts(13, w: FontWeight.w600)))]),
          const Gap(4),
          Row(children: [
            const Icon(Icons.meeting_room_outlined, size: 16, color: C.muted),
            const Gap(0, w: 6),
            Flexible(child: Text(t.room, style: ts(13))),
            const Gap(0, w: 6),
            Pill(t.roomOk ? 'Ruang terkonfirmasi' : 'Menunggu GA', tone: t.roomOk ? Tone.ok : Tone.warn),
          ]),
          const Gap(4),
          Text('${t.n + (on ? 1 : 0)} / ${t.max} peserta', style: ts(12, c: C.muted)),
          if (t.warn.isNotEmpty) ...[const Gap(8), Notice(t.warn, tone: Tone.warn, icon: Icons.event_busy)],
          const Gap(10),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: on
                ? OutlinedButton(onPressed: t.mandatory ? null : () => setState(() => enr.remove(t.id)), child: Text(t.mandatory ? 'Terdaftar (wajib)' : 'Batalkan pendaftaran'))
                : FilledButton(onPressed: () => setState(() => enr.add(t.id)), child: const Text('Daftar')),
          ),
        ]),
      ),
    );
  }
}
