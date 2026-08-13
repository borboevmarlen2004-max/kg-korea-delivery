import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'admin_chat_detail_page.dart';

class AdminChatPage extends StatefulWidget {
  const AdminChatPage({super.key});

  @override
  State<AdminChatPage> createState() => _AdminChatPageState();
}

class _AdminChatPageState extends State<AdminChatPage> {
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

  // =========================================================
  // 🌍 TRANSLATIONS
  // =========================================================

  String t(String key) {
    const translations = <String, Map<String, String>>{
      'customerChats': {
        'ky': '💬 Кардарлардын чаты',
        'ru': '💬 Чат с клиентами',
        'en': '💬 Customer Chats',
        'ko': '💬 고객 채팅',
      },
      'error': {'ky': 'Ката', 'ru': 'Ошибка', 'en': 'Error', 'ko': '오류'},
      'customers': {
        'ky': 'Кардарлар',
        'ru': 'Клиенты',
        'en': 'Customers',
        'ko': '고객',
      },
      'customersChat': {
        'ky': 'кардар менен чат',
        'ru': 'клиентов в чате',
        'en': 'customers in chat',
        'ko': '명의 고객과 채팅',
      },
      'active': {
        'ky': 'Активдүү',
        'ru': 'Активные',
        'en': 'Active',
        'ko': '활성',
      },
      'unknownCustomer': {
        'ky': 'Белгисиз кардар',
        'ru': 'Неизвестный клиент',
        'en': 'Unknown customer',
        'ko': '알 수 없는 고객',
      },
      'noMessage': {
        'ky': 'Билдирүү жок',
        'ru': 'Нет сообщения',
        'en': 'No message',
        'ko': '메시지 없음',
      },
      'noCustomers': {
        'ky': 'Кардарлар жок',
        'ru': 'Клиентов нет',
        'en': 'No customers',
        'ko': '고객이 없습니다',
      },
      'noCustomersDescription': {
        'ky':
            'Кардарлар билдирүү жөнөткөндө,\nалардын чаттары бул жерде көрүнөт.',
        'ru': 'Когда клиенты отправят сообщение,\nих чаты появятся здесь.',
        'en': 'When customers send messages,\ntheir chats will appear here.',
        'ko': '고객이 메시지를 보내면\n여기에 채팅이 표시됩니다.',
      },
    };

    return translations[key]?[currentLanguage] ??
        translations[key]?['ky'] ??
        key;
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
          t('customerChats'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .orderBy('createdAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
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

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return _emptyState();
          }

          // =================================================
          // 👤 АР БИР КАРДАРДЫ БИР ГАНА ЖОЛУ КӨРСӨТӨБҮЗ
          // =================================================

          final Map<String, QueryDocumentSnapshot> uniqueChats = {};

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;

            final uid = data['uid']?.toString() ?? '';

            // Admin өзү кардарлардын тизмесине кирбейт
            if (uid.isEmpty || uid == 'admin') {
              continue;
            }

            if (!uniqueChats.containsKey(uid)) {
              uniqueChats[uid] = doc;
            }
          }

          final chats = uniqueChats.values.toList();

          if (chats.isEmpty) {
            return _emptyState();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // =================================================
              // 📊 HEADER
              // =================================================
              Container(
                width: double.infinity,
                color: Colors.white,

                padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),

                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,

                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: const Icon(
                        Icons.support_agent,
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
                            t('customers'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            '${chats.length} ${t('customersChat')}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),

                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Row(
                        mainAxisSize: MainAxisSize.min,

                        children: [
                          Container(
                            width: 8,
                            height: 8,

                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),

                          const SizedBox(width: 6),

                          Text(
                            t('active'),
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // =================================================
              // 💬 CHAT LIST
              // =================================================
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 5, 14, 25),

                  itemCount: chats.length,

                  itemBuilder: (context, index) {
                    final data = chats[index].data() as Map<String, dynamic>;

                    final uid = data['uid']?.toString() ?? '';

                    final email =
                        data['email']?.toString() ?? t('unknownCustomer');

                    final message = data['message']?.toString() ?? '';

                    String time = '';

                    if (data['createdAt'] != null &&
                        data['createdAt'] is Timestamp) {
                      final date = (data['createdAt'] as Timestamp).toDate();

                      time =
                          '${date.hour.toString().padLeft(2, '0')}:'
                          '${date.minute.toString().padLeft(2, '0')}';
                    }

                    return _buildChatCard(
                      context: context,
                      uid: uid,
                      email: email,
                      message: message,
                      time: time,
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

  // =========================================================
  // 💬 CHAT CARD
  // =========================================================

  Widget _buildChatCard({
    required BuildContext context,
    required String uid,
    required String email,
    required String message,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Material(
        color: Colors.transparent,

        child: InkWell(
          borderRadius: BorderRadius.circular(20),

          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminChatDetailPage(uid: uid, email: email),
              ),
            );
          },

          child: Padding(
            padding: const EdgeInsets.all(15),

            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,

              children: [
                // =================================================
                // 👤 AVATAR
                // =================================================
                Container(
                  width: 55,
                  height: 55,

                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    shape: BoxShape.circle,

                    border: Border.all(color: const Color(0xFFBBDEFB)),
                  ),

                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF1565C0),
                    size: 28,
                  ),
                ),

                const SizedBox(width: 13),

                // =================================================
                // 📧 EMAIL + MESSAGE
                // =================================================
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              email,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,

                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          if (time.isNotEmpty) ...[
                            const SizedBox(width: 8),

                            Text(
                              time,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 7),

                      Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline,
                            size: 15,
                            color: Colors.grey,
                          ),

                          const SizedBox(width: 6),

                          Expanded(
                            child: Text(
                              message.isEmpty ? t('noMessage') : message,

                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,

                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // =================================================
                // ➡️
                // =================================================
                Container(
                  width: 32,
                  height: 32,

                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: const Icon(
                    Icons.arrow_forward_ios,
                    size: 13,
                    color: Colors.grey,
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
  // 📭 EMPTY STATE
  // =========================================================

  Widget _emptyState() {
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
                Icons.chat_bubble_outline,
                size: 52,
                color: Color(0xFF1565C0),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              t('noCustomers'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              t('noCustomersDescription'),
              textAlign: TextAlign.center,

              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
