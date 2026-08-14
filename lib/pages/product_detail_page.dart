import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'buy_product_page.dart';
import 'edit_product_page.dart';

class ProductDetailPage extends StatefulWidget {
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
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  String currentLanguage = 'ky';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

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
      'productDetails': {
        'ky': 'Товар тууралуу',
        'ru': 'О товаре',
        'en': 'Product Details',
        'ko': '상품 정보',
      },
      'selling': {
        'ky': 'Сатууда',
        'ru': 'В продаже',
        'en': 'For sale',
        'ko': '판매 중',
      },
      'description': {
        'ky': 'Сүрөттөмө',
        'ru': 'Описание',
        'en': 'Description',
        'ko': '설명',
      },
      'noDescription': {
        'ky': 'Сүрөттөмө жок',
        'ru': 'Описание отсутствует',
        'en': 'No description',
        'ko': '설명이 없습니다',
      },
      'seller': {
        'ky': 'Сатуучу',
        'ru': 'Продавец',
        'en': 'Seller',
        'ko': '판매자',
      },
      'buy': {'ky': 'Сатып алуу', 'ru': 'Купить', 'en': 'Buy', 'ko': '구매하기'},
      'productManagement': {
        'ky': 'Товарды башкаруу',
        'ru': 'Управление товаром',
        'en': 'Product Management',
        'ko': '상품 관리',
      },
      'editProduct': {
        'ky': 'Товарды өзгөртүү',
        'ru': 'Изменить товар',
        'en': 'Edit Product',
        'ko': '상품 수정',
      },
      'deleteProduct': {
        'ky': 'Товарды өчүрүү',
        'ru': 'Удалить товар',
        'en': 'Delete Product',
        'ko': '상품 삭제',
      },
      'deleteQuestion': {
        'ky': 'Товарды өчүрүү?',
        'ru': 'Удалить товар?',
        'en': 'Delete product?',
        'ko': '상품을 삭제하시겠습니까?',
      },
      'deleteInfo': {
        'ky': 'Бул товар Marketplaceтен өчүрүлөт. Улантасызбы?',
        'ru': 'Этот товар будет удалён из Marketplace. Продолжить?',
        'en': 'This product will be removed from Marketplace. Continue?',
        'ko': '이 상품은 Marketplace에서 삭제됩니다. 계속하시겠습니까?',
      },
      'no': {'ky': 'Жок', 'ru': 'Нет', 'en': 'No', 'ko': '아니요'},
      'yesDelete': {
        'ky': 'Ооба, өчүрүү',
        'ru': 'Да, удалить',
        'en': 'Yes, delete',
        'ko': '예, 삭제',
      },
      'deleted': {
        'ky': 'Товар өчүрүлдү 🗑️',
        'ru': 'Товар удалён 🗑️',
        'en': 'Product deleted 🗑️',
        'ko': '상품이 삭제되었습니다 🗑️',
      },
      'deleteError': {
        'ky': 'Өчүрүүдө ката',
        'ru': 'Ошибка удаления',
        'en': 'Delete error',
        'ko': '삭제 오류',
      },
    };

    return translations[key]?[currentLanguage] ??
        translations[key]?['ky'] ??
        key;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Бул товарды азыр кирген адам сатабы?
    final isSeller = user?.email == widget.sellerEmail;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: false,

        title: Text(
          t('productDetails'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // =================================================
            // 📸 ТОВАРДЫН СҮРӨТҮ
            // =================================================
            Container(
              width: double.infinity,
              height: 300,

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),

              clipBehavior: Clip.antiAlias,

              child: widget.imageBase64.isNotEmpty
                  ? Image.memory(
                      base64Decode(widget.imageBase64),

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

            // =================================================
            // 🏷️ ТОВАРДЫН НЕГИЗГИ МААЛЫМАТЫ
            // =================================================
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
                  Text(
                    widget.title,

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
                        '${widget.price} сом',

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

                        child: Row(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Color(0xFF2E7D32),
                            ),

                            const SizedBox(width: 5),

                            Text(
                              t('selling'),

                              style: const TextStyle(
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

            // =================================================
            // 📝 СҮРӨТТӨМӨ
            // =================================================
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
                      const Icon(
                        Icons.description_outlined,
                        color: Color(0xFF1565C0),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        t('description'),

                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    widget.description.isNotEmpty
                        ? widget.description
                        : t('noDescription'),

                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,

                      color: widget.description.isNotEmpty
                          ? Colors.black87
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // =================================================
            // 👤 САТУУЧУ
            // =================================================
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
                        Text(
                          t('seller'),

                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          widget.sellerEmail,

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

            // =================================================
            // 🛒 САТЫП АЛУУ
            // =================================================
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
                        productId: widget.productId,
                        productTitle: widget.title,
                        price: widget.price,
                        sellerEmail: widget.sellerEmail,
                      ),
                    ),
                  );
                },

                icon: const Icon(Icons.shopping_cart_outlined),

                label: Text(
                  t('buy'),

                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // =================================================
            // 👇 САТУУЧУ ҮЧҮН БӨЛҮК
            // =================================================
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
                    Text(
                      t('productManagement'),

                      style: const TextStyle(
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
                                productId: widget.productId,
                                title: widget.title,
                                price: widget.price,
                                description: widget.description,
                                imageBase64: widget.imageBase64,
                              ),
                            ),
                          );
                        },

                        icon: const Icon(Icons.edit_outlined),

                        label: Text(
                          t('editProduct'),

                          style: const TextStyle(
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
                                title: Text(t('deleteQuestion')),

                                content: Text(t('deleteInfo')),

                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },

                                    child: Text(t('no')),
                                  ),

                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, true);
                                    },

                                    child: Text(
                                      t('yesDelete'),

                                      style: const TextStyle(color: Colors.red),
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
                                .doc(widget.productId)
                                .delete();

                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(t('deleted'))),
                            );

                            Navigator.pop(context);
                          } catch (e) {
                            if (!context.mounted) {
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${t('deleteError')}: $e'),
                              ),
                            );
                          }
                        },

                        icon: const Icon(Icons.delete_outline),

                        label: Text(
                          t('deleteProduct'),

                          style: const TextStyle(
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

  // =========================================================
  // 📸 СҮРӨТ ЖОК БОЛСО
  // =========================================================

  static Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFEFF2F5),

      child: const Center(
        child: Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
      ),
    );
  }
}
