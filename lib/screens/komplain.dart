import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter/material.dart' hide Text;
import 'package:image_picker/image_picker.dart';
import '../api/api.dart';
import '../api/komplain.dart';
import '../refresh.dart';
import '../routes.dart';
import '../theme.dart';
import '../widgets.dart';

const _statusKeys = <String?>[null, 'open', 'progress', 'closed', 'rejected'];
const _statusNames = ['Semua', 'Terbuka', 'Diproses', 'Selesai', 'Ditolak'];

String _statusName(String? key) => switch (key) {
      'open' => 'Terbuka',
      'progress' => 'Diproses',
      'closed' => 'Selesai',
      'rejected' => 'Ditolak',
      _ => '-',
    };

Tone _statusTone(String? key) => switch (key) {
      'open' => Tone.warn,
      'progress' => Tone.info,
      'closed' => Tone.ok,
      'rejected' => Tone.bad,
      _ => Tone.neutral,
    };

const _bln = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

/// '2026-10-09T03:15:00+00:00' -> '9 Okt 2026 · 11:15' (waktu perangkat).
String _when(String? iso) {
  if (iso == null || iso.isEmpty) return '-';
  final d = DateTime.tryParse(iso)?.toLocal();
  if (d == null) return '-';
  String p2(int n) => n < 10 ? '0$n' : '$n';
  return '${d.day} ${_bln[d.month - 1]} ${d.year} · ${p2(d.hour)}:${p2(d.minute)}';
}

/// Galat + tombol coba lagi. Sesi Portal yang berakhir mengembalikan pengguna ke layar masuk.
class _Err extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const _Err(this.error, this.onRetry);

  @override
  Widget build(BuildContext context) {
    if (error is ApiException && (error as ApiException).unauthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, R.login, (r) => false);
      });
    }
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('$error', textAlign: TextAlign.center, style: ts(14, c: C.red, h: 1.5)),
        const Gap(12),
        PrimaryButton('Coba lagi', onTap: onRetry),
      ]),
    );
  }
}

/// Beranda Komplain GA: "Laporan Saya" untuk semua karyawan, "Pantau" tambahan untuk petugas.
class KomplainScreen extends StatefulWidget {
  const KomplainScreen({super.key});
  @override
  State<KomplainScreen> createState() => _KomplainScreenState();
}

class _KomplainScreenState extends State<KomplainScreen> {
  late Future<Map<String, dynamic>> _opts = KomplainApi.instance.options();
  int tab = 0;
  int rev = 0;

  void _retry() => setState(() => _opts = KomplainApi.instance.options());

  Future<void> _lapor() async {
    await Navigator.pushNamed(context, R.komplainForm);
    if (mounted) setState(() => rev++);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: C.bg,
        body: SafeArea(
          child: Column(children: [
            const PageHeader('Komplain GA'),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _opts,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
                  if (snap.hasError) return Center(child: _Err(snap.error!, _retry));
                  final user = Map<String, dynamic>.from((snap.data!['user'] as Map?) ?? const {});
                  final canMonitor = user['can_monitor'] == true;
                  if (!canMonitor && tab != 0) tab = 0;
                  return Column(children: [
                    if (canMonitor)
                      Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: Seg(tabs: const ['Laporan Saya', 'Pantau'], index: tab, onChange: (i) => setState(() => tab = i))),
                    Expanded(child: ComplaintList(key: ValueKey('$tab-$rev'), monitor: tab == 1)),
                    Padding(padding: const EdgeInsets.all(16), child: PrimaryButton('Buat Laporan', ic: 'plus', onTap: _lapor)),
                  ]);
                },
              ),
            ),
          ]),
        ),
      );
}

/// Daftar laporan: milik sendiri ([monitor] = false) atau pemantauan petugas ([monitor] = true, dengan ringkasan, pencarian, dan filter).
class ComplaintList extends StatefulWidget {
  final bool monitor;
  const ComplaintList({super.key, required this.monitor});
  @override
  State<ComplaintList> createState() => _ComplaintListState();
}

class _ComplaintListState extends State<ComplaintList> {
  final _q = TextEditingController();
  final _items = <Map<String, dynamic>>[];
  Map<String, dynamic> _summary = const {};
  Object? _error;
  bool _loading = true, _more = false, _hasMore = false;
  int _page = 1;
  int _status = 0; // indeks pada _statusKeys
  bool _overdue = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  Future<void> _load({bool more = false}) async {
    setState(() {
      _error = null;
      if (more) {
        _more = true;
      } else {
        _loading = true;
      }
    });
    try {
      final page = more ? _page + 1 : 1;
      final status = _statusKeys[_status];
      final res = widget.monitor
          ? await KomplainApi.instance.monitor(status: status, q: _q.text, overdue: _overdue, page: page)
          : await KomplainApi.instance.mine(status: status, page: page);
      if (!mounted) return;
      setState(() {
        if (!more) _items.clear();
        _items.addAll(res.items);
        _page = res.page;
        _hasMore = res.hasMore;
        if (widget.monitor) _summary = res.summary;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _more = false;
        });
      }
    }
  }

  Widget _tile(String label, String key, Tone tone, {VoidCallback? onTap, bool on = false}) {
    final n = (_summary[key] as num?)?.toInt() ?? 0;
    return SizedBox(
      width: 98,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        color: on ? toneBg(tone) : Colors.white,
        border: on ? toneFg(tone) : C.line,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$n', style: ts(22, w: FontWeight.w800, c: toneFg(tone), h: 1.1)),
          Text(label, style: ts(12, c: C.muted)),
        ]),
      ),
    );
  }

  Widget _card(Map<String, dynamic> c) {
    final status = c['status'] as String?;
    final overdue = c['is_overdue'] == true;
    final room = (c['room_number'] as String?) ?? '';
    final where = [c['building'] as String? ?? '', if (room.isNotEmpty) 'Kamar $room'].where((s) => s.isNotEmpty).join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: () => Navigator.pushNamed(context, R.komplainDetail, arguments: c['ticket']),
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text('${c['ticket']}', style: ts(14, w: FontWeight.w800))),
            if (overdue) ...[const Pill('Terlambat', tone: Tone.bad), const Gap(0, w: 6)],
            Pill(_statusName(status), tone: _statusTone(status)),
          ]),
          const Gap(4),
          Text('${c['type_label']}${where.isEmpty ? '' : ' · $where'}', style: ts(12, c: C.muted, h: 1.4)),
          const Gap(6),
          Text('${c['description']}', maxLines: 2, overflow: TextOverflow.ellipsis, style: ts(14, h: 1.4)),
          const Gap(8),
          Row(children: [
            Expanded(child: Text(widget.monitor && c['reporter_name'] != null ? '${c['reporter_name']}' : _when(c['created_at'] as String?), style: ts(12, c: C.muted))),
            if (widget.monitor) Text(_when(c['created_at'] as String?), style: ts(12, c: C.muted)),
            if ((c['photo_count'] as num? ?? 0) > 0) ...[const Gap(0, w: 8), const Icon(Icons.photo_outlined, size: 14, color: C.muted), Text(' ${c['photo_count']}', style: ts(12, c: C.muted))],
          ]),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final header = <Widget>[
      if (widget.monitor) ...[
        Wrap(spacing: 8, runSpacing: 8, children: [
          _tile('Terbuka', 'open', Tone.warn),
          _tile('Diproses', 'progress', Tone.info),
          _tile('Selesai', 'closed', Tone.ok),
          _tile('Ditolak', 'rejected', Tone.bad),
          _tile('Terlambat', 'overdue', Tone.bad, on: _overdue, onTap: () {
            setState(() => _overdue = !_overdue);
            _load();
          }),
        ]),
        const Gap(12),
        TextField(
          controller: _q,
          textInputAction: TextInputAction.search,
          onSubmitted: (_) => _load(),
          style: ts(15),
          decoration: fieldDeco(hint: 'Cari tiket, pelapor, bangunan, kamar').copyWith(
            prefixIcon: const Icon(Icons.search, color: C.muted),
            suffixIcon: _q.text.isEmpty ? null : IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () {
              _q.clear();
              _load();
            }),
          ),
        ),
        const Gap(12),
      ],
      FilterChips(
        items: _statusNames,
        value: _statusNames[_status],
        onChange: (v) {
          setState(() => _status = _statusNames.indexOf(v));
          _load();
        },
      ),
      const Gap(12),
    ];

    final Widget body;
    if (_loading) {
      body = const Padding(padding: EdgeInsets.symmetric(vertical: 60), child: Center(child: CircularProgressIndicator()));
    } else if (_error != null) {
      body = _Err(_error!, _load);
    } else if (_items.isEmpty) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Text(widget.monitor ? 'Tidak ada laporan untuk filter ini.' : 'Belum ada laporan. Ketuk "Buat Laporan" untuk melaporkan masalah fasilitas.',
            textAlign: TextAlign.center, style: ts(14, c: C.muted, h: 1.5)),
      );
    } else {
      body = Column(children: [
        for (final c in _items) _card(c),
        if (_hasMore) OutlineButton(_more ? 'Memuat...' : 'Muat lainnya', onTap: _more ? null : () => _load(more: true)),
      ]);
    }

    return PullToRefresh(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        children: [...header, body],
      ),
    );
  }
}

/// Formulir laporan baru. Nama dan NIK pelapor diambil server dari akun yang login.
class KomplainFormScreen extends StatefulWidget {
  const KomplainFormScreen({super.key});
  @override
  State<KomplainFormScreen> createState() => _KomplainFormScreenState();
}

class _KomplainFormScreenState extends State<KomplainFormScreen> {
  static const _lainnya = 'Lainnya (tulis sendiri)';
  static const _maxFoto = 6;

  late final Future<Map<String, dynamic>> _opts = KomplainApi.instance.options();
  final _room = TextEditingController(), _lokasi = TextEditingController(), _desc = TextEditingController();
  final _wa = TextEditingController(), _lainBangunan = TextEditingController();
  final _photos = <(String, Uint8List)>[];
  final _picker = ImagePicker();

  String? type, building;
  bool sending = false;
  String? error;
  Map<String, dynamic>? result;

  @override
  void dispose() {
    for (final c in [_room, _lokasi, _desc, _wa, _lainBangunan]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _addPhoto(ImageSource source) async {
    if (_photos.length >= _maxFoto) {
      toast(context, 'Maksimal $_maxFoto foto');
      return;
    }
    try {
      final x = await _picker.pickImage(source: source, imageQuality: 80, maxWidth: 1600);
      if (x == null) return;
      final bytes = await x.readAsBytes();
      if (!mounted) return;
      setState(() => _photos.add((x.name.isEmpty ? 'foto.jpg' : x.name, bytes)));
    } catch (_) {
      if (mounted) toast(context, 'Tidak bisa mengambil foto. Periksa izin kamera/galeri.');
    }
  }

  Future<void> _send(Map<String, dynamic> types) async {
    final t = types[type] as Map<String, dynamic>?;
    final place = building == _lainnya ? _lainBangunan.text.trim() : (building ?? '');
    final needRoom = t?['room_required'] == true;

    String? problem;
    if (type == null) {
      problem = 'Pilih jenis laporan.';
    } else if (place.isEmpty) {
      problem = 'Pilih atau isi bangunan/area.';
    } else if (needRoom && _room.text.trim().isEmpty) {
      problem = 'Nomor kamar wajib diisi untuk laporan Receptionist.';
    } else if (_desc.text.trim().length < 5) {
      problem = 'Uraikan masalahnya (minimal 5 karakter).';
    }
    if (problem != null) {
      setState(() => error = problem);
      return;
    }

    setState(() {
      sending = true;
      error = null;
    });
    try {
      final data = await KomplainApi.instance.create(
        type: type!,
        building: place,
        description: _desc.text.trim(),
        room: _room.text,
        location: _lokasi.text,
        wa: _wa.text,
        photos: [for (final p in _photos) UploadFile(p.$1, p.$2)],
      );
      if (mounted) setState(() => result = data);
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  Widget _photoStrip() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Foto (opsional, maksimal $_maxFoto)', style: ts(13, w: FontWeight.w600, c: C.text2)),
        const Gap(8),
        if (_photos.isNotEmpty)
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _photos.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => Stack(children: [
                ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.memory(_photos[i].$2, width: 84, height: 84, fit: BoxFit.cover)),
                Positioned(
                  top: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () => setState(() => _photos.removeAt(i)),
                    child: Container(decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle), padding: const EdgeInsets.all(3), child: const Icon(Icons.close, size: 14, color: Colors.white)),
                  ),
                ),
              ]),
            ),
          ),
        if (_photos.isNotEmpty) const Gap(8),
        Row(children: [
          Expanded(child: OutlineButton('Kamera', onTap: sending ? null : () => _addPhoto(ImageSource.camera))),
          const Gap(0, w: 10),
          Expanded(child: OutlineButton('Galeri', onTap: sending ? null : () => _addPhoto(ImageSource.gallery))),
        ]),
      ]);

  Widget _form(Map<String, dynamic> data) {
    final types = {for (final t in (data['types'] as List)) (t as Map)['value'] as String: Map<String, dynamic>.from(t)};
    final groups = [for (final g in (data['buildings'] as List)) Map<String, dynamic>.from(g as Map)];
    final items = <String>[for (final g in groups) ...(g['items'] as List).map((e) => '$e'), _lainnya];
    final groupOf = {for (final g in groups) for (final i in (g['items'] as List)) '$i': '${g['group']}'};
    final needRoom = types[type]?['room_required'] == true;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (error != null) ...[Notice(error!, tone: Tone.bad), const Gap(14)],
        Text('Jenis laporan', style: ts(13, w: FontWeight.w600, c: C.text2)),
        const Gap(8),
        ChoiceRow(
          options: [for (final t in types.values) '${t['label']}'],
          selected: type == null ? '' : '${types[type]!['label']}',
          onSelect: (label) => setState(() => type = types.entries.firstWhere((e) => '${e.value['label']}' == label).key),
          wrap: true,
        ),
        const Gap(16),
        DropField<String?>(
          'Bangunan / area',
          value: building,
          items: [null, ...items],
          text: (v) => v == null ? 'Pilih...' : (groupOf[v] == null ? v : '$v · ${groupOf[v]}'),
          onChanged: (v) => setState(() => building = v),
        ),
        if (building == _lainnya) TextBox('Nama bangunan / area', controller: _lainBangunan, hint: 'Tulis nama bangunan atau area'),
        TextBox(needRoom ? 'Nomor kamar *' : 'Nomor kamar (opsional)', controller: _room, hint: 'mis. 12'),
        TextBox('Detail lokasi (opsional)', controller: _lokasi, hint: 'mis. kamar mandi, lantai 2'),
        TextBox('Uraian masalah *', controller: _desc, lines: 4, hint: 'Jelaskan masalahnya: apa, sejak kapan'),
        TextBox('Nomor WhatsApp (opsional)', controller: _wa, type: TextInputType.phone, hint: '08xxxxxxxxxx'),
        _photoStrip(),
        const Gap(20),
        PrimaryButton(sending ? 'Mengirim...' : 'Kirim Laporan', ic: 'send', onTap: sending ? null : () => _send(types)),
        const Gap(8),
        Text('Pelapor tercatat otomatis sesuai akun Anda.', textAlign: TextAlign.center, style: ts(12, c: C.muted)),
      ]),
    );
  }

  Widget _done(Map<String, dynamic> r) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ResultView(
          icon: Icons.check_circle_outline,
          color: C.green,
          title: 'Laporan terkirim',
          text: 'Petugas GA telah menerima laporan Anda. Pantau perkembangannya di menu Laporan Saya.',
          children: [
            SummaryBox([('No. tiket', '${r['ticket']}'), ('Jenis', '${r['type_label']}'), ('Batas penanganan', _when(r['sla_deadline'] as String?))]),
            const Gap(16),
            PrimaryButton('Lihat Laporan', onTap: () => Navigator.pushReplacementNamed(context, R.komplainDetail, arguments: r['ticket'])),
            const Gap(10),
            OutlineButton('Kembali', onTap: () => Navigator.pop(context)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: C.bg,
        body: SafeArea(
          child: Column(children: [
            const PageHeader('Buat Laporan'),
            Expanded(
              child: result != null
                  ? _done(result!)
                  : FutureBuilder<Map<String, dynamic>>(
                      future: _opts,
                      builder: (context, snap) {
                        if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
                        if (snap.hasError) return Center(child: _Err(snap.error!, () => Navigator.pushReplacementNamed(context, R.komplainForm)));
                        return _form(snap.data!);
                      },
                    ),
            ),
          ]),
        ),
      );
}

/// Rincian satu laporan (argumen rute: nomor tiket).
class KomplainDetailScreen extends StatefulWidget {
  const KomplainDetailScreen({super.key});
  @override
  State<KomplainDetailScreen> createState() => _KomplainDetailScreenState();
}

class _KomplainDetailScreenState extends State<KomplainDetailScreen> {
  Future<Map<String, dynamic>>? _data;
  String ticket = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (_data == null && arg is String) {
      ticket = arg;
      _data = KomplainApi.instance.detail(arg);
    }
  }

  void _reload() => setState(() => _data = KomplainApi.instance.detail(ticket));

  void _zoom(String url) => showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: Stack(children: [
            InteractiveViewer(child: Center(child: CachedNetworkImage(imageUrl: url, fit: BoxFit.contain, errorWidget: (_, _, _) => const Icon(Icons.broken_image, color: Colors.white)))),
            Positioned(top: 8, right: 8, child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context))),
          ]),
        ),
      );

  Widget _body(Map<String, dynamic> c) {
    final status = c['status'] as String?;
    final overdue = c['is_overdue'] == true;
    final photos = ((c['photos'] as List?) ?? const []).map((e) => '$e').toList();
    final reporter = c['reporter'] is Map ? Map<String, dynamic>.from(c['reporter'] as Map) : null;
    String v(Object? x) => (x == null || '$x'.trim().isEmpty) ? '-' : '$x';

    return PullToRefresh(
      onRefresh: () async => _reload(),
      child: ListView(physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(16), children: [
        Row(children: [
          Expanded(child: Text('${c['ticket']}', style: ts(20, w: FontWeight.w800))),
          if (overdue) ...[const Pill('Terlambat', tone: Tone.bad), const Gap(0, w: 6)],
          Pill(_statusName(status), tone: _statusTone(status)),
        ]),
        const Gap(14),
        SummaryBox([
          ('Jenis', v(c['type_label'])),
          ('Bangunan / area', v(c['building'])),
          ('Nomor kamar', v(c['room_number'])),
          ('Detail lokasi', v(c['location'])),
          ('Dilaporkan', _when(c['created_at'] as String?)),
          ('Batas penanganan', _when(c['sla_deadline'] as String?)),
          if (c['resolved_at'] != null) ('Selesai pada', _when(c['resolved_at'] as String?)),
        ]),
        if (c['admin_notes'] != null && '${c['admin_notes']}'.trim().isNotEmpty) ...[
          const Gap(12),
          Notice('Catatan petugas: ${c['admin_notes']}', tone: Tone.info),
        ],
        const Gap(14),
        const SectionLabel('Uraian'),
        const Gap(6),
        AppCard(child: SizedBox(width: double.infinity, child: Text('${c['description']}', style: ts(14, h: 1.5)))),
        if (photos.isNotEmpty) ...[
          const Gap(14),
          const SectionLabel('Foto'),
          const Gap(8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final url in photos)
              GestureDetector(
                onTap: () => _zoom(url),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(imageUrl: url, width: 96, height: 96, fit: BoxFit.cover, placeholder: (_, _) => Container(width: 96, height: 96, color: C.chip), errorWidget: (_, _, _) => Container(width: 96, height: 96, color: C.chip, child: const Icon(Icons.broken_image, color: C.muted))),
                ),
              ),
          ]),
        ],
        if (reporter != null) ...[
          const Gap(14),
          const SectionLabel('Pelapor'),
          const Gap(6),
          SummaryBox([('Nama', v(reporter['name'])), ('NIK', v(reporter['nik'])), ('Jabatan', v(reporter['job_title'])), ('WhatsApp', v(reporter['wa']))]),
        ],
        const Gap(16),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: C.bg,
        body: SafeArea(
          child: Column(children: [
            const PageHeader('Rincian Laporan'),
            Expanded(
              child: _data == null
                  ? const Center(child: Text('Laporan tidak dikenali.'))
                  : FutureBuilder<Map<String, dynamic>>(
                      future: _data,
                      builder: (context, snap) {
                        if (snap.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
                        if (snap.hasError) return Center(child: _Err(snap.error!, _reload));
                        return _body(snap.data!);
                      },
                    ),
            ),
          ]),
        ),
      );
}
