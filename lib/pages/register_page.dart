import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String message = '';
  bool isLoading = false;
  bool hidePassword = true;

  // =========================================================
  // 📝 КАТТАЛУУ
  // =========================================================

  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        message = 'Email жана пароль толтуруңуз';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        message = 'Пароль кеминде 6 белгиден турушу керек';
      });
      return;
    }

    setState(() {
      isLoading = true;
      message = '';
    });

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String errorMessage;

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Бул Email менен аккаунт мурунтан бар';
          break;

        case 'invalid-email':
          errorMessage = 'Email туура эмес жазылды';
          break;

        case 'weak-password':
          errorMessage = 'Пароль өтө жөнөкөй';
          break;

        case 'operation-not-allowed':
          errorMessage = 'Email аркылуу катталуу азыр жеткиликтүү эмес';
          break;

        default:
          errorMessage = e.message ?? 'Катталууда ката кетти';
      }

      setState(() {
        message = errorMessage;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        message = 'Күтүлбөгөн ката кетти';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // =========================================================
  // 🧹 DISPOSE
  // =========================================================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
        centerTitle: true,

        title: const Text(
          'Катталуу',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),

          child: Column(
            children: [
              // =================================================
              // 🔵 ICON
              // =================================================
              Container(
                width: 90,
                height: 90,

                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  shape: BoxShape.circle,

                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1565C0).withOpacity(0.10),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: const Center(
                  child: Text('📝', style: TextStyle(fontSize: 42)),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Жаңы аккаунт 📝',
                textAlign: TextAlign.center,

                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                'Аккаунт түзүп, Кыргызстан ↔ Корея\n'
                'кызматтарын колдонуңуз',
                textAlign: TextAlign.center,

                style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
              ),

              const SizedBox(height: 30),

              // =================================================
              // 📧 EMAIL
              // =================================================
              TextField(
                controller: emailController,

                keyboardType: TextInputType.emailAddress,

                textInputAction: TextInputAction.next,

                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'example@gmail.com',

                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Color(0xFF1565C0),
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF1565C0),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // =================================================
              // 🔐 PASSWORD
              // =================================================
              TextField(
                controller: passwordController,

                obscureText: hidePassword,

                textInputAction: TextInputAction.done,

                onSubmitted: (_) {
                  if (!isLoading) {
                    register();
                  }
                },

                decoration: InputDecoration(
                  labelText: 'Пароль',
                  hintText: 'Кеминде 6 белги',

                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Color(0xFF1565C0),
                  ),

                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },

                    icon: Icon(
                      hidePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF1565C0),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // =================================================
              // ❌ ERROR
              // =================================================
              if (message.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red.withOpacity(0.15)),
                  ),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),
              ],

              // =================================================
              // 🔵 REGISTER BUTTON
              // =================================================
              SizedBox(
                width: double.infinity,
                height: 58,

                child: ElevatedButton(
                  onPressed: isLoading ? null : register,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,

                    disabledBackgroundColor: Colors.grey.shade300,

                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(17),
                    ),
                  ),

                  child: isLoading
                      ? const SizedBox(
                          width: 23,
                          height: 23,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            Icon(Icons.person_add_outlined),

                            SizedBox(width: 8),

                            Text(
                              'Катталуу',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // =================================================
              // 🔙 LOGIN
              // =================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const Text(
                    'Аккаунтыңыз барбы?',
                    style: TextStyle(color: Colors.grey),
                  ),

                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.pop(context);
                          },

                    child: const Text(
                      'Кирүү',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              const Text(
                '🇰🇬 Кыргызстан  ↔  🇰🇷 Корея',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
