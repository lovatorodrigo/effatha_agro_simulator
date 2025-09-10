import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import 'core/localization/locale_controller.dart';
import 'l10n/app_localizations.dart';
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
  final localeCtrl = LocaleController.instance;
  await localeCtrl.loadSavedLocale();

  runApp(_LocaleProvider(
    notifier: localeCtrl,
    child: const MyApp(),
  ));
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
          routes: AppRoutes.routes,
          initialRoute: AppRoutes.initial,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
        );
      },
    );
  }
}
