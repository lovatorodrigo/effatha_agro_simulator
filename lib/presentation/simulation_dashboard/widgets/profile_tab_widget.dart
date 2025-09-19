import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/app_export.dart';

class ProfileTabWidget extends StatefulWidget {
  const ProfileTabWidget({
    super.key,
    this.initialName = '',
    this.initialEmail = '',
    this.simulationsRun = 0,
    this.onLogout,
  });

  final String initialName;
  final String initialEmail;
  final int simulationsRun;
  final VoidCallback? onLogout;

  @override
  State<ProfileTabWidget> createState() => _ProfileTabWidgetState();
}

class _ProfileTabWidgetState extends State<ProfileTabWidget> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _pwd2Ctrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    _restoreFromPrefs();
  }

  Future<void> _restoreFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _nameCtrl.text = prefs.getString('profile_name') ?? widget.initialName;
    _emailCtrl.text = prefs.getString('profile_email') ?? widget.initialEmail;

    final savedAvatarPath = prefs.getString('profile_avatar_path');
    if (savedAvatarPath != null && File(savedAvatarPath).existsSync()) {
      setState(() => _avatarFile = File(savedAvatarPath));
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final img = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (img != null) {
        setState(() => _avatarFile = File(img.path));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_avatar_path', img.path);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível escolher a foto.')),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Valida senha somente se usuário digitou algo
    if (_pwdCtrl.text.isNotEmpty || _pwd2Ctrl.text.isNotEmpty) {
      if (_pwdCtrl.text != _pwd2Ctrl.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('As senhas não conferem.')),
        );
        return;
      }
      if (_pwdCtrl.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A senha deve ter pelo menos 6 caracteres.')),
        );
        return;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', _nameCtrl.text.trim());
    await prefs.setString('profile_email', _emailCtrl.text.trim());

    // AVISO: aqui só persistimos localmente por simplicidade.
    // Se tiver backend/Auth, troque por chamada segura.
    if (_pwdCtrl.text.isNotEmpty) {
      await prefs.setString('profile_password_local', _pwdCtrl.text);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alterações salvas.')),
    );

    setState(() {
      _pwdCtrl.clear();
      _pwd2Ctrl.clear();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _pwd2Ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          Text(
            'Perfil',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
              shadows: const [
                Shadow(color: Colors.black54, offset: Offset(0, 1), blurRadius: 2),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Card da foto + nome/email
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppTheme.primaryLight,
                  backgroundImage: _avatarFile != null ? FileImage(_avatarFile!) : null,
                  child: _avatarFile == null
                      ? const CustomIconWidget(iconName: 'person', color: Colors.white, size: 48)
                      : null,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successLight,
                    foregroundColor: AppTheme.onSecondaryLight,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  icon: const CustomIconWidget(iconName: 'photo_camera', color: Colors.white, size: 18),
                  label: const Text('Editar Foto'),
                ),
                const SizedBox(height: 10),
                Text(
                  _nameCtrl.text.isEmpty ? 'Usuário' : _nameCtrl.text,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _emailCtrl.text.isEmpty ? 'email@exemplo.com' : _emailCtrl.text,
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondaryLight),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Form
          Form(
            key: _formKey,
            child: Column(
              children: [
                _field(
                  label: 'Nome',
                  controller: _nameCtrl,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 12),
                _field(
                  label: 'Email',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    final t = v?.trim() ?? '';
                    if (t.isEmpty) return 'Informe o e-mail';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(t)) return 'E-mail inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _field(
                  label: 'Nova senha',
                  controller: _pwdCtrl,
                  obscure: true,
                ),
                const SizedBox(height: 12),
                _field(
                  label: 'Confirmar nova senha',
                  controller: _pwd2Ctrl,
                  obscure: true,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.successLight,
                      foregroundColor: AppTheme.onSecondaryLight,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Salvar Alterações'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          Text('Resumo',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              )),
          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              border: Border.all(color: const Color(0xFF366348)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Simulações Realizadas',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
                Text(
                  NumberFormat.decimalPattern('pt_BR').format(widget.simulationsRun),
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Text('Conta',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              )),
          const SizedBox(height: 8),

          // Sair
          InkWell(
            onTap: widget.onLogout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: const [
                  Expanded(child: Text('Sair', style: TextStyle(color: Colors.white))),
                  Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: const Color(0xFF1b3124),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF366348)),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF366348)),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
