// lib/presentation/consent_screen/consent_screen.dart
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../theme/app_theme.dart';
import '../../widgets/effatha_logo_widget.dart';
import '../../widgets/soy_background_widget.dart';
import 'terms_of_use_screen.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SoyBackgroundWidget(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const EffathaLogoWidget.large(heroTag: 'effatha-logo'),
                SizedBox(height: 4.h),
                Text(
                  'Termos de Uso',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.surfaceLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 1.5.h),
                Container(
                  width: double.infinity,
                  constraints: BoxConstraints(maxWidth: 720),
                  padding: EdgeInsets.all(2.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Ao continuar, você declara que leu e concorda com os termos de uso do simulador de rentabilidade agrícola. '
                    'O acesso ao dashboard dispensa cadastro e identificação pessoal nesta versão.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.surfaceLight.withOpacity(0.95),
                      height: 1.35,
                    ),
                  ),
                ),
                SizedBox(height: 1.2.h),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TermsOfUseScreen()),
                  ),
                  child: const Text('Ver Termos de Uso'),
                ),
                SizedBox(height: 2.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _accepted,
                      onChanged: (v) => setState(() => _accepted = v ?? false),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _accepted = !_accepted),
                      child: Text(
                        'Li e concordo com os termos de uso.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.surfaceLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.5.h),
                SizedBox(
                  width: 260,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _accepted
                        ? () => Navigator.pushReplacementNamed(
                            context, '/simulation-dashboard')
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Entrar no Dashboard'),
                    style: ElevatedButton.styleFrom(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
