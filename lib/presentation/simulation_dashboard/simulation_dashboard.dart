import 'package:effatha_agro_simulator/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import '../export_results_screen/export_results_screen.dart';
import './widgets/comparison_card_widget.dart';
import './widgets/crop_selector_widget.dart';
import './widgets/input_card_widget.dart';

class SimulationDashboard extends StatefulWidget {
  SimulationDashboard({super.key});

  @override
  State<SimulationDashboard> createState() => _SimulationDashboardState();
}

class _SimulationDashboardState extends State<SimulationDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Form data (default 0)
  String _selectedCrop = 'soy';
  String _area = '';
  String _historicalProductivity = '';
  String _historicalCosts = '';
  String _cropPrice = '';
  String _effathaInvestment = '';
  String _additionalProductivity = '';

  // Settings
  String _currency = 'USD';
  double _kgPerSackWeight = 60.0;
  String _priceUnit = r'$/sc';
  String _areaUnit = 'hectares';
  String _productivityUnit = 'sc/ha';

  // Per-parameter units
  String _costUnit = r'$/ha';
  String _investmentUnit = r'$/ha';
  String _additionalProductivityUnit = 'sc/ha';

  // Results
  Map<String, dynamic> _traditionalResults = {};
  Map<String, dynamic> _effathaResults = {};

  // Backgrounds por cultura
  final Map<String, String> _cropBackgrounds = {
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
    _loadKgPerSack();
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _calculateResults();
  }

  Future<void> _loadKgPerSack() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final k = prefs.getDouble('kg_per_sack_weight');
      if (k != null && k > 0) {
        setState(() {
          _kgPerSackWeight = k;
        });
      }
    } catch (_) {}
  }

  // Helpers de formatação
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
        final sacks = _kgPerSackWeight > 0 ? (totalKg / _kgPerSackWeight) : 0;
        return '${sacks.toStringAsFixed(0)} sacas';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Cálculos
  void _calculateResults() {
    final double area = double.tryParse(_area) ?? 0.0;
    final double productivity =
        double.tryParse(_historicalProductivity) ?? 0.0;
    final double costs = double.tryParse(_historicalCosts) ?? 0.0;
    final double price = double.tryParse(_cropPrice) ?? 0.0;
    final double investment = double.tryParse(_effathaInvestment) ?? 0.0;
    final double additionalProd =
        double.tryParse(_additionalProductivity) ?? 0.0;

    const double acresPerHectare = 2.47105;

    // Área em ha
    final double areaHa =
        _areaUnit == 'acres' ? (area / acresPerHectare) : area;

    // Preço por kg
    double pricePerKg;
    switch (_priceUnit) {
      case r'$/kg':
        pricePerKg = price;
        break;
      case r'$/t':
        pricePerKg = price / 1000.0;
        break;
      case r'$/sc': // saca
      default:
        pricePerKg =
            _kgPerSackWeight > 0 ? (price / _kgPerSackWeight) : 0.0;
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

    // percentual do LUCRO adicional (modelo antigo)
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
        'roi': _fmtPercent(traditionalProfitability),
        'profit': traditionalProfit,
        'revenue': traditionalRevenue,
        '_productionKg': traditionalProductionKg,
        '_totalCosts': traditionalTotalCosts,
        '_profitabilityRaw': traditionalProfitability,
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
        '_productionKg': effathaProductionKg,
        '_totalCosts': effathaTotalCosts,
        '_profitabilityRaw': effathaProfitability,
      };
    });
  }

  // UI
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                _buildAppBar(theme, isDark),
                _buildTabBar(theme, isDark),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildDashboardTab(),
                      _buildSettingsTab(),
                     
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(
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
                );
              },
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
            )
          : null,
    );
  }

  Widget _buildAppBar(ThemeData theme, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          CustomImageWidget(
            imageUrl: 'assets/images/logo_effatha.png',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
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
            icon: const CustomIconWidget(
              iconName: 'settings',
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Dashboard'),
          Tab(text: 'Settings'),
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
        await Future.delayed(const Duration(seconds: 1));
        _calculateResults();
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CropSelectorWidget(
              selectedCrop: _selectedCrop,
              onCropChanged: (crop) {
                setState(() {
                  _selectedCrop = crop;
                });
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
                    value:
                        _traditionalResults['profitabilityPercent'] ?? '0%',
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

            // ---------- Inputs ----------
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
              hintText: AppLocalizations.of(context)!.enterCostsPerArea,
              onChanged: (value) {
                setState(() => _historicalCosts = value);
                _calculateResults();
              },
              units: const [r'$/ha', r'$/acre', 'sc/ha', 'sc/acre'],
              onUnitChanged: (u) {
                setState(() => _costUnit = u);
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
              hintText: AppLocalizations.of(context)!.enterPrice,
              onChanged: (value) {
                setState(() => _cropPrice = value);
                _calculateResults();
              },
              units: const [r'$/sc', r'$/kg', r'$/t'],
              onUnitChanged: (u) {
                setState(() => _priceUnit = u);
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
              hintText:
                  AppLocalizations.of(context)!.enterInvestmentPerArea,
              onChanged: (value) {
                setState(() => _effathaInvestment = value);
                _calculateResults();
              },
              units: const [r'$/ha', r'$/acre', 'sc/ha', 'sc/acre'],
              onUnitChanged: (u) {
                setState(() => _investmentUnit = u);
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
              hintText: AppLocalizations.of(context)!
                  .enterAdditionalProductivity,
              onChanged: (value) {
                setState(() => _additionalProductivity = value);
                _calculateResults();
              },
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),

            SizedBox(height: 3.h),

            // ---------- CARD BRANCO: Resultados + Rentabilidade ----------
            _buildResultsWhiteCard(context),

            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  // Card branco com os campos do novo modelo + seção "Rentabilidade"
  Widget _buildResultsWhiteCard(BuildContext context) {
    final double tProfit = (_traditionalResults['profit'] as double?) ?? 0.0;
    final double eProfit = (_effathaResults['profit'] as double?) ?? 0.0;

    final double tProdKg =
        (_traditionalResults['_productionKg'] as double?) ?? 0;
    final double eProdKg =
        (_effathaResults['_productionKg'] as double?) ?? 0;

    final double tCosts =
        (_traditionalResults['_totalCosts'] as double?) ?? 0;
    final double eCosts =
        (_effathaResults['_totalCosts'] as double?) ?? 0;

    final double tPerc =
        (_traditionalResults['_profitabilityRaw'] as double?) ?? 0.0;
    final double ePerc =
        (_effathaResults['_profitabilityRaw'] as double?) ?? 0.0;

    // Diferença em R$ (Effatha - Padrão)
    final double diffProfitMoney = eProfit - tProfit;

    // Lucro adicional (%) — modelo antigo
    final double additionalProfitPercent =
        tProfit.abs() > 0 ? ((eProfit - tProfit) / tProfit) * 100.0 : 0.0;

    String prodToSc(double kg) {
      final sc = _kgPerSackWeight > 0 ? kg / _kgPerSackWeight : 0.0;
      return '${NumberFormat.decimalPattern('pt_BR').format(sc.round())} sc';
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título atualizado
          Text(
            'Resultados',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 1.h),
          _doubleRow(
            context,
            label: 'Investimento Total',
            left: _fmtMoney(tCosts),
            right: _fmtMoney(eCosts),
          ),
          _doubleRow(
            context,
            label: 'Produção Total',
            left: prodToSc(tProdKg),
            right: prodToSc(eProdKg),
          ),
          _doubleRow(
            context,
            label: 'Rentabilidade Total (R\$)',
            left: _fmtMoney(tProfit),
            right: _fmtMoney(eProfit),
          ),
          _doubleRow(
            context,
            label: 'Rentabilidade Total (%)',
            left: _traditionalResults['profitabilityPercent'] ?? '0%',
            right: _effathaResults['profitabilityPercent'] ?? '0%',
          ),
          SizedBox(height: 2.0.h),

          // Seção de destaque: Rentabilidade
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.5.w),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2ecc71), Color(0xFF27ae60)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rentabilidade',
                  style:
                      Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                ),
                SizedBox(height: 0.8.h),
                Row(
                  children: [
                    Expanded(
                      child: _highlightTile(
                        context,
                        title: 'Diferença (\$)',
                        value: _fmtMoney(diffProfitMoney),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: _highlightTile(
                        context,
                        title: 'Lucro adicional (%)',
                        value: _fmtPercent(
                            additionalProfitPercent,
                            decimals: 2),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _highlightTile(BuildContext context,
      {required String title, required String value}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 1.2.h, horizontal: 3.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(
                    color: Colors.white70, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }

  Widget _doubleRow(BuildContext context,
      {required String label, required String left, required String right}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.1.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label (Padrão Fazenda)',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppTheme.textSecondaryLight),
                ),
                const SizedBox(height: 4),
                Text(left, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$label (Effatha)',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppTheme.textSecondaryLight),
                ),
                const SizedBox(height: 4),
                Text(right, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Settings e Profile (mantidos)
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
                    setState(() {
                      _areaUnit = value ?? 'hectares';
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
                      child:
                          Text(AppLocalizations.of(context)!.squareMeters),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/settings-screen'),
                  child:
                      Text(AppLocalizations.of(context)!.advancedSettings),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}
