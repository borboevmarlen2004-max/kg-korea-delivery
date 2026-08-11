import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  // =========================================================
  // 📦 ЗАКАЗ ТҮЗҮҮ
  // =========================================================

  Future<void> createOrder() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        message = 'Адегенде аккаунтка кириңиз';
      });
      return;
    }

    if (productController.text.trim().isEmpty ||
        fromController.text.trim().isEmpty ||
        toController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      setState(() {
        message = 'Бардык талааларды толтуруңуз';
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
        message = 'Заказ ийгиликтүү түзүлдү! 🎉';
      });

      productController.clear();
      fromController.clear();
      toController.clear();
      phoneController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заказ ийгиликтүү түзүлдү! 🎉')),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        message = 'Ката: $e';
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

        title: const Text(
          '📦 Заказ түзүү',
          style: TextStyle(fontWeight: FontWeight.bold),
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
                    color: const Color(0xFF1565C0).withOpacity(0.18),
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
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),

                    child: const Center(
                      child: Text('🇰🇷', style: TextStyle(fontSize: 30)),
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Жеткирүү багыты',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),

                        SizedBox(height: 4),

                        Text(
                          'Корея → Кыргызстан 🇰🇬',
                          style: TextStyle(
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

            const Text(
              '📦 Заказ маалыматы',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            // =================================================
            // 📦 PRODUCT
            // =================================================
            buildField(
              controller: productController,
              label: 'Товардын аты',
              icon: Icons.inventory_2_outlined,
              hint: 'Мисалы: Телефон',
            ),

            const SizedBox(height: 13),

            // =================================================
            // 📍 FROM
            // =================================================
            buildField(
              controller: fromController,
              label: 'Кайдан?',
              icon: Icons.location_on_outlined,
              hint: 'Мисалы: Сеул',
            ),

            const SizedBox(height: 13),

            // =================================================
            // 📍 TO
            // =================================================
            buildField(
              controller: toController,
              label: 'Кайда?',
              icon: Icons.location_searching,
              hint: 'Мисалы: Бишкек',
            ),

            const SizedBox(height: 13),

            // =================================================
            // 📞 PHONE
            // =================================================
            buildField(
              controller: phoneController,
              label: 'Телефон',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              hint: 'Мисалы: +996...',
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

              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF1565C0)),

                  SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      'Маалыматтарды туура толтуруңуз. '
                      'Заказ түзүлгөндөн кийин аны '
                      '«Менин заказдарым» бөлүмүнөн көрө аласыз.',
                      style: TextStyle(
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
                  isCreating ? 'Заказ түзүлүүдө...' : 'Заказ түзүү',
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
                  color: message.startsWith('Ката')
                      ? Colors.red.withOpacity(0.08)
                      : Colors.green.withOpacity(0.08),

                  borderRadius: BorderRadius.circular(15),
                ),

                child: Text(
                  message,
                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: message.startsWith('Ката')
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
