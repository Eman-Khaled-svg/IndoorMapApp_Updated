import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ملف شخصي',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الصفحة الرئيسية'),
        backgroundColor: Color(0xFF87CEEB),
      ),
      backgroundColor: Color(0xFFE0F6FF),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF87CEEB),
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
          child: Text(
            'الملف الشخصي',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF87CEEB),
      appBar: AppBar(
        title: Text('الملف الشخصي'),
        backgroundColor: Colors.white,
        foregroundColor: Color(0xFF87CEEB),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFE0F6FF)],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // صورة الملف الشخصي
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF87CEEB),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Color(0xFF87CEEB).withOpacity(0.3),
                      blurRadius: 15,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(Icons.person, size: 80, color: Colors.white),
              ),
              SizedBox(height: 20),
              
              // اسم المستخدم
              Text(
                'أحمد محمد',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF87CEEB),
                ),
              ),
              SizedBox(height: 10),
              
              Text(
                'user@example.com',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 30),
              
              // قائمة الخيارات
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: [
                        _buildOption(
                          context,
                          Icons.brightness_6,
                          'وضع الثيم',
                          () => _showMessage(context, 'تم الضغط على وضع الثيم'),
                        ),
                        Divider(),
                        _buildOption(
                          context,
                          Icons.language,
                          'اللغة',
                          () => _showMessage(context, 'تم الضغط على اللغة'),
                        ),
                        Divider(),
                        _buildOption(
                          context,
                          Icons.security,
                          'الخصوصية',
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => PrivacyPage()),
                          ),
                        ),
                        Divider(),
                        _buildOption(
                          context,
                          Icons.lock,
                          'الأمان',
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => SecurityPage()),
                          ),
                        ),
                        Divider(),
                        _buildOption(
                          context,
                          Icons.logout,
                          'تسجيل الخروج',
                          () => _showLogoutDialog(context),
                          Colors.red,
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

  Widget _buildOption(BuildContext context, IconData icon, String title, VoidCallback onTap, [Color? color]) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Color(0xFFE0F6FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color ?? Color(0xFF87CEEB), size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: color ?? Color(0xFF87CEEB),
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFF87CEEB), size: 18),
      onTap: onTap,
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFF87CEEB),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('تسجيل الخروج'),
          content: Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('لا'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showMessage(context, 'تم تسجيل الخروج بنجاح');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('نعم', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PrivacyPageState createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  bool _showOnlineStatus = true;
  bool _allowDataCollection = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إعدادات الخصوصية'),
        backgroundColor: Color(0xFF87CEEB),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text('إظهار الحالة الأونلاين'),
                      subtitle: Text('السماح للآخرين برؤية حالتك'),
                      value: _showOnlineStatus,
                      onChanged: (value) {
                        setState(() {
                          _showOnlineStatus = value;
                        });
                      },
                      activeThumbColor: Color(0xFF87CEEB),
                    ),
                    Divider(),
                    SwitchListTile(
                      title: Text('جمع البيانات'),
                      subtitle: Text('السماح بجمع البيانات لتحسين الخدمة'),
                      value: _allowDataCollection,
                      onChanged: (value) {
                        setState(() {
                          _allowDataCollection = value;
                        });
                      },
                      activeThumbColor: Color(0xFF87CEEB),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم حفظ إعدادات الخصوصية'),
                      backgroundColor: Color(0xFF87CEEB),
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF87CEEB),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text('حفظ', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SecurityPageState createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _twoFactorAuth = false;
  bool _biometricLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إعدادات الأمان'),
        backgroundColor: Color(0xFF87CEEB),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text('المصادقة الثنائية'),
                      subtitle: Text('تفعيل طبقة حماية إضافية'),
                      value: _twoFactorAuth,
                      onChanged: (value) {
                        setState(() {
                          _twoFactorAuth = value;
                        });
                      },
                      activeThumbColor: Color(0xFF87CEEB),
                    ),
                    Divider(),
                    SwitchListTile(
                      title: Text('تسجيل الدخول البيومتري'),
                      subtitle: Text('استخدام البصمة أو الوجه'),
                      value: _biometricLogin,
                      onChanged: (value) {
                        setState(() {
                          _biometricLogin = value;
                        });
                      },
                      activeThumbColor: Color(0xFF87CEEB),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم حفظ إعدادات الأمان'),
                      backgroundColor: Color(0xFF87CEEB),
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF87CEEB),
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text('حفظ', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}