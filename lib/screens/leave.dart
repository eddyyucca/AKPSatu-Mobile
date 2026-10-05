import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

class LeaveScreen extends StatelessWidget {
  const LeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget stat(String v, String l, Color c) => Expanded(
          child: Column(children: [
            Text(v, style: ts(22, w: FontWeight.w800, c: c)),
            Text(l, style: ts(12, c: C.pale)),
          ]),
        );
    Widget hist(String period, String sub, String meta, String pill, Tone tone) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(period, style: ts(14, w: FontWeight.w800)),
                  Text(sub, style: ts(13, c: C.text2, h: 1.4)),
                  const Gap(2),
                  Text(meta, style: ts(12, c: C.muted)),
                ]),
              ),
              Pill(pill, tone: tone),
            ]),
          ),
        );
    return SubPage(
      title: 'Cuti Tahunan',
      bottom: PrimaryButton('Ajukan Cuti', icon: Icons.add, onTap: () => Navigator.pushNamed(context, R.pengajuanCuti)),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: C.navy, borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Sisa cuti tahunan 2026', style: ts(13, c: C.pale)),
            const Gap(4),
            Text('9 dari 12 hari', style: ts(28, w: FontWeight.w800, c: Colors.white)),
            const Gap(10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: const LinearProgressIndicator(value: .75, minHeight: 8, backgroundColor: C.navy2, color: Color(0xFF6FA0F5)),
            ),
            const Gap(8),
            Text('Berlaku sampai 31 Des 2026', style: ts(12, c: C.pale)),
            const Gap(14),
            Row(children: [stat('12', 'Hak cuti', Colors.white), stat('3', 'Terpakai', Colors.white), stat('3', 'Menunggu', Colors.white)]),
          ]),
        ),
        const Gap(18),
        Text('Riwayat pengajuan', style: ts(16, w: FontWeight.w800)),
        const Gap(10),
        hist('19 – 21 Okt 2026', '3 hari · Keperluan keluarga', 'Diajukan 01 Okt 2026 · menunggu atasan', 'Pending', Tone.warn),
        hist('10 – 11 Agu 2026', '2 hari · Urusan pribadi', 'Bentrok dengan jadwal shutdown', 'Ditolak', Tone.bad),
        hist('02 – 04 Jun 2026', '3 hari · Liburan keluarga', 'Disetujui 25 Mei 2026', 'Disetujui', Tone.ok),
      ]),
    );
  }
}
