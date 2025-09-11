import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../../core/app_export.dart';
import './widgets/comparison_card_widget.dart';
import './widgets/crop_selector_widget.dart';
import './widgets/input_card_widget.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/results_summary_widget.dart';

class SimulationDashboard extends StatefulWidget {
  SimulationDashboard({super.key});

  @override
  State<SimulationDashboard> createState() => _SimulationDashboardState();
}

class _SimulationDashboardState extends State<SimulationDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Form data (strings da UI)
  String _selectedCrop = 'soy';
  String _area = '100';
  String _historicalProductivity = '60';
  String _historicalCosts = '5000';
  String _cropPrice = '80';
  String _effathaInvestment = '500';
  String _additionalProductivity = '15';

  // Settings
  String _currency = 'USD'; // mantido, mas formatamos sempre como $ no _fmtMoney
  double _kgPerSackWeight = 60.0; // peso padrão da saca
  String _priceUnit = r'$/sack';
  String _areaUnit = 'hectares';
  String _productivityUnit = 'sacks/ha';
  double _exchangeRate = 1.0; // ignorado nos cálculos (apenas $), mantido p/ futuro

  // Per-parameter units (configuráveis)
  String _costUnit = r'$/ha';
  String _investmentUnit = r'$/ha';
  String _additionalProductivityUnit = 'sacks/ha';

  // Results
  Map<String, dynamic> _traditionalResults = {};
  Map<String, dynamic> _effathaResults = {};

  // Imagens de fundo por cultura
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

  // Formatações: $ com pt_BR e % com vírgula
  String _fmtMoney(double value) {
    final f = NumberFormat.currency(locale: 'pt_BR', symbol: r'$ ', decimalDigits: 2);
    return f.format(value);
  }

  String _fmtPercent(double value, {int decimals = 1}) {
    final rounded = double.parse(value.toStringAsFixed(decimals));
    return '${NumberFormat.decimalPattern('pt_BR').format(rounded)}%';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatTotalProduction(double totalKg) {
    switch (_productivityUnit) {
      case 'kg/ha':
        return '${totalKg.toStringAsFixed(0)} kg';
      case 't/ha':
        return '${(totalKg / 1000.0).toStringAsFixed(2)} t';
      case 'sacks/ha':
      case 'sacks/acre':
      default:
        final sacks = totalKg / _kgPerSackWeight;
        return '${sacks.toStringAsFixed(0)} sacks';
    }
  }

  void _calculateResults() {
    // Leitura segura dos campos numéricos
    final areaInput = double.tryParse(_area.replaceAll(',', '.')) ?? 0.0;
    final prodInput = double.tryParse(_historicalProductivity.replaceAll(',', '.')) ?? 0.0;
    final costsInput = double.tryParse(_historicalCosts.replaceAll(',', '.')) ?? 0.0;
    final priceInput = double.tryParse(_cropPrice.replaceAll(',', '.')) ?? 0.0;
    final investInput = double.tryParse(_effathaInvestment.replaceAll(',', '.')) ?? 0.0;
    final addProdInput = double.tryParse(_additionalProductivity.replaceAll(',', '.')) ?? 0.0;

    // Converte para base: ha, kg/ha e $/ha
    const double acresPerHectare = 2.47105;

    // Área em ha
    final double areaHa = _areaUnit == 'acres' ? (areaInput / acresPerHectare) : areaInput;

    // Preço por kg
    double pricePerKg;
    switch (_priceUnit) {
      case r'$/kg':
        pricePerKg = priceInput;
        break;
      case r'$/t':
        pricePerKg = priceInput / 1000.0;
        break;
      case r'$/sack':
      default:
        pricePerKg = _kgPerSackWeight > 0 ? priceInput / _kgPerSackWeight : 0.0;
        break;
    }

    // Conversores
    double toKgPerHa(double value, String unit) {
      switch (unit) {
        case 'kg/ha':
          return value;
        case 't/ha':
          return value * 1000.0;
        case 'sacks/ha':
          return value * _kgPerSackWeight;
        case 'sacks/acre':
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
        case 'sacks/ha':
          return value * _kgPerSackWeight * pricePerKg;
        case 'sacks/acre':
          return value * acresPerHectare * _kgPerSackWeight * pricePerKg;
        default:
          return value;
      }
    }

    // Valores em base
    final double productivityKgPerHa = toKgPerHa(prodInput, _productivityUnit);
    final double additionalProdKgPerHa = toKgPerHa(addProdInput, _additionalProductivityUnit);
    final double costsPerHa = toDollarsPerHa(costsInput, _costUnit);
    final double investmentPerHa = toDollarsPerHa(investInput, _investmentUnit);

    // Cálculos tradicionais
    final double traditionalProductionKg = areaHa * productivityKgPerHa;
    final double traditionalRevenue = traditionalProductionKg * pricePerKg;
    final double traditionalTotalCosts = areaHa * costsPerHa;
    final double traditionalProfit = traditionalRevenue - traditionalTotalCosts;
    final double traditionalProfitability =
        traditionalTotalCosts > 0 ? (traditionalProfit / traditionalTotalCosts) * 100 : 0.0;

    // Cálculos Effatha
    final double effathaProductionKg = areaHa * (productivityKgPerHa + additionalProdKgPerHa);
    final double effathaRevenue = effathaProductionKg * pricePerKg;
    final double effathaInvestmentTotal = areaHa * investmentPerHa;
    final double effathaTotalCosts = areaHa * (costsPerHa + investmentPerHa);
    final double effathaProfit = effathaRevenue - effathaTotalCosts;
    final double effathaProfitability =
        effathaTotalCosts > 0 ? (effathaProfit / effathaTotalCosts) * 100 : 0.0;

    // Adicionais
    final double additionalProfit = effathaProfit - traditionalProfit;
    final double additionalProfitPercent =
        traditionalProfit.abs() > 0 ? (additionalProfit / traditionalProfit) * 100 : 0.0;
    final double roi =
        effathaInvestmentTotal > 0 ? (additionalProfit / effathaInvestmentTotal) * 100 : 0.0;

    setState(() {
      _traditionalResults = {
        'investmentTotal': _fmtMoney(traditionalTotalCosts),
        'productionTotal': _formatTotalProduction(traditionalProductionKg),
        'profitabilityPercent': _fmtPercent(traditionalProfitability),
        // ROI tradicional ≈ rentabilidade tradicional
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
                      _buildProfileTab(),
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
              onPressed: () => Navigator.pushNamed(context, '/export-results-screen'),
              icon: CustomIconWidget(
                iconName: 'file_download',
                color: AppTheme.onSecondaryLight,
                size: 20,
              ),
              label: Text(
                'Export',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.onSecondaryLight,
                ),
              ),
              backgroundColor: isDark ? AppTheme.secondaryDark : AppTheme.secondaryLight,
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
            imageUrl: 'https://via.placeholder.com/40x40/4CAF50/FFFFFF?text=E',
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
                shadows: [
                  const Shadow(
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
            icon: CustomIconWidget(
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
        await Future.delayed(const Duration(seconds: 1));
        _calculateResults();
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        physics: const AlwaysScrollableScrollPhysics(),
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
              'Comparison Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      const Shadow(
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
                ComparisonCardWidget(
                  title: 'Traditional Farming',
                  value: _traditionalResults['profitabilityPercent'] ?? '0%',
                  subtitle: 'Current profitability',
                ),
                SizedBox(width: 3.w),
                ComparisonCardWidget(
                  title: 'With Effatha Technology',
                  value: _effathaResults['profitabilityPercent'] ?? '0%',
                  subtitle: 'Enhanced profitability',
                  isEffatha: true,
                  accentColor: AppTheme.successLight,
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Text(
              'Input Parameters',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    shadows: [
                      const Shadow(
                        color: Colors.black54,
                        offset: Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
            ),
            SizedBox(height: 2.h),

            // AREA
            InputCardWidget(
              title: 'Area',
              value: _area,
              unit: _areaUnit,
              units: const ['hectares', 'acres'],
              onUnitChanged: (u) {
                setState(() {
                  _areaUnit = u;
                });
                _calculateResults();
              },
              hintText: 'Enter area',
              onChanged: (value) {
                setState(() {
                  _area = value;
                });
                _calculateResults();
              },
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            SizedBox(height: 2.h),

            // HISTORICAL PRODUCTIVITY
            InputCardWidget(
              title: 'Historical Productivity',
              value: _historicalProductivity,
              unit: _productivityUnit,
              units: const ['sacks/ha', 'sacks/acre', 't/ha', 'kg/ha'],
              onUnitChanged: (u) {
                setState(() {
                  _productivityUnit = u;
                });
                _calculateResults();
              },
              hintText: 'Enter productivity',
              onChanged: (value) {
                setState(() {
                  _historicalProductivity = value;
                });
                _calculateResults();
              },
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            SizedBox(height: 2.h),

            // HISTORICAL COSTS
            InputCardWidget(
              title: 'Historical Costs',
              value: _historicalCosts,
              unit: _costUnit,
              units: const [r'$/ha', r'$/acre', 'sacks/ha', 'sacks/acre'],
              onUnitChanged: (u) {
                setState(() {
                  _costUnit = u;
                });
                _calculateResults();
              },
              hintText: 'Enter costs per area',
              onChanged: (value) {
                setState(() {
                  _historicalCosts = value;
                });
                _calculateResults();
              },
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            SizedBox(height: 2.h),

            // CROP PRICE
            InputCardWidget(
              title: 'Crop Price',
              value: _cropPrice,
              unit: _priceUnit,
              units: const [r'$/sack', r'$/kg', r'$/t'],
              onUnitChanged: (u) {
                setState(() {
                  _priceUnit = u;
                });
                _calculateResults();
              },
              hintText: 'Enter price',
              onChanged: (value) {
                setState(() {
                  _cropPrice = value;
                });
                _calculateResults();
              },
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            SizedBox(height: 2.h),

            // EFFATHA INVESTMENT
            InputCardWidget(
              title: 'Effatha Investment Cost',
              value: _effathaInvestment,
              unit: _investmentUnit,
              units: const [r'$/ha', r'$/acre', 'sacks/ha', 'sacks/acre'],
              onUnitChanged: (u) {
                setState(() {
                  _investmentUnit = u;
                });
                _calculateResults();
              },
              hintText: 'Enter investment per area',
              onChanged: (value) {
                setState(() {
                  _effathaInvestment = value;
                });
                _calculateResults();
              },
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
            SizedBox(height: 2.h),

            // ADDITIONAL PRODUCTIVITY
            InputCardWidget(
              title: 'Additional Productivity with Effatha',
              value: _additionalProductivity,
              unit: _additionalProductivityUnit,
              units: const ['sacks/ha', 'sacks/acre', 't/ha', 'kg/ha'],
              onUnitChanged: (u) {
                setState(() {
                  _additionalProductivityUnit = u;
                });
                _calculateResults();
              },
              hintText: 'Enter additional productivity',
              onChanged: (value) {
                setState(() {
                  _additionalProductivity = value;
                });
                _calculateResults();
              },
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),

            SizedBox(height: 3.h),
            ResultsSummaryWidget(
              traditionalResults: _traditionalResults,
              effathaResults: _effathaResults,
            ),
            SizedBox(height: 3.h),
            ProgressIndicatorWidget(
              title: 'ROI Progress',
              value: double.tryParse(
                      _effathaResults['roi']?.replaceAll('%', '') ?? '0') ??
                  0,
              maxValue: 100,
              displayValue: _effathaResults['roi'] ?? '0%',
              progressColor: AppTheme.successLight,
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application Settings',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              shadows: [
                const Shadow(
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
                  'Currency Settings',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                DropdownButtonFormField<String>(
                  value: _currency,
                  onChanged: (value) {
                    setState(() {
                      _currency = value ?? 'USD';
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Currency',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'USD', child: Text('USD - US Dollar')),
                    DropdownMenuItem(value: 'BRL', child: Text('BRL - Brazilian Real')),
                    DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro')),
                    DropdownMenuItem(value: 'GBP', child: Text('GBP - British Pound')),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  'Area Unit Settings',
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
                  decoration: const InputDecoration(
                    labelText: 'Area Unit',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'hectares', child: Text('Hectares')),
                    DropdownMenuItem(value: 'acres', child: Text('Acres')),
                    DropdownMenuItem(value: 'm²', child: Text('Square Meters')),
                  ],
                ),
                SizedBox(height: 3.h),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/settings-screen'),
                  child: const Text('Advanced Settings'),
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
            'User Profile',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              shadows: [
                const Shadow(
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
                  child: CustomIconWidget(
                    iconName: 'person',
                    color: Colors.white,
                    size: 50,
                  ),
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
                SizedBox(height: 3.h),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'analytics',
                    color: AppTheme.primaryLight,
                    size: 24,
                  ),
                  title: const Text('Simulations Run'),
                  trailing: const Text('24'),
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'trending_up',
                    color: AppTheme.successLight,
                    size: 24,
                  ),
                  title: const Text('Average ROI'),
                  trailing: const Text('18.5%'),
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'agriculture',
                    color: AppTheme.primaryLight,
                    size: 24,
                  ),
                  title: const Text('Preferred Crop'),
                  trailing: Text(_selectedCrop.toUpperCase()),
                ),
                SizedBox(height: 2.h),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/login-screen'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorLight,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
