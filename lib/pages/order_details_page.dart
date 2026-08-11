import 'package:flutter/material.dart';
import 'payment_page.dart';

class OrderDetailsPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const OrderDetailsPage({super.key, required this.data});

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
    final orderNumber = data['orderNumber']?.toString() ?? 'Жок';

    final direction = data['direction']?.toString() ?? 'Белгисиз';

    final product = data['product']?.toString() ?? 'Белгисиз';

    final from = data['from']?.toString() ?? 'Көрсөтүлгөн эмес';

    final to = data['to']?.toString() ?? 'Көрсөтүлгөн эмес';

    final phone = data['phone']?.toString() ?? 'Көрсөтүлгөн эмес';

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

        title: const Text(
          '📦 Заказ жөнүндө',
          style: TextStyle(fontWeight: FontWeight.bold),
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
                    color: const Color(0xFF1565C0).withOpacity(0.18),
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
                      color: Colors.white.withOpacity(0.16),
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
                        const Text(
                          'Заказ',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
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
                          direction,
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
            const Text(
              '📊 Заказдын статусу',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      color: statusColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: Icon(
                      getStatusIcon(status),
                      color: statusColor,
                      size: 25,
                    ),
                  ),

                  const SizedBox(width: 13),

                  const Expanded(
                    child: Text(
                      'Учурдагы статус',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),

                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),

                    child: Text(
                      status,
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
            const Text(
              '📦 Заказ маалыматы',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  detail(Icons.inventory_2_outlined, 'Товар', product),

                  _divider(),

                  detail(Icons.swap_horiz, 'Багыты', direction),

                  _divider(),

                  detail(Icons.location_on_outlined, 'Кайдан', from),

                  _divider(),

                  detail(Icons.location_searching, 'Кайда', to),

                  _divider(),

                  detail(Icons.phone_outlined, 'Телефон', phone),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =================================================
            // 💰 PAYMENT
            // =================================================
            const Text(
              '💰 Төлөм маалыматы',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  _priceRow('Товар', '$price сом'),

                  const SizedBox(height: 11),

                  _priceRow('Жеткирүү', '$deliveryFee сом'),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 13),

                    child: Divider(height: 1),
                  ),

                  Row(
                    children: [
                      const Text(
                        'Жалпы сумма',
                        style: TextStyle(
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
                          ? Colors.green.withOpacity(0.08)
                          : Colors.orange.withOpacity(0.08),
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
                            'Төлөм: $paymentStatus',
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

                label: const Text(
                  'Төлөмгө өтүү',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
