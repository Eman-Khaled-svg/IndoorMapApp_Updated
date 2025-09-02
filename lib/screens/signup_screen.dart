import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'user_profile_screen.dart';

class SignUpScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final Function(Locale) onLanguageChanged;
  final ThemeMode initialThemeMode;
  final Locale initialLocale;

  const SignUpScreen({
    super.key,
    required this.onThemeChanged,
    required this.onLanguageChanged,
    required this.initialThemeMode,
    required this.initialLocale,
  });

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Get Supabase client
  final supabase = Supabase.instance.client;

Future<void> _normalSignUp() async {
  String name = nameController.text.trim();
  String email = emailController.text.trim();
  String password = passwordController.text.trim();

  if (name.isEmpty || email.isEmpty || password.isEmpty) {
    _showSnackBar('يرجى ملء جميع الحقول', Colors.red);
    return;
  }

  if (password.length < 6) {
    _showSnackBar('كلمة المرور يجب أن تكون أكثر من 6 أحرف', Colors.red);
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    // ✅ تسجيل مستخدم جديد
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name}, // user metadata
    );

    // ✅ الكول باك: لو التسجيل نجح
    if (response.user != null) {
      // حفظ البيانات في جدول profiles
      await supabase.from('profiles').insert({
        'id': response.user!.id,
        'full_name': name,
        'email': email,
        'created_at': DateTime.now().toIso8601String(),
      });

      _showSnackBar('تم إنشاء الحساب بنجاح! 🎉', Colors.green);

      // 🚀 الانتقال لصفحة البروفايل بعد التسجيل
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserProfileScreen(
              name: name,
              onThemeChanged: widget.onThemeChanged,
              onLanguageChanged: widget.onLanguageChanged,
              initialThemeMode: widget.initialThemeMode,
              initialLocale: widget.initialLocale,
            ),
          ),
        );
      }
    } else {
      _showSnackBar('لم يتم إنشاء الحساب، حاول مرة أخرى', Colors.red);
    }
  } on AuthException catch (error) {
    _showSnackBar('خطأ في التسجيل: ${error.message}', Colors.red);
  } catch (error) {
    _showSnackBar('حدث خطأ غير متوقع', Colors.red);
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}


  Future<void> _googleSignUp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Sign in with Google
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.myapp://login-callback/',
      );

      _showSnackBar('تم التسجيل بجوجل بنجاح! 🎉', Colors.green);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => UserProfileScreen(
            name: 'مستخدم جوجل',
            onThemeChanged: widget.onThemeChanged,
            onLanguageChanged: widget.onLanguageChanged,
            initialThemeMode: widget.initialThemeMode,
            initialLocale: widget.initialLocale,
          ),
        ),
      );
    } catch (error) {
      _showSnackBar('فشل في التسجيل بجوجل', Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
        ),
      );
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          onThemeChanged: widget.onThemeChanged,
          onLanguageChanged: widget.onLanguageChanged,
          initialThemeMode: widget.initialThemeMode,
          initialLocale: widget.initialLocale,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFF89CFF0).withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    'إنشاء حساب جديد',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF89CFF0),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'أدخل بياناتك للتسجيل',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: nameController,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      labelText: 'الاسم الكامل',
                      prefixIcon: Icon(Icons.person, color: Color(0xFF89CFF0)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: Color(0xFF89CFF0), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    enabled: !_isLoading,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      prefixIcon: Icon(Icons.email, color: Color(0xFF89CFF0)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: Color(0xFF89CFF0), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    enabled: !_isLoading,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      prefixIcon: Icon(Icons.lock, color: Color(0xFF89CFF0)),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Color(0xFF89CFF0),
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: Color(0xFF89CFF0), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _normalSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF89CFF0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 3,
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'تسجيل',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[400])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'أو',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[400])),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _googleSignUp,
                      icon: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.g_mobiledata,
                            color: Colors.white, size: 20),
                      ),
                      label: Text(
                        'التسجيل بجوجل',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF89CFF0),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Color(0xFF89CFF0), width: 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: _isLoading ? null : _navigateToLogin,
                      child: RichText(
                        text: TextSpan(
                          text: 'لديك حساب بالفعل؟ ',
                          style: TextStyle(color: Colors.grey[600]),
                          children: [
                            TextSpan(
                              text: 'سجل الدخول',
                              style: TextStyle(
                                color: Color(0xFF89CFF0),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
