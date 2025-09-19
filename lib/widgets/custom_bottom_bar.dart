import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

enum CustomBottomBarVariant {
  standard,
  floating,
  minimal,
}

/// Custom BottomNavigationBar widget optimized for agricultural profitability applications
/// Designed for one-handed operation with larger touch targets for outdoor use
class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final CustomBottomBarVariant variant;
  final double? elevation;
  final Color? backgroundColor;
  final bool showLabels;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.variant = CustomBottomBarVariant.standard,
    this.elevation,
    this.backgroundColor,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (variant) {
      case CustomBottomBarVariant.floating:
        return _buildFloatingBottomBar(context, theme, isDark);
      case CustomBottomBarVariant.minimal:
        return _buildMinimalBottomBar(context, theme, isDark);
      case CustomBottomBarVariant.standard:
      default:
        return _buildStandardBottomBar(context, theme, isDark);
    }
  }

  Widget _buildStandardBottomBar(
      BuildContext context, ThemeData theme, bool isDark) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        HapticFeedback.lightImpact(); // Haptic feedback for outdoor use
        _handleNavigation(context, index);
        onTap(index);
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: backgroundColor ??
          (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight),
      selectedItemColor: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
      unselectedItemColor:
          isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
      elevation: elevation ?? 8.0,
      showSelectedLabels: showLabels,
      showUnselectedLabels: showLabels,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      iconSize: 28.0, // Larger icons for better outdoor visibility
      items: _getBottomNavItems(),
    );
  }

  Widget _buildFloatingBottomBar(
      BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: (backgroundColor ??
                (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight))
            .withOpacity(0.95),
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: (isDark ? AppTheme.shadowDark : AppTheme.shadowLight)
                .withOpacity(0.2),
            blurRadius: 12.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.0),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            HapticFeedback.lightImpact();
            _handleNavigation(context, index);
            onTap(index);
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor:
              isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
          unselectedItemColor:
              isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
          elevation: 0,
          showSelectedLabels: showLabels,
          showUnselectedLabels: showLabels,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 28.0,
          items: _getBottomNavItems(),
        ),
      ),
    );
  }

  Widget _buildMinimalBottomBar(
      BuildContext context, ThemeData theme, bool isDark) {
    return Container(
      height: 60.0,
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight),
        border: Border(
          top: BorderSide(
            color: (isDark ? AppTheme.dividerDark : AppTheme.dividerLight)
                .withOpacity(0.2),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _getBottomNavItems().asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isSelected = index == currentIndex;

          return Expanded(
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                _handleNavigation(context, index);
                onTap(index);
              },
              child: Container(
                height: 60.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 24.0,
                      color: isSelected
                          ? (isDark
                              ? AppTheme.primaryDark
                              : AppTheme.primaryLight)
                          : (isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight),
                    ),
                    if (showLabels && item.label != null) ...[
                      SizedBox(height: 4.0),
                      Text(
                        item.label!,
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? (isDark
                                  ? AppTheme.primaryDark
                                  : AppTheme.primaryLight)
                              : (isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight),
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  List<BottomNavigationBarItem> _getBottomNavItems() {
    return [
      const BottomNavigationBarItem(
        icon: Icon(Icons.dashboard),
        activeIcon: Icon(Icons.dashboard),
        label: 'Dashboard',
        tooltip: 'Simulation Dashboard',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.calculate),
        activeIcon: Icon(Icons.calculate),
        label: 'Calculate',
        tooltip: 'Profitability Calculator',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.file_download),
        activeIcon: Icon(Icons.file_download),
        label: 'Export',
        tooltip: 'Export Results',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.settings),
        activeIcon: Icon(Icons.settings),
        label: 'Settings',
        tooltip: 'Application Settings',
      ),
    ];
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/simulation-dashboard');
        break;
      case 1:
        Navigator.pushNamed(context, '/simulation-dashboard');
        break;
      case 2:
        Navigator.pushNamed(context, '/export-results-screen');
        break;
      case 3:
        Navigator.pushNamed(context, '/settings-screen');
        break;
    }
  }
}
