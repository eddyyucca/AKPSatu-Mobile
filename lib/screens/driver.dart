import 'package:flutter/material.dart' hide Text;
import '../pattern.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

class _Pax {
  final int seat;
  final String name, nip, dept, group, note;
  const _Pax(this.seat, this.name, this.nip, this.dept, this.group, this.note);
}

class _Trip {
  final String time, route, startedAt, eta;
  final Map<String, String> groups;
  final List<_Pax> pax;
  final List<int> preset;
  const _Trip(this.time, this.route, this.startedAt, this.eta, this.groups, this.pax, this.preset);
}

const _trips = [
  _Trip('05:10', 'Mess → Bandara KDI', '05:41', '06:50', {'MESS BLOK A': '05:10', 'MESS BLOK B': '05:20', 'MESS BLOK C · LOBBY': '05:30'}, [
    _Pax(2, 'Rizal Maulana', 'AKP122', 'Operations', 'MESS BLOK A', 'Pesawat XX 1234 · 09:40'),
    _Pax(3, 'Wahyu Pratama', 'AKP087', 'Maintenance', 'MESS BLOK A', 'Pesawat XX 1234 · 09:40'),
    _Pax(5, 'Sri Wahyuni', 'AKP203', 'HSE', 'MESS BLOK B', 'Pesawat XX 1238 · 11:20'),
    _Pax(6, 'Andi Pratama', 'AKP003', 'Operations', 'MESS BLOK B', 'Pesawat XX 1234 · 09:40'),
    _Pax(8, 'Yohanes Lado', 'AKP156', 'Maintenance', 'MESS BLOK B', 'Pesawat XX 1238 · 11:20'),
    _Pax(9, 'Nurul Hidayah', 'AKP210', 'Finance', 'MESS BLOK C · LOBBY', 'Pesawat XX 1234 · 09:40'),
    _Pax(11, 'Taufik Hidayat', 'AKP078', 'Operations', 'MESS BLOK C · LOBBY', 'Pesawat XX 1238 · 11:20'),
    _Pax(12, 'Ketut Arsana', 'AKP091', 'HSE', 'MESS BLOK C · LOBBY', 'Pesawat XX 1234 · 09:40'),
    _Pax(14, 'Eddy Adha Saputra', '32601949', 'IT', 'MESS BLOK C · LOBBY', 'Pesawat XX 1234 · 09:40'),
    _Pax(15, 'Hendra Wijaya', 'AKP007', 'Maintenance', 'MESS BLOK C · LOBBY', 'Pesawat XX 1238 · 11:20'),
    _Pax(17, 'Lukman Hakim', 'AKP140', 'Operations', 'MESS BLOK C · LOBBY', 'Pesawat XX 1234 · 09:40'),
    _Pax(18, 'Maria Ulfa', 'AKP188', 'HR', 'MESS BLOK C · LOBBY', 'Pesawat XX 1238 · 11:20'),
  ], [2, 3, 5, 6, 8]),
  _Trip('11:30', 'Bandara KDI → Site', '11:52', '13:05', {'BANDARA KDI · KEDATANGAN': '11:30'}, [
    _Pax(1, 'Arif Setiawan', 'AKP230', 'Operations', 'BANDARA KDI · KEDATANGAN', 'Tiba XX 1233 · 11:05 · turun Mess Blok A'),
    _Pax(2, 'Fitri Handayani', 'AKP008', 'Finance', 'BANDARA KDI · KEDATANGAN', 'Tiba XX 1233 · 11:05 · turun Mess Blok C'),
    _Pax(4, 'Gede Sudarma', 'AKP115', 'Maintenance', 'BANDARA KDI · KEDATANGAN', 'Tiba XX 1233 · 11:05 · turun Mess Blok B'),
    _Pax(5, 'Irwan Saputra', 'AKP167', 'Operations', 'BANDARA KDI · KEDATANGAN', 'Tiba XX 1233 · 11:05 · turun Mess Blok A'),
    _Pax(7, 'Joko Susilo', 'AKP098', 'HSE', 'BANDARA KDI · KEDATANGAN', 'Tiba XX 1233 · 11:05 · turun Mess Blok B'),
    _Pax(9, 'Siska Amelia', 'AKP221', 'HR', 'BANDARA KDI · KEDATANGAN', 'Tiba XX 1233 · 11:05 · turun Mess Blok C'),
    _Pax(10, 'Yusran Darwis', 'AKP176', 'Operations', 'BANDARA KDI · KEDATANGAN', 'Tiba XX 1233 · 11:05 · turun Mess Blok A'),
    _Pax(12, 'Rahman Tuasikal', 'AKP149', 'Maintenance', 'BANDARA KDI · KEDATANGAN', 'Tiba XX 1233 · 11:05 · turun Mess Blok B'),
  ], []),
];

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});
  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  int ti = 0;
  bool onlyRemaining = false;
  final boarded = <int, Set<int>>{0: {2, 3, 5, 6, 8}, 1: {}};
  final started = <int, bool>{};

  // Pada mockup angka statistik dibungkus <span> yang terkena `.stat span` (11px, pucat), dalam baris b setinggi 26.4px.
  Widget _stat(Widget big, String label, {bool borders = false}) => Expanded(
        child: Container(
          decoration: BoxDecoration(border: borders ? const Border(left: BorderSide(color: Color(0xFF2B4D73)), right: BorderSide(color: Color(0xFF2B4D73))) : null),
          child: Column(children: [
            SizedBox(height: 26.4, child: Center(child: big)),
            Text(label, style: ts(11, c: C.pale, h: 19.2 / 11)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final trip = _trips[ti];
    final b = boarded[ti]!;
    final nBoard = trip.pax.where((p) => b.contains(p.seat)).length;
    final total = trip.pax.length;
    final remaining = total - nBoard;
    final list = trip.pax.where((p) => !onlyRemaining || !b.contains(p.seat)).toList();
    final st = started[ti] ?? false;
    final children = <Widget>[];
    String? last;
    for (final p in list) {
      final on = b.contains(p.seat);
      if (p.group != last) {
        final inGroup = trip.pax.where((x) => x.group == p.group).toList();
        children.add(Padding(
          padding: const EdgeInsets.fromLTRB(2, 10, 2, 2),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(p.group, style: ts(12, w: FontWeight.w800, c: C.muted).copyWith(letterSpacing: .3)),
            Text('${trip.groups[p.group]} · ${inGroup.where((x) => b.contains(x.seat)).length}/${inGroup.length}', style: ts(12, w: FontWeight.w800, c: C.muted).copyWith(letterSpacing: .3)),
          ]),
        ));
        children.add(const Gap(8));
        last = p.group;
      }
      children.add(Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: on ? const Color(0xFFF3FBF6) : Colors.white, border: Border.all(color: on ? const Color(0xFFBFE3CC) : C.line), borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: C.navy, borderRadius: BorderRadius.circular(10)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('KURSI', style: ts(9, c: C.pale, h: 1)), Text('${p.seat}', style: ts(16, w: FontWeight.w800, c: Colors.white, h: 1))]),
          ),
          const Gap(0, w: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, style: ts(14, w: FontWeight.w700, h: 1.4)),
              Text('${p.nip} · ${p.dept}', style: ts(12, c: C.muted, h: 1.4)),
              Text(p.note, style: ts(12, c: C.text2, h: 1.4)),
            ]),
          ),
          const Gap(0, w: 12),
          Semantics(
            button: true,
            label: '${on ? 'Batalkan naik' : 'Tandai naik'} ${p.name}',
            child: Material(
              color: on ? C.green : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: on ? BorderSide.none : const BorderSide(color: C.blue, width: 1.5)),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => setState(() => on ? b.remove(p.seat) : b.add(p.seat)),
                child: Container(constraints: const BoxConstraints(minHeight: 44, minWidth: 96), padding: const EdgeInsets.symmetric(horizontal: 10), alignment: Alignment.center, child: Text(on ? 'Naik ✓' : 'Tandai naik', style: ts(13, w: FontWeight.w700, c: on ? Colors.white : C.blue))),
              ),
            ),
          ),
        ]),
      ));
      children.add(const Gap(8));
    }
    if (list.isEmpty) children.add(Padding(padding: const EdgeInsets.only(top: 32), child: Center(child: Text('Semua penumpang sudah naik.', style: ts(14, c: C.muted)))));
    Widget chip(String t, bool on, VoidCallback tap) => Material(
          color: on ? C.blue : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99), side: BorderSide(color: on ? C.blue : C.input)),
          child: InkWell(borderRadius: BorderRadius.circular(99), onTap: tap, child: Container(height: 40, padding: const EdgeInsets.symmetric(horizontal: 14), alignment: Alignment.center, child: Text(t, style: ts(13, w: on ? FontWeight.w700 : FontWeight.w600, c: on ? Colors.white : C.text2)))),
        );
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(children: [
          BrandHeader(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
            child: Column(children: [
              Row(children: [
                Container(width: 44, height: 44, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFDCE7FB), shape: BoxShape.circle), child: Text('RH', style: ts(15, w: FontWeight.w800, c: C.blueFg))),
                const Gap(0, w: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Rahmat Hidayat', style: ts(16, w: FontWeight.w800, c: Colors.white, h: 1.35)),
                    Text('Driver · BUS-07 · DT 7421 KB', style: ts(12, c: C.pale, h: 1.35)),
                  ]),
                ),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: C.navy2, borderRadius: BorderRadius.circular(99)), child: Text('Sen, 5 Okt', style: ts(12, w: FontWeight.w700, c: const Color(0xFFDCE7FB)))),
              ]),
              const Gap(12),
              Row(children: [
                for (var i = 0; i < _trips.length; i++) ...[
                  if (i > 0) const Gap(0, w: 6),
                  Expanded(
                    child: Material(
                      color: i == ti ? Colors.white : Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: i == ti ? BorderSide.none : const BorderSide(color: Color(0xFF2B4D73))),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => setState(() { ti = i; onlyRemaining = false; }),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 52),
                          alignment: Alignment.center,
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Text(_trips[i].time, style: ts(15, w: FontWeight.w800, c: i == ti ? C.navy : const Color(0xFFDCE7FB), h: 1.25)),
                            Text(_trips[i].route, style: ts(11, c: i == ti ? C.navy : const Color(0xFFDCE7FB), h: 1.25)),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ],
              ]),
              const Gap(12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                decoration: BoxDecoration(color: C.navy2, borderRadius: BorderRadius.circular(12)),
                child: IntrinsicHeight(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    _stat(Text('$nBoard', style: ts(11, w: FontWeight.w800, c: C.pale)), 'Sudah naik'),
                    _stat(Text('$remaining', style: ts(11, w: FontWeight.w800, c: C.pale)), 'Belum naik', borders: true),
                    _stat(Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [Text('$total', style: ts(11, w: FontWeight.w800, c: C.pale)), Text('/20', style: ts(22, w: FontWeight.w800, c: Colors.white))]), 'Kursi terisi'),
                  ]),
                ),
              ),
            ]),
          ),
          if (st) Container(width: double.infinity, color: C.greenBg, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), child: Text('Perjalanan dimulai ${trip.startedAt} · estimasi tiba ${trip.eta}', style: ts(13, w: FontWeight.w600, c: const Color(0xFF14532D)))),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [chip('Semua ($total)', !onlyRemaining, () => setState(() => onlyRemaining = false)), const Gap(0, w: 8), chip('Belum naik ($remaining)', onlyRemaining, () => setState(() => onlyRemaining = true))]),
          ),
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children))),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: C.line))),
            child: Column(children: [
              if (!st && remaining > 0) ...[Text('$remaining penumpang belum naik', style: ts(12, w: FontWeight.w600, c: C.orangeFg)), const Gap(6)],
              PrimaryButton(st ? 'Selesaikan Perjalanan' : 'Mulai Perjalanan', color: st ? C.green : C.blue, onTap: () => setState(() => started[ti] = !st)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
            decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFEEF1F5)))),
            child: Row(children: [
              for (final t in const [('bus', 'Trip'), ('clock', 'Riwayat'), ('user', 'Profil')])
                Expanded(
                  child: InkWell(
                    onTap: t.$2 == 'Profil' ? () => Navigator.pushNamedAndRemoveUntil(context, R.login, (r) => false) : null,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 56),
                      child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                        Ic(t.$1, size: 22, color: t.$2 == 'Trip' ? C.blue : C.muted),
                        const Gap(4),
                        Text(t.$2, style: ts(11, w: FontWeight.w600, c: t.$2 == 'Trip' ? C.blue : C.muted)),
                      ]),
                    ),
                  ),
                ),
            ]),
          ),
        ]),
      ),
    );
  }
}
