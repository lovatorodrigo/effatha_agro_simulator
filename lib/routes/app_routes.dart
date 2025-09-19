// lib/routes/app_routes.dart
import 'package:flutter/widgets.dart';

import '../presentation/login_screen/login_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/password_reset_screen/password_reset_screen.dart';
import '../presentation/simulation_dashboard/simulation_dashboard.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/export_results_screen/export_results_screen.dart';
import '../presentation/consent_screen/consent_screen.dart';

class AppRoutes {
  static const String initial = '/consent-screen';
  static const String passwordReset = '/password-reset-screen';
  static const String settings = '/settings-screen';
  static const String exportResults = '/export-results-screen';
  static const String login = '/login-screen';
  static const String simulationDashboard = '/simulation-dashboard';
  static const String registration = '/registration-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => LoginScreen(),
    passwordReset: (context) => PasswordResetScreen(),
    settings: (context) => SettingsScreen(),
    exportResults: (context) => ExportResultsScreen(),
    login: (context) => LoginScreen(),
    simulationDashboard: (context) => SimulationDashboard(),
    '/consent-screen': (context) => const ConsentScreen(),
    registration: (context) => RegistrationScreen(),
  };
}
