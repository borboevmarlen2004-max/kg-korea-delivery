import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProductPage extends StatefulWidget {
  final String productId;
  final String title;
  final String price;
  final String description;
  final String imageBase64;

  const EditProductPage({
    super.key,
    required this.productId,
    required this.title,
    required this.price,
    required this.description,
    required this.imageBase64,
  });

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  late TextEditingController titleController;
  late TextEditingController priceController;
  late TextEditingController descriptionController;

  File? selectedImage;
  String imageBase64 = '';
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.title);

    priceController = TextEditingController(text: widget.price);

    descriptionController = TextEditingController(text: widget.description);

    imageBase64 = widget.imageBase64;
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // 📷 Жаңы сүрөт тандоо
  Future<void> pickImage() async {
    final picker = ImagePicker();

    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 30,
      maxWidth: 600,
      maxHeight: 600,
    );

    if (image == null) return;

    final file = File(image.path);

    final bytes = await file.readAsBytes();
    final base64Image = base64Encode(bytes);

    setState(() {
      selectedImage = file;
      imageBase64 = base64Image;
    });
  }

  // 💾 Өзгөртүүлөрдү сактоо
  Future<void> updateProduct() async {
    final title = titleController.text.trim();
    final price = priceController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || price.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Бардык талааларды толтуруңуз')),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('marketplace')
          .doc(widget.productId)
          .update({
            'title': title,
            'price': double.tryParse(price) ?? 0,
            'description': description,
            'imageBase64': imageBase64,
          });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Товар жаңыртылды! ✅')));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Өзгөртүүдө ката: $e')));
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
          '✏️ Товарды өзгөртүү',
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

                child: selectedImage != null
                    ? Stack(
                        children: [
                          Positioned.fill(
                            child: Image.file(
                              selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          ),

                          _changeImageButton(),
                        ],
                      )
                    : imageBase64.isNotEmpty
                    ? Stack(
                        children: [
                          Positioned.fill(
                            child: Image.memory(
                              base64Decode(imageBase64),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _imagePlaceholder();
                              },
                            ),
                          ),

                          _changeImageButton(),
                        ],
                      )
                    : _imagePlaceholder(),
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
                    keyboardType: TextInputType.number,
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
                onPressed: isSaving ? null : updateProduct,

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
                  isSaving ? 'Сакталууда...' : 'Өзгөртүүнү сактоо',

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
                "Өзгөртүүлөр Firebase'ке сакталат.",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 📷 Сүрөттү өзгөртүү кнопкасы
  Widget _changeImageButton() {
    return Positioned(
      right: 15,
      bottom: 15,

      child: Material(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(14),

        child: InkWell(
          onTap: pickImage,
          borderRadius: BorderRadius.circular(14),

          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),

            child: Row(
              mainAxisSize: MainAxisSize.min,

              children: [
                Icon(Icons.camera_alt_outlined, color: Colors.white, size: 19),

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
      ),
    );
  }

  // 📸 Сүрөт жок болсо
  Widget _imagePlaceholder() {
    return InkWell(
      onTap: pickImage,

      child: Container(
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

        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(icon, color: const Color(0xFF1565C0)),
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
          borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
        ),
      ),
    );
  }
}
