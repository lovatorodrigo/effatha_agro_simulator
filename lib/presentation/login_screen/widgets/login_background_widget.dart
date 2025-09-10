import 'package:flutter/material.dart';
import '../../../../widgets/app_background.dart';

class LoginBackgroundWidget extends StatelessWidget {
  final Widget child;

  const LoginBackgroundWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      assetPath: 'assets/images/bg_sim_soy.jpg',
      child: SafeArea(child: child),
    );
  }
}
