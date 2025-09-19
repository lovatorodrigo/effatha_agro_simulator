import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import 'core/localization/locale_controller.dart';
import 'package:effatha_agro_simulator/l10n/app_localizations.dart';
import 'routes/app_routes.dart';

/// Provider simples para expor o LocaleController na árvore.
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
    Zone.current.handleUncaughtError(details.exception, details.stack ?? StackTrace.empty);
  };

  // Captura erros não tratados fora do Flutter (Dart)
  PlatformDispatcher.instance.onError = (error, stack) {
    // Loga e evita que vire tela branca silenciosa
    debugPrint('Uncaught error: $error');
    debugPrint('$stack');
    return true; // já tratamos
  };

  // Carrega locale salvo (síncrono com o que você já usava)
  await LocaleController.instance.loadSavedLocale();
}

void main() async {
  await runZonedGuarded<Future<void>>(
    () async {
      await _bootstrap();

      final localeCtrl = LocaleController.instance;

      runApp(
        _LocaleProvider(
          notifier: localeCtrl,
          child: const MyApp(),
        ),
      );
    },
    (error, stack) {
      // Qualquer erro que escapar cai aqui
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

    // Mostra um "cartão" vermelho nos lugares onde ocorreria tela branca.
    ErrorWidget.builder = (FlutterErrorDetails details) {
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
        // Verifica se a rota inicial realmente existe.
        final String configuredInitial = AppRoutes.initial;
        final Map<String, WidgetBuilder> routes = AppRoutes.routes;
        final bool hasInitial = routes.containsKey(configuredInitial);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('pt'),
            Locale('en'),
          ],
          locale: localeCtrl.locale,
          routes: routes,
          // Se a rota inicial não existir, cai no FallbackPage em vez de tela branca
          initialRoute: hasInitial ? configuredInitial : _FallbackPage.routeName,
          onUnknownRoute: (settings) => MaterialPageRoute(
            builder: (_) => _FallbackPage(
              message:
                  'Rota desconhecida: ${settings.name}\nConfira AppRoutes.routes e AppRoutes.initial.',
            ),
          ),
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          // (Opcional) Tela de transição inteligível para primeiro frame
          builder: (context, child) => _FirstFrameGuard(child: child),
        );
      },
    );
  }
}

/// Página de fallback amigável caso a rota inicial/unknown falhe.
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
              Text(
                message!,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
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

/// Evita tela branca no primeiro frame e tenta pré-carregar o logo.
/// Se o asset estiver faltando, apenas loga (não quebra a UI).
class _FirstFrameGuard extends StatefulWidget {
  final Widget? child;
  const _FirstFrameGuard({required this.child});

  @override
  State<_FirstFrameGuard> createState() => _FirstFrameGuardState();
}

class _FirstFrameGuardState extends State<_FirstFrameGuard> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    try {
      // Tenta pré-carregar o logo (ajuste o caminho se mudar de PNG/JPG)
      await precacheImage(const AssetImage('assets/images/logo_effatha.png'), context)
          .catchError((e, s) {
        debugPrint('Logo não pôde ser pré-carregado: $e');
      });
    } catch (e, s) {
      debugPrint('Erro no preload do logo: $e');
      debugPrint('$s');
    } finally {
      if (mounted) {
        setState(() => _ready = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Material(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return widget.child ?? const SizedBox.shrink();
  }
}
