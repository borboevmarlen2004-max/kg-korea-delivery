import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'order_details_page.dart';

class AdminSearchPage extends StatefulWidget {
  const AdminSearchPage({super.key});

  @override
  State<AdminSearchPage> createState() => _AdminSearchPageState();
}

class _AdminSearchPageState extends State<AdminSearchPage> {
  final TextEditingController searchController = TextEditingController();

  String searchText = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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

        title: const Text(
          '🔍 Заказ издөө',
          style: TextStyle(fontWeight: FontWeight.bold),
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
                const Text(
                  'Заказды табуу',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Заказ №, телефон же Email аркылуу издеңиз',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: searchController,

                  textInputAction: TextInputAction.search,

                  decoration: InputDecoration(
                    hintText: 'Заказ №, телефон же Email...',

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
                        'Ката: ${snapshot.error}',
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
                            '${filteredOrders.length} заказ табылды',
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
    final orderNumber = data['orderNumber']?.toString() ?? 'Заказ';

    final product = data['product']?.toString() ?? 'Товар көрсөтүлгөн эмес';

    final phone = data['phone']?.toString() ?? 'Телефон жок';

    final email = data['email']?.toString() ?? 'Email жок';

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
            color: Colors.black.withOpacity(0.04),
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

                const SizedBox(height: 15),

                Divider(height: 1, color: Colors.grey.shade200),

                const SizedBox(height: 14),

                // ==========================================
                // 👤 USER INFO
                // ==========================================
                _infoRow(Icons.phone_outlined, 'Телефон', phone),

                const SizedBox(height: 9),

                _infoRow(Icons.email_outlined, 'Email', email),

                if (direction.isNotEmpty) ...[
                  const SizedBox(height: 9),

                  _infoRow(Icons.swap_horiz, 'Багыт', direction),
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

                      const Text(
                        'Жалпы сумма',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
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
                      'Толук маалымат',
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
              hasSearch ? 'Заказ табылган жок' : 'Заказдар жок',

              textAlign: TextAlign.center,

              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              hasSearch
                  ? 'Издөө сөзүңүздү же маалыматты текшерип көрүңүз.'
                  : 'Азырынча заказдар жок.',

              textAlign: TextAlign.center,

              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
