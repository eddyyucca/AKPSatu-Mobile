import 'dart:async';
import 'package:flutter/material.dart';
import '../pattern.dart';
import '../routes.dart';
import 'menu_section.dart';
import '../theme.dart';
import '../widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _time(String l, String v) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: C.bg, borderRadius: BorderRadius.circular(10)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l, style: ts(12, c: C.muted)),
            Text(v, style: ts(20, w: FontWeight.w800)),
          ]),
        ),
      );

  Widget _card({required Widget child, VoidCallback? onTap, Color color = Colors.white, Color border = C.line}) => Material(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: border)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.all(16), child: child)),
      );

  Widget _link(BuildContext context, String route, {required Widget icon, required String k, required String t, required String s, Color color = Colors.white, Color border = C.line}) => _card(
        onTap: () => Navigator.pushNamed(context, route),
        color: color,
        border: border,
        child: Row(children: [
          if (icon is! SizedBox) ...[icon, const Gap(0, w: 12)],
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(k, style: ts(12, c: C.muted, h: 1.45)),
              Text(t, style: ts(14, w: FontWeight.w700, h: 1.45)),
              Text(s, style: ts(13, c: C.muted, h: 1.45)),
            ]),
          ),
          const Gap(0, w: 12),
          const Ic('chevron', size: 20, color: C.muted, stroke: 2),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    void go(String r) => Navigator.pushNamed(context, r);
    return SingleChildScrollView(
      child: Column(children: [
        BrandHeader(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 76),
          child: Column(children: [
            Row(children: [
              const Logo(size: 34),
              const Gap(0, w: 10),
              Expanded(child: Text('AKPSatu', style: ts(18, w: FontWeight.w800, c: Colors.white))),
              Semantics(
                button: true,
                label: 'Notifikasi, 7 belum dibaca',
                child: Material(
                  color: C.navy2,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => go(R.notifikasi),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Stack(alignment: Alignment.center, children: [
                        const Ic('bell', color: Colors.white),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            constraints: const BoxConstraints(minWidth: 18),
                            height: 18,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: const Color(0xFFD64545), borderRadius: BorderRadius.circular(9), border: Border.all(color: C.navy, width: 2)),
                            child: Text('7', style: ts(11, w: FontWeight.w800, c: Colors.white)),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
            ]),
            const Gap(16),
            Row(children: [
              InkWell(
                customBorder: const CircleBorder(),
                onTap: () => go(R.profil),
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: Color(0xFFDCE7FB), shape: BoxShape.circle),
                  child: Text('EA', style: ts(16, w: FontWeight.w800, c: C.blueFg)),
                ),
              ),
              const Gap(0, w: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Selamat datang,', style: ts(13, c: C.pale, h: 1.35)),
                  Text('Eddy Adha Saputra', style: ts(18, w: FontWeight.w800, c: Colors.white, h: 1.35)),
                  Text('32601949 · Supervisor IT', style: ts(12, c: C.pale, h: 1.35)),
                ]),
              ),
            ]),
          ]),
        ),
        PullUp(
          by: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: [
              _card(
                child: Column(children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Minggu, 4 Oktober 2026', style: ts(12, c: C.muted)),
                      Text('Day shift · 07:00 – 19:00', style: ts(15, w: FontWeight.w700)),
                    ])),
                    const Pill('Hadir', tone: Tone.ok),
                  ]),
                  const Gap(12),
                  Row(children: [_time('Masuk', '06:52'), const Gap(0, w: 10), _time('Pulang', '--:--')]),
                ]),
              ),
              const Gap(14),
              Material(
                color: C.navy,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => go(R.approval),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: C.blue, borderRadius: BorderRadius.circular(10)),
                        child: const Center(child: Ic('approve', size: 22, color: Colors.white)),
                      ),
                      const Gap(0, w: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('6 pengajuan menunggu persetujuan', style: ts(14, w: FontWeight.w700, c: Colors.white, h: 1.4)),
                          Text('2 cuti · 3 lembur · 1 PTW', style: ts(12, c: C.pale, h: 1.4)),
                        ]),
                      ),
                      const Gap(0, w: 12),
                      Text('Tinjau', style: ts(13, w: FontWeight.w700, c: const Color(0xFF8FB0EE))),
                    ]),
                  ),
                ),
              ),
              const Gap(14),
              const PromoBanner(),
              const Gap(14),
              const MenuSection(),
              const Gap(14),
              _link(context, R.myActivity,
                  icon: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: C.redBg, borderRadius: BorderRadius.circular(10)),
                    child: Text('3', style: ts(16, w: FontWeight.w800, c: C.red)),
                  ),
                  k: 'My Activity · IT Department',
                  t: '3 perlu follow-up',
                  s: 'Lisensi antivirus jatuh tempo 15 Okt'),
              const Gap(14),
              _link(context, R.itinerary,
                  color: const Color(0xFFF5F8FE),
                  border: const Color(0xFFC9D8F5),
                  icon: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: C.blue, borderRadius: BorderRadius.circular(10)),
                    child: const Center(child: Ic('busfront', size: 22, color: Colors.white)),
                  ),
                  k: 'Itinerary cuti · besok, Sen 5 Okt',
                  t: 'Jemput 05:30 · BUS-07 · Kursi 14',
                  s: 'Pesawat KDI → UPG 09:40 · lumpsum sudah ditransfer'),
              const Gap(14),
              _link(context, R.roster, icon: const SizedBox(), k: 'Jadwal kerja', t: 'Day shift sampai hari ini', s: 'Off 5 – 11 Okt · Night mulai 12 Okt'),
              const Gap(14),
              TextButton(onPressed: () => go(R.notifPush), child: Text('Lihat contoh notifikasi push (demo)', style: ts(12, c: C.muted))),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _Promo {
  final String tag, title, text, cta, route, ic;
  final List<Color> colors;
  const _Promo(this.tag, this.title, this.text, this.cta, this.route, this.ic, this.colors);
}

const _promos = [
  _Promo('KAMPANYE K3', 'Zero Harm: Pulang Selamat', 'Gunakan APD lengkap dan laporkan setiap potensi bahaya sebelum bekerja.', 'Lihat panduan', R.learning, 'ptw', [Color(0xFF1E5BD7), Color(0xFF0E2A47)]),
  _Promo('SOSIALISASI', 'Cyber Security Awareness', 'Waspada phishing. Ikuti pelatihan wajib Sel, 13 Okt pukul 09:00.', 'Daftar training', R.learning, 'learn', [Color(0xFF5B32B8), Color(0xFF1748AE)]),
  _Promo('HIDUP SEHAT', 'Isi Fit To Work Setiap Hari', 'Pastikan kondisi Anda prima sebelum shift dimulai.', 'Isi sekarang', R.ftw, 'ftw', [Color(0xFF14655F), Color(0xFF0E2A47)]),
];

/// Banner kampanye / sosialisasi karyawan (geser atau otomatis berganti).
class PromoBanner extends StatefulWidget {
  const PromoBanner({super.key});
  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  final ctrl = PageController();
  int i = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!ctrl.hasClients) return;
      ctrl.animateToPage((i + 1) % _promos.length, duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        SizedBox(
          // Tinggi mengikuti lebar layar (teks lebih sering membungkus di layar sempit) dan skala teks.
          height: (MediaQuery.sizeOf(context).width < 380 ? 168 : 140) * (MediaQuery.textScalerOf(context).scale(14) / 14),
          child: PageView.builder(
            controller: ctrl,
            itemCount: _promos.length,
            onPageChanged: (v) => setState(() => i = v),
            itemBuilder: (_, k) {
              final p = _promos[k];
              return Semantics(
                button: true,
                label: '${p.tag}: ${p.title}',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.pushNamed(context, p.route),
                    child: Ink(
                      decoration: BoxDecoration(gradient: LinearGradient(colors: p.colors, begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)),
                      child: Stack(children: [
                        Positioned(right: -14, bottom: -14, child: Opacity(opacity: .14, child: Ic(p.ic, size: 120, stroke: 1.4, color: Colors.white))),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0x33FFFFFF), borderRadius: BorderRadius.circular(6)), child: Text(p.tag, style: ts(10, w: FontWeight.w800, c: Colors.white).copyWith(letterSpacing: .6))),
                            const Gap(8),
                            Text(p.title, style: ts(17, w: FontWeight.w800, c: Colors.white, h: 1.25)),
                            const Gap(4),
                            Padding(padding: const EdgeInsets.only(right: 70), child: Text(p.text, maxLines: 2, overflow: TextOverflow.ellipsis, style: ts(12, c: const Color(0xFFDCE7FB), h: 1.4))),
                            const Spacer(),
                            Text('${p.cta} →', style: ts(12, w: FontWeight.w700, c: Colors.white)),
                          ]),
                        ),
                      ]),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const Gap(8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (var k = 0; k < _promos.length; k++) ...[
            if (k > 0) const Gap(0, w: 5),
            Container(width: k == i ? 16 : 6, height: 6, decoration: BoxDecoration(color: k == i ? C.blue : const Color(0xFFC4CDD9), borderRadius: BorderRadius.circular(3))),
          ],
        ]),
      ]);
}
