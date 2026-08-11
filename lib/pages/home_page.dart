import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_translations.dart';

import 'login_page.dart';
import 'create_order_page.dart';
import 'korea_to_kyrgyzstan_page.dart';
import 'admin_panel_page.dart';
import 'my_orders_page.dart';
import 'profile_page.dart';
import 'chat_page.dart';
import 'marketplace_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentLanguage = 'ky';

  final String adminEmail = 'miki@gmail.com';

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
    return AppTranslations.get(key, currentLanguage);
  }

  String homeText(String key) {
    const texts = {
      'ky': {
        'serviceDescription':
            'Кыргызстан менен Кореянын ортосундагы жеткирүү кызматы',
        'chooseDirection': '📦 Жеткирүү багытын тандаңыз',
        'services': '🛍️ Кызматтар',
        'kgToKrSubtitle': 'Кыргызстандан Кореяга заказ жөнөтүү',
        'krToKgSubtitle': 'Кореядан Кыргызстанга заказ жөнөтүү',
        'myOrdersSubtitle': 'Бардык заказдарыңызды көрүү',
        'marketplaceSubtitle': 'Товарларды сатып алуу жана сатуу',
        'chatTitle': 'Админ менен чат',
        'chatSubtitle': 'Суроолор боюнча биз менен байланышыңыз',
        'profileSubtitle': 'Жеке маалыматтарды башкаруу',
        'adminSubtitle': 'Заказдарды жана кардарларды башкаруу',
        'logoutTooltip': 'Чыгуу',
        'logout': 'Аккаунттан чыгуу',
      },
      'ru': {
        'serviceDescription': 'Сервис доставки между Кыргызстаном и Кореей',
        'chooseDirection': '📦 Выберите направление доставки',
        'services': '🛍️ Сервисы',
        'kgToKrSubtitle': 'Отправить заказ из Кыргызстана в Корею',
        'krToKgSubtitle': 'Отправить заказ из Кореи в Кыргызстан',
        'myOrdersSubtitle': 'Просмотреть все ваши заказы',
        'marketplaceSubtitle': 'Покупка и продажа товаров',
        'chatTitle': 'Чат с администратором',
        'chatSubtitle': 'Свяжитесь с нами по вопросам',
        'profileSubtitle': 'Управление личными данными',
        'adminSubtitle': 'Управление заказами и клиентами',
        'logoutTooltip': 'Выйти',
        'logout': 'Выйти из аккаунта',
      },
      'en': {
        'serviceDescription': 'Delivery service between Kyrgyzstan and Korea',
        'chooseDirection': '📦 Choose delivery direction',
        'services': '🛍️ Services',
        'kgToKrSubtitle': 'Send an order from Kyrgyzstan to Korea',
        'krToKgSubtitle': 'Send an order from Korea to Kyrgyzstan',
        'myOrdersSubtitle': 'View all your orders',
        'marketplaceSubtitle': 'Buy and sell products',
        'chatTitle': 'Chat with admin',
        'chatSubtitle': 'Contact us if you have any questions',
        'profileSubtitle': 'Manage your personal information',
        'adminSubtitle': 'Manage orders and customers',
        'logoutTooltip': 'Log out',
        'logout': 'Log out of account',
      },
      'ko': {
        'serviceDescription': '키르기스스탄과 한국 간 배송 서비스',
        'chooseDirection': '📦 배송 방향을 선택하세요',
        'services': '🛍️ 서비스',
        'kgToKrSubtitle': '키르기스스탄에서 한국으로 주문 보내기',
        'krToKgSubtitle': '한국에서 키르기스스탄으로 주문 보내기',
        'myOrdersSubtitle': '모든 주문 보기',
        'marketplaceSubtitle': '상품 구매 및 판매',
        'chatTitle': '관리자와 채팅',
        'chatSubtitle': '문의사항이 있으면 연락해주세요',
        'profileSubtitle': '개인정보 관리',
        'adminSubtitle': '주문 및 고객 관리',
        'logoutTooltip': '로그아웃',
        'logout': '계정에서 로그아웃',
      },
    };

    return texts[currentLanguage]?[key] ?? texts['ky']?[key] ?? key;
  }

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,

        title: const Text(
          'KG ↔️ KOREA',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
            tooltip: homeText('logoutTooltip'),
          ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // 👋 Саламдашуу
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.circular(24),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,

                      child: Icon(
                        Icons.local_shipping,
                        size: 32,
                        color: Color(0xFF1565C0),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'KG ↔️ KOREA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      homeText('serviceDescription'),
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                homeText('chooseDirection'),
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // 🇰🇬 → 🇰🇷
              _directionCard(
                context: context,
                flag: '🇰🇬',
                secondFlag: '🇰🇷',
                title: t('kyrgyzstanKorea'),
                subtitle: homeText('kgToKrSubtitle'),
                color: const Color(0xFFE3F2FD),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateOrderPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // 🇰🇷 → 🇰🇬
              _directionCard(
                context: context,
                flag: '🇰🇷',
                secondFlag: '🇰🇬',
                title: t('koreaKyrgyzstan'),
                subtitle: homeText('krToKgSubtitle'),
                color: const Color(0xFFE8F5E9),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KoreaToKyrgyzstanPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              Text(
                homeText('services'),
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              // 📦 Менин заказдарым
              _menuCard(
                context: context,
                icon: Icons.inventory_2,
                title: t('orders'),
                subtitle: homeText('myOrdersSubtitle'),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyOrdersPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // 🛍️ Marketplace
              _menuCard(
                context: context,
                icon: Icons.storefront,
                title: t('marketplace'),
                subtitle: homeText('marketplaceSubtitle'),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MarketplacePage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // 💬 Chat
              _menuCard(
                context: context,
                icon: Icons.chat_bubble_outline,
                title: homeText('chatTitle'),
                subtitle: homeText('chatSubtitle'),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatPage()),
                  );
                },
              ),

              const SizedBox(height: 12),

              // 👤 Profile
              _menuCard(
                context: context,
                icon: Icons.person_outline,
                title: t('profile'),
                subtitle: homeText('profileSubtitle'),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
              ),

              // 👨‍💼 Admin
              if (user?.email == adminEmail) ...[
                const SizedBox(height: 12),

                _menuCard(
                  context: context,
                  icon: Icons.admin_panel_settings,
                  title: t('adminPanel'),
                  subtitle: homeText('adminSubtitle'),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminPanelPage(),
                      ),
                    );
                  },
                ),
              ],

              const SizedBox(height: 25),

              // 🚪 Чыгуу
              SizedBox(
                width: double.infinity,
                height: 52,

                child: OutlinedButton.icon(
                  onPressed: () => logout(context),

                  icon: const Icon(Icons.logout),

                  label: Text(
                    homeText('logout'),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              const Center(
                child: Text(
                  'KG ↔️ KOREA Delivery',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // 📦 Багыт карточкасы
  static Widget _directionCard({
    required BuildContext context,
    required String flag,
    required String secondFlag,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),

        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),

                child: Center(
                  child: Text(
                    '$flag $secondFlag',
                    style: const TextStyle(fontSize: 23),
                  ),
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // 🛍️ Меню карточкасы
  static Widget _menuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,

      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),

        child: Padding(
          padding: const EdgeInsets.all(17),

          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,

                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(15),
                ),

                child: Icon(icon, color: const Color(0xFF1565C0), size: 27),
              ),

              const SizedBox(width: 15),

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
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
