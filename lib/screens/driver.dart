import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

class _Pax {
  final int seat;
  final String name, nip, dept, group, note;
  const _Pax(this.seat, this.name, this.nip, this.dept, this.group, this.note);
}

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});
  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  int trip = 0;
  String f = 'Semua';
  bool started = true;
  final boarded = <String>{'AKP122', 'AKP087', 'AKP203', 'AKP003', 'AKP156'};

  static const trips = [
    ('05:10', 'Mess → Bandara KDI', '05:41', '06:50', [
      _Pax(2, 'Rizal Maulana', 'AKP122', 'Operations', 'MESS BLOK A · 05:10', 'Pesawat XX 1234 · 09:40'),
      _Pax(3, 'Wahyu Pratama', 'AKP087', 'Maintenance', 'MESS BLOK A · 05:10', 'Pesawat XX 1234 · 09:40'),
      _Pax(5, 'Sri Wahyuni', 'AKP203', 'HSE', 'MESS BLOK B · 05:20', 'Pesawat XX 1238 · 11:20'),
      _Pax(6, 'Andi Pratama', 'AKP003', 'Operations', 'MESS BLOK B · 05:20', 'Pesawat XX 1234 · 09:40'),
      _Pax(8, 'Yohanes Lado', 'AKP156', 'Maintenance', 'MESS BLOK B · 05:20', 'Pesawat XX 1238 · 11:20'),
      _Pax(9, 'Nurul Hidayah', 'AKP210', 'Finance', 'MESS BLOK C · LOBBY · 05:30', 'Pesawat XX 1234 · 09:40'),
      _Pax(11, 'Taufik Hidayat', 'AKP078', 'Operations', 'MESS BLOK C · LOBBY · 05:30', 'Pesawat XX 1238 · 11:20'),
      _Pax(12, 'Ketut Arsana', 'AKP091', 'HSE', 'MESS BLOK C · LOBBY · 05:30', 'Pesawat XX 1234 · 09:40'),
      _Pax(14, 'Budi Santoso', 'AKP001', 'IT', 'MESS BLOK C · LOBBY · 05:30', 'Pesawat XX 1234 · 09:40'),
      _Pax(15, 'Hendra Wijaya', 'AKP007', 'Maintenance', 'MESS BLOK C · LOBBY · 05:30', 'Pesawat XX 1238 · 11:20'),
      _Pax(17, 'Lukman Hakim', 'AKP140', 'Operations', 'MESS BLOK C · LOBBY · 05:30', 'Pesawat XX 1234 · 09:40'),
      _Pax(18, 'Maria Ulfa', 'AKP188', 'HR', 'MESS BLOK C · LOBBY · 05:30', 'Pesawat XX 1238 · 11:20'),
    ]),
    ('11:30', 'Bandara KDI → Site', '11:52', '13:05', [
      _Pax(1, 'Arif Setiawan', 'AKP230', 'Operations', 'BANDARA KDI · KEDATANGAN · 11:30', 'Tiba XX 1233 · turun Mess Blok A'),
      _Pax(2, 'Fitri Handayani', 'AKP008', 'Finance', 'BANDARA KDI · KEDATANGAN · 11:30', 'Tiba XX 1233 · turun Mess Blok C'),
      _Pax(4, 'Gede Sudarma', 'AKP115', 'Maintenance', 'BANDARA KDI · KEDATANGAN · 11:30', 'Tiba XX 1233 · turun Mess Blok B'),
    ]),
  ];

  @override
  Widget build(BuildContext context) {
    final t = trips[trip];
    final pax = t.$5;
    final nBoard = pax.where((p) => boarded.contains(p.nip)).length;
    final remaining = pax.length - nBoard;
    final list = pax.where((p) => f == 'Semua' || (f == 'Belum naik' ? !boarded.contains(p.nip) : boarded.contains(p.nip))).toList();
    String? last;
    final children = <Widget>[];
    for (final p in list) {
      if (p.group != last) {
        children.add(Padding(padding: const EdgeInsets.only(top: 6, bottom: 8), child: Text(p.group, style: ts(12, w: FontWeight.w800, c: C.muted))));
        last = p.group;
      }
      final on = boarded.contains(p.nip);
      children.add(Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AppCard(
          color: on ? const Color(0xFFF1F9F4) : Colors.white,
          child: Row(children: [
            Container(
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(color: on ? C.greenBg : C.blueSoft, borderRadius: BorderRadius.circular(10)),
              child: Column(children: [Text('KURSI', style: ts(9, w: FontWeight.w800, c: on ? C.greenFg : C.blueFg)), Text('${p.seat}', style: ts(20, w: FontWeight.w800, c: on ? C.greenFg : C.blueFg))]),
            ),
            const Gap(0, w: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, style: ts(14, w: FontWeight.w800)),
              Text('${p.nip} · ${p.dept}', style: ts(12, c: C.muted)),
              Text(p.note, style: ts(12, c: C.text2)),
            ])),
            SizedBox(
              height: 44,
              child: on
                  ? OutlinedButton(onPressed: () => setState(() => boarded.remove(p.nip)), child: const Text('Naik ✓'))
                  : FilledButton(onPressed: () => setState(() => boarded.add(p.nip)), child: const Text('Naik')),
            ),
          ]),
        ),
      ));
    }
    Widget stat(String v, String l, Color c) => Expanded(child: AppCard(padding: const EdgeInsets.symmetric(vertical: 10), child: Column(children: [Text(v, style: ts(20, w: FontWeight.w800, c: c)), Text(l, style: ts(11, c: C.muted))])));
    return SubPage(
      title: 'Driver · Daftar Penumpang',
      actions: [IconButton(tooltip: 'Keluar', onPressed: () => Navigator.pushNamedAndRemoveUntil(context, R.login, (r) => false), icon: const Icon(Icons.logout))],
      bottom: remaining == 0
          ? PrimaryButton(started ? 'Selesaikan Perjalanan' : 'Mulai Perjalanan', color: C.green, onTap: () => setState(() => started = !started))
          : PrimaryButton(started ? '$remaining penumpang belum naik' : 'Mulai Perjalanan', color: started ? C.chip : C.blue, onTap: started ? null : () => setState(() => started = true)),
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Avatar('RH', bg: C.tealBg, fg: C.teal, size: 48),
          const Gap(0, w: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Rahmat Hidayat', style: ts(16, w: FontWeight.w800)), Text('Driver · BUS-07 · DT 7421 KB', style: ts(12, c: C.muted))])),
          const Pill('Sen, 5 Okt', tone: Tone.info),
        ]),
        const Gap(14),
        Seg(tabs: [for (final x in trips) '${x.$1} ${x.$2.split(' → ')[0]}'], index: trip, onChange: (v) => setState(() { trip = v; f = 'Semua'; })),
        const Gap(10),
        Text(t.$2, style: ts(15, w: FontWeight.w800)),
        Text('Perjalanan dimulai ${t.$3} · estimasi tiba ${t.$4}', style: ts(12, c: C.muted)),
        const Gap(10),
        Row(children: [stat('$nBoard', 'Sudah naik', C.green), const Gap(0, w: 8), stat('$remaining', 'Belum naik', C.orange), const Gap(0, w: 8), stat('${pax.length}/20', 'Kursi terisi', C.navy)]),
        const Gap(12),
        FilterChips(items: const ['Semua', 'Belum naik', 'Sudah naik'], value: f, onChange: (v) => setState(() => f = v)),
        const Gap(8),
        ...children,
        if (remaining == 0) const Padding(padding: EdgeInsets.only(top: 4), child: Notice('Semua penumpang sudah naik.', tone: Tone.ok, icon: Icons.check_circle_outline)),
      ]),
    );
  }
}
