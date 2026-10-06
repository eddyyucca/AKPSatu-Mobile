import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

class _Item {
  final String type, ini, name, role, title, sub, when, hint;
  final Color avBg, avFg, hintFg;
  const _Item(this.type, this.ini, this.avBg, this.avFg, this.name, this.role, this.title, this.sub, this.when, this.hint, this.hintFg);
}

const _grey = Color(0xFF3D4B5E);
const _pend = <_Item>[
  _Item('Cuti', 'AS', Color(0xFFDCE7FB), Color(0xFF1748AE), 'Agus Salim', 'IT Support · AKP014', 'Cuti Tahunan · 3 hari', '12 – 14 Okt 2026 · pengganti: Rina Kartika', '11:42', 'Mulai 8 hari lagi', _grey),
  _Item('Lembur', 'FN', Color(0xFFD8F1F0), Color(0xFF14655F), 'Fajar Nugroho', 'Network Engineer · AKP022', '3 jam', 'Sab, 3 Okt · 19:00 – 22:00 · Migrasi switch core', 'Kemarin', 'Sudah dikerjakan', _grey),
  _Item('Cuti', 'RK', Color(0xFFFBE3EC), Color(0xFF9C2155), 'Rina Kartika', 'IT Support · AKP031', 'Cuti Roster · 14 hari', '19 Okt – 1 Nov 2026 · + tiket & jemputan', 'Kemarin', 'Perlu diproses cepat: tiket dipesan GA', Color(0xFF9A4A06)),
  _Item('PTW', 'FN', Color(0xFFD8F1F0), Color(0xFF14655F), 'Fajar Nugroho', 'Network Engineer · AKP022', 'Bekerja di ketinggian', 'Sel, 6 Okt · 13:00 – 16:00 · Penarikan kabel antena Pos 3', '10:05', 'Checklist lengkap · lanjut ke HSE setelah Anda setujui', _grey),
  _Item('Lembur', 'DA', Color(0xFFECE5FB), Color(0xFF5B32B8), 'Dewi Anggraini', 'IT Programmer · AKP045', '2 jam', 'Jum, 2 Okt · 19:00 – 21:00 · Deploy aplikasi FTW', '2 Okt', '', _grey),
  _Item('Lembur', 'FN', Color(0xFFD8F1F0), Color(0xFF14655F), 'Fajar Nugroho', 'Network Engineer · AKP022', '4 jam', 'Kam, 1 Okt · 18:00 – 22:00 · Backup NAS', '1 Okt', 'Menunggu 3 hari', Color(0xFFB42318)),
];
const _done = <_Item>[
  _Item('Cuti', 'DA', Color(0xFFECE5FB), Color(0xFF5B32B8), 'Dewi Anggraini', 'IT Programmer · AKP045', 'Cuti Sakit · 1 hari', '28 Sep 2026', '28 Sep', 'Disetujui', Color(0xFF1A6B3A)),
  _Item('Lembur', 'AS', Color(0xFFDCE7FB), Color(0xFF1748AE), 'Agus Salim', 'IT Support · AKP014', '2 jam', 'Ming, 27 Sep · 19:00 – 21:00', '27 Sep', 'Disetujui', Color(0xFF1A6B3A)),
  _Item('Lembur', 'RK', Color(0xFFFBE3EC), Color(0xFF9C2155), 'Rina Kartika', 'IT Support · AKP031', '5 jam', 'Sab, 26 Sep · 17:00 – 22:00', '26 Sep', 'Ditolak · melebihi batas 4 jam/hari', Color(0xFFB42318)),
];

class ApprovalInboxScreen extends StatefulWidget {
  const ApprovalInboxScreen({super.key});
  @override
  State<ApprovalInboxScreen> createState() => _ApprovalInboxScreenState();
}

class _ApprovalInboxScreenState extends State<ApprovalInboxScreen> {
  bool pend = true;
  String f = 'Semua';

  (Color, Color) _tc(String t) => switch (t) {
        'Cuti' => (C.orangeBg, C.orangeFg),
        'Lembur' => (C.blueSoft, C.blueFg),
        _ => (C.redBg, const Color(0xFF9C2B1F)),
      };

  Widget _segBtn(String t, bool on, VoidCallback tap) => Expanded(
        child: Material(
          color: on ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          child: InkWell(borderRadius: BorderRadius.circular(9), onTap: tap, child: SizedBox(height: 40, child: Center(child: Text(t, style: ts(14, w: on ? FontWeight.w700 : FontWeight.w600, c: on ? C.text : C.muted))))),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final src = pend ? _pend : _done;
    final items = src.where((x) => f == 'Semua' || x.type == f).toList();
    int count(String t) => src.where((x) => t == 'Semua' || x.type == t).length;
    return Scaffold(
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
                Text('Persetujuan', style: ts(18, w: FontWeight.w800, h: 1.3)),
                Text('Eddy Adha Saputra · Supervisor IT · 4 anggota tim', style: ts(12, c: C.muted, h: 1.3)),
              ])),
            ]),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: C.line))),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: const Color(0xFFEEF1F5), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [_segBtn('Menunggu (${_pend.length})', pend, () => setState(() => pend = true)), const Gap(0, w: 4), _segBtn('Selesai', !pend, () => setState(() => pend = false))]),
              ),
              const Gap(10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  for (final t in const ['Semua', 'Cuti', 'Lembur', 'PTW']) ...[
                    if (t != 'Semua') const Gap(0, w: 8),
                    Material(
                      color: t == f ? C.blue : Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99), side: BorderSide(color: t == f ? C.blue : C.input)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(99),
                        onTap: () => setState(() => f = t),
                        child: Container(height: 40, padding: const EdgeInsets.symmetric(horizontal: 12), alignment: Alignment.center, child: Text('$t (${count(t)})', style: ts(13, w: t == f ? FontWeight.w700 : FontWeight.w600, c: t == f ? Colors.white : C.text2))),
                      ),
                    ),
                  ],
                ]),
              ),
            ]),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const Gap(10),
                  _card(context, items[i]),
                ],
                if (items.isEmpty) Padding(padding: const EdgeInsets.only(top: 40), child: Text('Tidak ada pengajuan di kategori ini.', style: ts(14, c: C.muted))),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _card(BuildContext context, _Item it) {
    final (tbg, tfg) = _tc(it.type);
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: C.line)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.pushNamed(context, R.approvalDetail),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 42, height: 42, alignment: Alignment.center, decoration: BoxDecoration(color: it.avBg, shape: BoxShape.circle), child: Text(it.ini, style: ts(14, w: FontWeight.w800, c: it.avFg))),
            const Gap(0, w: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(it.name, style: ts(15, w: FontWeight.w700)),
                  Text(it.when, style: ts(11, c: C.muted)),
                ]),
                const Gap(3),
                Text(it.role, style: ts(12, c: C.muted)),
                const Gap(7),
                Row(children: [
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: tbg, borderRadius: BorderRadius.circular(99)), child: Text(it.type, style: ts(12, w: FontWeight.w600, c: tfg))),
                  const Gap(0, w: 6),
                  Expanded(child: Text(it.title, style: ts(14, w: FontWeight.w700))),
                ]),
                const Gap(3),
                Text(it.sub, style: ts(13, c: C.text2)),
                if (it.hint.isNotEmpty) ...[const Gap(5), Text(it.hint, style: ts(12, w: FontWeight.w700, c: it.hintFg))],
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

class ApprovalDetailScreen extends StatefulWidget {
  const ApprovalDetailScreen({super.key});
  @override
  State<ApprovalDetailScreen> createState() => _ApprovalDetailScreenState();
}

class _ApprovalDetailScreenState extends State<ApprovalDetailScreen> {
  String d = 'pending'; // pending | rejecting | approved | rejected
  String reason = '';

  Widget _card(Widget child, {Color border = C.line}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: border), borderRadius: BorderRadius.circular(14)),
        child: child,
      );

  Widget _row(String k, String v, {bool first = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(border: first ? null : const Border(top: BorderSide(color: Color(0xFFEEF1F5)))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(k, style: ts(14, c: C.muted)),
          const Gap(0, w: 16),
          Flexible(child: Text(v, textAlign: TextAlign.right, style: ts(14, w: FontWeight.w600))),
        ]),
      );

  Widget _chk(String ic, Color c, String t, {double sw = 2.4}) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.only(top: 1), child: Ic(ic, size: 18, stroke: sw, color: c)),
        const Gap(0, w: 10),
        Expanded(child: Text(t, style: ts(13, c: C.text2, h: 1.45))),
      ]);

  Widget _ta(String hint) => SizedBox(
        height: 62,
        child: TextField(
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          style: ts(14, w: FontWeight.w400),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ts(14, c: const Color(0xFF757575), w: FontWeight.w400),
            filled: true,
            fillColor: Colors.white,
            isDense: true,
            contentPadding: const EdgeInsets.fromLTRB(9, 11, 9, 11),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: C.input)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: C.input)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: C.blue, width: 2)),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final steps = switch (d) {
      'approved' => const [
          ('✓', C.green, Colors.white, 'Diajukan', 'Agus Salim · hari ini 11:42', false),
          ('✓', C.green, Colors.white, 'Atasan langsung', 'Eddy Adha Saputra (Anda) · disetujui baru saja', false),
          ('3', C.orange, Colors.white, 'HR Department', 'Menunggu verifikasi saldo · Siti Rahmawati', false),
          ('4', Color(0xFFEEF1F5), C.muted, 'Selesai', 'Agus menerima notifikasi & cuti masuk roster', true),
        ],
      'rejected' => const [
          ('✓', C.green, Colors.white, 'Diajukan', 'Agus Salim · hari ini 11:42', false),
          ('✕', C.red, Colors.white, 'Atasan langsung', 'Eddy Adha Saputra (Anda) · ditolak baru saja', false),
          ('3', Color(0xFFEEF1F5), C.muted, 'HR Department', 'Tidak diteruskan', true),
          ('4', Color(0xFFEEF1F5), C.muted, 'Selesai', 'Agus menerima notifikasi penolakan', true),
        ],
      _ => const [
          ('✓', C.green, Colors.white, 'Diajukan', 'Agus Salim · hari ini 11:42', false),
          ('2', C.orange, Colors.white, 'Atasan langsung', 'Eddy Adha Saputra (Anda) · menunggu keputusan', false),
          ('3', Color(0xFFEEF1F5), C.muted, 'HR Department', 'Verifikasi saldo cuti', true),
          ('4', Color(0xFFEEF1F5), C.muted, 'Selesai', 'Agus menerima notifikasi & cuti masuk roster', true),
        ],
    };
    final (bt, bbg, bfg) = switch (d) {
      'approved' => ('Diteruskan ke HR', C.blueSoft, C.blueFg),
      'rejected' => ('Ditolak', C.redBg, C.red),
      _ => ('Menunggu Anda', C.orangeBg, C.orangeFg),
    };
    final done = d == 'approved' || d == 'rejected';
    Widget bar(Widget child, {EdgeInsets pad = const EdgeInsets.fromLTRB(16, 12, 16, 20)}) => Container(width: double.infinity, padding: pad, decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: C.line))), child: child);
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(children: [
          const PageHeader('Persetujuan Cuti'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: bbg, borderRadius: BorderRadius.circular(99)), child: Text(bt, style: ts(12, w: FontWeight.w700, c: bfg))),
                    Flexible(child: Text('CT-2026-10-0027', style: ts(12, c: C.muted))),
                  ]),
                  const Gap(12),
                  Row(children: [
                    Container(width: 52, height: 52, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFDCE7FB), shape: BoxShape.circle), child: Text('AS', style: ts(17, w: FontWeight.w800, c: C.blueFg))),
                    const Gap(0, w: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Agus Salim', style: ts(17, w: FontWeight.w800, h: 1.4)),
                      Text('IT Support · IT Department', style: ts(13, c: C.text2, h: 1.4)),
                      Text('AKP014 · Diajukan hari ini 11:42', style: ts(12, c: C.muted, h: 1.4)),
                    ])),
                  ]),
                  const Gap(12),
                  _row('Jenis', 'Cuti Tahunan', first: true),
                  _row('Periode', 'Sen – Rab, 12 – 14 Okt 2026'),
                  _row('Durasi', '3 hari'),
                  _row('Sisa cuti', '10 → 7 hari'),
                  _row('Alasan', 'Acara pernikahan saudara'),
                  _row('Pengganti', 'Rina Kartika'),
                  _row('Perjalanan', 'Tidak perlu tiket / jemputan'),
                ])),
                const Gap(12),
                _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Dampak ke tim (12 – 14 Okt)', style: ts(14, w: FontWeight.w800)),
                  const Gap(10),
                  _chk('check', C.greenFg, '3 dari 4 anggota tim tetap bertugas'),
                  const Gap(10),
                  _chk('check', C.greenFg, 'Pengganti (Rina Kartika) masuk Day shift di tanggal tersebut'),
                  const Gap(10),
                  _chk('alert', C.orange, 'Rina Kartika juga mengajukan Cuti Roster mulai 19 Okt (tidak bentrok)', sw: 2.2),
                ])),
                const Gap(12),
                _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Alur persetujuan', style: ts(14, w: FontWeight.w800)),
                  const Gap(12),
                  for (var i = 0; i < steps.length; i++)
                    IntrinsicHeight(
                      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        SizedBox(
                          width: 28,
                          child: Column(children: [
                            Container(width: 28, height: 28, alignment: Alignment.center, decoration: BoxDecoration(color: steps[i].$2, shape: BoxShape.circle), child: Text(steps[i].$1, style: ts(13, w: FontWeight.w800, c: steps[i].$3))),
                            if (i < steps.length - 1) Expanded(child: Container(width: 2, constraints: const BoxConstraints(minHeight: 14), color: (i == 0 || (i == 1 && d == 'approved')) ? C.green : const Color(0xFFC4CDD9))),
                          ]),
                        ),
                        const Gap(0, w: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(steps[i].$4, style: ts(14, w: FontWeight.w700, c: steps[i].$6 ? C.muted : C.text, h: 1.4)),
                              Text(steps[i].$5, style: ts(12, c: C.muted, h: 1.4)),
                            ]),
                          ),
                        ),
                      ]),
                    ),
                ])),
                if (d == 'pending') ...[
                  const Gap(12),
                  Text('Catatan untuk Agus (opsional)', style: ts(13, w: FontWeight.w600, c: C.text2)),
                  const Gap(6),
                  _ta('Contoh: pastikan serah terima tiket helpdesk ke Rina'),
                ],
                if (d == 'rejecting') ...[
                  const Gap(12),
                  _card(
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Alasan penolakan (wajib)', style: ts(14, w: FontWeight.w800, c: C.red)),
                      const Gap(10),
                      Wrap(spacing: 8, runSpacing: 8, children: [
                        for (final r in const ['Kebutuhan operasional', 'Bentrok jadwal tim', 'Saldo tidak cukup', 'Lainnya'])
                          Material(
                            color: r == reason ? C.redBg : Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99), side: BorderSide(color: r == reason ? C.red : C.input, width: r == reason ? 2 : 1)),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(99),
                              onTap: () => setState(() => reason = r),
                              child: Container(constraints: const BoxConstraints(minHeight: 40), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), alignment: Alignment.center, child: Text(r, style: ts(13, w: r == reason ? FontWeight.w700 : FontWeight.w600, c: r == reason ? C.red : C.text2))),
                            ),
                          ),
                      ]),
                      const Gap(10),
                      Text('Keterangan', style: ts(13, w: FontWeight.w600, c: C.text2)),
                      const Gap(10),
                      _ta('Jelaskan agar karyawan bisa mengajukan ulang'),
                    ]),
                    border: const Color(0xFFF2B8B5),
                  ),
                ],
                if (done) ...[
                  const Gap(12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(color: d == 'approved' ? C.greenBg : C.redBg, borderRadius: BorderRadius.circular(14)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(d == 'approved' ? 'Disetujui' : 'Ditolak', style: ts(15, w: FontWeight.w800, c: d == 'approved' ? const Color(0xFF14532D) : const Color(0xFF7A1A12))),
                      const Gap(4),
                      Text(
                        d == 'approved' ? 'Pengajuan diteruskan ke HR untuk verifikasi saldo. Agus Salim mendapat notifikasi status.' : 'Alasan: $reason. Agus Salim mendapat notifikasi dan bisa mengajukan ulang.',
                        style: ts(13, c: d == 'approved' ? const Color(0xFF14532D) : const Color(0xFF7A1A12), h: 1.5),
                      ),
                    ]),
                  ),
                ],
              ]),
            ),
          ),
          if (d == 'pending')
            bar(Row(children: [
              Expanded(
                child: Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: C.red, width: 1.5)),
                  child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => setState(() => d = 'rejecting'), child: SizedBox(height: 52, child: Center(child: Text('Tolak', style: ts(16, w: FontWeight.w700, c: C.red))))),
                ),
              ),
              const Gap(0, w: 12),
              Expanded(
                child: Material(
                  color: C.green,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => setState(() => d = 'approved'), child: SizedBox(height: 52, child: Center(child: Text('Setujui', style: ts(16, w: FontWeight.w700, c: Colors.white))))),
                ),
              ),
            ])),
          if (d == 'rejecting')
            bar(Row(children: [
              Expanded(
                child: Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: C.input)),
                  child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () => setState(() { d = 'pending'; reason = ''; }), child: SizedBox(height: 52, child: Center(child: Text('Batal', style: ts(16, w: FontWeight.w700))))),
                ),
              ),
              const Gap(0, w: 12),
              Expanded(
                child: Material(
                  color: reason.isEmpty ? C.line : C.red,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(borderRadius: BorderRadius.circular(12), onTap: reason.isEmpty ? null : () => setState(() => d = 'rejected'), child: SizedBox(height: 52, child: Center(child: Text('Kirim Penolakan', style: ts(16, w: FontWeight.w700, c: reason.isEmpty ? C.muted : Colors.white))))),
                ),
              ),
            ])),
          if (done)
            bar(
              Column(children: [
                PrimaryButton('Kembali ke daftar (5 lagi)', onTap: () => Navigator.pop(context)),
                const Gap(4),
                InkWell(onTap: () => setState(() { d = 'pending'; reason = ''; }), child: SizedBox(height: 44, child: Center(child: Text('Batalkan keputusan (demo)', style: ts(14, w: FontWeight.w700, c: C.blue))))),
              ]),
              pad: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            ),
        ]),
      ),
    );
  }
}
