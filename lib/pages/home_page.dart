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
  int selectedIndex = 0;

  final String adminEmail = 'miki@gmail.com';

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
    return AppTranslations.get(key, currentLanguage);
  }

  String homeText(String key) {
    const texts = {
      'ky': {
        'marketplace': 'Marketplace',
        'orders': 'Менин заказдарым',
        'delivery': 'Жеткирүү',
        'chat': 'Chat',
        'profile': 'Профиль',
        'admin': 'Admin Panel',
        'kgToKr': 'Кыргызстан → Корея',
        'kgToKrSubtitle': 'Кыргызстандан Кореяга заказ жөнөтүү',
        'krToKg': 'Корея → Кыргызстан',
        'krToKgSubtitle': 'Кореядан Кыргызстанга заказ жөнөтүү',
        'chooseDirection': 'Жеткирүү багытын тандаңыз',
        'logout': 'Аккаунттан чыгуу',
        'logoutTooltip': 'Чыгуу',
        'deliveryTitle': 'Жеткирүү',
        'deliverySubtitle': 'Кыргызстан ↔ Корея',
      },

      'ru': {
        'marketplace': 'Marketplace',
        'orders': 'Мои заказы',
        'delivery': 'Доставка',
        'chat': 'Чат',
        'profile': 'Профиль',
        'admin': 'Admin Panel',
        'kgToKr': 'Кыргызстан → Корея',
        'kgToKrSubtitle': 'Отправить заказ из Кыргызстана в Корею',
        'krToKg': 'Корея → Кыргызстан',
        'krToKgSubtitle': 'Отправить заказ из Кореи в Кыргызстан',
        'chooseDirection': 'Выберите направление доставки',
        'logout': 'Выйти из аккаунта',
        'logoutTooltip': 'Выйти',
        'deliveryTitle': 'Доставка',
        'deliverySubtitle': 'Кыргызстан ↔ Корея',
      },

      'en': {
        'marketplace': 'Marketplace',
        'orders': 'My Orders',
        'delivery': 'Delivery',
        'chat': 'Chat',
        'profile': 'Profile',
        'admin': 'Admin Panel',
        'kgToKr': 'Kyrgyzstan → Korea',
        'kgToKrSubtitle': 'Send an order from Kyrgyzstan to Korea',
        'krToKg': 'Korea → Kyrgyzstan',
        'krToKgSubtitle': 'Send an order from Korea to Kyrgyzstan',
        'chooseDirection': 'Choose delivery direction',
        'logout': 'Log out',
        'logoutTooltip': 'Log out',
        'deliveryTitle': 'Delivery',
        'deliverySubtitle': 'Kyrgyzstan ↔ Korea',
      },

      'ko': {
        'marketplace': 'Marketplace',
        'orders': '내 주문',
        'delivery': '배송',
        'chat': '채팅',
        'profile': '프로필',
        'admin': '관리자 패널',
        'kgToKr': '키르기스스탄 → 한국',
        'kgToKrSubtitle': '키르기스스탄에서 한국으로 주문 보내기',
        'krToKg': '한국 → 키르기스스탄',
        'krToKgSubtitle': '한국에서 키르기스스탄으로 주문 보내기',
        'chooseDirection': '배송 방향을 선택하세요',
        'logout': '로그아웃',
        'logoutTooltip': '로그아웃',
        'deliveryTitle': '배송',
        'deliverySubtitle': '키르기스스탄 ↔ 한국',
      },
    };

    return texts[currentLanguage]?[key] ?? texts['ky']?[key] ?? key;
  }

  // =========================================================
  // 🚪 LOGOUT
  // =========================================================

  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  // =========================================================
  // 📱 NAVIGATION PAGES
  // =========================================================

  Widget _buildPage(int index, User? user) {
    switch (index) {
      case 0:
        // 🛍️ Marketplace — БИРИНЧИ БЕТ
        return const MarketplacePage();

      case 1:
        // 📦 Менин заказдарым
        return const MyOrdersPage();

      case 2:
        // 🚚 Жеткирүү
        return _buildDeliveryPage();

      case 3:
        // 💬 Chat же 👨‍💼 Admin
        if (user?.email == adminEmail) {
          return const AdminPanelPage();
        }

        return const ChatPage();

      case 4:
        // 👤 Profile
        return const ProfilePage();

      default:
        return const MarketplacePage();
    }
  }

  // =========================================================
  // 🚚 DELIVERY PAGE
  // =========================================================

  Widget _buildDeliveryPage() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,

        title: Text(
          homeText('deliveryTitle'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // =================================================
            // HEADER
            // =================================================
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

              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: const Center(
                      child: Text('🚚', style: TextStyle(fontSize: 30)),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          homeText('deliveryTitle'),

                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          homeText('deliverySubtitle'),

                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Text(
              homeText('chooseDirection'),

              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            // =================================================
            // 🇰🇬 → 🇰🇷
            // =================================================
            _directionCard(
              flag: '🇰🇬',
              secondFlag: '🇰🇷',

              title: homeText('kgToKr'),

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

            const SizedBox(height: 14),

            // =================================================
            // 🇰🇷 → 🇰🇬
            // =================================================
            _directionCard(
              flag: '🇰🇷',
              secondFlag: '🇰🇬',

              title: homeText('krToKg'),

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
          ],
        ),
      ),
    );
  }

  // =========================================================
  // 📦 DIRECTION CARD
  // =========================================================

  Widget _directionCard({
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

  // =========================================================
  // 🧭 BOTTOM NAVIGATION
  // =========================================================

  Widget _buildBottomNavigation(User? user) {
    final isAdmin = user?.email == adminEmail;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),

            blurRadius: 18,

            offset: const Offset(0, -5),
          ),
        ],
      ),

      child: SafeArea(
        top: false,

        child: SizedBox(
          height: 72,

          child: Row(
            children: [
              // 🛍️ MARKETPLACE
              _navItem(
                index: 0,
                icon: Icons.storefront_outlined,
                activeIcon: Icons.storefront,
                label: homeText('marketplace'),
              ),

              // 📦 ORDERS
              _navItem(
                index: 1,
                icon: Icons.inventory_2_outlined,
                activeIcon: Icons.inventory_2,
                label: homeText('orders'),
              ),

              // 🚚 DELIVERY
              _navItem(
                index: 2,
                icon: Icons.local_shipping_outlined,
                activeIcon: Icons.local_shipping,
                label: homeText('delivery'),
              ),

              // 💬 CHAT / ADMIN
              _navItem(
                index: 3,

                icon: isAdmin
                    ? Icons.admin_panel_settings_outlined
                    : Icons.chat_bubble_outline,

                activeIcon: isAdmin
                    ? Icons.admin_panel_settings
                    : Icons.chat_bubble,

                label: isAdmin ? homeText('admin') : homeText('chat'),
              ),

              // 👤 PROFILE
              _navItem(
                index: 4,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: homeText('profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================
  // 🧩 NAV ITEM
  // =========================================================

  Widget _navItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final selected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,

        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),

              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),

              decoration: BoxDecoration(
                color: selected ? const Color(0xFFE3F2FD) : Colors.transparent,

                borderRadius: BorderRadius.circular(18),
              ),

              child: Icon(
                selected ? activeIcon : icon,

                size: 25,

                color: selected
                    ? const Color(0xFF1565C0)
                    : Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              label,

              maxLines: 1,

              overflow: TextOverflow.ellipsis,

              style: TextStyle(
                fontSize: 10,

                fontWeight: selected ? FontWeight.bold : FontWeight.normal,

                color: selected
                    ? const Color(0xFF1565C0)
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // 🏠 BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: IndexedStack(
        index: selectedIndex,

        children: [
          _buildPage(0, user),
          _buildPage(1, user),
          _buildPage(2, user),
          _buildPage(3, user),
          _buildPage(4, user),
        ],
      ),

      bottomNavigationBar: _buildBottomNavigation(user),
    );
  }
}
