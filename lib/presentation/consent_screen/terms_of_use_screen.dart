// lib/presentation/consent_screen/terms_of_use_screen.dart
import 'package:flutter/material.dart';

class TermsOfUseScreen extends StatelessWidget {
  const TermsOfUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    TextStyle h = theme.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700);
    TextStyle b = theme.textTheme.bodyMedium!.copyWith(height: 1.45);
    return Scaffold(
      appBar: AppBar(title: const Text('Termos de Uso')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: DefaultTextStyle(
            style: b,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('1. Natureza do Aplicativo', style: h),
                const SizedBox(height: 8),
                const Text(
                  'Este aplicativo é uma ferramenta de simulação e projeção de cenários de rentabilidade agrícola. '
                  'Os resultados apresentados são estimativas baseadas em parâmetros fornecidos pelo usuário e/ou '
                  'em modelos internos, e não representam, asseguram ou garantem a ocorrência de resultados reais no campo.'
                ),
                const SizedBox(height: 16),
                Text('2. Ausência de Garantia de Desempenho', style: h),
                const SizedBox(height: 8),
                const Text(
                  'A utilização do aplicativo não constitui promessa, garantia, endosso ou compromisso de desempenho da Effatha '
                  'ou de quaisquer terceiros. As simulações não são e não devem ser interpretadas como previsões exatas, '
                  'recomendações técnicas, consultoria agronômica ou financeira.'
                ),
                const SizedBox(height: 16),
                Text('3. Responsabilidade do Usuário', style: h),
                const SizedBox(height: 8),
                const Text(
                  'Cabe exclusivamente ao usuário avaliar a adequação das informações geradas para seus objetivos, bem como validar, '
                  'por meios próprios, quaisquer decisões operacionais, técnicas ou comerciais. O usuário reconhece que fatores '
                  'climáticos, biológicos, logísticos, econômicos e regulatórios, entre outros, podem impactar substancialmente os resultados reais.'
                ),
                const SizedBox(height: 16),
                Text('4. Limitação de Responsabilidade', style: h),
                const SizedBox(height: 8),
                const Text(
                  'Na máxima extensão permitida pela legislação aplicável, a Effatha e seus colaboradores não serão responsáveis por quaisquer '
                  'danos diretos, indiretos, incidentais, especiais, consequenciais ou punitivos decorrentes do uso, incapacidade de uso '
                  'ou confiança nas informações geradas pelo aplicativo.'
                ),
                const SizedBox(height: 16),
                Text('5. Atualizações e Alterações', style: h),
                const SizedBox(height: 8),
                const Text(
                  'As funcionalidades, modelos e parâmetros do aplicativo podem ser alterados, suspensos ou descontinuados a qualquer tempo, sem aviso prévio.'
                ),
                const SizedBox(height: 16),
                Text('6. Aceite', style: h),
                const SizedBox(height: 8),
                const Text(
                  'Ao utilizar o aplicativo, o usuário declara ter lido, compreendido e concordado integralmente com estes Termos de Uso.'
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
