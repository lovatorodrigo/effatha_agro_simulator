import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';

class LoginHeaderWidget extends StatelessWidget {
  const LoginHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(top: 6.h, left: 5.w, right: 5.w, bottom: 2.h),
      child: Column(
        children: [
          // LOGO RESPONSIVO – ocupa até ~80% da largura (máx. 520 px)
          LayoutBuilder(
            builder: (ctx, c) {
              final w = c.maxWidth;
              final target = w * 0.8;
              final logoWidth = target.clamp(240.0, 520.0);
              return Image.asset(
                'assets/images/logo_effatha.png',
                width: logoWidth,
                fit: BoxFit.contain,
              );
            },
          ),
          SizedBox(height: 2.0.h),
          Text(
            'Effatha Agro Simulator',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
              shadows: const [
                Shadow(
                  color: Colors.black45,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          SizedBox(height: 0.4.h),
          Text(
            'Faça login para continuar',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
