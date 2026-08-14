import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditOrderPage extends StatefulWidget {
  final String orderId;
  final Map<String, dynamic> data;

  const EditOrderPage({super.key, required this.orderId, required this.data});

  @override
  State<EditOrderPage> createState() => _EditOrderPageState();
}

class _EditOrderPageState extends State<EditOrderPage> {
  late TextEditingController productController;
  late TextEditingController fromController;
  late TextEditingController toController;
  late TextEditingController phoneController;

  String currentLanguage = 'ky';

  @override
  void initState() {
    super.initState();

    productController = TextEditingController(
      text: widget.data['product'] ?? '',
    );

    fromController = TextEditingController(text: widget.data['from'] ?? '');

    toController = TextEditingController(text: widget.data['to'] ?? '');

    phoneController = TextEditingController(text: widget.data['phone'] ?? '');

    _loadLanguage();
  }

  @override
  void dispose() {
    productController.dispose();
    fromController.dispose();
    toController.dispose();
    phoneController.dispose();

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
      'editOrder': {
        'ky': 'Заказды түзөтүү',
        'ru': 'Редактировать заказ',
        'en': 'Edit Order',
        'ko': '주문 수정',
      },

      'productName': {
        'ky': '📦 Товардын аты',
        'ru': '📦 Название товара',
        'en': '📦 Product name',
        'ko': '📦 상품명',
      },

      'from': {
        'ky': '📍 Кайдан',
        'ru': '📍 Откуда',
        'en': '📍 From',
        'ko': '📍 출발지',
      },

      'to': {'ky': '📍 Кайда', 'ru': '📍 Куда', 'en': '📍 To', 'ko': '📍 도착지'},

      'phone': {
        'ky': '📞 Телефон',
        'ru': '📞 Телефон',
        'en': '📞 Phone',
        'ko': '📞 전화번호',
      },

      'saveChanges': {
        'ky': 'Өзгөртүүлөрдү сактоо',
        'ru': 'Сохранить изменения',
        'en': 'Save Changes',
        'ko': '변경사항 저장',
      },

      'saved': {
        'ky': 'Өзгөртүүлөр сакталды ✅',
        'ru': 'Изменения сохранены ✅',
        'en': 'Changes saved ✅',
        'ko': '변경사항이 저장되었습니다 ✅',
      },

      'saveError': {
        'ky': 'Сактоодо ката',
        'ru': 'Ошибка сохранения',
        'en': 'Save error',
        'ko': '저장 오류',
      },
    };

    return translations[key]?[currentLanguage] ??
        translations[key]?['ky'] ??
        key;
  }

  // =========================================================
  // 💾 SAVE ORDER
  // =========================================================

  Future<void> saveOrder() async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId)
          .update({
            'product': productController.text.trim(),

            'from': fromController.text.trim(),

            'to': toController.text.trim(),

            'phone': phoneController.text.trim(),
          });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t('saved'))));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${t('saveError')}: $e')));
    }
  }

  // =========================================================
  // 🏗️ BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t('editOrder'))),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // 📦 PRODUCT
            TextField(
              controller: productController,

              decoration: InputDecoration(
                labelText: t('productName'),

                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // 📍 FROM
            TextField(
              controller: fromController,

              decoration: InputDecoration(
                labelText: t('from'),

                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // 📍 TO
            TextField(
              controller: toController,

              decoration: InputDecoration(
                labelText: t('to'),

                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            // 📞 PHONE
            TextField(
              controller: phoneController,

              keyboardType: TextInputType.phone,

              decoration: InputDecoration(
                labelText: t('phone'),

                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            // 💾 SAVE
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed: saveOrder,

                icon: const Icon(Icons.save),

                label: Text(
                  t('saveChanges'),

                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
