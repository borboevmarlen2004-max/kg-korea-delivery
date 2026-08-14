import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const PaymentPage({super.key, required this.data});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool isPaying = false;
  String currentLanguage = 'ky';

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
    const translations = <String, Map<String, String>>{
      'payment': {
        'ky': '💳 Төлөм',
        'ru': '💳 Оплата',
        'en': '💳 Payment',
        'ko': '💳 결제',
      },

      'totalPayment': {
        'ky': 'Төлөмдүн жалпы суммасы',
        'ru': 'Общая сумма оплаты',
        'en': 'Total payment amount',
        'ko': '총 결제 금액',
      },

      'orderInfo': {
        'ky': '📦 Заказ маалыматы',
        'ru': '📦 Информация о заказе',
        'en': '📦 Order information',
        'ko': '📦 주문 정보',
      },

      'orderNumber': {
        'ky': 'Заказ №',
        'ru': 'Заказ №',
        'en': 'Order No.',
        'ko': '주문 번호',
      },

      'product': {'ky': 'Товар', 'ru': 'Товар', 'en': 'Product', 'ko': '상품'},

      'total': {
        'ky': 'Жалпы сумма',
        'ru': 'Общая сумма',
        'en': 'Total',
        'ko': '총 금액',
      },

      'paymentStatus': {
        'ky': 'Төлөмдүн абалы',
        'ru': 'Статус оплаты',
        'en': 'Payment status',
        'ko': '결제 상태',
      },

      'notPaid': {
        'ky': 'Төлөнө элек',
        'ru': 'Не оплачено',
        'en': 'Not paid',
        'ko': '미결제',
      },

      'paid': {'ky': 'Төлөндү', 'ru': 'Оплачено', 'en': 'Paid', 'ko': '결제 완료'},

      'paying': {
        'ky': 'Төлөнүүдө...',
        'ru': 'Оплата...',
        'en': 'Processing payment...',
        'ko': '결제 중...',
      },

      'paymentCompleted': {
        'ky': 'Төлөм аткарылды',
        'ru': 'Оплата выполнена',
        'en': 'Payment completed',
        'ko': '결제 완료',
      },

      'pay': {'ky': 'Төлөө', 'ru': 'Оплатить', 'en': 'Pay', 'ko': '결제하기'},

      'securePayment': {
        'ky': '🔒 Төлөм коопсуз түрдө иштетилет',
        'ru': '🔒 Платёж обрабатывается безопасно',
        'en': '🔒 Payment is processed securely',
        'ko': '🔒 결제는 안전하게 처리됩니다',
      },

      'paymentSuccess': {
        'ky': '✅ Төлөм ийгиликтүү аткарылды',
        'ru': '✅ Оплата успешно выполнена',
        'en': '✅ Payment completed successfully',
        'ko': '✅ 결제가 성공적으로 완료되었습니다',
      },

      'paymentError': {
        'ky': 'Төлөмдө ката',
        'ru': 'Ошибка при оплате',
        'en': 'Payment error',
        'ko': '결제 오류',
      },
    };

    return translations[key]?[currentLanguage] ??
        translations[key]?['ky'] ??
        key;
  }

  // =========================================================
  // 💳 PAYMENT
  // =========================================================

  Future<void> pay() async {
    if (isPaying) return;

    setState(() {
      isPaying = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.data['id'])
          .update({'paymentStatus': 'Төлөндү'});

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t('paymentSuccess'))));

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${t('paymentError')}: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isPaying = false;
        });
      }
    }
  }

  // =========================================================
  // 🏗️ BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final orderNumber = widget.data['orderNumber']?.toString() ?? '';

    final totalPrice = widget.data['totalPrice']?.toString() ?? '0';

    final product = widget.data['product']?.toString() ?? '';

    final paymentStatus =
        widget.data['paymentStatus']?.toString() ?? 'Төлөнө элек';

    final isPaid = paymentStatus == 'Төлөндү';

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
          t('payment'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // =====================================================
      // BODY
      // =====================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // =================================================
            // 💳 PAYMENT HEADER
            // =================================================
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(22),

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

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Container(
                    width: 55,
                    height: 55,

                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),

                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.credit_card,
                      color: Colors.white,
                      size: 29,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    t('totalPayment'),

                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '$totalPrice сом',

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // =================================================
            // 📦 ORDER INFO
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
                  _infoRow(
                    Icons.receipt_long_outlined,
                    t('orderNumber'),
                    orderNumber,
                  ),

                  _divider(),

                  _infoRow(Icons.inventory_2_outlined, t('product'), product),

                  _divider(),

                  _infoRow(
                    Icons.payments_outlined,
                    t('total'),
                    '$totalPrice сом',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // =================================================
            // 💰 PAYMENT STATUS
            // =================================================
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(17),

              decoration: BoxDecoration(
                color: isPaid
                    ? Colors.green.withValues(alpha: 0.08)
                    : Colors.orange.withValues(alpha: 0.08),

                borderRadius: BorderRadius.circular(20),

                border: Border.all(
                  color: isPaid
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.orange.withValues(alpha: 0.2),
                ),
              ),

              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,

                    decoration: BoxDecoration(
                      color: isPaid
                          ? Colors.green.withValues(alpha: 0.12)
                          : Colors.orange.withValues(alpha: 0.12),

                      shape: BoxShape.circle,
                    ),

                    child: Icon(
                      isPaid ? Icons.check_circle : Icons.pending_outlined,

                      color: isPaid ? Colors.green : Colors.orange,

                      size: 25,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Text(
                          t('paymentStatus'),

                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          isPaid ? t('paid') : t('notPaid'),

                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,

                            color: isPaid ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // =================================================
            // 💳 PAY BUTTON
            // =================================================
            SizedBox(
              width: double.infinity,
              height: 58,

              child: ElevatedButton.icon(
                onPressed: isPaid || isPaying ? null : pay,

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1565C0),

                  foregroundColor: Colors.white,

                  disabledBackgroundColor: Colors.grey.shade300,

                  disabledForegroundColor: Colors.grey.shade600,

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),

                icon: isPaying
                    ? const SizedBox(
                        width: 22,
                        height: 22,

                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(isPaid ? Icons.check_circle : Icons.payment),

                label: Text(
                  isPaying
                      ? t('paying')
                      : isPaid
                      ? t('paymentCompleted')
                      : t('pay'),

                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Center(
              child: Text(
                t('securePayment'),

                style: const TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ),
          ],
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
        Container(
          width: 40,
          height: 40,

          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),

            borderRadius: BorderRadius.circular(12),
          ),

          child: Icon(icon, color: const Color(0xFF1565C0), size: 20),
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

              const SizedBox(height: 3),

              Text(
                value,

                maxLines: 2,

                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // =========================================================
  // DIVIDER
  // =========================================================

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),

      child: Divider(height: 1, color: Colors.grey.shade200),
    );
  }
}
