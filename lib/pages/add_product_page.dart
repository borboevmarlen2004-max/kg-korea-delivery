import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

  File? selectedImage;
  String? imageBase64;
  bool isSaving = false;

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // 📷 Сүрөт тандоо
  Future<void> pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 45,
      maxWidth: 900,
      maxHeight: 900,
    );

    if (image == null) return;

    final file = File(image.path);
    final bytes = await file.readAsBytes();

    // Firestore документин өтө чоң кылбоо үчүн
    if (bytes.length > 700000) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Сүрөт өтө чоң. Башка сүрөт тандаңыз 📷')),
      );

      return;
    }

    setState(() {
      selectedImage = file;
      imageBase64 = base64Encode(bytes);
    });
  }

  // 💾 Товарды сактоо
  Future<void> saveProduct() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Адегенде аккаунтка кириңиз')),
      );

      return;
    }

    final title = titleController.text.trim();
    final priceText = priceController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || priceText.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Бардык талааларды толтуруңуз')),
      );

      return;
    }

    if (imageBase64 == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Сүрөт тандаңыз 📷')));

      return;
    }

    final price = double.tryParse(priceText);

    if (price == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Бааны туура жазыңыз')));

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('marketplace').add({
        'title': title,
        'price': price,
        'description': description,

        // 🖼️ Сүрөт
        'imageBase64': imageBase64,

        // 👤 Сатуучу
        'sellerUid': user.uid,
        'sellerEmail': user.email,

        // 🛒 Товар азырынча сатылган эмес
        'sold': false,

        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Товар ийгиликтүү сакталды! 🎉')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ката: $e')));
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,

        title: const Text(
          '➕ Товар кошуу',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // 📸 СҮРӨТ
            const Text(
              'Товар сүрөтү',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            GestureDetector(
              onTap: pickImage,

              child: Container(
                width: double.infinity,
                height: 280,

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                clipBehavior: Clip.antiAlias,

                child: selectedImage == null
                    ? _imagePlaceholder()
                    : Stack(
                        children: [
                          Positioned.fill(
                            child: Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          ),

                          // 📷 Өзгөртүү белгиси
                          Positioned(
                            right: 15,
                            bottom: 15,

                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),

                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.65),
                                borderRadius: BorderRadius.circular(14),
                              ),

                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    color: Colors.white,
                                    size: 19,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Сүрөттү өзгөртүү',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 25),

            // 📝 МААЛЫМАТ
            const Text(
              'Товар маалыматы',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),

              child: Column(
                children: [
                  // 🏷️ Аты
                  _buildTextField(
                    controller: titleController,
                    label: 'Товардын аты',
                    hint: 'Мисалы: iPhone 15',
                    icon: Icons.shopping_bag_outlined,
                  ),

                  const SizedBox(height: 15),

                  // 💰 Баасы
                  _buildTextField(
                    controller: priceController,
                    label: 'Баасы (сом)',
                    hint: 'Мисалы: 50000',
                    icon: Icons.payments_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 📄 Сүрөттөмө
                  _buildTextField(
                    controller: descriptionController,
                    label: 'Сүрөттөмө',
                    hint: 'Товар тууралуу маалымат',
                    icon: Icons.description_outlined,
                    maxLines: 5,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 💾 САКТОО
            SizedBox(
              width: double.infinity,
              height: 58,

              child: ElevatedButton.icon(
                onPressed: isSaving ? null : saveProduct,

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
                  isSaving ? 'Сакталууда...' : 'Товарды сактоо',

                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Center(
              child: Text(
                'Товар Marketplace бөлүмүнө кошулат.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📸 Сүрөт тандоо
  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFEFF2F5),

      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(Icons.add_a_photo_outlined, size: 60, color: Colors.grey),

            SizedBox(height: 12),

            Text(
              'Сүрөт тандоо',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),

            SizedBox(height: 5),

            Text(
              'Галереядан сүрөт тандаңыз',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ✏️ Кооз TextField
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),

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
          borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
        ),
      ),
    );
  }
}
