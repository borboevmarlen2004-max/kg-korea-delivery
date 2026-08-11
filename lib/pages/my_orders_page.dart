import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'login_page.dart';
import 'order_details_page.dart';
import 'edit_order_page.dart';

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

  // =========================================================
  // 🔄 СТАТУСТУ ӨЗГӨРТҮҮ
  // =========================================================

  Future<void> changeStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update(
        {'status': newStatus},
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Статус өзгөртүлдү: $newStatus ✅')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Статус өзгөртүүдө ката: $e')));
    }
  }

  // =========================================================
  // 🗑️ ЗАКАЗДЫ ӨЧҮРҮҮ
  // =========================================================

  Future<void> deleteOrder(String orderId) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Заказ өчүрүлдү 🗑️')));
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Өчүрүүдө ката: $e')));
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
  // 📊 ORDER PROGRESS
  // =========================================================

  Widget buildOrderProgress(String status) {
    const statuses = [
      'Жаңы заказ',
      'Кабыл алынды',
      'Даярдалууда',
      'Жолдо',
      'Жеткирилди',
    ];

    final currentIndex = statuses.indexOf(status);

    if (status == 'Жокко чыгарылды') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.red.withOpacity(0.18)),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: Colors.red),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Бул заказ жокко чыгарылган',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.route_outlined, size: 19, color: Color(0xFF1565C0)),
              SizedBox(width: 7),
              Text(
                'Заказдын жүрүшү',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            children: List.generate(statuses.length, (index) {
              final isCompleted = currentIndex >= index;

              final isCurrent = currentIndex == index;

              final color = isCompleted
                  ? getStatusColor(statuses[index])
                  : Colors.grey.shade300;

              return Expanded(
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: isCurrent ? 27 : 21,
                      height: isCurrent ? 27 : 21,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.30),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                      child: isCompleted
                          ? const Icon(
                              Icons.check,
                              size: 13,
                              color: Colors.white,
                            )
                          : null,
                    ),

                    if (index < statuses.length - 1)
                      Expanded(
                        child: Container(
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: currentIndex > index
                                ? getStatusColor(statuses[index])
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 10),

          Row(
            children: statuses.map((item) {
              final selected = item == status;

              return Expanded(
                child: Text(
                  item,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected ? getStatusColor(status) : Colors.grey,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // 🔀 BUYER + SELLER ORDERS
  // =========================================================

  List<QueryDocumentSnapshot<Map<String, dynamic>>> combineOrders(
    QuerySnapshot<Map<String, dynamic>> buyerSnapshot,
    QuerySnapshot<Map<String, dynamic>> sellerSnapshot,
  ) {
    final Map<String, QueryDocumentSnapshot<Map<String, dynamic>>>
    uniqueOrders = {};

    for (final order in buyerSnapshot.docs) {
      uniqueOrders[order.id] = order;
    }

    for (final order in sellerSnapshot.docs) {
      uniqueOrders[order.id] = order;
    }

    final orders = uniqueOrders.values.toList();

    orders.sort((a, b) {
      final aTime = a.data()['createdAt'];
      final bTime = b.data()['createdAt'];

      if (aTime == null && bTime == null) {
        return 0;
      }

      if (aTime == null) {
        return 1;
      }

      if (bTime == null) {
        return -1;
      }

      return bTime.compareTo(aTime);
    });

    return orders;
  }

  // =========================================================
  // 🏷️ MARKETPLACE BADGE
  // =========================================================

  Widget buildMarketplaceBadge(bool isSeller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSeller ? Icons.store_outlined : Icons.shopping_cart_outlined,
            size: 17,
            color: const Color(0xFF1565C0),
          ),

          const SizedBox(width: 6),

          Text(
            isSeller ? 'Товарыңыз сатылды' : 'Marketplace сатып алуу',
            style: const TextStyle(
              color: Color(0xFF1565C0),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // 📦 ORDER CARD
  // =========================================================

  Widget buildOrderCard(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> order,
    bool isAdmin,
  ) {
    final data = order.data();

    final createdAt = data['createdAt'];

    final formattedDate = createdAt != null
        ? DateFormat('dd.MM.yyyy, HH:mm').format(createdAt.toDate())
        : 'Дата жок';

    final status = data['status'] ?? 'Жаңы заказ';

    final isMarketplace = data['direction'] == 'Marketplace';

    final sellerEmail = data['sellerEmail']?.toString() ?? '';

    final currentUser = FirebaseAuth.instance.currentUser;

    final isSeller =
        isMarketplace &&
        sellerEmail.isNotEmpty &&
        sellerEmail == currentUser?.email;

    final statusColor = getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(23),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    OrderDetailsPage(data: {...data, 'id': order.id}),
              ),
            );
          },

          child: Padding(
            padding: const EdgeInsets.all(17),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =========================================
                // TOP
                // =========================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: isMarketplace
                            ? const Color(0xFFE3F2FD)
                            : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        isMarketplace
                            ? (isSeller ? Icons.store : Icons.shopping_cart)
                            : Icons.local_shipping,
                        color: isMarketplace
                            ? const Color(0xFF1565C0)
                            : const Color(0xFF2E7D32),
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['product']?.toString() ?? 'Товар',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Заказ № ${data['orderNumber'] ?? 'Жок'}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 7),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.10),
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
                            status,
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

                const SizedBox(height: 13),

                // =========================================
                // MARKETPLACE
                // =========================================
                if (isMarketplace)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 13),
                    child: buildMarketplaceBadge(isSeller),
                  ),

                Divider(height: 1, color: Colors.grey.shade200),

                const SizedBox(height: 15),

                // =========================================
                // DELIVERY INFO
                // =========================================
                _infoRow(
                  icon: Icons.location_on_outlined,
                  title: 'Кайдан',
                  value: data['from']?.toString() ?? '',
                ),

                const SizedBox(height: 10),

                _infoRow(
                  icon: Icons.location_searching,
                  title: 'Кайда',
                  value: data['to']?.toString() ?? '',
                ),

                const SizedBox(height: 10),

                _infoRow(
                  icon: Icons.phone_outlined,
                  title: 'Телефон',
                  value: data['phone']?.toString() ?? '',
                ),

                const SizedBox(height: 15),

                // =========================================
                // 💰 PRICE
                // =========================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _priceRow(
                        'Товар',
                        '${data['price'] ?? 'Көрсөтүлгөн эмес'} сом',
                      ),

                      const SizedBox(height: 7),

                      _priceRow(
                        'Жеткирүү',
                        '${data['deliveryFee'] ?? 'Көрсөтүлгөн эмес'} сом',
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        child: Divider(height: 1, color: Colors.grey.shade300),
                      ),

                      Row(
                        children: [
                          const Text(
                            'Жалпы',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            '${data['totalPrice'] ?? 'Көрсөтүлгөн эмес'} сом',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 11),

                // =========================================
                // DATE
                // =========================================
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 15, color: Colors.grey),

                    const SizedBox(width: 6),

                    Text(
                      'Түзүлгөн: $formattedDate',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),

                const SizedBox(height: 17),

                // =========================================
                // PROGRESS
                // =========================================
                buildOrderProgress(status),

                // =========================================
                // ADMIN / SELLER
                // =========================================
                if (isAdmin || isSeller) ...[
                  const SizedBox(height: 17),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.admin_panel_settings_outlined,
                              size: 18,
                              color: Color(0xFF1565C0),
                            ),

                            const SizedBox(width: 7),

                            const Text(
                              'Статусту башкаруу',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 11),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: status,
                              isExpanded: true,

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
                                if (newStatus == null) {
                                  return;
                                }

                                await changeStatus(order.id, newStatus);
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 11),

                        Wrap(
                          spacing: 7,
                          runSpacing: 7,
                          children: [
                            _statusButton(
                              order.id,
                              'Кабыл алынды',
                              '✅',
                              Colors.blue,
                            ),
                            _statusButton(
                              order.id,
                              'Даярдалууда',
                              '🟡',
                              Colors.orange,
                            ),
                            _statusButton(
                              order.id,
                              'Жолдо',
                              '🚚',
                              Colors.deepOrange,
                            ),
                            _statusButton(
                              order.id,
                              'Жеткирилди',
                              '📦',
                              Colors.green,
                            ),
                            _statusButton(
                              order.id,
                              'Жокко чыгарылды',
                              '❌',
                              Colors.red,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // =========================================
                // ✏️ EDIT
                // =========================================
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditOrderPage(orderId: order.id, data: data),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Заказды түзөтүү'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1565C0),
                      side: const BorderSide(color: Color(0xFF1565C0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 9),

                // =========================================
                // 🗑️ DELETE
                // =========================================
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text(
                              'Заказды өчүрүү?',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            content: const Text(
                              'Бул заказ өчүрүлөт. Улантасызбы?',
                            ),
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
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Өчүрүү'),
                              ),
                            ],
                          );
                        },
                      );

                      if (shouldDelete == true) {
                        await deleteOrder(order.id);
                      }
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Заказды өчүрүү'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
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

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 19, color: const Color(0xFF1565C0)),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),

              const SizedBox(height: 2),

              Text(
                value.isEmpty ? 'Көрсөтүлгөн эмес' : value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
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
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // =========================================================
  // 🔘 STATUS BUTTON
  // =========================================================

  Widget _statusButton(
    String orderId,
    String status,
    String emoji,
    Color color,
  ) {
    return OutlinedButton(
      onPressed: () {
        changeStatus(orderId, status);
      },

      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      child: Text('$emoji $status', style: const TextStyle(fontSize: 12)),
    );
  }

  // =========================================================
  // 📭 EMPTY
  // =========================================================

  Widget buildEmptyOrders() {
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

              child: const Icon(
                Icons.inventory_2_outlined,
                size: 54,
                color: Color(0xFF1565C0),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              selectedStatus == 'Баары'
                  ? 'Сизде азырынча заказ жок'
                  : '$selectedStatus боюнча заказ жок',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              'Заказдарыңыз бул жерде көрсөтүлөт.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================
  // 📋 ORDERS LIST
  // =========================================================

  Widget buildOrdersList(
    BuildContext context,
    List<QueryDocumentSnapshot<Map<String, dynamic>>> orders,
    bool isAdmin,
  ) {
    final filteredOrders = selectedStatus == 'Баары'
        ? orders
        : orders.where((order) {
            return order.data()['status'] == selectedStatus;
          }).toList();

    if (filteredOrders.isEmpty) {
      return buildEmptyOrders();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),

      itemCount: filteredOrders.length,

      itemBuilder: (context, index) {
        return buildOrderCard(context, filteredOrders[index], isAdmin);
      },
    );
  }

  // =========================================================
  // 🔘 STATUS FILTERS
  // =========================================================

  Widget buildStatusFilters() {
    return Container(
      color: Colors.white,

      height: 72,

      child: ListView(
        scrollDirection: Axis.horizontal,

        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),

        children: statusFilters.map((filter) {
          final selected = selectedStatus == filter;

          final color = filter == 'Баары'
              ? const Color(0xFF1565C0)
              : getStatusColor(filter);

          return Padding(
            padding: const EdgeInsets.only(right: 8),

            child: ChoiceChip(
              avatar: selected
                  ? const Icon(Icons.check, size: 15, color: Colors.white)
                  : null,

              label: Text(filter),

              selected: selected,

              selectedColor: color,

              backgroundColor: const Color(0xFFF5F7FA),

              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: selected ? color : Colors.grey.shade300,
                ),
              ),

              onSelected: (_) {
                setState(() {
                  selectedStatus = filter;
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  // =========================================================
  // 🏠 BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    const adminEmail = 'miki@gmail.com';

    final isAdmin = user?.email == adminEmail;

    final currentUserEmail = user?.email ?? '';

    if (user == null) {
      return const LoginPage();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,

        title: const Text(
          '📦 Менин заказдарым',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: isAdmin
            ? FirebaseFirestore.instance
                  .collection('orders')
                  .orderBy('createdAt', descending: true)
                  .snapshots()
            : FirebaseFirestore.instance
                  .collection('orders')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),

        builder: (context, buyerSnapshot) {
          if (buyerSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (buyerSnapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Ката: ${buyerSnapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // =================================================
          // 👨‍💼 ADMIN
          // =================================================

          if (isAdmin) {
            final orders = buyerSnapshot.data?.docs ?? [];

            return Column(
              children: [
                buildStatusFilters(),

                Expanded(child: buildOrdersList(context, orders, true)),
              ],
            );
          }

          // =================================================
          // 👤 USER
          // =================================================

          final buyerOrders = buyerSnapshot.data?.docs ?? [];

          // =================================================
          // 🏪 SELLER ORDERS
          // =================================================

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('sellerEmail', isEqualTo: currentUserEmail)
                .snapshots(),

            builder: (context, sellerSnapshot) {
              if (sellerSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (sellerSnapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Ката: ${sellerSnapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              final allOrders = combineOrders(
                buyerSnapshot.data!,
                sellerSnapshot.data!,
              );

              return Column(
                children: [
                  buildStatusFilters(),

                  Expanded(child: buildOrdersList(context, allOrders, false)),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
