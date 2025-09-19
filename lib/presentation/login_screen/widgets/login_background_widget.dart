import 'package:flutter/material.dart';

class LoginBackgroundWidget extends StatelessWidget {
  final Widget child;

  const LoginBackgroundWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Fallback SEM assets para evitar tela branca por erro de imagem
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1217), Color(0xFF12202A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}
