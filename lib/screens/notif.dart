import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

class _N {
  final String group, title, body, time, route, icon;
  final Color bg, fg;
  bool unread;
  _N(this.group, this.title, this.body, this.time, this.route, this.icon, this.bg, this.fg, this.unread);
}

class NotifScreen extends StatefulWidget {
  const NotifScreen({super.key});
  @override
  State<NotifScreen> createState() => _NotifScreenState();
}

class _NotifScreenState extends State<NotifScreen> {
  bool onlyUnread = false;

  static const _bus = 'M4 3h16v15H4zM4 11h16M7 18v3M17 18v3';
  static const _plane = 'M17.8 19.2L16 11l3.5-3.5C21 6 21.5 4 21 3c-1-.5-3 0-4.5 1.5L13 8 4.8 6.2c-.5-.1-.9.1-1.1.5l-.3.5c-.2.5-.1 1 .3 1.3L9 12l-2 3H4l-1 1 3 2 2 3 1-1v-3l3-2 3.5 5.3c.3.4.8.5 1.3.3l.5-.2c.4-.3.6-.7.5-1.2z';
  static const _heart = 'M12 20s-8-5.2-8-11a4.5 4.5 0 0 1 8-2.8A4.5 4.5 0 0 1 20 9c0 5.8-8 11-8 11z';
  static const _qr = 'M3 3h7v7H3zM14 3h7v7h-7zM3 14h7v7H3zM14 14h3v3h-3zM17 17h4v4h-4z';
  static const _cal = 'M3 5h18v16H3zM3 10h18M8 3v4M16 3v4';
  static const _home = 'M4 21V5h11v16M15 9h5v12M3 21h18M8 8h3M8 12h3M8 16h3';

  final items = [
    _N('HARI INI', 'Jemputan cuti terkonfirmasi', 'Sen, 5 Okt · jemput 05:30 di Lobby Mess Blok C. Unit BUS-07, kursi 14, driver Rahmat Hidayat.', '20:10', R.perjalanan, _bus, const Color(0xFFE6EEFD), const Color(0xFF1E5BD7), true),
    _N('HARI INI', 'E-tiket pesawat terbit', 'KDI → UPG, 5 Okt 09:40 · kursi 12A. Kode booking K7P2QD.', '18:32', R.perjalanan, _plane, const Color(0xFFEFE9FD), const Color(0xFF5B32B8), true),
    _N('HARI INI', 'Jatah makan malam tersedia', 'Kantin buka 17:30 – 20:30. Tunjukkan QR di kiosk.', '17:30', R.makan, _qr, const Color(0xFFE2F4E8), const Color(0xFF1A6B3A), false),
    _N('HARI INI', 'PTW-0047 perlu revisi', 'HSE Officer meminta lampiran gambar jalur utilitas untuk penggalian kabel FO ke Pos 2.', '13:20', R.ptw, 'M6 3h9l4 4v14H6zM15 3v4h4M12 11v4M12 18h.01', const Color(0xFFFDE8E8), const Color(0xFFB42318), true),
    _N('HARI INI', 'Ditugaskan training wajib', 'Cyber Security Awareness · Sel, 13 Okt 09:00 · Ruang Meeting Lt. 2.', '12:05', R.learning, 'M2 8l10-5 10 5-10 5zM6 10v5c2 2 10 2 12 0v-5', const Color(0xFFEFE9FD), const Color(0xFF5B32B8), true),
    _N('HARI INI', '6 pengajuan menunggu persetujuan', 'Agus Salim mengajukan Cuti Tahunan 12 – 14 Okt. Tinjau sebelum diteruskan ke HR.', '11:42', R.approval, 'M9 11l3 3 8-8M20 12v7a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h9', const Color(0xFFE3E8EF), const Color(0xFF0E2A47), true),
    _N('HARI INI', 'Isi Fit To Work', 'FTW hari ini belum diisi. Isi sebelum shift dimulai.', '06:00', R.ftw, _heart, const Color(0xFFFDE8E8), const Color(0xFFB42318), true),
    _N('KEMARIN', 'Info mess diperbarui', 'Jadwal laundry Blok C: Senin & Kamis, ambil 17:00.', '15:20', R.camp, _home, const Color(0xFFE3E8EF), const Color(0xFF0E2A47), false),
    _N('KEMARIN', 'Lumpsum cuti ditransfer', 'Rp 1.750.000 ke BRI •••• 4521 untuk Cuti Roster 5 – 11 Okt. Lihat rinciannya di itinerary.', '10:15', R.itinerary, 'M3 7h18v12H3zM3 11h18M7 15h3', const Color(0xFFE2F4E8), const Color(0xFF1A6B3A), true),
    _N('KEMARIN', 'Pengajuan cuti diteruskan', 'Cuti 19 – 21 Okt menunggu persetujuan atasan.', '09:05', R.cuti, _cal, const Color(0xFFFFF1E0), const Color(0xFFC2610C), false),
  ];

  int get unread => items.where((e) => e.unread).length;

  Widget _pill(String t, bool on, VoidCallback tap) => Material(
        color: on ? C.blue : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99), side: BorderSide(color: on ? C.blue : C.input)),
        child: InkWell(
          borderRadius: BorderRadius.circular(99),
          onTap: tap,
          child: Container(height: 40, padding: const EdgeInsets.symmetric(horizontal: 16), alignment: Alignment.center, child: Text(t, style: ts(13, w: on ? FontWeight.w700 : FontWeight.w600, c: on ? Colors.white : C.text2))),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final list = items.where((e) => !onlyUnread || e.unread).toList();
    String? last;
    final children = <Widget>[];
    for (final n in list) {
      if (children.isNotEmpty) children.add(const Gap(8));
      final card = Material(
        color: n.unread ? const Color(0xFFF5F8FE) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: n.unread ? const Color(0xFFC9D8F5) : C.line)),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() => n.unread = false);
            Navigator.pushNamed(context, n.route);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: n.bg, borderRadius: BorderRadius.circular(12)), child: Center(child: Ic.path(n.icon, color: n.fg))),
              const Gap(0, w: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(child: Text(n.title, style: ts(14, w: FontWeight.w700, h: 1.45))),
                    const Gap(0, w: 8),
                    Text(n.time, style: ts(11, c: C.muted, h: 1.45)),
                  ]),
                  Text(n.body, style: ts(13, c: C.text2, h: 1.45)),
                ]),
              ),
              if (n.unread) ...[const Gap(0, w: 12), Padding(padding: const EdgeInsets.only(top: 6), child: Container(width: 9, height: 9, decoration: const BoxDecoration(color: C.blue, shape: BoxShape.circle)))],
            ]),
          ),
        ),
      );
      children.add(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (n.group != last) ...[
          Padding(padding: const EdgeInsets.fromLTRB(4, 8, 4, 0), child: Text(n.group, style: ts(12, w: FontWeight.w800, c: C.muted).copyWith(letterSpacing: .4))),
          const Gap(8),
        ],
        card,
      ]));
      last = n.group;
    }
    if (list.isEmpty) children.add(Padding(padding: const EdgeInsets.only(top: 48), child: Center(child: Text('Semua notifikasi sudah dibaca.', style: ts(14, c: C.muted)))));
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(children: [
          PageHeader('Notifikasi',
              border: false,
              trailing: InkWell(
                onTap: () => setState(() {
                  for (final n in items) {
                    n.unread = false;
                  }
                }),
                child: Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.symmetric(horizontal: 8), alignment: Alignment.center, child: Text('Tandai semua dibaca', style: ts(13, w: FontWeight.w700, c: C.blue))),
              )),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: C.line))),
            child: Row(children: [_pill('Semua', !onlyUnread, () => setState(() => onlyUnread = false)), const Gap(0, w: 8), _pill('Belum dibaca ($unread)', onlyUnread, () => setState(() => onlyUnread = true))]),
          ),
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), child: Column(children: children))),
        ]),
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
