import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

BoxDecoration _cardDeco() => BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14));

class FitnessScreen extends StatefulWidget {
  const FitnessScreen({super.key});
  @override
  State<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen> {
  int tab = 0;
  bool gym = false;
  final joined = <String>{'bola'};

  // (label, ikon, bg, fg, gps)
  static const sports = <(String, String, Color, Color, bool)>[
    ('Lari', 'run', Color(0xFFE6EEFD), Color(0xFF1E5BD7), true),
    ('Jalan Kaki', 'walk', Color(0xFFD8F1F0), Color(0xFF14655F), true),
    ('Bersepeda', 'bike', Color(0xFFFFF1E0), Color(0xFFC2610C), true),
    ('Sepak Bola', 'ball', Color(0xFFE2F4E8), Color(0xFF1A6B3A), false),
    ('Badminton', 'shuttle', Color(0xFFEFE9FD), Color(0xFF5B32B8), false),
    ('Futsal', 'court', Color(0xFFFBE3EC), Color(0xFF9C2155), false),
    ('Voli', 'globe', Color(0xFFFFF1E0), Color(0xFF9A4A06), false),
    ('Senam', 'senam', Color(0xFFE3E8EF), Color(0xFF0E2A47), false),
  ];
  static const events = [
    ('bola', 'Sab', '10', 'Sepak Bola antar Departemen', '17:00 · Lapangan Mess', 18, 22),
    ('bad', 'Rab', '14', 'Badminton Malam', '19:30 · GOR Camp', 9, 16),
    ('senam', 'Jum', '16', 'Senam Pagi Bersama', '06:00 · Halaman Kantor Site', 40, 80),
  ];
  static const runP = 'M14 4a1.6 1.6 0 1 0 0 .01M8 21l3-6 3 2v4M6 12l3-3 4 1 3 3h3M11 15l-1-5';
  static const walkP = 'M13 4a1.6 1.6 0 1 0 0 .01M9 21l2-6 2 2 1 4M10 9l3-1 2 3 3 1M11 15l-1-6-3 3';
  static const gymP = 'M6 7v10M18 7v10M3 9v6M21 9v6M6 12h12';
  static const ballP = 'M12 3a9 9 0 1 0 0 18a9 9 0 1 0 0-18M12 7l4 3-1.5 4.5h-5L8 10z';
  static const shuttleP = 'M14 4l6 6-8 8H6v-6zM4 20l3-3';
  static const hist = <(String, String, String, String, String, Color, Color)>[
    ('Lari', 'Hari ini · 05:40', '5,02 km · 31:12 · 9,7 km/j', 'Pace 6:13 /km · 352 kkal · rute Mess – Pos 2', runP, Color(0xFFE6EEFD), Color(0xFF1E5BD7)),
    ('Gym', 'Jum, 2 Okt', '18:30 – 19:45 · 75 mnt', 'Check-in Fitness Center Mess · 410 kkal (estimasi)', gymP, Color(0xFFE2F4E8), Color(0xFF1A6B3A)),
    ('Jalan Kaki', 'Kam, 1 Okt', '4,80 km · 58:20 · 4,9 km/j', 'Pace 12:09 /km · 210 kkal', walkP, Color(0xFFD8F1F0), Color(0xFF14655F)),
    ('Sepak Bola', 'Sab, 26 Sep', '90 mnt · kegiatan terjadwal', 'Lapangan Mess · hadir tercatat panitia', ballP, Color(0xFFFFF1E0), Color(0xFFC2610C)),
    ('Badminton', 'Rab, 23 Sep', '60 mnt', 'GOR Camp · 300 kkal (estimasi)', shuttleP, Color(0xFFEFE9FD), Color(0xFF5B32B8)),
    ('Gym', 'Sel, 22 Sep', '18:20 – 19:30 · 70 mnt', 'Check-in Fitness Center Mess', gymP, Color(0xFFE2F4E8), Color(0xFF1A6B3A)),
  ];

  Widget _spi(Widget icon, Color bg) => Container(width: 42, height: 42, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)), child: Center(child: icon));

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

  Widget _sec(String t) => Padding(padding: const EdgeInsets.fromLTRB(2, 6, 2, 0), child: Text(t, style: ts(15, w: FontWeight.w800)));

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: C.bg,
        body: SafeArea(
          child: Column(children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
              child: Row(children: [
                const BackBtn(label: 'Kembali ke beranda'),
                const Gap(0, w: 4),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Fitness', style: ts(18, w: FontWeight.w800, h: 1.3)),
                  Text('Terhubung dengan AKP Sehat', style: ts(12, w: FontWeight.w600, c: C.greenFg, h: 1.3)),
                ])),
              ]),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: C.line))),
              child: Seg(tabs: const ['Aktivitas', 'Riwayat'], index: tab, onChange: (v) => setState(() => tab = v), gap: 4),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                child: tab == 0 ? _activity() : _history(),
              ),
            ),
          ]),
        ),
      );

  Widget _activity() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: C.navy, borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Oktober 2026 · target 12 sesi', style: ts(13, c: C.pale)),
            const Gap(10),
            Row(children: [_st('4', 'Sesi'), const Gap(0, w: 6), _st('9,8', 'km'), const Gap(0, w: 6), _st('1.240', 'kkal'), const Gap(0, w: 6), _st('3 j', 'Durasi')]),
          ]),
        ),
        const Gap(12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: _cardDeco(),
          child: Row(children: [
            _spi(const Ic('dumbbell', size: 22, color: C.greenFg), C.greenBg),
            const Gap(0, w: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Akses Gym', style: ts(15, w: FontWeight.w700, h: 1.4)),
                Text(gym ? 'Sedang di gym sejak 18:30 · Fitness Center Mess' : 'Fitness Center Mess · buka 05:00 – 22:00 · 12 orang di dalam', style: ts(12, c: C.muted, h: 1.4)),
              ]),
            ),
            const Gap(0, w: 12),
            Material(
              color: gym ? C.red : C.green,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => setState(() => gym = !gym),
                child: Container(constraints: const BoxConstraints(minHeight: 44), padding: const EdgeInsets.symmetric(horizontal: 14), alignment: Alignment.center, child: Text(gym ? 'Check-out' : 'Check-in', style: ts(13, w: FontWeight.w700, c: Colors.white))),
              ),
            ),
          ]),
        ),
        const Gap(12),
        _sec('Mulai aktivitas'),
        const Gap(12),
        for (var r = 0; r < sports.length; r += 4) ...[
          if (r > 0) const Gap(8),
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (var c = r; c < r + 4; c++) ...[
                if (c > r) const Gap(0, w: 8),
                Expanded(child: _sport(sports[c])),
              ],
            ]),
          ),
        ],
        const Gap(12),
        Text('Daftar olahraga dan jadwal kegiatan diatur dari web AKP Sehat, otomatis muncul di sini.', style: ts(12, c: C.muted, h: 1.5)),
        const Gap(12),
        _sec('Kegiatan terjadwal'),
        for (final e in events) ...[
          const Gap(12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: _cardDeco(),
            child: Row(children: [
              Container(
                width: 48,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(color: C.bg, borderRadius: BorderRadius.circular(10)),
                child: Column(children: [Text(e.$2, style: ts(11, c: C.muted, h: 1.15)), Text(e.$3, style: ts(18, w: FontWeight.w800, h: 1.15))]),
              ),
              const Gap(0, w: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(e.$4, style: ts(14, w: FontWeight.w700, h: 1.4)),
                  Text(e.$5, style: ts(12, c: C.muted, h: 1.4)),
                  Text('${e.$6 + (joined.contains(e.$1) ? 1 : 0)} / ${e.$7} peserta', style: ts(12, c: C.text2, h: 1.4)),
                ]),
              ),
              const Gap(0, w: 12),
              _joinBtn(e.$1),
            ]),
          ),
        ],
      ]);

  Widget _joinBtn(String id) {
    final on = joined.contains(id);
    return Material(
      color: on ? C.green : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: on ? BorderSide.none : const BorderSide(color: C.blue, width: 1.5)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => on ? joined.remove(id) : joined.add(id)),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44, minWidth: 72),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          child: Text(on ? 'Ikut ✓' : 'Ikut', style: ts(13, w: FontWeight.w700, c: on ? Colors.white : C.blue)),
        ),
      ),
    );
  }

  Widget _sport((String, String, Color, Color, bool) s) => Semantics(
        button: true,
        label: s.$1,
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: C.line)),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => s.$5 ? Navigator.pushNamed(context, R.fitnessRecord) : toast(context, '${s.$1} dicatat dari jadwal kegiatan'),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 96),
              child: Stack(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  child: Column(children: [
                    _spi(Ic(s.$2, size: 22, color: s.$4), s.$3),
                    const Gap(6),
                    Text(s.$1, textAlign: TextAlign.center, style: ts(12, w: FontWeight.w700)),
                  ]),
                ),
                if (s.$5)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(color: C.blueSoft, borderRadius: BorderRadius.circular(6)),
                      child: Text('GPS', style: ts(9, w: FontWeight.w800, c: C.blueFg)),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      );

  Widget _history() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Oktober 2026', style: ts(13, c: C.muted)),
          Flexible(child: Text('Semua tersinkron ke AKP Sehat', textAlign: TextAlign.right, style: ts(13, w: FontWeight.w600, c: C.greenFg))),
        ]),
        for (final h in hist) ...[
          const Gap(10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: _cardDeco(),
            child: Row(children: [
              _spi(Ic.path(h.$5, size: 22, color: h.$7), h.$6),
              const Gap(0, w: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(h.$1, style: ts(15, w: FontWeight.w700, h: 1.45)),
                    Text(h.$2, style: ts(12, c: C.muted, h: 1.45)),
                  ]),
                  Text(h.$3, style: ts(13, c: C.text2, h: 1.45)),
                  Text(h.$4, style: ts(12, c: C.muted, h: 1.45)),
                ]),
              ),
            ]),
          ),
        ],
      ]);
}

const _routeMapSvg = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 358 250" width="358" height="250">
<rect width="358" height="250" fill="#E8EEF3"/>
<path d="M0 60 L358 40 M0 150 L358 170 M70 0 L90 250 M230 0 L250 250 M0 220 L358 205" stroke="#FFFFFF" stroke-width="10" fill="none"/>
<path d="M150 0 L170 250" stroke="#FFFFFF" stroke-width="5" fill="none"/>
<rect x="260" y="70" width="70" height="60" rx="6" fill="#D6E9DA"/>
<rect x="100" y="80" width="40" height="55" rx="4" fill="#DDE3EA"/>
<path d="M86 228 L84 160 L118 152 L160 150 L166 100 L238 92 L243 168" stroke="#1E5BD7" stroke-width="5" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
<circle cx="86" cy="228" r="7" fill="#1F7A47" stroke="#FFFFFF" stroke-width="3"/>
<circle cx="243" cy="168" r="11" fill="#1E5BD7" fill-opacity="0.25"/>
<circle cx="243" cy="168" r="6" fill="#1E5BD7" stroke="#FFFFFF" stroke-width="3"/>
</svg>''';

class FitnessRecordScreen extends StatefulWidget {
  const FitnessRecordScreen({super.key});
  @override
  State<FitnessRecordScreen> createState() => _FitnessRecordScreenState();
}

class _FitnessRecordScreenState extends State<FitnessRecordScreen> {
  String sport = 'Lari';
  String status = 'run'; // idle | run | pause | done
  int metric = 0;
  int sec = 1715;
  double dist = 4.42;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (status != 'run') return;
      final v = sport == 'Lari' ? 2.7 : sport == 'Jalan Kaki' ? 1.35 : 5.5;
      setState(() {
        sec++;
        dist += v * (1 + .08 * sin(sec / 23)) / 1000;
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String pad(int n) => n < 10 ? '0$n' : '$n';
  String f(double x, int d) => x.toStringAsFixed(d).replaceAll('.', ',');
  String get timeTxt {
    final h = sec ~/ 3600, m = (sec % 3600) ~/ 60, s = sec % 60;
    return '${h > 0 ? '$h:${pad(m)}' : pad(m)}:${pad(s)}';
  }

  double get speed => sec > 0 ? dist / (sec / 3600) : 0;
  int get paceSec => dist > .01 ? (sec / dist).round() : 0;
  int get perKm => sport == 'Lari' ? 70 : sport == 'Jalan Kaki' ? 40 : 30;

  Widget _mt(String v, String l) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Mockup: nilai dibungkus <span> yang terkena `.mt span` (12px, abu-abu) di baris setinggi 25px.
          SizedBox(height: 25, child: Padding(padding: const EdgeInsets.only(top: 11), child: Text(v, style: ts(12, w: FontWeight.w800, c: C.muted)))),
          SizedBox(height: 20, child: Padding(padding: const EdgeInsets.only(top: 3.7), child: Text(l, style: ts(12, c: C.muted)))),
        ]),
      );

  Widget _grid(List<(String, String)> t) => Column(children: [
        for (var r = 0; r < t.length; r += 2) ...[
          if (r > 0) const Gap(8),
          Row(children: [Expanded(child: _mt(t[r].$1, t[r].$2)), const Gap(0, w: 8), Expanded(child: _mt(t[r + 1].$1, t[r + 1].$2))]),
        ],
      ]);

  @override
  Widget build(BuildContext context) {
    final kcal = (dist * perKm).round();
    final pace = paceSec > 0 ? '${paceSec ~/ 60}:${pad(paceSec % 60)}' : '-';
    final done = status == 'done';
    final metrics = <(String, String, (String, String))>[
      (f(dist, 2), 'kilometer', ('${f(dist, 2)} km', 'Jarak')),
      (f(speed, 1), 'km/jam rata-rata', (f(speed, 1), 'Rata-rata km/jam')),
      ('$kcal', 'kkal terbakar', ('$kcal', 'Kalori (kkal)')),
    ];
    final tiles = <(String, String)>[
      (timeTxt, 'Durasi'),
      for (var i = 0; i < 3; i++)
        if (i != metric) metrics[i].$3,
      (pace, 'Pace rata-rata /km'),
    ];
    final (mainLabel, mainBg) = switch (status) { 'idle' => ('MULAI', C.green), 'pause' => ('LANJUT', C.green), _ => ('JEDA', C.orange) };
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(children: [
          PageHeader(
            sport,
            trailing: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: C.green, shape: BoxShape.circle)),
                const Gap(0, w: 6),
                Text('GPS kuat', style: ts(12, w: FontWeight.w700, c: C.greenFg)),
              ]),
            ),
          ),
          if (status == 'idle')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(children: [
                for (final l in const ['Lari', 'Jalan Kaki', 'Bersepeda']) ...[
                  if (l != 'Lari') const Gap(0, w: 6),
                  Expanded(
                    child: Material(
                      color: l == sport ? C.blue : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99), side: BorderSide(color: l == sport ? C.blue : C.input)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(99),
                        onTap: () => setState(() => sport = l),
                        child: SizedBox(height: 40, child: Center(child: Text(l, style: ts(13, w: l == sport ? FontWeight.w700 : FontWeight.w600, c: l == sport ? Colors.white : C.text2)))),
                      ),
                    ),
                  ),
                ],
              ]),
            ),
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            height: 250,
            decoration: BoxDecoration(color: const Color(0xFFE8EEF3), borderRadius: BorderRadius.circular(16), border: Border.all(color: C.input)),
            clipBehavior: Clip.antiAlias,
            child: Stack(children: [
              Positioned(left: -1, top: -1, child: SvgPicture.string(_routeMapSvg, width: 358, height: 250)),
              Positioned(
                left: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: Text('Mess Blok C → Pos 2', style: ts(11, w: FontWeight.w700, c: C.text2)),
                ),
              ),
            ]),
          ),
          if (!done) ...[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Column(children: [
                  Semantics(
                    button: true,
                    label: '${metrics[metric].$1} ${metrics[metric].$2}. Ketuk untuk ganti tampilan',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => metric = (metric + 1) % 3),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(children: [
                          Text(metrics[metric].$1, style: ts(56, w: FontWeight.w800, h: 1.1).copyWith(letterSpacing: -1)),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(metrics[metric].$2, style: ts(13, w: FontWeight.w600, c: C.muted, h: 1.1)),
                            const Gap(0, w: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: C.blueSoft, borderRadius: BorderRadius.circular(6)),
                              child: Text('ketuk untuk ganti', style: ts(11, w: FontWeight.w700, c: C.blue, h: 1.1)),
                            ),
                          ]),
                          const Gap(8),
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            for (var i = 0; i < 3; i++) ...[
                              if (i > 0) const Gap(0, w: 5),
                              Container(width: i == metric ? 16 : 6, height: 6, decoration: BoxDecoration(color: i == metric ? C.blue : const Color(0xFFC4CDD9), borderRadius: BorderRadius.circular(3))),
                            ],
                          ]),
                        ]),
                      ),
                    ),
                  ),
                  const Gap(10),
                  _grid(tiles),
                  if (status == 'pause') ...[const Gap(10), Text('Dijeda', style: ts(13, w: FontWeight.w700, c: C.orangeFg))],
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (status == 'run' || status == 'pause') ...[
                  Semantics(
                    button: true,
                    label: 'Selesai',
                    child: Material(
                      color: C.redBg,
                      shape: const CircleBorder(),
                      child: InkWell(customBorder: const CircleBorder(), onTap: () => setState(() => status = 'done'), child: SizedBox(width: 60, height: 60, child: Center(child: Container(width: 12, height: 12, decoration: BoxDecoration(color: C.red, borderRadius: BorderRadius.circular(2)))))),
                    ),
                  ),
                  const Gap(0, w: 28),
                ],
                Material(
                  color: mainBg,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => setState(() => status = status == 'run' ? 'pause' : 'run'),
                    child: SizedBox(width: 84, height: 84, child: Center(child: Text(mainLabel, style: ts(15, w: FontWeight.w800, c: Colors.white)))),
                  ),
                ),
              ]),
            ),
          ] else
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(color: C.greenBg, borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      const Ic('check', size: 18, stroke: 2.4, color: Color(0xFF14532D)),
                      const Gap(0, w: 10),
                      Text('Tersimpan & tersinkron ke AKP Sehat', style: ts(13, w: FontWeight.w600, c: const Color(0xFF14532D))),
                    ]),
                  ),
                  const Gap(10),
                  _grid([('${f(dist, 2)} km', 'Jarak'), (timeTxt, 'Durasi'), ('$kcal', 'Kalori (kkal)'), (f(speed, 1), 'Rata-rata km/jam')]),
                  const Gap(14),
                  PrimaryButton('Lihat Riwayat', onTap: () => Navigator.pop(context)),
                  const Gap(10),
                  InkWell(onTap: () => setState(() { status = 'idle'; sec = 0; dist = 0; }), child: SizedBox(height: 44, child: Center(child: Text('Rekam lagi (demo)', style: ts(14, w: FontWeight.w700, c: C.blue))))),
                ]),
              ),
            ),
        ]),
      ),
    );
  }
}
