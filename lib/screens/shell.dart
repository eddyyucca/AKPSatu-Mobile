import 'dart:math';
import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';
import 'attendance.dart';
import 'home.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int i = 0;
  static const tabs = [
    (Icons.home_outlined, Icons.home, 'Beranda'),
    (Icons.access_time, Icons.access_time_filled, 'Absensi'),
    (Icons.qr_code_2, Icons.qr_code_2, 'Makan'),
    (Icons.person_outline, Icons.person, 'Profil'),
  ];

  Widget _titled(String t, Widget body) => Column(children: [
        Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Text(t, style: ts(18, w: FontWeight.w800)),
        ),
        const Divider(height: 1, color: C.line),
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: body)),
      ]);

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: C.bg,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(index: i, children: [
            const HomeTab(),
            _titled('Riwayat Absensi', const AttendanceBody()),
            _titled('Barcode Makan', const BarcodeBody()),
            _titled('Profil', const ProfileBody()),
          ]),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: C.line))),
          padding: EdgeInsets.fromLTRB(8, 6, 8, 6 + MediaQuery.of(context).padding.bottom),
          child: Row(children: [
            for (var n = 0; n < tabs.length; n++)
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => i = n),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 56),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(i == n ? tabs[n].$2 : tabs[n].$1, color: i == n ? C.blue : C.muted, size: 24),
                      const Gap(4),
                      Text(tabs[n].$3, style: ts(11, w: FontWeight.w600, c: i == n ? C.blue : C.muted)),
                    ]),
                  ),
                ),
              ),
          ]),
        ),
      );
}

class ProfileBody extends StatelessWidget {
  const ProfileBody({super.key});
  Widget _group(String title, List<(String, String)> rows) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionLabel(title),
        AppCard(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: Column(children: [for (final r in rows) KV(r.$1, r.$2, bold: false)])),
        const Gap(8),
      ]);

  @override
  Widget build(BuildContext context) => Column(children: [
        const Gap(8),
        const Avatar('BS', size: 84),
        const Gap(12),
        Text('Budi Santoso', style: ts(20, w: FontWeight.w800)),
        const Gap(2),
        Text('Supervisor IT · IT Department', style: ts(14, c: C.muted)),
        const Gap(8),
        const Pill('NIP AKP001', tone: Tone.info),
        const Gap(12),
        Align(
          alignment: Alignment.centerLeft,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _group('DATA PEKERJAAN', const [
              ('Departemen', 'IT'),
              ('Jabatan', 'Supervisor IT'),
              ('Lokasi kerja', 'Site'),
              ('Status Karyawan', 'Tetap'),
              ('Tanggal bergabung', '01 Mar 2018'),
              ('Pola roster', '14 / 7'),
            ]),
            _group('DATA PRIBADI', const [
              ('Tempat, tgl lahir', 'Makassar, 12 Mei 1990'),
              ('No. HP', '0812 •••• 7890'),
              ('Email', 'budi.santoso@email.com'),
              ('Mess', 'Blok C · C-214'),
            ]),
          ]),
        ),
        const SectionLabelLeft('AKUN'),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: [
            ListTile(
              leading: const Icon(Icons.lock_outline, color: C.text2),
              title: Text('Ubah Password', style: ts(14, w: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right, color: C.muted),
              onTap: () => toast(context, 'Ubah password (demo)'),
            ),
            const Divider(height: 1, color: C.line),
            ListTile(
              leading: const Icon(Icons.logout, color: C.red),
              title: Text('Keluar', style: ts(14, w: FontWeight.w700, c: C.red)),
              onTap: () => Navigator.pushNamedAndRemoveUntil(context, R.login, (r) => false),
            ),
          ]),
        ),
        const Gap(8),
      ]);
}

class SectionLabelLeft extends StatelessWidget {
  final String t;
  const SectionLabelLeft(this.t, {super.key});
  @override
  Widget build(BuildContext context) => Align(alignment: Alignment.centerLeft, child: SectionLabel(t));
}

class BarcodeBody extends StatelessWidget {
  const BarcodeBody({super.key});

  static List<List<bool>> _matrix() {
    const n = 25;
    var seed = 1749;
    double rnd() {
      seed = (seed * 9301 + 49297) % 233280;
      return seed / 233280;
    }

    int finder(int r, int c) {
      for (final o in [(0, 0), (0, n - 7), (n - 7, 0)]) {
        final dr = r - o.$1, dc = c - o.$2;
        if (dr >= -1 && dr <= 7 && dc >= -1 && dc <= 7) {
          if (dr < 0 || dr > 6 || dc < 0 || dc > 6) return 0;
          final ring = dr == 0 || dr == 6 || dc == 0 || dc == 6;
          final core = dr >= 2 && dr <= 4 && dc >= 2 && dc <= 4;
          return ring || core ? 1 : 0;
        }
      }
      return -1;
    }

    return [
      for (var r = 0; r < n; r++)
        [
          for (var c = 0; c < n; c++)
            () {
              var v = finder(r, c);
              if (v == -1) v = (r == 6 || c == 6) ? ((r + c) % 2 == 0 ? 1 : 0) : (rnd() > .52 ? 1 : 0);
              return v == 1;
            }()
        ]
    ];
  }

  @override
  Widget build(BuildContext context) {
    final m = _matrix();
    Widget meal(String t, String menu, String time, String status, Tone tone) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(t, style: ts(15, w: FontWeight.w800))),
                Pill(status, tone: tone),
              ]),
              const Gap(4),
              Text(menu, style: ts(13, c: C.text2, h: 1.4)),
              const Gap(2),
              Text(time, style: ts(12, c: C.muted)),
            ]),
          ),
        );
    return Column(children: [
      AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Text('Budi Santoso', style: ts(17, w: FontWeight.w800)),
          Text('NIP AKP001 · IT Department', style: ts(13, c: C.muted)),
          const Gap(16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: C.line)),
            child: SizedBox(
              width: 210,
              height: 210,
              child: CustomPaint(painter: _QrPainter(m)),
            ),
          ),
          const Gap(12),
          Text('Tunjukkan QR ini ke kiosk kantin. Naikkan kecerahan layar bila sulit terbaca.',
              textAlign: TextAlign.center, style: ts(13, c: C.muted, h: 1.5)),
        ]),
      ),
      const Gap(8),
      const SectionLabelLeft('MENU & JATAH MAKAN HARI INI'),
      meal('Sarapan', 'Nasi kuning, telur balado, buah', '05:30 – 08:00 · diambil 06:12', 'Sudah diambil', Tone.neutral),
      meal('Makan Siang', 'Nasi, ayam bakar, sayur asem, tempe', '11:00 – 13:30 · diambil 12:05', 'Sudah diambil', Tone.neutral),
      meal('Makan Malam', 'Nasi, ikan kuah kuning, tumis kangkung', '17:30 – 20:30', 'Tersedia', Tone.ok),
      Text('Menu dipublikasikan Dept. Kantin', style: ts(12, c: C.muted)),
    ]);
  }
}

class _QrPainter extends CustomPainter {
  final List<List<bool>> m;
  _QrPainter(this.m);
  @override
  void paint(Canvas canvas, Size size) {
    final n = m.length;
    final cell = size.width / n;
    final p = Paint()..color = C.navy;
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        if (m[r][c]) canvas.drawRect(Rect.fromLTWH(c * cell, r * cell, max(cell, 1), max(cell, 1)), p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
