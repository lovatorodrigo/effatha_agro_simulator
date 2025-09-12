import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';
import './effatha_logo_widget.dart';

enum CustomAppBarVariant {
  primary,
  transparent,
  minimal,
}

/// Custom AppBar widget optimized for agricultural profitability applications
/// Provides professional credibility while maintaining outdoor visibility
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final CustomAppBarVariant variant;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final PreferredSizeWidget? bottom;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool showLogo;

  const CustomAppBar({
    super.key,
    required this.title,
    this.variant = CustomAppBarVariant.primary,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
    this.showBackButton = false,
    this.onBackPressed,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      title: _buildTitle(theme, isDark),
      leading: _buildLeading(context, theme, isDark),
      actions: _buildActions(context, theme, isDark),
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: centerTitle,
      elevation: _getElevation(),
      backgroundColor: _getBackgroundColor(theme, isDark),
      foregroundColor: _getForegroundColor(theme, isDark),
      bottom: bottom,
      systemOverlayStyle: _getSystemOverlayStyle(isDark),
      toolbarHeight: 56.0, // Standard height for one-handed operation
      titleSpacing: 16.0,
    );
  }

  Widget _buildTitle(ThemeData theme, bool isDark) {
    if (showLogo) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const EffathaLogoWidget.small(),
          SizedBox(width: 12),
          Flexible(
            child: Text(
              title,
              style: _getTitleStyle(theme, isDark),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    return Text(
      title,
      style: _getTitleStyle(theme, isDark),
    );
  }

  Widget? _buildLeading(BuildContext context, ThemeData theme, bool isDark) {
    if (leading != null) return leading;

    if (showBackButton ||
        (automaticallyImplyLeading && Navigator.canPop(context))) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
        tooltip: 'Back',
        iconSize: 24.0,
        padding: const EdgeInsets.all(16.0),
      );
    }

    return null;
  }

  List<Widget>? _buildActions(
      BuildContext context, ThemeData theme, bool isDark) {
    if (actions != null) return actions;

    // Default actions for agricultural app navigation
    return [
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () => Navigator.pushNamed(context, '/settings-screen'),
        tooltip: 'Settings',
        iconSize: 24.0,
        padding: const EdgeInsets.all(16.0),
      ),
      IconButton(
        icon: const Icon(Icons.file_download),
        onPressed: () => Navigator.pushNamed(context, '/export-results-screen'),
        tooltip: 'Export Results',
        iconSize: 24.0,
        padding: const EdgeInsets.all(16.0),
      ),
    ];
  }

  TextStyle _getTitleStyle(ThemeData theme, bool isDark) {
    final baseStyle =
        theme.appBarTheme.titleTextStyle ?? theme.textTheme.titleLarge!;

    switch (variant) {
      case CustomAppBarVariant.primary:
        return baseStyle.copyWith(
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        );
      case CustomAppBarVariant.transparent:
        return baseStyle.copyWith(
          color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
          fontWeight: FontWeight.w500,
          shadows: [
            Shadow(
              color:
                  (isDark ? Colors.black : Colors.white).withOpacity(0.8),
              offset: const Offset(0, 1),
              blurRadius: 2.0,
            ),
          ],
        );
      case CustomAppBarVariant.minimal:
        return baseStyle.copyWith(
          fontWeight: FontWeight.w400,
          fontSize: 18,
        );
    }
  }

  double _getElevation() {
    if (elevation != null) return elevation!;

    switch (variant) {
      case CustomAppBarVariant.primary:
        return 4.0;
      case CustomAppBarVariant.transparent:
        return 0.0;
      case CustomAppBarVariant.minimal:
        return 1.0;
    }
  }

  Color? _getBackgroundColor(ThemeData theme, bool isDark) {
    if (backgroundColor != null) return backgroundColor;

    switch (variant) {
      case CustomAppBarVariant.primary:
        return isDark ? AppTheme.surfaceDark : AppTheme.primaryLight;
      case CustomAppBarVariant.transparent:
        return Colors.transparent;
      case CustomAppBarVariant.minimal:
        return theme.scaffoldBackgroundColor;
    }
  }

  Color? _getForegroundColor(ThemeData theme, bool isDark) {
    if (foregroundColor != null) return foregroundColor;

    switch (variant) {
      case CustomAppBarVariant.primary:
        return isDark ? AppTheme.textPrimaryDark : AppTheme.onPrimaryLight;
      case CustomAppBarVariant.transparent:
        return isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
      case CustomAppBarVariant.minimal:
        return isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight;
    }
  }

  SystemUiOverlayStyle _getSystemOverlayStyle(bool isDark) {
    switch (variant) {
      case CustomAppBarVariant.primary:
        return isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
      case CustomAppBarVariant.transparent:
        return isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
      case CustomAppBarVariant.minimal:
        return isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(
        (bottom?.preferredSize.height ?? 0.0) + 56.0,
      );
}
