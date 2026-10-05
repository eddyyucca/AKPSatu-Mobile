import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

class _N {
  final String group, title, body, time, route;
  final IconData icon;
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
  final items = [
    _N('HARI INI', 'Jemputan cuti terkonfirmasi', 'Sen, 5 Okt · jemput 05:30 di Lobby Mess Blok C. Unit BUS-07, kursi 14, driver Rahmat Hidayat.', '20:10', R.perjalanan, Icons.directions_bus_outlined, C.blueSoft, C.blue, true),
    _N('HARI INI', 'E-tiket pesawat terbit', 'KDI → UPG, 5 Okt 09:40 · kursi 12A. Kode booking K7P2QD.', '18:32', R.perjalanan, Icons.flight, C.purpleBg, C.purple, true),
    _N('HARI INI', 'Jatah makan malam tersedia', 'Kantin buka 17:30 – 20:30. Tunjukkan QR di kiosk.', '17:30', R.home, Icons.qr_code_2, C.greenBg, C.greenFg, false),
    _N('HARI INI', 'PTW-0047 perlu revisi', 'HSE Officer meminta lampiran gambar jalur utilitas untuk penggalian kabel FO ke Pos 2.', '13:20', R.ptw, Icons.assignment_late_outlined, C.redBg, C.red, true),
    _N('HARI INI', 'Ditugaskan training wajib', 'Cyber Security Awareness · Sel, 13 Okt 09:00 · Ruang Meeting Lt. 2.', '12:05', R.learning, Icons.school_outlined, C.purpleBg, C.purple, true),
    _N('HARI INI', '6 pengajuan menunggu persetujuan', 'Agus Salim mengajukan Cuti Tahunan 12 – 14 Okt. Tinjau sebelum diteruskan ke HR.', '11:42', R.approval, Icons.fact_check_outlined, C.chip, C.navy, true),
    _N('HARI INI', 'Isi Fit To Work', 'FTW hari ini belum diisi. Isi sebelum shift dimulai.', '06:00', R.ftw, Icons.monitor_heart_outlined, C.redBg, C.red, true),
    _N('KEMARIN', 'Lembur disetujui', 'Lembur 3 Okt 19:00 – 22:00 (3 jam) disetujui Rudi Hartono.', '16:20', R.pengajuanLembur, Icons.timer_outlined, C.blueSoft, C.blueFg, false),
    _N('KEMARIN', 'Jadwal roster diperbarui', 'Jadwal 2 – 15 Nov diperbarui Admin Roster.', '16:05', R.roster, Icons.calendar_month_outlined, C.tealBg, C.teal, false),
  ];

  int get unread => items.where((e) => e.unread).length;

  @override
  Widget build(BuildContext context) {
    final list = items.where((e) => !onlyUnread || e.unread).toList();
    String? last;
    final children = <Widget>[];
    for (final n in list) {
      if (n.group != last) {
        children.add(SectionLabelLeft2(n.group));
        last = n.group;
      }
      children.add(Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AppCard(
          color: n.unread ? const Color(0xFFF5F8FE) : Colors.white,
          border: n.unread ? const Color(0xFFC9D8F5) : C.line,
          onTap: () {
            setState(() => n.unread = false);
            if (n.route == R.home) return;
            Navigator.pushNamed(context, n.route);
          },
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            IconBox(n.icon, n.bg, n.fg, size: 42),
            const Gap(0, w: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(n.title, style: ts(14, w: n.unread ? FontWeight.w800 : FontWeight.w600))),
                  Text(n.time, style: ts(12, c: C.muted)),
                ]),
                const Gap(2),
                Text(n.body, style: ts(13, c: C.text2, h: 1.4)),
              ]),
            ),
            if (n.unread) Padding(padding: const EdgeInsets.only(left: 8, top: 4), child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: C.blue, shape: BoxShape.circle))),
          ]),
        ),
      ));
    }
    if (list.isEmpty) children.add(Padding(padding: const EdgeInsets.all(32), child: Center(child: Text('Semua notifikasi sudah dibaca.', style: ts(14, c: C.muted)))));
    return SubPage(
      title: 'Notifikasi',
      actions: [TextButton(onPressed: () => setState(() { for (final n in items) { n.unread = false; } }), child: Text('Tandai semua dibaca', style: ts(12, w: FontWeight.w700, c: C.blue)))],
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        FilterChips(items: ['Semua', 'Belum dibaca ($unread)'], value: onlyUnread ? 'Belum dibaca ($unread)' : 'Semua', onChange: (v) => setState(() => onlyUnread = v != 'Semua')),
        const Gap(12),
        ...children,
      ]),
    );
  }
}

class SectionLabelLeft2 extends StatelessWidget {
  final String t;
  const SectionLabelLeft2(this.t, {super.key});
  @override
  Widget build(BuildContext context) => Align(alignment: Alignment.centerLeft, child: SectionLabel(t));
}

class NotifPushScreen extends StatelessWidget {
  const NotifPushScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Widget push(String time, String title, String body) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .92), borderRadius: BorderRadius.circular(18)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Logo(size: 38),
            const Gap(0, w: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Text('AKPSatu', style: ts(12, c: C.muted)), const Spacer(), Text(time, style: ts(12, c: C.muted))]),
                Text(title, style: ts(14, w: FontWeight.w800)),
                Text(body, style: ts(13, c: C.text2, h: 1.4)),
              ]),
            ),
          ]),
        );
    return Scaffold(
      backgroundColor: C.navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Align(alignment: Alignment.centerLeft, child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white))),
            const Gap(24),
            Text('05:02', style: ts(64, w: FontWeight.w300, c: Colors.white)),
            Text('Senin, 5 Oktober', style: ts(16, c: C.pale)),
            const Gap(32),
            push('sekarang', 'Jemputan tiba dalam 30 menit', 'BUS-07 (DT 7421 KB) · kursi 14 · driver Rahmat Hidayat. Kumpul di Lobby Mess Blok C pukul 05:30.'),
            push('04:30', 'Pengingat penerbangan', 'XX 1234 KDI → UPG berangkat 09:40, kursi 12A. Siapkan e-tiket dan KTP.'),
            push('kemarin', 'Selamat menikmati masa off', 'Off 5 – 11 Okt. Kembali Night shift 12 Okt, jemputan bandara 11 Okt 08:45.'),
            const Spacer(),
            Text('Geser ke atas untuk membuka', style: ts(12, c: C.pale)),
          ]),
        ),
      ),
    );
  }
}
