import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  String? apnsToken;

  for (int i = 0; i < 10; i++) {
    apnsToken = await FirebaseMessaging.instance.getAPNSToken();

    if (apnsToken != null) {
      break;
    }

    await Future.delayed(const Duration(seconds: 1));
  }

  if (apnsToken != null) {
    final token = await FirebaseMessaging.instance.getToken();
    print('FCM TOKEN: $token');
  } else {
    print('APNS TOKEN азырынча алынган жок');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KG ↔️ KOREA Delivery',

      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: Colors.grey.shade100,

        appBarTheme: const AppBarTheme(centerTitle: true),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),

      home: const AuthCheck(),
    );
  }
}

// ================= AUTH CHECK =================

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return const HomePage();
    }

    return const LoginPage();
  }
}

// ================= HOME + FIRESTORE =================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
      appBar: AppBar(
        title: const Text('KG ↔️ KOREA'),
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            const CircleAvatar(
              radius: 45,
              child: Icon(Icons.local_shipping, size: 50),
            ),

            const SizedBox(height: 20),

            const Text(
              'KG ↔️ KOREA',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'Корея ↔️ Кыргызстан жеткирүү кызматы',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 35),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Кайсы багыт?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              height: 65,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateOrderPage(),
                    ),
                  );
                },
                icon: const Text('🇰🇬', style: TextStyle(fontSize: 28)),
                label: const Text(
                  'Кыргызстан → Корея',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 65,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KoreaToKyrgyzstanPage(),
                    ),
                  );
                },
                icon: const Text('🇰🇷', style: TextStyle(fontSize: 28)),
                label: const Text(
                  'Корея → Кыргызстан',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 25),

            if (user?.email != null)
              Text(user!.email!, style: const TextStyle(fontSize: 14)),

            const SizedBox(height: 15),

            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyOrdersPage()),
                );
              },
              icon: const Icon(Icons.inventory_2),
              label: const Text('Менин заказдарым'),
            ),

            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              icon: const Icon(Icons.person),
              label: const Text('Менин профилим'),
            ),
            const SizedBox(height: 10),
            if (user?.email == 'miki@gmail.com')
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminPanelPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.admin_panel_settings),
                label: const Text('Admin Panel 👨‍💼'),
              ),
            const SizedBox(height: 20),

            TextButton.icon(
              onPressed: () => logout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Аккаунттан чыгуу'),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> {
  final productController = TextEditingController();
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final phoneController = TextEditingController();
  final priceController = TextEditingController();
  final deliveryController = TextEditingController(text: '500');
  String message = '';

  Future<void> createOrder() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        message = 'Адегенде аккаунтка кириңиз';
      });
      return;
    }

    if (productController.text.trim().isEmpty ||
        fromController.text.trim().isEmpty ||
        toController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      setState(() {
        message = 'Бардык талааларды толтуруңуз';
      });
      return;
    }

    try {
      final orderNumber = 'KGK${DateTime.now().millisecondsSinceEpoch}';
      await FirebaseFirestore.instance.collection('orders').add({
        'orderNumber': orderNumber,
        'userId': user.uid,
        'email': user.email,
        'direction': 'Кыргызстан → Корея',
        'product': productController.text.trim(),
        'from': fromController.text.trim(),
        'to': toController.text.trim(),
        'phone': phoneController.text.trim(),
        'price': priceController.text,
        'deliveryFee': deliveryController.text,
        'totalPrice':
            (double.tryParse(priceController.text) ?? 0) +
            (double.tryParse(deliveryController.text) ?? 0),
        'status': 'Жаңы заказ',
        'paymentStatus': 'Төлөнө элек',
        'paymentMethod': 'Карта',
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        message = 'Заказ ийгиликтүү түзүлдү! 🎉';
      });

      productController.clear();
      fromController.clear();
      toController.clear();
      phoneController.clear();
    } catch (e) {
      setState(() {
        message = 'Ката: $e';
      });
    }
  }

  @override
  void dispose() {
    productController.dispose();
    fromController.dispose();
    toController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Заказ түзүү')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              '🇰🇬 Кыргызстан → 🇰🇷 Корея',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: productController,
              decoration: const InputDecoration(
                labelText: '📦 Товардын аты',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: fromController,
              decoration: const InputDecoration(
                labelText: '📍 Кайдан?',
                hintText: 'Мисалы: Бишкек',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: toController,
              decoration: const InputDecoration(
                labelText: '📍 Кайда?',
                hintText: 'Мисалы: Сеул',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: '📞 Телефон',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '💰 Баасы (сом)',
                hintText: 'Мисалы: 5000',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: deliveryController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '🚚 Жеткирүү акысы (сом)',
                hintText: 'Мисалы: 500',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            ValueListenableBuilder<TextEditingValue>(
              valueListenable: priceController,
              builder: (context, priceValue, child) {
                final price = double.tryParse(priceValue.text) ?? 0;
                final delivery = double.tryParse(deliveryController.text) ?? 0;
                final total = price + delivery;

                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '💰 Жалпы сумма: ${total.toStringAsFixed(0)} сом',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: createOrder,
                child: const Text(
                  'Заказ түзүү 📦',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class KoreaToKyrgyzstanPage extends StatefulWidget {
  const KoreaToKyrgyzstanPage({super.key});

  @override
  State<KoreaToKyrgyzstanPage> createState() => _KoreaToKyrgyzstanPageState();
}

class _KoreaToKyrgyzstanPageState extends State<KoreaToKyrgyzstanPage> {
  final productController = TextEditingController();
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final phoneController = TextEditingController();

  String message = '';

  Future<void> createOrder() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() {
        message = 'Адегенде аккаунтка кириңиз';
      });
      return;
    }

    if (productController.text.trim().isEmpty ||
        fromController.text.trim().isEmpty ||
        toController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      setState(() {
        message = 'Бардык талааларды толтуруңуз';
      });
      return;
    }

    try {
      final orderNumber = 'KRK${DateTime.now().millisecondsSinceEpoch}';
      await FirebaseFirestore.instance.collection('orders').add({
        'orderNumber': orderNumber,
        'userId': user.uid,
        'email': user.email,
        'direction': 'Корея → Кыргызстан',
        'product': productController.text.trim(),
        'from': fromController.text.trim(),
        'to': toController.text.trim(),
        'phone': phoneController.text.trim(),
        'status': 'Жаңы заказ',
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        message = 'Заказ ийгиликтүү түзүлдү! 🎉';
      });

      productController.clear();
      fromController.clear();
      toController.clear();
      phoneController.clear();
    } catch (e) {
      setState(() {
        message = 'Ката: $e';
      });
    }
  }

  @override
  void dispose() {
    productController.dispose();
    fromController.dispose();
    toController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Заказ түзүү')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              '🇰🇷 Корея → 🇰🇬 Кыргызстан',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: productController,
              decoration: const InputDecoration(
                labelText: '📦 Товардын аты',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: fromController,
              decoration: const InputDecoration(
                labelText: '📍 Кайдан?',
                hintText: 'Мисалы: Сеул',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: toController,
              decoration: const InputDecoration(
                labelText: '📍 Кайда?',
                hintText: 'Мисалы: Бишкек',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: '📞 Телефон',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: createOrder,
                child: const Text(
                  'Заказ түзүү 📦',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  String selectedStatus = 'Баары';

  final List<String> statusFilters = [
    'Баары',
    'Жаңы заказ',
    'Кабыл алынды',
    'Даярдалууда',
    'Жолдо',
    'Жеткирилди',
    'Жокко чыгарылды',
  ];

  Future<void> changeStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update(
        {'status': newStatus},
      );
    } catch (e) {
      debugPrint('STATUS UPDATE ERROR: $e');
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .delete();
    } catch (e) {
      debugPrint('DELETE ERROR: $e');
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Жаңы заказ':
        return Colors.orange;
      case 'Кабыл алынды':
        return Colors.blue;
      case 'Даярдалууда':
        return Colors.amber;
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

  Widget buildOrderProgress(String status) {
    const statuses = [
      'Жаңы заказ',
      'Кабыл алынды',
      'Даярдалууда',
      'Жолдо',
      'Жеткирилди',
    ];

    final currentIndex = statuses.indexOf(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Заказдын жүрүшү',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),

        const SizedBox(height: 12),

        Row(
          children: List.generate(statuses.length, (index) {
            final isCompleted = currentIndex >= index;

            final color = isCompleted
                ? getStatusColor(statuses[index])
                : Colors.grey.shade300;

            return Expanded(
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),

                  if (index < statuses.length - 1)
                    Expanded(
                      child: Container(
                        height: 3,
                        color: currentIndex > index
                            ? getStatusColor(statuses[index])
                            : Colors.grey.shade300,
                      ),
                    ),
                ],
              ),
            );
          }),
        ),

        const SizedBox(height: 8),

        Row(
          children: statuses.map((item) {
            return Expanded(
              child: Text(
                item,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: item == status
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    const adminEmail = 'miki@gmail.com';
    final isAdmin = user?.email == adminEmail;

    if (user == null) {
      return const LoginPage();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Менин заказдарым')),

      body: StreamBuilder<QuerySnapshot>(
        stream: isAdmin
            ? FirebaseFirestore.instance
                  .collection('orders')
                  .orderBy('createdAt', descending: true)
                  .snapshots()
            : FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ката: ${snapshot.error}'));
          }

          final orders = snapshot.data?.docs ?? [];

          final filteredOrders = selectedStatus == 'Баары'
              ? orders
              : orders.where((order) {
                  final data = order.data() as Map<String, dynamic>;

                  return data['status'] == selectedStatus;
                }).toList();

          return Column(
            children: [
              // ================= FILTER =================
              if (isAdmin)
                SizedBox(
                  height: 55,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    children: statusFilters.map((filter) {
                      final selected = selectedStatus == filter;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              selectedStatus = filter;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // ================= ORDERS =================
              Expanded(
                child: filteredOrders.isEmpty
                    ? Center(
                        child: Text(
                          selectedStatus == 'Баары'
                              ? 'Сизде азырынча заказ жок 📦'
                              : '$selectedStatus боюнча заказ жок 📦',
                          style: const TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(15),
                        itemCount: filteredOrders.length,

                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];

                          final data = order.data() as Map<String, dynamic>;

                          final createdAt = data['createdAt'];

                          final formattedDate = createdAt != null
                              ? DateFormat(
                                  'dd.MM.yyyy, HH:mm',
                                ).format(createdAt.toDate())
                              : 'Дата жок';

                          final status = data['status'] ?? 'Жаңы заказ';

                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderDetailsPage(
                                    data: {...data, 'id': order.id},
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 15),
                              child: Padding(
                                padding: const EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['direction'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 5),

                                    Text(
                                      '🔢 Заказ № ${data['orderNumber'] ?? 'Жок'}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    Text('📦 Товар: ${data['product'] ?? ''}'),
                                    Text('📍 Кайдан: ${data['from'] ?? ''}'),
                                    Text('📍 Кайда: ${data['to'] ?? ''}'),

                                    Text(
                                      '🕐 Заказ түзүлгөн: $formattedDate',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),

                                    Text(
                                      '💰 Баасы: ${data['price'] ?? 'Көрсөтүлгөн эмес'} сом',
                                    ),

                                    Text(
                                      '🚚 Жеткирүү: ${data['deliveryFee'] ?? 'Көрсөтүлгөн эмес'} сом',
                                    ),

                                    Text(
                                      '💵 Жалпы: ${data['totalPrice'] ?? 'Көрсөтүлгөн эмес'} сом',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    const SizedBox(height: 10),

                                    Chip(
                                      backgroundColor: getStatusColor(
                                        status,
                                      ).withValues(alpha: 0.2),
                                      label: Text(
                                        '📦 $status',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: getStatusColor(status),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 15),

                                    if (status != 'Жокко чыгарылды')
                                      buildOrderProgress(status),

                                    const SizedBox(height: 15),

                                    if (isAdmin) ...[
                                      const Text(
                                        'Статусту өзгөртүү:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      DropdownButton<String>(
                                        value: status,
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'Жаңы заказ',
                                            child: Text('🟠 Жаңы заказ'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Кабыл алынды',
                                            child: Text('🔵 Кабыл алынды'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Даярдалууда',
                                            child: Text('🟡 Даярдалууда'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Жолдо',
                                            child: Text('🚚 Жолдо'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Жеткирилди',
                                            child: Text('🟢 Жеткирилди'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Жокко чыгарылды',
                                            child: Text('🔴 Жокко чыгарылды'),
                                          ),
                                        ],
                                        onChanged: (newStatus) async {
                                          if (newStatus == null) return;

                                          await changeStatus(
                                            order.id,
                                            newStatus,
                                          );
                                        },
                                      ),
                                    ],

                                    const SizedBox(height: 10),

                                    if (isAdmin)
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              changeStatus(
                                                order.id,
                                                'Кабыл алынды',
                                              );
                                            },
                                            child: const Text('✅ Кабыл алынды'),
                                          ),

                                          ElevatedButton(
                                            onPressed: () {
                                              changeStatus(
                                                order.id,
                                                'Даярдалууда',
                                              );
                                            },
                                            child: const Text('🟡 Даярдалууда'),
                                          ),

                                          ElevatedButton(
                                            onPressed: () {
                                              changeStatus(order.id, 'Жолдо');
                                            },
                                            child: const Text('🚚 Жолдо'),
                                          ),

                                          ElevatedButton(
                                            onPressed: () {
                                              changeStatus(
                                                order.id,
                                                'Жеткирилди',
                                              );
                                            },
                                            child: const Text('📦 Жеткирилди'),
                                          ),

                                          ElevatedButton(
                                            onPressed: () {
                                              changeStatus(
                                                order.id,
                                                'Жокко чыгарылды',
                                              );
                                            },
                                            child: const Text(
                                              '❌ Жокко чыгарылды',
                                            ),
                                          ),
                                        ],
                                      ),

                                    const SizedBox(height: 10),

                                    OutlinedButton.icon(
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text(
                                                'Заказды өчүрүү',
                                              ),
                                              content: const Text(
                                                'Бул заказды чын эле өчүрөсүзбү?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      context,
                                                      false,
                                                    );
                                                  },
                                                  child: const Text('Жок'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(
                                                      context,
                                                      true,
                                                    );
                                                  },
                                                  child: const Text(
                                                    'Ооба, өчүрүү',
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );

                                        if (confirm == true) {
                                          await deleteOrder(order.id);
                                        }
                                      },
                                      icon: const Icon(Icons.delete),
                                      label: const Text('Заказды өчүрүү'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class PaymentPage extends StatelessWidget {
  final String orderId;
  final dynamic total;

  const PaymentPage({super.key, required this.orderId, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Төлөм 💳')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 30),

            const Icon(Icons.credit_card, size: 80),

            const SizedBox(height: 25),

            const Text('Төлөнө турган сумма', style: TextStyle(fontSize: 18)),

            const SizedBox(height: 10),

            Text(
              '$total сом',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    print('ORDER ID = $orderId');
                    await FirebaseFirestore.instance
                        .collection('orders')
                        .doc(orderId)
                        .update({
                          'paymentStatus': 'Төлөндү',
                          'paymentMethod': 'Тесттик төлөм',
                          'paidAt': FieldValue.serverTimestamp(),
                        });

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Тесттик төлөм ийгиликтүү ✅'),
                      ),
                    );

                    Navigator.pop(context, true);
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Ката: $e')));
                  }
                },
                icon: const Icon(Icons.payment),
                label: const Text(
                  'Карта менен төлөө',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderDetailsPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const OrderDetailsPage({super.key, required this.data});

  @override
  State<OrderDetailsPage> createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  bool isUpdating = false;

  Color getStatusColor(String status) {
    switch (status) {
      case 'Жаңы заказ':
        return Colors.orange;
      case 'Кабыл алынды':
        return Colors.blue;
      case 'Даярдалууда':
        return Colors.amber;
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

  Future<void> markAsPaid() async {
    final orderId = widget.data['id'];

    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'paymentStatus': 'Төлөндү',
    });

    setState(() {
      widget.data['paymentStatus'] = 'Төлөндү';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Төлөм ийгиликтүү белгиленди ✅')),
    );
  }

  Future<void> changeStatus(String newStatus) async {
    final orderId = widget.data['id'];

    if (orderId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Заказ ID табылган жок')));
      return;
    }

    try {
      setState(() {
        isUpdating = true;
      });

      await FirebaseFirestore.instance.collection('orders').doc(orderId).update(
        {'status': newStatus},
      );

      setState(() {
        widget.data['status'] = newStatus;
        isUpdating = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Статус өзгөрдү: $newStatus ✅')));
    } catch (e) {
      setState(() {
        isUpdating = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ката: $e')));
    }
  }

  Future<void> deleteOrder() async {
    final orderId = widget.data['id'];

    if (orderId == null) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Заказды өчүрүү'),
          content: const Text('Бул заказды чын эле өчүрөсүзбү?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Жок'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Ооба, өчүрүү'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Заказ өчүрүлдү 🗑️')));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ката: $e')));
    }
  }

  Widget infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final user = FirebaseAuth.instance.currentUser;
    final isAdmin = user?.email == 'miki@gmail.com';
    final status = data['status'] ?? 'Жаңы заказ';

    final price = data['price'] ?? 'Көрсөтүлгөн эмес';
    final delivery = data['deliveryFee'] ?? 'Көрсөтүлгөн эмес';
    final total = data['totalPrice'] ?? 'Көрсөтүлгөн эмес';

    return Scaffold(
      appBar: AppBar(title: const Text('Заказдын деталдары')),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER =================
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.local_shipping, size: 45),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    data['orderNumber'] ?? 'Заказ № жок',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    data['direction'] ?? '',
                    style: const TextStyle(fontSize: 17),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ================= STATUS =================
            Card(
              child: ListTile(
                leading: Icon(Icons.info, color: getStatusColor(status)),
                title: const Text(
                  'Учурдагы статус',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  status,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: getStatusColor(status),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ================= ORDER INFO =================
            const Text(
              'Заказ жөнүндө маалымат',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            infoCard(
              icon: Icons.inventory_2,
              title: 'Товар',
              value: data['product'] ?? 'Көрсөтүлгөн эмес',
            ),

            infoCard(
              icon: Icons.location_on,
              title: 'Кайдан',
              value: data['from'] ?? 'Көрсөтүлгөн эмес',
            ),

            infoCard(
              icon: Icons.location_on,
              title: 'Кайда',
              value: data['to'] ?? 'Көрсөтүлгөн эмес',
            ),

            infoCard(
              icon: Icons.phone,
              title: 'Телефон',
              value: data['phone'] ?? 'Көрсөтүлгөн эмес',
            ),

            infoCard(
              icon: Icons.email,
              title: 'Email',
              value: data['email'] ?? 'Көрсөтүлгөн эмес',
            ),

            const SizedBox(height: 20),

            // ================= PRICE =================
            const Text(
              'Төлөм маалыматы',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            infoCard(
              icon: Icons.payments,
              title: 'Товардын баасы',
              value: '$price сом',
            ),

            infoCard(
              icon: Icons.local_shipping,
              title: 'Жеткирүү акысы',
              value: '$delivery сом',
            ),

            Card(
              elevation: 3,
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.account_balance_wallet),
                ),
                title: const Text(
                  'Жалпы сумма',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '$total сом',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            Card(
              child: ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text(
                  'Төлөм статусу',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  data['paymentStatus'] ?? 'Төлөнө элек',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            const SizedBox(height: 15),

            if ((data['paymentStatus'] ?? 'Төлөнө элек') != 'Төлөндү')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PaymentPage(orderId: data['id'], total: total),
                      ),
                    );

                    if (result == true && mounted) {
                      setState(() {
                        widget.data['paymentStatus'] = 'Төлөндү';
                      });
                    }
                  },
                  icon: const Icon(Icons.payment),
                  label: Text(
                    'Төлөө $total сом',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // ================= PAYMENT STATUS =================
            Card(
              child: ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text(
                  'Төлөмдүн абалы',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  data['paymentStatus'] ?? 'Төлөнө элек',
                  style: const TextStyle(fontSize: 17),
                ),
              ),
            ),
            // ================= ADMIN STATUS =================
            if (isAdmin) ...[
              const Text(
                'Статусту өзгөртүү',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              if (isUpdating)
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          changeStatus('Кабыл алынды');
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Кабыл алынды'),
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          changeStatus('Даярдалууда');
                        },
                        icon: const Icon(Icons.inventory),
                        label: const Text('Даярдалууда'),
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          changeStatus('Жолдо');
                        },
                        icon: const Icon(Icons.local_shipping),
                        label: const Text('Жолдо'),
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          changeStatus('Жеткирилди');
                        },
                        icon: const Icon(Icons.done_all),
                        label: const Text('Жеткирилди'),
                      ),
                    ),

                    const SizedBox(height: 8),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          changeStatus('Жокко чыгарылды');
                        },
                        icon: const Icon(Icons.cancel),
                        label: const Text('Жокко чыгарылды'),
                      ),
                    ),
                  ],
                ),
            ],

            const SizedBox(height: 25),

            // ================= DELETE =================
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: deleteOrder,
                icon: const Icon(Icons.delete),
                label: const Text(
                  'Заказды өчүрүү',
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // ================= BACK =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Артка', style: TextStyle(fontSize: 17)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Менин профилим')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(radius: 45, child: Icon(Icons.person, size: 50)),

            const SizedBox(height: 25),

            const Text(
              '👤 Аккаунт',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 25),

            Card(
              child: ListTile(
                leading: const Icon(Icons.email),
                title: const Text('Email'),
                subtitle: Text(user?.email ?? 'Email жок'),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: const Icon(Icons.fingerprint),
                title: const Text('User ID'),
                subtitle: Text(user?.uid ?? 'UID жок'),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();

                  if (!context.mounted) return;

                  Navigator.pop(context);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Аккаунттан чыгуу'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= ADMIN PANEL =================

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel 👨‍💼')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ката: ${snapshot.error}'));
          }

          final orders = snapshot.data?.docs ?? [];

          int newOrders = 0;
          int acceptedOrders = 0;
          int preparingOrders = 0;
          int onTheWayOrders = 0;
          int deliveredOrders = 0;
          int cancelledOrders = 0;

          double totalAmount = 0;

          for (final order in orders) {
            final data = order.data() as Map<String, dynamic>;

            final status = data['status'] ?? 'Жаңы заказ';

            if (status == 'Жаңы заказ') {
              newOrders++;
            } else if (status == 'Кабыл алынды') {
              acceptedOrders++;
            } else if (status == 'Даярдалууда') {
              preparingOrders++;
            } else if (status == 'Жолдо') {
              onTheWayOrders++;
            } else if (status == 'Жеткирилди') {
              deliveredOrders++;
            } else if (status == 'Жокко чыгарылды') {
              cancelledOrders++;
            }

            final amount = data['totalPrice'];

            if (amount is num) {
              totalAmount += amount.toDouble();
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(Icons.admin_panel_settings, size: 80),

                const SizedBox(height: 15),

                const Text(
                  'Admin Panel',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Заказдарды башкаруу',
                  style: TextStyle(fontSize: 17),
                ),

                const SizedBox(height: 25),

                // ================= TOTAL =================
                _statCard(
                  icon: Icons.inventory_2,
                  title: 'Бардык заказдар',
                  value: orders.length.toString(),
                ),

                const SizedBox(height: 12),

                // ================= NEW =================
                _statCard(
                  icon: Icons.fiber_new,
                  title: 'Жаңы заказдар',
                  value: newOrders.toString(),
                ),

                const SizedBox(height: 12),

                // ================= ACCEPTED =================
                _statCard(
                  icon: Icons.check_circle,
                  title: 'Кабыл алынган',
                  value: acceptedOrders.toString(),
                ),

                const SizedBox(height: 12),

                // ================= PREPARING =================
                _statCard(
                  icon: Icons.inventory,
                  title: 'Даярдалууда',
                  value: preparingOrders.toString(),
                ),

                const SizedBox(height: 12),

                // ================= ON THE WAY =================
                _statCard(
                  icon: Icons.local_shipping,
                  title: 'Жолдо',
                  value: onTheWayOrders.toString(),
                ),

                const SizedBox(height: 12),

                // ================= DELIVERED =================
                _statCard(
                  icon: Icons.done_all,
                  title: 'Жеткирилди',
                  value: deliveredOrders.toString(),
                ),

                const SizedBox(height: 12),

                // ================= CANCELLED =================
                _statCard(
                  icon: Icons.cancel,
                  title: 'Жокко чыгарылды',
                  value: cancelledOrders.toString(),
                ),

                const SizedBox(height: 20),

                // ================= MONEY =================
                Card(
                  elevation: 3,
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.payments)),
                    title: const Text(
                      'Жалпы заказ суммасы',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${totalAmount.toStringAsFixed(0)} сом',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // ================= SEARCH ORDERS =================
                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminOrderSearchPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.search),
                    label: const Text(
                      'Заказ издөө 🔎',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),

                const SizedBox(height: 15),
                // ================= ALL ORDERS =================
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyOrdersPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.inventory),
                    label: const Text(
                      'Бардык заказдар',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // ================= REFRESH =================
                OutlinedButton.icon(
                  onPressed: () {
                    // Stream автоматтык түрдө жаңыланат.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Маалымат автоматтык жаңыланат ✅'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Жаңыртуу'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= STAT CARD =================

  static Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 3,
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ================= ADMIN ORDER SEARCH =================

class AdminOrderSearchPage extends StatefulWidget {
  const AdminOrderSearchPage({super.key});

  @override
  State<AdminOrderSearchPage> createState() => _AdminOrderSearchPageState();
}

class _AdminOrderSearchPageState extends State<AdminOrderSearchPage> {
  final searchController = TextEditingController();

  String searchText = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  bool matchesSearch(Map<String, dynamic> data) {
    if (searchText.trim().isEmpty) {
      return true;
    }

    final search = searchText.trim().toLowerCase();

    final orderNumber = (data['orderNumber'] ?? '').toString().toLowerCase();

    final phone = (data['phone'] ?? '').toString().toLowerCase();

    final product = (data['product'] ?? '').toString().toLowerCase();

    final email = (data['email'] ?? '').toString().toLowerCase();

    return orderNumber.contains(search) ||
        phone.contains(search) ||
        product.contains(search) ||
        email.contains(search);
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'Жаңы заказ':
        return Colors.orange;
      case 'Кабыл алынды':
        return Colors.blue;
      case 'Даярдалууда':
        return Colors.amber;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Заказ издөө 🔎')),
      body: Column(
        children: [
          // ================= SEARCH =================
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Заказ издөө',
                hintText: 'Заказ №, телефон, товар же Email',
                prefixIcon: const Icon(Icons.search),
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
                border: const OutlineInputBorder(),
              ),
            ),
          ),

          // ================= ORDERS =================
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
                  return Center(child: Text('Ката: ${snapshot.error}'));
                }

                final documents = snapshot.data?.docs ?? [];

                final filteredOrders = documents.where((order) {
                  final data = order.data() as Map<String, dynamic>;

                  return matchesSearch(data);
                }).toList();

                if (filteredOrders.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 70),
                        SizedBox(height: 15),
                        Text(
                          'Заказ табылган жок 📦',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];

                    final data = order.data() as Map<String, dynamic>;

                    final status = data['status'] ?? 'Жаңы заказ';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(15),

                        leading: CircleAvatar(child: Text('${index + 1}')),

                        title: Text(
                          '№ ${data['orderNumber'] ?? 'Жок'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('📦 ${data['product'] ?? 'Товар жок'}'),
                              Text('📞 ${data['phone'] ?? 'Телефон жок'}'),
                              Text('👤 ${data['email'] ?? 'Email жок'}'),
                              const SizedBox(height: 6),
                              Chip(
                                label: Text('📦 $status'),
                                backgroundColor: getStatusColor(
                                  status,
                                ).withValues(alpha: 0.15),
                              ),
                            ],
                          ),
                        ),

                        trailing: const Icon(Icons.arrow_forward_ios, size: 18),

                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderDetailsPage(data: data),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
