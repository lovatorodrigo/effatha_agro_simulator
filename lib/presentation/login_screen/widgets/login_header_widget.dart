import 'package:effatha_agro_simulator/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/effatha_logo_widget.dart';

class LoginHeaderWidget extends StatelessWidget {
  const LoginHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 5.w),
      child: Column(
        children: [
          SizedBox(height: 4.h),

          // Effatha Logo - Updated to use actual asset
          const EffathaLogoWidget.large(
            heroTag: 'effatha-logo',
          ),

          SizedBox(height: 3.h),

          // Welcome Text
          Text(
            'Bem-vindo',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: AppTheme.surfaceLight,
              fontWeight: FontWeight.bold,
              fontSize: 28,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.8),
                  offset: const Offset(0, 2),
                  blurRadius: 4.0,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 1.h),

          // Subtitle
          Text(
            'Sign in to access your agricultural profitability simulator',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.surfaceLight.withOpacity(0.9),
              fontSize: 16,
              height: 1.4,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.8),
                  offset: const Offset(0, 1),
                  blurRadius: 2.0,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 4.h),
        ],
      ),
    );
  }
}
