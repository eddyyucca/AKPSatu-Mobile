import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

class CampScreen extends StatelessWidget {
  const CampScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget fac(IconData i, String t, String s) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(children: [
            IconBox(i, C.chip, C.navy, size: 40),
            const Gap(0, w: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: ts(14, w: FontWeight.w700)), Text(s, style: ts(12, c: C.muted))])),
          ]),
        );
    return SubPage(
      title: 'Camp Facility',
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Mess saya', style: ts(12, c: C.muted)),
            Text('Blok C · Kamar C-214', style: ts(20, w: FontWeight.w800)),
            const Gap(8),
            Wrap(spacing: 6, runSpacing: 6, children: const [Pill('Tipe Supervisor', tone: Tone.info), Pill('2 penghuni'), Pill('Lantai 2')]),
            const Gap(8),
            const KV('Teman sekamar', 'Hendra Wijaya'),
            const KV('Menempati sejak', '21 Sep 2026'),
            const KV('Jadwal laundry', 'Senin & Kamis'),
            const KV('Ambil laundry', '17:00 · Pos Laundry C'),
            const Divider(color: C.line),
            Text('Fasilitas kamar', style: ts(13, w: FontWeight.w700)),
            const Gap(8),
            Wrap(spacing: 6, runSpacing: 6, children: const [Pill('AC'), Pill('Wi-Fi'), Pill('Kamar mandi dalam'), Pill('Lemari'), Pill('Air panas')]),
          ]),
        ),
        const Gap(12),
        AppCard(
          child: Row(children: [
            const IconBox(Icons.support_agent, C.tealBg, C.teal, size: 40),
            const Gap(0, w: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Pengelola Mess Blok C', style: ts(14, w: FontWeight.w700)), Text('Pos Mess C · 24 jam · 0811 •••• 4402', style: ts(12, c: C.muted))])),
          ]),
        ),
        const Gap(12),
        OutlineButton('Lapor Kerusakan Kamar', onTap: () => sheet(context, (ctx) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Lapor Kerusakan Kamar', style: ts(18, w: FontWeight.w800)),
              const Gap(14),
              const TextBox('Kerusakan', lines: 3, hint: 'Contoh: AC tidak dingin'),
              PrimaryButton('Kirim Laporan', onTap: () { Navigator.pop(ctx); toast(context, 'Laporan terkirim ke pengelola mess'); }),
            ]))),
        const Gap(18),
        Text('Perjalanan cuti', style: ts(16, w: FontWeight.w800)),
        const Gap(10),
        AppCard(
          color: const Color(0xFFF5F8FE),
          border: const Color(0xFFC9D8F5),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Expanded(child: Text('Off roster 5 – 11 Okt 2026', style: ts(14, w: FontWeight.w800))), const Pill('Terkonfirmasi', tone: Tone.ok)]),
            const Gap(6),
            Text('Jemput 05:30 · BUS-07 · Kursi 14', style: ts(13, c: C.text2)),
            Text('Pesawat KDI → UPG · 09:40', style: ts(13, c: C.text2)),
            const Gap(8),
            GestureDetector(onTap: () => Navigator.pushNamed(context, R.itinerary), child: Text('Lihat itinerary', style: ts(13, w: FontWeight.w700, c: C.blue))),
          ]),
        ),
        const Gap(18),
        Text('Fasilitas camp', style: ts(16, w: FontWeight.w800)),
        const Gap(4),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          child: Column(children: [
            fac(Icons.restaurant, 'Kantin', '05:30 – 20:30 · Gedung Serbaguna'),
            fac(Icons.local_hospital_outlined, 'Klinik', '24 jam · samping Pos Security'),
            fac(Icons.fitness_center, 'Fitness center', '05:00 – 22:00'),
            fac(Icons.storefront_outlined, 'Minimarket', '07:00 – 21:00'),
          ]),
        ),
      ]),
    );
  }
}
