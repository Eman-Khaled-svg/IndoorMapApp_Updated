import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'المساعدة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header Card with App Icon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24.0),
              margin: const EdgeInsets.only(bottom: 20.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.deepPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const FaIcon(
                              FontAwesomeIcons.map,
                              size: 30,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Indoor Map App',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'دليلك للتنقل الذكي',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // About Section
            _buildSectionCard(
              title: 'عن المشروع',
              icon: const FaIcon(FontAwesomeIcons.infoCircle, color: Colors.blue, size: 28),
              color: Colors.blue,
              content:
                  'تطبيق الخرائط الداخلية هو تطبيق مصمم لتسهيل التنقل داخل المباني الكبيرة مثل المولات، الجامعات، والمستشفيات. يوفر التطبيق خرائط تفصيلية، توجيهات دقيقة، ومعلومات عن الزحمة، مما يساعد المستخدمين على الوصول إلى وجهاتهم بسهولة.',
            ),

            const SizedBox(height: 16),

            // How it Works Section
            _buildSectionCard(
              title: 'كيفية عمل التطبيق',
              icon: const FaIcon(FontAwesomeIcons.map, size: 28, color: Colors.orange),
              color: Colors.orange,
              content:
                  'يعتمد التطبيق على تقنيات تحديد المواقع الداخلية مثل Wi-Fi وBluetooth لتوفير خرائط دقيقة وتوجيهات في الوقت الفعلي. يتم تخزين بيانات الرحلات والأماكن المفضلة في قاعدة بيانات محلية للوصول السريع.',
            ),

            const SizedBox(height: 16),

            // Features Section
            _buildFeaturesCard(),

            const SizedBox(height: 20),

            // Contact Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: const [
                  FaIcon(
                    FontAwesomeIcons.headset,
                    size: 40,
                    color: Colors.purple,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'هل تحتاج مساعدة إضافية؟',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),

                  // واتساب
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                      SizedBox(width: 8),
                      Text("Whatsapp - Ahmed",
                          style: TextStyle(fontSize: 15, color: Colors.black87)),
                    ],
                  ),
                  SizedBox(height: 10),

                  // فيسبوك
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(FontAwesomeIcons.facebook, color: Colors.blue),
                      SizedBox(width: 8),
                      Text("Facebook - Mona",
                          style: TextStyle(fontSize: 15, color: Colors.black87)),
                    ],
                  ),
                  SizedBox(height: 10),

                  // انستجرام
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(FontAwesomeIcons.instagram, color: Colors.pink),
                      SizedBox(width: 8),
                      Text("Instagram - Sara",
                          style: TextStyle(fontSize: 15, color: Colors.black87)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // تعديل: نخلي الايقونة Widget مش IconData
  Widget _buildSectionCard({
    required String title,
    required Widget icon,
    required Color color,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: icon,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesCard() {
    final features = [
      {
        'icon': const FaIcon(FontAwesomeIcons.locationArrow, color: Colors.red, size: 20),
        'title': 'اكتشف موقعك الحالي',
        'description': 'عرض الخريطة، البحث عن الأماكن، التوجيهات، ومعلومات الزحمة',
        'color': Colors.red,
      },
      {
        'icon': const FaIcon(FontAwesomeIcons.history, color: Colors.green, size: 20),
        'title': 'سجل الرحلات',
        'description': 'عرض الرحلات السابقة مع تفاصيلها مثل الوجهة والتاريخ',
        'color': Colors.green,
      },
      {
        'icon': const FaIcon(FontAwesomeIcons.heart, color: Colors.pink, size: 20),
        'title': 'الأماكن المفضلة',
        'description': 'حفظ الأماكن المفضلة مع إحداثياتها للوصول السريع',
        'color': Colors.pink,
      },
      {
        'icon': const FaIcon(FontAwesomeIcons.gear, color: Colors.purple, size: 20),
        'title': 'الإعدادات',
        'description': 'تغيير اللغة (العربية/الإنجليزية) والثيم (فاتح/داكن)',
        'color': Colors.purple,
      },
      {
        'icon': const FaIcon(FontAwesomeIcons.circleQuestion, color: Colors.teal, size: 20),
        'title': 'المساعدة',
        'description': 'دليل شامل لاستخدام التطبيق',
        'color': Colors.teal,
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              FaIcon(FontAwesomeIcons.star, color: Colors.purple, size: 24),
              SizedBox(width: 12),
              Text(
                'مميزات التطبيق',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...features.map((feature) => _buildFeatureItem(
                icon: feature['icon'] as Widget,
                title: feature['title'] as String,
                description: feature['description'] as String,
                color: feature['color'] as Color,
              )),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required Widget icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: icon,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
