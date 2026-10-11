import 'package:flutter/material.dart' hide Text;
import '../api/api.dart';
import '../l10n/lang.dart';
import '../theme.dart';
import '../widgets.dart';

/// Detail tiket/transport satu pengajuan cuti (tab Berangkat/Kembali), diisi HR/GA setelah cuti disetujui.
/// [leaveId] = id dari `Api.instance.leaves()`.
class TripScreen extends StatefulWidget {
  final int? leaveId;
  const TripScreen({super.key, this.leaveId});
  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  bool back = false;
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

  Widget _sec(String icon, String t) => Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
        child: Row(children: [Ic(icon, size: 16, stroke: 2, color: C.muted), const Gap(0, w: 8), Text(t, style: ts(13, w: FontWeight.w800, c: C.muted).copyWith(letterSpacing: .3))]),
      );

  Widget _seatMap(int mine) {
    var n = 1;
    final cells = <Widget>[];
    for (var r = 0; r < 5; r++) {
      for (var c = 0; c < 5; c++) {
        if (c == 2) {
          cells.add(const SizedBox());
          continue;
        }
        final me = n == mine;
        cells.add(Container(alignment: Alignment.center, decoration: BoxDecoration(color: me ? C.blue : const Color(0xFFEEF1F5), borderRadius: BorderRadius.circular(6)), child: Text('$n', style: ts(12, w: FontWeight.w700, c: me ? Colors.white : C.muted))));
        n++;
      }
    }
    return Semantics(
      label: 'Denah kursi, kursi Anda nomor $mine',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Denah kursi (depan di atas)', style: ts(12, c: C.muted)),
        const Gap(6),
        for (var r = 0; r < 5; r++) ...[if (r > 0) const Gap(6), SizedBox(height: 30, child: Row(children: [for (var c = 0; c < 5; c++) ...[if (c > 0) const Gap(0, w: 6), Expanded(child: cells[r * 5 + c])]]))],
      ]),
    );
  }

  /// Satu kaki perjalanan (berangkat/kembali), dibangun dari field `Api.instance.leaves()` yang sesungguhnya.
  /// `leg` null = HR/GA belum mengisi data untuk kaki ini.
  Widget _leg({required String date, required bool needsTicket, required bool needsPickup, Map<String, dynamic>? leg}) {
    if (!needsTicket && !needsPickup) return const Notice('Pengajuan ini tidak menandai kebutuhan tiket/jemputan.');
    if (leg == null || (leg['mode'] == null && leg['detail'] == null)) {
      return Notice('Data tiket/transport untuk $date belum diisi HR/GA. Hubungi HR Department.', tone: Tone.warn);
    }

    final mode = leg['mode'] as String?;
    final detail = leg['detail'] as String?;
    final seat = leg['seat'] as String?;
    final note = leg['note'] as String?;
    final seatNum = seat == null ? null : int.tryParse(seat);

    return Card14(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(date, style: ts(12, c: C.muted, h: 1.4)),
              Text(mode == 'flight' ? 'Penerbangan' : 'Transport darat', style: ts(20, w: FontWeight.w800, h: 1.4)),
              if (detail != null) Text(detail, style: ts(13, c: C.text2, h: 1.4)),
            ]),
          ),
          if (seat != null) ...[
            const Gap(0, w: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: C.blue, borderRadius: BorderRadius.circular(12)),
              child: Column(children: [Text('Kursi', style: ts(11, c: const Color(0xFFDCE7FB), h: 1.1)), Text(seat, style: ts(22, w: FontWeight.w800, c: Colors.white, h: 1.1))]),
            ),
          ],
        ]),
        if (note != null && note.isNotEmpty) ...[const Gap(10), Text(note, style: ts(13, c: C.text2, h: 1.4))],
        if (mode == 'ground' && seatNum != null) ...[const Gap(14), _seatMap(seatNum)],
      ]),
    );
  }

  Widget _tab(String t, bool on, VoidCallback tap) => Expanded(
        child: Material(
          color: on ? C.blue : const Color(0xFFEEF1F5),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(borderRadius: BorderRadius.circular(10), onTap: tap, child: SizedBox(height: 44, child: Center(child: Text(t, style: ts(14, w: on ? FontWeight.w700 : FontWeight.w600, c: on ? Colors.white : C.text2))))),
        ),
      );

  String _date(String? iso) {
    final d = iso == null ? null : DateTime.tryParse(iso);
    return d == null ? '-' : L.instance.shortDate(d);
  }

  @override
  Widget build(BuildContext context) {
    L.watch(context);
    return Scaffold(
      backgroundColor: C.bg,
      body: SafeArea(
        child: widget.leaveId == null
            ? const Center(child: Padding(padding: EdgeInsets.all(24), child: Notice('Pengajuan tidak ditemukan.')))
            : FutureBuilder<Map<String, dynamic>?>(
                future: future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
                  final l = snap.hasError ? null : snap.data;
                  if (l == null) {
                    return Column(children: [
                      const PageHeader('Perjalanan Cuti'),
                      Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(24), child: snap.hasError ? Text('${snap.error}', style: ts(14, c: C.red)) : const Notice('Pengajuan tidak ditemukan.')))),
                    ]);
                  }

                  final travel = l['travel'] as Map<String, dynamic>?;
                  final needsTicket = l['needs_ticket'] == true, needsPickup = l['needs_pickup'] == true;
                  final outDate = _date(l['travel_out_date'] as String? ?? l['start_date'] as String?);
                  final backDate = _date(l['travel_back_date'] as String? ?? l['end_date'] as String?);

                  return Column(children: [
                    PageHeader('Perjalanan Cuti', border: false),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: C.line))),
                      child: Row(children: [_tab('Berangkat · $outDate', !back, () => setState(() => back = false)), const Gap(0, w: 6), _tab('Kembali · $backDate', back, () => setState(() => back = true))]),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Flexible(child: Text('${l['type_label']} · ${_date(l['start_date'] as String?)} – ${_date(l['end_date'] as String?)}', style: ts(13, c: C.muted))),
                            const Pill('Disetujui', tone: Tone.ok),
                          ]),
                          const Gap(12),
                          _sec(back ? 'bus' : 'plane', back ? 'KEPULANGAN' : 'KEBERANGKATAN'),
                          const Gap(12),
                          _leg(date: back ? backDate : outDate, needsTicket: needsTicket, needsPickup: needsPickup, leg: travel?[back ? 'return' : 'outbound'] as Map<String, dynamic>?),
                        ]),
                      ),
                    ),
                  ]);
                },
              ),
      ),
    );
  }
}
