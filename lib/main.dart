import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import 'core/localization/locale_controller.dart';
import 'package:effatha_agro_simulator/l10n/app_localizations.dart';
import 'routes/app_routes.dart';

// >>> Toggle de diagnóstico: quando true, abre SafeBoot em vez da initialRoute
const bool kSafeBoot = true;

class _LocaleProvider extends InheritedNotifier<LocaleController> {
  const _LocaleProvider({
    required super.notifier,
    required super.child,
    super.key,
  });

  static LocaleController of(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<_LocaleProvider>();
    assert(widget != null, 'LocaleProvider not found');
    return widget!.notifier!;
  }

  @override
  bool updateShouldNotify(covariant _LocaleProvider oldWidget) => true;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --------- Tratamento global de erros (evita "tela branca") ---------
  ErrorWidget.builder = (FlutterErrorDetails details) {
    final Object exception = details.exception;
    return Material(
      color: Colors.white,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                const Text(
                  'Ocorreu um erro ao abrir a tela.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  exception.toString(),
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  };

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  final localeCtrl = LocaleController.instance;
  await localeCtrl.loadSavedLocale();

  runZonedGuarded(() {
    runApp(_LocaleProvider(
      notifier: localeCtrl,
      child: const MyApp(),
    ));
  }, (error, stack) {
    // Log opcional (Crashlytics/Sentry)
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeCtrl = _LocaleProvider.of(context);

    final baseLight = ThemeData(useMaterial3: true);
    final lightTheme = baseLight.copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
      textTheme: GoogleFonts.interTextTheme(baseLight.textTheme),
    );

    final baseDark = ThemeData.dark(useMaterial3: true);
    final darkTheme = baseDark.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2E7D32),
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTextTheme(baseDark.textTheme),
    );

    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          // Localizações
          onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('pt'), Locale('en')],
          locale: localeCtrl.locale,

          // Rotas registradas do app
          routes: AppRoutes.routes,

          // Modo diagnóstico: usa home em vez de initialRoute
          home: kSafeBoot ? const _SafeBootScreen() : null,
          initialRoute: kSafeBoot ? null : AppRoutes.initial,

          // Fallback para rotas desconhecidas
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => _UnknownRoutePage(
                name: settings.name ?? 'desconhecida',
              ),
            );
          },

          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
        );
      },
    );
  }
}

// ----------------- Safe Boot Screen (diagnóstico) -----------------
class _SafeBootScreen extends StatefulWidget {
  const _SafeBootScreen();

  @override
  State<_SafeBootScreen> createState() => _SafeBootScreenState();
}

class _SafeBootScreenState extends State<_SafeBootScreen> {
  String _status = 'App carregou. Pronto para testar rotas.';

  Future<void> _openInitialRoute() async {
    setState(() => _status = 'Abrindo rota inicial: ${AppRoutes.initial} ...');
    try {
      // pushReplacement para simular fluxo normal
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacementNamed(AppRoutes.initial);
    } catch (e) {
      setState(() => _status = 'Falha ao abrir initialRoute: $e');
      _showSnack('Erro ao abrir ${AppRoutes.initial}: $e');
    }
  }

  Future<void> _openNamed(String route) async {
    setState(() => _status = 'Abrindo rota: $route ...');
    try {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushNamed(route);
    } catch (e) {
      setState(() => _status = 'Falha ao abrir $route: $e');
      _showSnack('Erro ao abrir $route: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Safe Boot (Diagnóstico)')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.health_and_safety, size: 56),
                const SizedBox(height: 12),
                Text('Diagnóstico ativo', style: text.titleLarge, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  _status,
                  style: text.bodyMedium?.copyWith(color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _openInitialRoute,
                      icon: const Icon(Icons.play_arrow),
                      label: Text('Abrir initialRoute (${AppRoutes.initial})'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _openNamed('/export-results-screen'),
                      icon: const Icon(Icons.file_download),
                      label: const Text('Abrir /export-results-screen'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _openNamed('/settings-screen'),
                      icon: const Icon(Icons.settings),
                      label: const Text('Abrir /settings-screen'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _openNamed('/login-screen'),
                      icon: const Icon(Icons.login),
                      label: const Text('Abrir /login-screen'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Dica: quando tudo estiver ok, abra este arquivo e defina kSafeBoot=false '
                  'para voltar a usar a initialRoute normalmente.',
                  style: text.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------- Fallback de rota desconhecida -----------------
class _UnknownRoutePage extends StatelessWidget {
  final String name;
  const _UnknownRoutePage({required this.name});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Rota não encontrada')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.route, size: 48),
              const SizedBox(height: 12),
              Text('A rota "$name" não está registrada.',
                  style: text.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Verifique seu AppRoutes.routes/AppRoutes.initial ou a navegação por nome.',
                style: text.bodyMedium?.copyWith(color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
