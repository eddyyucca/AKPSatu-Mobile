import 'package:flutter/material.dart' hide Text;
import '../api/api.dart';
import '../l10n/lang.dart';
import '../refresh.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';
import '../states.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});
  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  Future<Map<String, dynamic>>? balanceFuture;
  List<Map<String, dynamic>> history = const [];
  bool loadingHistory = false;
  String? error;

  @override
  void initState() {
    super.initState();
    if (Session.instance.active) _reload();
    Refresh.add(_reload);
  }

  @override
  void dispose() {
    Refresh.remove(_reload);
    super.dispose();
  }

  Future<void> _reload() async {
    if (!Session.instance.active || !mounted) return;
    setState(() {
      balanceFuture = Api.instance.leaveCheck('cuti_tahunan');
      loadingHistory = true;
      error = null;
    });
    try {
      await Future.wait([balanceFuture!, _loadHistory()]);
    } catch (_) {}
  }

  Future<void> _loadHistory() async {
    try {
      final rows = await Api.instance.leaves();
      if (mounted) setState(() => history = rows);
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => loadingHistory = false);
    }
  }

  Widget _card(Widget child, {EdgeInsets padding = const EdgeInsets.all(16)}) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: C.line), borderRadius: BorderRadius.circular(14)),
        child: child,
      );

  Widget _st(String v, String l, {Color vc = C.text, bool borders = false}) => Expanded(
        child: Container(
          decoration: BoxDecoration(border: borders ? const Border(left: BorderSide(color: Color(0xFFEEF1F5)), right: BorderSide(color: Color(0xFFEEF1F5))) : null),
          child: Column(children: [Text(v, style: ts(18, w: FontWeight.w800, c: vc, h: 1.3)), Text(l, style: ts(12, c: C.muted, h: 20.8 / 12))]),
        ),
      );

  (String, Tone) _status(String s) => switch (s) {
        'pending_hr' => ('Menunggu HR', Tone.info),
        'approved' => ('Disetujui', Tone.ok),
        'rejected' => ('Ditolak', Tone.bad),
        'cancelled' => ('Dibatalkan', Tone.neutral),
        _ => ('Menunggu atasan', Tone.warn),
      };

  String _date(String? iso) {
    final d = iso == null ? null : DateTime.tryParse(iso);
    return d == null ? '-' : L.instance.shortDate(d);
  }

  Widget _hist(Map<String, dynamic> r) {
    final (label, tone) = _status(r['status'] as String);
    final sup = r['supervisor'] as Map<String, dynamic>?;
    final hr = r['hr'] as Map<String, dynamic>?;
    final note = (hr?['note'] ?? sup?['note']) as String?;
    final meta = switch (r['status']) {
      'approved' => 'Disetujui ${_date((hr?['at'] as String?)?.substring(0, 10))}',
      'rejected' => note != null && note.isNotEmpty ? note : 'Ditolak',
      'cancelled' => 'Dibatalkan',
      _ => 'Diajukan ${_date((r['start_date'] as String?))}',
    };
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.pushNamed(context, R.itinerary, arguments: r['id']),
        child: _card(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${_date(r['start_date'] as String?)} – ${_date(r['end_date'] as String?)}', style: ts(15, w: FontWeight.w700, h: 1.45)),
              Text('${r['days']} hari · ${r['type_label']}', style: ts(13, c: C.text2, h: 1.45)),
              Text(meta, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(12, c: C.muted, h: 1.45)),
            ]),
          ),
          const Gap(0, w: 12),
          Pill(label, tone: tone),
        ])),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    L.watch(context);
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(children: [
          const PageHeader('Cuti Tahunan'),
          Expanded(
            child: !Session.instance.active
                ? const Padding(padding: EdgeInsets.all(24), child: Notice('Masuk terlebih dahulu untuk melihat cuti.'))
                : PullToRefresh(
                    onRefresh: _reload,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        FutureBuilder<Map<String, dynamic>>(
                          future: balanceFuture,
                          builder: (context, snap) {
                            final b = snap.data?['balance'] as Map<String, dynamic>?;
                            final quota = (b?['quota'] as num?)?.toInt() ?? 12;
                            final used = (b?['used'] as num?)?.toInt() ?? 0;
                            final remaining = (b?['remaining'] as num?)?.toInt() ?? quota;
                            final pct = quota == 0 ? 0.0 : (used / quota).clamp(0, 1).toDouble();
                            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(color: C.navy, borderRadius: BorderRadius.circular(16)),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Text('Sisa cuti tahunan ${DateTime.now().year}', style: ts(13, c: C.pale)),
                                  const Gap(14),
                                  Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                                    Text('$remaining', style: ts(44, w: FontWeight.w800, c: Colors.white, h: 1)),
                                    const Gap(0, w: 8),
                                    Text('dari $quota hari', style: ts(16, c: const Color(0xFFDCE7FB))),
                                  ]),
                                  const Gap(14),
                                  Semantics(
                                    label: 'Terpakai $used dari $quota hari',
                                    child: Container(
                                      height: 8,
                                      decoration: BoxDecoration(color: C.navy2, borderRadius: BorderRadius.circular(4)),
                                      alignment: Alignment.centerLeft,
                                      child: FractionallySizedBox(widthFactor: pct, child: Container(height: 8, decoration: BoxDecoration(color: const Color(0xFF5B95F5), borderRadius: BorderRadius.circular(4)))),
                                    ),
                                  ),
                                ]),
                              ),
                              const Gap(14),
                              _card(
                                IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [_st('$quota', 'Hak cuti'), _st('$used', 'Terpakai', borders: true), _st('${history.where((r) => r['status'] == 'pending_supervisor' || r['status'] == 'pending_hr').length}', 'Menunggu', vc: C.orangeFg)])),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                              ),
                            ]);
                          },
                        ),
                        const Gap(14),
                        Material(
                          color: C.blue,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => Navigator.pushNamed(context, R.pengajuanCuti),
                            child: SizedBox(height: 52, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Ic('plus', size: 20, stroke: 2, color: Colors.white), const Gap(0, w: 8), Text('Ajukan Cuti', style: ts(16, w: FontWeight.w700, c: Colors.white))])),
                          ),
                        ),
                        const Gap(14),
                        Padding(padding: const EdgeInsets.fromLTRB(4, 6, 4, 0), child: Text('Riwayat pengajuan', style: ts(15, w: FontWeight.w800))),
                        if (loadingHistory && history.isEmpty)
                          const SkeletonCards(count: 2)
                        else if (error != null && history.isEmpty)
                          Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(error!, style: ts(13, c: C.red)))
                        else if (history.isEmpty)
                          const EmptyState(icon: 'leave', title: 'Belum ada pengajuan cuti', text: 'Pengajuan cuti yang Anda buat akan tampil di sini.', color: C.orange, bg: C.orangeBg, compact: true)
                        else
                          for (final r in history) _hist(r),
                      ]),
                    ),
                  ),
          ),
        ]),
      ),
    );
  }
}
