import 'package:flutter/material.dart';

/// Fundo padrão com imagem + gradiente para telas do app.
/// Use:
/// AppBackground(
///   assetPath: 'assets/images/bg_sim_soy.jpg',
///   child: Scaffold(...),
/// )
class AppBackground extends StatelessWidget {
  final String assetPath;
  final Widget child;

  /// Gradiente vertical (topo → base). Troque se quiser outro estilo.
  final AlignmentGeometry begin;
  final AlignmentGeometry end;
  final List<Color> colors;
  final List<double> stops;

  const AppBackground({
    super.key,
    required this.assetPath,
    required this.child,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
    this.colors = const [
      Color(0x99000000), // topo levemente escuro
      Color(0x00000000), // meio transparente
      Color(0x99000000), // base levemente escura
    ],
    this.stops = const [0.0, 0.3, 1.0],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // imagem de fundo
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(assetPath),
          fit: BoxFit.cover,
        ),
      ),
      // overlay em gradiente
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: begin,
            end: end,
            colors: colors,
            stops: stops,
          ),
        ),
        child: child,
      ),
    );
  }
}
