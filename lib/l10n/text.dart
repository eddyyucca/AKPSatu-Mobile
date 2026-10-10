import 'package:flutter/widgets.dart' as w;
import 'package:flutter/widgets.dart' hide Text;
import 'lang.dart';

/// Pengganti `Text` bawaan Flutter: teks sumber (Indonesia) diterjemahkan otomatis ke bahasa aplikasi
/// dan digambar ulang saat bahasa berganti. Teks yang tidak ada di kamus tampil apa adanya.
class Text extends StatelessWidget {
  final String? data;
  final InlineSpan? textSpan;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final String? semanticsLabel;

  const Text(String this.data, {super.key, this.style, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.semanticsLabel}) : textSpan = null;

  const Text.rich(InlineSpan this.textSpan, {super.key, this.style, this.textAlign, this.maxLines, this.overflow, this.softWrap, this.semanticsLabel}) : data = null;

  @override
  Widget build(BuildContext context) {
    context.dependOnInheritedWidgetOfExactType<LangScope>();   // gambar ulang saat bahasa berganti
    if (textSpan != null) {
      return w.Text.rich(textSpan!, style: style, textAlign: textAlign, maxLines: maxLines, overflow: overflow, softWrap: softWrap, semanticsLabel: semanticsLabel);
    }
    return w.Text(tr(data!), style: style, textAlign: textAlign, maxLines: maxLines, overflow: overflow, softWrap: softWrap, semanticsLabel: semanticsLabel == null ? null : tr(semanticsLabel!));
  }
}
