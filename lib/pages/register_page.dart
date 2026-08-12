import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_translations.dart';

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

  String registerText(String key) {
    const texts = {
      'ky': {
        'newAccount': 'Жаңы аккаунт 📝',
        'description':
            'Аккаунт түзүп, Кыргызстан ↔ Корея\nкызматтарын колдонуңуз',
        'emailHint': 'example@gmail.com',
        'passwordHint': 'Кеминде 6 белги',
        'emailPasswordRequired': 'Email жана пароль толтуруңуз',
        'passwordTooShort': 'Пароль кеминде 6 белгиден турушу керек',
        'emailAlreadyExists': 'Бул Email менен аккаунт мурунтан бар',
        'invalidEmail': 'Email туура эмес жазылды',
        'weakPassword': 'Пароль өтө жөнөкөй',
        'operationNotAllowed': 'Email аркылуу катталуу азыр жеткиликтүү эмес',
        'registerError': 'Катталууда ката кетти',
        'unexpectedError': 'Күтүлбөгөн ката кетти',
        'alreadyAccount': 'Аккаунтыңыз барбы?',
      },

      'ru': {
        'newAccount': 'Новый аккаунт 📝',
        'description':
            'Создайте аккаунт и пользуйтесь\nсервисами Кыргызстан ↔ Корея',
        'emailHint': 'example@gmail.com',
        'passwordHint': 'Минимум 6 символов',
        'emailPasswordRequired': 'Введите Email и пароль',
        'passwordTooShort': 'Пароль должен содержать минимум 6 символов',
        'emailAlreadyExists': 'Аккаунт с этим Email уже существует',
        'invalidEmail': 'Неверно указан Email',
        'weakPassword': 'Пароль слишком простой',
        'operationNotAllowed': 'Регистрация через Email сейчас недоступна',
        'registerError': 'Ошибка регистрации',
        'unexpectedError': 'Произошла неожиданная ошибка',
        'alreadyAccount': 'Уже есть аккаунт?',
      },

      'en': {
        'newAccount': 'Create Account 📝',
        'description': 'Create an account and use\nKyrgyzstan ↔ Korea services',
        'emailHint': 'example@gmail.com',
        'passwordHint': 'At least 6 characters',
        'emailPasswordRequired': 'Please enter your Email and password',
        'passwordTooShort': 'Password must be at least 6 characters',
        'emailAlreadyExists': 'An account with this Email already exists',
        'invalidEmail': 'Invalid Email address',
        'weakPassword': 'Password is too weak',
        'operationNotAllowed': 'Email registration is currently unavailable',
        'registerError': 'Registration error',
        'unexpectedError': 'An unexpected error occurred',
        'alreadyAccount': 'Already have an account?',
      },

      'ko': {
        'newAccount': '새 계정 만들기 📝',
        'description': '계정을 만들고\n키르기스스탄 ↔ 한국 서비스를 이용하세요',
        'emailHint': 'example@gmail.com',
        'passwordHint': '6자 이상 입력하세요',
        'emailPasswordRequired': '이메일과 비밀번호를 입력하세요',
        'passwordTooShort': '비밀번호는 6자 이상이어야 합니다',
        'emailAlreadyExists': '이 이메일로 등록된 계정이 이미 있습니다',
        'invalidEmail': '이메일 형식이 올바르지 않습니다',
        'weakPassword': '비밀번호가 너무 간단합니다',
        'operationNotAllowed': '현재 이메일 회원가입을 사용할 수 없습니다',
        'registerError': '회원가입 오류',
        'unexpectedError': '예기치 않은 오류가 발생했습니다',
        'alreadyAccount': '이미 계정이 있으신가요?',
      },
    };

    return texts[currentLanguage]?[key] ?? texts['ky']?[key] ?? key;
  }

  // =========================================================
  // 📝 КАТТАЛУУ
  // =========================================================

  Future<void> register() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        message = registerText('emailPasswordRequired');
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        message = registerText('passwordTooShort');
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
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String errorMessage;

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = registerText('emailAlreadyExists');
          break;

        case 'invalid-email':
          errorMessage = registerText('invalidEmail');
          break;

        case 'weak-password':
          errorMessage = registerText('weakPassword');
          break;

        case 'operation-not-allowed':
          errorMessage = registerText('operationNotAllowed');
          break;

        default:
          errorMessage = e.message ?? registerText('registerError');
      }

      setState(() {
        message = errorMessage;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        message = registerText('unexpectedError');
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
          t('register'),
          style: const TextStyle(fontWeight: FontWeight.bold),
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

              Text(
                registerText('newAccount'),
                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                registerText('description'),
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
                  hintText: registerText('emailHint'),

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
                  labelText: t('password'),

                  hintText: registerText('passwordHint'),

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
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            const Icon(Icons.person_add_outlined),

                            const SizedBox(width: 8),

                            Text(
                              t('register'),

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
              // 🔙 LOGIN
              // =================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Text(
                    registerText('alreadyAccount'),

                    style: const TextStyle(color: Colors.grey),
                  ),

                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.pop(context);
                          },

                    child: Text(
                      t('login'),

                      style: const TextStyle(
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
