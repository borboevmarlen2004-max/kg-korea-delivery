import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KoreaToKyrgyzstanPage extends StatefulWidget {
  const KoreaToKyrgyzstanPage({super.key});

  @override
  State<KoreaToKyrgyzstanPage> createState() => _KoreaToKyrgyzstanPageState();
}

class _KoreaToKyrgyzstanPageState extends State<KoreaToKyrgyzstanPage> {
  final productController = TextEditingController();
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final phoneController = TextEditingController();

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

      'krToKg': {
        'ky': 'Корея → Кыргызстан 🇰🇬',
        'ru': 'Корея → Кыргызстан 🇰🇬',
        'en': 'Korea → Kyrgyzstan 🇰🇬',
        'ko': '한국 → 키르기스스탄 🇰🇬',
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
        'ky': 'Мисалы: Сеул',
        'ru': 'Например: Сеул',
        'en': 'Example: Seoul',
        'ko': '예: 서울',
      },

      'to': {'ky': 'Кайда?', 'ru': 'Куда?', 'en': 'To?', 'ko': '도착지?'},

      'toHint': {
        'ky': 'Мисалы: Бишкек',
        'ru': 'Например: Бишкек',
        'en': 'Example: Bishkek',
        'ko': '예: 비슈케크',
      },

      'phone': {'ky': 'Телефон', 'ru': 'Телефон', 'en': 'Phone', 'ko': '전화번호'},

      'phoneHint': {
        'ky': 'Мисалы: +996...',
        'ru': 'Например: +996...',
        'en': 'Example: +996...',
        'ko': '예: +996...',
      },

      'info': {
        'ky':
            'Маалыматтарды туура толтуруңуз. '
            'Заказ түзүлгөндөн кийин аны '
            '«Менин заказдарым» бөлүмүнөн көрө аласыз.',
        'ru':
            'Заполните данные правильно. '
            'После создания заказа вы сможете '
            'увидеть его в разделе «Мои заказы».',
        'en':
            'Fill in the information correctly. '
            'After creating the order, you can '
            'view it in the “My Orders” section.',
        'ko':
            '정보를 정확하게 입력해주세요. '
            '주문 생성 후 “내 주문”에서 '
            '확인할 수 있습니다.',
      },

      'create': {
        'ky': 'Заказ түзүү',
        'ru': 'Создать заказ',
        'en': 'Create Order',
        'ko': '주문 생성',
      },

      'creating': {
        'ky': 'Заказ түзүлүүдө...',
        'ru': 'Создание заказа...',
        'en': 'Creating order...',
        'ko': '주문 생성 중...',
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
        'ko': '주문이 성공적으로 생성되었습니다! 🎉',
      },

      'error': {'ky': 'Ката', 'ru': 'Ошибка', 'en': 'Error', 'ko': '오류'},
    };

    return translations[key]?[currentLanguage] ??
        translations[key]?['ky'] ??
        key;
  }

  // =========================================================
  // 📦 ORDER
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
      final orderNumber = 'KRK${DateTime.now().millisecondsSinceEpoch}';

      await FirebaseFirestore.instance.collection('orders').add({
        'orderNumber': orderNumber,
        'userId': user.uid,
        'email': user.email,
        'direction': 'Корея → Кыргызстан',
        'product': productController.text.trim(),
        'from': fromController.text.trim(),
        'to': toController.text.trim(),
        'phone': phoneController.text.trim(),
        'status': 'Жаңы заказ',
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
            // 🇰🇷 → 🇰🇬 HEADER
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
                      child: Text('🇰🇷', style: TextStyle(fontSize: 30)),
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
                          t('krToKg'),

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

            const SizedBox(height: 22),

            // =================================================
            // ℹ️ INFO
            // =================================================
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(18),

                border: Border.all(color: Colors.grey.shade200),
              ),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF1565C0)),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      t('info'),

                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

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
                  isCreating ? t('creating') : t('create'),

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
