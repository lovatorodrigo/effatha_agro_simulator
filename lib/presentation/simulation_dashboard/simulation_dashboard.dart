import 'package:effatha_agro_simulator/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import '../export_results_screen/export_results_screen.dart'
    show SimulationExportArgs;

import './widgets/comparison_card_widget.dart';
import './widgets/crop_selector_widget.dart';
import './widgets/input_card_widget.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/results_summary_widget.dart';

class SimulationDashboard extends StatefulWidget {
  const SimulationDashboard({super.key});

  @override
  State<SimulationDashboard> createState() => _SimulationDashboardState();
}

class _SimulationDashboardState extends State<SimulationDashboard> {
  // Form data
  String _selectedCrop = 'soy';
  String _area = '100';
  String _historicalProductivity = '60';
  String _historicalCosts = '5000';
  String _cropPrice = '80';
  String _effathaInvestment = '500';
  String _additionalProductivity = '15';

  // Settings
  String _currency = 'USD';
  double _kgPerSackWeight = 60.0;
  String _priceUnit = r'$/sack';
  String _areaUnit = 'hectares';
  String _productivityUnit = 'sc/ha';

  // Per-parameter units (configuráveis)
  String _costUnit = r'$/ha';
  String _investmentUnit = r'$/ha';
  String _additionalProductivityUnit = 'sc/ha';

  // Results
  Map<String, dynamic> _traditionalResults = {};
  Map<String, dynamic> _effathaResults = {};

  // Backgrounds por cultura
  final Map<String, String> _cropBackgrounds = const {
    'soy': 'assets/images/bg_sim_soy.jpg',
    'corn': 'assets/images/bg_sim_corn.jpg',
    'cotton': 'assets/images/bg_sim_cotton.jpg',
    'sugarcane': 'assets/images/bg_sim_sugarcane.jpg',
    'wheat': 'assets/images/bg_sim_wheat.jpg',
    'coffee': 'assets/images/bg_sim_coffee.jpg',
    'orange': 'assets/images/bg_sim_orange.jpg',
  };

  @override
  void initState() {
    super.initState();
    _loadKgPerSack();
    _calculateResults();
  }

  Future<void> _loadKgPerSack() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final k = prefs.getDouble('kg_per_sack_weight');
      if (!mounted) return;
      if (k != null && k > 0) {
        setState(() => _kgPerSackWeight = k);
      }
    } catch (_) {
      // mantém default 60.0
    }
  }

  // --------------------------- Helpers de formatação --------------------------

  String _fmtMoney(double value) {
    final f =
        NumberFormat.currency(locale: 'pt_BR', symbol: r'$ ', decimalDigits: 2);
    return f.format(value);
  }

  String _fmtPercent(double value, {int decimals = 1}) {
    final rounded = double.parse(value.toStringAsFixed(decimals));
    return '${NumberFormat.decimalPattern('pt_BR').format(rounded)}%';
  }

  String _formatTotalProduction(double totalKg) {
    switch (_productivityUnit) {
      case 'kg/ha':
        return '${totalKg.toStringAsFixed(0)} kg';
      case 't/ha':
        return '${(totalKg / 1000.0).toStringAsFixed(2)} t';
      case 'sc/ha':
      case 'sc/acre':
      default:
        final sacks = totalKg / _kgPerSackWeight;
        return '${sacks.toStringAsFixed(0)} sacas';
    }
  }

  // ----------------------------- Cálculos principais --------------------------

  void _calculateResults() {
    final double area = double.tryParse(_area) ?? 0.0;
    final double productivity = double.tryParse(_historicalProductivity) ?? 0.0;
    final double costs = double.tryParse(_historicalCosts) ?? 0.0;
    final double price = double.tryParse(_cropPrice) ?? 0.0;
    final double investment = double.tryParse(_effathaInvestment) ?? 0.0;
    final double additionalProd =
        double.tryParse(_additionalProductivity) ?? 0.0;

    const double acresPerHectare = 2.47105;

    // Área base (ha)
    final double areaHa =
        _areaUnit == 'acres' ? (area / acresPerHectare) : area;

    // Preço por kg conforme unidade escolhida
    double pricePerKg;
    switch (_priceUnit) {
      case r'$/kg':
        pricePerKg = price;
        break;
      case r'$/t':
        pricePerKg = price / 1000.0;
        break;
      case r'$/sack':
      default:
        pricePerKg = _kgPerSackWeight > 0 ? price / _kgPerSackWeight : 0.0;
        break;
    }

    // Conversores
    double toKgPerHa(double value, String unit) {
      switch (unit) {
        case 'kg/ha':
          return value;
        case 't/ha':
          return value * 1000.0;
        case 'sc/ha':
          return value * _kgPerSackWeight;
        case 'sc/acre':
          return value * acresPerHectare * _kgPerSackWeight;
        default:
          return value;
      }
    }

    double toDollarsPerHa(double value, String unit) {
      switch (unit) {
        case r'$/ha':
          return value;
        case r'$/acre':
          return value * acresPerHectare;
        case 'sc/ha':
          return value * _kgPerSackWeight * pricePerKg;
        case 'sc/acre':
          return value * acresPerHectare * _kgPerSackWeight * pricePerKg;
        default:
          return value;
      }
    }

    final double productivityKgPerHa =
        toKgPerHa(productivity, _productivityUnit);
    final double additionalProdKgPerHa =
        toKgPerHa(additionalProd, _additionalProductivityUnit);
    final double costsPerHa = toDollarsPerHa(costs, _costUnit);
    final double investmentPerHa = toDollarsPerHa(investment, _investmentUnit);

    // Tradicional
    final double traditionalProductionKg = areaHa * productivityKgPerHa;
    final double traditionalRevenue = traditionalProductionKg * pricePerKg;
    final double traditionalTotalCosts = areaHa * costsPerHa;
    final double traditionalProfit =
        traditionalRevenue - traditionalTotalCosts;
    final double traditionalProfitability = traditionalTotalCosts > 0
        ? (traditionalProfit / traditionalTotalCosts) * 100.0
        : 0.0;

    // Com Effatha
    final double effathaProductionKg =
        areaHa * (productivityKgPerHa + additionalProdKgPerHa);
    final double effathaRevenue = effathaProductionKg * pricePerKg;
    final double effathaInvestmentTotal = areaHa * investmentPerHa;
    final double effathaTotalCosts = areaHa * (costsPerHa + investmentPerHa);
    final double effathaProfit = effathaRevenue - effathaTotalCosts;
    final double effathaProfitability = effathaTotalCosts > 0
        ? (effathaProfit / effathaTotalCosts) * 100.0
        : 0.0;

    // Métricas adicionais
    final double additionalProfit = effathaProfit - traditionalProfit;
    final double additionalProfitPercent = traditionalProfit.abs() > 0
        ? (additionalProfit / traditionalProfit) * 100.0
        : 0.0;
    final double roi = effathaInvestmentTotal > 0
        ? (additionalProfit / effathaInvestmentTotal) * 100.0
        : 0.0;

    setState(() {
      _traditionalResults = {
        'investmentTotal': _fmtMoney(traditionalTotalCosts),
        'productionTotal': _formatTotalProduction(traditionalProductionKg),
        'profitabilityPercent': _fmtPercent(traditionalProfitability),
        // ROI tradicional ~ rentabilidade tradicional (aproximação)
        'roi': _fmtPercent(traditionalProfitability),
        'profit': traditionalProfit,
        'revenue': traditionalRevenue,
      };

      _effathaResults = {
        'investmentTotal': _fmtMoney(effathaTotalCosts),
        'productionTotal': _formatTotalProduction(effathaProductionKg),
        'profitabilityPercent': _fmtPercent(effathaProfitability),
        'roi': _fmtPercent(roi),
        'additionalProfit': _fmtMoney(additionalProfit),
        'additionalProfitPercent': _fmtPercent(additionalProfitPercent),
        'profit': effathaProfit,
        'revenue': effathaRevenue,
      };
    });
  }

  // --------------------------------- UI --------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Usamos DefaultTabController para evitar erros de controller ausente
    return DefaultTabController(
      length: 3,
      child: Builder(
        builder: (outerCtx) {
          final tabController = DefaultTabController.of(outerCtx)!;

          return Scaffold(
            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_cropBackgrounds[_selectedCrop]!),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x99000000),
                      Color(0x00000000),
                      Color(0x99000000),
                    ],
                    stops: [0.0, 0.3, 1.0],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      _buildAppBar(theme),
                      _buildTabBar(theme),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildDashboardTab(),
                            _buildSettingsTab(),
                            _buildProfileTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // FAB só na aba 0 (Dashboard)
            floatingActionButton: AnimatedBuilder(
              animation: tabController,
              builder: (ctx, _) {
                final idx = tabController.index;
                if (idx != 0) return const SizedBox.shrink();
                return FloatingActionButton.extended(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/export-results-screen',
                    arguments: SimulationExportArgs(
                      traditional: _traditionalResults,
                      effatha: _effathaResults,
                      cropKey: _selectedCrop,
                      areaUnit: _areaUnit,
                      productivityUnit: _productivityUnit,
                      kgPerSack: _kgPerSackWeight,
                    ),
                  ),
                  icon: CustomIconWidget(
                    iconName: 'file_download',
                    color: AppTheme.onSecondaryLight,
                    size: 20,
                  ),
                  label: Text(
                    AppLocalizations.of(context)!.export,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.onSecondaryLight,
                    ),
                  ),
                  backgroundColor:
                      isDark ? AppTheme.secondaryDark : AppTheme.secondaryLight,
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ----------------------------- Subcomponentes -------------------------------

  Widget _buildAppBar(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          // Usa um PNG transparente (sem caixa)
          Image.asset(
            'assets/images/logo_effatha.png',
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              'Effatha Agro Simulator',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    color: Colors.black54,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/settings-screen'),
            icon: const Icon(Icons.settings, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        tabs: const [
          Tab(text: 'Dashboard'),
        //  Tab(text: 'Settings'),
        //  Tab(text: 'Profile'),
          Tab(text: 'Settings'),
          Tab(text: 'Profile'),
        ],
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
      ),
    );
  }

  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 400));
        _calculateResults();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CropSelectorWidget(
              selectedCrop: _selectedCrop,
              onCropChanged: (crop) {
                setState(() => _selectedCrop = crop);
              },
            ),
            SizedBox(height: 3.h),

            Text(
              AppLocalizations.of(context)!.comparisonOverview,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
            ),
            SizedBox(height: 2.h),

            Row(
              children: [
                Expanded(
                  child: ComparisonCardWidget(
                    title: AppLocalizations.of(context)!.traditionalFarming,
                    value: _traditionalResults['profitabilityPercent'] ?? '0%',
                    subtitle:
                        AppLocalizations.of(context)!.currentProfitability,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ComparisonCardWidget(
                    title: AppLocalizations.of(context)!.comEffatha,
                    value: _effathaResults['profitabilityPercent'] ?? '0%',
                    subtitle:
                        AppLocalizations.of(context)!.enhancedProfitability,
                    isEffatha: false,
                    accentColor: AppTheme.successLight,
                  ),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            Text(
              AppLocalizations.of(context)!.inputParameters,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: const [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
            ),
            SizedBox(height: 2.h),

            // ---- Entradas ----
            InputCardWidget(
              title: AppLocalizations.of(context)!.area,
              value: _area,
              unit: _areaUnit,
              units: const ['hectares', 'acres'],
              onUnitChanged: (u) {
                setState(() => _areaUnit = u);
                _calculateResults();
              },
              hintText: AppLocalizations.of(context)!.enterArea,
              onChanged: (value) {
                setState(() => _area = value);
                _calculateResults();
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            SizedBox(height: 2.h),

            InputCardWidget(
              title: AppLocalizations.of(context)!.historicalProductivity,
              value: _historicalProductivity,
              unit: _productivityUnit,
              units: const ['sc/ha', 'sc/acre', 't/ha', 'kg/ha'],
              onUnitChanged: (u) {
                setState(() => _productivityUnit = u);
                _calculateResults();
              },
              hintText: AppLocalizations.of(context)!.enterProductivity,
              onChanged: (value) {
                setState(() => _historicalProductivity = value);
                _calculateResults();
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            SizedBox(height: 2.h),

            InputCardWidget(
              title: AppLocalizations.of(context)!.historicalCosts,
              value: _historicalCosts,
              unit: _costUnit,
              units: const [r'$/ha', r'$/acre', 'sc/ha', 'sc/acre'],
              onUnitChanged: (u) {
                setState(() => _costUnit = u);
                _calculateResults();
              },
              hintText: AppLocalizations.of(context)!.enterCostsPerArea,
              onChanged: (value) {
                setState(() => _historicalCosts = value);
                _calculateResults();
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            SizedBox(height: 2.h),

            InputCardWidget(
              title: AppLocalizations.of(context)!.cropPrice,
              value: _cropPrice,
              unit: _priceUnit,
              units: const [r'$/sack', r'$/kg', r'$/t'],
              onUnitChanged: (u) {
                setState(() => _priceUnit = u);
                _calculateResults();
              },
              hintText: AppLocalizations.of(context)!.enterPrice,
              onChanged: (value) {
                setState(() => _cropPrice = value);
                _calculateResults();
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            SizedBox(height: 2.h),

            InputCardWidget(
              title: AppLocalizations.of(context)!.effathaInvestmentCost,
              value: _effathaInvestment,
              unit: _investmentUnit,
              units: const [r'$/ha', r'$/acre', 'sc/ha', 'sc/acre'],
              onUnitChanged: (u) {
                setState(() => _investmentUnit = u);
                _calculateResults();
              },
              hintText: AppLocalizations.of(context)!.enterInvestmentPerArea,
              onChanged: (value) {
                setState(() => _effathaInvestment = value);
                _calculateResults();
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            SizedBox(height: 2.h),

            InputCardWidget(
              title: AppLocalizations.of(context)!.additionalProductivity,
              value: _additionalProductivity,
              unit: _additionalProductivityUnit,
              units: const ['sc/ha', 'sc/acre', 't/ha', 'kg/ha'],
              onUnitChanged: (u) {
                setState(() => _additionalProductivityUnit = u);
                _calculateResults();
              },
              hintText:
                  AppLocalizations.of(context)!.enterAdditionalProductivity,
              onChanged: (value) {
                setState(() => _additionalProductivity = value);
                _calculateResults();
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),

            SizedBox(height: 3.h),

            // ----------------- CARD BRANCO: Resultados -----------------
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: ResultsSummaryWidget(
                traditionalResults: _traditionalResults,
                effathaResults: _effathaResults,
              ),
            ),

            SizedBox(height: 3.h),

            // ----------------- CARD BRANCO: ROI Progress -----------------
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: ProgressIndicatorWidget(
                title: AppLocalizations.of(context)!.roiProgress,
                value: double.tryParse(
                        (_effathaResults['roi'] as String? ?? '0')
                            .replaceAll('%', '')) ??
                    0,
                maxValue: 100,
                displayValue: _effathaResults['roi'] ?? '0%',
                progressColor: AppTheme.successLight,
              ),
            ),

            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.applicationSettings,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              shadows: const [
                Shadow(
                  color: Colors.black54,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mantemos apenas unidade de área (moedas fora do escopo)
                Text(
                  AppLocalizations.of(context)!.areaUnit,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                DropdownButtonFormField<String>(
                  value: _areaUnit,
                  onChanged: (value) {
                    setState(() => _areaUnit = value ?? 'hectares');
                  },
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.areaUnit,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(
                        value: 'hectares',
                        child: Text(AppLocalizations.of(context)!.hectares)),
                    DropdownMenuItem(
                        value: 'acres',
                        child: Text(AppLocalizations.of(context)!.acres)),
                  ],
                ),
                SizedBox(height: 3.h),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/settings-screen'),
                  child: Text(AppLocalizations.of(context)!.advancedSettings),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.userProfile,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              shadows: const [
                Shadow(
                  color: Colors.black54,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primaryLight,
                  child: const Icon(Icons.person, color: Colors.white, size: 50),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Agricultural Professional',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'user@effatha.com',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondaryLight,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.analytics,
                      color: AppTheme.primaryLight, size: 24),
                  title: Text(AppLocalizations.of(context)!.simulationsRun),
                  trailing: const Text('24'),
                ),
                ListTile(
                  leading: Icon(Icons.trending_up,
                      color: AppTheme.successLight, size: 24),
                  title: Text(AppLocalizations.of(context)!.averageROI),
                  trailing: const Text('18.5%'),
                ),
                ListTile(
                  leading: Icon(Icons.agriculture,
                      color: AppTheme.primaryLight, size: 24),
                  title: Text(AppLocalizations.of(context)!.preferredCrop),
                  trailing: Text(_selectedCrop.toUpperCase()),
                ),
                SizedBox(height: 2.h),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/login-screen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorLight,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(AppLocalizations.of(context)!.logout),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
