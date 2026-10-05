import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  static const _menu = <(String, IconData, Color, Color, String)>[
    ('Absensi', Icons.access_time, C.blueSoft, C.blue, R.absensi),
    ('Jadwal Kerja', Icons.calendar_month_outlined, C.tealBg, C.teal, R.roster),
    ('Cuti', Icons.event_available_outlined, C.orangeBg, C.orange, R.cuti),
    ('Lembur', Icons.timer_outlined, C.blueSoft, C.blueFg, R.pengajuanLembur),
    ('My Activity', Icons.checklist, C.chip, C.navy, R.myActivity),
    ('Fit To Work', Icons.monitor_heart_outlined, C.redBg, C.red, R.ftw),
    ('P2H Online', Icons.local_shipping_outlined, C.orangeBg, C.orangeFg, R.p2h),
    ('PTW Online', Icons.assignment_turned_in_outlined, C.redBg, Color(0xFF9C2B1F), R.ptw),
    ('Learning Center', Icons.school_outlined, C.purpleBg, C.purple, R.learning),
    ('Fitness', Icons.fitness_center, C.greenBg, C.greenFg, R.fitness),
    ('Camp Facility', Icons.apartment, C.chip, C.navy, R.camp),
    ('Itinerary Cuti', Icons.flight_takeoff, C.pinkBg, C.pink, R.itinerary),
  ];

  @override
  Widget build(BuildContext context) {
    void go(String r) => Navigator.pushNamed(context, r);
    return SingleChildScrollView(
      child: Column(children: [
        Container(
          width: double.infinity,
          color: C.navy,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 76),
          child: Column(children: [
            Row(children: [
              const Logo(size: 34),
              const Gap(0, w: 10),
              Expanded(child: Text('AKPSatu', style: ts(18, w: FontWeight.w800, c: Colors.white))),
              Semantics(
                label: 'Notifikasi, 7 belum dibaca',
                button: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => go(R.notifikasi),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: C.navy2, borderRadius: BorderRadius.circular(12)),
                    child: Stack(alignment: Alignment.center, children: [
                      const Icon(Icons.notifications_none, color: Colors.white),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 18),
                          height: 18,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: const Color(0xFFD64545), borderRadius: BorderRadius.circular(9), border: Border.all(color: C.navy, width: 2)),
                          child: Text('7', style: ts(11, w: FontWeight.w800, c: Colors.white)),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ]),
            const Gap(16),
            Row(children: [
              const Avatar('BS', size: 48),
              const Gap(0, w: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Selamat datang,', style: ts(13, c: C.pale)),
                  Text('Budi Santoso', style: ts(18, w: FontWeight.w800, c: Colors.white)),
                  Text('AKP001 · Supervisor IT', style: ts(12, c: C.pale)),
                ]),
              ),
            ]),
          ]),
        ),
        Transform.translate(
          offset: const Offset(0, -56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: [
              AppCard(
                child: Column(children: [
                  Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Minggu, 4 Oktober 2026', style: ts(12, c: C.muted)),
                        Text('Day shift · 07:00 – 19:00', style: ts(15, w: FontWeight.w700)),
                      ]),
                    ),
                    const Pill('Hadir', tone: Tone.ok),
                  ]),
                  const Gap(12),
                  Row(children: [
                    Expanded(child: _time('Masuk', '06:52')),
                    const Gap(0, w: 10),
                    Expanded(child: _time('Pulang', '--:--')),
                  ]),
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
                      const IconBox(Icons.fact_check_outlined, C.blue, Colors.white, size: 40),
                      const Gap(0, w: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('6 pengajuan menunggu persetujuan', style: ts(14, w: FontWeight.w700, c: Colors.white)),
                          Text('2 cuti · 3 lembur · 1 PTW', style: ts(12, c: C.pale)),
                        ]),
                      ),
                      Text('Tinjau', style: ts(13, w: FontWeight.w700, c: const Color(0xFF8FB0EE))),
                    ]),
                  ),
                ),
              ),
              const Gap(14),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: .86,
                  children: [
                    for (final m in _menu)
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => go(m.$5),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                          child: Column(children: [
                            IconBox(m.$2, m.$3, m.$4),
                            const Gap(7),
                            Text(m.$1, textAlign: TextAlign.center, maxLines: 2, style: ts(11, w: FontWeight.w600, h: 1.25)),
                          ]),
                        ),
                      ),
                  ],
                ),
              ),
              const Gap(14),
              ChevronRow(
                onTap: () => go(R.myActivity),
                leading: Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: C.redBg, borderRadius: BorderRadius.circular(10)),
                  child: Text('3', style: ts(16, w: FontWeight.w800, c: C.red)),
                ),
                kicker: 'My Activity · IT Department',
                title: '3 perlu follow-up',
                sub: 'Lisensi antivirus jatuh tempo 15 Okt',
              ),
              const Gap(14),
              ChevronRow(
                onTap: () => go(R.itinerary),
                color: const Color(0xFFF5F8FE),
                border: const Color(0xFFC9D8F5),
                leading: const IconBox(Icons.directions_bus_outlined, C.blue, Colors.white, size: 40),
                kicker: 'Itinerary cuti · besok, Sen 5 Okt',
                title: 'Jemput 05:30 · BUS-07 · Kursi 14',
                sub: 'Pesawat KDI → UPG 09:40 · lumpsum sudah ditransfer',
              ),
              const Gap(14),
              ChevronRow(
                onTap: () => go(R.roster),
                leading: const SizedBox.shrink(),
                kicker: 'Jadwal kerja',
                title: 'Day shift sampai hari ini',
                sub: 'Off 5 – 11 Okt · Night mulai 12 Okt',
              ),
              const Gap(8),
              TextButton(onPressed: () => go(R.notifPush), child: Text('Lihat contoh notifikasi push (demo)', style: ts(12, c: C.muted))),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _time(String l, String v) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: C.bg, borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l, style: ts(12, c: C.muted)),
          Text(v, style: ts(20, w: FontWeight.w800)),
        ]),
      );
}
