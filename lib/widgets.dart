import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'icons_data.dart';
import 'theme.dart';

enum Tone { ok, warn, bad, info, neutral, purple }

Color toneBg(Tone t) => switch (t) {
      Tone.ok => C.greenBg,
      Tone.warn => C.orangeBg,
      Tone.bad => C.redBg,
      Tone.info => C.blueSoft,
      Tone.purple => C.purpleBg,
      Tone.neutral => C.chip,
    };
Color toneFg(Tone t) => switch (t) {
      Tone.ok => C.greenFg,
      Tone.warn => C.orangeFg,
      Tone.bad => C.red,
      Tone.info => C.blueFg,
      Tone.purple => C.purple,
      Tone.neutral => C.text2,
    };

/// Tinggi baris 'normal' (px) Plus Jakarta Sans di Chrome, diukur dari mockup.
const _normalPx = {9: 11, 10: 12, 11: 13, 12: 15, 13: 16, 14: 18, 15: 19, 16: 21, 17: 22, 18: 23, 20: 25, 22: 28, 24: 30, 26: 33, 28: 35, 30: 38, 56: 70};
double normalLine(double size) => (_normalPx[size.round()] ?? (size * 1.26).round()) / size;

TextStyle ts(double size, {FontWeight w = FontWeight.w400, Color c = C.text, double? h}) =>
    TextStyle(inherit: false, textBaseline: TextBaseline.alphabetic, fontFamily: 'PlusJakartaSans', letterSpacing: 0, fontSize: size, fontWeight: w, color: c, height: h ?? normalLine(size));

class Pill extends StatelessWidget {
  final String text;
  final Tone tone;
  const Pill(this.text, {super.key, this.tone = Tone.neutral});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(color: toneBg(tone), borderRadius: BorderRadius.circular(99)),
        child: Text(text, style: ts(12, w: FontWeight.w600, c: toneFg(tone))),
      );
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color color;
  final Color border;
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color = Colors.white,
    this.border = C.line,
  });
  @override
  Widget build(BuildContext context) => Material(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: border)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
      );
}

class Logo extends StatelessWidget {
  final double size;
  const Logo({super.key, this.size = 40});
  @override
  Widget build(BuildContext context) => Image.asset('assets/logo.png', width: size, height: size, semanticLabel: 'Logo AKPSatu');
}

class IconBox extends StatelessWidget {
  final IconData icon;
  final Color bg, fg;
  final double size;
  const IconBox(this.icon, this.bg, this.fg, {super.key, this.size = 46});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(size * .3)),
        child: Icon(icon, color: fg, size: size * .48),
      );
}

class Avatar extends StatelessWidget {
  final String ini;
  final Color bg, fg;
  final double size;
  const Avatar(this.ini, {super.key, this.bg = const Color(0xFFDCE7FB), this.fg = C.blueFg, this.size = 40});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: Text(ini, style: ts(size * .36, w: FontWeight.w800, c: fg)),
      );
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final IconData? icon;
  final String? ic;
  final double height;
  const PrimaryButton(this.label, {super.key, this.onTap, this.color = C.blue, this.icon, this.ic, this.height = 52});
  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Material(
        color: enabled ? color : C.line,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (ic != null) ...[Ic(ic!, size: 20, stroke: 2, color: enabled ? Colors.white : C.muted), const SizedBox(width: 8)],
            if (icon != null) ...[Icon(icon, size: 20, color: enabled ? Colors.white : C.muted), const SizedBox(width: 8)],
            Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: ts(16, w: FontWeight.w700, c: enabled ? Colors.white : C.muted))),
          ]),
        ),
      ),
    );
  }
}

class OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final double height;
  const OutlineButton(this.label, {super.key, this.onTap, this.color = C.text, this.height = 48});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: onTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: const BorderSide(color: C.input),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: ts(14, w: FontWeight.w700),
          ),
          child: Text(label),
        ),
      );
}

/// Tombol kembali header (44x44, ikon 22 stroke 2).
class BackBtn extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;
  const BackBtn({super.key, this.onTap, this.label = 'Kembali'});
  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap ?? () => Navigator.of(context).maybePop(),
          child: const SizedBox(width: 44, height: 44, child: Center(child: Ic('back', size: 22, stroke: 2))),
        ),
      );
}

/// Header halaman: [<] Judul ........ trailing. Sama dengan `<header>` pada mockup.
class PageHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final bool border;
  final EdgeInsets padding;
  final Color color;
  const PageHeader(this.title, {super.key, this.trailing, this.border = true, this.padding = const EdgeInsets.fromLTRB(8, 12, 8, 12), this.color = Colors.white});
  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(color: color, border: border ? const Border(bottom: BorderSide(color: C.line)) : null),
        child: Row(children: [
          const BackBtn(),
          const SizedBox(width: 4),
          Expanded(child: Text(title, style: ts(18, w: FontWeight.w800))),
          if (trailing != null) trailing!,
        ]),
      );
}

/// Halaman dengan header putih + tombol kembali.
class SubPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? bottom;
  final List<Widget>? actions;
  final EdgeInsets padding;
  final bool scroll;
  const SubPage({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.bottom,
    this.actions,
    this.scroll = true,
    this.padding = const EdgeInsets.all(16),
  });
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: C.bg,
        body: SafeArea(
          child: Column(children: [
            PageHeader(title, trailing: actions == null ? null : Row(mainAxisSize: MainAxisSize.min, children: actions!)),
            Expanded(
              child: scroll ? SingleChildScrollView(padding: padding, child: body) : Padding(padding: padding, child: body),
            ),
            if (bottom != null)
              Container(
                decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: C.line))),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                child: bottom,
              ),
          ]),
        ),
      );
}

class Gap extends StatelessWidget {
  final double h, w;
  const Gap(this.h, {super.key, this.w = 0});
  @override
  Widget build(BuildContext context) => SizedBox(height: h, width: w);
}

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 8),
        child: Text(text, style: ts(12, w: FontWeight.w800, c: C.muted).copyWith(letterSpacing: .6)),
      );
}

class KV extends StatelessWidget {
  final String k, v;
  final Color? vColor;
  final bool bold;
  const KV(this.k, this.v, {super.key, this.vColor, this.bold = true});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 120, child: Text(k, style: ts(13, c: C.muted))),
          Expanded(child: Text(v, textAlign: TextAlign.right, style: ts(13, w: bold ? FontWeight.w700 : FontWeight.w500, c: vColor ?? C.text))),
        ]),
      );
}

class LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const LabeledField(this.label, this.child, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: ts(13, w: FontWeight.w600, c: C.text2)),
          const Gap(6),
          child,
        ]),
      );
}

InputDecoration fieldDeco({String? hint}) => InputDecoration(
      hintText: hint,
      isDense: false,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.input)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.input)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: C.blue, width: 2)),
    );

class TextBox extends StatelessWidget {
  final String label;
  final String? initial, hint;
  final int lines;
  final TextInputType? type;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  const TextBox(this.label, {super.key, this.initial, this.hint, this.lines = 1, this.type, this.onChanged, this.controller});
  @override
  Widget build(BuildContext context) => LabeledField(
        label,
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initial : null,
          maxLines: lines,
          keyboardType: type,
          onChanged: onChanged,
          style: ts(15),
          decoration: fieldDeco(hint: hint),
        ),
      );
}

class DropField<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String Function(T)? text;
  const DropField(this.label, {super.key, required this.value, required this.items, required this.onChanged, this.text});
  @override
  Widget build(BuildContext context) => LabeledField(
        label,
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          decoration: fieldDeco(),
          style: ts(15),
          items: [for (final i in items) DropdownMenuItem(value: i, child: Text(text?.call(i) ?? '$i', overflow: TextOverflow.ellipsis))],
          onChanged: onChanged,
        ),
      );
}

/// Pilihan bergaya chip (single select).
class ChoiceRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelect;
  final bool wrap;
  const ChoiceRow({super.key, required this.options, required this.selected, required this.onSelect, this.wrap = false});
  @override
  Widget build(BuildContext context) {
    final chips = [
      for (final o in options)
        Semantics(
          button: true,
          selected: o == selected,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => onSelect(o),
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: o == selected ? C.blueSoft : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: o == selected ? C.blue : C.input, width: o == selected ? 2 : 1),
              ),
              child: Text(o,
                  textAlign: TextAlign.center,
                  style: ts(14, w: o == selected ? FontWeight.w700 : FontWeight.w600, c: o == selected ? C.blueFg : C.text2)),
            ),
          ),
        ),
    ];
    if (wrap) return Wrap(spacing: 8, runSpacing: 8, children: chips);
    return Row(children: [for (var i = 0; i < chips.length; i++) ...[if (i > 0) const Gap(0, w: 8), Expanded(child: chips[i])]]);
  }
}

/// Tab segmen (Aktivitas / Riwayat dst.): tinggi 40, radius 9.
class Seg extends StatelessWidget {
  final List<String> tabs;
  final int index;
  final ValueChanged<int> onChange;
  final double gap;
  const Seg({super.key, required this.tabs, required this.index, required this.onChange, this.gap = 8});
  @override
  Widget build(BuildContext context) => Row(children: [
        for (var i = 0; i < tabs.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          Expanded(
            child: Semantics(
              button: true,
              selected: i == index,
              child: Material(
                color: i == index ? C.navy : Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9), side: i == index ? BorderSide.none : const BorderSide(color: C.input)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(9),
                  onTap: () => onChange(i),
                  child: SizedBox(height: 40, child: Center(child: Text(tabs[i], style: ts(14, w: i == index ? FontWeight.w700 : FontWeight.w600, c: i == index ? Colors.white : C.text2)))),
                ),
              ),
            ),
          ),
        ]
      ]);
}

/// Filter chip horizontal.
class FilterChips extends StatelessWidget {
  final List<String> items;
  final String value;
  final ValueChanged<String> onChange;
  const FilterChips({super.key, required this.items, required this.value, required this.onChange});
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final on = items[i] == value;
            return GestureDetector(
              onTap: () => onChange(items[i]),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: on ? C.navy : Colors.white,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: on ? C.navy : C.input),
                ),
                child: Text(items[i], style: ts(13, w: FontWeight.w700, c: on ? Colors.white : C.text2)),
              ),
            );
          },
        ),
      );
}

class Toggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const Toggle(this.value, this.onChanged, {super.key});
  @override
  Widget build(BuildContext context) => Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: C.blue,
        inactiveTrackColor: const Color(0xFFC4CDD9),
        inactiveThumbColor: Colors.white,
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      );
}

enum FlowState { ok, now, bad, wait }

class StepItem {
  final FlowState state;
  final String title, sub;
  const StepItem(this.state, this.title, this.sub);
}

class FlowSteps extends StatelessWidget {
  final List<StepItem> steps;
  const FlowSteps(this.steps, {super.key});
  @override
  Widget build(BuildContext context) => Column(children: [
        for (var i = 0; i < steps.length; i++)
          IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SizedBox(
                width: 28,
                child: Column(children: [
                  _dot(steps[i].state, i + 1),
                  if (i < steps.length - 1) Expanded(child: Container(width: 2, color: C.line)),
                ]),
              ),
              const Gap(0, w: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(steps[i].title,
                        style: ts(14, w: FontWeight.w700, c: steps[i].state == FlowState.wait ? C.muted : C.text)),
                    Text(steps[i].sub, style: ts(12, c: C.muted, h: 1.4)),
                  ]),
                ),
              ),
            ]),
          )
      ]);

  Widget _dot(FlowState s, int n) {
    final (bg, fg, t) = switch (s) {
      FlowState.ok => (C.green, Colors.white, '✓'),
      FlowState.now => (C.orange, Colors.white, '$n'),
      FlowState.bad => (C.red, Colors.white, '!'),
      FlowState.wait => (C.chip, C.muted, '$n'),
    };
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Text(t, style: ts(13, w: FontWeight.w800, c: fg)),
    );
  }
}

/// Banner info berwarna.
class Notice extends StatelessWidget {
  final String text;
  final Tone tone;
  final IconData icon;
  const Notice(this.text, {super.key, this.tone = Tone.warn, this.icon = Icons.info_outline});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: toneBg(tone), borderRadius: BorderRadius.circular(10)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: toneFg(tone)),
          const Gap(0, w: 8),
          Expanded(child: Text(text, style: ts(13, c: toneFg(tone), h: 1.4))),
        ]),
      );
}

/// Layar hasil sukses / gagal.
class ResultView extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, text;
  final List<Widget> children;
  const ResultView({super.key, required this.icon, required this.color, required this.title, required this.text, this.children = const []});
  @override
  Widget build(BuildContext context) => Column(children: [
        const Gap(16),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(color: color.withValues(alpha: .12), shape: BoxShape.circle),
          child: Icon(icon, size: 42, color: color),
        ),
        const Gap(16),
        Text(title, textAlign: TextAlign.center, style: ts(20, w: FontWeight.w800)),
        const Gap(8),
        Text(text, textAlign: TextAlign.center, style: ts(14, c: C.muted, h: 1.5)),
        const Gap(20),
        ...children,
      ]);
}

class SummaryBox extends StatelessWidget {
  final List<(String, String)> rows;
  const SummaryBox(this.rows, {super.key});
  @override
  Widget build(BuildContext context) => AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(children: [for (final r in rows) KV(r.$1, r.$2)]),
      );
}

class ChevronRow extends StatelessWidget {
  final Widget leading;
  final String? kicker;
  final String title;
  final String? sub;
  final VoidCallback? onTap;
  final Color color, border;
  const ChevronRow({super.key, required this.leading, required this.title, this.kicker, this.sub, this.onTap, this.color = Colors.white, this.border = C.line});
  @override
  Widget build(BuildContext context) => AppCard(
        onTap: onTap,
        color: color,
        border: border,
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          leading,
          const Gap(0, w: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (kicker != null) Text(kicker!, style: ts(12, c: C.muted)),
              Text(title, style: ts(14, w: FontWeight.w700, h: 1.35)),
              if (sub != null) Text(sub!, style: ts(13, c: C.muted, h: 1.4)),
            ]),
          ),
          const Icon(Icons.chevron_right, color: C.muted),
        ]),
      );
}

void toast(BuildContext c, String msg) {
  ScaffoldMessenger.of(c)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
}

Future<T?> sheet<T>(BuildContext c, Widget Function(BuildContext) b) => showModalBottomSheet<T>(
      context: c,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
        child: b(ctx),
      ),
    );


String _hex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

/// Ikon stroke bergaya mockup (viewBox 24, stroke 1.8). [name] = kunci di kIcons.
class Ic extends StatelessWidget {
  final String? name;
  final String? path;
  final double size;
  final Color color;
  final double stroke;
  const Ic(this.name, {super.key, this.size = 20, this.color = C.text, this.stroke = 1.8}) : path = null;
  const Ic.path(this.path, {super.key, this.size = 20, this.color = C.text, this.stroke = 1.8}) : name = null;
  @override
  Widget build(BuildContext context) {
    final inner = path != null ? '<path d="$path"/>' : (kIcons[name] ?? '');
    return SvgPicture.string(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="${_hex(color)}" '
      'stroke-width="$stroke" stroke-linecap="round" stroke-linejoin="round">$inner</svg>',
      width: size,
      height: size,
    );
  }
}


/// Setara `margin-top: -by` pada CSS: anak digeser ke atas dan tinggi layout berkurang.
class PullUp extends SingleChildRenderObjectWidget {
  final double by;
  const PullUp({super.key, required this.by, required super.child});
  @override
  RenderObject createRenderObject(BuildContext context) => _RenderPullUp(by);
  @override
  void updateRenderObject(BuildContext context, covariant _RenderPullUp r) => r.by = by;
}

class _RenderPullUp extends RenderShiftedBox {
  _RenderPullUp(this._by) : super(null);
  double _by;
  set by(double v) {
    if (v != _by) {
      _by = v;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    child!.layout(constraints, parentUsesSize: true);
    size = constraints.constrain(Size(child!.size.width, child!.size.height - _by));
    (child!.parentData! as BoxParentData).offset = Offset(0, -_by);
  }
}

/// Garis putus-putus horizontal (border-bottom: dashed).
class DashedLine extends StatelessWidget {
  final Color color;
  final double thickness;
  const DashedLine({super.key, this.color = C.input, this.thickness = 1.5});
  @override
  Widget build(BuildContext context) => SizedBox(width: double.infinity, height: thickness, child: CustomPaint(painter: _DashPainter(color, thickness)));
}

class _DashPainter extends CustomPainter {
  final Color color;
  final double t;
  _DashPainter(this.color, this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..strokeWidth = t;
    for (double x = 0; x < size.width; x += 6) {
      canvas.drawLine(Offset(x, t / 2), Offset((x + 3).clamp(0, size.width), t / 2), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Kotak putih bergaris (class `.card`): padding 16, radius 14.
class Card14 extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final Color border;
  final VoidCallback? onTap;
  const Card14({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.color = Colors.white, this.border = C.line, this.onTap});
  @override
  Widget build(BuildContext context) => Material(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: border)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: SizedBox(width: double.infinity, child: Padding(padding: padding, child: child))),
      );
}

/// Kotak bertepi putus-putus (border: dashed) dengan sudut membulat.
class DashedRRect extends StatelessWidget {
  final Widget child;
  final double radius;
  final Color color;
  final Color? fill;
  final double strokeWidth;
  final double height;
  const DashedRRect({super.key, required this.child, this.radius = 10, this.color = const Color(0xFFB8C4D4), this.fill, this.strokeWidth = 1.5, this.height = 64});
  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _DashRRectPainter(radius, color, fill, strokeWidth),
        child: SizedBox(width: double.infinity, height: height, child: child),
      );
}

class _DashRRectPainter extends CustomPainter {
  final double r;
  final Color color;
  final Color? fill;
  final double w;
  _DashRRectPainter(this.r, this.color, this.fill, this.w);
  @override
  void paint(Canvas canvas, Size size) {
    final rr = RRect.fromRectAndRadius(Rect.fromLTWH(w / 2, w / 2, size.width - w, size.height - w), Radius.circular(r));
    if (fill != null) canvas.drawRRect(rr, Paint()..color = fill!);
    final path = Path()..addRRect(rr);
    final p = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = w;
    for (final m in path.computeMetrics()) {
      var d = 0.0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, (d + 4).clamp(0, m.length)), p);
        d += 7;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}


/// Isi penuh layar tapi bisa digulir bila konten lebih tinggi dari layar (untuk layar pendek / teks besar).
class ScrollFill extends StatelessWidget {
  final Widget child;
  const ScrollFill({super.key, required this.child});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, box) => SingleChildScrollView(
          child: ConstrainedBox(constraints: BoxConstraints(minHeight: box.maxHeight), child: IntrinsicHeight(child: child)),
        ),
      );
}
