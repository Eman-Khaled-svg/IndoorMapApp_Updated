import 'package:flutter/material.dart';
import 'explore_location_screen.dart';
import 'trip_history_screen.dart';
import 'favorite_places_screen.dart';
import 'help_screen.dart';
import 'user_profile_screen.dart';
import 'offers_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String name;
  final Function(ThemeMode) onThemeChanged;
  final Function(Locale) onLanguageChanged;
  final ThemeMode initialThemeMode;
  final Locale initialLocale;

  const DashboardScreen({
    super.key,
    required this.name,
    required this.onThemeChanged,
    required this.onLanguageChanged,
    required this.initialThemeMode,
    required this.initialLocale,
  });

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  // Colors
  static const Color babyBlue = Color(0xFF87CEEB);
  static const Color lightBabyBlue = Color(0xFFB0E0E6);
  static const Color paleBlue = Color(0xFFE0F6FF);
  static const Color whiteColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: babyBlue,
      appBar: AppBar(
        title: const Text(
          'IndoorMap',
          style: TextStyle(
            color: babyBlue,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: whiteColor,
        elevation: 2,
        shadowColor: babyBlue.withOpacity(0.1),
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: paleBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.person, color: babyBlue, size: 26),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfileScreen(
                      name: widget.name,
                      onThemeChanged: widget.onThemeChanged,
                      onLanguageChanged: widget.onLanguageChanged,
                      initialThemeMode: widget.initialThemeMode,
                      initialLocale: widget.initialLocale,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة الترحيب
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: babyBlue.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: lightBabyBlue.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [babyBlue, lightBabyBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.waving_hand,
                        size: 30,
                        color: whiteColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'مرحباً بك، ${widget.name}! 👋',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: babyBlue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'أهلاً وسهلاً في تطبيق IndoorMap',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // main section
             _buildMainServiceCard(
  context: context,
  icon: Icons.explore,
  title: 'اكتشف موقعك الحالي',
  subtitle: 'الخريطة • البحث • التوجيهات',
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedFloorMapScreen(
          userName: widget.name,
          floorId: "floor1", 55
        ),
      ),
    );
  },
),
              const SizedBox(height: 30),

              // services section
              const Text(
                'خدمات أخرى',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: babyBlue,
                ),
              ),
              const SizedBox(height: 20),

              // Grid View for services - بدون Expanded
              GridView.count(
                shrinkWrap: true, // مهم جداً عشان ياخد المساحة المطلوبة بس
                physics:
                    const NeverScrollableScrollPhysics(), // عشان ميعملش scroll منفصل
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 0.8,
                children: [
                  _buildServiceCard(
                    context: context,
                    icon: Icons.history,
                    title: 'سجل الرحلات',
                    subtitle: 'عرض رحلاتك السابقة',
                    color: const Color(0xFF4CAF50),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TripHistoryScreen()),
                      );
                    },
                  ),
                  _buildServiceCard(
                    context: context,
                    icon: Icons.favorite,
                    title: 'الأماكن المفضلة',
                    subtitle: 'احفظ أماكنك المفضلة',
                    color: const Color(0xFFE91E63),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => FavoritePlacesScreen()),
                      );
                    },
                  ),
                  _buildServiceCard(
                    context: context,
                    icon: Icons.help,
                    title: 'المساعدة',
                    subtitle: 'دليل الاستخدام',
                    color: const Color(0xFF9C27B0),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HelpScreen()),
                      );
                    },
                  ),
                  _buildServiceCard(
                    context: context,
                    icon: Icons.sell,
                    title: 'العروض',
                    subtitle: 'عروض خاصة للمستخدمين',
                    color: const Color.fromARGB(255, 24, 11, 162),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OffersScreen()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20), // مساحة إضافية في الآخر
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainServiceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              babyBlue,
              lightBabyBlue,
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: babyBlue.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: whiteColor.withOpacity(0.25),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: whiteColor.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(icon, size: 32, color: whiteColor),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: whiteColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: whiteColor.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: whiteColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_forward_ios,
                  color: whiteColor, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: babyBlue.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.15),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
