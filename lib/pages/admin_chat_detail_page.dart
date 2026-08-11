import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminChatDetailPage extends StatefulWidget {
  final String uid;
  final String email;

  const AdminChatDetailPage({
    super.key,
    required this.uid,
    required this.email,
  });

  @override
  State<AdminChatDetailPage> createState() => _AdminChatDetailPageState();
}

class _AdminChatDetailPageState extends State<AdminChatDetailPage> {
  final messageController = TextEditingController();

  bool isSending = false;

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  // =========================================================
  // 📤 АДМИН ЖООБУН ЖӨНӨТҮҮ
  // =========================================================

  Future<void> sendReply() async {
    final message = messageController.text.trim();

    if (message.isEmpty || isSending) {
      return;
    }

    setState(() {
      isSending = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.uid)
          .collection('messages')
          .add({
            'message': message,
            'email': 'Admin',
            'uid': 'admin',
            'createdAt': FieldValue.serverTimestamp(),
          });

      messageController.clear();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Жооп жөнөтүүдө ката: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  // =========================================================
  // 💬 MESSAGE BUBBLE
  // =========================================================

  Widget buildMessageBubble(Map<String, dynamic> data) {
    final isAdmin = data['uid'] == 'admin';

    final message = data['message']?.toString() ?? '';

    String time = '';

    final createdAt = data['createdAt'];

    if (createdAt != null && createdAt is Timestamp) {
      final date = createdAt.toDate();

      final hour = date.hour.toString().padLeft(2, '0');

      final minute = date.minute.toString().padLeft(2, '0');

      time = '$hour:$minute';
    }

    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,

      child: Container(
        constraints: const BoxConstraints(maxWidth: 310),

        margin: EdgeInsets.only(
          left: isAdmin ? 55 : 8,
          right: isAdmin ? 8 : 55,
          bottom: 12,
        ),

        padding: const EdgeInsets.fromLTRB(15, 12, 15, 10),

        decoration: BoxDecoration(
          color: isAdmin ? const Color(0xFF1565C0) : Colors.white,

          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isAdmin ? 20 : 5),
            bottomRight: Radius.circular(isAdmin ? 5 : 20),
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],

          border: isAdmin ? null : Border.all(color: Colors.grey.shade200),
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAdmin ? Icons.admin_panel_settings : Icons.person,
                  size: 15,
                  color: isAdmin ? Colors.white70 : Colors.grey.shade600,
                ),

                const SizedBox(width: 5),

                Text(
                  isAdmin ? 'Админ' : 'Кардар',

                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isAdmin ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              message,

              style: TextStyle(
                fontSize: 16,
                height: 1.3,
                color: isAdmin ? Colors.white : Colors.black87,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              time,

              style: TextStyle(
                fontSize: 10,
                color: isAdmin ? Colors.white70 : Colors.grey,
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,

        titleSpacing: 12,

        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,

              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                shape: BoxShape.circle,
              ),

              child: const Icon(Icons.person, color: Color(0xFF1565C0)),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    widget.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 2),

                  const Row(
                    children: [
                      Icon(Icons.support_agent, size: 12, color: Colors.green),

                      SizedBox(width: 4),

                      Text(
                        'Кардар менен чат',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          // =================================================
          // 💬 MESSAGES
          // =================================================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.uid)
                  .collection('messages')
                  .orderBy('createdAt')
                  .snapshots(),

              builder: (context, snapshot) {
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

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        Container(
                          width: 90,
                          height: 90,

                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(28),
                          ),

                          child: const Icon(
                            Icons.chat_bubble_outline,
                            size: 48,
                            color: Color(0xFF1565C0),
                          ),
                        ),

                        const SizedBox(height: 18),

                        const Text(
                          'Билдирүүлөр жок',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 7),

                        const Text(
                          'Кардарга биринчи жоопту жазыңыз.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 15, 14, 15),

                  itemCount: docs.length,

                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    return buildMessageBubble(data);
                  },
                );
              },
            ),
          ),

          // =================================================
          // ✍️ INPUT
          // =================================================
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),

            decoration: const BoxDecoration(color: Colors.white),

            child: SafeArea(
              top: false,

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,

                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,

                      minLines: 1,
                      maxLines: 5,

                      textInputAction: TextInputAction.newline,

                      decoration: InputDecoration(
                        hintText: 'Кардарга жооп жазыңыз...',

                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),

                        filled: true,

                        fillColor: const Color(0xFFF5F7FA),

                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 17,
                          vertical: 13,
                        ),

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: Color(0xFF1565C0),
                            width: 1.2,
                          ),
                        ),
                      ),

                      onSubmitted: (_) {
                        if (!isSending) {
                          sendReply();
                        }
                      },
                    ),
                  ),

                  const SizedBox(width: 9),

                  GestureDetector(
                    onTap: isSending ? null : sendReply,

                    child: Container(
                      width: 50,
                      height: 50,

                      decoration: BoxDecoration(
                        color: isSending
                            ? Colors.grey
                            : const Color(0xFF1565C0),
                        shape: BoxShape.circle,
                      ),

                      child: isSending
                          ? const Padding(
                              padding: EdgeInsets.all(15),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 23,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
