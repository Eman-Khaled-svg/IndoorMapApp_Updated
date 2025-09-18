import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class EnhancedFloorMapScreen extends StatefulWidget {
  final String userName;
  final String floorId;

  const EnhancedFloorMapScreen({
    super.key,
    required this.userName,
    required this.floorId,
  });

  @override
  State<EnhancedFloorMapScreen> createState() => _EnhancedFloorMapScreenState();
}

class _EnhancedFloorMapScreenState extends State<EnhancedFloorMapScreen>
    with TickerProviderStateMixin {
  String selectedFloor = "floor1";
  String? selectedShop;
  bool isNavigating = false;
  Set<String> favoriteShops = {};
  
  late AnimationController _pulseController;
  late AnimationController _pathController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _pathAnimation;

  // موقع المستخدم (افتراضي بالقرب من المدخل) - نسبي
  Offset userPosition = const Offset(0.5, 0.9); // نسب مئوية

  // نظام التحديث الديناميكي
  Timer? _crowdUpdateTimer;
  DateTime lastUpdateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startCrowdUpdates();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _pathController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pathAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pathController,
      curve: Curves.easeInOut,
    ));
  }

  // بدء نظام التحديث الديناميكي
  void _startCrowdUpdates() {
    _crowdUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateCrowdLevels();
    });
  }

  // تحديث مستوى الازدحام ديناميكياً
  void _updateCrowdLevels() {
    final random = math.Random();
    final currentHour = DateTime.now().hour;
    
    setState(() {
      // تحديث الازدحام بناءً على الوقت والعشوائية
      for (String floorKey in floorData.keys) {
        final shops = floorData[floorKey]!["shops"] as List;
        final facilities = floorData[floorKey]!["facilities"] as List;
        
        for (var shop in shops) {
          String newCrowdLevel = _calculateDynamicCrowdLevel(
            shop["category"], 
            currentHour, 
            random,
            shop["name"]
          );
          shop["crowdLevel"] = newCrowdLevel;
          
          // تحديث حالة المتاجر (مفتوح/مغلق) حسب الوقت
          shop["isOpen"] = _isShopOpen(shop["name"], currentHour);
        }
        
        for (var facility in facilities) {
          String newCrowdLevel = _calculateDynamicCrowdLevel(
            "مرافق", 
            currentHour, 
            random,
            facility["name"]
          );
          facility["crowdLevel"] = newCrowdLevel;
        }
      }
      
      lastUpdateTime = DateTime.now();
    });
    
    // إشعار بالتحديث
    _showCrowdUpdateNotification();
  }

  // حساب مستوى الازدحام بناءً على عوامل مختلفة
  String _calculateDynamicCrowdLevel(String category, int hour, math.Random random, String name) {
    double crowdFactor = 0.0;
    
    // عوامل الوقت
    if (hour >= 18 && hour <= 22) {
      crowdFactor += 0.4; // أوقات الذروة المسائية
    } else if (hour >= 12 && hour <= 15) {
      crowdFactor += 0.3; // وقت الغداء
    } else if (hour >= 10 && hour <= 12) {
      crowdFactor += 0.2; // صباح نهاية الأسبوع
    }
    
    // عوامل نوع المتجر/المرفق
    switch (category) {
      case "مطاعم سريعة":
      case "مطاعم":
      case "مقاهي":
        crowdFactor += (hour >= 12 && hour <= 14) ? 0.4 : 0.2;
        break;
      case "سينما":
      case "ترفيه":
        crowdFactor += (hour >= 19 && hour <= 23) ? 0.5 : 0.1;
        break;
      case "أزياء":
      case "تسوق":
        crowdFactor += (hour >= 16 && hour <= 21) ? 0.3 : 0.2;
        break;
      case "صيدلية":
      case "خدمات مصرفية":
        crowdFactor += 0.1;
        break;
      case "مرافق":
        // المصاعد والحمامات
        if (name.contains("مصعد")) {
          crowdFactor += (hour >= 18 && hour <= 21) ? 0.4 : 0.2;
        } else if (name.contains("حمام")) {
          crowdFactor += 0.15;
        }
        break;
    }
    
    // عامل عشوائي للتنويع
    crowdFactor += (random.nextDouble() - 0.5) * 0.3;
    
    // تحديد مستوى الازدحام
    if (crowdFactor < 0.25) {
      return "خفيف";
    } else if (crowdFactor < 0.6) {
      return "متوسط";
    } else {
      return "مزدحم";
    }
  }

  // تحديد ما إذا كان المتجر مفتوح
  bool _isShopOpen(String shopName, int hour) {
    // قواعد أوقات العمل
    Map<String, Map<String, int>> openingHours = {
      "ماكدونالدز": {"open": 0, "close": 24}, // 24 ساعة
      "بنك مصر ATM": {"open": 0, "close": 24}, // 24 ساعة
      "Starbucks": {"open": 7, "close": 24},
      "KFC": {"open": 11, "close": 2}, // حتى 2 صباحاً
      "سينما مصر": {"open": 10, "close": 2},
      "صالة البولينج": {"open": 14, "close": 2},
      "ملعب بلاي ستيشن": {"open": 14, "close": 2},
      "جيم النجوم": {"open": 6, "close": 24},
      "كافية شعبي": {"open": 6, "close": 24},
    };
    
    if (openingHours.containsKey(shopName)) {
      int openTime = openingHours[shopName]!["open"]!;
      int closeTime = openingHours[shopName]!["close"]!;
      
      if (closeTime <= openTime) {
        // يعمل بعد منتصف الليل
        return hour >= openTime || hour < closeTime;
      } else {
        return hour >= openTime && hour < closeTime;
      }
    }
    
    // أوقات افتراضية للمتاجر العادية (10 ص - 11 م)
    return hour >= 10 && hour < 23;
  }

  void _showCrowdUpdateNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.update, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              "تم تحديث حالة الازدحام - ${_formatTime(lastUpdateTime)}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF87CEEB),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  // بيانات الأدوار مع معلومات الازدحام وحالة التشغيل والمفضلة - استخدام إحداثيات نسبية
  final Map<String, Map<String, dynamic>> floorData = {
    "floor1": {
      "name": "الدور الأرضي",
      "shops": [
        {
          "name": "Nike",
          "category": "رياضة",
          "position": const Offset(0.075, 0.214),
          "size": const Size(0.15, 0.114),
          "color": Colors.orange,
          "icon": Icons.sports_soccer,
          "isOpen": true,
          "crowdLevel": "متوسط",
          "openingHours": "10:00 ص - 12:00 م",
        },
        {
          "name": "Zara",
          "category": "أزياء نساء",
          "position": const Offset(0.275, 0.214),
          "size": const Size(0.175, 0.114),
          "color": Colors.blue,
          "icon": Icons.checkroom,
          "isOpen": true,
          "crowdLevel": "مزدحم",
          "openingHours": "10:00 ص - 12:00 م",
        },
        {
          "name": "Adidas",
          "category": "رياضة",
          "position": const Offset(0.5, 0.214),
          "size": const Size(0.15, 0.114),
          "color": Colors.green,
          "icon": Icons.sports_tennis,
          "isOpen": false,
          "crowdLevel": "خفيف",
          "openingHours": "12:00 ظ - 11:00 م",
        },
        {
          "name": "Apple Store",
          "category": "تكنولوجيا",
          "position": const Offset(0.7, 0.214),
          "size": const Size(0.1625, 0.114),
          "color": Colors.grey.shade800,
          "icon": Icons.phone_iphone,
          "isOpen": true,
          "crowdLevel": "متوسط",
          "openingHours": "10:00 ص - 11:00 م",
        },
        {
          "name": "ماكدونالدز",
          "category": "مطاعم سريعة",
          "position": const Offset(0.075, 0.4),
          "size": const Size(0.175, 0.129),
          "color": Colors.red.shade600,
          "icon": Icons.fastfood,
          "isOpen": true,
          "crowdLevel": "مزدحم",
          "openingHours": "24 ساعة",
        },
        {
          "name": "Carrefour Express",
          "category": "تسوق",
          "position": const Offset(0.3, 0.4),
          "size": const Size(0.2, 0.129),
          "color": Colors.blue.shade700,
          "icon": Icons.shopping_cart,
          "isOpen": true,
          "crowdLevel": "متوسط",
          "openingHours": "8:00 ص - 12:00 م",
        },
        {
          "name": "صيدلية العزبي",
          "category": "صيدلية",
          "position": const Offset(0.55, 0.4),
          "size": const Size(0.15, 0.129),
          "color": Colors.green.shade600,
          "icon": Icons.local_pharmacy,
          "isOpen": true,
          "crowdLevel": "خفيف",
          "openingHours": "9:00 ص - 11:00 م",
        },
        {
          "name": "بنك مصر ATM",
          "category": "خدمات مصرفية",
          "position": const Offset(0.75, 0.4),
          "size": const Size(0.125, 0.129),
          "color": Colors.indigo.shade700,
          "icon": Icons.atm,
          "isOpen": true,
          "crowdLevel": "خفيف",
          "openingHours": "24 ساعة",
        },
        {
          "name": "Orange Store",
          "category": "اتصالات",
          "position": const Offset(0.075, 0.6),
          "size": const Size(0.1375, 0.114),
          "color": Colors.orange.shade700,
          "icon": Icons.phone,
          "isOpen": false,
          "crowdLevel": "خفيف",
          "openingHours": "10:00 ص - 10:00 م",
        },
        {
          "name": "Vodafone",
          "category": "اتصالات",
          "position": const Offset(0.25, 0.6),
          "size": const Size(0.1375, 0.114),
          "color": Colors.red.shade700,
          "icon": Icons.signal_cellular_alt,
          "isOpen": true,
          "crowdLevel": "متوسط",
          "openingHours": "10:00 ص - 10:00 م",
        },
      ],
      "facilities": [
        {
          "name": "مصعد 1",
          "position": const Offset(0.4375, 0.714),
          "icon": Icons.elevator,
          "color": Colors.grey.shade600,
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "مصعد 2", 
          "position": const Offset(0.5625, 0.714),
          "icon": Icons.elevator,
          "color": Colors.grey.shade600,
          "isOpen": true,
          "crowdLevel": "متوسط",
        },
        {
          "name": "حمامات رجال",
          "position": const Offset(0.75, 0.6),
          "icon": Icons.man,
          "color": Colors.blue.shade400,
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "حمامات نساء",
          "position": const Offset(0.8125, 0.6),
          "icon": Icons.woman,
          "color": Colors.pink.shade400,
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "مدخل رئيسي",
          "position": const Offset(0.5, 0.929),
          "icon": Icons.door_front_door,
          "color": Colors.brown.shade600,
          "isOpen": true,
          "crowdLevel": "متوسط",
        },
        {
          "name": "خدمة عملاء",
          "position": const Offset(0.4375, 0.6),
          "icon": Icons.help_center,
          "color": Colors.purple.shade600,
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "مكتب الأمن",
          "position": const Offset(0.625, 0.6),
          "icon": Icons.security,
          "color": Colors.red.shade800,
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
      ],
    },
    "floor2": {
      "name": "الدور الأول", 
      "shops": [
        {
          "name": "Starbucks",
          "category": "مقاهي",
          "position": const Offset(0.075, 0.214),
          "size": const Size(0.175, 0.143),
          "color": Colors.green.shade800,
          "icon": Icons.local_cafe,
          "isOpen": true,
          "crowdLevel": "مزدحم",
          "openingHours": "7:00 ص - 12:00 م",
        },
        {
          "name": "H&M",
          "category": "أزياء",
          "position": const Offset(0.3, 0.214),
          "size": const Size(0.1625, 0.143),
          "color": Colors.red.shade600,
          "icon": Icons.checkroom,
          "isOpen": true,
          "crowdLevel": "متوسط",
          "openingHours": "10:00 ص - 11:00 م",
        },
        {
          "name": "Sephora",
          "category": "تجميل",
          "position": const Offset(0.5, 0.214),
          "size": const Size(0.15, 0.143),
          "color": Colors.pink.shade600,
          "icon": Icons.face_retouching_natural,
          "isOpen": true,
          "crowdLevel": "متوسط",
          "openingHours": "10:00 ص - 11:00 م",
        },
        {
          "name": "LC Waikiki",
          "category": "أزياء",
          "position": const Offset(0.6875, 0.214),
          "size": const Size(0.1625, 0.143),
          "color": Colors.blue.shade600,
          "icon": Icons.shopping_bag,
          "isOpen": true,
          "crowdLevel": "خفيف",
          "openingHours": "10:00 ص - 12:00 م",
        },
        {
          "name": "KFC",
          "category": "مطاعم",
          "position": const Offset(0.075, 0.429),
          "size": const Size(0.1625, 0.129),
          "color": Colors.red.shade700,
          "icon": Icons.restaurant,
          "isOpen": true,
          "crowdLevel": "مزدحم",
          "openingHours": "11:00 ص - 2:00 ص",
        },
        {
          "name": "Pizza Hut",
          "category": "مطاعم",
          "position": const Offset(0.275, 0.429),
          "size": const Size(0.1625, 0.129),
          "color": Colors.red.shade800,
          "icon": Icons.local_pizza,
          "isOpen": false,
          "crowdLevel": "خفيف",
          "openingHours": "12:00 ظ - 12:00 م",
        },
        {
          "name": "ملعب بلاي ستيشن",
          "category": "ترفيه",
          "position": const Offset(0.475, 0.429),
          "size": const Size(0.1875, 0.129),
          "color": Colors.purple.shade700,
          "icon": Icons.sports_esports,
          "isOpen": true,
          "crowdLevel": "متوسط",
          "openingHours": "2:00 ظ - 2:00 ص",
        },
        {
          "name": "محل ألعاب",
          "category": "ألعاب أطفال",
          "position": const Offset(0.7, 0.429),
          "size": const Size(0.15, 0.129),
          "color": Colors.orange.shade600,
          "icon": Icons.toys,
          "isOpen": true,
          "crowdLevel": "خفيف",
          "openingHours": "10:00 ص - 10:00 م",
        },
        {
          "name": "مكتبة الشروق",
          "category": "كتب",
          "position": const Offset(0.075, 0.629),
          "size": const Size(0.175, 0.114),
          "color": Colors.brown.shade600,
          "icon": Icons.book,
          "isOpen": true,
          "crowdLevel": "خفيف",
          "openingHours": "9:00 ص - 10:00 م",
        },
        {
          "name": "محل هدايا",
          "category": "هدايا",
          "position": const Offset(0.3, 0.629),
          "size": const Size(0.15, 0.114),
          "color": Colors.teal.shade600,
          "icon": Icons.card_giftcard,
          "isOpen": true,
          "crowdLevel": "خفيف",
          "openingHours": "10:00 ص - 11:00 م",
        },
      ],
      "facilities": [
        {
          "name": "مصعد 1",
          "position": const Offset(0.4375, 0.714),
          "icon": Icons.elevator,
          "color": Colors.grey.shade600,
          "isOpen": true,
          "crowdLevel": "متوسط",
        },
        {
          "name": "مصعد 2",
          "position": const Offset(0.5625, 0.714),
          "icon": Icons.elevator, 
          "color": Colors.grey.shade600,
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "حمامات رجال",
          "position": const Offset(0.75, 0.629),
          "icon": Icons.man,
          "color": Colors.blue.shade400,
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "حمامات نساء",
          "position": const Offset(0.8125, 0.629),
          "icon": Icons.woman,
          "color": Colors.pink.shade400,
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "منطقة جلوس",
          "position": const Offset(0.5, 0.629),
          "icon": Icons.chair,
          "color": Colors.brown.shade400,
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "كافتيريا",
          "position": const Offset(0.625, 0.629),
          "icon": Icons.local_cafe,
          "color": Colors.orange.shade700,
          "isOpen": true,
          "crowdLevel": "متوسط",
        },
      ],
    },
    "floor3": {
      "name": "الدور الثاني",
      "shops": [
        {
          "name": "سينما مصر",
          "category": "سينما",
          "position": const Offset(0.075, 0.171),
          "size": const Size(0.25, 0.186),
          "color": Colors.purple.shade800,
          "icon": Icons.movie,
          "isOpen": true,
          "crowdLevel": "مزدحم",
          "openingHours": "10:00 ص - 2:00 ص",
        },
        {
          "name": "صالة البولينج",
          "category": "ترفيه",
          "position": const Offset(0.375, 0.171),
          "size": const Size(0.225, 0.186),
          "color": Colors.indigo.shade700,
          "icon": Icons.sports_baseball,
          "isOpen": true,
          "crowdLevel": "متوسط",
          "openingHours": "2:00 ظ - 2:00 ص",
        },
        {
          "name": "منطقة الألعاب",
          "category": "ترفيه أطفال",
          "position": const Offset(0.65, 0.171),
          "size": const Size(0.2, 0.186),
          "color": Colors.green.shade600,
          "icon": Icons.child_care,
          "isOpen": true,
          "crowdLevel": "مزدحم",
          "openingHours": "10:00 ص - 11:00 م",
        },
        {
          "name": "Food Court",
          "category": "مطاعم متنوعة",
          "position": const Offset(0.075, 0.414),
          "size": const Size(0.3, 0.171),
          "color": Colors.orange.shade600,
          "icon": Icons.restaurant_menu,
          "isOpen": true,
          "crowdLevel": "مزدحم",
          "openingHours": "11:00 ص - 1:00 ص",
        },
        {
          "name": "مطعم بيتزا",
          "category": "مطاعم",
          "position": const Offset(0.425, 0.414),
          "size": const Size(0.15, 0.171),
          "color": Colors.red.shade600,
          "icon": Icons.local_pizza,
          "isOpen": true,
          "crowdLevel": "متوسط",
          "openingHours": "12:00 ظ - 12:00 م",
        },
        {
          "name": "كافية شعبي",
          "category": "مقاهي شعبية",
          "position": const Offset(0.625, 0.414),
          "size": const Size(0.1625, 0.171),
          "color": Colors.brown.shade700,
          "icon": Icons.coffee,
          "isOpen": true,
          "crowdLevel": "خفيف",
          "openingHours": "6:00 ص - 12:00 م",
        },
        {
          "name": "جيم النجوم",
          "category": "صالة رياضية",
          "position": const Offset(0.075, 0.643),
          "size": const Size(0.2125, 0.143),
          "color": Colors.red.shade700,
          "icon": Icons.fitness_center,
          "isOpen": true,
          "crowdLevel": "متوسط",
          "openingHours": "6:00 ص - 12:00 م",
        },
        {
          "name": "صالة بلياردو",
          "category": "ترفيه",
          "position": const Offset(0.3375, 0.643),
          "size": const Size(0.1875, 0.143),
          "color": Colors.green.shade700,
          "icon": Icons.sports_cricket,
          "isOpen": false,
          "crowdLevel": "خفيف",
          "openingHours": "2:00 ظ - 2:00 ص",
        },
        {
          "name": "مركز تدليك",
          "category": "صحة وجمال",
          "position": const Offset(0.575, 0.643),
          "size": const Size(0.175, 0.143),
          "color": Colors.teal.shade600,
          "icon": Icons.spa,
          "isOpen": true,
          "crowdLevel": "خفيف",
          "openingHours": "10:00 ص - 10:00 م",
        },
      ],
      "facilities": [
        {
          "name": "مصعد 1",
          "position": const Offset(0.4375, 0.829),
          "icon": Icons.elevator,
          "color": Colors.grey.shade600,
          "isOpen": true,
          "crowdLevel": "متوسط",
        },
        {
          "name": "مصعد 2",
          "position": const Offset(0.5625, 0.829),
          "icon": Icons.elevator,
          "color": Colors.grey.shade600,
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "حمامات رجال",
          "position": const Offset(0.8, 0.643),
          "icon": Icons.man,
          "color": Colors.blue.shade400,
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "حمامات نساء",
          "position": const Offset(0.8625, 0.643),
          "icon": Icons.woman,
          "color": Colors.pink.shade400,
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "تراس خارجي",
          "position": const Offset(0.8, 0.414),
          "icon": Icons.deck,
          "color": Colors.green.shade500,
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "منطقة تدخين",
          "position": const Offset(0.8625, 0.414),
          "icon": Icons.smoking_rooms,
          "color": Colors.grey.shade500,
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "صراف آلي",
          "position": const Offset(0.8, 0.829),
          "icon": Icons.atm,
          "color": Colors.blue.shade700,
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
      ],
    },
  };

  Color getCrowdColor(String crowdLevel) {
    switch (crowdLevel) {
      case "خفيف":
        return Colors.green;
      case "متوسط":
        return Colors.orange;
      case "مزدحم":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF), // Baby blue background
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFloorSelector(),
          _buildStatusBar(),
          _buildFavoritesButton(),
          _buildInteractiveMap(),
          if (isNavigating && selectedShop != null) _buildNavigationPanel(),
        ],
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        "خريطة مول ${widget.userName}",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E3A8A), // Dark blue
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 2,
      iconTheme: const IconThemeData(color: Color(0xFF1E3A8A)),
      actions: [
        IconButton(
          onPressed: () => _showCrowdAnalysis(),
          icon: const Icon(Icons.analytics, color: Color(0xFF1E3A8A)),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              userPosition = const Offset(0.5, 0.9);
              selectedShop = null;
              isNavigating = false;
            });
          },
          icon: const Icon(Icons.my_location, color: Color(0xFF1E3A8A)),
        ),
      ],
    );
  }

  Widget _buildFloorSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFF87CEEB), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF87CEEB).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF87CEEB), // Baby blue
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.layers, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 15),
          const Text(
            "اختر الدور:",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF1E3A8A), // Dark blue
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedFloor,
                isExpanded: true,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A8A),
                ),
                items: floorData.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value["name"]),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFloor = value!;
                    selectedShop = null;
                    isNavigating = false;
                    _pathController.reset();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    final currentTime = DateTime.now();
    final shops = floorData[selectedFloor]!["shops"] as List;
    
    // حساب إحصائيات الازدحام
    int openShops = shops.where((s) => s["isOpen"] == true).length;
    int totalShops = shops.length;
    
    Map<String, int> crowdStats = {"خفيف": 0, "متوسط": 0, "مزدحم": 0};
    for (var shop in shops) {
      if (shop["isOpen"] == true) {
        String crowdLevel = shop["crowdLevel"] ?? "خفيف";
        crowdStats[crowdLevel] = (crowdStats[crowdLevel] ?? 0) + 1;
      }
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF87CEEB), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF87CEEB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.access_time, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "الوقت الحالي: ${_formatTime(currentTime)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  Text(
                    "المتاجر المفتوحة: $openShops من $totalShops",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  _updateCrowdLevels();
                },
                icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                label: const Text(
                  "تحديث",
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF87CEEB),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildCrowdIndicator("خفيف", crowdStats["خفيف"]!, Colors.green),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCrowdIndicator("متوسط", crowdStats["متوسط"]!, Colors.orange),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCrowdIndicator("مزدحم", crowdStats["مزدحم"]!, Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "آخر تحديث: ${_formatTime(lastUpdateTime)}",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrowdIndicator(String level, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            level,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: () => _showFavorites(),
        icon: const Icon(Icons.favorite, color: Colors.red),
        label: Text(
          "المفضلة (${favoriteShops.length})",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF87CEEB), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveMap() {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            margin: EdgeInsets.all(16 * constraints.maxWidth / 360),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20 * constraints.maxWidth / 360),
              border: Border.all(color: const Color(0xFF87CEEB), width: 3 * constraints.maxWidth / 360),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400,
                  blurRadius: 20 * constraints.maxWidth / 360,
                  offset: Offset(0, 8 * constraints.maxWidth / 360),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20 * constraints.maxWidth / 360),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: MallFloorPainter(
                    floorData: floorData[selectedFloor]!,
                    userPosition: Offset(userPosition.dx * constraints.maxWidth, userPosition.dy * constraints.maxHeight),
                    selectedShop: selectedShop,
                    pulseAnimation: _pulseAnimation,
                    pathAnimation: _pathAnimation,
                    isNavigating: isNavigating,
                    favoriteShops: favoriteShops,
                    screenSize: Size(constraints.maxWidth, constraints.maxHeight),
                  ),
                  child: GestureDetector(
                    onTapUp: (details) => _handleMapTap(details.localPosition, constraints.maxWidth, constraints.maxHeight),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleMapTap(Offset position, double width, double height) {
    final shops = floorData[selectedFloor]!["shops"] as List;
    final facilities = floorData[selectedFloor]!["facilities"] as List;
    
    // فحص النقر على المتاجر
    for (var shop in shops) {
      final shopPosition = Offset(shop["position"].dx * width, shop["position"].dy * height);
      final shopSize = Size(shop["size"].width * width, shop["size"].height * height);
      
      final rect = Rect.fromLTWH(
        shopPosition.dx,
        shopPosition.dy,
        shopSize.width,
        shopSize.height,
      );
      
      if (rect.contains(position)) {
        setState(() {
          selectedShop = shop["name"];
          isNavigating = true;
        });
        _pathController.forward();
        return;
      }
    }
    
    // فحص النقر على المرافق
    for (var facility in facilities) {
      final facilityPosition = Offset(facility["position"].dx * width, facility["position"].dy * height);
      
      final distance = (position - facilityPosition).distance;
      if (distance <= 25 * width / 360) {
        setState(() {
          selectedShop = facility["name"];
          isNavigating = true;
        });
        _pathController.forward();
        return;
      }
    }
  }

  Widget _buildNavigationPanel() {
    final shops = floorData[selectedFloor]!["shops"] as List;
    final facilities = floorData[selectedFloor]!["facilities"] as List;
    
    // البحث في المتاجر أولاً
    var item = shops.where((s) => s["name"] == selectedShop).firstOrNull;
    item ??= facilities.where((f) => f["name"] == selectedShop).firstOrNull;
    
    if (item == null) return Container();
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, const Color(0xFFF0F8FF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFF87CEEB), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF87CEEB).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF87CEEB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  item["icon"] ?? Icons.place,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "التوجه إلى: ${item["name"]}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (favoriteShops.contains(item["name"])) {
                                favoriteShops.remove(item["name"]);
                              } else {
                                favoriteShops.add(item["name"]);
                              }
                            });
                          },
                          icon: Icon(
                            favoriteShops.contains(item["name"]) ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                    if (item["category"] != null)
                      Text(
                        "النوع: ${item["category"]}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    Row(
                      children: [
                        Icon(
                          item["isOpen"] == true ? Icons.check_circle : Icons.cancel,
                          color: item["isOpen"] == true ? Colors.green : Colors.red,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          item["isOpen"] == true ? "مفتوح" : "مغلق",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: item["isOpen"] == true ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: getCrowdColor(item["crowdLevel"] ?? "خفيف"),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "الازدحام: ${item["crowdLevel"] ?? "غير محدد"}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      isNavigating = false;
                      selectedShop = null;
                    });
                    _pathController.reset();
                  },
                  icon: const Icon(Icons.close, color: Colors.white),
                  label: const Text(
                    "إنهاء التوجيه",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showItemDetails(item);
                  },
                  icon: const Icon(Icons.info, color: Color(0xFF1E3A8A)),
                  label: const Text(
                    "التفاصيل",
                    style: TextStyle(
                      color: Color(0xFF1E3A8A),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFF87CEEB), width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showItemDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF87CEEB), width: 2),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF87CEEB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item["icon"], color: Colors.white, size: 28),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item["name"],
                style: const TextStyle(color: Color(0xFF1E3A8A)),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item["category"] != null)
              _buildDetailRow(Icons.category, "النوع", item["category"]),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.layers, "الدور", floorData[selectedFloor]!["name"]),
            const SizedBox(height: 10),
            if (item["openingHours"] != null)
              _buildDetailRow(Icons.access_time, "ساعات العمل", item["openingHours"]),
            const SizedBox(height: 10),
            _buildDetailRow(
              item["isOpen"] == true ? Icons.check_circle : Icons.cancel,
              "الحالة",
              item["isOpen"] == true ? "مفتوح الآن" : "مغلق الآن",
              color: item["isOpen"] == true ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 10),
            _buildDetailRow(
              Icons.people,
              "مستوى الازدحام",
              item["crowdLevel"] ?? "غير محدد",
              color: getCrowdColor(item["crowdLevel"] ?? "خفيف"),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                if (favoriteShops.contains(item["name"])) {
                  favoriteShops.remove(item["name"]);
                } else {
                  favoriteShops.add(item["name"]);
                }
              });
              Navigator.pop(context);
            },
            icon: Icon(
              favoriteShops.contains(item["name"]) ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            label: Text(
              favoriteShops.contains(item["name"]) ? "إزالة من المفضلة" : "إضافة للمفضلة",
              style: const TextStyle(color: Color(0xFF1E3A8A)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إغلاق", style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, color: color ?? const Color(0xFF87CEEB), size: 20),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF1E3A8A),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color ?? const Color(0xFF1E3A8A),
            ),
          ),
        ),
      ],
    );
  }

  void _showCrowdAnalysis() {
    final shops = floorData[selectedFloor]!["shops"] as List;
    final currentHour = DateTime.now().hour;
    
    // تجميع البيانات حسب الفئة
    Map<String, Map<String, int>> categoryStats = {};
    
    for (var shop in shops) {
      String category = shop["category"] ?? "عام";
      if (!categoryStats.containsKey(category)) {
        categoryStats[category] = {"خفيف": 0, "متوسط": 0, "مزدحم": 0, "مغلق": 0};
      }
      
      if (shop["isOpen"] == true) {
        String crowdLevel = shop["crowdLevel"] ?? "خفيف";
        categoryStats[category]![crowdLevel] = (categoryStats[category]![crowdLevel] ?? 0) + 1;
      } else {
        categoryStats[category]!["مغلق"] = (categoryStats[category]!["مغلق"] ?? 0) + 1;
      }
    }
    
    // التوقع للساعة القادمة
    String nextHourPrediction = _predictNextHourCrowd(currentHour);
    
    showDialog(
      context: context,
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20 * screenSize.width / 360),
            side: BorderSide(color: const Color(0xFF87CEEB), width: 2 * screenSize.width / 360),
          ),
          title: const Row(
            children: [
              Icon(Icons.analytics, color: Color(0xFF87CEEB), size: 28),
              SizedBox(width: 10),
              Text("تحليل الازدحام", style: TextStyle(color: Color(0xFF1E3A8A))),
            ],
          ),
          content: SizedBox(
            width: screenSize.width * 0.9,
            height: screenSize.height * 0.5,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F8FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF87CEEB), width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "📊 توقع الساعة القادمة:",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          nextHourPrediction,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "📈 إحصائيات حسب الفئة:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...categoryStats.entries.map((entry) {
                    return Card(
                      color: const Color(0xFFF0F8FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFF87CEEB), width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildMiniCrowdIndicator("🟢", entry.value["خفيف"]!),
                                _buildMiniCrowdIndicator("🟠", entry.value["متوسط"]!),
                                _buildMiniCrowdIndicator("🔴", entry.value["مزدحم"]!),
                                _buildMiniCrowdIndicator("⚫", entry.value["مغلق"]!),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange, width: 1),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "💡 نصائح:",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "• أفضل أوقات للتسوق: 10-12 ظهراً\n• المطاعم أقل ازدحاماً: 3-5 عصراً\n• تجنب أوقات الذروة: 7-9 مساءً",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إغلاق", style: TextStyle(color: Color(0xFF1E3A8A))),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMiniCrowdIndicator(String emoji, int count) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Text(
        "$emoji $count",
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  String _predictNextHourCrowd(int currentHour) {
    int nextHour = (currentHour + 1) % 24;
    
    if (nextHour >= 18 && nextHour <= 21) {
      return "🔴 الساعة ${nextHour}:00 - متوقع ازدحام شديد في المطاعم ومناطق الترفيه";
    } else if (nextHour >= 12 && nextHour <= 15) {
      return "🟠 الساعة ${nextHour}:00 - متوقع ازدحام متوسط في المطاعم";
    } else if (nextHour >= 10 && nextHour <= 12) {
      return "🟢 الساعة ${nextHour}:00 - أفضل وقت للتسوق - ازدحام خفيف";
    } else if (nextHour >= 22 || nextHour <= 6) {
      return "⚫ الساعة ${nextHour}:00 - معظم المتاجر ستكون مغلقة";
    } else {
      return "🟢 الساعة ${nextHour}:00 - متوقع ازدحام خفيف في معظم المناطق";
    }
  }

  void _showFavorites() {
    showDialog(
      context: context,
      builder: (context) {
        final screenSize = MediaQuery.of(context).size;
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20 * screenSize.width / 360),
            side: BorderSide(color: const Color(0xFF87CEEB), width: 2 * screenSize.width / 360),
          ),
          title: const Row(
            children: [
              Icon(Icons.favorite, color: Colors.red, size: 28),
              SizedBox(width: 10),
              Text("المتاجر المفضلة", style: TextStyle(color: Color(0xFF1E3A8A))),
            ],
          ),
          content: SizedBox(
            width: screenSize.width * 0.9,
            height: screenSize.height * 0.5,
            child: favoriteShops.isEmpty
                ? const Center(
                    child: Text(
                      "لا توجد متاجر مفضلة بعد",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: favoriteShops.length,
                    itemBuilder: (context, index) {
                      final shopName = favoriteShops.elementAt(index);
                      return Card(
                        color: const Color(0xFFF0F8FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFF87CEEB), width: 1),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.favorite, color: Colors.red),
                          title: Text(
                            shopName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () {
                              setState(() {
                                favoriteShops.remove(shopName);
                              });
                              Navigator.pop(context);
                              _showFavorites();
                            },
                            icon: const Icon(Icons.delete, color: Colors.red),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              selectedShop = shopName;
                              isNavigating = true;
                            });
                            _pathController.forward();
                          },
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إغلاق", style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pathController.dispose();
    _crowdUpdateTimer?.cancel();
    super.dispose();
  }
}

class MallFloorPainter extends CustomPainter {
  final Map<String, dynamic> floorData;
  final Offset userPosition;
  final String? selectedShop;
  final Animation<double> pulseAnimation;
  final Animation<double> pathAnimation;
  final bool isNavigating;
  final Set<String> favoriteShops;
  final Size screenSize;

  MallFloorPainter({
    required this.floorData,
    required this.userPosition,
    this.selectedShop,
    required this.pulseAnimation,
    required this.pathAnimation,
    required this.isNavigating,
    required this.favoriteShops,
    required this.screenSize,
  }) : super(repaint: pulseAnimation);

  Offset scaleOffset(Offset original) {
    return Offset(
      original.dx * screenSize.width,
      original.dy * screenSize.height,
    );
  }

  Size scaleSize(Size original) {
    return Size(
      original.width * screenSize.width,
      original.height * screenSize.height,
    );
  }

  double scaleValue(double original) {
    return original * screenSize.width / 800;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawWalkways(canvas, size);
    _drawShops(canvas);
    _drawFacilities(canvas);
    _drawUserPosition(canvas);
    if (isNavigating && selectedShop != null) _drawNavigationPath(canvas);
    _drawLabels(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = const Color(0xFFF8FCFF)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);
    
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = scaleValue(6);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(scaleValue(15), scaleValue(15), size.width - scaleValue(30), size.height - scaleValue(30)),
        Radius.circular(scaleValue(20)),
      ),
      borderPaint,
    );
    
    final innerBorderPaint = Paint()
      ..color = const Color(0xFF87CEEB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = scaleValue(3);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(scaleValue(20), scaleValue(20), size.width - scaleValue(40), size.height - scaleValue(40)),
        Radius.circular(scaleValue(15)),
      ),
      innerBorderPaint,
    );
  }

  void _drawWalkways(Canvas canvas, Size size) {
    final walkwayPaint = Paint()
      ..color = const Color(0xFFF0F8FF) // Baby blue فاتح جداً
      ..style = PaintingStyle.fill;
    
    final walkwayBorder = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = scaleValue(3);
    
    // الممرات الأفقية
    final walkways = [
      Rect.fromLTWH(scaleValue(40), scaleValue(100), scaleValue(680), scaleValue(60)),
      Rect.fromLTWH(scaleValue(40), scaleValue(250), scaleValue(680), scaleValue(60)),
      Rect.fromLTWH(scaleValue(40), scaleValue(400), scaleValue(680), scaleValue(60)),
      Rect.fromLTWH(scaleValue(30), scaleValue(520), scaleValue(740), scaleValue(40)),
    ];
    
    for (var walkway in walkways) {
      final rrect = RRect.fromRectAndRadius(walkway, Radius.circular(scaleValue(8)));
      canvas.drawRRect(rrect, walkwayPaint);
      canvas.drawRRect(rrect, walkwayBorder);
    }
    
    // الممر العمودي المركزي
    final centerWalkway = RRect.fromRectAndRadius(
      Rect.fromLTWH(scaleValue(370), scaleValue(100), scaleValue(60), scaleValue(520)),
      Radius.circular(scaleValue(8)),
    );
    canvas.drawRRect(centerWalkway, walkwayPaint);
    canvas.drawRRect(centerWalkway, walkwayBorder);
  }

  void _drawShops(Canvas canvas) {
    final shops = floorData["shops"] as List;
    
    for (var shop in shops) {
      final position = scaleOffset(shop["position"] as Offset);
      final shopSize = scaleSize(shop["size"] as Size);
      final color = shop["color"] as Color;
      final isOpen = shop["isOpen"] as bool;
      final crowdLevel = shop["crowdLevel"] as String;
      final isFavorite = favoriteShops.contains(shop["name"]);
      
      // رسم ظل المتجر
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.1)
        ..style = PaintingStyle.fill;
      
      final shadowRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          position.dx + scaleValue(3),
          position.dy + scaleValue(3),
          shopSize.width,
          shopSize.height,
        ),
        Radius.circular(scaleValue(12)),
      );
      canvas.drawRRect(shadowRect, shadowPaint);
      
      // رسم المتجر
      final shopPaint = Paint()
        ..color = isOpen ? color : color.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      
      final shopRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(position.dx, position.dy, shopSize.width, shopSize.height),
        Radius.circular(scaleValue(12)),
      );
      canvas.drawRRect(shopRect, shopPaint);
      
      // الحدود البيضاء
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = scaleValue(3);
      canvas.drawRRect(shopRect, borderPaint);
      
      // رسم اسم المتجر
      final textPainter = TextPainter(
        text: TextSpan(
          text: shop["name"],
          style: TextStyle(
            color: Colors.white,
            fontSize: scaleValue(14),
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(scaleValue(1), scaleValue(1)),
                blurRadius: scaleValue(2),
                color: Colors.black54,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.rtl,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          position.dx + (shopSize.width - textPainter.width) / 2,
          position.dy + shopSize.height - scaleValue(35),
        ),
      );
      
      // رسم حالة المتجر
      final statusText = isOpen ? "مفتوح" : "مغلق";
      final statusColor = isOpen ? Colors.green : Colors.red;
      
      final statusPainter = TextPainter(
        text: TextSpan(
          text: statusText,
          style: TextStyle(
            color: statusColor,
            fontSize: scaleValue(10),
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.white,
          ),
        ),
        textDirection: TextDirection.rtl,
      );
      
      statusPainter.layout();
      statusPainter.paint(
        canvas,
        Offset(
          position.dx + scaleValue(5),
          position.dy + scaleValue(5),
        ),
      );
      
      // رسم مستوى الازدحام
      final crowdColor = _getCrowdColor(crowdLevel);
      final crowdPaint = Paint()
        ..color = crowdColor
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(position.dx + shopSize.width - scaleValue(15), position.dy + scaleValue(15)),
        scaleValue(8),
        crowdPaint,
      );
      
      canvas.drawCircle(
        Offset(position.dx + shopSize.width - scaleValue(15), position.dy + scaleValue(15)),
        scaleValue(8),
        Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = scaleValue(2),
      );
      
      // رسم أيقونة المفضلة
      if (isFavorite) {
        final heartPaint = Paint()
          ..color = Colors.red
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(
          Offset(position.dx + shopSize.width - scaleValue(15), position.dy + shopSize.height - scaleValue(15)),
          scaleValue(10),
          Paint()..color = Colors.white..style = PaintingStyle.fill,
        );
        
        canvas.drawCircle(
          Offset(position.dx + shopSize.width - scaleValue(15), position.dy + shopSize.height - scaleValue(15)),
          scaleValue(10),
          Paint()..color = Colors.red..style = PaintingStyle.stroke..strokeWidth = scaleValue(2),
        );
        
        // رسم شكل القلب (مبسط)
        canvas.drawCircle(
          Offset(position.dx + shopSize.width - scaleValue(15), position.dy + shopSize.height - scaleValue(15)),
          scaleValue(6),
          heartPaint,
        );
      }
      
      // تمييز المتجر المحدد
      if (selectedShop == shop["name"]) {
        final highlightPaint = Paint()
          ..color = const Color(0xFF87CEEB)
          ..style = PaintingStyle.stroke
          ..strokeWidth = scaleValue(4);
        canvas.drawRRect(shopRect, highlightPaint);
        
        // تأثير وميض
        final glowPaint = Paint()
          ..color = const Color(0xFF87CEEB).withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = scaleValue(8);
        canvas.drawRRect(shopRect, glowPaint);
      }
    }
  }

  Color _getCrowdColor(String crowdLevel) {
    switch (crowdLevel) {
      case "خفيف":
        return Colors.green;
      case "متوسط":
        return Colors.orange;
      case "مزدحم":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _drawFacilities(Canvas canvas) {
    final facilities = floorData["facilities"] as List;
    
    for (var facility in facilities) {
      final position = scaleOffset(facility["position"] as Offset);
      final color = facility["color"] as Color;
      final isOpen = facility["isOpen"] as bool;
      final crowdLevel = facility["crowdLevel"] as String;
      
      // رسم دائرة الخلفية
      final backgroundPaint = Paint()
        ..color = isOpen ? color : color.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(position, scaleValue(22), backgroundPaint);
      
      // الحدود البيضاء
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = scaleValue(3);
      canvas.drawCircle(position, scaleValue(22), borderPaint);
      
      // رسم دائرة بيضاء داخلية للأيقونة
      final iconBackgroundPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(position, scaleValue(16), iconBackgroundPaint);
      
      // رسم مستوى الازدحام
      final crowdColor = _getCrowdColor(crowdLevel);
      final crowdPaint = Paint()
        ..color = crowdColor
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(position.dx + scaleValue(15), position.dy - scaleValue(15)),
        scaleValue(6),
        crowdPaint,
      );
      
      canvas.drawCircle(
        Offset(position.dx + scaleValue(15), position.dy - scaleValue(15)),
        scaleValue(6),
        Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = scaleValue(2),
      );
      
      // رسم اسم المرفق
      final textPainter = TextPainter(
        text: TextSpan(
          text: facility["name"],
          style: TextStyle(
            color: const Color(0xFF1E3A8A),
            fontSize: scaleValue(11),
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.white,
          ),
        ),
        textDirection: TextDirection.rtl,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          position.dx - textPainter.width / 2,
          position.dy + scaleValue(28),
        ),
      );
      
      // تمييز المرفق المحدد
      if (selectedShop == facility["name"]) {
        final highlightPaint = Paint()
          ..color = const Color(0xFF87CEEB)
          ..style = PaintingStyle.stroke
          ..strokeWidth = scaleValue(4);
        canvas.drawCircle(position, scaleValue(26), highlightPaint);
      }
    }
  }

  void _drawUserPosition(Canvas canvas) {
    // رسم دائرة النبض
    final pulsePaint = Paint()
      ..color = const Color(0xFF87CEEB).withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      userPosition,
      scaleValue(28) * pulseAnimation.value,
      pulsePaint,
    );
    
    // رسم موقع المستخدم
    final userPaint = Paint()
      ..color = const Color(0xFF1E3A8A)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(userPosition, scaleValue(14), userPaint);
    
    // الحدود البيضاء
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = scaleValue(4);
    
    canvas.drawCircle(userPosition, scaleValue(14), borderPaint);
    
    // نص "أنت هنا"
    final textPainter = TextPainter(
      text: const TextSpan(
        text: "أنت هنا",
        style: TextStyle(
          color: Color(0xFF1E3A8A),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.white,
        ),
      ),
      textDirection: TextDirection.rtl,
    );
    
    textPainter.layout();
    
    // رسم خلفية للنص
    final textBackground = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          userPosition.dx - textPainter.width / 2 - scaleValue(4),
          userPosition.dy - scaleValue(40),
          textPainter.width + scaleValue(8),
          textPainter.height + scaleValue(4),
        ),
        Radius.circular(scaleValue(8)),
      ),
      textBackground,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          userPosition.dx - textPainter.width / 2 - scaleValue(4),
          userPosition.dy - scaleValue(40),
          textPainter.width + scaleValue(8),
          textPainter.height + scaleValue(4),
        ),
        Radius.circular(scaleValue(8)),
      ),
      Paint()..color = const Color(0xFF87CEEB)..style = PaintingStyle.stroke..strokeWidth = scaleValue(2),
    );
    
    textPainter.paint(
      canvas,
      Offset(
        userPosition.dx - textPainter.width / 2,
        userPosition.dy - scaleValue(38),
      ),
    );
  }

  void _drawNavigationPath(Canvas canvas) {
    if (selectedShop == null) return;
    
    final shops = floorData["shops"] as List;
    final facilities = floorData["facilities"] as List;
    
    // البحث عن الوجهة
    Offset? destination;
    
    for (var shop in shops) {
      if (shop["name"] == selectedShop) {
        final position = scaleOffset(shop["position"] as Offset);
        final shopSize = scaleSize(shop["size"] as Size);
        destination = Offset(
          position.dx + shopSize.width / 2,
          position.dy + shopSize.height / 2,
        );
        break;
      }
    }
    
    if (destination == null) {
      for (var facility in facilities) {
        if (facility["name"] == selectedShop) {
          destination = scaleOffset(facility["position"] as Offset);
          break;
        }
      }
    }
    
    if (destination == null) return;
    
    // رسم المسار بخطوط بيضاء
    final pathPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = scaleValue(8)
      ..strokeCap = StrokeCap.round;
    
    // رسم خط متقطع بيبي بلو
    final dashPaint = Paint()
      ..color = const Color(0xFF87CEEB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = scaleValue(6)
      ..strokeCap = StrokeCap.round;
    
    // حساب نقاط المسار
    List<Offset> waypoints = _calculateWaypoints(userPosition, destination);
    
    // رسم المسار المتحرك
    double totalLength = 0;
    for (int i = 0; i < waypoints.length - 1; i++) {
      totalLength += (waypoints[i + 1] - waypoints[i]).distance;
    }
    
    double currentLength = 0;
    double animatedLength = totalLength * pathAnimation.value;
    
    for (int i = 0; i < waypoints.length - 1; i++) {
      final segmentLength = (waypoints[i + 1] - waypoints[i]).distance;
      
      if (currentLength + segmentLength <= animatedLength) {
        // رسم الجزء الكامل
        canvas.drawLine(waypoints[i], waypoints[i + 1], pathPaint);
        canvas.drawLine(waypoints[i], waypoints[i + 1], dashPaint);
      } else if (currentLength < animatedLength) {
        // رسم جزء من الخط
        final ratio = (animatedLength - currentLength) / segmentLength;
        final endPoint = Offset.lerp(waypoints[i], waypoints[i + 1], ratio)!;
        canvas.drawLine(waypoints[i], endPoint, pathPaint);
        canvas.drawLine(waypoints[i], endPoint, dashPaint);
        break;
      }
      
      currentLength += segmentLength;
    }
    
    // رسم سهم في النهاية
    if (pathAnimation.value > 0.9) {
      _drawArrow(canvas, destination);
    }
  }

  List<Offset> _calculateWaypoints(Offset start, Offset end) {
    List<Offset> waypoints = [start];
    
    // إضافة نقاط وسطية للتنقل عبر الممرات
    if ((start.dx - end.dx).abs() > (start.dy - end.dy).abs()) {
      // حركة أفقية أكبر
      waypoints.add(Offset(screenSize.width * 0.5, start.dy)); // نقطة الممر المركزي
      waypoints.add(Offset(screenSize.width * 0.5, end.dy));   // نقطة محاذاة الهدف
    } else {
      // حركة عمودية أكبر
      waypoints.add(Offset(start.dx, screenSize.height * 0.571)); // نقطة الممر الأفقي
      waypoints.add(Offset(end.dx, screenSize.height * 0.571));   // نقطة محاذاة الهدف
    }
    
    waypoints.add(end);
    return waypoints;
  }

  void _drawArrow(Canvas canvas, Offset position) {
    final arrowPaint = Paint()
      ..color = const Color(0xFF1E3A8A)
      ..style = PaintingStyle.fill;
    
    final path = Path();
    path.moveTo(position.dx - scaleValue(15), position.dy - scaleValue(10));
    path.lineTo(position.dx, position.dy);
    path.lineTo(position.dx - scaleValue(15), position.dy + scaleValue(10));
    path.lineTo(position.dx - scaleValue(10), position.dy);
    path.close();
    
    canvas.drawPath(path, arrowPaint);
    
    // حدود بيضاء للسهم
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = scaleValue(3);
    
    canvas.drawPath(path, borderPaint);
  }

  void _drawLabels(Canvas canvas, Size size) {
    // عنوان الخريطة
    final titlePainter = TextPainter(
      text: TextSpan(
        text: floorData["name"],
        style: TextStyle(
          color: const Color(0xFF1E3A8A),
          fontSize: scaleValue(26),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.rtl,
    );
    
    titlePainter.layout();
    
    // رسم خلفية العنوان
    final titleBackground = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          (size.width - titlePainter.width) / 2 - scaleValue(15),
          scaleValue(20),
          titlePainter.width + scaleValue(30),
          titlePainter.height + scaleValue(10),
        ),
        Radius.circular(scaleValue(15)),
      ),
      titleBackground,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          (size.width - titlePainter.width) / 2 - scaleValue(15),
          scaleValue(20),
          titlePainter.width + scaleValue(30),
          titlePainter.height + scaleValue(10),
        ),
        Radius.circular(scaleValue(15)),
      ),
      Paint()..color = const Color(0xFF87CEEB)..style = PaintingStyle.stroke..strokeWidth = scaleValue(2),
    );
    
    titlePainter.paint(
      canvas,
      Offset(
        (size.width - titlePainter.width) / 2,
        scaleValue(25),
      ),
    );
    
    // مفتاح الخريطة
    _drawLegend(canvas, size);
  }

  void _drawLegend(Canvas canvas, Size size) {
    final legendPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final legendRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width - scaleValue(200), scaleValue(70), scaleValue(180), scaleValue(160)),
      Radius.circular(scaleValue(15)),
    );
    
    canvas.drawRRect(legendRect, legendPaint);
    
    final borderPaint = Paint()
      ..color = const Color(0xFF87CEEB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = scaleValue(2);
    
    canvas.drawRRect(legendRect, borderPaint);
    
    // عنوان المفتاح
    final legendTitle = TextPainter(
      text: const TextSpan(
        text: "مفتاح الخريطة",
        style: TextStyle(
          color: Color(0xFF1E3A8A),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.rtl,
    );
    
    legendTitle.layout();
    legendTitle.paint(
      canvas,
      Offset(size.width - scaleValue(190), scaleValue(80)),
    );
    
    // عناصر المفتاح
    final legendItems = [
      {"color": const Color(0xFF1E3A8A), "text": "موقعك"},
      {"color": const Color(0xFFF0F8FF), "text": "ممرات"},
      {"color": Colors.orange, "text": "متاجر مفتوحة"},
      {"color": Colors.grey.shade400, "text": "متاجر مغلقة"},
      {"color": Colors.red, "text": "مفضلة"},
      {"color": Colors.green, "text": "ازدحام خفيف"},
      {"color": Colors.orange, "text": "ازدحام متوسط"},
      {"color": Colors.red, "text": "ازدحام كثيف"},
    ];
    
    for (int i = 0; i < legendItems.length; i++) {
      final y = scaleValue(105) + i * scaleValue(18);
      
      // رسم المربع الملون
      final colorPaint = Paint()
        ..color = legendItems[i]["color"] as Color
        ..style = PaintingStyle.fill;
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width - scaleValue(190), y, scaleValue(12), scaleValue(12)),
          Radius.circular(scaleValue(3)),
        ),
        colorPaint,
      );
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width - scaleValue(190), y, scaleValue(12), scaleValue(12)),
          Radius.circular(scaleValue(3)),
        ),
        Paint()..color = const Color(0xFF87CEEB)..style = PaintingStyle.stroke..strokeWidth = scaleValue(1),
      );
      
      // رسم النص
      final textPainter = TextPainter(
        text: TextSpan(
          text: legendItems[i]["text"] as String,
          style: TextStyle(
            color: const Color(0xFF1E3A8A),
            fontSize: scaleValue(11),
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.rtl,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size.width - scaleValue(170), y + scaleValue(1)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant MallFloorPainter oldDelegate) {
    return oldDelegate.floorData != floorData ||
           oldDelegate.userPosition != userPosition ||
           oldDelegate.selectedShop != selectedShop ||
           oldDelegate.isNavigating != isNavigating ||
           oldDelegate.favoriteShops != favoriteShops ||
           oldDelegate.pulseAnimation.value != pulseAnimation.value ||
           oldDelegate.pathAnimation.value != pathAnimation.value ||
           oldDelegate.screenSize != screenSize;
  }
}
