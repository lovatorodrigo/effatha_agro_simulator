import 'package:effatha_agro_simulator/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Estado
  bool _isLoading = true;

  // Preferências
  String _selectedAreaUnit = 'hectares'; // 'hectares' | 'acres' | 'm²'
  String _selectedLanguage = 'pt_BR';    // 'pt_BR' | 'en_US'
  double _kgPerSackWeight = 60.0;        // peso padrão de 1 saca (kg)

  // ===== Ciclo de vida =====
  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _selectedAreaUnit =
            prefs.getString('selected_area_unit') ?? 'hectares';
        _selectedLanguage =
            prefs.getString('selected_language') ?? 'pt_BR';
        _kgPerSackWeight =
            prefs.getDouble('kg_per_sack_weight') ?? 60.0;
        _isLoading = false;
      });
    } catch (e) {
      // Em caso de erro, usa defaults e libera UI
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_area_unit', _selectedAreaUnit);
    await prefs.setString('selected_language', _selectedLanguage);
    await prefs.setDouble('kg_per_sack_weight', _kgPerSackWeight);
  }

  void _handleLogout() {
    Navigator.pushNamedAndRemoveUntil(context, '/login-screen', (_) => false);
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.applicationSettings),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.applicationSettings),
        actions: [
          IconButton(
            onPressed: () async {
              await _savePrefs();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.advancedSettings),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.save),
            tooltip: 'Salvar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== Unidade de área =====
            Text(
              AppLocalizations.of(context)!.areaUnit,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            DropdownButtonFormField<String>(
              value: _selectedAreaUnit,
              onChanged: (value) {
                setState(() {
                  _selectedAreaUnit = value ?? 'hectares';
                });
              },
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.areaUnit,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: 'hectares',
                  child: Text(AppLocalizations.of(context)!.hectares),
                ),
                DropdownMenuItem(
                  value: 'acres',
                  child: Text(AppLocalizations.of(context)!.acres),
                ),
                DropdownMenuItem(
                  value: 'm²',
                  child: Text(AppLocalizations.of(context)!.squareMeters),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // ===== Idioma =====
            Text(
              // Pode criar uma chave específica tipo "languageSettings" se quiser
              'Idioma',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value ?? 'pt_BR';
                });
              },
              decoration: const InputDecoration(
                labelText: 'Idioma',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'pt_BR', child: Text('Português (Brasil)')),
                DropdownMenuItem(value: 'en_US', child: Text('English (US)')),
              ],
            ),

            SizedBox(height: 3.h),

            // ===== Peso da saca (kg) =====
            Text(
              'Peso por saca (kg)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            TextFormField(
              initialValue: _kgPerSackWeight.toStringAsFixed(1),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: const InputDecoration(
                labelText: 'kg',
                border: OutlineInputBorder(),
              ),
              onChanged: (v) {
                final parsed = double.tryParse(v.replaceAll(',', '.'));
                if (parsed != null && parsed > 0) {
                  setState(() {
                    _kgPerSackWeight = parsed;
                  });
                }
              },
            ),

            SizedBox(height: 3.h),

            // ===== Ações =====
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await _savePrefs();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Preferências salvas'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout),
                  label: Text(AppLocalizations.of(context)!.logout),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
