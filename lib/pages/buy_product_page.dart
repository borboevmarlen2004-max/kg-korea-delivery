import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BuyProductPage extends StatefulWidget {
  final String productId;
  final String productTitle;
  final String price;
  final String sellerEmail;

  const BuyProductPage({
    super.key,
    required this.productId,
    required this.productTitle,
    required this.price,
    required this.sellerEmail,
  });

  @override
  State<BuyProductPage> createState() => _BuyProductPageState();
}

class _BuyProductPageState extends State<BuyProductPage> {
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final phoneController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> createOrder() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Адегенде аккаунтка кириңиз')),
      );
      return;
    }

    final from = fromController.text.trim();
    final to = toController.text.trim();
    final phone = phoneController.text.trim();

    if (from.isEmpty || to.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Бардык талааларды толтуруңуз')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final priceValue = double.tryParse(widget.price) ?? 0;

      final orderNumber = 'MKT${DateTime.now().millisecondsSinceEpoch}';

      // 🔒 Бир эле товарды эки адам сатып алып
      // кетпеши үчүн transaction колдонулат.
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final productRef = FirebaseFirestore.instance
            .collection('marketplace')
            .doc(widget.productId);

        final productSnapshot = await transaction.get(productRef);

        if (!productSnapshot.exists) {
          throw Exception('Бул товар табылган жок.');
        }

        final productData = productSnapshot.data() as Map<String, dynamic>;

        // 🛑 Товар мурда сатылып кеткенби?
        if (productData['sold'] == true) {
          throw Exception('Бул товар буга чейин сатылып кеткен.');
        }

        // 🛒 Заказ түзөбүз
        final orderRef = FirebaseFirestore.instance.collection('orders').doc();

        transaction.set(orderRef, {
          'orderNumber': orderNumber,
          'userId': user.uid,
          'email': user.email,
          'direction': 'Marketplace',
          'product': widget.productTitle,
          'from': from,
          'to': to,
          'phone': phone,
          'price': priceValue,
          'deliveryFee': 0,
          'totalPrice': priceValue,
          'status': 'Жаңы заказ',
          'paymentStatus': 'Төлөнө элек',
          'paymentMethod': 'Карта',

          // 👤 Сатуучу
          'sellerEmail': widget.sellerEmail,

          // 🛍️ Marketplace товар ID
          'marketplaceProductId': widget.productId,

          'createdAt': FieldValue.serverTimestamp(),
        });

        // ✅ Товарды сатылды деп белгилейбиз
        transaction.update(productRef, {
          'sold': true,
          'soldAt': FieldValue.serverTimestamp(),
          'soldTo': user.email,
        });
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заказ ийгиликтүү түзүлдү! 🎉')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Сатып алууда ката: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
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
          '🛒 Сатып алуу',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🛍️ ТОВАР МААЛЫМАТЫ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,

                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(15),
                        ),

                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Color(0xFF1565C0),
                          size: 28,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Text(
                          widget.productTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  const Divider(),

                  const SizedBox(height: 12),

                  // 💰 Баасы
                  Row(
                    children: [
                      const Text(
                        'Баасы',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),

                      const Spacer(),

                      Text(
                        '${widget.price} сом',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 👤 Сатуучу
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 20,
                        color: Colors.grey,
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          widget.sellerEmail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 📦 ЖЕТКИРҮҮ МААЛЫМАТЫ
            const Text(
              'Жеткирүү маалыматы',
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
                  // 📍 Кайдан
                  _buildTextField(
                    controller: fromController,
                    label: 'Кайдан',
                    hint: 'Мисалы: Бишкек',
                    icon: Icons.location_on_outlined,
                  ),

                  const SizedBox(height: 15),

                  // 📍 Кайда
                  _buildTextField(
                    controller: toController,
                    label: 'Кайда',
                    hint: 'Мисалы: Сеул',
                    icon: Icons.location_searching,
                  ),

                  const SizedBox(height: 15),

                  // 📞 Телефон
                  _buildTextField(
                    controller: phoneController,
                    label: 'Телефон',
                    hint: '+996 ...',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 💳 ТӨЛӨМ
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),

              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,

                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(13),
                    ),

                    child: const Icon(
                      Icons.credit_card,
                      color: Color(0xFF2E7D32),
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Төлөм',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Карта аркылуу',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                  Text(
                    '${widget.price} сом',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 🛒 ЗАКАЗ БЕРҮҮ
            SizedBox(
              width: double.infinity,
              height: 58,

              child: ElevatedButton.icon(
                onPressed: isLoading ? null : createOrder,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),

                icon: isLoading
                    ? const SizedBox(
                        width: 21,
                        height: 21,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.shopping_cart_outlined),

                label: Text(
                  isLoading ? 'Заказ түзүлүүдө...' : 'Заказ берүү',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Center(
              child: Text(
                'Заказ берилгенден кийин товар сатылды деп белгиленет.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
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
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,

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
