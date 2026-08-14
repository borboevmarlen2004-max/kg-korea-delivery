import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final nameController = TextEditingController();

  File? selectedImage;

  bool isSaving = false;
  String currentLanguage = 'ky';

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    nameController.text = user?.displayName ?? '';

    _loadLanguage();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  // =========================================================
  // 🌍 LANGUAGE
  // =========================================================

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('language') ?? 'ky';

    if (!mounted) return;

    setState(() {
      currentLanguage = language;
    });
  }

  String t(String key) {
    const translations = <String, Map<String, String>>{
      'editProfile': {
        'ky': '✏️ Профилди өзгөртүү',
        'ru': '✏️ Изменить профиль',
        'en': '✏️ Edit Profile',
        'ko': '✏️ 프로필 수정',
      },

      'profilePhoto': {
        'ky': 'Профиль сүрөтү',
        'ru': 'Фото профиля',
        'en': 'Profile Photo',
        'ko': '프로필 사진',
      },

      'changePhoto': {
        'ky': 'Сүрөттү өзгөртүү үчүн басыңыз',
        'ru': 'Нажмите, чтобы изменить фото',
        'en': 'Tap to change your photo',
        'ko': '사진을 변경하려면 누르세요',
      },

      'personalInfo': {
        'ky': 'Жеке маалымат',
        'ru': 'Личная информация',
        'en': 'Personal Information',
        'ko': '개인 정보',
      },

      'yourName': {
        'ky': 'Атыңыз',
        'ru': 'Ваше имя',
        'en': 'Your name',
        'ko': '이름',
      },

      'exampleName': {
        'ky': 'Мисалы: Марлен',
        'ru': 'Например: Марлен',
        'en': 'Example: Marlen',
        'ko': '예: Marlen',
      },

      'saveProfile': {
        'ky': 'Профилди сактоо',
        'ru': 'Сохранить профиль',
        'en': 'Save Profile',
        'ko': '프로필 저장',
      },

      'saving': {
        'ky': 'Сакталууда...',
        'ru': 'Сохранение...',
        'en': 'Saving...',
        'ko': '저장 중...',
      },

      'nameRequired': {
        'ky': 'Атыңызды жазыңыз',
        'ru': 'Введите ваше имя',
        'en': 'Please enter your name',
        'ko': '이름을 입력해주세요',
      },

      'profileSaved': {
        'ky': 'Профиль сакталды! ✅',
        'ru': 'Профиль сохранён! ✅',
        'en': 'Profile saved! ✅',
        'ko': '프로필이 저장되었습니다! ✅',
      },

      'saveError': {
        'ky': 'Сактоодо ката',
        'ru': 'Ошибка сохранения',
        'en': 'Error while saving',
        'ko': '저장 중 오류',
      },

      'storageInfo': {
        'ky': 'Сүрөт Firebase Storage, аты Firebase Auth аркылуу сакталат.',
        'ru': 'Фото сохраняется в Firebase Storage, имя — через Firebase Auth.',
        'en':
            'The photo is saved to Firebase Storage, and the name through Firebase Auth.',
        'ko': '사진은 Firebase Storage에, 이름은 Firebase Auth를 통해 저장됩니다.',
      },
    };

    return translations[key]?[currentLanguage] ??
        translations[key]?['ky'] ??
        key;
  }

  // =========================================================
  // 📸 СҮРӨТ ТАНДОО
  // =========================================================

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
    });
  }

  // =========================================================
  // 💾 ПРОФИЛЬДИ САКТОО
  // =========================================================

  Future<void> saveProfile() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t('nameRequired'))));
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      // 👤 АТЫН САКТОО
      await user.updateDisplayName(name);

      // 📸 ЭГЕР ЖАҢЫ СҮРӨТ ТАНДАЛСА
      if (selectedImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_photos')
            .child('${user.uid}.jpg');

        await storageRef.putFile(selectedImage!);

        final photoUrl = await storageRef.getDownloadURL();

        // 🔗 Firebase Auth'ка сүрөт URL сактайбыз
        await user.updatePhotoURL(photoUrl);
      }

      await user.reload();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t('profileSaved'))));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${t('saveError')}: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // =========================================================
  // 🏠 BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,

        title: Text(
          t('editProfile'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),

        child: Column(
          children: [
            // =================================================
            // 👤 ПРОФИЛЬ СҮРӨТҮ
            // =================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                children: [
                  GestureDetector(
                    onTap: pickImage,

                    child: Stack(
                      children: [
                        Container(
                          width: 120,
                          height: 120,

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE3F2FD),

                            border: Border.all(
                              color: const Color(0xFF1565C0),
                              width: 3,
                            ),
                          ),

                          child: ClipOval(
                            child: selectedImage != null
                                ? Image.file(
                                    selectedImage!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  )
                                : (user?.photoURL != null &&
                                      user!.photoURL!.isNotEmpty)
                                ? Image.network(
                                    user.photoURL!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.person,
                                        size: 65,
                                        color: Color(0xFF1565C0),
                                      );
                                    },
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 65,
                                    color: Color(0xFF1565C0),
                                  ),
                          ),
                        ),

                        // 📷 КАМЕРА
                        Positioned(
                          right: 0,
                          bottom: 0,

                          child: Container(
                            width: 40,
                            height: 40,

                            decoration: BoxDecoration(
                              color: const Color(0xFF1565C0),
                              shape: BoxShape.circle,

                              border: Border.all(color: Colors.white, width: 3),
                            ),

                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    t('profilePhoto'),
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    t('changePhoto'),
                    textAlign: TextAlign.center,

                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =================================================
            // 📝 ЖЕКЕ МААЛЫМАТ
            // =================================================
            Align(
              alignment: Alignment.centerLeft,

              child: Text(
                t('personalInfo'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),

              child: TextField(
                controller: nameController,

                textCapitalization: TextCapitalization.words,

                decoration: InputDecoration(
                  labelText: t('yourName'),
                  hintText: t('exampleName'),

                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF1565C0),
                  ),

                  filled: true,

                  fillColor: const Color(0xFFF5F7FA),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),

                    borderSide: const BorderSide(
                      color: Color(0xFF1565C0),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // =================================================
            // 💾 САКТОО
            // =================================================
            SizedBox(
              width: double.infinity,
              height: 58,

              child: ElevatedButton.icon(
                onPressed: isSaving ? null : saveProfile,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),

                  foregroundColor: Colors.white,

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),

                icon: isSaving
                    ? const SizedBox(
                        width: 21,
                        height: 21,

                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),

                label: Text(
                  isSaving ? t('saving') : t('saveProfile'),

                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Text(
              t('storageInfo'),
              textAlign: TextAlign.center,

              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
