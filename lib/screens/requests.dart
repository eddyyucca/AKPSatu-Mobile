import 'package:flutter/material.dart' hide Text;
import '../l10n/lang.dart';
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
  const InpText({super.key, this.initial, this.hint, this.readOnly = false, this.type, this.fontSize = 15, this.height = 48, this.small = false});
  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: TextFormField(
          initialValue: initial,
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

/// `<textarea class="ta">`.
class TaField extends StatelessWidget {
  final String initial;
  final int rows;
  const TaField(this.initial, {super.key, this.rows = 2});
  @override
  Widget build(BuildContext context) => SizedBox(
        height: rows == 2 ? 64 : 83,
        child: TextFormField(
          initialValue: initial,
          maxLines: null,
          expands: true,
          textAlignVertical: TextAlignVertical.top,
          style: ts(15, w: FontWeight.w400),
          decoration: InputDecoration(
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

Widget _sentView(BuildContext context, {required String title, required List<InlineSpan> body, required List<(String, String)> rows, required String cta, required VoidCallback onCta, required VoidCallback onReset}) => SingleChildScrollView(
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
        InkWell(onTap: onReset, child: SizedBox(height: 44, child: Center(child: Text('Ajukan lagi (demo)', style: ts(14, w: FontWeight.w700, c: C.blue))))),
      ]),
    );

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});
  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  String jenis = 'Cuti Tahunan';
  DateTime start = DateTime(2026, 11, 9), end = DateTime(2026, 11, 11);
  String pengganti = 'Fajar Nugroho · Network Engineer';
  String kota = 'Makassar (UPG)';
  bool tiket = false, jemput = false, sent = false;

  static const jenisList = ['Cuti Tahunan', 'Cuti Roster', 'Cuti Sakit', 'Cuti Melahirkan', 'Cuti Menikah', 'Cuti Duka', 'Cuti Khusus'];

  int get days => end.difference(start).inDays + 1;
  bool get validRange => days >= 1;
  bool get isTahunan => jenis == 'Cuti Tahunan';
  bool get over => validRange && isTahunan && days > 9;
  bool get travel => tiket || jemput;

  @override
  Widget build(BuildContext context) {
    final canSend = validRange && !over;
    final steps = <(String, String, String)>[
      ('1', 'Rudi Hartono', 'IT Manager · atasan langsung'),
      ('2', 'HR Department', 'Verifikasi saldo cuti & data'),
      if (travel) ('3', 'GA / Travel', 'Pesan tiket, jadwalkan jemputan · lumpsum oleh HR'),
      ('${(travel ? 3 : 2) + 1}', 'Itinerary terbit', 'Detail perjalanan muncul di aplikasi'),
    ];
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(children: [
          PageHeader(sent ? 'Ajukan Cuti' : 'Ajukan Cuti'),
          Expanded(
            child: sent
                ? _sentView(
                    context,
                    title: 'Pengajuan terkirim',
                    body: [const TextSpan(text: 'Menunggu persetujuan '), TextSpan(text: 'Rudi Hartono', style: ts(15, w: FontWeight.w700, c: C.text2, h: 1.5)), const TextSpan(text: ' (IT Manager). Anda akan menerima notifikasi setiap ada perubahan status.')],
                    rows: [
                      ('No. pengajuan', 'CT-2026-11-0031'),
                      ('Jenis', jenis),
                      ('Periode', '${fmtDate(start)} – ${fmtDate(end)}'),
                      ('Durasi', '$days hari'),
                      ('Perjalanan', tiket && jemput ? 'Tiket + jemputan' : tiket ? 'Tiket pesawat' : jemput ? 'Jemputan' : 'Tidak ada'),
                    ],
                    cta: 'Lihat Cuti Tahunan',
                    onCta: () => Navigator.pop(context),
                    onReset: () => setState(() => sent = false),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(color: C.blueSoft, borderRadius: BorderRadius.circular(12)),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('Sisa cuti tahunan', style: ts(14, w: FontWeight.w600, c: C.blueFg)),
                          Text('9 hari', style: ts(18, w: FontWeight.w800, c: C.blueFg)),
                        ]),
                      ),
                      const Gap(16),
                      Fld(
                        'Jenis cuti',
                        SelectInp<String>(
                          value: jenis,
                          items: jenisList,
                          onChanged: (v) => setState(() {
                            jenis = v;
                            if (v == 'Cuti Roster') {
                              tiket = true;
                              jemput = true;
                            }
                            if (v == 'Cuti Sakit') {
                              tiket = false;
                              jemput = false;
                            }
                          }),
                        ),
                        hint: 'Daftar jenis cuti diatur HR dari web AKPSatu',
                      ),
                      const Gap(16),
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(child: Fld('Tanggal mulai', DateInp(start, (d) => setState(() => start = d), fontSize: 14, padX: 10))),
                        const Gap(0, w: 12),
                        Expanded(child: Fld('Tanggal selesai', DateInp(end, (d) => setState(() => end = d), fontSize: 14, padX: 10))),
                      ]),
                      if (validRange) ...[
                        const Gap(16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(12)),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Flexible(child: Text.rich(TextSpan(children: [TextSpan(text: 'Total ', style: ts(14, c: C.text2)), TextSpan(text: '$days hari', style: ts(18, w: FontWeight.w700))]))),
                            if (isTahunan) Text.rich(TextSpan(children: [TextSpan(text: 'Sisa setelah cuti: ', style: ts(13, c: C.muted)), TextSpan(text: '${9 - days} hari', style: ts(13, w: FontWeight.w700))])),
                          ]),
                        ),
                      ],
                      if (!validRange) ...[const Gap(16), Text('Tanggal selesai harus sama atau setelah tanggal mulai.', style: ts(13, w: FontWeight.w600, c: C.red))],
                      if (over) ...[const Gap(16), Text('Durasi melebihi sisa cuti tahunan (9 hari).', style: ts(13, w: FontWeight.w600, c: C.red))],
                      const Gap(16),
                      const Fld('Alasan', TaField('Acara keluarga di Makassar.')),
                      const Gap(16),
                      Fld('Pengganti tugas', SelectInp<String>(value: pengganti, items: const ['Fajar Nugroho · Network Engineer', 'Agus Salim · IT Support', 'Rina Kartika · IT Support'], onChanged: (v) => setState(() => pengganti = v))),
                      const Gap(16),
                      const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(child: Fld('Alamat selama cuti', InpText(initial: 'Makassar'))),
                        Gap(0, w: 12),
                        Expanded(child: Fld('No. darurat', InpText(hint: '08xx', type: TextInputType.phone))),
                      ]),
                      if (jenis == 'Cuti Sakit') ...[
                        const Gap(16),
                        Fld(
                          'Surat dokter',
                          InkWell(
                            onTap: () => toast(context, 'Pilih berkas (demo)'),
                            child: Container(
                              height: 48,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              alignment: Alignment.centerLeft,
                              decoration: _inp(),
                              child: Text('Pilih File  Tidak ada file yang dipilih', style: ts(14, w: FontWeight.w400)),
                            ),
                          ),
                        ),
                      ],
                      if (jenis != 'Cuti Sakit') ...[
                        const Gap(16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Padding(padding: const EdgeInsets.only(top: 12, bottom: 4), child: Text('Kebutuhan perjalanan', style: ts(14, w: FontWeight.w800))),
                            SwitchRow('Tiket pesawat', 'Dipesankan oleh GA / Travel', tiket, (v) => setState(() => tiket = v), first: true),
                            SwitchRow('Jemputan bandara', 'Mess ↔ bandara, berangkat & kembali', jemput, (v) => setState(() => jemput = v)),
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
                      const Gap(16),
                      PrimaryButton(canSend ? 'Kirim Pengajuan' : 'Periksa tanggal cuti', height: 54, onTap: canSend ? () => setState(() => sent = true) : null),
                    ]),
                  ),
          ),
        ]),
      ),
    );
  }
}
