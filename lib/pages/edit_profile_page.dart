import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final nameController = TextEditingController();

  File? selectedImage;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    nameController.text = user?.displayName ?? '';
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  // 📸 СҮРӨТ ТАНДОО
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

  // 💾 ПРОФИЛЬДИ САКТОО
  Future<void> saveProfile() async {
    final name = nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Атыңызды жазыңыз')));
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
      ).showSnackBar(const SnackBar(content: Text('Профиль сакталды! ✅')));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Сактоодо ката: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: const Text(
          '✏️ Профилди өзгөртүү',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),

        child: Column(
          children: [
            // 👤 ПРОФИЛЬ СҮРӨТҮ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),

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

                  const Text(
                    'Профиль сүрөтү',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Сүрөттү өзгөртүү үчүн басыңыз',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 📝 АТЫ
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Жеке маалымат',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  labelText: 'Атыңыз',
                  hintText: 'Мисалы: Марлен',

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

            // 💾 САКТОО
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
                  isSaving ? 'Сакталууда...' : 'Профилди сактоо',

                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'Сүрөт Firebase Storage, аты Firebase Auth аркылуу сакталат.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
