import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'buy_product_page.dart';
import 'edit_product_page.dart';

class ProductDetailPage extends StatelessWidget {
  final String productId;
  final String title;
  final String price;
  final String description;
  final String sellerEmail;
  final String imageBase64;

  const ProductDetailPage({
    super.key,
    required this.title,
    required this.price,
    required this.description,
    required this.sellerEmail,
    required this.productId,
    required this.imageBase64,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Бул товарды азыр кирген адам сатабы?
    final isSeller = user?.email == sellerEmail;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Товар тууралуу',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📸 ТОВАРДЫН СҮРӨТҮ
            Container(
              width: double.infinity,
              height: 300,

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),

              clipBehavior: Clip.antiAlias,

              child: imageBase64.isNotEmpty
                  ? Image.memory(
                      base64Decode(imageBase64),
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,

                      errorBuilder: (context, error, stackTrace) {
                        return _imagePlaceholder();
                      },
                    )
                  : _imagePlaceholder(),
            ),

            const SizedBox(height: 22),

            // 🏷️ ТОВАРДЫН НЕГИЗГИ МААЛЫМАТЫ
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
                  // Товар аты
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 💰 Баа + Сатууда
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,

                    children: [
                      Text(
                        '$price сом',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),

                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),

                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Color(0xFF2E7D32),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Сатууда',
                              style: TextStyle(
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 📝 СҮРӨТТӨМӨ
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
                  const Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        color: Color(0xFF1565C0),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Сүрөттөмө',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    description.isNotEmpty ? description : 'Сүрөттөмө жок',

                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: description.isNotEmpty
                          ? Colors.black87
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 👤 САТУУЧУ
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),

              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,

                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: const Icon(
                      Icons.person,
                      color: Color(0xFF1565C0),
                      size: 25,
                    ),
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Text(
                          'Сатуучу',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          sellerEmail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 🛒 САТЫП АЛУУ
            SizedBox(
              width: double.infinity,
              height: 58,

              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),
                  foregroundColor: Colors.white,

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),

                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BuyProductPage(
                        productId: productId,
                        productTitle: title,
                        price: price,
                        sellerEmail: sellerEmail,
                      ),
                    ),
                  );
                },

                icon: const Icon(Icons.shopping_cart_outlined),

                label: const Text(
                  'Сатып алуу',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // 👇 САТУУЧУ ҮЧҮН БӨЛҮК
            if (isSeller) ...[
              const SizedBox(height: 24),

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Товарды башкаруу',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // ✏️ ӨЗГӨРТҮҮ
                    SizedBox(
                      width: double.infinity,
                      height: 52,

                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE3F2FD),
                          foregroundColor: const Color(0xFF1565C0),
                          elevation: 0,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),

                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProductPage(
                                productId: productId,
                                title: title,
                                price: price,
                                description: description,
                                imageBase64: imageBase64,
                              ),
                            ),
                          );
                        },

                        icon: const Icon(Icons.edit_outlined),

                        label: const Text(
                          'Товарды өзгөртүү',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 🗑️ ӨЧҮРҮҮ
                    SizedBox(
                      width: double.infinity,
                      height: 52,

                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),

                        onPressed: () async {
                          final shouldDelete = await showDialog<bool>(
                            context: context,

                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Товарды өчүрүү?'),

                                content: const Text(
                                  'Бул товар Marketplaceтен өчүрүлөт. Улантасызбы?',
                                ),

                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },

                                    child: const Text('Жок'),
                                  ),

                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },

                                    child: const Text(
                                      'Ооба, өчүрүү',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );

                          if (shouldDelete != true) {
                            return;
                          }

                          try {
                            await FirebaseFirestore.instance
                                .collection('marketplace')
                                .doc(productId)
                                .delete();

                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Товар өчүрүлдү 🗑️'),
                              ),
                            );

                            Navigator.pop(context);
                          } catch (e) {
                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Өчүрүүдө ката: $e')),
                            );
                          }
                        },

                        icon: const Icon(Icons.delete_outline),

                        label: const Text(
                          'Товарды өчүрүү',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 📸 Сүрөт жок болсо
  static Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFEFF2F5),

      child: const Center(
        child: Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
      ),
    );
  }
}
