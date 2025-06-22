// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:souq_tawfikia/SignUp_page.dart';
import 'package:souq_tawfikia/home_page.dart'; // لـ MyHomePage
import 'package:souq_tawfikia/admin_product_entry_page.dart'; // لـ AdminProductEntryPage

class login_page extends StatefulWidget {
  @override
  _login_pageState createState() => _login_pageState();
}

class _login_pageState extends State<login_page> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // الخلفية مع صورة وتدرج لوني
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/misr_petroleum.png'), // مسار صورتك
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.4),
                  BlendMode.darken,
                ),
              ),
            ),
          ),

          SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              // Set a minimum height to allow scrolling even if content is short
              // but let it expand if content is long.
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // الجزء العلوي مع الشعار
                  _buildHeaderSection(),

                  SizedBox(height: 40),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // حقل الإيميل
                        _buildInputField(
                          controller: _emailController,
                          hint: 'البريد الإلكتروني',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'الرجاء إدخال البريد الإلكتروني';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value))
                              return 'بريد إلكتروني غير صالح';
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        // حقل كلمة المرور
                        _buildInputField(
                          controller: _passwordController,
                          hint: 'كلمة المرور',
                          icon: Icons.lock,
                          isPassword: true,
                          obscureText: _obscureText, // Use the getter
                          togglePasswordVisibility: _togglePasswordVisibility,
                          validator: (value) {
                            if (value == null || value.isEmpty)
                              return 'الرجاء إدخال كلمة المرور';
                            if (value.length < 6)
                              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  _buildLoginButton(),

                  SizedBox(height: 20),

                  // نسيت كلمة المرور؟
                  TextButton(
                    onPressed: () {
                      _showResetPasswordDialog(); // ← هل دي موجودة فعلاً هنا؟
                    },
                    child: Text(
                      'نسيت كلمة المرور؟',
                      style: TextStyle(
                        color: Colors.amber[200],
                        fontSize: 14,
                      ),
                    ),
                  ),

                  SizedBox(height: 40),

                  // تسجيل الدخول عبر وسائل التواصل
                  _buildSocialLoginSection(),

                  SizedBox(height: 20),

                  // رابط إنشاء حساب
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'ليس لديك حساب؟ ',
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUp_page()),
                          );
                        },
                        child: const Text(
                          'إنشاء حساب',
                          style: TextStyle(
                              color: Colors.amber, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return const Column(
      children: [
        // يمكن استبدالها بصورة شعارك
        CircleAvatar(
          radius: 50,
          backgroundImage: AssetImage(
              'assets/images/Misr_logo.png'), // تأكد أن هذا المسار صحيح
        ),
        SizedBox(height: 20),
        Text(
          'مرحبا بعودتك',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'سجل الدخول  ',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? togglePasswordVisibility,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white54),
          icon: Icon(icon, color: Colors.white),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white54,
                  ),
                  onPressed: togglePasswordVisibility,
                )
              : null,
        ),
        validator: validator,
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: _isLoading ? null : _submitLogin,
        child: _isLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'تسجيل الدخول',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward, color: Colors.black87)
                ],
              ),
      ),
    );
  }

  Future<void> _submitLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (!mounted) return;
        User? user = userCredential.user;

        if (user != null) {
          if (user.email == 'admin@misrpetroleum.com.eg') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AdminProductEntryPage(onProductAdded: (product) {
                  // ملاحظة: هذه دالة وهمية.
                  // يجب توفير دالة حقيقية لإضافة المنتج إلى حالة التطبيق الرئيسية.
                  debugPrint('Admin added product: ${product.name}');
                }),
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MyHomePage()),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'user-not-found') {
          errorMessage = 'لا يوجد مستخدم بهذا البريد الإلكتروني.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'كلمة المرور غير صحيحة.';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'صيغة البريد الإلكتروني غير صحيحة.';
        } else {
          errorMessage = 'فشل تسجيل الدخول. الرجاء المحاولة مرة أخرى.';
          debugPrint('Firebase Auth Error: ${e.code} - ${e.message}');
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(errorMessage), backgroundColor: Colors.redAccent),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('حدث خطأ غير متوقع: $e'),
                backgroundColor: Colors.redAccent),
          );
          debugPrint('Login Error: ${e.toString()}');
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        Text(
          'أو سجل الدخول باستخدام',
          style: TextStyle(color: Colors.white70),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialIcon(Icons.g_mobiledata, Colors.red),
            SizedBox(width: 20),
            _buildSocialIcon(Icons.facebook, Colors.blue),
            SizedBox(width: 20),
            _buildSocialIcon(Icons.apple, Colors.black),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon, Color color) {
    return InkWell(
      onTap: () {
        // TODO: Implement social login
        debugPrint("${icon.toString()} social login tapped");
      },
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.7),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  // Helper getter for obscureText, to avoid direct access to _obscurePassword in build method
  bool get _obscureText {
    return _obscurePassword;
  }

  void _showResetPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('استعادة كلمة المرور'),
          content: TextField(
            controller: resetEmailController,
            decoration: InputDecoration(
              hintText: 'أدخل بريدك الإلكتروني',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                final email = resetEmailController.text.trim();
                if (email.isEmpty || !email.contains('@')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('يرجى إدخال بريد إلكتروني صالح')),
                  );
                  return;
                }

                try {
                  Navigator.of(context).pop();
                  await FirebaseAuth.instance
                      .sendPasswordResetEmail(email: email);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('تم إرسال رابط إعادة تعيين كلمة المرور')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('حدث خطأ: $e')),
                    );
                  }
                }
              },
              child: Text('إرسال'),
            ),
          ],
        );
      },
    );
  }
}
