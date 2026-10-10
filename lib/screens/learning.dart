import 'package:flutter/material.dart' hide Text;
import '../theme.dart';
import '../widgets.dart';

class _Tr {
  final String id, cat, title, trainer, when, room;
  final bool roomOk, mandatory;
  final int n, max;
  final String by, warn;
  const _Tr(this.id, this.cat, this.title, this.trainer, this.when, this.room, this.roomOk, this.n, this.max, {this.mandatory = false, this.by = '', this.warn = ''});
}

class _Past {
  final String cat, title, trainer, when, room, result, cert;
  const _Past(this.cat, this.title, this.trainer, this.when, this.room, this.result, this.cert);
}

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});
  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  String tab = 'sched';
  final enr = <String>{'cyber', 'excel'};

  static const sched = [
    _Tr('fire', 'K3', 'Fire Fighting Dasar', 'Tim ERT · HSE Department', 'Kam, 8 Okt · 08:00 – 12:00', 'Training Room A', true, 18, 25, warn: 'Bentrok: Anda sedang off roster 5 – 11 Okt.'),
    _Tr('cyber', 'WAJIB UMUM', 'Cyber Security Awareness', 'IT Department', 'Sel, 13 Okt · 09:00 – 11:00', 'Ruang Meeting Lt. 2 + online', true, 32, 40, mandatory: true, by: 'HR'),
    _Tr('drive', 'K3', 'Defensive Driving LV', 'Instruktur eksternal', 'Kam, 15 Okt · 08:00 – 16:00', 'Training Room B', false, 9, 15),
    _Tr('excel', 'TEKNIS', 'Microsoft Excel Lanjutan', 'IT Department', 'Sel, 20 Okt · 13:00 – 16:00', 'Lab Komputer', true, 12, 20),
    _Tr('lead', 'SOFT SKILL', 'Leadership untuk Supervisor', 'HR Development', 'Sel, 27 Okt · 08:00 – 17:00', 'Aula Camp', true, 20, 30),
  ];
  static const past = [
    _Past('K3', 'First Aid & CPR', 'Klinik Site', '15 Sep 2026 · 8 jam', 'Training Room A', 'Lulus · 88', 'Berlaku s/d Sep 2028'),
    _Past('TEKNIS', 'Fortigate Firewall Administration', 'Vendor', '20 – 21 Agu 2026 · 16 jam', 'Online', 'Lulus', 'Sertifikat vendor'),
    _Past('WAJIB UMUM', 'Refreshment Induksi K3', 'HSE Department', '10 Jun 2026 · 4 jam', 'Aula Camp', 'Hadir', 'Berlaku s/d Jun 2027'),
  ];

  Widget _cat(String c) {
    final (bg, fg) = switch (c) {
      'K3' => (C.redBg, const Color(0xFF9C2B1F)),
      'TEKNIS' => (C.blueSoft, C.blueFg),
      'SOFT SKILL' => (C.purpleBg, C.purple),
      _ => (const Color(0xFFE3E8EF), C.navy),
    };
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)), child: Text(c, style: ts(11, w: FontWeight.w800, c: fg)));
  }

  Widget _mi(String ic, List<InlineSpan> t) => Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Ic(ic, size: 15, color: C.text2),
        const Gap(0, w: 6),
        Expanded(child: Text.rich(TextSpan(children: t), style: ts(12, c: C.text2))),
      ]);

  Widget _card(Color border, List<Widget> children) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: border), borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (var i = 0; i < children.length; i++) ...[if (i > 0) const Gap(10), children[i]],
        ]),
      );

  Widget _st(String v, String l) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: C.navy2, borderRadius: BorderRadius.circular(10)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(v, style: ts(18, w: FontWeight.w800, c: Colors.white, h: 22.5 / 18)),
            SizedBox(height: 20, child: Padding(padding: const EdgeInsets.only(top: 4.8), child: Text(l, style: ts(11, c: C.pale)))),
          ]),
        ),
      );

  Widget _train(_Tr x) {
    final on = enr.contains(x.id);
    return _card(on ? const Color(0xFFC9D8F5) : C.line, [
      Wrap(spacing: 6, runSpacing: 6, children: [
        _cat(x.cat),
        if (x.mandatory) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: C.redBg, borderRadius: BorderRadius.circular(6)), child: Text('WAJIB · ditugaskan ${x.by}', style: ts(11, w: FontWeight.w800, c: C.red))),
      ]),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(x.title, style: ts(15, w: FontWeight.w700, h: 1.35)), Text(x.trainer, style: ts(12, c: C.muted, h: 1.35))]),
      Column(children: [
        _mi('calendar', [TextSpan(text: x.when)]),
        const Gap(5),
        _mi('building', [
          TextSpan(text: '${x.room} '),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(margin: const EdgeInsets.only(left: 6), padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: x.roomOk ? C.greenBg : C.orangeBg, borderRadius: BorderRadius.circular(6)), child: Text(x.roomOk ? 'Dikonfirmasi GA' : 'Menunggu GA', style: ts(11, w: FontWeight.w700, c: x.roomOk ? C.greenFg : C.orangeFg))),
          ),
        ]),
        const Gap(5),
        _mi('people', [TextSpan(text: '${x.n + (on && !x.mandatory ? 1 : 0)} / ${x.max} peserta')]),
      ]),
      if (x.warn.isNotEmpty) Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), decoration: BoxDecoration(color: C.orangeBg, borderRadius: BorderRadius.circular(8)), child: Text(x.warn, style: ts(12, w: FontWeight.w600, c: C.orangeFg))),
      Material(
        color: x.mandatory ? const Color(0xFFEEF1F5) : on ? const Color(0xFFF3FBF6) : C.blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: on && !x.mandatory ? const BorderSide(color: C.green, width: 1.5) : BorderSide.none),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: x.mandatory ? null : () => setState(() => on ? enr.remove(x.id) : enr.add(x.id)),
          child: SizedBox(
            height: 46,
            width: double.infinity,
            child: Center(child: Text(x.mandatory ? 'Terdaftar otomatis (wajib)' : on ? 'Terdaftar ✓ · Batalkan' : 'Daftar Training', style: ts(14, w: FontWeight.w700, c: x.mandatory ? const Color(0xFF3D4B5E) : on ? C.greenFg : Colors.white))),
          ),
        ),
      ),
    ]);
  }

  Widget _pastCard(_Past p) => _card(C.line, [
        Wrap(children: [_cat(p.cat)]),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(p.title, style: ts(15, w: FontWeight.w700, h: 1.35)), Text(p.trainer, style: ts(12, c: C.muted, h: 1.35))]),
        Column(children: [
          _mi('calendar', [TextSpan(text: p.when)]),
          const Gap(5),
          _mi('building', [TextSpan(text: '${p.room} ')]),
        ]),
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: C.greenBg, borderRadius: BorderRadius.circular(99)), child: Text(p.result, style: ts(12, w: FontWeight.w700, c: C.greenFg))),
          const Gap(0, w: 8),
          Expanded(child: Text(p.cert, style: ts(12, c: C.muted))),
          InkWell(onTap: () => toast(context, 'Mengunduh sertifikat (demo)'), child: Container(constraints: const BoxConstraints(minHeight: 40), alignment: Alignment.center, child: Text('Sertifikat', style: ts(13, w: FontWeight.w700, c: C.blue)))),
        ]),
      ]);

  @override
  Widget build(BuildContext context) {
    final mine = sched.where((x) => enr.contains(x.id)).toList();
    final tabs = [('sched', 'Jadwal'), ('mine', 'Training Saya (${mine.length})'), ('hist', 'Riwayat')];
    final children = <Widget>[];
    if (tab == 'hist') {
      children.add(Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: C.navy, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [_st('5', 'Training 2026'), const Gap(0, w: 6), _st('32 j', 'Jam belajar'), const Gap(0, w: 6), _st('4', 'Sertifikat aktif')]),
      ));
      for (final p in past) {
        children.add(_pastCard(p));
      }
    } else {
      final src = tab == 'mine' ? mine : sched;
      for (final x in src) {
        children.add(_train(x));
      }
      if (src.isEmpty) children.add(Padding(padding: const EdgeInsets.only(top: 40), child: Center(child: Text('Belum ada training yang Anda ikuti. Pilih dari tab Jadwal.', textAlign: TextAlign.center, style: ts(14, c: C.muted)))));
      if (tab == 'sched') children.add(Padding(padding: const EdgeInsets.fromLTRB(2, 4, 2, 0), child: Text('Jadwal training dan pemesanan ruangan dibuat penyelenggara di web AKPSatu. Ruangan dikonfirmasi oleh GA.', style: ts(12, c: C.muted, h: 1.5))));
    }
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
            child: Row(children: [const BackBtn(label: 'Kembali ke beranda'), const Gap(0, w: 4), Expanded(child: Text('Learning Center', style: ts(18, w: FontWeight.w800)))]),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: C.line))),
            child: Seg(tabs: [for (final t in tabs) t.$2], index: tabs.indexWhere((t) => t.$1 == tab), onChange: (i) => setState(() => tab = tabs[i].$1), gap: 4),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              child: Column(children: [for (var i = 0; i < children.length; i++) ...[if (i > 0) const Gap(10), children[i]]]),
            ),
          ),
        ]),
      ),
    );
  }
}
