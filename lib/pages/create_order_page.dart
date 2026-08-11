import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
        message = 'Заказ ийгиликтүү түзүлдү! 🎉';
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                color: Color(0xFF1565C0),
              ),
              SizedBox(width: 8),
              Text(
                'Төлөм маалыматы',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 15),

          _priceRow('Товардын баасы', '${price.toStringAsFixed(0)} сом'),

          const SizedBox(height: 8),

          _priceRow('Жеткирүү', '${delivery.toStringAsFixed(0)} сом'),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.grey.shade200),
          ),

          Row(
            children: [
              const Text(
                'Жалпы сумма',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
                      child: Text('🇰🇬', style: TextStyle(fontSize: 30)),
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
                          'Кыргызстан → Корея 🇰🇷',
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
              hint: 'Мисалы: Бишкек',
            ),

            const SizedBox(height: 13),

            // =================================================
            // 📍 TO
            // =================================================
            buildField(
              controller: toController,
              label: 'Кайда?',
              icon: Icons.location_searching,
              hint: 'Мисалы: Сеул',
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

            const SizedBox(height: 13),

            // =================================================
            // 💰 PRICE
            // =================================================
            buildField(
              controller: priceController,
              label: 'Баасы (сом)',
              icon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 13),

            // =================================================
            // 🚚 DELIVERY
            // =================================================
            buildField(
              controller: deliveryController,
              label: 'Жеткирүү акысы (сом)',
              icon: Icons.local_shipping_outlined,
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 20),

            // =================================================
            // 📷 IMAGE
            // =================================================
            const Text(
              '📷 Товардын сүрөтү',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add_a_photo_outlined,
                              size: 28,
                              color: Color(0xFF1565C0),
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            'Сүрөт тандоо',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            'Галереядан сүрөт тандаңыз',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
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
