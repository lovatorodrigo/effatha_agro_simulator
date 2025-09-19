import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'presentation/simulation_dashboard/simulation_dashboard.dart';
import 'presentation/settings/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EffathaApp());
}

class EffathaApp extends StatelessWidget {
  const EffathaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Effatha Agro Simulator',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        brightness: Brightness.dark,
      ),
      initialRoute: AppRoutes.simulationDashboard,
      routes: {
        AppRoutes.simulationDashboard: (context) => const SimulationDashboard(),
        AppRoutes.settings: (context) => const SettingsScreen(),
      },
    );
  }
}
