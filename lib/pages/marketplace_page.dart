import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'add_product_page.dart';
import 'product_detail_page.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final searchController = TextEditingController();

  String searchText = '';
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
      'marketplace': {
        'ky': '🛍️ Marketplace',
        'ru': '🛍️ Marketplace',
        'en': '🛍️ Marketplace',
        'ko': '🛍️ Marketplace',
      },

      'searchProduct': {
        'ky': 'Товар издөө...',
        'ru': 'Поиск товара...',
        'en': 'Search product...',
        'ko': '상품 검색...',
      },

      'addProduct': {
        'ky': 'Товар кошуу',
        'ru': 'Добавить товар',
        'en': 'Add Product',
        'ko': '상품 추가',
      },

      'noProducts': {
        'ky': 'Азырынча товарлар жок',
        'ru': 'Пока нет товаров',
        'en': 'No products yet',
        'ko': '아직 상품이 없습니다',
      },

      'noProductFound': {
        'ky': 'Товар табылган жок',
        'ru': 'Товар не найден',
        'en': 'Product not found',
        'ko': '상품을 찾을 수 없습니다',
      },

      'addFirstProduct': {
        'ky': 'Биринчи болуп товар кошуңуз',
        'ru': 'Добавьте первый товар',
        'en': 'Add the first product',
        'ko': '첫 번째 상품을 추가해보세요',
      },

      'tryAnotherSearch': {
        'ky': 'Башка сөз менен кайра издеп көрүңүз',
        'ru': 'Попробуйте поискать по-другому',
        'en': 'Try searching with another word',
        'ko': '다른 단어로 다시 검색해보세요',
      },

      'selling': {
        'ky': 'Сатууда',
        'ru': 'В продаже',
        'en': 'For sale',
        'ko': '판매 중',
      },

      'seller': {
        'ky': 'Сатуучу',
        'ru': 'Продавец',
        'en': 'Seller',
        'ko': '판매자',
      },

      'noName': {
        'ky': 'Аты жок',
        'ru': 'Без названия',
        'en': 'No name',
        'ko': '이름 없음',
      },

      'error': {'ky': 'Ката', 'ru': 'Ошибка', 'en': 'Error', 'ko': '오류'},
    };

    return translations[key]?[currentLanguage] ??
        translations[key]?['ky'] ??
        key;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,

        title: Text(
          t('marketplace'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [
          // =================================================
          // 🔎 ИЗДӨӨ
          // =================================================
          Container(
            color: Colors.white,

            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),

            child: TextField(
              controller: searchController,

              onChanged: (value) {
                setState(() {
                  searchText = value.trim().toLowerCase();
                });
              },

              decoration: InputDecoration(
                hintText: t('searchProduct'),

                prefixIcon: const Icon(Icons.search, color: Color(0xFF1565C0)),

                suffixIcon: searchText.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          searchController.clear();

                          setState(() {
                            searchText = '';
                          });
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,

                filled: true,

                fillColor: const Color(0xFFF5F7FA),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),

                  borderSide: const BorderSide(
                    color: Color(0xFF1565C0),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // =================================================
          // 📦 ТОВАРЛАР
          // =================================================
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('marketplace')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),

                      child: Text(
                        '${t('error')}: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allProducts = snapshot.data?.docs ?? [];

                // 🛒 Сатылбаган товарлар
                final availableProducts = allProducts.where((product) {
                  final data = product.data();

                  return data['sold'] != true;
                }).toList();

                // 🔎 Издөө
                final products = availableProducts.where((product) {
                  final data = product.data();

                  final title = data['title']?.toString().toLowerCase() ?? '';

                  final description =
                      data['description']?.toString().toLowerCase() ?? '';

                  final sellerEmail =
                      data['sellerEmail']?.toString().toLowerCase() ?? '';

                  return title.contains(searchText) ||
                      description.contains(searchText) ||
                      sellerEmail.contains(searchText);
                }).toList();

                if (products.isEmpty) {
                  return _emptySearch();
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),

                  itemCount: products.length,

                  itemBuilder: (context, index) {
                    final product = products[index];

                    final data = product.data();

                    final productId = product.id;

                    final title = data['title']?.toString() ?? t('noName');

                    final price = data['price']?.toString() ?? '0';

                    final description = data['description']?.toString() ?? '';

                    final sellerEmail = data['sellerEmail']?.toString() ?? '';

                    final imageBase64 = data['imageBase64']?.toString() ?? '';

                    return _productCard(
                      context: context,
                      productId: productId,
                      title: title,
                      price: price,
                      description: description,
                      sellerEmail: sellerEmail,
                      imageBase64: imageBase64,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // ➕ Товар кошуу
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1565C0),

        foregroundColor: Colors.white,

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductPage()),
          );
        },

        icon: const Icon(Icons.add),

        label: Text(
          t('addProduct'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // =========================================================
  // 🔎 ТОВАР ТАБЫЛГАН ЖОК
  // =========================================================

  Widget _emptySearch() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 90,
              height: 90,

              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(25),
              ),

              child: Icon(
                searchText.isEmpty ? Icons.storefront : Icons.search_off,

                size: 50,

                color: const Color(0xFF1565C0),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              searchText.isEmpty ? t('noProducts') : t('noProductFound'),

              textAlign: TextAlign.center,

              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              searchText.isEmpty ? t('addFirstProduct') : t('tryAnotherSearch'),

              textAlign: TextAlign.center,

              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // 🛍️ ТОВАР КАРТОЧКАСЫ
  // =========================================================

  Widget _productCard({
    required BuildContext context,
    required String productId,
    required String title,
    required String price,
    required String description,
    required String sellerEmail,
    required String imageBase64,
  }) {
    return Card(
      elevation: 0,

      margin: const EdgeInsets.only(bottom: 16),

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),

      clipBehavior: Clip.antiAlias,

      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailPage(
                productId: productId,
                title: title,
                price: price,
                description: description,
                sellerEmail: sellerEmail,
                imageBase64: imageBase64,
              ),
            ),
          );
        },

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // =================================================
            // 📸 СҮРӨТ
            // =================================================
            SizedBox(
              width: double.infinity,
              height: 210,

              child: imageBase64.isNotEmpty
                  ? Image.memory(
                      base64Decode(imageBase64),

                      fit: BoxFit.cover,

                      errorBuilder: (context, error, stackTrace) {
                        return _imagePlaceholder();
                      },
                    )
                  : _imagePlaceholder(),
            ),

            // =================================================
            // 📦 МААЛЫМАТ
            // =================================================
            Padding(
              padding: const EdgeInsets.all(17),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    maxLines: 2,

                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Text(
                        '$price сом',

                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),

                      const Spacer(),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),

                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),

                          borderRadius: BorderRadius.circular(20),
                        ),

                        child: Text(
                          t('selling'),

                          style: const TextStyle(
                            color: Color(0xFF2E7D32),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  if (description.isNotEmpty)
                    Text(
                      description,

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),

                  const SizedBox(height: 12),

                  const Divider(height: 1),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,

                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),

                          borderRadius: BorderRadius.circular(10),
                        ),

                        child: const Icon(
                          Icons.person_outline,
                          size: 20,
                          color: Color(0xFF1565C0),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              t('seller'),

                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),

                            Text(
                              sellerEmail,

                              maxLines: 1,

                              overflow: TextOverflow.ellipsis,

                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // 📸 СҮРӨТ ЖОК БОЛСО
  // =========================================================

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFEFF2F5),

      child: const Center(
        child: Icon(Icons.shopping_bag_outlined, size: 70, color: Colors.grey),
      ),
    );
  }
}
