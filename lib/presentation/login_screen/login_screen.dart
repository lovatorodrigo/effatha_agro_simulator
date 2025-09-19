import 'package:effatha_agro_simulator/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';

import './widgets/login_background_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/login_header_widget.dart';
import './widgets/social_login_widget.dart';

// Google Sign-In real
import 'package:google_sign_in/google_sign_in.dart';

// Persistência simples do usuário
import 'package:effatha_agro_simulator/presentation/services/user_prefs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  // DEMO (e-mail/senha) – mantém se você quiser testar local
  final Map<String, String> _mockCredentials = const {
    'admin@effatha.com': 'admin123',
    'farmer@effatha.com': 'farmer123',
    'demo@effatha.com': 'demo123',
  };

  // --- GoogleSignIn real (sem Firebase) ---
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email', 'profile'],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginBackgroundWidget(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 100.h),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Cabeçalho com logo responsivo grande
                  const LoginHeaderWidget(),

                  // Form + Social
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_errorMessage != null)
                            Container(
                              width: 85.w,
                              constraints: const BoxConstraints(maxWidth: 420),
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: AppTheme.errorLight.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.errorLight,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const CustomIconWidget(
                                    iconName: 'error_outline',
                                    color: AppTheme.errorLight,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppTheme.errorLight,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Login por e-mail/senha (opcional)
                          LoginFormWidget(
                            onLogin: _handleEmailLogin,
                            isLoading: _isLoading,
                          ),

                          SizedBox(height: 3.h),

                          // Social
                          SocialLoginWidget(
                            onGoogleSignIn: _handleGoogleSignIn,
                            onAppleSignIn: _handleAppleSignIn, // você pode ocultar no Android
                            isLoading: _isLoading,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --------- EMAIL/SENHA (DEMO) ----------
  Future<void> _handleEmailLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 900));

      if (_mockCredentials[email.toLowerCase()] == password) {
        final name = email.split('@').first;
        await UserPrefs.save(UserData(name: name, email: email));
        HapticFeedback.lightImpact();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/simulation-dashboard');
        }
      } else {
        setState(() {
          _errorMessage =
              'E-mail ou senha inválidos. Verifique suas credenciais e tente novamente.';
        });
        HapticFeedback.mediumImpact();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Ocorreu um erro. Tente novamente.';
      });
      HapticFeedback.mediumImpact();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --------- GOOGLE REAL ----------
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Desloga sessão anterior (evita conta "presa")
      await _googleSignIn.signOut();

      // Abre o seletor de contas
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      if (account == null) {
        // usuário cancelou
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      // auth.accessToken / idToken disponíveis se você quiser validar no backend

      await UserPrefs.save(UserData(
        name: account.displayName ?? account.email.split('@').first,
        email: account.email,
        photoUrl: account.photoUrl,
      ));

      HapticFeedback.lightImpact();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/simulation-dashboard');
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Falha no login com Google. Verifique a configuração do app e tente novamente.';
      });
      HapticFeedback.mediumImpact();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --------- APPLE (placeholder) ----------
  Future<void> _handleAppleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Implementar com sign_in_with_apple quando quiser.
      await Future.delayed(const Duration(milliseconds: 1200));
      await UserPrefs.save(const UserData(
        name: 'Apple User',
        email: 'apple.user@example.com',
      ));
      HapticFeedback.lightImpact();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/simulation-dashboard');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Falha no login Apple. Tente novamente.';
      });
      HapticFeedback.mediumImpact();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
