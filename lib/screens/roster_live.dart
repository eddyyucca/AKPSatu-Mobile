import 'package:flutter/material.dart' hide Text;
import '../l10n/lang.dart';
import '../api/api.dart';
import '../refresh.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

/// Jadwal kerja = roster karyawan yang login, SAMA dengan kalender Roster & Cuti di web HRIS:
/// kode (K kerja, O off, C cuti, S sakit, I izin, P perjalanan), warna, siklus otomatis, dan penyesuaian HR.
class LiveRosterScreen extends StatefulWidget {
  const LiveRosterScreen({super.key});
  @override
  State<LiveRosterScreen> createState() => _LiveRosterScreenState();
}

class _LiveRosterScreenState extends State<LiveRosterScreen> {
  static const _bulan = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
  static const _hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  static const _batas = 12; // bulan ke belakang / ke depan

  late DateTime month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  final _cache = <String, Future<Map<String, dynamic>>>{};

  String _key(DateTime m) => '${m.year}-${m.month.toString().padLeft(2, '0')}';
  Future<Map<String, dynamic>> get _data => _cache.putIfAbsent(_key(month), () => Api.instance.roster(_key(month)));

  DateTime get _now => DateTime(DateTime.now().year, DateTime.now().month, 1);
  int get _offset => (month.year - _now.year) * 12 + month.month - _now.month;

  void _go(int delta) {
    final next = _offset + delta;
    if (next < -_batas || next > _batas) return;
    setState(() => month = DateTime(month.year, month.month + delta, 1));
  }

  Future<void> _reload() async {
    final key = _key(month);
    setState(() => _cache.remove(key));
    try {
      await _data;
    } catch (_) {}
  }

  /// Peta dari JSON; larik kosong ([]) atau null dianggap peta kosong (server PHP bisa mengirim [] untuk objek kosong).
  static Map<String, dynamic> _map(Object? v) => v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  Color _hex(String? v, Color fallback) {
    final h = (v ?? '').replaceAll('#', '');
    if (h.length != 6) return fallback;
    return Color(int.parse('FF$h', radix: 16));
  }

  Widget _navBtn(String label, String icon, VoidCallback? onTap) => Semantics(
        button: true,
        label: label,
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: C.input)),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: SizedBox(width: 40, height: 40, child: Center(child: Ic(icon, size: 18, stroke: 2, color: onTap == null ? C.line : C.text))),
          ),
        ),
      );

  Widget _cell(Map<String, dynamic> d, Map<String, Map<String, dynamic>> legend, bool today) {
    final date = DateTime.parse(d['date'] as String);
    final code = d['code'] as String?;
    final def = legend[code];
    final bg = _hex(def?['bg'] as String?, const Color(0xFFF3F4F6));
    final fg = _hex(def?['fg'] as String?, C.muted);
    final adjusted = d['adjusted'] == true;
    return Semantics(
      label: '${date.day} ${_bulan[date.month - 1]} · ${def?['label'] ?? 'Belum ada jadwal'}',
      child: Stack(clipBehavior: Clip.none, children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(9)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('${date.day}', style: ts(13, w: FontWeight.w700, c: fg, h: 1.1)),
              Text(code ?? '', style: ts(10, w: FontWeight.w800, c: fg.withValues(alpha: .85), h: 1.1)),
            ]),
          ),
        ),
        if (today)
          Positioned(
            left: -3,
            top: -3,
            right: -3,
            bottom: -3,
            child: IgnorePointer(child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: C.orange, width: 2)))),
          ),
        if (adjusted) Positioned(top: 3, right: 3, child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: C.orange, shape: BoxShape.circle))),
      ]),
    );
  }

  Widget _grid(List<Map<String, dynamic>> days, Map<String, Map<String, dynamic>> legend) {
    final first = DateTime.parse(days.first['date'] as String);
    final lead = first.weekday - 1;
    final n = DateTime.now();
    final todayKey = '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
    final rows = <Widget>[];
    for (var r = 0; r < 6; r++) {
      if (r * 7 - lead >= days.length) break;
      rows.add(SizedBox(
        height: 44,
        child: Row(children: [
          for (var c = 0; c < 7; c++) ...[
            if (c > 0) const Gap(0, w: 5),
            Expanded(
              child: () {
                final i = r * 7 + c - lead;
                if (i < 0 || i >= days.length) return const SizedBox();
                return _cell(days[i], legend, days[i]['date'] == todayKey);
              }(),
            ),
          ],
        ]),
      ));
    }
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(children: [
          Row(children: [
            for (var c = 0; c < 7; c++) ...[
              if (c > 0) const Gap(0, w: 5),
              Expanded(child: Center(child: Text(_hari[c], style: ts(11, w: FontWeight.w700, c: C.muted)))),
            ],
          ]),
          const Gap(6),
          for (var r = 0; r < rows.length; r++) ...[if (r > 0) const Gap(5), rows[r]],
        ]),
      ),
    );
  }

  String _patternText(Map<String, dynamic> p) {
    if (p['type'] == 'office') return 'Pola kantor · Minggu libur';
    if (p.isEmpty) return 'Pola kerja belum ditetapkan';
    final w = p['work_days'], o = p['off_days'];
    final base = (w != null && o != null) ? 'Pola kerja $w:$o' : 'Pola kerja belum ditetapkan';
    final l = p['leave_after_days'], ld = p['leave_days'];
    return (l != null && ld != null) ? '$base · cuti $ld hari setelah $l hari' : base;
  }

  Widget _body() => FutureBuilder<Map<String, dynamic>>(
        future: _data,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Padding(padding: EdgeInsets.symmetric(vertical: 80), child: Center(child: CircularProgressIndicator()));
          }
          if (snap.hasError) {
            final e = snap.error;
            if (e is ApiException && e.unauthenticated) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) Navigator.pushNamedAndRemoveUntil(context, R.login, (r) => false);
              });
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(children: [
                Text('$e', textAlign: TextAlign.center, style: ts(14, c: C.red, h: 1.5)),
                const Gap(12),
                PrimaryButton('Coba lagi', onTap: _reload),
              ]),
            );
          }

          final data = snap.data!;
          final days = ((data['days'] as List?) ?? const []).map((e) => _map(e)).toList();
          final legendList = ((data['legend'] as List?) ?? const []).map((e) => _map(e)).toList();
          final hasSchedule = days.any((d) => d['code'] != null);
          final legend = {for (final l in legendList) l['code'] as String: l};
          final summary = _map(data['summary']);
          final pattern = _map(data['pattern']);
          final estimated = pattern['estimated'] == true;

          return Column(children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 14),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(16)),
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    _navBtn('Bulan sebelumnya', 'back', _offset <= -_batas ? null : () => _go(-1)),
                    Flexible(
                      child: Column(children: [
                        Text(L.instance.monthYear(month), style: ts(17, w: FontWeight.w800, h: 1.3)),
                        Text(
                          hasSchedule ? [for (final l in legendList) if ((summary[l['code']] as num?) != null) '${l['label']} ${summary[l['code']]}'].join(' · ') : 'Jadwal belum tersedia',
                          textAlign: TextAlign.center,
                          style: ts(12, c: C.muted, h: 1.3),
                        ),
                      ]),
                    ),
                    _navBtn('Bulan berikutnya', 'chevron', _offset >= _batas ? null : () => _go(1)),
                  ]),
                ),
                const Gap(10),
                if (days.isNotEmpty) _grid(days, legend),
                const Gap(10),
                if (hasSchedule)
                  Text('Titik oranye = disesuaikan HR di web', style: ts(11, c: C.muted))
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Jadwal bulan ini belum tersedia. Pola kerja atau tanggal masuk Anda belum diisi; hubungi HR.', textAlign: TextAlign.center, style: ts(12, c: C.muted, h: 1.4)),
                  ),
              ]),
            ),
            const Gap(12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Pola roster Anda', style: ts(14, w: FontWeight.w800)),
                const Gap(6),
                Text(_patternText(pattern), style: ts(13, c: C.text2, h: 1.4)),
                if (estimated) ...[
                  const Gap(8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(color: C.blueSoft, borderRadius: BorderRadius.circular(8)),
                    child: Text('Jadwal ini perkiraan dari tanggal masuk dan pola kerja. HR dapat menyesuaikannya di web.', style: ts(12, c: C.blueFg, h: 1.4)),
                  ),
                ],
              ]),
            ),
          ]);
        },
      );

  @override
  void initState() {
    super.initState();
    Refresh.add(_reload);
  }

  @override
  void dispose() {
    Refresh.remove(_reload);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    L.watch(context);
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(children: [
          PageHeader('Jadwal Kerja',
              border: false,
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 6),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(99),
                  onTap: () => setState(() => month = _now),
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(99), border: Border.all(color: C.input)),
                    child: Text('Hari ini', style: ts(13, w: FontWeight.w700)),
                  ),
                ),
              )),
          // Legenda dari server (sama dengan di web), tampil begitu data bulan ini ada.
          FutureBuilder<Map<String, dynamic>>(
            future: _data,
            builder: (context, snap) {
              final legend = snap.hasData ? ((snap.data!['legend'] as List?) ?? const []).map((e) => _map(e)).toList() : <Map<String, dynamic>>[];
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: C.line))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: C.green, shape: BoxShape.circle)),
                    const Gap(0, w: 8),
                    Expanded(child: Text('Sama dengan Roster & Cuti di web HRIS', style: ts(12, w: FontWeight.w600, c: C.greenFg))),
                  ]),
                  if (legend.isNotEmpty) ...[
                    const Gap(8),
                    Wrap(spacing: 14, runSpacing: 8, children: [
                      for (final l in legend)
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(color: _hex(l['bg'] as String?, C.line), borderRadius: BorderRadius.circular(4), border: Border.all(color: _hex(l['fg'] as String?, C.muted).withValues(alpha: .35))),
                          ),
                          const Gap(0, w: 6),
                          Text('${l['code']} ${l['label']}', style: ts(12, c: C.text2)),
                        ]),
                    ]),
                  ],
                ]),
              );
            },
          ),
          Expanded(
            child: PullToRefresh(
              onRefresh: _reload,
              child: GestureDetector(
                onHorizontalDragEnd: (d) {
                  final v = d.primaryVelocity ?? 0;
                  if (v > 200) _go(-1);
                  if (v < -200) _go(1);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                  child: _body(),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
