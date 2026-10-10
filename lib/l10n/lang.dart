import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dict.dart';

/// Bahasa yang didukung. Teks sumber aplikasi berbahasa Indonesia; bahasa lain diterjemahkan lewat kamus ([dict]).
enum AppLang {
  id('id', 'Bahasa Indonesia', 'ID'),
  en('en', 'English', 'EN'),
  ko('ko', '한국어', 'KO');

  final String code;
  final String label;
  final String badge;
  const AppLang(this.code, this.label, this.badge);
}

/// Pengaturan bahasa aplikasi (tersimpan di perangkat) + penerjemah teks.
///
/// Teks sumber (Indonesia) dipakai sebagai kunci kamus. Teks yang berisi angka/nama diterjemahkan lewat pola dengan
/// penampung `{}` (urut) atau `{1}`, `{2}` (bila urutan berbeda di bahasa tujuan). Teks yang tidak ada di kamus tampil apa adanya.
/// Kunci boleh diberi konteks `Kata|konteks` untuk membedakan arti; bahasa Indonesia membuang bagian `|konteks`.
class L extends ChangeNotifier {
  L._();
  static final L instance = L._();
  static const _key = 'app.lang';

  AppLang lang = AppLang.id;

  Locale get locale => Locale(lang.code);

  Future<void> restore() async {
    try {
      final p = await SharedPreferences.getInstance();
      final code = p.getString(_key);
      lang = AppLang.values.firstWhere((l) => l.code == code, orElse: () => AppLang.id);
    } catch (_) {}
  }

  Future<void> set(AppLang next) async {
    if (next == lang) return;
    lang = next;
    _cache.clear();
    notifyListeners();
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_key, next.code);
    } catch (_) {}
  }

  /// Panggil di `build` agar widget digambar ulang saat bahasa berganti (untuk teks yang diformat di kode, mis. tanggal).
  static void watch(BuildContext context) => context.dependOnInheritedWidgetOfExactType<LangScope>();

  // — Penerjemah —

  final _cache = <String, String>{};
  AppLang? _cacheLang;
  AppLang? _patternLang;
  List<_Pattern> _patterns = const [];

  String translate(String s) {
    if (s.isEmpty) return s;
    if (lang == AppLang.id) return _stripContext(s);
    if (_cacheLang != lang) {
      _cache.clear();
      _cacheLang = lang;
    }
    return _cache.putIfAbsent(s, () => _translate(s));
  }

  static String _stripContext(String s) {
    final i = s.indexOf('|');
    return i <= 0 ? s : s.substring(0, i);
  }

  String _pick((String, String) v) => lang == AppLang.en ? v.$1 : v.$2;

  String _translate(String s) {
    final exact = dict[s];
    if (exact != null) return _pick(exact);
    // Tanpa konteks: coba kunci dasar.
    final base = _stripContext(s);

    final byBase = base == s ? null : dict[base];
    if (byBase != null) return _pick(byBase);

    final viaPattern = _viaPattern(base);
    if (viaPattern != null) return viaPattern;

    // "A · B · C": terjemahkan per bagian.
    if (base.contains(' · ')) {
      final parts = base.split(' · ');
      final out = parts.map((p) => _part(p)).toList();
      return out.join(' · ');
    }
    return _words(base);
  }

  /// Satu bagian dari teks bertanda " · ": kamus, pola, lalu nama hari/bulan.
  String _part(String p) {
    final e = dict[p];
    if (e != null) return _pick(e);
    return _viaPattern(p) ?? _words(p);
  }

  String? _viaPattern(String s) {
    if (_patternLang != lang) {
      _patternLang = lang;
      _patterns = [for (final e in dict.entries) if (e.key.contains('{') && !e.key.contains('|')) _Pattern(e.key, _pick(e.value))];
    }
    for (final p in _patterns) {
      final out = p.apply(s, (v) => _words(dict[v] == null ? v : _pick(dict[v]!)));
      if (out != null) return out;
    }
    return null;
  }

  static final _shortDate = RegExp(r'\b(\d{1,2}) (Jan|Feb|Mar|Apr|Mei|Jun|Jul|Agu|Sep|Okt|Nov|Des) (\d{4})\b');

  /// Ganti tanggal pendek ("5 Okt 2026") dan nama hari/bulan Indonesia (kata utuh) dengan bahasa tujuan.
  String _words(String s) {
    s = s.replaceAllMapped(_shortDate, (m) {
      final month = _id.monthsShort.indexOf(m[2]!) + 1;
      return lang == AppLang.ko ? '${m[3]}년 $month월 ${m[1]}일' : '${m[1]} ${_names.monthsShort[month - 1]} ${m[3]}';
    });
    return s.replaceAllMapped(_dateWord, (m) {
      final w = m[0]!;
      final v = dateWords[w];
      return v == null ? w : _pick(v);
    });
  }

  static final _dateWord = RegExp(r'\b(?:' + dateWords.keys.join('|') + r')\b');

  // — Format tanggal —

  static const _id = _Names(
    long: ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'],
    short: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
    months: ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'],
    monthsShort: ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'],
  );
  static const _en = _Names(
    long: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
    short: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    months: ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
    monthsShort: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
  );
  static const _ko = _Names(
    long: ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'],
    short: ['월', '화', '수', '목', '금', '토', '일'],
    months: ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'],
    monthsShort: ['1월', '2월', '3월', '4월', '5월', '6월', '7월', '8월', '9월', '10월', '11월', '12월'],
  );

  _Names get _names => switch (lang) { AppLang.id => _id, AppLang.en => _en, AppLang.ko => _ko };

  /// [weekday] 1 = Senin ... 7 = Minggu (seperti DateTime.weekday).
  String weekday(int weekday) => _names.long[weekday - 1];
  String weekdayShort(int weekday) => _names.short[weekday - 1];

  /// [month] 1..12
  String month(int month) => _names.months[month - 1];
  String monthShort(int month) => _names.monthsShort[month - 1];

  /// Rabu, 8 Oktober 2026 / Wednesday, 8 October 2026 / 2026년 10월 8일 수요일
  String longDate(DateTime d) => switch (lang) {
        AppLang.id => '${weekday(d.weekday)}, ${d.day} ${month(d.month)} ${d.year}',
        AppLang.en => '${weekday(d.weekday)}, ${d.day} ${month(d.month)} ${d.year}',
        AppLang.ko => '${d.year}년 ${d.month}월 ${d.day}일 ${weekday(d.weekday)}',
      };

  /// 8 Okt 2026 / 8 Oct 2026 / 2026년 10월 8일
  String shortDate(DateTime d) => lang == AppLang.ko ? '${d.year}년 ${d.month}월 ${d.day}일' : '${d.day} ${monthShort(d.month)} ${d.year}';

  /// Oktober 2026 / October 2026 / 2026년 10월
  String monthYear(DateTime d) => lang == AppLang.ko ? '${d.year}년 ${d.month}월' : '${month(d.month)} ${d.year}';
}

class _Names {
  final List<String> long, short, months, monthsShort;
  const _Names({required this.long, required this.short, required this.months, required this.monthsShort});
}

/// Pola terjemahan: kunci Indonesia dengan `{}` → regex penangkap.
class _Pattern {
  final RegExp re;
  final String target;
  _Pattern(String key, this.target) : re = _compile(key);

  static final _token = RegExp(r'\{#?\}');

  /// `{}` = teks apa saja, `{#}` = angka/jam/tanggal (digit, titik, koma, titik dua, garis miring, strip).
  static RegExp _compile(String key) {
    final b = StringBuffer('^');
    var last = 0;
    for (final m in _token.allMatches(key)) {
      b.write(RegExp.escape(key.substring(last, m.start)));
      b.write(m[0] == '{#}' ? r'(\d[\d.,:/–-]*)' : '(.+?)');
      last = m.end;
    }
    b.write(RegExp.escape(key.substring(last)));
    b.write(r'$');
    return RegExp(b.toString(), dotAll: true);
  }

  String? apply(String s, String Function(String) tx) {
    final m = re.firstMatch(s);
    if (m == null) return null;
    final g = [for (var i = 1; i <= m.groupCount; i++) tx(m[i]!)];
    var n = 0;
    return target.replaceAllMapped(RegExp(r'\{(\d*)\}'), (x) {
      final idx = x[1]!.isEmpty ? n++ : int.parse(x[1]!) - 1;
      return idx < g.length ? g[idx] : '';
    });
  }
}

/// Terjemahkan teks sumber (Indonesia) ke bahasa yang sedang dipakai.
String tr(String s) => L.instance.translate(s);

/// Memberi tahu widget di bawahnya agar digambar ulang saat bahasa berganti.
class LangScope extends InheritedNotifier<L> {
  LangScope({super.key, required super.child}) : super(notifier: L.instance);
}
