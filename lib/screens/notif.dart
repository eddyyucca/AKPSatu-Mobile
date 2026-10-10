import 'package:flutter/material.dart' hide Text;
import '../api/api.dart';
import '../api/notifications.dart';
import '../l10n/lang.dart';
import '../refresh.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

class NotifScreen extends StatefulWidget {
  const NotifScreen({super.key});
  @override
  State<NotifScreen> createState() => _NotifScreenState();
}

class _NotifScreenState extends State<NotifScreen> {
  final center = NotificationCenter.instance;
  bool onlyUnread = false;

  @override
  void initState() {
    super.initState();
    if (Session.instance.active) center.load();
  }

  /// Layar tujuan saat notifikasi diketuk; kosong = hanya ditandai dibaca.
  static String _target(AppNotification n) => switch (n.route) {
        'overtime' => R.pengajuanLembur,
        _ => '',
      };

  /// Ikon dan warna per jenis notifikasi.
  static (String, Color, Color) _style(String type) => switch (type) {
        'overtime.approved' => ('overtime', C.greenBg, C.greenFg),
        'overtime.rejected' => ('overtime', C.redBg, C.red),
        _ => ('bell', C.blueSoft, C.blue),
      };

  /// HARI INI / KEMARIN / tanggal.
  static String _group(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final diff = today.difference(day).inDays;
    return diff <= 0 ? 'HARI INI' : (diff == 1 ? 'KEMARIN' : L.instance.shortDate(day));
  }

  static String _time(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  Widget _pill(String t, bool on, VoidCallback tap) => Material(
        color: on ? C.blue : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99), side: BorderSide(color: on ? C.blue : C.input)),
        child: InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: tap,
          child: Container(height: 40, padding: const EdgeInsets.symmetric(horizontal: 16), alignment: Alignment.center, child: Text(t, style: ts(13, w: on ? FontWeight.w700 : FontWeight.w600, c: on ? Colors.white : C.text2))),
        ),
      );

  Widget _card(AppNotification n) {
    final (icon, bg, fg) = _style(n.type);
    return Material(
      color: n.read ? Colors.white : const Color(0xFFF5F8FE),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: n.read ? C.line : const Color(0xFFC9D8F5))),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          center.markRead(n);
          final route = _target(n);
          if (route.isNotEmpty) Navigator.pushNamed(context, route);
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)), child: Center(child: Ic(icon, color: fg))),
            const Gap(0, w: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Text(n.title, style: ts(14, w: FontWeight.w700, h: 1.45))),
                  const Gap(0, w: 8),
                  Text(_time(n.createdAt), style: ts(11, c: C.muted, h: 1.45)),
                ]),
                Text(n.body, style: ts(13, c: C.text2, h: 1.45)),
              ]),
            ),
            if (!n.read) ...[const Gap(0, w: 12), Padding(padding: const EdgeInsets.only(top: 6), child: Container(width: 9, height: 9, decoration: const BoxDecoration(color: C.blue, shape: BoxShape.circle)))],
          ]),
        ),
      ),
    );
  }

  List<Widget> _body() {
    if (!Session.instance.active) return [const Notice('Masuk terlebih dahulu untuk melihat notifikasi.')];
    if (center.loading && center.items.isEmpty) {
      return [const Padding(padding: EdgeInsets.only(top: 48), child: Center(child: CircularProgressIndicator()))];
    }
    if (center.error != null && center.items.isEmpty) {
      return [
        Padding(padding: const EdgeInsets.only(top: 32), child: Text(center.error!, textAlign: TextAlign.center, style: ts(14, c: C.red, h: 1.5))),
        const Gap(12),
        PrimaryButton('Coba lagi', onTap: center.load),
      ];
    }

    final list = center.items.where((e) => !onlyUnread || !e.read).toList();
    if (list.isEmpty) {
      return [Padding(padding: const EdgeInsets.only(top: 48), child: Center(child: Text(center.items.isEmpty ? 'Belum ada notifikasi.' : 'Semua notifikasi sudah dibaca.', style: ts(14, c: C.muted))))];
    }

    final out = <Widget>[];
    String? last;
    for (final n in list) {
      final g = _group(n.createdAt);
      if (out.isNotEmpty) out.add(const Gap(8));
      out.add(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (g != last) ...[
          Padding(padding: const EdgeInsets.fromLTRB(4, 8, 4, 0), child: Text(g, style: ts(12, w: FontWeight.w800, c: C.muted).copyWith(letterSpacing: .4))),
          const Gap(8),
        ],
        _card(n),
      ]));
      last = g;
    }
    if (center.hasMore && !onlyUnread) {
      out.add(const Gap(12));
      out.add(OutlineButton(center.loading ? 'Memuat...' : 'Muat lebih lama', onTap: center.loading ? null : center.loadMore));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    L.watch(context);
    return ListenableBuilder(
      listenable: center,
      builder: (context, _) => Scaffold(
        backgroundColor: C.bg,
        body: SafeArea(
          child: Column(children: [
            PageHeader('Notifikasi',
                border: false,
                trailing: center.unread == 0
                    ? null
                    : InkWell(
                        onTap: center.markAllRead,
                        child: Container(constraints: const BoxConstraints(minHeight: 44, maxWidth: 112), padding: const EdgeInsets.symmetric(horizontal: 8), alignment: Alignment.center, child: Text('Tandai semua dibaca', textAlign: TextAlign.right, style: ts(13, w: FontWeight.w700, c: C.blue, h: 1.25))),
                      )),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: C.line))),
              child: Wrap(spacing: 8, runSpacing: 8, children: [_pill('Semua', !onlyUnread, () => setState(() => onlyUnread = false)), _pill('Belum dibaca (${center.unread})', onlyUnread, () => setState(() => onlyUnread = true))]),
            ),
            Expanded(
              child: PullToRefresh(
                onRefresh: Session.instance.active ? center.load : () async {},
                child: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: _body())),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class NotifPushScreen extends StatelessWidget {
  const NotifPushScreen({super.key});

  Widget _push(BuildContext context, String route, String time, String title, String body) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: const Color(0xEBFFFFFF),
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.pushNamed(context, route),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Logo(size: 22),
                  const Gap(0, w: 8),
                  Text('AKPSatu', style: ts(12, w: FontWeight.w700, c: C.text2)),
                  const Spacer(),
                  Text(time, style: ts(12, c: C.muted)),
                ]),
                const Gap(4),
                Text(title, style: ts(15, w: FontWeight.w700)),
                const Gap(4),
                Text(body, style: ts(14, c: C.text2, h: 1.4)),
              ]),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: C.navy,
        body: Padding(
            padding: const EdgeInsets.fromLTRB(14, 56, 14, 28),
            child: ScrollFill(child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Column(children: [
                  const Ic('lock', color: C.pale),
                  const Gap(4),
                  const Gap(8),
                  Text('05:02', style: ts(80, w: FontWeight.w300, c: Colors.white, h: 1.05).copyWith(letterSpacing: -2)),
                  const Gap(4),
                  Text('Senin, 5 Oktober', style: ts(17, w: FontWeight.w500, c: const Color(0xFFD3DEEC))),
                ]),
              ),
              const Spacer(),
              _push(context, R.perjalanan, 'sekarang', 'Jemputan tiba dalam 30 menit', 'BUS-07 (DT 7421 KB) · kursi 14 · driver Rahmat Hidayat. Kumpul di Lobby Mess Blok C pukul 05:30.'),
              _push(context, R.perjalanan, '04:30', 'Pengingat penerbangan', 'XX 1234 KDI → UPG berangkat 09:40, kursi 12A. Siapkan e-tiket dan KTP.'),
              _push(context, R.roster, 'kemarin', 'Selamat menikmati masa off', 'Off 5 – 11 Okt. Kembali Night shift 12 Okt, jemputan bandara 11 Okt 08:45.'),
              const Gap(18),
              Text('Geser ke atas untuk membuka', style: ts(13, c: C.pale)),
              const Gap(18),
              Semantics(
                button: true,
                label: 'Tutup',
                child: GestureDetector(onTap: () => Navigator.maybePop(context), child: Container(width: 134, height: 5, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)))),
              ),
            ])),
          ),
      );
}
