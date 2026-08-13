import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'order_details_page.dart';

class AdminSearchPage extends StatefulWidget {
  const AdminSearchPage({super.key});

  @override
  State<AdminSearchPage> createState() => _AdminSearchPageState();
}

class _AdminSearchPageState extends State<AdminSearchPage> {
  final TextEditingController searchController = TextEditingController();

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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // =========================================================
  // 🌍 TRANSLATIONS
  // =========================================================

  String t(String key) {
    const values = <String, Map<String, String>>{
      'searchOrder': {
        'ky': '🔍 Заказ издөө',
        'ru': '🔍 Поиск заказа',
        'en': '🔍 Search order',
        'ko': '🔍 주문 검색',
      },
      'findOrders': {
        'ky': 'Заказдарды табуу',
        'ru': 'Поиск заказов',
        'en': 'Find orders',
        'ko': '주문 찾기',
      },
      'searchDescription': {
        'ky': 'Заказ №, телефон же Email аркылуу издеңиз',
        'ru': 'Ищите по номеру заказа, телефону или Email',
        'en': 'Search by order number, phone or Email',
        'ko': '주문번호, 전화번호 또는 Email로 검색하세요',
      },
      'searchHint': {
        'ky': 'Заказ №, телефон же Email...',
        'ru': 'Номер заказа, телефон или Email...',
        'en': 'Order number, phone or Email...',
        'ko': '주문번호, 전화번호 또는 Email...',
      },
      'error': {'ky': 'Ката', 'ru': 'Ошибка', 'en': 'Error', 'ko': '오류'},
      'ordersFound': {
        'ky': 'заказ табылды',
        'ru': 'заказов найдено',
        'en': 'orders found',
        'ko': '개의 주문을 찾았습니다',
      },
      'phone': {'ky': 'Телефон', 'ru': 'Телефон', 'en': 'Phone', 'ko': '전화번호'},
      'email': {'ky': 'Email', 'ru': 'Email', 'en': 'Email', 'ko': 'Email'},
      'direction': {
        'ky': 'Багыт',
        'ru': 'Направление',
        'en': 'Direction',
        'ko': '방향',
      },
      'total': {
        'ky': 'Жалпы сумма',
        'ru': 'Общая сумма',
        'en': 'Total amount',
        'ko': '총 금액',
      },
      'details': {
        'ky': 'Толук маалымат',
        'ru': 'Подробнее',
        'en': 'Details',
        'ko': '상세 정보',
      },
      'order': {'ky': 'Заказ', 'ru': 'Заказ', 'en': 'Order', 'ko': '주문'},
      'productNotSpecified': {
        'ky': 'Товар көрсөтүлгөн эмес',
        'ru': 'Товар не указан',
        'en': 'Product not specified',
        'ko': '상품이 지정되지 않았습니다',
      },
      'phoneNotFound': {
        'ky': 'Телефон жок',
        'ru': 'Телефон отсутствует',
        'en': 'Phone not found',
        'ko': '전화번호 없음',
      },
      'emailNotFound': {
        'ky': 'Email жок',
        'ru': 'Email отсутствует',
        'en': 'Email not found',
        'ko': 'Email 없음',
      },
      'noOrders': {
        'ky': 'Заказдар жок',
        'ru': 'Заказов нет',
        'en': 'No orders',
        'ko': '주문이 없습니다',
      },
      'orderNotFound': {
        'ky': 'Заказ табылган жок',
        'ru': 'Заказ не найден',
        'en': 'Order not found',
        'ko': '주문을 찾을 수 없습니다',
      },
      'checkSearch': {
        'ky': 'Издөө сөзүңүздү же маалыматты текшерип көрүңүз.',
        'ru': 'Проверьте поисковый запрос или введённые данные.',
        'en': 'Please check your search term or information.',
        'ko': '검색어 또는 입력한 정보를 확인해 주세요.',
      },
      'noOrdersYet': {
        'ky': 'Азырынча заказдар жок.',
        'ru': 'Пока заказов нет.',
        'en': 'There are no orders yet.',
        'ko': '아직 주문이 없습니다.',
      },
      'newOrder': {
        'ky': 'Жаңы заказ',
        'ru': 'Новый заказ',
        'en': 'New order',
        'ko': '새 주문',
      },
      'accepted': {
        'ky': 'Кабыл алынды',
        'ru': 'Принят',
        'en': 'Accepted',
        'ko': '접수됨',
      },
      'preparing': {
        'ky': 'Даярдалууда',
        'ru': 'Подготавливается',
        'en': 'Preparing',
        'ko': '준비 중',
      },
      'onWay': {
        'ky': 'Жолдо',
        'ru': 'В пути',
        'en': 'On the way',
        'ko': '배송 중',
      },
      'delivered': {
        'ky': 'Жеткирилди',
        'ru': 'Доставлен',
        'en': 'Delivered',
        'ko': '배송 완료',
      },
      'cancelled': {
        'ky': 'Жокко чыгарылды',
        'ru': 'Отменён',
        'en': 'Cancelled',
        'ko': '취소됨',
      },
    };

    return values[key]?[currentLanguage] ?? values[key]?['ky'] ?? key;
  }

  // =========================================================
  // 🌍 TRANSLATE STATUS
  // =========================================================

  String translateStatus(String status) {
    switch (status) {
      case 'Жаңы заказ':
        return t('newOrder');

      case 'Кабыл алынды':
        return t('accepted');

      case 'Даярдалууда':
        return t('preparing');

      case 'Жолдо':
        return t('onWay');

      case 'Жеткирилди':
        return t('delivered');

      case 'Жокко чыгарылды':
        return t('cancelled');

      default:
        return status;
    }
  }

  // =========================================================
  // 🎨 STATUS COLOR
  // =========================================================

  Color getStatusColor(String status) {
    switch (status) {
      case 'Жаңы заказ':
        return Colors.orange;

      case 'Кабыл алынды':
        return Colors.blue;

      case 'Даярдалууда':
        return Colors.amber.shade800;

      case 'Жолдо':
        return Colors.deepOrange;

      case 'Жеткирилди':
        return Colors.green;

      case 'Жокко чыгарылды':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  // =========================================================
  // 🎯 STATUS ICON
  // =========================================================

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'Жаңы заказ':
        return Icons.fiber_new;

      case 'Кабыл алынды':
        return Icons.check_circle_outline;

      case 'Даярдалууда':
        return Icons.inventory_2_outlined;

      case 'Жолдо':
        return Icons.local_shipping_outlined;

      case 'Жеткирилди':
        return Icons.done_all;

      case 'Жокко чыгарылды':
        return Icons.cancel_outlined;

      default:
        return Icons.info_outline;
    }
  }

  // =========================================================
  // 🔄 TRANSLATE DIRECTION
  // =========================================================

  String translateDirection(String direction) {
    switch (direction) {
      case 'Кыргызстан → Корея':
        switch (currentLanguage) {
          case 'ru':
            return 'Кыргызстан → Корея';
          case 'en':
            return 'Kyrgyzstan → Korea';
          case 'ko':
            return '키르기스스탄 → 한국';
          default:
            return direction;
        }

      case 'Корея → Кыргызстан':
        switch (currentLanguage) {
          case 'ru':
            return 'Корея → Кыргызстан';
          case 'en':
            return 'Korea → Kyrgyzstan';
          case 'ko':
            return '한국 → 키르기스스탄';
          default:
            return direction;
        }

      case 'Marketplace':
        switch (currentLanguage) {
          case 'ru':
            return 'Marketplace';
          case 'en':
            return 'Marketplace';
          case 'ko':
            return '마켓플레이스';
          default:
            return direction;
        }

      default:
        return direction;
    }
  }

  // =========================================================
  // 📱 BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      // =====================================================
      // APP BAR
      // =====================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: Text(
          t('searchOrder'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Column(
        children: [
          // =================================================
          // 🔎 SEARCH HEADER
          // =================================================
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('findOrders'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  t('searchDescription'),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: t('searchHint'),

                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),

                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF1565C0),
                    ),

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

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),

                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF1565C0),
                        width: 1.2,
                      ),
                    ),
                  ),

                  onChanged: (value) {
                    setState(() {
                      searchText = value.toLowerCase().trim();
                    });
                  },
                ),
              ],
            ),
          ),

          // =================================================
          // 📦 ORDERS
          // =================================================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),

              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

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

                final orders = snapshot.data?.docs ?? [];

                // =========================================
                // 🔎 FILTER
                // =========================================

                final filteredOrders = orders.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final orderNumber = (data['orderNumber'] ?? '')
                      .toString()
                      .toLowerCase();

                  final phone = (data['phone'] ?? '').toString().toLowerCase();

                  final email = (data['email'] ?? '').toString().toLowerCase();

                  return orderNumber.contains(searchText) ||
                      phone.contains(searchText) ||
                      email.contains(searchText);
                }).toList();

                // =========================================
                // 📊 RESULT COUNT
                // =========================================

                if (filteredOrders.isEmpty) {
                  return _buildEmptyState();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 19,
                            color: Color(0xFF1565C0),
                          ),

                          const SizedBox(width: 7),

                          Text(
                            '${filteredOrders.length} ${t('ordersFound')}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];

                          final data = order.data() as Map<String, dynamic>;

                          return _buildOrderCard(context, order.id, data);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // 📦 ORDER CARD
  // =========================================================

  Widget _buildOrderCard(
    BuildContext context,
    String orderId,
    Map<String, dynamic> data,
  ) {
    final orderNumber = data['orderNumber']?.toString() ?? t('order');

    final product = data['product']?.toString() ?? t('productNotSpecified');

    final phone = data['phone']?.toString() ?? t('phoneNotFound');

    final email = data['email']?.toString() ?? t('emailNotFound');

    final status = data['status']?.toString() ?? 'Жаңы заказ';

    final price =
        data['totalPrice']?.toString() ?? data['price']?.toString() ?? '0';

    final direction = data['direction']?.toString() ?? '';

    final statusColor = getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius: BorderRadius.circular(22),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    OrderDetailsPage(data: {...data, 'id': orderId}),
              ),
            );
          },

          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ==========================================
                // HEADER
                // ==========================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Container(
                      width: 52,
                      height: 52,

                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: const Icon(
                        Icons.local_shipping,
                        color: Color(0xFF1565C0),
                        size: 27,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            orderNumber,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            product,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // STATUS
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 7,
                      ),

                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Icon(
                            getStatusIcon(status),
                            size: 14,
                            color: statusColor,
                          ),

                          const SizedBox(width: 4),

                          Text(
                            translateStatus(status),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Divider(height: 1, color: Colors.grey.shade200),

                const SizedBox(height: 14),

                // ==========================================
                // 👤 USER INFO
                // ==========================================
                _infoRow(Icons.phone_outlined, t('phone'), phone),

                const SizedBox(height: 9),

                _infoRow(Icons.email_outlined, t('email'), email),

                if (direction.isNotEmpty) ...[
                  const SizedBox(height: 9),

                  _infoRow(
                    Icons.swap_horiz,
                    t('direction'),
                    translateDirection(direction),
                  ),
                ],

                const SizedBox(height: 14),

                // ==========================================
                // 💰 PRICE
                // ==========================================
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(13),

                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: Row(
                    children: [
                      const Icon(
                        Icons.payments_outlined,
                        size: 20,
                        color: Color(0xFF1565C0),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        t('total'),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        '$price сом',
                        style: const TextStyle(
                          color: Color(0xFF1565C0),
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ==========================================
                // OPEN DETAILS
                // ==========================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,

                  children: [
                    Text(
                      t('details'),
                      style: const TextStyle(
                        color: Color(0xFF1565C0),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(width: 5),

                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 13,
                      color: Color(0xFF1565C0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================
  // ℹ️ INFO ROW
  // =========================================================

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),

        const SizedBox(width: 8),

        Text(
          '$title:',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),

        const SizedBox(width: 6),

        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // 📭 EMPTY STATE
  // =========================================================

  Widget _buildEmptyState() {
    final hasSearch = searchText.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              width: 100,
              height: 100,

              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(30),
              ),

              child: Icon(
                hasSearch ? Icons.search_off : Icons.inventory_2_outlined,
                size: 52,
                color: const Color(0xFF1565C0),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              hasSearch ? t('orderNotFound') : t('noOrders'),
              textAlign: TextAlign.center,

              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              hasSearch ? t('checkSearch') : t('noOrdersYet'),
              textAlign: TextAlign.center,

              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
