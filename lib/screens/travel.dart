import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

class TravelScreen extends StatefulWidget {
  const TravelScreen({super.key});
  @override
  State<TravelScreen> createState() => _TravelScreenState();
}

class _TravelScreenState extends State<TravelScreen> {
  bool back = false;

  Widget seatMap(int mine) {
    var n = 1;
    final cells = <Widget>[];
    for (var r = 0; r < 5; r++) {
      for (var c = 0; c < 5; c++) {
        if (c == 2) {
          cells.add(const SizedBox());
          continue;
        }
        final me = n == mine;
        cells.add(Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(color: me ? C.blue : C.chip, borderRadius: BorderRadius.circular(6)),
          child: Text('$n', style: ts(11, w: FontWeight.w700, c: me ? Colors.white : C.muted)),
        ));
        n++;
      }
    }
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Denah kursi (depan di atas)', style: ts(12, c: C.muted)),
        const Gap(8),
        GridView.count(crossAxisCount: 5, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), mainAxisSpacing: 5, crossAxisSpacing: 5, childAspectRatio: 1.5, children: cells),
      ]),
    );
  }

  Widget pickup(String no, String title, String date, String info, String seatNo, String unit, String plate, String dest, int seat, String ini, String driver, String phone) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionLabel('$no · $title'),
        AppCard(
          child: Column(children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(date, style: ts(15, w: FontWeight.w800)), Text(info, style: ts(13, c: C.muted))])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: C.blueSoft, borderRadius: BorderRadius.circular(10)),
                child: Column(children: [Text('Kursi', style: ts(11, c: C.blueFg)), Text(seatNo, style: ts(22, w: FontWeight.w800, c: C.blueFg))]),
              ),
            ]),
            const Divider(color: C.line, height: 20),
            KV('No. unit', unit),
            KV('No. polisi', plate),
            const KV('Jenis', 'Bus 20 kursi'),
            KV('Tujuan', dest),
          ]),
        ),
        const Gap(10),
        seatMap(seat),
        const Gap(10),
        AppCard(
          child: Row(children: [
            Avatar(ini, bg: C.tealBg, fg: C.teal),
            const Gap(0, w: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Driver $driver', style: ts(14, w: FontWeight.w700)), Text(phone, style: ts(12, c: C.muted))])),
            IconButton(tooltip: 'Telepon driver', onPressed: () => toast(context, 'Menelepon $driver (demo)'), icon: const Icon(Icons.call, color: C.blue)),
          ]),
        ),
      ]);

  Widget ticket(String no, String from, String fromT, String to, String toT, String date, String flight, String seat, String code) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionLabel('$no · TIKET PESAWAT'),
        AppCard(
          child: Column(children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(from.split(' ')[0], style: ts(26, w: FontWeight.w800)), Text(from.split(' ')[1], style: ts(12, c: C.muted)), Text(fromT, style: ts(15, w: FontWeight.w700))])),
              Column(children: [const Icon(Icons.flight_takeoff, color: C.blue), Text('1 j 15 m', style: ts(11, c: C.muted))]),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(to.split(' ')[0], style: ts(26, w: FontWeight.w800)), Text(to.split(' ')[1], style: ts(12, c: C.muted)), Text(toT, style: ts(15, w: FontWeight.w700))])),
            ]),
            const Divider(color: C.line, height: 20),
            KV('Tanggal', date),
            KV('Penerbangan', flight),
            KV('Kursi', seat),
            KV('Kode booking', code),
            const KV('Bagasi', '20 kg'),
            const KV('Kelas', 'Ekonomi'),
            const Gap(8),
            Row(children: [
              Expanded(child: OutlineButton('Lihat e-tiket', onTap: () => toast(context, 'Membuka e-tiket (demo)'))),
              const Gap(0, w: 10),
              Expanded(child: OutlineButton('Unduh PDF', onTap: () => toast(context, 'Mengunduh PDF (demo)'))),
            ]),
          ]),
        ),
      ]);

  @override
  Widget build(BuildContext context) => SubPage(
        title: 'Perjalanan Cuti',
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Seg(tabs: const ['Berangkat · 5 Okt', 'Kembali · 11 Okt'], index: back ? 1 : 0, onChange: (v) => setState(() => back = v == 1)),
          const Gap(12),
          AppCard(
            color: const Color(0xFFF5F8FE),
            border: const Color(0xFFC9D8F5),
            child: Row(children: [
              Expanded(child: Text('Off roster 5 – 11 Okt 2026', style: ts(14, w: FontWeight.w800))),
              const Pill('Terkonfirmasi', tone: Tone.ok),
            ]),
          ),
          if (!back) ...[
            pickup('1', 'JEMPUTAN KE BANDARA', 'Senin, 5 Okt 2026', 'Jemput 05:30 · Lobby Mess Blok C', '14', 'BUS-07', 'DT 7421 KB', 'Bandara KDI', 14, 'RH', 'Rahmat Hidayat', '0813 •••• 2210'),
            ticket('2', 'KDI Kendari', '09:40', 'UPG Makassar', '10:55', '5 Okt 2026', 'XX 1234', '12A', 'K7P2QD'),
          ] else ...[
            ticket('1', 'UPG Makassar', '07:10', 'KDI Kendari', '08:25', '11 Okt 2026', 'XX 1231', '8C', 'M3RX8T'),
            pickup('2', 'JEMPUTAN KE SITE', 'Minggu, 11 Okt 2026', 'Jemput 08:45 · Bandara KDI, pintu kedatangan', '6', 'BUS-03', 'DT 7188 KB', 'Mess Blok C', 6, 'YR', 'Yusuf Rahman', '0812 •••• 5531'),
          ],
        ]),
      );
}

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});
  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  bool ls = false;

  Widget day(String label, List<Widget> items) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [SectionLabel(label), ...items]);

  Widget ev(String time, IconData icon, Color bg, Color fg, String title, String sub, {List<String> chips = const []}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: AppCard(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 46, child: Text(time, style: ts(14, w: FontWeight.w800))),
            IconBox(icon, bg, fg, size: 38),
            const Gap(0, w: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: ts(14, w: FontWeight.w700)),
                Text(sub, style: ts(12, c: C.muted, h: 1.4)),
                if (chips.isNotEmpty) ...[const Gap(6), Wrap(spacing: 6, runSpacing: 4, children: [for (final c in chips) Pill(c)])],
              ]),
            ),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    Widget check(String t, bool ok) => Expanded(
          child: Column(children: [
            Container(width: 26, height: 26, alignment: Alignment.center, decoration: BoxDecoration(color: ok ? C.green : C.chip, shape: BoxShape.circle), child: const Icon(Icons.check, size: 16, color: Colors.white)),
            const Gap(4),
            Text(t, textAlign: TextAlign.center, style: ts(10, c: C.muted, h: 1.2)),
          ]),
        );
    return SubPage(
      title: 'Itinerary Cuti',
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: C.navy, borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Cuti Roster · CT-2026-09-0214', style: ts(12, c: C.pale)),
            const Gap(2),
            Text('5 – 11 Oktober 2026', style: ts(22, w: FontWeight.w800, c: Colors.white)),
            Text('7 hari · Kendari ⇄ Makassar', style: ts(13, c: C.pale)),
            const Gap(14),
            Row(children: [check('Cuti disetujui', true), check('Lumpsum ditransfer', true), check('Tiket terbit', true), check('Jemputan terjadwal', true)]),
            const Gap(12),
            Text('Kembali kerja: Sen, 12 Okt · Night shift 19:00', style: ts(13, w: FontWeight.w600, c: Colors.white)),
          ]),
        ),
        const SectionLabel('SEBELUM BERANGKAT'),
        AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [const Icon(Icons.verified_outlined, color: C.green), const Gap(0, w: 8), Text('Cuti disetujui · 1 Okt', style: ts(14, w: FontWeight.w700))]),
            const Gap(4),
            Text('Rudi Hartono (IT Manager) · 1 Okt 09:12\nHR Department · 1 Okt 14:30', style: ts(12, c: C.muted, h: 1.5)),
            const Divider(color: C.line, height: 24),
            Row(children: [
              const Icon(Icons.payments_outlined, color: C.green),
              const Gap(0, w: 8),
              Expanded(child: Text('Lumpsum cuti ditransfer · 2 Okt', style: ts(14, w: FontWeight.w700))),
              const Pill('Ditransfer', tone: Tone.ok),
            ]),
            const Gap(8),
            Text('Rp 1.750.000', style: ts(24, w: FontWeight.w800)),
            Text('BRI •••• 4521', style: ts(12, c: C.muted)),
            TextButton(onPressed: () => setState(() => ls = !ls), style: TextButton.styleFrom(padding: EdgeInsets.zero), child: Text(ls ? 'Sembunyikan rincian' : 'Lihat rincian lumpsum', style: ts(13, w: FontWeight.w700, c: C.blue))),
            if (ls) ...[
              const KV('Tunjangan cuti roster', 'Rp 1.250.000'),
              const KV('Uang makan (2 × Rp 150.000)', 'Rp 300.000'),
              const KV('Transport lokal kota tujuan', 'Rp 200.000'),
              const Gap(6),
              Text('Diajukan HR (Siti Rahmawati) · 28 Sep\nDisetujui Finance · 30 Sep\nDitransfer ke BRI •••• 4521 a.n. Budi Santoso · 2 Okt 10:15', style: ts(12, c: C.muted, h: 1.6)),
            ],
          ]),
        ),
        day('SENIN, 5 OKT · BERANGKAT', [
          ev('05:30', Icons.directions_bus_outlined, C.blueSoft, C.blue, 'Jemputan ke bandara', 'Lobby Mess Blok C → Bandara KDI', chips: ['BUS-07', 'Kursi 14', 'Rahmat Hidayat']),
          ev('09:40', Icons.flight_takeoff, C.purpleBg, C.purple, 'Penerbangan KDI → UPG', 'XX 1234 · tiba 10:55 · booking K7P2QD', chips: ['Kursi 12A', 'Bagasi 20 kg']),
        ]),
        day('5 – 10 OKT · MASA OFF', [ev('', Icons.beach_access_outlined, C.orangeBg, C.orangeFg, 'Istirahat di Makassar', 'Hubungi HR bila ada perubahan jadwal kembali.')]),
        day('MINGGU, 11 OKT · KEMBALI', [
          ev('07:10', Icons.flight_land, C.purpleBg, C.purple, 'Penerbangan UPG → KDI', 'XX 1231 · tiba 08:25 · booking M3RX8T', chips: ['Kursi 8C']),
          ev('08:45', Icons.directions_bus_outlined, C.blueSoft, C.blue, 'Jemputan ke site', 'Bandara KDI (kedatangan) → Mess Blok C', chips: ['BUS-03', 'Kursi 6', 'Yusuf Rahman']),
        ]),
        day('SENIN, 12 OKT · MASUK KERJA', [
          ev('18:00', Icons.monitor_heart_outlined, C.redBg, C.red, 'Isi Fit To Work', 'Wajib sebelum shift dimulai'),
          ev('19:00', Icons.nights_stay_outlined, C.navy, Colors.white, 'Night shift dimulai', '12 – 25 Okt · 19:00 – 07:00'),
        ]),
        const Gap(6),
        OutlineButton('Lihat detail jemputan & tiket', onTap: () => Navigator.pushNamed(context, R.perjalanan)),
      ]),
    );
  }
}
