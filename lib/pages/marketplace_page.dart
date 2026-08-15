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

  // Фильтрлер
  String selectedCategory = 'all';
  String selectedCountry = 'all';

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

      'all': {'ky': 'Баары', 'ru': 'Все', 'en': 'All', 'ko': '전체'},

      'category': {
        'ky': 'Категория',
        'ru': 'Категория',
        'en': 'Category',
        'ko': '카테고리',
      },

      'country': {'ky': 'Өлкө', 'ru': 'Страна', 'en': 'Country', 'ko': '국가'},

      'promoted': {
        'ky': '🔥 Жарнамаланган',
        'ru': '🔥 Рекламируемые',
        'en': '🔥 Promoted',
        'ko': '🔥 추천 상품',
      },

      'newProducts': {
        'ky': '🆕 Жаңы товарлар',
        'ru': '🆕 Новые товары',
        'en': '🆕 New products',
        'ko': '🆕 새 상품',
      },

      'kg': {
        'ky': '🇰🇬 Кыргызстан',
        'ru': '🇰🇬 Кыргызстан',
        'en': '🇰🇬 Kyrgyzstan',
        'ko': '🇰🇬 키르기스스탄',
      },

      'kr': {
        'ky': '🇰🇷 Корея',
        'ru': '🇰🇷 Корея',
        'en': '🇰🇷 Korea',
        'ko': '🇰🇷 한국',
      },

      'electronics': {
        'ky': 'Электроника',
        'ru': 'Электроника',
        'en': 'Electronics',
        'ko': '전자제품',
      },

      'clothes': {'ky': 'Кийим', 'ru': 'Одежда', 'en': 'Clothes', 'ko': '의류'},

      'phones': {
        'ky': 'Телефон',
        'ru': 'Телефоны',
        'en': 'Phones',
        'ko': '휴대폰',
      },

      'home': {
        'ky': 'Үй буюмдары',
        'ru': 'Для дома',
        'en': 'Home',
        'ko': '생활용품',
      },

      'cosmetics': {
        'ky': 'Косметика',
        'ru': 'Косметика',
        'en': 'Cosmetics',
        'ko': '화장품',
      },

      'other': {'ky': 'Башка', 'ru': 'Другое', 'en': 'Other', 'ko': '기타'},
    };

    return translations[key]?[currentLanguage] ??
        translations[key]?['ky'] ??
        key;
  }

  // =========================================================
  // 🏷️ CATEGORY NAME
  // =========================================================

  String categoryName(String category) {
    switch (category) {
      case 'electronics':
        return t('electronics');

      case 'clothes':
        return t('clothes');

      case 'phones':
        return t('phones');

      case 'home':
        return t('home');

      case 'cosmetics':
        return t('cosmetics');

      case 'other':
        return t('other');

      default:
        return t('all');
    }
  }

  // =========================================================
  // 💰 PRICE
  // =========================================================

  String priceText(Map<String, dynamic> data) {
    final price = data['price']?.toString() ?? '0';

    final currency = data['currency']?.toString().toLowerCase() ?? 'kgs';

    if (currency == 'krw' || currency == 'won' || currency == '₩') {
      return '₩$price';
    }

    return '$price сом';
  }

  // =========================================================
  // 🌍 COUNTRY
  // =========================================================

  String countryName(String country) {
    final value = country.toLowerCase();

    if (value == 'korea' ||
        value == 'kr' ||
        value == 'корея' ||
        value == '한국') {
      return t('kr');
    }

    if (value == 'kyrgyzstan' ||
        value == 'kg' ||
        value == 'кыргызстан' ||
        value == 'кыргыз') {
      return t('kg');
    }

    return country;
  }

  // =========================================================
  // 🧹 DISPOSE
  // =========================================================

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // =========================================================
  // 🏠 BUILD
  // =========================================================

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
          // 🔎 SEARCH
          // =================================================
          Container(
            color: Colors.white,

            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),

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
          // 🏷️ CATEGORY
          // =================================================
          Container(
            color: Colors.white,

            height: 58,

            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 10),

            child: ListView(
              scrollDirection: Axis.horizontal,

              children: [
                _categoryChip(value: 'all', icon: Icons.apps, label: t('all')),

                _categoryChip(
                  value: 'phones',
                  icon: Icons.phone_android,
                  label: t('phones'),
                ),

                _categoryChip(
                  value: 'electronics',
                  icon: Icons.devices,
                  label: t('electronics'),
                ),

                _categoryChip(
                  value: 'clothes',
                  icon: Icons.checkroom,
                  label: t('clothes'),
                ),

                _categoryChip(
                  value: 'home',
                  icon: Icons.home_outlined,
                  label: t('home'),
                ),

                _categoryChip(
                  value: 'cosmetics',
                  icon: Icons.face,
                  label: t('cosmetics'),
                ),

                _categoryChip(
                  value: 'other',
                  icon: Icons.more_horiz,
                  label: t('other'),
                ),
              ],
            ),
          ),

          // =================================================
          // 🌍 COUNTRY FILTER
          // =================================================
          Container(
            color: Colors.white,

            height: 55,

            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),

            child: Row(
              children: [
                Expanded(
                  child: _countryButton(
                    value: 'all',
                    label: t('all'),
                    icon: Icons.public,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _countryButton(
                    value: 'kg',
                    label: t('kg'),
                    icon: Icons.flag_outlined,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _countryButton(
                    value: 'kr',
                    label: t('kr'),
                    icon: Icons.flag_outlined,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // =================================================
          // 🔥 / 🆕 FILTER INFO
          // =================================================
          Container(
            color: Colors.white,

            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),

            child: Row(
              children: [
                const Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                  size: 20,
                ),

                const SizedBox(width: 7),

                Text(
                  t('promoted'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                Text(
                  t('newProducts'),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),

          // =================================================
          // 📦 FIRESTORE PRODUCTS
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

                // =================================================
                // 🛒 САТЫЛБАГАН ТОВАРЛАР
                // =================================================

                final availableProducts = allProducts.where((product) {
                  final data = product.data();

                  return data['sold'] != true;
                }).toList();

                // =================================================
                // 🔎 SEARCH + CATEGORY + COUNTRY
                // =================================================

                final products = availableProducts.where((product) {
                  final data = product.data();

                  final title = data['title']?.toString().toLowerCase() ?? '';

                  final description =
                      data['description']?.toString().toLowerCase() ?? '';

                  final sellerEmail =
                      data['sellerEmail']?.toString().toLowerCase() ?? '';

                  final category =
                      data['category']?.toString().toLowerCase() ?? '';

                  final country =
                      data['country']?.toString().toLowerCase() ?? '';

                  // 🔎 Search
                  final matchesSearch =
                      searchText.isEmpty ||
                      title.contains(searchText) ||
                      description.contains(searchText) ||
                      sellerEmail.contains(searchText);

                  // 🏷️ Category
                  final matchesCategory =
                      selectedCategory == 'all' || category == selectedCategory;

                  // 🌍 Country
                  bool matchesCountry = true;

                  if (selectedCountry != 'all') {
                    if (selectedCountry == 'kg') {
                      matchesCountry =
                          country == 'kg' ||
                          country == 'kyrgyzstan' ||
                          country == 'кыргызстан' ||
                          country == 'кыргыз';
                    }

                    if (selectedCountry == 'kr') {
                      matchesCountry =
                          country == 'kr' ||
                          country == 'korea' ||
                          country == 'корея' ||
                          country == '한국';
                    }
                  }

                  return matchesSearch && matchesCategory && matchesCountry;
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

                    final description = data['description']?.toString() ?? '';

                    final sellerEmail = data['sellerEmail']?.toString() ?? '';

                    final imageBase64 = data['imageBase64']?.toString() ?? '';

                    final price = priceText(data);

                    final country = data['country']?.toString() ?? '';

                    final category = data['category']?.toString() ?? '';

                    final promoted = data['isPromoted'] == true;

                    return _productCard(
                      context: context,
                      productId: productId,
                      title: title,
                      price: price,
                      description: description,
                      sellerEmail: sellerEmail,
                      imageBase64: imageBase64,
                      country: country,
                      category: category,
                      promoted: promoted,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // =====================================================
      // ➕ ADD PRODUCT
      // =====================================================
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
  // 🏷️ CATEGORY CHIP
  // =========================================================

  Widget _categoryChip({
    required String value,
    required IconData icon,
    required String label,
  }) {
    final selected = selectedCategory == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),

      child: ChoiceChip(
        selected: selected,

        onSelected: (_) {
          setState(() {
            selectedCategory = value;
          });
        },

        avatar: Icon(
          icon,
          size: 18,
          color: selected ? Colors.white : const Color(0xFF1565C0),
        ),

        label: Text(label),

        selectedColor: const Color(0xFF1565C0),

        backgroundColor: const Color(0xFFF5F7FA),

        labelStyle: TextStyle(
          color: selected ? Colors.white : Colors.black87,

          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),

        side: BorderSide(
          color: selected ? const Color(0xFF1565C0) : Colors.transparent,
        ),
      ),
    );
  }

  // =========================================================
  // 🌍 COUNTRY BUTTON
  // =========================================================

  Widget _countryButton({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final selected = selectedCountry == value;

    return InkWell(
      borderRadius: BorderRadius.circular(14),

      onTap: () {
        setState(() {
          selectedCountry = value;
        });
      },

      child: Container(
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE3F2FD) : const Color(0xFFF5F7FA),

          borderRadius: BorderRadius.circular(14),

          border: Border.all(
            color: selected ? const Color(0xFF1565C0) : Colors.transparent,
          ),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(
              icon,
              size: 17,
              color: selected ? const Color(0xFF1565C0) : Colors.grey,
            ),

            const SizedBox(width: 5),

            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,

                style: TextStyle(
                  fontSize: 12,

                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,

                  color: selected ? const Color(0xFF1565C0) : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // 🔎 EMPTY
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
  // 🛍️ PRODUCT CARD
  // =========================================================

  Widget _productCard({
    required BuildContext context,
    required String productId,
    required String title,
    required String price,
    required String description,
    required String sellerEmail,
    required String imageBase64,
    required String country,
    required String category,
    required bool promoted,
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
            // 📸 IMAGE
            // =================================================
            Stack(
              children: [
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

                // 🔥 PROMOTED
                if (promoted)
                  Positioned(
                    top: 12,
                    left: 12,

                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.orange,

                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: const Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: 16,
                          ),

                          SizedBox(width: 4),

                          Text(
                            'PROMOTED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // =================================================
            // 📦 INFORMATION
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

                  // 💰 PRICE
                  Row(
                    children: [
                      Text(
                        price,

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

                  // 🌍 COUNTRY + CATEGORY
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,

                    children: [
                      if (country.isNotEmpty)
                        _infoTag(
                          icon: Icons.location_on_outlined,
                          text: countryName(country),
                        ),

                      if (category.isNotEmpty)
                        _infoTag(
                          icon: Icons.category_outlined,
                          text: categoryName(category),
                        ),
                    ],
                  ),

                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 12),

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
                  ],

                  const SizedBox(height: 12),

                  const Divider(height: 1),

                  const SizedBox(height: 12),

                  // =================================================
                  // 👤 SELLER
                  // =================================================
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
  // 🏷️ INFO TAG
  // =========================================================

  Widget _infoTag({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),

      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),

        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(icon, size: 15, color: const Color(0xFF1565C0)),

          const SizedBox(width: 4),

          Text(
            text,

            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // 📸 IMAGE PLACEHOLDER
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
