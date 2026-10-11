import 'package:flutter/material.dart' hide Text;
import '../api/api.dart';
import '../l10n/lang.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

String fmtDate(DateTime d) => L.instance.shortDate(d);
String _p2(int n) => n < 10 ? '0$n' : '$n';

BoxDecoration _inp({Color bg = Colors.white}) => BoxDecoration(color: bg, border: Border.all(color: C.input), borderRadius: BorderRadius.circular(10));

/// Label + field (class `.fld`: gap 6).
class Fld extends StatelessWidget {
  final String label;
  final Widget child;
  final String? hint;
  const Fld(this.label, this.child, {super.key, this.hint});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: ts(13, w: FontWeight.w600, c: C.text2)),
        const Gap(6),
        child,
        if (hint != null) ...[const Gap(6), Text(hint!, style: ts(12, c: C.muted))],
      ]);
}

/// `<input class="inp">` (tinggi 48, radius 10).
class InpText extends StatelessWidget {
  final String? initial, hint;
  final bool readOnly;
  final TextInputType? type;
  final double fontSize;
  final double height;
  final bool small;
  final TextEditingController? controller;
  const InpText({super.key, this.initial, this.hint, this.readOnly = false, this.type, this.fontSize = 15, this.height = 48, this.small = false, this.controller});
  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: TextFormField(
          controller: controller,
          initialValue: controller == null ? initial : null,
          readOnly: readOnly,
          keyboardType: type,
          style: ts(fontSize, c: readOnly ? const Color(0xFF3D4B5E) : C.text, w: FontWeight.w400),
          decoration: InputDecoration(
            hintText: hint == null ? null : tr(hint!),
            hintStyle: ts(fontSize, c: const Color(0xFF757575), w: FontWeight.w400),
            filled: true,
            fillColor: readOnly ? C.bg : Colors.white,
            contentPadding: EdgeInsets.fromLTRB(small ? 7 : 9, 0, small ? 7 : 9, 0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: C.input)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: C.input)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: C.blue, width: 2)),
          ),
        ),
      );
}

/// `<textarea class="ta">`. [controller] opsional: saat diisi, teks dibaca/diubah lewat controller (nilai awal diabaikan);
/// tanpa controller, berperan statis seperti sebelumnya (`initialValue`, tidak bisa dibaca balik).
class TaField extends StatelessWidget {
  final String initial;
  final int rows;
  final TextEditingController? controller;
  final String? hint;
  const TaField(this.initial, {super.key, this.rows = 2, this.controller, this.hint});
  @override
  Widget build(BuildContext context) => SizedBox(
        height: rows == 2 ? 64 : 83,
        child: TextFormField(
          controller: controller,
          initialValue: controller == null ? initial : null,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          style: ts(15, w: FontWeight.w400),
          decoration: InputDecoration(
            hintText: hint == null ? null : tr(hint!),
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
}

/// `<select class="inp">`.
class SelectInp<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final String Function(T)? text;
  final double height;
  const SelectInp({super.key, required this.value, required this.items, required this.onChanged, this.text, this.height = 48});
  @override
  Widget build(BuildContext context) => Container(
        height: height,
        padding: const EdgeInsets.only(left: 16, right: 8),
        decoration: _inp(),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            icon: const Ic.path('M6 9l6 6 6-6', size: 14, stroke: 2.4),
            style: ts(15, w: FontWeight.w400),
            dropdownColor: Colors.white,
            items: [for (final i in items) DropdownMenuItem(value: i, child: Text(text?.call(i) ?? '$i', overflow: TextOverflow.ellipsis))],
            onChanged: (v) => onChanged(v as T),
          ),
        ),
      );
}

/// `<input type="date">` (dd/mm/yyyy + ikon kalender).
class DateInp extends StatelessWidget {
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  final double fontSize;
  final double padX;
  final DateTime? first, last; // batas tanggal yang bisa dipilih (bawaan 2026–2027)
  const DateInp(this.value, this.onChanged, {super.key, this.fontSize = 15, this.padX = 12, this.first, this.last});
  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () async {
          final d = await showDatePicker(context: context, initialDate: value, firstDate: first ?? DateTime(2026, 1, 1), lastDate: last ?? DateTime(2027, 12, 31));
          if (d != null) onChanged(d);
        },
        child: Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: padX),
          decoration: _inp(),
          child: Row(children: [
            Expanded(child: Text('${_p2(value.day)}/${_p2(value.month)}/${value.year}', style: ts(fontSize, w: FontWeight.w400))),
            const Ic('leave', size: 16, color: C.text2),
          ]),
        ),
      );
}

class SwitchRow extends StatelessWidget {
  final String title, sub;
  final bool value, first;
  final ValueChanged<bool> onChanged;
  const SwitchRow(this.title, this.sub, this.value, this.onChanged, {super.key, this.first = false});
  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(minHeight: 52),
        decoration: BoxDecoration(border: first ? null : const Border(top: BorderSide(color: Color(0xFFEEF1F5)))),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: ts(14, w: FontWeight.w600, h: 1.4)), Text(sub, style: ts(12, c: C.muted, h: 1.4))])),
          const Gap(0, w: 12),
          Semantics(
            toggled: value,
            label: title,
            child: GestureDetector(
              onTap: () => onChanged(!value),
              child: Container(
                width: 52,
                height: 32,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(color: value ? C.blue : const Color(0xFFC4CDD9), borderRadius: BorderRadius.circular(16)),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(width: 26, height: 26, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              ),
            ),
          ),
        ]),
      );
}

Widget _flowCard(List<(String, String, String)> steps) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Alur persetujuan', style: ts(14, w: FontWeight.w800)),
        for (final s in steps) ...[
          const Gap(12),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 26, height: 26, alignment: Alignment.center, decoration: const BoxDecoration(color: C.blueSoft, shape: BoxShape.circle), child: Text(s.$1, style: ts(12, w: FontWeight.w800, c: C.blueFg))),
            const Gap(0, w: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(s.$2, style: ts(14, w: FontWeight.w700, h: 1.4)), Text(s.$3, style: ts(12, c: C.muted, h: 1.4))])),
          ]),
        ],
      ]),
    );

Widget _dlCard(List<(String, String)> rows) => Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        for (var i = 0; i < rows.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(border: i == 0 ? null : const Border(top: BorderSide(color: Color(0xFFEEF1F5)))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(rows[i].$1, style: ts(14, c: C.muted)),
              const Gap(0, w: 16),
              Flexible(child: Text(rows[i].$2, textAlign: TextAlign.right, style: ts(14, w: FontWeight.w600))),
            ]),
          ),
      ]),
    );

Widget _sentView(BuildContext context, {required String title, required List<InlineSpan> body, required List<(String, String)> rows, required String cta, required VoidCallback onCta, required VoidCallback onReset, String resetLabel = 'Ajukan lagi (demo)'}) => SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: Column(children: [
        Container(width: 84, height: 84, decoration: const BoxDecoration(color: C.blueSoft, shape: BoxShape.circle), child: const Center(child: Ic('send', size: 40, stroke: 2, color: C.blue))),
        const Gap(14),
        Text(title, textAlign: TextAlign.center, style: ts(24, w: FontWeight.w800)),
        const Gap(14),
        Text.rich(TextSpan(children: body), textAlign: TextAlign.center, style: ts(15, c: C.text2, h: 1.5)),
        const Gap(14),
        _dlCard(rows),
        const Gap(14),
        PrimaryButton(cta, onTap: onCta),
        const Gap(14),
        InkWell(onTap: onReset, child: SizedBox(height: 44, child: Center(child: Text(resetLabel, style: ts(14, w: FontWeight.w700, c: C.blue))))),
      ]),
    );

/// Jenis cuti: label tampil (sudah ada di kamus terjemahan) -> kode yang dipakai server.
const _leaveTypeCodes = {
  'Cuti Tahunan': 'cuti_tahunan',
  'Cuti Roster': 'cuti_roster',
  'Cuti Sakit': 'cuti_sakit',
  'Cuti Melahirkan': 'cuti_melahirkan',
  'Cuti Menikah': 'cuti_menikah',
  'Cuti Duka': 'cuti_duka',
  'Cuti Khusus': 'cuti_khusus',
};

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});
  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

/// Ajukan cuti ke HRIS. Untuk Cuti Roster, tanggal & durasi mengikuti siklus roster karyawan (server menghitung,
/// termasuk hari buffer perjalanan untuk karyawan non-lokal) -- lihat `Modules/Leave` di HRIS. Jenis cuti lain
/// (Tahunan, Sakit, dll.) memakai tanggal bebas yang dipilih sendiri.
class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  String jenis = 'Cuti Tahunan';
  DateTime start = DateTime.now().add(const Duration(days: 14)), end = DateTime.now().add(const Duration(days: 16));
  String kota = 'Makassar (UPG)';
  bool tiket = false, jemput = false;
  final reason = TextEditingController(), address = TextEditingController(), phone = TextEditingController();

  static const jenisList = ['Cuti Tahunan', 'Cuti Roster', 'Cuti Sakit', 'Cuti Melahirkan', 'Cuti Menikah', 'Cuti Duka', 'Cuti Khusus'];

  Map<String, dynamic>? check;
  bool checking = false;
  String? checkError;

  bool submitting = false;
  String? submitError;
  Map<String, dynamic>? sent;

  String get _code => _leaveTypeCodes[jenis]!;
  bool get isRoster => check?['roster_driven'] == true;
  bool get isTahunan => jenis == 'Cuti Tahunan';
  int get days => isRoster ? ((check?['days'] as num?)?.toInt() ?? 0) : (end.difference(start).inDays + 1);
  bool get validRange => isRoster ? true : days >= 1;
  int? get _remaining => (check?['balance'] as Map?)?['remaining'] as int?;
  bool get over => isTahunan && validRange && _remaining != null && days > _remaining!;
  bool get canSend => !checking && !submitting && validRange && !over && (!isRoster || check?['ok'] == true);

  static String _iso(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    if (Session.instance.active) _loadCheck(autoCorrect: true);
  }

  @override
  void dispose() {
    reason.dispose();
    address.dispose();
    phone.dispose();
    super.dispose();
  }

  bool _expired(Object e) {
    if (e is ApiException && e.unauthenticated) {
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, R.login, (r) => false);
      return true;
    }
    return false;
  }

  /// [autoCorrect]: untuk Cuti Roster, bila tanggal saat ini di luar toleransi jendela siklus, langsung pakai
  /// tanggal saran server dan tanya ulang sekali -- dipakai saat pertama buka / ganti jenis, bukan saat pengguna
  /// sendiri memilih tanggal (supaya pilihan mereka tidak diam-diam ditimpa).
  Future<void> _loadCheck({bool autoCorrect = false}) async {
    setState(() {
      checking = true;
      checkError = null;
    });
    try {
      var c = await Api.instance.leaveCheck(_code, startDate: _iso(start));
      if (autoCorrect && c['roster_driven'] == true && c['ok'] != true) {
        final w = c['roster_window'] as Map<String, dynamic>?;
        if (w != null && w['start'] != null) {
          start = DateTime.parse(w['start'] as String);
          c = await Api.instance.leaveCheck(_code, startDate: _iso(start));
        }
      }
      if (!mounted) return;
      setState(() => check = c);
    } on ApiException catch (e) {
      if (_expired(e) || !mounted) return;
      setState(() => checkError = e.message);
    } finally {
      if (mounted) setState(() => checking = false);
    }
  }

  Future<void> _submit() async {
    if (!canSend || submitting) return;
    if (reason.text.trim().isEmpty) {
      setState(() => submitError = 'Isi alasan cuti.');
      return;
    }
    setState(() {
      submitting = true;
      submitError = null;
    });
    try {
      final r = await Api.instance.submitLeave(
        type: _code,
        startDate: _iso(start),
        endDate: isRoster ? null : _iso(end),
        reason: reason.text.trim(),
        addressDuringLeave: address.text.trim().isEmpty ? null : address.text.trim(),
        emergencyPhone: phone.text.trim().isEmpty ? null : phone.text.trim(),
        needsTicket: tiket,
        needsPickup: jemput,
        destinationCity: tiket ? kota : null,
      );
      if (mounted) setState(() => sent = r);
    } on ApiException catch (e) {
      if (_expired(e) || !mounted) return;
      setState(() => submitError = e.message);
      _loadCheck();   // jendela/saldo mungkin berubah
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  void _onJenisChanged(String v) {
    setState(() {
      jenis = v;
      if (v == 'Cuti Roster') {
        tiket = true;
        jemput = true;
      }
      if (v == 'Cuti Sakit') {
        tiket = false;
        jemput = false;
      }
      check = null;
      submitError = null;
    });
    _loadCheck(autoCorrect: true);
  }

  Widget _rosterPreview() {
    if (checking && check == null) return const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))));
    final c = check;
    if (c == null) return const SizedBox.shrink();
    if (c['ok'] != true) {
      return Notice((c['reason'] as String?) ?? 'Tanggal ini di luar jadwal siklus roster Anda.', tone: Tone.warn);
    }
    String? d(String? key) => c[key] as String?;
    return _dlCard([
      ('Tanggal mulai', fmtDate(DateTime.parse(c['start_date'] as String))),
      ('Tanggal selesai', fmtDate(DateTime.parse(c['end_date'] as String))),
      ('Durasi', '${c['days']} hari'),
      if (d('departure_half_day_date') != null) ('Berangkat (setengah hari)', fmtDate(DateTime.parse(d('departure_half_day_date')!))),
      if (d('travel_out_date') != null) ('Penerbangan pergi', fmtDate(DateTime.parse(d('travel_out_date')!))),
      if (d('travel_back_date') != null) ('Penerbangan pulang', fmtDate(DateTime.parse(d('travel_back_date')!))),
      if (d('return_half_day_date') != null) ('Kembali (setengah hari)', fmtDate(DateTime.parse(d('return_half_day_date')!))),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    L.watch(context);
    final balance = isTahunan ? (check?['balance'] as Map<String, dynamic>?) : null;
    final steps = <(String, String, String)>[
      ('1', 'Atasan langsung', 'Superintendent Seksi Anda'),
      ('2', 'HR Department', 'Verifikasi saldo cuti & data'),
      if (tiket || jemput) ('3', 'GA / Travel', 'Isi tiket & transport setelah disetujui'),
    ];
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(children: [
          const PageHeader('Ajukan Cuti'),
          Expanded(
            child: !Session.instance.active
                ? const Padding(padding: EdgeInsets.all(24), child: Notice('Masuk terlebih dahulu untuk mengajukan cuti.'))
                : sent != null
                    ? _sentView(
                        context,
                        title: 'Pengajuan terkirim',
                        body: const [TextSpan(text: 'Menunggu persetujuan atasan langsung, lalu konfirmasi HR. Anda akan menerima notifikasi setiap ada perubahan status.')],
                        rows: [
                          ('No. pengajuan', '#${sent!['id']}'),
                          ('Jenis', sent!['type_label'] as String? ?? jenis),
                          ('Periode', '${fmtDate(DateTime.parse(sent!['start_date'] as String))} – ${fmtDate(DateTime.parse(sent!['end_date'] as String))}'),
                          ('Durasi', '${sent!['days']} hari'),
                          ('Perjalanan', tiket && jemput ? 'Tiket + jemputan' : tiket ? 'Tiket pesawat' : jemput ? 'Jemputan' : 'Tidak ada'),
                        ],
                        cta: 'Kembali ke Beranda',
                        onCta: () => Navigator.pop(context),
                        resetLabel: 'Lihat Itinerary',
                        onReset: () => Navigator.pushReplacementNamed(context, R.itinerary, arguments: sent!['id'] as int),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          if (balance != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(color: C.blueSoft, borderRadius: BorderRadius.circular(12)),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Flexible(child: Text('Sisa cuti tahunan', style: ts(14, w: FontWeight.w600, c: C.blueFg))),
                                const Gap(0, w: 8),
                                Text('${balance['remaining']} hari', style: ts(18, w: FontWeight.w800, c: C.blueFg)),
                              ]),
                            ),
                            const Gap(16),
                          ],
                          Fld('Jenis cuti', SelectInp<String>(value: jenis, items: jenisList, onChanged: _onJenisChanged), hint: 'Daftar jenis cuti diatur HR dari web AKPSatu'),
                          const Gap(16),
                          if (isRoster) ...[
                            Fld('Tanggal mulai', DateInp(start, (d) {
                              setState(() => start = d);
                              _loadCheck();
                            }, fontSize: 14, padX: 10, first: DateTime.now(), last: DateTime.now().add(const Duration(days: 400)))),
                            const Gap(16),
                            _rosterPreview(),
                          ] else ...[
                            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Expanded(
                                child: Fld(
                                  'Tanggal mulai',
                                  DateInp(start, (d) {
                                    setState(() => start = d);
                                    if (isTahunan) _loadCheck();
                                  }, fontSize: 14, padX: 10),
                                ),
                              ),
                              const Gap(0, w: 12),
                              Expanded(child: Fld('Tanggal selesai', DateInp(end, (d) => setState(() => end = d), fontSize: 14, padX: 10, first: start))),
                            ]),
                            if (validRange) ...[
                              const Gap(16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(12)),
                                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Flexible(child: Text.rich(TextSpan(children: [TextSpan(text: 'Total ', style: ts(14, c: C.text2)), TextSpan(text: '$days hari', style: ts(18, w: FontWeight.w700))]))),
                                  if (isTahunan && _remaining != null) ...[
                                    const Gap(0, w: 8),
                                    Flexible(child: Text.rich(TextSpan(children: [TextSpan(text: 'Sisa setelah cuti: ', style: ts(13, c: C.muted)), TextSpan(text: '${_remaining! - days} hari', style: ts(13, w: FontWeight.w700))]), overflow: TextOverflow.ellipsis)),
                                  ],
                                ]),
                              ),
                            ],
                            if (!validRange) ...[const Gap(16), Text('Tanggal selesai harus sama atau setelah tanggal mulai.', style: ts(13, w: FontWeight.w600, c: C.red))],
                            if (over) ...[const Gap(16), Text('Durasi melebihi sisa cuti tahunan (${_remaining ?? 0} hari).', style: ts(13, w: FontWeight.w600, c: C.red))],
                          ],
                          if (checkError != null) ...[const Gap(16), Text(checkError!, style: ts(13, w: FontWeight.w600, c: C.red))],
                          const Gap(16),
                          Fld('Alasan', TaField('', controller: reason, hint: 'Jelaskan alasan cuti')),
                          const Gap(16),
                          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Expanded(child: Fld('Alamat selama cuti', InpText(controller: address))),
                            const Gap(0, w: 12),
                            Expanded(child: Fld('No. darurat', InpText(controller: phone, hint: '08xx', type: TextInputType.phone))),
                          ]),
                          if (jenis != 'Cuti Sakit') ...[
                            const Gap(16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Padding(padding: const EdgeInsets.only(top: 12, bottom: 4), child: Text('Kebutuhan perjalanan', style: ts(14, w: FontWeight.w800))),
                                SwitchRow('Tiket pesawat', 'Diisi oleh GA / Travel setelah disetujui', tiket, (v) => setState(() => tiket = v), first: true),
                                SwitchRow('Jemputan', 'Mess ↔ bandara, berangkat & kembali', jemput, (v) => setState(() => jemput = v)),
                                if (tiket)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4, bottom: 14),
                                    child: Fld('Kota tujuan', SelectInp<String>(value: kota, items: const ['Makassar (UPG)', 'Jakarta (CGK)', 'Surabaya (SUB)', 'Kota lain'], onChanged: (v) => setState(() => kota = v))),
                                  ),
                              ]),
                            ),
                          ],
                          const Gap(16),
                          _flowCard(steps),
                          if (submitError != null) ...[const Gap(16), Text(submitError!, style: ts(13, w: FontWeight.w600, c: C.red))],
                          const Gap(16),
                          PrimaryButton(submitting ? 'Mengirim...' : 'Kirim Pengajuan', height: 54, onTap: canSend ? _submit : null),
                        ]),
                      ),
          ),
        ]),
      ),
    );
  }
}
