import 'package:flutter/material.dart' hide Text;
import '../api/api.dart';
import '../l10n/lang.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

/// Lini masa satu pengajuan cuti: tahap persetujuan, lalu (bila disetujui) keberangkatan/kepulangan dan data
/// tiket/transport yang diisi HR/GA. [leaveId] = id dari `Api.instance.leaves()`; tanpa id, layar tidak bisa memuat apa pun.
class ItineraryScreen extends StatefulWidget {
  final int? leaveId;
  const ItineraryScreen({super.key, this.leaveId});
  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  Future<Map<String, dynamic>?>? future;

  @override
  void initState() {
    super.initState();
    if (widget.leaveId != null && Session.instance.active) _load();
  }

  Future<void> _load() async {
    setState(() {
      future = Api.instance.leaves().then((rows) => rows.where((r) => r['id'] == widget.leaveId).firstOrNull);
    });
    try {
      await future;
    } catch (_) {}
  }

  Widget _day(String t) => Padding(padding: const EdgeInsets.fromLTRB(0, 10, 0, 2), child: Text(t, style: ts(12, w: FontWeight.w800, c: C.muted).copyWith(letterSpacing: .4)));

  Widget _chip(String t, Color bg, Color fg, {bool bold = true}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Text(t, style: ts(12, w: bold ? FontWeight.w700 : FontWeight.w600, c: fg)),
      );

  Widget _ev({required String time, required Color dot, required Widget box, bool line = true, String? route, bool dashed = false}) => IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(width: 68, child: Padding(padding: const EdgeInsets.only(top: 15), child: Text(time, textAlign: TextAlign.right, style: ts(12, w: FontWeight.w800, c: C.text2)))),
          const Gap(0, w: 10),
          SizedBox(
            width: 14,
            child: Column(children: [
              Padding(padding: const EdgeInsets.only(top: 17), child: Container(width: 12, height: 12, decoration: BoxDecoration(color: dot, shape: BoxShape.circle))),
              if (line) Expanded(child: Container(width: 2, color: C.input)),
            ]),
          ),
          const Gap(0, w: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: dashed ? const Color(0xFFF8FAFC) : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: C.line)),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: route == null ? null : () => Navigator.pushNamed(context, route, arguments: widget.leaveId),
                  child: SizedBox(width: double.infinity, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), child: box)),
                ),
              ),
            ),
          ),
        ]),
      );

  Widget _b(String t) => Text(t, style: ts(14, w: FontWeight.w700));
  Widget _s(String t) => Text(t, style: ts(13, c: C.muted, h: 1.45));

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

  List<Widget> _timeline(Map<String, dynamic> l) {
    final status = l['status'] as String;
    final out = <Widget>[];

    _day('PENGAJUAN');
    out.add(_ev(
      time: _date(l['start_date'] as String?),
      dot: C.blue,
      line: true,
      box: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_b(l['type_label'] as String? ?? ''), _s('${l['reason']}')]),
    ));

    final sup = l['supervisor'] as Map<String, dynamic>?;
    if (sup != null) {
      final rejectedHere = status == 'rejected' && l['hr'] == null;
      out.add(_ev(
        time: _date(sup['at'] as String?),
        dot: rejectedHere ? C.red : C.green,
        box: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _b(rejectedHere ? 'Ditolak atasan' : 'Disetujui atasan'),
          _s('${sup['by']}'),
          if ((sup['note'] as String?)?.isNotEmpty ?? false) _s('Catatan: ${sup['note']}'),
        ]),
      ));
    }

    final hr = l['hr'] as Map<String, dynamic>?;
    if (hr != null) {
      final rejectedHere = status == 'rejected';
      out.add(_ev(
        time: _date(hr['at'] as String?),
        dot: rejectedHere ? C.red : C.green,
        line: status == 'approved',
        box: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _b(rejectedHere ? 'Ditolak HR' : 'Disetujui HR'),
          _s('${hr['by']}'),
          if ((hr['note'] as String?)?.isNotEmpty ?? false) _s('Catatan: ${hr['note']}'),
        ]),
      ));
    }

    if (status != 'approved') return out;   // belum disetujui penuh: belum ada jadwal keberangkatan untuk ditampilkan

    final travel = l['travel'] as Map<String, dynamic>?;
    final needsTravel = l['needs_ticket'] == true || l['needs_pickup'] == true;

    if (l['departure_half_day_date'] != null) {
      _day('${_date(l['departure_half_day_date'] as String?)} · SETENGAH HARI');
      out.add(_ev(time: '', dot: C.orange, box: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_b('Masuk setengah hari'), _s('Berangkat setelah jam kerja siang.')])));
    }

    if (l['travel_out_date'] != null) {
      _day('${_date(l['travel_out_date'] as String?)} · BERANGKAT');
      final o = travel?['outbound'] as Map<String, dynamic>?;
      out.add(_ev(
        time: '',
        dot: C.blue,
        route: needsTravel ? R.perjalanan : null,
        box: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _b(o?['mode'] == 'flight' ? 'Penerbangan keberangkatan' : 'Keberangkatan'),
          if (o?['detail'] != null) ...[
            _s('${o?['detail']}'),
            const Gap(8),
            Wrap(spacing: 6, runSpacing: 6, children: [if (o?['seat'] != null) _chip('Kursi ${o?['seat']}', C.blueSoft, C.blueFg)]),
          ] else
            _s('Belum diisi HR/GA.'),
        ]),
      ));
    }

    _day('${_date(l['start_date'] as String?)} – ${_date(l['end_date'] as String?)} · CUTI (${l['days']} HARI)');
    out.add(_ev(time: '', dot: C.navy, dashed: true, box: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_b(l['type_label'] as String? ?? ''), if ((l['address_during_leave'] as String?)?.isNotEmpty ?? false) _s('Alamat: ${l['address_during_leave']}')])));

    if (l['travel_back_date'] != null) {
      _day('${_date(l['travel_back_date'] as String?)} · KEMBALI');
      final r = travel?['return'] as Map<String, dynamic>?;
      out.add(_ev(
        time: '',
        dot: C.blue,
        route: needsTravel ? R.perjalanan : null,
        box: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _b(r?['mode'] == 'flight' ? 'Penerbangan kepulangan' : 'Kepulangan'),
          if (r?['detail'] != null) ...[
            _s('${r?['detail']}'),
            const Gap(8),
            Wrap(spacing: 6, runSpacing: 6, children: [if (r?['seat'] != null) _chip('Kursi ${r?['seat']}', C.blueSoft, C.blueFg)]),
          ] else
            _s('Belum diisi HR/GA.'),
        ]),
      ));
    }

    if (l['return_half_day_date'] != null) {
      _day('${_date(l['return_half_day_date'] as String?)} · SETENGAH HARI');
      out.add(_ev(time: '', dot: C.orange, line: false, box: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_b('Masuk setengah hari'), _s('Kembali bekerja.')])));
    }

    return out;
  }

  @override
  Widget build(BuildContext context) {
    L.watch(context);
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: Column(children: [
          const PageHeader('Itinerary Cuti'),
          Expanded(
            child: widget.leaveId == null
                ? const Notice('Pengajuan tidak ditemukan.')
                : FutureBuilder<Map<String, dynamic>?>(
                    future: future,
                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
                      if (snap.hasError) {
                        return Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(children: [Text('${snap.error}', style: ts(14, c: C.red)), const Gap(12), PrimaryButton('Coba lagi', onTap: _load)]),
                        );
                      }
                      final l = snap.data;
                      if (l == null) return const Padding(padding: EdgeInsets.all(24), child: Notice('Pengajuan tidak ditemukan.'));
                      final (label, tone) = _status(l['status'] as String);

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(color: C.navy, borderRadius: BorderRadius.circular(16)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Expanded(child: Text(l['type_label'] as String? ?? '', style: ts(12, c: C.pale, h: 1.35))),
                                Pill(label, tone: tone),
                              ]),
                              Text('${_date(l['start_date'] as String?)} – ${_date(l['end_date'] as String?)}', style: ts(20, w: FontWeight.w800, c: Colors.white, h: 1.35)),
                              Text('${l['days']} hari${(l['destination_city'] as String?)?.isNotEmpty ?? false ? ' · ${l['destination_city']}' : ''}', style: ts(13, c: const Color(0xFFDCE7FB), h: 1.35)),
                            ]),
                          ),
                          ..._timeline(l),
                        ]),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }
}
