import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'edit_profile_page.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String selectedLanguage = 'ky';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      selectedLanguage = prefs.getString('language') ?? 'ky';
    });
  }

  Future<void> _changeLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('language', language);

    if (!mounted) return;

    setState(() {
      selectedLanguage = language;
    });

    Navigator.pop(context);
  }

  String _languageName() {
    switch (selectedLanguage) {
      case 'ru':
        return 'Русский';
      case 'en':
        return 'English';
      case 'ko':
        return '한국어';
      default:
        return 'Кыргызча';
    }
  }

  String _languageFlag() {
    switch (selectedLanguage) {
      case 'ru':
        return '🇷🇺';
      case 'en':
        return '🇬🇧';
      case 'ko':
        return '🇰🇷';
      default:
        return '🇰🇬';
    }
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Тилди тандоо',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 15),

                _languageTile(
                  context: sheetContext,
                  flag: '🇰🇬',
                  name: 'Кыргызча',
                  code: 'ky',
                ),

                _languageTile(
                  context: sheetContext,
                  flag: '🇷🇺',
                  name: 'Русский',
                  code: 'ru',
                ),

                _languageTile(
                  context: sheetContext,
                  flag: '🇬🇧',
                  name: 'English',
                  code: 'en',
                ),

                _languageTile(
                  context: sheetContext,
                  flag: '🇰🇷',
                  name: '한국어',
                  code: 'ko',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _languageTile({
    required BuildContext context,
    required String flag,
    required String name,
    required String code,
  }) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      leading: Text(flag, style: const TextStyle(fontSize: 25)),
      title: Text(
        name,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      trailing: selectedLanguage == code
          ? const Icon(Icons.check, color: Color(0xFF1565C0))
          : null,
      onTap: () async {
        await _changeLanguage(code);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : 'Аты көрсөтүлгөн эмес';

    final email = user?.email ?? 'Белгисиз';
    final uid = user?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          '👤 Менин профилим',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),

        child: Column(
          children: [
            // 👤 ПРОФИЛЬ HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                children: [
                  // 📸 ПРОФИЛЬ СҮРӨТҮ
                  Container(
                    width: 110,
                    height: 110,

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE3F2FD),

                      border: Border.all(
                        color: const Color(0xFF1565C0),
                        width: 3,
                      ),
                    ),

                    child: ClipOval(
                      child:
                          user?.photoURL != null && user!.photoURL!.isNotEmpty
                          ? Image.network(
                              user.photoURL!,
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.person,
                                  size: 55,
                                  color: Color(0xFF1565C0),
                                );
                              },
                            )
                          : const Icon(
                              Icons.person,
                              size: 55,
                              color: Color(0xFF1565C0),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),

                  const SizedBox(height: 20),

                  // ✏️ ПРОФИЛДИ ӨЗГӨРТҮҮ
                  SizedBox(
                    width: double.infinity,
                    height: 50,

                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfilePage(),
                          ),
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),

                      icon: const Icon(Icons.edit_outlined),

                      label: const Text(
                        'Профилди өзгөртүү',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🌍 ТИЛ
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),

              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),

                leading: Container(
                  width: 42,
                  height: 42,

                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: const Icon(
                    Icons.language,
                    color: Color(0xFF1565C0),
                    size: 21,
                  ),
                ),

                title: const Text(
                  'Тил',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),

                subtitle: Text(
                  '${_languageFlag()}  ${_languageName()}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),

                trailing: const Icon(Icons.chevron_right, color: Colors.grey),

                onTap: _showLanguageSelector,
              ),
            ),

            const SizedBox(height: 20),

            // 📋 АККАУНТ МААЛЫМАТЫ
            const Align(
              alignment: Alignment.centerLeft,

              child: Text(
                'Аккаунт маалыматы',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),

              child: Column(
                children: [
                  _infoTile(
                    icon: Icons.person_outline,
                    title: 'Аты',
                    value: name,
                  ),

                  Divider(height: 1, color: Colors.grey.shade200),

                  _infoTile(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    value: email,
                  ),

                  Divider(height: 1, color: Colors.grey.shade200),

                  _infoTile(
                    icon: Icons.badge_outlined,
                    title: 'UID',
                    value: uid,
                    isUid: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 🚪 ЧЫГУУ
            SizedBox(
              width: double.infinity,
              height: 55,

              child: OutlinedButton.icon(
                onPressed: () => logout(context),

                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,

                  side: const BorderSide(color: Colors.red),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),

                icon: const Icon(Icons.logout),

                label: const Text(
                  'Аккаунттан чыгуу',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'KG ↔️ KOREA Delivery',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // 📋 МААЛЫМАТ КАРТОЧКАСЫ
  Widget _infoTile({
    required IconData icon,
    required String title,
    required String value,
    bool isUid = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(icon, color: const Color(0xFF1565C0), size: 21),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 4),

                Text(
                  value.isEmpty ? 'Көрсөтүлгөн эмес' : value,

                  maxLines: isUid ? 2 : 3,

                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
