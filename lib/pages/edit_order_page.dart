import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  @override
  void initState() {
    super.initState();

    productController = TextEditingController(
      text: widget.data['product'] ?? '',
    );

    fromController = TextEditingController(text: widget.data['from'] ?? '');

    toController = TextEditingController(text: widget.data['to'] ?? '');

    phoneController = TextEditingController(text: widget.data['phone'] ?? '');
  }

  @override
  void dispose() {
    productController.dispose();
    fromController.dispose();
    toController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> saveOrder() async {
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

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Заказды түзөтүү')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: productController,
              decoration: const InputDecoration(
                labelText: '📦 Товардын аты',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: fromController,
              decoration: const InputDecoration(
                labelText: '📍 Кайдан',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: toController,
              decoration: const InputDecoration(
                labelText: '📍 Кайда',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: '📞 Телефон',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: saveOrder,
                icon: const Icon(Icons.save),
                label: const Text(
                  'Өзгөртүүлөрдү сактоо',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
