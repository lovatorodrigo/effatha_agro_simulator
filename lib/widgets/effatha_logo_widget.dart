import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Effatha Logo Widget
/// Displays the official Effatha logo with consistent styling across the app
class EffathaLogoWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final bool showContainer;
  final bool showShadow;
  final String? heroTag;

  const EffathaLogoWidget({
    super.key,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(8.0),
    this.showContainer = false,
    this.showShadow = false,
    this.heroTag,
  });

  /// Small logo variant for AppBar
  const EffathaLogoWidget.small({
    super.key,
    this.heroTag,
  })  : width = 32,
        height = 32,
        padding = const EdgeInsets.all(4.0),
        showContainer = false,
        showShadow = false;

  /// Medium logo variant for headers
  const EffathaLogoWidget.medium({
    super.key,
    this.heroTag,
  })  : width = null,
        height = null,
        padding = const EdgeInsets.all(12.0),
        showContainer = false,
        showShadow = false;

  /// Large logo variant for splash/welcome screens
  const EffathaLogoWidget.large({
    super.key,
    this.heroTag,
  })  : width = null,
        height = null,
        padding = const EdgeInsets.all(20.0),
        showContainer = false,
        showShadow = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Medium vs Large inferred by padding (>= 40 → large)
    final bool isLarge =
        (padding.horizontal >= 40.0) || (padding.vertical >= 40.0);

    // Base responsive size using Sizer
    final double baseSizeW = isLarge ? 28.w : 20.w;
    final double maxSize = isLarge ? 220.0 : 120.0;
    final double targetSize = baseSizeW > maxSize ? maxSize : baseSizeW;

    final double logoWidth = width ?? (showContainer ? targetSize : 24.0);
    final double logoHeight = height ?? (showContainer ? targetSize : 24.0);

    // Single asset path (ajuste o nome se necessário)
    final String assetPath = 'assets/images/logo_effatha_official.svg';

    Widget logoImage = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: logoWidth,
        maxHeight: logoHeight,
        minWidth: showContainer ? 60 : 20,
        minHeight: showContainer ? 60 : 20,
      ),
      child: assetPath.toLowerCase().endsWith('.svg')
          ? SvgPicture.asset(
              assetPath,
              width: logoWidth,
              height: logoHeight,
              fit: BoxFit.contain,
            )
          : Image.asset(
              assetPath,
        width: logoWidth,
        height: logoHeight,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.agriculture,
            size: logoWidth,
            color: theme.primaryColor,
          );
        },
      ),
    );

    // Hero animation (opcional)
    if (heroTag != null) {
      logoImage = Hero(
        tag: heroTag!,
        child: logoImage,
      );
    }

    // Padding externo
    logoImage = Padding(
      padding: padding,
      child: logoImage,
    );

    // Container decorado (opcional)
    if (showContainer) {
      logoImage = Container(
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.95)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8.0,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
          border: isDark
              ? Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 1,
                )
              : null,
        ),
        child: logoImage,
      );
    }

    return logoImage;
  }
}
