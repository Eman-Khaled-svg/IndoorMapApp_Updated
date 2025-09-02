import 'package:flutter/material.dart';

class ThemeSettingsScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  final ThemeMode initialThemeMode;

  const ThemeSettingsScreen({
    super.key,
    required this.onThemeChanged,
    required this.initialThemeMode,
  });

  @override
  _ThemeSettingsScreenState createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  static const Color babyBlue = Color(0xFF87CEEB);
  static const Color lightBabyBlue = Color(0xFFB0E0E6);
  static const Color paleBlue = Color(0xFFE0F6FF);
  static const Color whiteColor = Colors.white;
  
  late ThemeMode _selectedTheme;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.initialThemeMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: babyBlue,
      appBar: AppBar(
        title: const Text(
          'إعدادات الثيم',
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
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'اختر وضع الثيم المفضل لك',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: babyBlue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildThemeOption(
                    ThemeMode.system,
                    'النظام',
                    'اتبع إعدادات النظام',
                    Icons.phone_android,
                  ),
                  const SizedBox(height: 10),
                  _buildThemeOption(
                    ThemeMode.light,
                    'الوضع الفاتح',
                    'استخدام الثيم الفاتح دائماً',
                    Icons.light_mode,
                  ),
                  const SizedBox(height: 10),
                  _buildThemeOption(
                    ThemeMode.dark,
                    'الوضع المظلم',
                    'استخدام الثيم المظلم دائماً',
                    Icons.dark_mode,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(ThemeMode themeMode, String title, String subtitle, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _selectedTheme == themeMode ? paleBlue : Colors.transparent,
        border: Border.all(
          color: _selectedTheme == themeMode ? babyBlue : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: RadioListTile<ThemeMode>(
        value: themeMode,
        groupValue: _selectedTheme,
        onChanged: (ThemeMode? value) {
          if (value != null) {
            setState(() {
              _selectedTheme = value;
            });
            widget.onThemeChanged(value);
          }
        },
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _selectedTheme == themeMode ? babyBlue.withOpacity(0.2) : paleBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: _selectedTheme == themeMode ? babyBlue : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _selectedTheme == themeMode ? babyBlue : Colors.black87,
                    ),
                  ),
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
          ],
        ),
        activeColor: babyBlue,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}