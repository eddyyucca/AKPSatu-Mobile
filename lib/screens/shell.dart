import 'package:flutter/material.dart' hide Text;
import '../api/notifications.dart';
import '../theme.dart';
import '../widgets.dart';
import 'attendance.dart';
import 'barcode.dart';
import 'home.dart';
import 'profile.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int i = widget.initialIndex;

  @override
  void initState() {
    super.initState();
    NotificationCenter.instance.attach(); // pemeriksaan notifikasi berjalan selama layar utama tampil
  }

  @override
  void dispose() {
    NotificationCenter.instance.detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: C.bg,
        body: SafeArea(
          bottom: false,
          child: IndexedStack(index: i, sizing: StackFit.expand, children: const [
            HomePage(),
            AttendancePage(),
            BarcodePage(),
            ProfilePage(),
          ]),
        ),
        bottomNavigationBar: AppTabBar(index: i, onTap: (n) => setState(() => i = n)),
      );
}

class AppTabBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const AppTabBar({super.key, required this.index, required this.onTap});

  static const _tabs = [('home', 'Beranda'), ('clock', 'Absensi'), ('qr', 'Makan'), ('user', 'Profil')];

  @override
  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: C.line))),
        padding: EdgeInsets.fromLTRB(8, 6, 8, 12 + MediaQuery.of(context).padding.bottom),
        child: Row(children: [
          for (var n = 0; n < _tabs.length; n++)
            Expanded(
              child: Semantics(
                button: true,
                selected: n == index,
                label: _tabs[n].$2,
                child: InkWell(
                  onTap: () => onTap(n),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 56),
                    child: Column(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Ic(_tabs[n].$1, size: 22, color: n == index ? C.blue : C.muted),
                      const SizedBox(height: 4),
                      Text(_tabs[n].$2, style: ts(11, w: FontWeight.w600, c: n == index ? C.blue : C.muted)),
                    ]),
                  ),
                ),
              ),
            ),
        ]),
      );
}

/// Header putih halaman tab (judul 20 w800).
class TabHeader extends StatelessWidget {
  final String title;
  final Widget? extra;
  const TabHeader(this.title, {super.key, this.extra});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
        decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: C.line))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: ts(20, w: FontWeight.w800)),
          if (extra != null) ...[const SizedBox(height: 12), extra!],
        ]),
      );
}
