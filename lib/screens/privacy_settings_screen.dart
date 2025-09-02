import 'package:flutter/material.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  _PrivacySettingsScreenState createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  static const Color babyBlue = Color(0xFF87CEEB);
  static const Color lightBabyBlue = Color(0xFFB0E0E6);
  static const Color paleBlue = Color(0xFFE0F6FF);
  static const Color whiteColor = Colors.white;
  
  bool _shareDataWithThirdParties = false;
  bool _allowPersonalizedAds = true;
  bool _shareLocationData = false;
  bool _allowAnalytics = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: babyBlue,
      appBar: AppBar(
        title: const Text(
          'إعدادات الخصوصية',
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
              _buildPrivacySection(
                'البيانات الشخصية',
                [
                  _buildPrivacyOption(
                    'مشاركة البيانات مع أطراف ثالثة',
                    'السماح بمشاركة بياناتك مع شركاء التطبيق',
                    _shareDataWithThirdParties,
                    (value) => setState(() => _shareDataWithThirdParties = value),
                    Icons.share,
                  ),
                  _buildPrivacyOption(
                    'السماح بالإعلانات المخصصة',
                    'عرض إعلانات تتناسب مع اهتماماتك',
                    _allowPersonalizedAds,
                    (value) => setState(() => _allowPersonalizedAds = value),
                    Icons.ads_click,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildPrivacySection(
                'الموقع والتتبع',
                [
                  _buildPrivacyOption(
                    'مشاركة بيانات الموقع',
                    'السماح للتطبيق بالوصول لموقعك الحالي',
                    _shareLocationData,
                    (value) => setState(() => _shareLocationData = value),
                    Icons.location_on,
                  ),
                  _buildPrivacyOption(
                    'السماح بالتحليلات',
                    'جمع بيانات الاستخدام لتحسين التطبيق',
                    _allowAnalytics,
                    (value) => setState(() => _allowAnalytics = value),
                    Icons.analytics,
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacySection(String title, List<Widget> options) {
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

  Widget _buildPrivacyOption(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: paleBlue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: value ? babyBlue.withOpacity(0.5) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value ? babyBlue.withOpacity(0.2) : paleBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: value ? babyBlue : Colors.grey[600],
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
                    color: value ? babyBlue : Colors.black87,
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: babyBlue,
            activeTrackColor: lightBabyBlue,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey[300],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم حفظ إعدادات الخصوصية'),
                  backgroundColor: babyBlue,
                ),
              );
            },
            icon: const Icon(Icons.save, color: whiteColor),
            label: const Text(
              'حفظ الإعدادات',
              style: TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: babyBlue,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _shareDataWithThirdParties = false;
                _allowPersonalizedAds = false;
                _shareLocationData = false;
                _allowAnalytics = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إعادة تعيين إعدادات الخصوصية'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            icon: const Icon(Icons.refresh, color: babyBlue),
            label: const Text(
              'إعادة تعيين',
              style: TextStyle(color: babyBlue, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: babyBlue),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}