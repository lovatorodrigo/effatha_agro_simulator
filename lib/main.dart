import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import 'core/localization/locale_controller.dart';
import 'package:effatha_agro_simulator/l10n/app_localizations.dart';
import 'routes/app_routes.dart';

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
  // Substitui o widget de erro padrão por uma tela amigável
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

  // Captura erros do Flutter (pipeline de widgets)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // Aqui você pode enviar para Crashlytics/Sentry se quiser.
    // debugPrint(details.exceptionAsString());
  };

  final localeCtrl = LocaleController.instance;
  await localeCtrl.loadSavedLocale();

  // Captura erros fora do pipeline de widgets
  runZonedGuarded(() {
    runApp(_LocaleProvider(
      notifier: localeCtrl,
      child: const MyApp(),
    ));
  }, (error, stack) {
    // Envie logs se quiser (Crashlytics/Sentry)
    // debugPrint('Uncaught zone error: $error');
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

          // Título localizado
          onGenerateTitle: (ctx) => AppLocalizations.of(ctx).appTitle,

          // Localizações
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

          // Rotas do app
          routes: AppRoutes.routes,
          initialRoute: AppRoutes.initial,

          // Fallback para rotas desconhecidas (evita crash/tela branca)
          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => _UnknownRoutePage(
                name: settings.name ?? 'desconhecida',
              ),
            );
          },

          // Temas
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
        );
      },
    );
  }
}

// Página simples para quando uma rota não estiver registrada.
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
              Text('A rota "$name" não está registrada.', style: text.titleMedium, textAlign: TextAlign.center),
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
