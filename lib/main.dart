import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:someday/core/config/app_config.dart';
import 'package:someday/core/router/app_router.dart';
import 'package:someday/core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // In debug builds without --dart-define values, show a config error screen
  // instead of crashing. Production builds require real credentials.
  if (AppConfig.supabaseUrl.isEmpty || AppConfig.supabaseAnonKey.isEmpty) {
    if (kDebugMode) {
      runApp(const _MissingConfigApp());
      return;
    }
    throw StateError(
      'SUPABASE_URL and SUPABASE_ANON_KEY must be provided via --dart-define.',
    );
  }

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey, // ignore: deprecated_member_use
  );

  runApp(const ProviderScope(child: SomedayApp()));
}

class _MissingConfigApp extends StatelessWidget {
  const _MissingConfigApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFF0EDE8),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.eco_outlined, size: 64, color: Color(0xFFC97D3A)),
                const SizedBox(height: 24),
                const Text(
                  'Someday',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1C2B3A),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Run with:\nflutter run \\\n  --dart-define=SUPABASE_URL=<url> \\\n  --dart-define=SUPABASE_ANON_KEY=<key>',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7A8C7E),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SomedayApp extends StatefulWidget {
  const SomedayApp({super.key});

  @override
  State<SomedayApp> createState() => _SomedayAppState();
}

class _SomedayAppState extends State<SomedayApp> {
  late final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Someday',
      theme: buildAppTheme(),
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
