import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_translations.dart';

import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String message = '';
  bool isLoading = false;
  bool hidePassword = true;

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

  String t(String key) {
    return AppTranslations.get(key, currentLanguage);
  }

  String loginText(String key) {
    const texts = {
      'ky': {
        'loginDescription': 'Аккаунтуңузга кирип,\nзаказдарыңызды башкарыңыз',
        'emailHint': 'example@gmail.com',
        'passwordHint': 'Паролуңузду жазыңыз',
        'emailPasswordRequired': 'Email жана пароль толтуруңуз',
        'wrongEmailPassword': 'Email же пароль туура эмес',
        'invalidEmail': 'Email туура эмес жазылды',
        'userDisabled': 'Бул аккаунт өчүрүлгөн',
        'tooManyRequests':
            'Көп жолу аракет кылынды. Бир аздан кийин кайра аракет кылыңыз',
        'loginError': 'Кирүүдө ката кетти',
        'unexpectedError': 'Күтүлбөгөн ката кетти',
      },

      'ru': {
        'loginDescription': 'Войдите в аккаунт,\nчтобы управлять заказами',
        'emailHint': 'example@gmail.com',
        'passwordHint': 'Введите пароль',
        'emailPasswordRequired': 'Заполните Email и пароль',
        'wrongEmailPassword': 'Неверный Email или пароль',
        'invalidEmail': 'Неверно указан Email',
        'userDisabled': 'Этот аккаунт отключён',
        'tooManyRequests': 'Слишком много попыток. Попробуйте позже',
        'loginError': 'Ошибка входа',
        'unexpectedError': 'Произошла неожиданная ошибка',
      },

      'en': {
        'loginDescription': 'Sign in to your account\nto manage your orders',
        'emailHint': 'example@gmail.com',
        'passwordHint': 'Enter your password',
        'emailPasswordRequired': 'Please enter your Email and password',
        'wrongEmailPassword': 'Incorrect Email or password',
        'invalidEmail': 'Invalid Email address',
        'userDisabled': 'This account has been disabled',
        'tooManyRequests': 'Too many attempts. Please try again later',
        'loginError': 'Login error',
        'unexpectedError': 'An unexpected error occurred',
      },

      'ko': {
        'loginDescription': '계정에 로그인하여\n주문을 관리하세요',
        'emailHint': 'example@gmail.com',
        'passwordHint': '비밀번호를 입력하세요',
        'emailPasswordRequired': '이메일과 비밀번호를 입력하세요',
        'wrongEmailPassword': '이메일 또는 비밀번호가 올바르지 않습니다',
        'invalidEmail': '이메일 형식이 올바르지 않습니다',
        'userDisabled': '이 계정은 비활성화되었습니다',
        'tooManyRequests': '시도가 너무 많습니다. 잠시 후 다시 시도하세요',
        'loginError': '로그인 오류',
        'unexpectedError': '예기치 않은 오류가 발생했습니다',
      },
    };

    return texts[currentLanguage]?[key] ?? texts['ky']?[key] ?? key;
  }

  // =========================================================
  // 🔐 КИРҮҮ
  // =========================================================

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        message = loginText('emailPasswordRequired');
      });
      return;
    }

    setState(() {
      isLoading = true;
      message = '';
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String errorMessage;

      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          errorMessage = loginText('wrongEmailPassword');
          break;

        case 'invalid-email':
          errorMessage = loginText('invalidEmail');
          break;

        case 'user-disabled':
          errorMessage = loginText('userDisabled');
          break;

        case 'too-many-requests':
          errorMessage = loginText('tooManyRequests');
          break;

        default:
          errorMessage = e.message ?? loginText('loginError');
      }

      setState(() {
        message = errorMessage;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        message = loginText('unexpectedError');
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

        title: Text(
          t('login'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),

          child: Column(
            children: [
              // =================================================
              // 🔵 LOGO
              // =================================================
              Container(
                width: 90,
                height: 90,

                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  shape: BoxShape.circle,

                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1565C0).withValues(alpha: 0.10),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),

                child: const Center(
                  child: Text('🚚', style: TextStyle(fontSize: 45)),
                ),
              ),

              const SizedBox(height: 25),

              Text(
                t('welcome'),
                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                loginText('loginDescription'),
                textAlign: TextAlign.center,

                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  height: 1.4,
                ),
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
                  labelText: t('email'),
                  hintText: loginText('emailHint'),

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
                    login();
                  }
                },

                decoration: InputDecoration(
                  labelText: t('password'),
                  hintText: loginText('passwordHint'),

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
              // ❌ ERROR MESSAGE
              // =================================================
              if (message.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.15)),
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
              // 🔵 LOGIN BUTTON
              // =================================================
              SizedBox(
                width: double.infinity,
                height: 58,

                child: ElevatedButton(
                  onPressed: isLoading ? null : login,

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
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            const Icon(Icons.login),

                            const SizedBox(width: 8),

                            Text(
                              t('login'),
                              style: const TextStyle(
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
              // 📝 REGISTER
              // =================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Text(
                    t('noAccount'),
                    style: const TextStyle(color: Colors.grey),
                  ),

                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            );
                          },

                    child: Text(
                      t('register'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // =================================================
              // 🇰🇬 🇰🇷
              // =================================================
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
