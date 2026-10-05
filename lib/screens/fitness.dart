import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

class FitnessScreen extends StatefulWidget {
  const FitnessScreen({super.key});
  @override
  State<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen> {
  int tab = 0;
  bool gymOn = false;
  final joined = <String>{'bola'};

  static const sports = [
    ('GPS Lari', Icons.directions_run, true),
    ('GPS Jalan Kaki', Icons.directions_walk, true),
    ('GPS Bersepeda', Icons.directions_bike, true),
    ('Sepak Bola', Icons.sports_soccer, false),
    ('Badminton', Icons.sports_tennis, false),
    ('Futsal', Icons.sports_soccer, false),
    ('Voli', Icons.sports_volleyball, false),
    ('Senam', Icons.self_improvement, false),
  ];
  static const events = [
    ('bola', 'Sab', '10', 'Sepak Bola antar Departemen', '17:00 · Lapangan Mess', 18, 22),
    ('bad', 'Rab', '14', 'Badminton Malam', '19:30 · GOR Camp', 9, 16),
    ('senam', 'Jum', '16', 'Senam Pagi Bersama', '06:00 · Halaman Kantor Site', 40, 80),
  ];
  static const hist = [
    ('Lari', 'Hari ini · 05:40', '5,02 km · 31:12 · 9,7 km/j', 'Pace 6:13 /km · 352 kkal · rute Mess – Pos 2', Icons.directions_run, C.blueSoft, C.blue),
    ('Gym', 'Jum, 2 Okt', '1 jam 05 mnt', 'Akses gym · 410 kkal', Icons.fitness_center, C.greenBg, C.greenFg),
    ('Jalan Kaki', 'Rab, 30 Sep', '3,10 km · 38:40', '120 kkal · rute Mess – Kantin', Icons.directions_walk, C.tealBg, C.teal),
    ('Badminton', 'Sen, 28 Sep', '1 jam 30 mnt', 'GOR Camp · 358 kkal', Icons.sports_tennis, C.orangeBg, C.orangeFg),
  ];

  Widget stat(IconData i, String v, String l) => Expanded(
        child: AppCard(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          child: Column(children: [
            Icon(i, size: 18, color: C.muted),
            const Gap(4),
            Text(v, style: ts(15, w: FontWeight.w800)),
            Text(l, style: ts(11, c: C.muted)),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) => SubPage(
        title: 'Fitness',
        subtitle: 'Terhubung dengan AKP Sehat',
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Seg(tabs: const ['Aktivitas', 'Riwayat'], index: tab, onChange: (v) => setState(() => tab = v)),
          const Gap(14),
          Text('Oktober 2026 · target 12 sesi', style: ts(13, c: C.muted)),
          const Gap(8),
          Row(children: [
            stat(Icons.event_repeat, '4', 'Sesi'),
            const Gap(0, w: 8),
            stat(Icons.route, '9,8 km', 'Jarak'),
            const Gap(0, w: 8),
            stat(Icons.local_fire_department_outlined, '1.240', 'kkal'),
            const Gap(0, w: 8),
            stat(Icons.timer_outlined, '3 j', 'Durasi'),
          ]),
          const Gap(16),
          if (tab == 0) ..._activity() else ..._history(),
        ]),
      );

  List<Widget> _activity() => [
        AppCard(
          child: Row(children: [
            const IconBox(Icons.fitness_center, C.greenBg, C.greenFg, size: 44),
            const Gap(0, w: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Akses Gym', style: ts(14, w: FontWeight.w800)),
                Text(gymOn ? 'Check-in 06:05 · Fitness center' : 'Check-in dengan scan QR di pintu gym', style: ts(12, c: C.muted)),
              ]),
            ),
            SizedBox(
              height: 40,
              child: FilledButton(
                onPressed: () => setState(() => gymOn = !gymOn),
                style: FilledButton.styleFrom(backgroundColor: gymOn ? C.red : C.blue),
                child: Text(gymOn ? 'Check-out' : 'Check-in'),
              ),
            ),
          ]),
        ),
        const Gap(16),
        Text('Mulai aktivitas', style: ts(16, w: FontWeight.w800)),
        const Gap(10),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: .9,
          children: [
            for (final s in sports)
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => s.$3 ? Navigator.pushNamed(context, R.fitnessRecord) : toast(context, '${s.$1} dicatat manual (demo)'),
                child: Column(children: [
                  IconBox(s.$2, s.$3 ? C.blueSoft : C.chip, s.$3 ? C.blue : C.navy),
                  const Gap(6),
                  Text(s.$1, textAlign: TextAlign.center, style: ts(11, w: FontWeight.w600, h: 1.2)),
                ]),
              ),
          ],
        ),
        const Gap(4),
        Text('Daftar olahraga dan jadwal kegiatan diatur dari web AKP Sehat, otomatis muncul di sini.', style: ts(12, c: C.muted, h: 1.4)),
        const Gap(16),
        Text('Kegiatan terjadwal', style: ts(16, w: FontWeight.w800)),
        const Gap(10),
        for (final e in events)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              child: Row(children: [
                Container(
                  width: 48,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(color: C.bg, borderRadius: BorderRadius.circular(10)),
                  child: Column(children: [Text(e.$3, style: ts(18, w: FontWeight.w800)), Text(e.$2, style: ts(11, c: C.muted))]),
                ),
                const Gap(0, w: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.$4, style: ts(14, w: FontWeight.w700, h: 1.3)),
                    Text(e.$5, style: ts(12, c: C.muted)),
                    Text('${e.$6 + (joined.contains(e.$1) ? 1 : 0)} / ${e.$7} peserta', style: ts(12, c: C.muted)),
                  ]),
                ),
                SizedBox(
                  height: 44,
                  child: joined.contains(e.$1)
                      ? FilledButton(onPressed: () => setState(() => joined.remove(e.$1)), style: FilledButton.styleFrom(backgroundColor: C.green), child: const Text('Ikut ✓'))
                      : OutlinedButton(onPressed: () => setState(() => joined.add(e.$1)), child: const Text('Ikut')),
                ),
              ]),
            ),
          ),
      ];

  List<Widget> _history() => [
        Text('Oktober 2026', style: ts(16, w: FontWeight.w800)),
        Text('Semua tersinkron ke AKP Sehat', style: ts(12, c: C.muted)),
        const Gap(10),
        for (final h in hist)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AppCard(
              child: Row(children: [
                IconBox(h.$5, h.$6, h.$7, size: 44),
                const Gap(0, w: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [Text(h.$1, style: ts(14, w: FontWeight.w800)), const Spacer(), Text(h.$2, style: ts(12, c: C.muted))]),
                    Text(h.$3, style: ts(13, w: FontWeight.w600)),
                    Text(h.$4, style: ts(12, c: C.muted, h: 1.4)),
                  ]),
                ),
              ]),
            ),
          ),
      ];
}

class FitnessRecordScreen extends StatefulWidget {
  const FitnessRecordScreen({super.key});
  @override
  State<FitnessRecordScreen> createState() => _FitnessRecordScreenState();
}

class _FitnessRecordScreenState extends State<FitnessRecordScreen> {
  String sport = 'Lari';
  bool paused = false, done = false, showPace = false;
  int sec = 1715;
  double dist = 4.42;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (paused || done) return;
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
  String get timeTxt {
    final h = sec ~/ 3600, m = (sec % 3600) ~/ 60, s = sec % 60;
    return '${h > 0 ? '$h:${pad(m)}' : pad(m)}:${pad(s)}';
  }

  String f(double x, int d) => x.toStringAsFixed(d).replaceAll('.', ',');
  double get speed => sec > 0 ? dist / (sec / 3600) : 0;
  String get pace {
    if (dist < .01) return '--:--';
    final p = (sec / dist).round();
    return '${p ~/ 60}:${pad(p % 60)}';
  }

  int get kcal => (dist * (sport == 'Lari' ? 70 : sport == 'Jalan Kaki' ? 40 : 30)).round();

  @override
  Widget build(BuildContext context) {
    if (done) {
      return SubPage(
        title: 'Rekam Aktivitas GPS',
        body: ResultView(icon: Icons.check_circle, color: C.green, title: 'Tersimpan & tersinkron ke AKP Sehat', text: 'Aktivitas $sport Anda sudah masuk riwayat.', children: [
          SummaryBox([('Jarak', '${f(dist, 2)} km'), ('Durasi', timeTxt), ('Kalori', '$kcal kkal'), ('Rata-rata', '${f(speed, 1)} km/jam')]),
          const Gap(16),
          PrimaryButton('Lihat Riwayat', onTap: () => Navigator.pop(context)),
          TextButton(onPressed: () => setState(() { done = false; paused = false; sec = 0; dist = 0; }), child: Text('Rekam lagi (demo)', style: ts(13, c: C.muted))),
        ]),
      );
    }
    return SubPage(
      title: 'Rekam Aktivitas GPS',
      actions: [Padding(padding: const EdgeInsets.only(right: 8), child: Pill(paused ? 'Dijeda' : 'GPS kuat', tone: paused ? Tone.warn : Tone.ok))],
      scroll: false,
      padding: const EdgeInsets.all(16),
      body: Column(children: [
        ChoiceRow(options: const ['Lari', 'Jalan Kaki', 'Sepeda'], selected: sport, onSelect: (v) => setState(() => sport = v)),
        const Gap(12),
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: const Color(0xFFDCE7FB), borderRadius: BorderRadius.circular(16)),
            child: Stack(children: [
              Positioned.fill(child: CustomPaint(painter: _RoutePainter())),
              const Positioned(left: 14, bottom: 12, child: Pill('Mess Blok C → Pos 2', tone: Tone.info)),
            ]),
          ),
        ),
        const Gap(14),
        GestureDetector(
          onTap: () => setState(() => showPace = !showPace),
          child: Column(children: [
            Text(showPace ? pace : f(dist, 2), style: ts(56, w: FontWeight.w800, h: 1.1)),
            Text(showPace ? 'menit / km · ketuk untuk ganti' : 'km · ketuk untuk ganti', style: ts(12, c: C.muted)),
          ]),
        ),
        const Gap(12),
        Row(children: [
          for (final t in [(timeTxt, 'Durasi'), ('$kcal', 'Kkal'), (f(speed, 1), 'km/jam')])
            Expanded(child: Column(children: [Text(t.$1, style: ts(20, w: FontWeight.w800)), Text(t.$2, style: ts(12, c: C.muted))])),
        ]),
        const Gap(16),
        Row(children: [
          Expanded(child: PrimaryButton(paused ? 'Lanjutkan' : 'Jeda', color: paused ? C.green : C.orange, icon: paused ? Icons.play_arrow : Icons.pause, onTap: () => setState(() => paused = !paused))),
          const Gap(0, w: 10),
          Expanded(child: PrimaryButton('Selesai', color: C.red, icon: Icons.stop, onTap: () => setState(() => done = true))),
        ]),
      ]),
    );
  }
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final grid = Paint()..color = Colors.white.withValues(alpha: .5)..strokeWidth = 1;
    for (var i = 1; i < 6; i++) {
      canvas.drawLine(Offset(0, s.height * i / 6), Offset(s.width, s.height * i / 6), grid);
      canvas.drawLine(Offset(s.width * i / 6, 0), Offset(s.width * i / 6, s.height), grid);
    }
    final p = Path()
      ..moveTo(s.width * .12, s.height * .8)
      ..cubicTo(s.width * .3, s.height * .9, s.width * .35, s.height * .4, s.width * .55, s.height * .5)
      ..cubicTo(s.width * .75, s.height * .6, s.width * .6, s.height * .15, s.width * .85, s.height * .2);
    canvas.drawPath(p, Paint()..color = C.blue..style = PaintingStyle.stroke..strokeWidth = 5..strokeCap = StrokeCap.round);
    canvas.drawCircle(Offset(s.width * .12, s.height * .8), 7, Paint()..color = C.green);
    canvas.drawCircle(Offset(s.width * .85, s.height * .2), 9, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(s.width * .85, s.height * .2), 6, Paint()..color = C.red);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
