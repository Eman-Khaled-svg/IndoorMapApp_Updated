import 'package:flutter/material.dart';

class LanguageSettingsScreen extends StatefulWidget {
  final Function(Locale) onLanguageChanged;
  final Locale initialLocale;

  const LanguageSettingsScreen({
    super.key,
    required this.onLanguageChanged,
    required this.initialLocale,
  });

  @override
  _LanguageSettingsScreenState createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  static const Color babyBlue = Color(0xFF87CEEB);
  static const Color lightBabyBlue = Color(0xFFB0E0E6);
  static const Color paleBlue = Color(0xFFE0F6FF);
  static const Color whiteColor = Colors.white;
  
  late Locale _selectedLocale;

  final List<Map<String, dynamic>> languages = [
    {'locale': const Locale('ar'), 'name': 'العربية', 'flag': '🇸🇦'},
    {'locale': const Locale('en'), 'name': 'English', 'flag': '🇺🇸'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedLocale = widget.initialLocale;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: babyBlue,
      appBar: AppBar(
        title: const Text(
          'إعدادات اللغة',
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
                    'اختر اللغة المفضلة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: babyBlue,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...languages.map((language) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildLanguageOption(
                      language['locale'],
                      language['name'],
                      language['flag'],
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(Locale locale, String name, String flag) {
    bool isSelected = _selectedLocale.languageCode == locale.languageCode;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? paleBlue : Colors.transparent,
        border: Border.all(
          color: isSelected ? babyBlue : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: RadioListTile<Locale>(
        value: locale,
        groupValue: _selectedLocale,
        onChanged: (Locale? value) {
          if (value != null) {
            setState(() {
              _selectedLocale = value;
            });
            widget.onLanguageChanged(value);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم تغيير اللغة إلى $name'),
                backgroundColor: babyBlue,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? babyBlue.withOpacity(0.2) : paleBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                flag,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? babyBlue : Colors.black87,
                ),
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