import 'package:flutter/material.dart' hide Text;
import '../l10n/lang.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

class _Mi {
  final String label, ic, dept, keys;
  final Color bg, fg;
  final String? route;
  const _Mi(this.label, this.ic, this.bg, this.fg, this.dept, this.route, {this.keys = ''});
}

const _depts = <(String, String, Color)>[
  ('HR & Kepegawaian', 'Absensi, jadwal, cuti, lembur, pelatihan', Color(0xFF1E5BD7)),
  ('HSE & Keselamatan', 'Fit To Work, P2H, PTW', Color(0xFFB42318)),
  ('GA & Camp', 'Mess, perjalanan, jemputan, makan', Color(0xFFC2610C)),
  ('Kesehatan', 'Kebugaran dan layanan klinik', Color(0xFF1F7A47)),
  ('Operasional & Site', 'Aktivitas kerja, peta tambang, persetujuan', Color(0xFF0E2A47)),
  ('IT & Layanan', 'Helpdesk dan layanan digital', Color(0xFF5B32B8)),
];

const _all = <_Mi>[
  _Mi('Absensi', 'clock', Color(0xFFE6EEFD), Color(0xFF1E5BD7), 'HR & Kepegawaian', R.absensi, keys: 'kehadiran riwayat masuk pulang'),
  _Mi('Jadwal Kerja', 'roster', Color(0xFFD8F1F0), Color(0xFF14655F), 'HR & Kepegawaian', R.roster, keys: 'roster shift kalender'),
  _Mi('Cuti', 'leave', Color(0xFFFFF1E0), Color(0xFFC2610C), 'HR & Kepegawaian', R.cuti, keys: 'libur tahunan saldo'),
  _Mi('Lembur', 'overtime', Color(0xFFE6EEFD), Color(0xFF1748AE), 'HR & Kepegawaian', R.pengajuanLembur, keys: 'overtime jam kerja tambahan'),
  _Mi('Learning Center', 'learn', Color(0xFFEFE9FD), Color(0xFF5B32B8), 'HR & Kepegawaian', R.learning, keys: 'training pelatihan sertifikat'),
  _Mi('Slip Gaji', 'download', Color(0xFFE2F4E8), Color(0xFF1A6B3A), 'HR & Kepegawaian', null, keys: 'payroll gaji upah'),
  _Mi('Fit To Work', 'ftw', Color(0xFFFDE8E8), Color(0xFFB42318), 'HSE & Keselamatan', R.ftw, keys: 'ftw kesehatan sebelum kerja'),
  _Mi('P2H Online', 'truck', Color(0xFFFFF1E0), Color(0xFF9A4A06), 'HSE & Keselamatan', R.p2h, keys: 'kendaraan unit lv periksa harian'),
  _Mi('PTW Online', 'ptw', Color(0xFFFDE8E8), Color(0xFF9C2B1F), 'HSE & Keselamatan', R.ptw, keys: 'permit to work izin kerja'),
  _Mi('Camp Facility', 'camp', Color(0xFFE3E8EF), Color(0xFF0E2A47), 'GA & Camp', R.camp, keys: 'mess kamar laundry fasilitas'),
  _Mi('Komplain GA', 'wrench', Color(0xFFFFF1E0), Color(0xFFC2610C), 'GA & Camp', R.komplain, keys: 'komplain laporan keluhan fasilitas kamar housekeeping laundry mess ac rusak'),
  _Mi('Itinerary Cuti', 'plane', Color(0xFFFBE3EC), Color(0xFF9C2155), 'GA & Camp', R.itinerary, keys: 'perjalanan lumpsum tiket'),
  _Mi('Jemputan & Tiket', 'bus', Color(0xFFE6EEFD), Color(0xFF1E5BD7), 'GA & Camp', R.perjalanan, keys: 'bus bandara pesawat kursi'),
  _Mi('Barcode Makan', 'qr', Color(0xFFE2F4E8), Color(0xFF1A6B3A), 'GA & Camp', R.makan, keys: 'kantin menu jatah makan'),
  _Mi('Fitness', 'dumbbell', Color(0xFFE2F4E8), Color(0xFF1A6B3A), 'Kesehatan', R.fitness, keys: 'olahraga gym lari gps'),
  _Mi('Layanan Klinik', 'plus', Color(0xFFFDE8E8), Color(0xFFB42318), 'Kesehatan', null, keys: 'dokter obat berobat'),
  _Mi('My Activity', 'tasks', Color(0xFFE3E8EF), Color(0xFF0E2A47), 'Operasional & Site', R.myActivity, keys: 'form kerja tugas follow up laporan'),
  _Mi('Peta Tambang', 'pin', Color(0xFFE3E8EF), Color(0xFF0E2A47), 'Operasional & Site', R.peta, keys: 'mine plan progres pit survey'),
  _Mi('Persetujuan', 'approve', Color(0xFFE6EEFD), Color(0xFF1E5BD7), 'Operasional & Site', R.approval, keys: 'approval atasan setujui'),
  _Mi('Helpdesk IT', 'wrench', Color(0xFFEFE9FD), Color(0xFF5B32B8), 'IT & Layanan', null, keys: 'tiket komputer jaringan printer bantuan'),
];

/// Menu layanan dikelompokkan per departemen + pencarian menu.
class MenuSection extends StatefulWidget {
  const MenuSection({super.key});
  @override
  State<MenuSection> createState() => _MenuSectionState();
}

class _MenuSectionState extends State<MenuSection> {
  final ctrl = TextEditingController();
  String q = '';

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  Widget _item(_Mi m) => Semantics(
        button: true,
        label: m.label,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => m.route != null ? Navigator.pushNamed(context, m.route!) : toast(context, '${m.label} segera hadir'),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 84),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
              child: Column(children: [
                Stack(clipBehavior: Clip.none, children: [
                  Container(width: 46, height: 46, decoration: BoxDecoration(color: m.bg, borderRadius: BorderRadius.circular(14)), child: Center(child: Ic(m.ic, size: 22, color: m.fg))),
                  if (m.route == null)
                    Positioned(
                      top: -5,
                      right: -9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(color: C.orange, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.white, width: 1.5)),
                        child: Text('Segera', style: ts(8, w: FontWeight.w800, c: Colors.white, h: 1.2)),
                      ),
                    ),
                ]),
                const Gap(7),
                Text(m.label, textAlign: TextAlign.center, style: ts(11, w: FontWeight.w600, h: 1.25)),
              ]),
            ),
          ),
        ),
      );

  Widget _grid(List<_Mi> items) => Column(children: [
        for (var r = 0; r < items.length; r += 4) ...[
          if (r > 0) const Gap(4),
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (var c = r; c < r + 4; c++) ...[
                if (c > r) const Gap(0, w: 2),
                Expanded(child: c < items.length ? _item(items[c]) : const SizedBox()),
              ],
            ]),
          ),
        ],
      ]);

  @override
  Widget build(BuildContext context) {
    final query = q.trim().toLowerCase();
    final found = query.isEmpty ? <_Mi>[] : _all.where((m) => '${m.label} ${tr(m.label)} ${m.dept} ${tr(m.dept)} ${m.keys}'.toLowerCase().contains(query)).toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            height: 44,
            child: TextField(
              controller: ctrl,
              onChanged: (v) => setState(() => q = v),
              textInputAction: TextInputAction.search,
              style: ts(14, w: FontWeight.w400),
              decoration: InputDecoration(
                hintText: tr('Cari menu (mis. cuti, PTW, makan)'),
                hintStyle: ts(14, c: const Color(0xFF757575), w: FontWeight.w400),
                filled: true,
                fillColor: C.bg,
                contentPadding: EdgeInsets.zero,
                prefixIcon: const Padding(padding: EdgeInsets.all(12), child: Ic.path('M11 4a7 7 0 1 0 0 14 7 7 0 0 0 0-14zM21 21l-4.5-4.5', color: C.muted, size: 20)),
                suffixIcon: q.isEmpty
                    ? null
                    : IconButton(
                        tooltip: tr('Hapus pencarian'),
                        icon: const Ic('close', size: 18, stroke: 2, color: C.muted),
                        onPressed: () => setState(() {
                          ctrl.clear();
                          q = '';
                        }),
                      ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.blue, width: 1.5)),
              ),
            ),
          ),
        ),
        const Gap(8),
        if (query.isNotEmpty) ...[
          Padding(padding: const EdgeInsets.fromLTRB(8, 4, 8, 6), child: Text('${found.length} hasil untuk "${q.trim()}"', style: ts(12, w: FontWeight.w700, c: C.muted))),
          if (found.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8), child: Center(child: Text('Menu tidak ditemukan. Coba kata kunci lain.', textAlign: TextAlign.center, style: ts(13, c: C.muted))))
          else
            _grid(found),
        ] else
          for (final d in _depts) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 8, 2),
              child: Row(children: [
                Container(width: 4, height: 14, decoration: BoxDecoration(color: d.$3, borderRadius: BorderRadius.circular(2))),
                const Gap(0, w: 8),
                Text(d.$1, style: ts(13, w: FontWeight.w800)),
              ]),
            ),
            Padding(padding: const EdgeInsets.fromLTRB(20, 0, 8, 4), child: Text(d.$2, style: ts(11, c: C.muted))),
            _grid(_all.where((m) => m.dept == d.$1).toList()),
          ],
      ]),
    );
  }
}
