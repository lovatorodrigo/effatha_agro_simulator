import 'package:flutter/material.dart';

/// Fundo padrão para a tela de login, com imagem (soja) e overlay em gradiente
/// para manter legibilidade do conteúdo.
class LoginBackgroundWidget extends StatelessWidget {
  final Widget child;

  /// Opcional: trocar a imagem de fundo se desejar.
  final String imageAsset;

  /// Intensidade do escurecimento (0 = sem overlay, 1 = opaco).
  final double overlayOpacity;

  const LoginBackgroundWidget({
    super.key,
    required this.child,
    this.imageAsset = 'assets/images/bg_sim_soy.jpg',
    this.overlayOpacity = 0.65,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imageAsset),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(overlayOpacity * 0.9),
              Colors.black.withOpacity(overlayOpacity * 0.25),
              Colors.black.withOpacity(overlayOpacity),
            ],
            stops: const [0.0, 0.40, 1.0],
          ),
        ),
        child: SafeArea(child: child),
      ),
    );
  }
}
