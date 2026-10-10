import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' hide Text;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../api/api.dart';
import '../l10n/lang.dart';
import '../api/banners.dart';
import '../api/notifications.dart';
import '../pattern.dart';
import '../refresh.dart';
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

  /// Tarik ke bawah: perbarui jabatan di sesi, banner, dan absensi hari ini.
  Future<void> _refresh() async {
    if (Session.instance.active) await Api.instance.loadSummary();
    await Refresh.run();
  }

  @override
  Widget build(BuildContext context) {
    void go(String r) => Navigator.pushNamed(context, r);
    return ValueListenableBuilder<int>(
      valueListenable: Refresh.rev,
      builder: (context, _, _) => PullToRefresh(
        onRefresh: _refresh,
        child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(children: [
        BrandHeader(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 76),
          child: Column(children: [
            Row(children: [
              const Logo(size: 34),
              const Gap(0, w: 10),
              Expanded(child: Text('AKPSatu', style: ts(18, w: FontWeight.w800, c: Colors.white))),
              ListenableBuilder(
                listenable: NotificationCenter.instance,
                builder: (context, _) {
                  final n = NotificationCenter.instance.unread;
                  return Semantics(
                    button: true,
                    label: n > 0 ? tr('Notifikasi, $n belum dibaca') : tr('Notifikasi'),
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
                            if (n > 0)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  constraints: const BoxConstraints(minWidth: 18),
                                  height: 18,
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(color: const Color(0xFFD64545), borderRadius: BorderRadius.circular(9), border: Border.all(color: C.navy, width: 2)),
                                  child: Text(n > 99 ? '99+' : '$n', style: ts(11, w: FontWeight.w800, c: Colors.white)),
                                ),
                              ),
                          ]),
                        ),
                      ),
                    ),
                  );
                },
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
                  child: Text(Session.instance.name.isEmpty ? 'EA' : Session.instance.initials, style: ts(16, w: FontWeight.w800, c: C.blueFg)),
                ),
              ),
              const Gap(0, w: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Selamat datang,', style: ts(13, c: C.pale, h: 1.35)),
                  Text(Session.instance.nameOr('Eddy Adha Saputra'), maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(18, w: FontWeight.w800, c: Colors.white, h: 1.35)),
                  Text(Session.instance.name.isEmpty ? '32601949 · Supervisor IT' : [Session.instance.nik, if (Session.instance.user['position'] != null) Session.instance.user['position']].join(' · '), maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(12, c: C.pale, h: 1.35)),
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
              TodayAttendance(
                builder: (t) => _card(
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(t.dateLabel, style: ts(12, c: C.muted)),
                        Text(t.hoursLabel, style: ts(15, w: FontWeight.w700)),
                      ])),
                      Pill(t.status, tone: t.ok ? Tone.ok : Tone.warn),
                    ]),
                    const Gap(12),
                    Row(children: [_time('Masuk', t.inTime), const Gap(0, w: 10), _time('Pulang', t.outTime)]),
                  ]),
                ),
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
    ),
      ),
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
  List<PromoItem> live = const []; // banner dari Portal (disimpan di perangkat); kosong = tampilan contoh

  int get _count => live.isNotEmpty ? live.length : _promos.length;

  @override
  void initState() {
    super.initState();
    Refresh.add(_loadBanners);
    timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!ctrl.hasClients || _count < 2) return;
      ctrl.animateToPage((i + 1) % _count, duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
    });
    _loadBanners();
  }

  /// Tampilkan banner tersimpan dulu (langsung, tanpa jaringan), lalu cek perubahan ke Portal.
  Future<void> _loadBanners() async {
    if (!Session.instance.active) return;
    final cached = await BannerStore.instance.cached();
    if (mounted && cached.isNotEmpty) setState(() => live = cached);
    final fresh = await BannerStore.instance.refresh();
    if (mounted && fresh != null) {
      setState(() {
        live = fresh;
        i = 0;
      });
      if (ctrl.hasClients) ctrl.jumpToPage(0);
    }
  }

  Future<void> _open(PromoItem p) async {
    final uri = Uri.tryParse(p.linkUrl);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// Kartu banner dari Portal: gambar + teks di atas lapisan gelap.
  Widget _liveCard(PromoItem p) => Semantics(
        button: p.linkUrl.isNotEmpty,
        label: p.title,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: C.navy,
            child: InkWell(
              onTap: p.linkUrl.isEmpty ? null : () => _open(p),
              child: Stack(fit: StackFit.expand, children: [
                if (p.imageUrl.isNotEmpty) _BannerImage(key: ValueKey(p.imageUrl), url: p.imageUrl),
                const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00000000), Color(0xCC0E1C38)]))),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text(p.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: ts(17, w: FontWeight.w800, c: Colors.white, h: 1.25)),
                    if (p.subtitle.isNotEmpty) ...[const Gap(4), Text(p.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: ts(12, c: const Color(0xFFDCE7FB), h: 1.4))],
                    if (p.linkUrl.isNotEmpty) ...[const Gap(6), Text('${p.linkLabel.isEmpty ? 'Selengkapnya' : p.linkLabel} →', style: ts(12, w: FontWeight.w700, c: Colors.white))],
                  ]),
                ),
              ]),
            ),
          ),
        ),
      );

  @override
  void dispose() {
    Refresh.remove(_loadBanners);
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
            itemCount: _count,
            onPageChanged: (v) => setState(() => i = v),
            itemBuilder: (_, k) {
              if (live.isNotEmpty) return _KeepAlive(key: ValueKey(live[k].imageUrl), child: _liveCard(live[k]));
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
          for (var k = 0; k < _count; k++) ...[
            if (k > 0) const Gap(0, w: 5),
            Container(width: k == i ? 16 : 6, height: 6, decoration: BoxDecoration(color: k == i ? C.blue : const Color(0xFFC4CDD9), borderRadius: BorderRadius.circular(3))),
          ],
        ]),
      ]);
}


/// Isi kartu "hari ini" di beranda.
class TodayInfo {
  final String dateLabel, hoursLabel, status, inTime, outTime;
  final bool ok;
  const TodayInfo(this.dateLabel, this.hoursLabel, this.status, this.inTime, this.outTime, this.ok);
}

/// Absensi hari ini milik karyawan yang login (dari HRIS). Tanpa sesi, tampil data contoh.
class TodayAttendance extends StatefulWidget {
  final Widget Function(TodayInfo info) builder;
  const TodayAttendance({super.key, required this.builder});
  @override
  State<TodayAttendance> createState() => _TodayAttendanceState();
}

class _TodayAttendanceState extends State<TodayAttendance> {
  Future<Map<String, dynamic>>? future;

  static String _month(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}';
  static String _day(DateTime d) => '${_month(d)}-${d.day.toString().padLeft(2, '0')}';

  /// Bulan ini; bila belum ada catatan sama sekali (mis. awal bulan) ikut ambil bulan lalu agar data terakhir tetap tampil.
  Future<Map<String, dynamic>> _fetch() async {
    final n = DateTime.now();
    final cur = await Api.instance.attendance(_month(n));
    if ((cur['days'] as List).isNotEmpty) return cur;
    try {
      final prev = await Api.instance.attendance(_month(DateTime(n.year, n.month - 1, 1)));
      return {...cur, 'days': prev['days']};
    } catch (_) {
      return cur;
    }
  }

  void _load() => future = _fetch();

  Future<void> _reload() async {
    if (!Session.instance.active || !mounted) return;
    setState(_load);
    try {
      await future;
    } catch (_) {}
  }

  @override
  void initState() {
    super.initState();
    if (Session.instance.active) _load();
    Refresh.add(_reload);
  }

  @override
  void dispose() {
    Refresh.remove(_reload);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    L.watch(context);
    final l = L.instance;
    final n = DateTime.now();
    final todayLabel = l.longDate(n);
    if (future == null) return widget.builder(TodayInfo(l.longDate(DateTime(2026, 10, 4)), 'Day shift · 07:00 – 19:00', 'Hadir', '06:52', '--:--', true));

    return FutureBuilder<Map<String, dynamic>>(
      future: future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return widget.builder(TodayInfo(todayLabel, snap.hasError ? 'Absensi belum bisa dimuat' : 'Memuat absensi...', snap.hasError ? 'Offline' : '...', '--:--', '--:--', false));
        }
        final data = snap.data!;
        final hours = Map<String, dynamic>.from(data['work_hours'] as Map);
        final hoursLabel = 'Jam kerja · ${hours['start']} – ${hours['end']}';

        // Catatan hari ini; bila belum ada, catatan terakhir yang tersedia.
        final days = (data['days'] as List).map((e) => Map<String, dynamic>.from(e as Map)).toList()..sort((a, b) => (b['date'] as String).compareTo(a['date'] as String));
        final key = _day(n);
        final rec = days.where((d) => d['date'] == key).firstOrNull ?? days.firstOrNull;
        if (rec == null) return widget.builder(TodayInfo(todayLabel, hoursLabel, 'Belum absen', '--:--', '--:--', false));

        final isToday = rec['date'] == key;
        final inT = rec['in'] as String?, outT = rec['out'] as String?;
        final late = rec['late'] == true;
        final status = inT == null ? 'Belum absen' : (late ? 'Terlambat' : 'Hadir');
        final label = isToday ? todayLabel : '${l.longDate(DateTime.parse(rec['date'] as String))} · Data terakhir';
        return widget.builder(TodayInfo(label, hoursLabel, status, inT ?? '--:--', outT ?? '--:--', inT != null && !late));
      },
    );
  }
}


/// Gambar banner dari Portal: PNG/JPG/WebP atau SVG (banner bawaan Portal berupa SVG, yang tidak bisa didekode Image biasa).
/// Diunduh sekali ke penyimpanan perangkat (kunci = alamat + ?v= dari Portal), lalu dibaca dari sana.
class _BannerImage extends StatefulWidget {
  final String url;
  const _BannerImage({super.key, required this.url});
  @override
  State<_BannerImage> createState() => _BannerImageState();
}

class _BannerImageState extends State<_BannerImage> {
  late final Future<Widget?> image = _load();

  Future<Widget?> _load() async {
    try {
      final Uint8List bytes;
      if (kIsWeb) {
        final res = await http.get(Uri.parse(widget.url));
        if (res.statusCode != 200) return null;
        bytes = res.bodyBytes;
      } else {
        bytes = await (await DefaultCacheManager().getSingleFile(widget.url)).readAsBytes();
      }
      final head = utf8.decode(bytes.take(1024).toList(), allowMalformed: true).toLowerCase();
      return head.contains('<svg') ? SvgPicture.memory(bytes, fit: BoxFit.cover) : Image.memory(bytes, fit: BoxFit.cover, gaplessPlayback: true);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Widget?>(
        future: image,
        builder: (_, snap) => snap.data ?? const ColoredBox(color: C.navy),
      );
}

/// Menjaga halaman PageView tetap hidup di luar layar, supaya gambar tidak dimuat ulang (dan hilang) saat digeser.
class _KeepAlive extends StatefulWidget {
  final Widget child;
  const _KeepAlive({super.key, required this.child});
  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
