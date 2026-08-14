import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String currentLanguage = 'ky';

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.title);

    priceController = TextEditingController(text: widget.price);

    descriptionController = TextEditingController(text: widget.description);

    imageBase64 = widget.imageBase64;

    _loadLanguage();
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    descriptionController.dispose();
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
      'editProduct': {
        'ky': '✏️ Товарды өзгөртүү',
        'ru': '✏️ Редактировать товар',
        'en': '✏️ Edit Product',
        'ko': '✏️ 상품 수정',
      },

      'productImage': {
        'ky': 'Товар сүрөтү',
        'ru': 'Фото товара',
        'en': 'Product image',
        'ko': '상품 사진',
      },

      'productInfo': {
        'ky': 'Товар маалыматы',
        'ru': 'Информация о товаре',
        'en': 'Product information',
        'ko': '상품 정보',
      },

      'productName': {
        'ky': 'Товардын аты',
        'ru': 'Название товара',
        'en': 'Product name',
        'ko': '상품명',
      },

      'productNameHint': {
        'ky': 'Мисалы: iPhone 15',
        'ru': 'Например: iPhone 15',
        'en': 'Example: iPhone 15',
        'ko': '예: iPhone 15',
      },

      'price': {
        'ky': 'Баасы (сом)',
        'ru': 'Цена (сом)',
        'en': 'Price (som)',
        'ko': '가격 (솜)',
      },

      'priceHint': {
        'ky': 'Мисалы: 50000',
        'ru': 'Например: 50000',
        'en': 'Example: 50000',
        'ko': '예: 50000',
      },

      'description': {
        'ky': 'Сүрөттөмө',
        'ru': 'Описание',
        'en': 'Description',
        'ko': '설명',
      },

      'descriptionHint': {
        'ky': 'Товар тууралуу маалымат',
        'ru': 'Информация о товаре',
        'en': 'Information about the product',
        'ko': '상품에 대한 정보',
      },

      'changeImage': {
        'ky': 'Сүрөттү өзгөртүү',
        'ru': 'Изменить фото',
        'en': 'Change image',
        'ko': '사진 변경',
      },

      'selectImage': {
        'ky': 'Сүрөт тандоо',
        'ru': 'Выбрать фото',
        'en': 'Select image',
        'ko': '사진 선택',
      },

      'galleryHint': {
        'ky': 'Галереядан сүрөт тандаңыз',
        'ru': 'Выберите фото из галереи',
        'en': 'Choose an image from gallery',
        'ko': '갤러리에서 사진을 선택하세요',
      },

      'saveChanges': {
        'ky': 'Өзгөртүүнү сактоо',
        'ru': 'Сохранить изменения',
        'en': 'Save Changes',
        'ko': '변경사항 저장',
      },

      'saving': {
        'ky': 'Сакталууда...',
        'ru': 'Сохранение...',
        'en': 'Saving...',
        'ko': '저장 중...',
      },

      'fillAll': {
        'ky': 'Бардык талааларды толтуруңуз',
        'ru': 'Заполните все поля',
        'en': 'Fill in all fields',
        'ko': '모든 항목을 입력해주세요',
      },

      'updated': {
        'ky': 'Товар жаңыртылды! ✅',
        'ru': 'Товар обновлён! ✅',
        'en': 'Product updated! ✅',
        'ko': '상품이 수정되었습니다! ✅',
      },

      'updateError': {
        'ky': 'Өзгөртүүдө ката',
        'ru': 'Ошибка при изменении',
        'en': 'Update error',
        'ko': '수정 오류',
      },

      'savedToFirebase': {
        'ky': "Өзгөртүүлөр Firebase'ке сакталат.",
        'ru': 'Изменения будут сохранены в Firebase.',
        'en': 'Changes will be saved to Firebase.',
        'ko': '변경사항은 Firebase에 저장됩니다.',
      },
    };

    return translations[key]?[currentLanguage] ??
        translations[key]?['ky'] ??
        key;
  }

  // =========================================================
  // 📷 ЖАҢЫ СҮРӨТ ТАНДОО
  // =========================================================

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

    if (!mounted) return;

    setState(() {
      selectedImage = file;
      imageBase64 = base64Image;
    });
  }

  // =========================================================
  // 💾 ӨЗГӨРТҮҮЛӨРДҮ САКТОО
  // =========================================================

  Future<void> updateProduct() async {
    final title = titleController.text.trim();

    final price = priceController.text.trim();

    final description = descriptionController.text.trim();

    if (title.isEmpty || price.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t('fillAll'))));

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
      ).showSnackBar(SnackBar(content: Text(t('updated'))));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${t('updateError')}: $e')));
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,

        foregroundColor: Colors.black87,

        elevation: 0,

        title: Text(
          t('editProduct'),

          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // =================================================
            // 📸 СҮРӨТ
            // =================================================
            Text(
              t('productImage'),

              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      color: Colors.black.withValues(alpha: 0.05),

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

            // =================================================
            // 📝 МААЛЫМАТ
            // =================================================
            Text(
              t('productInfo'),

              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  // 🏷️ АТЫ
                  _buildTextField(
                    controller: titleController,

                    label: t('productName'),

                    hint: t('productNameHint'),

                    icon: Icons.shopping_bag_outlined,
                  ),

                  const SizedBox(height: 15),

                  // 💰 БААСЫ
                  _buildTextField(
                    controller: priceController,

                    label: t('price'),

                    hint: t('priceHint'),

                    icon: Icons.payments_outlined,

                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 15),

                  // 📄 СҮРӨТТӨМӨ
                  _buildTextField(
                    controller: descriptionController,

                    label: t('description'),

                    hint: t('descriptionHint'),

                    icon: Icons.description_outlined,

                    maxLines: 5,
                  ),
                ],
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
                onPressed: isSaving ? null : updateProduct,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),

                  foregroundColor: Colors.white,

                  disabledBackgroundColor: Colors.grey.shade300,

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
                  isSaving ? t('saving') : t('saveChanges'),

                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: Text(
                t('savedToFirebase'),

                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // 📷 СҮРӨТТҮ ӨЗГӨРТҮҮ КНОПКАСЫ
  // =========================================================

  Widget _changeImageButton() {
    return Positioned(
      right: 15,
      bottom: 15,

      child: Material(
        color: Colors.black.withValues(alpha: 0.65),

        borderRadius: BorderRadius.circular(14),

        child: InkWell(
          onTap: pickImage,

          borderRadius: BorderRadius.circular(14),

          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

            child: Row(
              mainAxisSize: MainAxisSize.min,

              children: [
                const Icon(
                  Icons.camera_alt_outlined,

                  color: Colors.white,

                  size: 19,
                ),

                const SizedBox(width: 6),

                Text(
                  t('changeImage'),

                  style: const TextStyle(
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

  // =========================================================
  // 📸 СҮРӨТ ЖОК БОЛСО
  // =========================================================

  Widget _imagePlaceholder() {
    return InkWell(
      onTap: pickImage,

      child: Container(
        color: const Color(0xFFEFF2F5),

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              const Icon(
                Icons.add_a_photo_outlined,

                size: 60,

                color: Colors.grey,
              ),

              const SizedBox(height: 12),

              Text(
                t('selectImage'),

                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 5),

              Text(
                t('galleryHint'),

                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // ✏️ TEXT FIELD
  // =========================================================

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
