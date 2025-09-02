import 'package:flutter/material.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  _SecuritySettingsScreenState createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  static const Color babyBlue = Color(0xFF87CEEB);
  static const Color lightBabyBlue = Color(0xFFB0E0E6);
  static const Color paleBlue = Color(0xFFE0F6FF);
  static const Color whiteColor = Colors.white;
  
  bool _biometricLogin = false;
  bool _twoFactorAuth = false;
  bool _autoLock = true;
  bool _loginNotifications = true;
  String _selectedAutoLockTime = '5 دقائق';

  final List<String> _autoLockTimes = [
    'فوراً',
    '1 دقيقة',
    '5 دقائق',
    '15 دقيقة',
    '30 دقيقة',
    '1 ساعة',
    'أبداً'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: babyBlue,
      appBar: AppBar(
        title: const Text(
          'إعدادات الأمان',
          style: TextStyle(
            color: babyBlue,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: whiteColor,
        elevation: 2,
        shadowColor: babyBlue.withOpacity(0.1),
        iconTheme: const IconThemeData(color: babyBlue),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [whiteColor, paleBlue],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              _buildSecuritySection(
                'المصادقة وتسجيل الدخول',
                [
                  _buildSecurityOption(
                    'تسجيل الدخول بالبصمة',
                    'استخدام البصمة أو الوجه لتسجيل الدخول',
                    _biometricLogin,
                    (value) => setState(() => _biometricLogin = value),
                    Icons.fingerprint,
                    hasSwitch: true,
                  ),
                  _buildSecurityOption(
                    'المصادقة الثنائية',
                    'تفعيل طبقة حماية إضافية للحساب',
                    _twoFactorAuth,
                    (value) => setState(() => _twoFactorAuth = value),
                    Icons.security,
                    hasSwitch: true,
                  ),
                  _buildSecurityOption(
                    'تغيير كلمة المرور',
                    'تحديث كلمة مرور الحساب',
                    null,
                    null,
                    Icons.lock_reset,
                    hasSwitch: false,
                    onTap: () => _showChangePasswordDialog(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSecuritySection(
                'القفل التلقائي',
                [
                  _buildSecurityOption(
                    'تفعيل القفل التلقائي',
                    'قفل التطبيق تلقائياً عند عدم الاستخدام',
                    _autoLock,
                    (value) => setState(() => _autoLock = value),
                    Icons.lock_clock,
                    hasSwitch: true,
                  ),
                  _buildAutoLockTimeOption(),
                ],
              ),
              const SizedBox(height: 20),
              _buildSecuritySection(
                'التنبيهات',
                [
                  _buildSecurityOption(
                    'تنبيهات تسجيل الدخول',
                    'إشعار عند تسجيل الدخول من جهاز جديد',
                    _loginNotifications,
                    (value) => setState(() => _loginNotifications = value),
                    Icons.notification_important,
                    hasSwitch: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSecuritySection(
                'إدارة الجلسات',
                [
                  _buildSecurityOption(
                    'الأجهزة المتصلة',
                    'عرض وإدارة الأجهزة المسجلة',
                    null,
                    null,
                    Icons.devices,
                    hasSwitch: false,
                    onTap: () => _showConnectedDevicesDialog(),
                  ),
                  _buildSecurityOption(
                    'إنهاء جميع الجلسات',
                    'تسجيل الخروج من جميع الأجهزة الأخرى',
                    null,
                    null,
                    Icons.logout,
                    hasSwitch: false,
                    onTap: () => _showEndAllSessionsDialog(),
                    isDestructive: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecuritySection(String title, List<Widget> options) {
    return Card(
      color: whiteColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: lightBabyBlue.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: babyBlue,
              ),
            ),
            const SizedBox(height: 15),
            ...options,
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityOption(
    String title,
    String subtitle,
    bool? value,
    Function(bool)? onChanged,
    IconData icon, {
    required bool hasSwitch,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    Color iconColor = isDestructive ? Colors.red : (hasSwitch && value == true ? babyBlue : Colors.grey[600]!);
    Color titleColor = isDestructive ? Colors.red : (hasSwitch && value == true ? babyBlue : Colors.black87);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasSwitch && value == true 
            ? paleBlue.withOpacity(0.3) 
            : (isDestructive ? Colors.red.withOpacity(0.1) : Colors.grey[50]),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasSwitch && value == true 
              ? babyBlue.withOpacity(0.5) 
              : (isDestructive ? Colors.red.withOpacity(0.3) : Colors.transparent),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hasSwitch && value == true 
                    ? babyBlue.withOpacity(0.2) 
                    : (isDestructive ? Colors.red.withOpacity(0.2) : paleBlue),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (hasSwitch && onChanged != null)
              Switch(
                value: value!,
                onChanged: onChanged,
                activeThumbColor: babyBlue,
                activeTrackColor: lightBabyBlue,
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey[300],
              )
            else if (!hasSwitch)
              Icon(
                Icons.arrow_forward_ios,
                color: isDestructive ? Colors.red : babyBlue,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAutoLockTimeOption() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _autoLock ? paleBlue.withOpacity(0.3) : Colors.grey[100],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _autoLock ? babyBlue.withOpacity(0.5) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _autoLock ? babyBlue.withOpacity(0.2) : paleBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.timer,
              color: _autoLock ? babyBlue : Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مدة القفل التلقائي',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _autoLock ? babyBlue : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'اختر المدة قبل قفل التطبيق تلقائياً',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: _autoLock ? _selectedAutoLockTime : null,
            items: _autoLock
                ? _autoLockTimes.map((time) {
                    return DropdownMenuItem<String>(
                      value: time,
                      child: Text(
                        time,
                        style: const TextStyle(color: babyBlue),
                      ),
                    );
                  }).toList()
                : null,
            onChanged: _autoLock
                ? (value) {
                    if (value != null) {
                      setState(() {
                        _selectedAutoLockTime = value;
                      });
                    }
                  }
                : null,
            underline: Container(),
            icon: Icon(
              Icons.arrow_drop_down,
              color: _autoLock ? babyBlue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool showCurrentPassword = false;
    bool showNewPassword = false;
    bool showConfirmPassword = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'تغيير كلمة المرور',
            style: TextStyle(color: babyBlue, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: !showCurrentPassword,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الحالية',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: babyBlue),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () => setDialogState(() => showCurrentPassword = !showCurrentPassword),
                    icon: Icon(showCurrentPassword ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: newPasswordController,
                obscureText: !showNewPassword,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: babyBlue),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () => setDialogState(() => showNewPassword = !showNewPassword),
                    icon: Icon(showNewPassword ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: confirmPasswordController,
                obscureText: !showConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'تأكيد كلمة المرور الجديدة',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: babyBlue),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () => setDialogState(() => showConfirmPassword = !showConfirmPassword),
                    icon: Icon(showConfirmPassword ? Icons.visibility_off : Icons.visibility),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (newPasswordController.text == confirmPasswordController.text) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تغيير كلمة المرور بنجاح'),
                      backgroundColor: babyBlue,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('كلمات المرور غير متطابقة'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: babyBlue),
              child: const Text('حفظ', style: TextStyle(color: whiteColor)),
            ),
          ],
        ),
      ),
    );
  }

  void _showConnectedDevicesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'الأجهزة المتصلة',
          style: TextStyle(color: babyBlue, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDeviceItem('iPhone 13 Pro', 'الجهاز الحالي', Icons.phone_iphone, true),
            const Divider(),
            _buildDeviceItem('MacBook Air', 'آخر نشاط: منذ ساعتين', Icons.laptop_mac, false),
            const Divider(),
            _buildDeviceItem('iPad', 'آخر نشاط: منذ يومين', Icons.tablet_mac, false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق', style: TextStyle(color: babyBlue)),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceItem(String deviceName, String lastActivity, IconData icon, bool isCurrent) {
    return Row(
      children: [
        Icon(icon, color: isCurrent ? babyBlue : Colors.grey),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                deviceName,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: isCurrent ? babyBlue : Colors.black87,
                ),
              ),
              Text(
                lastActivity,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        if (!isCurrent)
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم إنهاء الجلسة على $deviceName'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            icon: const Icon(Icons.logout, color: Colors.red, size: 20),
          ),
      ],
    );
  }

  void _showEndAllSessionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          'إنهاء جميع الجلسات',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'هل أنت متأكد من إنهاء جميع الجلسات؟ سيتم تسجيل الخروج من جميع الأجهزة الأخرى.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إنهاء جميع الجلسات بنجاح'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('إنهاء الجلسات', style: TextStyle(color: whiteColor)),
          ),
        ],
      ),
    );
  }
}