import 'package:flutter/material.dart';
import 'theme_settings_screen.dart';
import 'language_settings_screen.dart';
import 'privacy_settings_screen.dart';
import 'security_settings_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String name;
  final Function(ThemeMode) onThemeChanged;
  final Function(Locale) onLanguageChanged;
  final ThemeMode initialThemeMode;
  final Locale initialLocale;

  const UserProfileScreen({
    super.key,
    required this.name,
    required this.onThemeChanged,
    required this.onLanguageChanged,
    required this.initialThemeMode,
    required this.initialLocale,
  });

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  static const Color babyBlue = Color(0xFF87CEEB);
  static const Color lightBabyBlue = Color(0xFFB0E0E6);
  static const Color paleBlue = Color(0xFFE0F6FF);
  static const Color whiteColor = Colors.white;

  // دالة تسجيل الخروج
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'تسجيل الخروج',
            style: TextStyle(
              color: babyBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق الحوار
              },
              child: const Text(
                'إلغاء',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // إغلاق الحوار
                _performLogout(); // تنفيذ تسجيل الخروج
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'تسجيل الخروج',
                style: TextStyle(color: whiteColor, fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  // تنفيذ عملية تسجيل الخروج
  void _performLogout() {
    // إزالة جميع الصفحات والعودة للصفحة الرئيسية (تسجيل الدخول)
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/', // أو المسار الخاص بصفحة تسجيل الدخول
      (route) => false,
    );
    
    // عرض رسالة تأكيد
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'تم تسجيل الخروج بنجاح',
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: babyBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: babyBlue,
      appBar: AppBar(
        title: const Text(
          'الملف الشخصي',
          style: TextStyle(
            color: babyBlue,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: whiteColor,
        elevation: 2,
        shadowColor: babyBlue.withOpacity(0.1),
        automaticallyImplyLeading: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              whiteColor,
              paleBlue,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // صورة الملف الشخصي
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [babyBlue, lightBabyBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: babyBlue.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  size: 80,
                  color: whiteColor,
                ),
              ),
              const SizedBox(height: 20),
              // اسم المستخدم
              Text(
                widget.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: babyBlue,
                ),
              ),
              const SizedBox(height: 10),
              // بريد إلكتروني افتراضي
              Text(
                'user@example.com',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              // قسم الإعدادات
              Expanded(
                child: Card(
                  color: whiteColor,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: lightBabyBlue.withOpacity(0.3), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        _buildProfileOption(
                          icon: Icons.brightness_6,
                          title: 'وضع الثيم',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ThemeSettingsScreen(
                                  onThemeChanged: widget.onThemeChanged,
                                  initialThemeMode: widget.initialThemeMode,
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(),
                        _buildProfileOption(
                          icon: Icons.language,
                          title: 'اللغة',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LanguageSettingsScreen(
                                  onLanguageChanged: widget.onLanguageChanged,
                                  initialLocale: widget.initialLocale,
                                ),
                              ),
                            );
                          },
                        ),
                        const Divider(),
                        _buildProfileOption(
                          icon: Icons.security,
                          title: 'الخصوصية',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PrivacySettingsScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(),
                        _buildProfileOption(
                          icon: Icons.lock,
                          title: 'الأمان',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SecuritySettingsScreen(),
                              ),
                            );
                          },
                        ),
                        const Divider(),
                        _buildProfileOption(
                          icon: Icons.logout,
                          title: 'تسجيل الخروج',
                          onTap: _showLogoutDialog, // الحل الجديد - استدعاء الحوار مباشرة
                          textColor: Colors.red,
                          iconColor: Colors.red,
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
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color textColor = babyBlue,
    Color iconColor = babyBlue,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: paleBlue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: babyBlue, size: 18),
      onTap: onTap,
    );
  }
}