import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String currentLanguage = 'ky';

  @override
  void initState() {
    super.initState();
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
      'addProduct': {
        'ky': '➕ Товар кошуу',
        'ru': '➕ Добавить товар',
        'en': '➕ Add Product',
        'ko': '➕ 상품 추가',
      },

      'productImage': {
        'ky': 'Товар сүрөтү',
        'ru': 'Фото товара',
        'en': 'Product Image',
        'ko': '상품 사진',
      },

      'changeImage': {
        'ky': 'Сүрөттү өзгөртүү',
        'ru': 'Изменить фото',
        'en': 'Change photo',
        'ko': '사진 변경',
      },

      'selectImage': {
        'ky': 'Сүрөт тандоо',
        'ru': 'Выбрать фото',
        'en': 'Select photo',
        'ko': '사진 선택',
      },

      'selectFromGallery': {
        'ky': 'Галереядан сүрөт тандаңыз',
        'ru': 'Выберите фото из галереи',
        'en': 'Choose a photo from gallery',
        'ko': '갤러리에서 사진을 선택하세요',
      },

      'productInfo': {
        'ky': 'Товар маалыматы',
        'ru': 'Информация о товаре',
        'en': 'Product Information',
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

      'saveProduct': {
        'ky': 'Товарды сактоо',
        'ru': 'Сохранить товар',
        'en': 'Save Product',
        'ko': '상품 저장',
      },

      'saving': {
        'ky': 'Сакталууда...',
        'ru': 'Сохранение...',
        'en': 'Saving...',
        'ko': '저장 중...',
      },

      'marketplaceInfo': {
        'ky': 'Товар Marketplace бөлүмүнө кошулат.',
        'ru': 'Товар будет добавлен в раздел Marketplace.',
        'en': 'The product will be added to the Marketplace.',
        'ko': '상품이 Marketplace에 추가됩니다.',
      },

      'imageTooLarge': {
        'ky': 'Сүрөт өтө чоң. Башка сүрөт тандаңыз 📷',
        'ru': 'Фото слишком большое. Выберите другое фото 📷',
        'en': 'Image is too large. Choose another photo 📷',
        'ko': '사진이 너무 큽니다. 다른 사진을 선택하세요 📷',
      },

      'loginFirst': {
        'ky': 'Адегенде аккаунтка кириңиз',
        'ru': 'Сначала войдите в аккаунт',
        'en': 'Please log in first',
        'ko': '먼저 로그인해주세요',
      },

      'fillAllFields': {
        'ky': 'Бардык талааларды толтуруңуз',
        'ru': 'Заполните все поля',
        'en': 'Fill in all fields',
        'ko': '모든 항목을 입력해주세요',
      },

      'selectImageError': {
        'ky': 'Сүрөт тандаңыз 📷',
        'ru': 'Выберите фото 📷',
        'en': 'Please select a photo 📷',
        'ko': '사진을 선택해주세요 📷',
      },

      'invalidPrice': {
        'ky': 'Бааны туура жазыңыз',
        'ru': 'Введите правильную цену',
        'en': 'Enter a valid price',
        'ko': '올바른 가격을 입력해주세요',
      },

      'productSaved': {
        'ky': 'Товар ийгиликтүү сакталды! 🎉',
        'ru': 'Товар успешно сохранён! 🎉',
        'en': 'Product saved successfully! 🎉',
        'ko': '상품이 성공적으로 저장되었습니다! 🎉',
      },

      'error': {'ky': 'Ката', 'ru': 'Ошибка', 'en': 'Error', 'ko': '오류'},
    };

    return translations[key]?[currentLanguage] ??
        translations[key]?['ky'] ??
        key;
  }

  // =========================================================
  // 📷 СҮРӨТ ТАНДОО
  // =========================================================

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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t('imageTooLarge'))));

      return;
    }

    setState(() {
      selectedImage = file;
      imageBase64 = base64Encode(bytes);
    });
  }

  // =========================================================
  // 💾 ТОВАРДЫ САКТОО
  // =========================================================

  Future<void> saveProduct() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t('loginFirst'))));

      return;
    }

    final title = titleController.text.trim();
    final priceText = priceController.text.trim();
    final description = descriptionController.text.trim();

    if (title.isEmpty || priceText.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t('fillAllFields'))));

      return;
    }

    if (imageBase64 == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t('selectImageError'))));

      return;
    }

    final price = double.tryParse(priceText);

    if (price == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t('invalidPrice'))));

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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t('productSaved'))));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${t('error')}: $e')));
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
          t('addProduct'),
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
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(14),
                              ),

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
                        ],
                      ),
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
                  // 🏷️ Аты
                  _buildTextField(
                    controller: titleController,
                    label: t('productName'),
                    hint: t('productNameHint'),
                    icon: Icons.shopping_bag_outlined,
                  ),

                  const SizedBox(height: 15),

                  // 💰 Баасы
                  _buildTextField(
                    controller: priceController,
                    label: t('price'),
                    hint: t('priceHint'),
                    icon: Icons.payments_outlined,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 📄 Сүрөттөмө
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
                  isSaving ? t('saving') : t('saveProduct'),

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
                t('marketplaceInfo'),
                textAlign: TextAlign.center,

                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // 📸 СҮРӨТ PLACEHOLDER
  // =========================================================

  Widget _imagePlaceholder() {
    return Container(
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
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 5),

            Text(
              t('selectFromGallery'),
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
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
