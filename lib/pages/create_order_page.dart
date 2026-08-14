import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final productController = TextEditingController();
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final phoneController = TextEditingController();
  final priceController = TextEditingController();
  final deliveryController = TextEditingController(text: '500');

  File? selectedImage;

  final ImagePicker picker = ImagePicker();

  String message = '';
  bool isCreating = false;
  String currentLanguage = 'ky';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
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
      'createOrder': {
        'ky': '📦 Заказ түзүү',
        'ru': '📦 Создание заказа',
        'en': '📦 Create Order',
        'ko': '📦 주문 생성',
      },

      'deliveryDirection': {
        'ky': 'Жеткирүү багыты',
        'ru': 'Направление доставки',
        'en': 'Delivery direction',
        'ko': '배송 방향',
      },

      'kgToKorea': {
        'ky': 'Кыргызстан → Корея 🇰🇷',
        'ru': 'Кыргызстан → Корея 🇰🇷',
        'en': 'Kyrgyzstan → Korea 🇰🇷',
        'ko': '키르기스스탄 → 한국 🇰🇷',
      },

      'orderInfo': {
        'ky': '📦 Заказ маалыматы',
        'ru': '📦 Информация о заказе',
        'en': '📦 Order information',
        'ko': '📦 주문 정보',
      },

      'productName': {
        'ky': 'Товардын аты',
        'ru': 'Название товара',
        'en': 'Product name',
        'ko': '상품명',
      },

      'productHint': {
        'ky': 'Мисалы: Телефон',
        'ru': 'Например: Телефон',
        'en': 'Example: Phone',
        'ko': '예: 휴대폰',
      },

      'from': {'ky': 'Кайдан?', 'ru': 'Откуда?', 'en': 'From?', 'ko': '출발지?'},

      'fromHint': {
        'ky': 'Мисалы: Бишкек',
        'ru': 'Например: Бишкек',
        'en': 'Example: Bishkek',
        'ko': '예: Bishkek',
      },

      'to': {'ky': 'Кайда?', 'ru': 'Куда?', 'en': 'To?', 'ko': '도착지?'},

      'toHint': {
        'ky': 'Мисалы: Сеул',
        'ru': 'Например: Сеул',
        'en': 'Example: Seoul',
        'ko': '예: Seoul',
      },

      'phone': {'ky': 'Телефон', 'ru': 'Телефон', 'en': 'Phone', 'ko': '전화번호'},

      'phoneHint': {
        'ky': 'Мисалы: +996...',
        'ru': 'Например: +996...',
        'en': 'Example: +996...',
        'ko': '예: +996...',
      },

      'price': {
        'ky': 'Баасы (сом)',
        'ru': 'Цена (сом)',
        'en': 'Price (som)',
        'ko': '가격 (솜)',
      },

      'deliveryFee': {
        'ky': 'Жеткирүү акысы (сом)',
        'ru': 'Стоимость доставки (сом)',
        'en': 'Delivery fee (som)',
        'ko': '배송비 (솜)',
      },

      'paymentInfo': {
        'ky': 'Төлөм маалыматы',
        'ru': 'Информация об оплате',
        'en': 'Payment information',
        'ko': '결제 정보',
      },

      'productPrice': {
        'ky': 'Товардын баасы',
        'ru': 'Цена товара',
        'en': 'Product price',
        'ko': '상품 가격',
      },

      'delivery': {
        'ky': 'Жеткирүү',
        'ru': 'Доставка',
        'en': 'Delivery',
        'ko': '배송',
      },

      'total': {
        'ky': 'Жалпы сумма',
        'ru': 'Общая сумма',
        'en': 'Total',
        'ko': '총 금액',
      },

      'productImage': {
        'ky': '📷 Товардын сүрөтү',
        'ru': '📷 Фото товара',
        'en': '📷 Product image',
        'ko': '📷 상품 사진',
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

      'creatingOrder': {
        'ky': 'Заказ түзүлүүдө...',
        'ru': 'Создание заказа...',
        'en': 'Creating order...',
        'ko': '주문 생성 중...',
      },

      'create': {
        'ky': 'Заказ түзүү',
        'ru': 'Создать заказ',
        'en': 'Create Order',
        'ko': '주문 생성',
      },

      'loginFirst': {
        'ky': 'Адегенде аккаунтка кириңиз',
        'ru': 'Сначала войдите в аккаунт',
        'en': 'Please log in first',
        'ko': '먼저 로그인해주세요',
      },

      'fillAll': {
        'ky': 'Бардык талааларды толтуруңуз',
        'ru': 'Заполните все поля',
        'en': 'Fill in all fields',
        'ko': '모든 항목을 입력해주세요',
      },

      'success': {
        'ky': 'Заказ ийгиликтүү түзүлдү! 🎉',
        'ru': 'Заказ успешно создан! 🎉',
        'en': 'Order created successfully! 🎉',
        'ko': '주문이 успешно 생성되었습니다! 🎉',
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
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return;

    setState(() {
      selectedImage = File(image.path);
    });
  }

  // =========================================================
  // 📦 ЗАКАЗ ТҮЗҮҮ
  // =========================================================

  Future<void> createOrder() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        message = t('loginFirst');
      });

      return;
    }

    if (productController.text.trim().isEmpty ||
        fromController.text.trim().isEmpty ||
        toController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      setState(() {
        message = t('fillAll');
      });

      return;
    }

    setState(() {
      isCreating = true;
      message = '';
    });

    try {
      final orderNumber = 'KGK${DateTime.now().millisecondsSinceEpoch}';

      await FirebaseFirestore.instance.collection('orders').add({
        'orderNumber': orderNumber,
        'userId': user.uid,
        'email': user.email,
        'direction': 'Кыргызстан → Корея',
        'product': productController.text.trim(),
        'from': fromController.text.trim(),
        'to': toController.text.trim(),
        'phone': phoneController.text.trim(),
        'price': priceController.text,
        'deliveryFee': deliveryController.text,
        'totalPrice':
            (double.tryParse(priceController.text) ?? 0) +
            (double.tryParse(deliveryController.text) ?? 0),
        'status': 'Жаңы заказ',
        'paymentStatus': 'Төлөнө элек',
        'paymentMethod': 'Карта',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        message = t('success');
      });

      productController.clear();
      fromController.clear();
      toController.clear();
      phoneController.clear();
      priceController.clear();
      deliveryController.text = '500';

      setState(() {
        selectedImage = null;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t('success'))));
    } catch (e) {
      if (!mounted) return;

      setState(() {
        message = '${t('error')}: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          isCreating = false;
        });
      }
    }
  }

  // =========================================================
  // 🧹 DISPOSE
  // =========================================================

  @override
  void dispose() {
    productController.dispose();
    fromController.dispose();
    toController.dispose();
    phoneController.dispose();
    priceController.dispose();
    deliveryController.dispose();

    super.dispose();
  }

  // =========================================================
  // 🧩 INPUT FIELD
  // =========================================================

  Widget buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,

      decoration: InputDecoration(
        labelText: label,
        hintText: hint,

        prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),

        filled: true,

        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
        ),
      ),
    );
  }

  // =========================================================
  // 💰 PRICE INFO
  // =========================================================

  Widget buildPricePreview() {
    final price = double.tryParse(priceController.text) ?? 0;

    final delivery = double.tryParse(deliveryController.text) ?? 0;

    final total = price + delivery;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

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
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: Color(0xFF1565C0),
              ),

              const SizedBox(width: 8),

              Text(
                t('paymentInfo'),

                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          _priceRow(t('productPrice'), '${price.toStringAsFixed(0)} сом'),

          const SizedBox(height: 8),

          _priceRow(t('delivery'), '${delivery.toStringAsFixed(0)} сом'),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),

            child: Divider(color: Colors.grey.shade200),
          ),

          Row(
            children: [
              Text(
                t('total'),

                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Spacer(),

              Text(
                '${total.toStringAsFixed(0)} сом',

                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String title, String value) {
    return Row(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),

        const Spacer(),

        Text(
          value,

          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
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
          t('createOrder'),

          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // =================================================
            // 🇰🇬 → 🇰🇷 HEADER
            // =================================================
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),

                borderRadius: BorderRadius.circular(24),

                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.18),

                    blurRadius: 18,

                    offset: const Offset(0, 7),
                  ),
                ],
              ),

              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,

                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),

                      shape: BoxShape.circle,
                    ),

                    child: const Center(
                      child: Text('🇰🇬', style: TextStyle(fontSize: 30)),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          t('deliveryDirection'),

                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          t('kgToKorea'),

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Text(
              t('orderInfo'),

              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // 📦 PRODUCT
            buildField(
              controller: productController,
              label: t('productName'),
              icon: Icons.inventory_2_outlined,
              hint: t('productHint'),
            ),

            const SizedBox(height: 13),

            // 📍 FROM
            buildField(
              controller: fromController,
              label: t('from'),
              icon: Icons.location_on_outlined,
              hint: t('fromHint'),
            ),

            const SizedBox(height: 13),

            // 📍 TO
            buildField(
              controller: toController,
              label: t('to'),
              icon: Icons.location_searching,
              hint: t('toHint'),
            ),

            const SizedBox(height: 13),

            // 📞 PHONE
            buildField(
              controller: phoneController,
              label: t('phone'),
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              hint: t('phoneHint'),
            ),

            const SizedBox(height: 13),

            // 💰 PRICE
            buildField(
              controller: priceController,
              label: t('price'),
              icon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 13),

            // 🚚 DELIVERY
            buildField(
              controller: deliveryController,
              label: t('deliveryFee'),
              icon: Icons.local_shipping_outlined,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            // =================================================
            // 📷 IMAGE
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
                height: 190,

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(20),

                  border: Border.all(color: Colors.grey.shade200),
                ),

                child: selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Container(
                            width: 58,
                            height: 58,

                            decoration: const BoxDecoration(
                              color: Color(0xFFE3F2FD),

                              shape: BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.add_a_photo_outlined,

                              size: 28,

                              color: Color(0xFF1565C0),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            t('selectImage'),

                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            t('galleryHint'),

                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),

                        child: Image.file(
                          selectedImage!,

                          width: double.infinity,

                          height: double.infinity,

                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // =================================================
            // 💰 PRICE PREVIEW
            // =================================================
            buildPricePreview(),

            const SizedBox(height: 20),

            // =================================================
            // 📦 CREATE BUTTON
            // =================================================
            SizedBox(
              width: double.infinity,
              height: 58,

              child: ElevatedButton.icon(
                onPressed: isCreating ? null : createOrder,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),

                  foregroundColor: Colors.white,

                  disabledBackgroundColor: Colors.grey.shade300,

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),

                icon: isCreating
                    ? const SizedBox(
                        width: 22,
                        height: 22,

                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.inventory_2_outlined),

                label: Text(
                  isCreating ? t('creatingOrder') : t('create'),

                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // =================================================
            // 💬 MESSAGE
            // =================================================
            if (message.isNotEmpty) ...[
              const SizedBox(height: 15),

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: message.startsWith(t('error'))
                      ? Colors.red.withValues(alpha: 0.08)
                      : Colors.green.withValues(alpha: 0.08),

                  borderRadius: BorderRadius.circular(15),
                ),

                child: Text(
                  message,

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: message.startsWith(t('error'))
                        ? Colors.red
                        : Colors.green,

                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
