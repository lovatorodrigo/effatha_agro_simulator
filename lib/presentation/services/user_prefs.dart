import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  final String name;
  final String email;
  final String? photoUrl;

  const UserData({
    required this.name,
    required this.email,
    this.photoUrl,
  });
}

class UserPrefs {
  static const _kName = 'user_name';
  static const _kEmail = 'user_email';
  static const _kPhoto = 'user_photo';

  /// Lê os dados salvos do usuário (ou null se não houver).
  static Future<UserData?> get() async {
    final p = await SharedPreferences.getInstance();
    final email = p.getString(_kEmail) ?? '';
    if (email.isEmpty) return null;
    return UserData(
      name: p.getString(_kName) ?? '',
      email: email,
      photoUrl: p.getString(_kPhoto),
    );
  }

  /// Salva/atualiza os dados do usuário.
  static Future<void> save(UserData u) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kName, u.name);
    await p.setString(_kEmail, u.email);
    if (u.photoUrl != null && u.photoUrl!.isNotEmpty) {
      await p.setString(_kPhoto, u.photoUrl!);
    }
  }

  /// Limpa os dados do usuário (logout simples).
  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kName);
    await p.remove(_kEmail);
    await p.remove(_kPhoto);
  }
}
