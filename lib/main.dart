import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import 'core/localization/locale_controller.dart';
import 'package:effatha_agro_simulator/l10n/app_localizations.dart';
import 'routes/app_routes.dart';

/// MODO DIAGNÓSTICO:
/// true  -> abre uma tela mínima (_BootProbe_) e NÃO usa initialRoute.
/// false -> fluxo normal do app (routes + initialRoute).
const bool kDiag = false;

/// SHA do commit (opcional). No Codemagic, passe:
/// flutter build apk --debug --dart-define=GIT_SHA=$CM_COMMIT
const String kGitSha = String.fromEnvironment('GIT_SHA', defaultValue: 'unknown');

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

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Captura erros globais de Flutter (UI)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    Zone.current.handleUncaughtError(
      details.exception,
      details.stack ?? StackTrace.empty,
    );
  };

  // Captura erros fora do Flutter (Dart/native -> evita branco silencioso)
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught error: $error');
    debugPrint('$stack');
    return true; // tratado
  };

  await LocaleController.instance.loadSavedLocale();
}

void main() async {
  await runZonedGuarded<Future<void>>(
    () async {
      await _bootstrap();
      runApp(
        _LocaleProvider(
          notifier: LocaleController.instance,
          child: const MyApp(),
        ),
      );
    },
    (error, stack) {
      debugPrint('runZonedGuarded: $error');
      debugPrint('$stack');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _buildLight() {
    final base = ThemeData(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
    );
  }

  ThemeData _buildDark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2E7D32),
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeCtrl = _LocaleProvider.of(context);

    // Em vez de branco, mostra cartão de erro com stacktrace
    ErrorWidget.builder = (details) {
      return Material(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: DefaultTextStyle(
                style: const TextStyle(color: Colors.black87),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 36),
                    const SizedBox(height: 8),
                    const Text(
                      'Ocorreu um erro na inicialização',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(details.exceptionAsString()),
                    const SizedBox(height: 12),
                    Text('${details.stack}', style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    };

    final lightTheme = _buildLight();
    final darkTheme = _buildDark();

    return Sizer(
      builder: (context, orientation, deviceType) {
        final routes = AppRoutes.routes;
        final initial = AppRoutes.initial;
        final hasInitial = routes.containsKey(initial);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('pt'), Locale('en')],
          locale: localeCtrl.locale,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,

          // DIAGNÓSTICO: tela mínima para testar rotas/assets
          home: kDiag ? _BootProbe(routes: routes, initialRoute: initial) : null,

          // Fluxo normal (quando kDiag=false)
          routes: routes,
          initialRoute: kDiag ? null : (hasInitial ? initial : _FallbackPage.routeName),

          onUnknownRoute: (settings) => MaterialPageRoute(
            builder: (_) => _FallbackPage(
              message:
                  'Rota desconhecida: ${settings.name}\nConfira AppRoutes.routes e AppRoutes.initial.',
            ),
          ),
        );
      },
    );
  }
}

class _BootProbe extends StatefulWidget {
  final Map<String, WidgetBuilder> routes;
  final String initialRoute;

  const _BootProbe({
    super.key,
    required this.routes,
    required this.initialRoute,
  });

  @override
  State<_BootProbe> createState() => _BootProbeState();
}

class _BootProbeState extends State<_BootProbe> {
  String _logoStatus = 'Pendente';
  String _bgStatus = 'Pendente';
  String _routeStatus = 'Pendente';

  @override
  void initState() {
    super.initState();
    _runChecks();
  }

  Future<void> _runChecks() async {
    final hasInitial = widget.routes.containsKey(widget.initialRoute);
    setState(() {
      _routeStatus = hasInitial
          ? 'OK (${widget.initialRoute})'
          : 'ERRO (rota não encontrada: ${widget.initialRoute})';
    });

    await _checkAsset('assets/images/logo_effatha.png',
        onOk: () => _logoStatus = 'OK',
        onErr: (e) => _logoStatus = 'ERRO: $e');

    await _checkAsset('assets/images/bg_sim_soy.jpg',
        onOk: () => _bgStatus = 'OK',
        onErr: (e) => _bgStatus = 'ERRO: $e');

    if (mounted) setState(() {});
  }

  Future<void> _checkAsset(
    String path, {
    required void Function() onOk,
    required void Function(Object e) onErr,
  }) async {
    try {
      await rootBundle.load(path);
      onOk();
    } catch (e) {
      onErr(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final routesList = widget.routes.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: Text('Diagnóstico de Inicialização — SHA: $kGitSha'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Status rápido',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _statusTile('Rota inicial', _routeStatus),
            _statusTile('Asset: logo_effatha.png', _logoStatus),
            _statusTile('Asset: bg_sim_soy.jpg', _bgStatus),

            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: Text('Abrir rota inicial: ${widget.initialRoute}'),
              onPressed: widget.routes.containsKey(widget.initialRoute)
                  ? () => Navigator.of(context).pushNamed(widget.initialRoute)
                  : null,
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            const Text('Rotas registradas',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...routesList.map(
              (r) => ListTile(
                dense: true,
                title: Text(r),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => Navigator.of(context).pushNamed(r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusTile(String label, String value) {
    final isOk = value.startsWith('OK');
    final isErr = value.startsWith('ERRO');
    final color = isOk ? Colors.green : (isErr ? Colors.red : Colors.orange);

    return Row(
      children: [
        Icon(isOk ? Icons.check_circle : Icons.error_outline, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FallbackPage extends StatelessWidget {
  static const routeName = '/__fallback__';
  final String? message;

  const _FallbackPage({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final routesList = AppRoutes.routes.keys.toList()..sort();
    return Scaffold(
      appBar: AppBar(title: const Text('Rota não encontrada')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (message != null) ...[
              Text(message!, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
            ],
            const Text('Rotas registradas:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            ...routesList.map(
              (r) => ListTile(
                dense: true,
                title: Text(r),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => Navigator.of(context).pushNamed(r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
