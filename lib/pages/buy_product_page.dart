import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  String currentLanguage = 'ky';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  @override
  void dispose() {
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
      'buyProduct': {
        'ky': '🛒 Сатып алуу',
        'ru': '🛒 Покупка',
        'en': '🛒 Purchase',
        'ko': '🛒 구매',
      },

      'loginFirst': {
        'ky': 'Адегенде аккаунтка кириңиз',
        'ru': 'Сначала войдите в аккаунт',
        'en': 'Please log in first',
        'ko': '먼저 로그인해주세요',
      },

      'fillAllFields': {
        'ky': 'Бардык талааларды толтуруңуз',
        'ru': 'Заполните все поля',
        'en': 'Fill in all fields',
        'ko': '모든 항목을 입력해주세요',
      },

      'productNotFound': {
        'ky': 'Бул товар табылган жок.',
        'ru': 'Этот товар не найден.',
        'en': 'This product was not found.',
        'ko': '이 상품을 찾을 수 없습니다.',
      },

      'alreadySold': {
        'ky': 'Бул товар буга чейин сатылып кеткен.',
        'ru': 'Этот товар уже продан.',
        'en': 'This product has already been sold.',
        'ko': '이 상품은 이미 판매되었습니다.',
      },

      'orderCreated': {
        'ky': 'Заказ ийгиликтүү түзүлдү! 🎉',
        'ru': 'Заказ успешно создан! 🎉',
        'en': 'Order created successfully! 🎉',
        'ko': '주문이 성공적으로 생성되었습니다! 🎉',
      },

      'purchaseError': {
        'ky': 'Сатып алууда ката',
        'ru': 'Ошибка при покупке',
        'en': 'Purchase error',
        'ko': '구매 오류',
      },

      'price': {'ky': 'Баасы', 'ru': 'Цена', 'en': 'Price', 'ko': '가격'},

      'seller': {
        'ky': 'Сатуучу',
        'ru': 'Продавец',
        'en': 'Seller',
        'ko': '판매자',
      },

      'deliveryInfo': {
        'ky': 'Жеткирүү маалыматы',
        'ru': 'Информация о доставке',
        'en': 'Delivery Information',
        'ko': '배송 정보',
      },

      'from': {'ky': 'Кайдан', 'ru': 'Откуда', 'en': 'From', 'ko': '출발지'},

      'fromHint': {
        'ky': 'Мисалы: Бишкек',
        'ru': 'Например: Бишкек',
        'en': 'Example: Bishkek',
        'ko': '예: Bishkek',
      },

      'to': {'ky': 'Кайда', 'ru': 'Куда', 'en': 'To', 'ko': '도착지'},

      'toHint': {
        'ky': 'Мисалы: Сеул',
        'ru': 'Например: Сеул',
        'en': 'Example: Seoul',
        'ko': '예: Seoul',
      },

      'phone': {'ky': 'Телефон', 'ru': 'Телефон', 'en': 'Phone', 'ko': '전화번호'},

      'payment': {'ky': 'Төлөм', 'ru': 'Оплата', 'en': 'Payment', 'ko': '결제'},

      'byCard': {
        'ky': 'Карта аркылуу',
        'ru': 'Картой',
        'en': 'By card',
        'ko': '카드 결제',
      },

      'creatingOrder': {
        'ky': 'Заказ түзүлүүдө...',
        'ru': 'Создание заказа...',
        'en': 'Creating order...',
        'ko': '주문 생성 중...',
      },

      'placeOrder': {
        'ky': 'Заказ берүү',
        'ru': 'Оформить заказ',
        'en': 'Place Order',
        'ko': '주문하기',
      },

      'soldAfterOrder': {
        'ky': 'Заказ берилгенден кийин товар сатылды деп белгиленет.',
        'ru': 'После оформления заказа товар будет отмечен как проданный.',
        'en': 'After placing the order, the product will be marked as sold.',
        'ko': '주문 후 상품은 판매 완료로 표시됩니다.',
      },
    };

    return translations[key]?[currentLanguage] ??
        translations[key]?['ky'] ??
        key;
  }

  // =========================================================
  // 🛒 ЗАКАЗ ТҮЗҮҮ
  // =========================================================

  Future<void> createOrder() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t('loginFirst'))));

      return;
    }

    final from = fromController.text.trim();
    final to = toController.text.trim();
    final phone = phoneController.text.trim();

    if (from.isEmpty || to.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t('fillAllFields'))));

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final priceValue = double.tryParse(widget.price) ?? 0;

      final orderNumber = 'MKT${DateTime.now().millisecondsSinceEpoch}';

      // 🔒 Бир эле товарды эки адам сатып албашы үчүн
      // transaction колдонулат.
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final productRef = FirebaseFirestore.instance
            .collection('marketplace')
            .doc(widget.productId);

        final productSnapshot = await transaction.get(productRef);

        if (!productSnapshot.exists) {
          throw Exception(t('productNotFound'));
        }

        final productData = productSnapshot.data() as Map<String, dynamic>;

        // 🛑 Товар мурда сатылып кеткенби?
        if (productData['sold'] == true) {
          throw Exception(t('alreadySold'));
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t('orderCreated'))));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${t('purchaseError')}: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
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
          t('buyProduct'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // =================================================
            // 🛍️ ТОВАР МААЛЫМАТЫ
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
                      Text(
                        t('price'),

                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
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

            // =================================================
            // 📦 ЖЕТКИРҮҮ МААЛЫМАТЫ
            // =================================================
            Text(
              t('deliveryInfo'),

              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    label: t('from'),
                    hint: t('fromHint'),
                    icon: Icons.location_on_outlined,
                  ),

                  const SizedBox(height: 15),

                  // 📍 Кайда
                  _buildTextField(
                    controller: toController,
                    label: t('to'),
                    hint: t('toHint'),
                    icon: Icons.location_searching,
                  ),

                  const SizedBox(height: 15),

                  // 📞 Телефон
                  _buildTextField(
                    controller: phoneController,
                    label: t('phone'),
                    hint: '+996 ...',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =================================================
            // 💳 ТӨЛӨМ
            // =================================================
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

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          t('payment'),

                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          t('byCard'),

                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
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

            // =================================================
            // 🛒 ЗАКАЗ БЕРҮҮ
            // =================================================
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
                  isLoading ? t('creatingOrder') : t('placeOrder'),

                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: Text(
                t('soldAfterOrder'),

                textAlign: TextAlign.center,

                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // ✏️ TEXT FIELD
  // =========================================================

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
