import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/app_background.dart';
import './widgets/account_section_widget.dart';
import './widgets/area_units_selector_widget.dart';
import './widgets/language_selector_widget.dart';
import './widgets/reset_defaults_widget.dart';
import './widgets/weight_input_widget.dart';

// i18n + controle de idioma
import 'package:effatha_agro_simulator/l10n/app_localizations.dart';
import '../../core/localization/locale_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings state (moeda REMOVIDA — tratamos tudo como '$' e usamos formato pt_BR)
  String _selectedAreaUnit = 'hectares';
  String _selectedLanguage = 'pt_BR';
  double _kgPerSackWeight = 60.0;
  bool _kgPerSackWeight = 60.0;
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('selected_area_unit', _selectedAreaUnit);
      await prefs.setString('selected_language', _selectedLanguage);
      await prefs.setDouble('kg_per_sack_weight', _kgPerSackWeight);
      await prefs.setBool('is_manual_exchange_mode', _isManualExchangeMode);

      // Salvar taxas
      for (final entry in _exchangeRates.entries) {
        await prefs.setDouble('exchange_rate_${entry.key}', entry.value);
      }
    } catch (_) {}
  }

  Locale _localeFromCode(String code) {
    switch (code) {
      case 'en':
      case 'en_US':
        return const Locale('en');
      case 'pt':
      case 'pt_BR':
      default:
        return const Locale('pt');
    }
  }

  Future<void> _applyLanguage(String code) async {
    final locale = _localeFromCode(code);
    await LocaleController.instance.setLocale(locale);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final t = AppLocalizations.of(context);

    return AppBackground(
      assetPath: 'assets/images/bg_sim_soy.jpg',
      child: Scaffold(
        // Mantemos transparente porque o AppBackground cuida do fundo
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            t.settings,
            style: theme.appBarTheme.titleTextStyle,
          ),
          backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.primaryLight,
          foregroundColor:
              isDark ? AppTheme.textPrimaryDark : AppTheme.onPrimaryLight,
          elevation: 2,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: CustomIconWidget(
              iconName: 'arrow_back',
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.onPrimaryLight,
              size: 24,
            ),
          ),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.settings,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppTheme.textPrimaryDark
                                  : AppTheme.textPrimaryLight,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Customize your agricultural simulation experience',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Area Units Settings
                    AreaUnitsSelectorWidget(
                      selectedUnit: _selectedAreaUnit,
                      onUnitChanged: (unit) {
                        setState(() {
                          _selectedAreaUnit = unit;
                        });
                        _saveSettings();
                      },
                    ),

                    SizedBox(height: 3.h),

                    // Language Settings
                    LanguageSelectorWidget(
                      selectedLanguage: _selectedLanguage,
                      onLanguageChanged: (language) async {
                        setState(() {
                          _selectedLanguage = language; // 'pt_BR' | 'en_US'
                        });
                        await _saveSettings();
                        await _applyLanguage(language);
                      },
                    ),

                    SizedBox(height: 3.h),

                    // Weight Input Settings (kg/sack)
                    WeightInputWidget(
                      currentWeight: _kgPerSackWeight,
                      onWeightChanged: (weight) {
                        setState(() {
                          _kgPerSackWeight = weight;
                        });
                        _saveSettings();
                      },
                    ),

                    SizedBox(height: 3.h),

                    // Exchange Rate Settings (opcional)
                    ExchangeRateWidget(
                      isManualMode: _isManualExchangeMode,
                      exchangeRates: _exchangeRates,
                      onModeChanged: (isManual) {
                        setState(() {
                          _isManualExchangeMode = isManual;
                        });
                        _saveSettings();
                      },
                      onRateChanged: (currency, rate) {
                        setState(() {
                          _exchangeRates[currency] = rate;
                        });
                        _saveSettings();
                      },
                    ),

                    SizedBox(height: 4.h),

                    // Section divider
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: Text(
                        'Account',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimaryLight,
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Account Settings
                    AccountSectionWidget(
                      onLogout: _handleLogout,
                    ),

                    SizedBox(height: 4.h),

                    // Reset to Defaults
                    ResetDefaultsWidget(
                      onResetDefaults: _resetToDefaults,
                    ),

                    SizedBox(height: 4.h),

                    // App info
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Effatha Agro Simulator',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Version 1.0.0',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
      ),
    );
  }

  void _resetToDefaults() {
    setState(() {
      _selectedAreaUnit = 'hectares';
      _selectedLanguage = 'pt_BR';
      _kgPerSackWeight = 60.0;
      _kgPerSackWeight = 60.0;
    _saveSettings();
    _applyLanguage('pt_BR');
  }

  void _handleLogout() {
    SharedPreferences.getInstance().then((prefs) {
      prefs.clear();
    });

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login-screen',
      (route) => false,
    );
  }
}
