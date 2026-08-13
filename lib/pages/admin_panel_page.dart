import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin_search_page.dart';
import 'admin_chat_page.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
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
    const translations = {
      // =========================================================
      // HEADER
      // =========================================================
      'adminPanel': {
        'ky': 'Башкаруу панели',
        'ru': 'Панель управления',
        'en': 'Admin Panel',
        'ko': '관리자 패널',
      },
      'appName': {
        'ky': 'KG ↔️ KOREA Delivery',
        'ru': 'KG ↔️ KOREA Delivery',
        'en': 'KG ↔️ KOREA Delivery',
        'ko': 'KG ↔️ KOREA Delivery',
      },

      // =========================================================
      // ERROR
      // =========================================================
      'error': {'ky': 'Ката', 'ru': 'Ошибка', 'en': 'Error', 'ko': '오류'},

      // =========================================================
      // STATISTICS
      // =========================================================
      'statistics': {
        'ky': '📊 Заказдар статистикасы',
        'ru': '📊 Статистика заказов',
        'en': '📊 Order Statistics',
        'ko': '📊 주문 통계',
      },
      'allOrders': {
        'ky': 'Бардык заказдар',
        'ru': 'Все заказы',
        'en': 'All Orders',
        'ko': '전체 주문',
      },
      'new': {'ky': 'Жаңы', 'ru': 'Новые', 'en': 'New', 'ko': '신규'},
      'accepted': {
        'ky': 'Кабыл алынды',
        'ru': 'Приняты',
        'en': 'Accepted',
        'ko': '접수됨',
      },
      'preparing': {
        'ky': 'Даярдалууда',
        'ru': 'Готовятся',
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
        'ru': 'Доставлены',
        'en': 'Delivered',
        'ko': '배송 완료',
      },
      'cancelled': {
        'ky': 'Жокко чыгарылды',
        'ru': 'Отменены',
        'en': 'Cancelled',
        'ko': '취소됨',
      },

      // =========================================================
      // MANAGEMENT
      // =========================================================
      'management': {
        'ky': '🛠️ Башкаруу',
        'ru': '🛠️ Управление',
        'en': '🛠️ Management',
        'ko': '🛠️ 관리',
      },
      'searchOrder': {
        'ky': 'Заказ издөө',
        'ru': 'Поиск заказа',
        'en': 'Search Order',
        'ko': '주문 검색',
      },
      'searchOrderSubtitle': {
        'ky': 'Заказ номерин же маалыматты издеңиз',
        'ru': 'Найдите заказ по номеру или данным',
        'en': 'Search by order number or information',
        'ko': '주문 번호 또는 정보로 검색',
      },
      'customerChat': {
        'ky': 'Кардарлардын чаты',
        'ru': 'Чат с клиентами',
        'en': 'Customer Chat',
        'ko': '고객 채팅',
      },
      'customerChatSubtitle': {
        'ky': 'Кардарлардын билдирүүлөрүн көрүү',
        'ru': 'Просмотр сообщений клиентов',
        'en': 'View customer messages',
        'ko': '고객 메시지 보기',
      },

      // =========================================================
      // INFO
      // =========================================================
      'info': {
        'ky':
            'Бул панель аркылуу заказдардын абалын көзөмөлдөп, кардарлар менен иштей аласыз.',
        'ru':
            'Через эту панель вы можете контролировать заказы и работать с клиентами.',
        'en': 'Use this panel to monitor orders and work with customers.',
        'ko': '이 패널에서 주문 상태를 확인하고 고객과 소통할 수 있습니다.',
      },
    };

    final value = translations[key];

    if (value == null) {
      return key;
    }

    return value[currentLanguage] ?? value['ky'] ?? key;
  }

  String statusText(String status) {
    const statusTranslations = {
      'Жаңы заказ': {
        'ky': 'Жаңы заказ',
        'ru': 'Новый заказ',
        'en': 'New order',
        'ko': '새 주문',
      },
      'Кабыл алынды': {
        'ky': 'Кабыл алынды',
        'ru': 'Принят',
        'en': 'Accepted',
        'ko': '접수됨',
      },
      'Даярдалууда': {
        'ky': 'Даярдалууда',
        'ru': 'Готовится',
        'en': 'Preparing',
        'ko': '준비 중',
      },
      'Жолдо': {
        'ky': 'Жолдо',
        'ru': 'В пути',
        'en': 'On the way',
        'ko': '배송 중',
      },
      'Жеткирилди': {
        'ky': 'Жеткирилди',
        'ru': 'Доставлен',
        'en': 'Delivered',
        'ko': '배송 완료',
      },
      'Жокко чыгарылды': {
        'ky': 'Жокко чыгарылды',
        'ru': 'Отменён',
        'en': 'Cancelled',
        'ko': '취소됨',
      },
    };

    return statusTranslations[status]?[currentLanguage] ??
        statusTranslations[status]?['ky'] ??
        status;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        title: Text(
          '👨‍💼 ${t('adminPanel')}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
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

          int newOrders = 0;
          int accepted = 0;
          int preparing = 0;
          int onWay = 0;
          int delivered = 0;
          int cancelled = 0;

          for (final order in orders) {
            final data = order.data() as Map<String, dynamic>;

            switch (data['status']) {
              case 'Жаңы заказ':
                newOrders++;
                break;

              case 'Кабыл алынды':
                accepted++;
                break;

              case 'Даярдалууда':
                preparing++;
                break;

              case 'Жолдо':
                onWay++;
                break;

              case 'Жеткирилди':
                delivered++;
                break;

              case 'Жокко чыгарылды':
                cancelled++;
                break;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 30),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // ==========================================
                // 👋 HEADER
                // ==========================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),

                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0),
                    borderRadius: BorderRadius.circular(24),

                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1565C0).withOpacity(0.20),
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
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.admin_panel_settings,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t('adminPanel'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              t('appName'),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // ==========================================
                // 📊 СТАТИСТИКА
                // ==========================================
                Text(
                  t('statistics'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                // Бардык заказдар
                _buildMainStatCard(
                  icon: Icons.inventory_2_outlined,
                  title: t('allOrders'),
                  value: orders.length,
                  color: const Color(0xFF1565C0),
                ),

                const SizedBox(height: 12),

                // 2 колонка
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.fiber_new,
                        title: t('new'),
                        value: newOrders,
                        color: Colors.orange,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.check_circle_outline,
                        title: t('accepted'),
                        value: accepted,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.inventory_2_outlined,
                        title: t('preparing'),
                        value: preparing,
                        color: Colors.amber.shade800,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.local_shipping_outlined,
                        title: t('onWay'),
                        value: onWay,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.done_all,
                        title: t('delivered'),
                        value: delivered,
                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.cancel_outlined,
                        title: t('cancelled'),
                        value: cancelled,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ==========================================
                // 🛠️ БАШКАРУУ
                // ==========================================
                Text(
                  t('management'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                // 🔍 Заказ издөө
                _buildActionCard(
                  context: context,
                  icon: Icons.search,
                  title: t('searchOrder'),
                  subtitle: t('searchOrderSubtitle'),
                  color: const Color(0xFF1565C0),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminSearchPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // 💬 Кардарлардын чаты
                _buildActionCard(
                  context: context,
                  icon: Icons.chat_bubble_outline,
                  title: t('customerChat'),
                  subtitle: t('customerChatSubtitle'),
                  color: const Color(0xFF2E7D32),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminChatPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 25),

                // ℹ️ INFO
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade200),
                  ),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF1565C0)),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          t('info'),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ========================================================
  // 📊 MAIN STAT CARD
  // ========================================================

  Widget _buildMainStatCard({
    required IconData icon,
    required String title,
    required int value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,

            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),

            child: Icon(icon, color: color, size: 28),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),

                const SizedBox(height: 4),

                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),

          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  // ========================================================
  // 📊 SMALL STAT CARD
  // ========================================================

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required int value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,

            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(icon, color: color, size: 21),
          ),

          const SizedBox(height: 12),

          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // 🛠️ ACTION CARD
  // ========================================================

  Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),

        child: Padding(
          padding: const EdgeInsets.all(17),

          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,

                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(15),
                ),

                child: Icon(icon, color: color, size: 27),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
