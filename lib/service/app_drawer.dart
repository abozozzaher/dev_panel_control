import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../generated/l10n.dart';
import 'auth_service.dart';

class AppDrawer extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;

  const AppDrawer(
      {super.key, required this.toggleTheme, required this.toggleLocale});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
//  final String version = 'Version 2024.09.23';

  String version = '';

  @override
  void initState() {
    super.initState();
    loadVersion();
  }

  Future<void> loadVersion() async {
    String data = await rootBundle.loadString('panel_control/README.md');
    // ابحث عن رقم الإصدار في النص المحمل
    final versionMatch =
        RegExp(r'## Version\s+(\d+\.\d+\.\d+)').firstMatch(data);
    if (versionMatch != null) {
      setState(() {
        version = versionMatch.group(1) ?? 'Unknown';
      });
    }
  }

  // رقم الإصدار
  @override
  Widget build(BuildContext context) {
    final String currentRoute = ModalRoute.of(context)!.settings.name ?? '/';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
              S().menu,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          if (currentRoute != '/')
            ListTile(
              leading: const Icon(Icons.home_filled),
              title: Text(S().go_to_page),
              onTap: () {
                context.go('/');
              },
            ),
          if (currentRoute != '/')
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: Text(S().toggle_theme),
              onTap: widget.toggleTheme,
            ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(S().toggle_language),
            onTap: widget.toggleLocale,
          ),
          if (currentRoute == '/')
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(S().logout),
              onTap: () async {
                await AuthService().logout(context);
              },
            ),
          const Spacer(), // يملأ المساحة المتبقية

          // رقم الإصدار
          Text(
            version.isNotEmpty ? 'Version $version' : 'Loading...',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}