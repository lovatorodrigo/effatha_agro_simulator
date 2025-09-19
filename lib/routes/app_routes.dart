// lib/routes/app_routes.dart
import 'package:flutter/widgets.dart';

import '../presentation/simulation_dashboard/simulation_dashboard.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/export_results_screen/export_results_screen.dart';
import '../presentation/consent_screen/consent_screen.dart';

class AppRoutes {
  static const String initial = '/consent-screen';  static const String settings = '/settings-screen';
  static const String exportResults = '/export-results-screen';  static const String simulationDashboard = '/simulation-dashboard';
  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const ConsentScreen(),    settings: (context) => SettingsScreen(),
    exportResults: (context) => ExportResultsScreen(),    simulationDashboard: (context) => SimulationDashboard(),
    '/consent-screen': (context) => const ConsentScreen(),  };
}
