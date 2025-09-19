import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class LoginHeaderWidget extends StatelessWidget {
  const LoginHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder sem carregar logo para isolar crash de asset
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Effatha Agro Simulator',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          SizedBox(height: 0.8.h),
          Text(
            'Faça login para continuar',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }
}
