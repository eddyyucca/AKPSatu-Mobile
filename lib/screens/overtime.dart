import 'package:flutter/material.dart' hide Text;
import '../api/api.dart';
import '../l10n/lang.dart';
import '../refresh.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';
import 'requests.dart';

/// Ajukan lembur ke HRIS. Aturan ikut server (sama dengan web HRIS):
///  - maksimal 2 jam per hari (nilainya dibaca dari server, bukan ditulis di sini);
///  - jam lembur harus sesuai absensi aktual: setelah jam pulang normal (hari kerja) sampai tap pulang, atau sejak tap masuk (hari off);
///  - diajukan setelah dikerjakan, jadi hanya tanggal yang sudah punya absen masuk dan pulang.
/// Pilihan jam dibatasi jendela dari server; server tetap memeriksa ulang saat pengajuan dikirim.
class OvertimeScreen extends StatefulWidget {
  const OvertimeScreen({super.key});
  @override
  State<OvertimeScreen> createState() => _OvertimeScreenState();
}

class _OvertimeScreenState extends State<OvertimeScreen> {
  static const _step = 5; // menit
  static const _daysBack = 60;

  late DateTime date = _today();
  Map<String, dynamic>? check; // jendela lembur dari absensi aktual + sisa kuota
  bool loadingCheck = false, unsupported = false;
  String? checkError;
  String? start, end;

  final reason = TextEditingController();
  bool submitting = false;
  String? submitError;
  Map<String, dynamic>? sent;

  List<Map<String, dynamic>> history = const [];
  bool loadingHistory = false;
  String? historyError;

  static DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static String _iso(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  static int _m(String hm) => int.parse(hm.substring(0, 2)) * 60 + int.parse(hm.substring(3, 5));
  static String _hm(int m) => '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    if (Session.instance.active) _reloadAll();
    Refresh.add(_reloadAll);
  }

  @override
  void dispose() {
    Refresh.remove(_reloadAll);
    reason.dispose();
    super.dispose();
  }

  Future<void> _reloadAll() async {
    if (!Session.instance.active || !mounted) return;
    await Future.wait([_loadCheck(), _loadHistory()]);
  }

  /// Sesi berakhir: kembali ke login.
  bool _expired(Object e) {
    if (e is ApiException && e.unauthenticated) {
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, R.login, (r) => false);
      return true;
    }
    return false;
  }

  Future<void> _loadCheck() async {
    setState(() {
      loadingCheck = true;
      checkError = null;
    });
    try {
      final c = await Api.instance.overtimeCheck(_iso(date));
      if (!mounted) return;
      setState(() {
        check = c;
        unsupported = false;
        _pickDefaults();
      });
    } on ApiException catch (e) {
      if (_expired(e) || !mounted) return;
      setState(() {
        if (e.status == 404) {
          // Server HRIS belum diperbarui: tanpa pemeriksaan absensi di aplikasi; server tetap memeriksa saat dikirim.
          unsupported = true;
          check = null;
          _pickDefaults();
        } else {
          check = null;
          checkError = e.message;
        }
      });
    } finally {
      if (mounted) setState(() => loadingCheck = false);
    }
  }

  Future<void> _loadHistory() async {
    setState(() {
      loadingHistory = true;
      historyError = null;
    });
    try {
      final h = await Api.instance.overtimes();
      if (mounted) setState(() => history = h);
    } on ApiException catch (e) {
      if (_expired(e) || !mounted) return;
      setState(() => historyError = e.message);
    } finally {
      if (mounted) setState(() => loadingHistory = false);
    }
  }

  // — Jendela jam —

  bool get _ok => unsupported || check?['ok'] == true;
  num get _maxHours => (check?['max_hours'] as num?) ?? 2;
  num get _perDay => (check?['max_hours_per_day'] as num?) ?? 2;

  /// Sisa kuota (menit) untuk tanggal ini.
  int get _quotaMin => (((check?['remaining_hours'] as num?) ?? _perDay) * 60).floor();

  int get _fromMin => unsupported ? 0 : _m(check!['from'] as String);
  int get _toMin => unsupported ? 24 * 60 - 1 : _m(check!['to'] as String);

  /// Batas durasi satu pengajuan (menit): kuota hari itu dan maksimal per pengajuan.
  int get _capMin => [_quotaMin, (_maxHours * 60).floor()].reduce((a, b) => a < b ? a : b);

  List<String> get _startItems {
    if (!_ok || _capMin < _step) return const [];
    return [for (var t = _fromMin; t + _step <= _toMin; t += _step) _hm(t)];
  }

  List<String> _endItems(String s) {
    final from = _m(s);
    final max = [_toMin, from + _capMin].reduce((a, b) => a < b ? a : b);
    return {for (var t = from + _step; t <= max; t += _step) _hm(t), if (max > from) _hm(max)}.toList()..sort();
  }

  /// Awal = awal jendela; akhir = selama yang diizinkan (kuota, maks. per pengajuan, atau tap pulang).
  void _pickDefaults() {
    final starts = _startItems;
    if (starts.isEmpty) {
      start = end = null;
      return;
    }
    start = starts.first;
    end = _endItems(start!).last;
  }

  int get _durMin => start == null || end == null ? 0 : _m(end!) - _m(start!);

  String _dur(int min) => min % 60 == 0 ? '${min ~/ 60} jam' : (min < 60 ? '$min menit' : '${min ~/ 60} jam ${min % 60} menit');

  String _hours(num h) => h == h.roundToDouble() ? '${h.toInt()}' : h.toString().replaceAll('.', ',');

  // — Aksi —

  Future<void> _submit() async {
    if (submitting || start == null || end == null) return;
    if (reason.text.trim().isEmpty) {
      setState(() => submitError = 'Isi uraian pekerjaan.');
      return;
    }
    setState(() {
      submitting = true;
      submitError = null;
    });
    try {
      final r = await Api.instance.submitOvertime(date: _iso(date), start: start!, end: end!, reason: reason.text.trim());
      if (!mounted) return;
      setState(() => sent = r);
      reason.clear();
      _loadHistory();
    } on ApiException catch (e) {
      if (_expired(e) || !mounted) return;
      setState(() => submitError = e.message);
      _loadCheck(); // kuota/absensi mungkin berubah
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  Future<void> _cancel(Map<String, dynamic> row) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Batalkan pengajuan?', style: ts(18, w: FontWeight.w800)),
        content: Text('Pengajuan lembur ini akan dibatalkan dan tidak diteruskan ke atasan.', style: ts(14, c: C.text2, h: 1.5)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Kembali', style: ts(14, w: FontWeight.w700, c: C.muted))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Batalkan', style: ts(14, w: FontWeight.w700, c: C.red))),
        ],
      ),
    );
    if (yes != true) return;
    try {
      await Api.instance.cancelOvertime((row['id'] as num).toInt());
      if (mounted) toast(context, 'Pengajuan dibatalkan');
      await _reloadAll();
    } on ApiException catch (e) {
      if (_expired(e) || !mounted) return;
      toast(context, e.message);
      await _loadHistory();
    }
  }

  // — Tampilan —

  Widget _box(Widget child) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
        child: child,
      );

  Widget _time(String label, String? v) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: C.bg, borderRadius: BorderRadius.circular(10)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: ts(12, c: C.muted)), Text(v ?? '--:--', style: ts(20, w: FontWeight.w800))]),
        ),
      );

  /// Absensi aktual pada tanggal terpilih + jendela lembur yang diizinkan.
  Widget _attendanceCard() {
    if (loadingCheck && check == null) {
      return _box(const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 12), child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5)))));
    }
    if (checkError != null) {
      return _box(Column(children: [
        Text(checkError!, textAlign: TextAlign.center, style: ts(13, c: C.red, h: 1.5)),
        const Gap(10),
        PrimaryButton('Coba lagi', onTap: _loadCheck),
      ]));
    }
    if (unsupported) return const Notice('Pemeriksaan absensi belum tersedia di server. Aturan server tetap berlaku saat pengajuan dikirim.');

    final c = check!;
    final att = c['attendance'] is Map ? Map<String, dynamic>.from(c['attendance'] as Map) : null;
    final working = c['working_day'] == true;
    return _box(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: Text('Absensi aktual', style: ts(14, w: FontWeight.w800))),
        Pill(working ? 'Hari kerja' : 'Hari off / libur', tone: working ? Tone.neutral : Tone.warn),
      ]),
      const Gap(10),
      Row(children: [_time('Masuk', att?['in'] as String?), const Gap(0, w: 10), _time('Pulang', att?['out'] as String?)]),
      const Gap(10),
      if (c['ok'] == true) ...[
        Text('Lembur yang bisa diajukan: ${c['from']} – ${c['to']}', style: ts(13, w: FontWeight.w600, c: C.greenFg, h: 1.4)),
        const Gap(2),
        Text('Sisa kuota hari ini: ${_hours((c['remaining_hours'] as num?) ?? 0)} jam (maksimal ${_hours(_perDay)} jam per hari)', style: ts(12, c: C.muted, h: 1.4)),
      ] else
        Text((c['reason'] as String?) ?? 'Tidak ada lembur yang bisa diajukan pada tanggal ini.', style: ts(13, w: FontWeight.w600, c: C.orangeFg, h: 1.5)),
    ]));
  }

  Widget _form() {
    final starts = _startItems;
    if (!_ok) return const SizedBox.shrink();
    if (starts.isEmpty) {
      return Notice('Kuota lembur tanggal ini sudah habis (${_hours(_perDay)} jam per hari).');
    }
    final ends = start == null ? const <String>[] : _endItems(start!);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Fld('Jam mulai', SelectInp<String>(
            value: start!,
            items: starts,
            onChanged: (v) => setState(() {
              start = v;
              final e = _endItems(v);
              if (!e.contains(end)) end = e.last;
            }),
          )),
        ),
        const Gap(0, w: 12),
        Expanded(child: Fld('Jam selesai', SelectInp<String>(value: end!, items: ends, onChanged: (v) => setState(() => end = v)))),
      ]),
      const Gap(12),
      _box(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Durasi', style: ts(14, c: C.text2)), Text(_dur(_durMin), style: ts(18, w: FontWeight.w800))])),
      const Gap(16),
      Fld(
        'Uraian pekerjaan',
        TextField(
          controller: reason,
          minLines: 3,
          maxLines: 5,
          maxLength: 500,
          onChanged: (_) => setState(() => submitError = null),
          style: ts(15, w: FontWeight.w400),
          decoration: InputDecoration(
            hintText: tr('Jelaskan pekerjaan yang dilakukan'),
            hintStyle: ts(15, c: const Color(0xFF757575), w: FontWeight.w400),
            filled: true,
            fillColor: Colors.white,
            counterText: '',
            contentPadding: const EdgeInsets.fromLTRB(9, 11, 9, 11),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: C.input)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: C.input)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: C.blue, width: 2)),
          ),
        ),
      ),
      if (submitError != null) ...[const Gap(12), Text(submitError!, style: ts(13, w: FontWeight.w600, c: C.red, h: 1.5))],
      const Gap(16),
      PrimaryButton(submitting ? 'Mengirim...' : 'Kirim Pengajuan Lembur', height: 54, onTap: submitting ? null : _submit),
    ]);
  }

  (String, Tone) _status(String s) => switch (s) {
        'approved' => ('Disetujui', Tone.ok),
        'rejected' => ('Ditolak', Tone.bad),
        'cancelled' => ('Dibatalkan', Tone.neutral),
        _ => ('Menunggu', Tone.warn),
      };

  Widget _historyRow(Map<String, dynamic> r, {required bool first}) {
    final (label, tone) = _status('${r['status']}');
    final d = DateTime.tryParse('${r['date']}');
    final h = r['hours'] as num? ?? 0;
    final note = r['note'] as String?;
    final by = r['decided_by'] as String?;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: first ? null : const Border(top: BorderSide(color: Color(0xFFEEF1F5)))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${d == null ? r['date'] : L.instance.shortDate(d)} · ${r['start']} – ${r['end']}', style: ts(14, w: FontWeight.w700, h: 1.4)),
              Text('${_hours(h)} jam · ${r['reason'] ?? ''}', maxLines: 2, overflow: TextOverflow.ellipsis, style: ts(12, c: C.muted, h: 1.4)),
            ]),
          ),
          const Gap(0, w: 8),
          Pill(label, tone: tone),
        ]),
        if (r['status'] == 'rejected' && note != null && note.isNotEmpty) ...[const Gap(4), Text('${by == null ? '' : '$by: '}$note', style: ts(12, c: C.red, h: 1.4))],
        if (r['status'] == 'pending') Align(alignment: Alignment.centerLeft, child: InkWell(onTap: () => _cancel(r), child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('Batalkan', style: ts(13, w: FontWeight.w700, c: C.red))))),
      ]),
    );
  }

  Widget _historyCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.only(top: 12, bottom: 4), child: Text('Riwayat lembur', style: ts(14, w: FontWeight.w800))),
          if (loadingHistory && history.isEmpty)
            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5))))
          else if (historyError != null && history.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(historyError!, style: ts(13, c: C.red, h: 1.5)))
          else if (history.isEmpty)
            Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text('Belum ada riwayat lembur.', style: ts(13, c: C.muted)))
          else
            for (var i = 0; i < history.length; i++) _historyRow(history[i], first: i == 0),
        ]),
      );

  Widget _sentView() {
    final r = sent!;
    final d = DateTime.tryParse('${r['date']}');
    return Column(children: [
      ResultView(
        icon: Icons.check_circle_outline,
        color: C.green,
        title: 'Pengajuan lembur terkirim',
        text: 'Menunggu persetujuan atasan langsung (Superintendent Seksi). Status bisa dilihat di Riwayat lembur.',
        children: [
          SummaryBox([
            ('No. pengajuan', '#${r['id']}'),
            ('Tanggal', d == null ? '${r['date']}' : L.instance.shortDate(d)),
            ('Waktu', '${r['start']} – ${r['end']}'),
            ('Durasi', _dur((((r['hours'] as num?) ?? 0) * 60).round())),
          ]),
          const Gap(20),
          PrimaryButton('Kembali ke Beranda', height: 54, onTap: () => Navigator.pop(context)),
          const Gap(10),
          OutlineButton('Ajukan lagi', onTap: () {
            setState(() => sent = null);
            _loadCheck();
          }),
        ],
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    L.watch(context);
    final signedIn = Session.instance.active;
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(children: [
          const PageHeader('Ajukan Lembur'),
          Expanded(
            child: PullToRefresh(
              onRefresh: _reloadAll,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: !signedIn
                    ? const Notice('Masuk terlebih dahulu untuk mengajukan lembur.')
                    : sent != null
                        ? _sentView()
                        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Notice('Maksimal ${_hours(_perDay)} jam per hari, di luar jam kerja, dan harus sesuai absensi aktual.', tone: Tone.neutral),
                            const Gap(16),
                            Fld(
                              'Tanggal lembur',
                              DateInp(
                                date,
                                (d) {
                                  setState(() {
                                    date = d;
                                    check = null; // jendela tanggal sebelumnya tidak boleh dipakai selagi memuat
                                    start = end = null;
                                    submitError = null;
                                  });
                                  _loadCheck();
                                },
                                first: _today().subtract(const Duration(days: _daysBack)),
                                last: _today(),
                              ),
                            ),
                            const Gap(12),
                            _attendanceCard(),
                            const Gap(16),
                            _form(),
                            const Gap(20),
                            _historyCard(),
                          ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
