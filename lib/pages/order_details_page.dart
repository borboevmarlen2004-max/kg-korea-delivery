import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'payment_page.dart';

class OrderDetailsPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const OrderDetailsPage({super.key, required this.data});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  String currentLanguage = 'ky';

  Map<String, dynamic> get data => widget.data;

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

  // =========================================================
  // 🌍 КОТОРМО
  // =========================================================

  String t(String key) {
    const tr = <String, Map<String, String>>{
      'orderDetails': {
        'ky': 'Заказ жөнүндө',
        'ru': 'О заказе',
        'en': 'Order details',
        'ko': '주문 정보',
      },

      'order': {'ky': 'Заказ', 'ru': 'Заказ', 'en': 'Order', 'ko': '주문'},

      'orderStatus': {
        'ky': '📊 Заказдын статусу',
        'ru': '📊 Статус заказа',
        'en': '📊 Order status',
        'ko': '📊 주문 상태',
      },

      'currentStatus': {
        'ky': 'Учурдагы статус',
        'ru': 'Текущий статус',
        'en': 'Current status',
        'ko': '현재 상태',
      },

      'orderInfo': {
        'ky': '📦 Заказ маалыматы',
        'ru': '📦 Информация о заказе',
        'en': '📦 Order information',
        'ko': '📦 주문 정보',
      },

      'product': {'ky': 'Товар', 'ru': 'Товар', 'en': 'Product', 'ko': '상품'},

      'direction': {
        'ky': 'Багыты',
        'ru': 'Направление',
        'en': 'Direction',
        'ko': '방향',
      },

      'from': {'ky': 'Кайдан', 'ru': 'Откуда', 'en': 'From', 'ko': '출발지'},

      'to': {'ky': 'Кайда', 'ru': 'Куда', 'en': 'To', 'ko': '도착지'},

      'phone': {'ky': 'Телефон', 'ru': 'Телефон', 'en': 'Phone', 'ko': '전화번호'},

      'paymentInfo': {
        'ky': '💰 Төлөм маалыматы',
        'ru': '💰 Информация об оплате',
        'en': '💰 Payment information',
        'ko': '💰 결제 정보',
      },

      'delivery': {
        'ky': 'Жеткирүү',
        'ru': 'Доставка',
        'en': 'Delivery',
        'ko': '배송',
      },

      'total': {
        'ky': 'Жалпы сумма',
        'ru': 'Общая сумма',
        'en': 'Total amount',
        'ko': '총 금액',
      },

      'payment': {'ky': 'Төлөм', 'ru': 'Оплата', 'en': 'Payment', 'ko': '결제'},

      'pay': {
        'ky': 'Төлөмгө өтүү',
        'ru': 'Перейти к оплате',
        'en': 'Proceed to payment',
        'ko': '결제로 이동',
      },

      'notPaid': {
        'ky': 'Төлөнө элек',
        'ru': 'Не оплачено',
        'en': 'Not paid',
        'ko': '미결제',
      },

      'paid': {'ky': 'Төлөндү', 'ru': 'Оплачено', 'en': 'Paid', 'ko': '결제 완료'},

      'notFound': {'ky': 'Жок', 'ru': 'Нет', 'en': 'None', 'ko': '없음'},

      'unknown': {
        'ky': 'Белгисиз',
        'ru': 'Неизвестно',
        'en': 'Unknown',
        'ko': '알 수 없음',
      },

      'notProvided': {
        'ky': 'Көрсөтүлгөн эмес',
        'ru': 'Не указано',
        'en': 'Not provided',
        'ko': '입력되지 않음',
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

    return tr[key]?[currentLanguage] ?? tr[key]?['ky'] ?? key;
  }

  // =========================================================
  // 📊 STATUS TEXT
  // =========================================================

  String statusText(String status) {
    const keys = {
      'Жаңы заказ': 'newOrder',
      'Кабыл алынды': 'accepted',
      'Даярдалууда': 'preparing',
      'Жолдо': 'onWay',
      'Жеткирилди': 'delivered',
      'Жокко чыгарылды': 'cancelled',
    };

    return t(keys[status] ?? status);
  }

  // =========================================================
  // 💳 PAYMENT STATUS
  // =========================================================

  String paymentStatusText(String status) {
    if (status == 'Төлөндү') {
      return t('paid');
    }

    if (status == 'Төлөнө элек') {
      return t('notPaid');
    }

    return status;
  }

  // =========================================================
  // 🌍 DIRECTION
  // =========================================================

  String directionText(String value) {
    if (value == 'Кыргызстан → Корея') {
      if (currentLanguage == 'ky') {
        return 'Кыргызстан → Корея';
      }

      if (currentLanguage == 'ru') {
        return 'Кыргызстан → Корея';
      }

      if (currentLanguage == 'en') {
        return 'Kyrgyzstan → Korea';
      }

      if (currentLanguage == 'ko') {
        return '키르기스스탄 → 한국';
      }
    }

    if (value == 'Корея → Кыргызстан') {
      if (currentLanguage == 'ky') {
        return 'Корея → Кыргызстан';
      }

      if (currentLanguage == 'ru') {
        return 'Корея → Кыргызстан';
      }

      if (currentLanguage == 'en') {
        return 'Korea → Kyrgyzstan';
      }

      if (currentLanguage == 'ko') {
        return '한국 → 키르기스스탄';
      }
    }

    return value;
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
  // 🏗️ BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final orderNumber = data['orderNumber']?.toString() ?? t('notFound');

    final direction = data['direction']?.toString() ?? t('unknown');

    final product = data['product']?.toString() ?? t('unknown');

    final from = data['from']?.toString() ?? t('notProvided');

    final to = data['to']?.toString() ?? t('notProvided');

    final phone = data['phone']?.toString() ?? t('notProvided');

    final price = data['price']?.toString() ?? '0';

    final deliveryFee = data['deliveryFee']?.toString() ?? '0';

    final totalPrice = data['totalPrice']?.toString() ?? '0';

    final status = data['status']?.toString() ?? 'Жаңы заказ';

    final paymentStatus = data['paymentStatus']?.toString() ?? 'Төлөнө элек';

    final statusColor = getStatusColor(status);

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
          t('orderDetails'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // =================================================
            // 📦 ORDER HEADER
            // =================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: const Color(0xFF1565C0),

                borderRadius: BorderRadius.circular(24),

                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1565C0).withValues(alpha: 0.18),

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
                      color: Colors.white.withValues(alpha: 0.16),

                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.local_shipping,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          t('order'),

                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          orderNumber,

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          directionText(direction),

                          maxLines: 1,

                          overflow: TextOverflow.ellipsis,

                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =================================================
            // 📊 STATUS
            // =================================================
            Text(
              t('orderStatus'),

              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(17),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(20),
              ),

              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,

                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.10),

                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: Icon(
                      getStatusIcon(status),

                      color: statusColor,

                      size: 25,
                    ),
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Text(
                      t('currentStatus'),

                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),

                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.10),

                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Text(
                      statusText(status),

                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =================================================
            // 📦 PRODUCT
            // =================================================
            Text(
              t('orderInfo'),

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
                  detail(Icons.inventory_2_outlined, t('product'), product),

                  _divider(),

                  detail(
                    Icons.swap_horiz,
                    t('direction'),
                    directionText(direction),
                  ),

                  _divider(),

                  detail(Icons.location_on_outlined, t('from'), from),

                  _divider(),

                  detail(Icons.location_searching, t('to'), to),

                  _divider(),

                  detail(Icons.phone_outlined, t('phone'), phone),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =================================================
            // 💰 PAYMENT
            // =================================================
            Text(
              t('paymentInfo'),

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
                  _priceRow(t('product'), '$price сом'),

                  const SizedBox(height: 11),

                  _priceRow(t('delivery'), '$deliveryFee сом'),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 13),

                    child: Divider(height: 1),
                  ),

                  Row(
                    children: [
                      Text(
                        t('total'),

                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        '$totalPrice сом',

                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(13),

                    decoration: BoxDecoration(
                      color: paymentStatus == 'Төлөндү'
                          ? Colors.green.withValues(alpha: 0.08)
                          : Colors.orange.withValues(alpha: 0.08),

                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: Row(
                      children: [
                        Icon(
                          paymentStatus == 'Төлөндү'
                              ? Icons.check_circle_outline
                              : Icons.payment_outlined,

                          size: 20,

                          color: paymentStatus == 'Төлөндү'
                              ? Colors.green
                              : Colors.orange,
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            '${t('payment')}: ${paymentStatusText(paymentStatus)}',

                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,

                              color: paymentStatus == 'Төлөндү'
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =================================================
            // 💳 PAYMENT BUTTON
            // =================================================
            SizedBox(
              width: double.infinity,
              height: 57,

              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (context) => PaymentPage(data: data),
                    ),
                  );
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),

                  foregroundColor: Colors.white,

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),

                icon: const Icon(Icons.credit_card),

                label: Text(
                  t('pay'),

                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // 📋 DETAIL
  // =========================================================

  Widget detail(IconData icon, String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            width: 40,
            height: 40,

            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),

              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(icon, size: 20, color: const Color(0xFF1565C0)),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),

                const SizedBox(height: 4),

                Text(
                  value?.toString() ?? '',

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
    );
  }

  // =========================================================
  // 💰 PRICE ROW
  // =========================================================

  Widget _priceRow(String title, String value) {
    return Row(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),

        const Spacer(),

        Text(
          value,

          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // =========================================================
  // DIVIDER
  // =========================================================

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),

      child: Divider(height: 1, color: Colors.grey.shade200),
    );
  }
}
