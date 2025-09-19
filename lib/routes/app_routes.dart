// Minimal routes without auth/profile
import 'package:flutter/material.dart';

import '../presentation/simulation_dashboard/simulation_dashboard.dart';
import '../presentation/settings/settings_screen.dart';

class AppRoutes {
  // rota inicial -> dashboard
  static const String initial = '/simulation-dashboard';

  static Map<String, WidgetBuilder> get routes {
    return {
      '/simulation-dashboard': (context) => const SimulationDashboard(),
      '/settings-screen': (context) => const SettingsScreen(),
    };
  }
}
