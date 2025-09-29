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
  Offset? targetPosition;
  Offset legendOffset = Offset.zero;
  
  late AnimationController _pulseController;
  late AnimationController _pathController;
  late AnimationController _navigationPanelController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _pathAnimation;
  late Animation<Offset> _navigationSlideAnimation;

  // ScrollController للتحكم في الاسكرول
  late ScrollController _scrollController;

  // موقع المستخدم (افتراضي بالقرب من المدخل) - نسبي
  Offset userPosition = const Offset(0.5, 0.9); // نسب مئوية

  // نظام التحديث الديناميكي
  Timer? _crowdUpdateTimer;
  DateTime lastUpdateTime = DateTime.now();

  // عناصر قائمة المفاتيح
  List<Map<String, dynamic>> get legendItems => [
    {"type": "user", "color": const Color(0xFF4facfe), "text": "موقعك الحالي"},
    {"type": "shop_open", "color": const Color(0xFF00D084), "text": "متجر مفتوح"},
    {"type": "shop_closed", "color": const Color(0xFF636E72), "text": "متجر مغلق"},
    {"type": "facility", "color": const Color(0xFF6c5ce7), "text": "مرافق عامة"},
    {"type": "favorite", "color": const Color(0xFFE84142), "text": "متجر مفضل"},
    {"type": "crowd_light", "color": const Color(0xFF00D084), "text": "ازدحام خفيف"},
    {"type": "crowd_medium", "color": const Color(0xFFFFB800), "text": "ازدحام متوسط"},
    {"type": "crowd_heavy", "color": const Color(0xFFE84142), "text": "ازدحام كثيف"},
    {"type": "walkway", "color": Colors.white, "text": "ممرات"},
    {"type": "selected", "color": const Color(0xFF4facfe), "text": "عنصر محدد"},
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startCrowdUpdates();
    _scrollController = ScrollController();
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
    
    _navigationPanelController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

    _navigationSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _navigationPanelController,
      curve: Curves.elasticOut,
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
    
    _showCrowdUpdateNotification();
  }

  String _calculateDynamicCrowdLevel(String category, int hour, math.Random random, String name) {
    double crowdFactor = 0.0;
    
    if (hour >= 18 && hour <= 22) {
      crowdFactor += 0.4;
    } else if (hour >= 12 && hour <= 15) {
      crowdFactor += 0.3;
    } else if (hour >= 10 && hour <= 12) {
      crowdFactor += 0.2;
    }
    
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
        if (name.contains("مصعد")) {
          crowdFactor += (hour >= 18 && hour <= 21) ? 0.4 : 0.2;
        } else if (name.contains("حمام")) {
          crowdFactor += 0.15;
        }
        break;
    }
    
    crowdFactor += (random.nextDouble() - 0.5) * 0.3;
    
    if (crowdFactor < 0.25) {
      return "خفيف";
    } else if (crowdFactor < 0.6) {
      return "متوسط";
    } else {
      return "مزدحم";
    }
  }

  bool _isShopOpen(String shopName, int hour) {
    Map<String, Map<String, int>> openingHours = {
      "ماكدونالدز": {"open": 0, "close": 24},
      "بنك مصر ATM": {"open": 0, "close": 24},
      "Starbucks": {"open": 7, "close": 24},
      "KFC": {"open": 11, "close": 2},
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
        return hour >= openTime || hour < closeTime;
      } else {
        return hour >= openTime && hour < closeTime;
      }
    }
    
    return hour >= 10 && hour < 23;
  }

  void _showCrowdUpdateNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.update, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "تم تحديث حالة الازدحام - ${_formatTime(lastUpdateTime)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF4facfe),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  // بيانات الأدوار مع تحسينات
  final Map<String, Map<String, dynamic>> floorData = {
    "floor1": {
      "name": "الدور الأرضي",
      "shops": [
        {
          "name": "Nike",
          "category": "رياضة",
          "position": const Offset(0.075, 0.214),
          "size": const Size(0.15, 0.114),
          "color": const Color(0xFFFF6B35), // برتقالي حديث
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
          "color": const Color(0xFF6C5CE7), // بنفسجي حديث
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
          "color": const Color(0xFF00D084), // أخضر حديث
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
          "color": const Color(0xFF2D3436), // رمادي داكن حديث
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
          "color": const Color(0xFFE84142),
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
          "color": const Color(0xFF0984e3),
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
          "color": const Color(0xFF00D084),
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
          "color": const Color(0xFF3742fa),
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
          "color": const Color(0xFFFF6B35),
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
          "color": const Color(0xFFE84142),
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
          "color": const Color(0xFF636E72),
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "مصعد 2", 
          "position": const Offset(0.5625, 0.714),
          "icon": Icons.elevator,
          "color": const Color(0xFF636E72),
          "isOpen": true,
          "crowdLevel": "متوسط",
        },
        {
          "name": "حمامات رجال",
          "position": const Offset(0.75, 0.6),
          "icon": Icons.man,
          "color": const Color(0xFF0984e3),
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "حمامات نساء",
          "position": const Offset(0.8125, 0.6),
          "icon": Icons.woman,
          "color": const Color(0xFFfd79a8),
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "مدخل رئيسي",
          "position": const Offset(0.5, 0.929),
          "icon": Icons.door_front_door,
          "color": const Color(0xFF8b4513),
          "isOpen": true,
          "crowdLevel": "متوسط",
        },
        {
          "name": "خدمة عملاء",
          "position": const Offset(0.4375, 0.6),
          "icon": Icons.help_center,
          "color": const Color(0xFF6c5ce7),
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "مكتب الأمن",
          "position": const Offset(0.625, 0.6),
          "icon": Icons.security,
          "color": const Color(0xFFE84142),
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
          "color": const Color(0xFF00b894),
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
          "color": const Color(0xFFE84142),
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
          "color": const Color(0xFFfd79a8),
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
          "color": const Color(0xFF0984e3),
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
          "color": const Color(0xFFE84142),
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
          "color": const Color(0xFFE84142),
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
          "color": const Color(0xFF6c5ce7),
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
          "color": const Color(0xFFFF6B35),
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
          "color": const Color(0xFF8b4513),
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
          "color": const Color(0xFF00cec9),
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
          "color": const Color(0xFF636E72),
          "isOpen": true,
          "crowdLevel": "متوسط",
        },
        {
          "name": "مصعد 2",
          "position": const Offset(0.5625, 0.714),
          "icon": Icons.elevator, 
          "color": const Color(0xFF636E72),
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "حمامات رجال",
          "position": const Offset(0.75, 0.629),
          "icon": Icons.man,
          "color": const Color(0xFF0984e3),
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "حمامات نساء",
          "position": const Offset(0.8125, 0.629),
          "icon": Icons.woman,
          "color": const Color(0xFFfd79a8),
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "منطقة جلوس",
          "position": const Offset(0.5, 0.629),
          "icon": Icons.chair,
          "color": const Color(0xFF8b4513),
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "كافتيريا",
          "position": const Offset(0.625, 0.629),
          "icon": Icons.local_cafe,
          "color": const Color(0xFFFF6B35),
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
          "color": const Color(0xFF6c5ce7),
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
          "color": const Color(0xFF3742fa),
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
          "color": const Color(0xFF00b894),
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
          "color": const Color(0xFFFF6B35),
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
          "color": const Color(0xFFE84142),
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
          "color": const Color(0xFF8b4513),
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
          "color": const Color(0xFFE84142),
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
          "color": const Color(0xFF00b894),
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
          "color": const Color(0xFF00cec9),
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
          "color": const Color(0xFF636E72),
          "isOpen": true,
          "crowdLevel": "متوسط",
        },
        {
          "name": "مصعد 2",
          "position": const Offset(0.5625, 0.829),
          "icon": Icons.elevator,
          "color": const Color(0xFF636E72),
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "حمامات رجال",
          "position": const Offset(0.8, 0.643),
          "icon": Icons.man,
          "color": const Color(0xFF0984e3),
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "حمامات نساء",
          "position": const Offset(0.8625, 0.643),
          "icon": Icons.woman,
          "color": const Color(0xFFfd79a8),
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "تراس خارجي",
          "position": const Offset(0.8, 0.414),
          "icon": Icons.deck,
          "color": const Color(0xFF00b894),
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "منطقة تدخين",
          "position": const Offset(0.8625, 0.414),
          "icon": Icons.smoking_rooms,
          "color": const Color(0xFF636E72),
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
        {
          "name": "صراف آلي",
          "position": const Offset(0.8, 0.829),
          "icon": Icons.atm,
          "color": const Color(0xFF0984e3),
          "isOpen": true,
          "crowdLevel": "خفيف",
        },
      ],
    },
  };

  Color getCrowdColor(String crowdLevel) {
    switch (crowdLevel) {
      case "خفيف":
        return const Color(0xFF00D084); // أخضر حديث
      case "متوسط":
        return const Color(0xFFFFB800); // برتقالي حديث
      case "مزدحم":
        return const Color(0xFFE84142); // أحمر حديث
      default:
        return const Color(0xFF636E72);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // خلفية حديثة
      body: Stack(
        children: [
          // المحتوى الرئيسي مع اسكرول محسن
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(), // فيزياء اسكرول أفضل
            slivers: [
              _buildModernAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildEnhancedFloorSelector(),
                    _buildModernStatusBar(),
                    _buildStylishFavoritesButton(),
                    _buildInteractiveMapContainer(),
                    // مساحة إضافية للاسكرول عند ظهور لوحة التنقل
                    SizedBox(height: isNavigating ? 200 : 20),
                  ],
                ),
              ),
            ],
          ),
          
          // لوحة التنقل المنزلقة
          if (isNavigating && selectedShop != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SlideTransition(
                position: _navigationSlideAnimation,
                child: _buildModernNavigationPanel(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.map, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "خريطة مول", 
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        const Text(
                          "خريطة تفاعلية ذكية",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildModernActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernActionButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildGlassmorphismButton(
          icon: Icons.analytics_outlined,
          onPressed: () => _showCrowdAnalysis(),
        ),
        const SizedBox(width: 8),
        _buildGlassmorphismButton(
          icon: Icons.my_location_outlined,
          onPressed: () {
            setState(() {
              userPosition = const Offset(0.5, 0.9);
              selectedShop = null;
              targetPosition = null;
              isNavigating = false;
            });
            _pathController.reset();
            _navigationPanelController.reverse();
          },
        ),
      ],
    );
  }

  Widget _buildGlassmorphismButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedFloorSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4facfe).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: floorData.entries.map((entry) {
          final isSelected = selectedFloor == entry.key;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedFloor = entry.key;
                  selectedShop = null;
                  targetPosition = null;
                  isNavigating = false;
                  _pathController.reset();
                  _navigationPanelController.reverse();
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
                        )
                      : null,
                  color: isSelected ? null : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  entry.value["name"],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModernStatusBar() {
    final currentTime = DateTime.now();
    final shops = floorData[selectedFloor]!["shops"] as List;
    
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.access_time, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "الوقت الحالي: ${_formatTime(currentTime)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    Text(
                      "المتاجر المفتوحة: $openShops من $totalShops",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              _buildModernRefreshButton(),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildModernCrowdIndicator("خفيف", crowdStats["خفيف"]!, const Color(0xFF00D084)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernCrowdIndicator("متوسط", crowdStats["متوسط"]!, const Color(0xFFFFB800)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildModernCrowdIndicator("مزدحم", crowdStats["مزدحم"]!, const Color(0xFFE84142)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "آخر تحديث: ${_formatTime(lastUpdateTime)}",
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernRefreshButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4facfe).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _updateCrowdLevels(),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                SizedBox(width: 6),
                Text(
                  "تحديث",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernCrowdIndicator(String level, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
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

  Widget _buildStylishFavoritesButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.pink.shade400,
              Colors.red.shade400,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _showFavorites(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_rounded, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    "المفضلة (${favoriteShops.length})",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
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

  Widget _buildInteractiveMapContainer() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 500,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                    painter: ModernMallFloorPainter(
                      floorData: floorData[selectedFloor]!,
                      userPosition: Offset(
                        userPosition.dx * constraints.maxWidth,
                        userPosition.dy * constraints.maxHeight,
                      ),
                      selectedShop: selectedShop,
                      targetPosition: targetPosition,
                      pulseAnimation: _pulseAnimation,
                      pathAnimation: _pathAnimation,
                      isNavigating: isNavigating,
                      favoriteShops: favoriteShops,
                      screenSize: Size(constraints.maxWidth, constraints.maxHeight),
                    ),
                    child: GestureDetector(
                      onTapUp: (details) => _handleMapTap(
                        details.localPosition,
                        constraints.maxWidth,
                        constraints.maxHeight,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildLegendWidget(),
        ],
      ),
    );
  }

  Widget _buildLegendWidget() {
    return Positioned(
      right: 16,
      top: 80,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            legendOffset += details.delta;
          });
        },
        child: Transform.translate(
          offset: legendOffset,
          child: Container(
            width: 140,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF4facfe).withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "مفتاح الخريطة",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 8),
                ...legendItems.map((item) => GestureDetector(
                  onTap: () => _showLegendItemInfo(item["text"] as String),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        _buildLegendIndicatorWidget(item),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item["text"] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2D3436),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegendIndicatorWidget(Map<String, dynamic> item) {
    final type = item["type"] as String;
    final color = item["color"] as Color;
    switch (type) {
      case "user":
        return Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          child: Container(
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        );
      case "shop_open":
      case "shop_closed":
        return Container(
          width: 16,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      case "facility":
      case "crowd_light":
      case "crowd_medium":
      case "crowd_heavy":
        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        );
      case "favorite":
        return Icon(Icons.favorite, size: 12, color: color);
      case "walkway":
        return Container(
          width: 16,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      case "selected":
        return Container(
          width: 16,
          height: 12,
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      default:
        return Container(width: 12, height: 12, color: color);
    }
  }

  void _showLegendItemInfo(String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("شرح العنصر"),
        content: Text("هذا العنصر يمثل: $text في الخريطة."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("موافق"),
          ),
        ],
      ),
    );
  }

  void _handleMapTap(Offset position, double width, double height) {
    final shops = floorData[selectedFloor]!["shops"] as List;
    final facilities = floorData[selectedFloor]!["facilities"] as List;
    
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
        final center = Offset(
          shopPosition.dx + shopSize.width / 2,
          shopPosition.dy + shopSize.height / 2,
        );
        setState(() {
          selectedShop = shop["name"];
          targetPosition = center;
          isNavigating = true;
        });
        _pathController.forward();
        _navigationPanelController.forward();
        
        // اسكرول سلس للأسفل لإظهار لوحة التنقل
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        return;
      }
    }
    
    for (var facility in facilities) {
      final facilityPosition = Offset(facility["position"].dx * width, facility["position"].dy * height);
      
      final distance = (position - facilityPosition).distance;
      if (distance <= 25) {
        setState(() {
          selectedShop = facility["name"];
          targetPosition = facilityPosition;
          isNavigating = true;
        });
        _pathController.forward();
        _navigationPanelController.forward();
        
        // اسكرول سلس للأسفل
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
        return;
      }
    }
  }

  Widget _buildModernNavigationPanel() {
    final shops = floorData[selectedFloor]!["shops"] as List;
    final facilities = floorData[selectedFloor]!["facilities"] as List;
    
    var item = shops.where((s) => s["name"] == selectedShop).firstOrNull;
    item ??= facilities.where((f) => f["name"] == selectedShop).firstOrNull;
    
    if (item == null) return Container();
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مقبض السحب
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            item["color"] ?? const Color(0xFF4facfe),
                            (item["color"] ?? const Color(0xFF4facfe)).withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (item["color"] ?? const Color(0xFF4facfe)).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
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
                                    color: Color(0xFF2D3436),
                                  ),
                                ),
                              ),
                              _buildModernFavoriteButton(item),
                            ],
                          ),
                          if (item["category"] != null)
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "النوع: ${item["category"]}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildStatusChip(
                                icon: item["isOpen"] == true ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                label: item["isOpen"] == true ? "مفتوح" : "مغلق",
                                color: item["isOpen"] == true ? const Color(0xFF00D084) : const Color(0xFFE84142),
                              ),
                              const SizedBox(width: 12),
                              _buildStatusChip(
                                icon: Icons.people_rounded,
                                label: "الازدحام: ${item["crowdLevel"] ?? "غير محدد"}",
                                color: getCrowdColor(item["crowdLevel"] ?? "خفيف"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildModernActionButton(
                        icon: Icons.close_rounded,
                        label: "إنهاء التوجيه",
                        color: const Color(0xFFE84142),
                        onPressed: () {
                          setState(() {
                            isNavigating = false;
                            selectedShop = null;
                            targetPosition = null;
                          });
                          _pathController.reset();
                          _navigationPanelController.reverse();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildModernActionButton(
                        icon: Icons.info_rounded,
                        label: "التفاصيل",
                        color: const Color(0xFF4facfe),
                        onPressed: () => _showItemDetails(item),
                        isOutlined: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFavoriteButton(Map<String, dynamic> item) {
    final isFavorite = favoriteShops.contains(item["name"]);
    
    return Container(
      decoration: BoxDecoration(
        color: isFavorite ? Colors.red.withOpacity(0.1) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFavorite ? Colors.red.withOpacity(0.3) : Colors.grey.shade300,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              if (favoriteShops.contains(item["name"])) {
                favoriteShops.remove(item["name"]);
              } else {
                favoriteShops.add(item["name"]);
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFavorite ? Colors.red : Colors.grey.shade600,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: isOutlined ? null : LinearGradient(
          colors: [color, color.withOpacity(0.8)],
        ),
        color: isOutlined ? Colors.white : null,
        borderRadius: BorderRadius.circular(16),
        border: isOutlined ? Border.all(color: color, width: 1.5) : null,
        boxShadow: isOutlined ? null : [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: isOutlined ? color : Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isOutlined ? color : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showItemDetails(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      item["color"] ?? const Color(0xFF4facfe),
                      (item["color"] ?? const Color(0xFF4facfe)).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  item["icon"] ?? Icons.place,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                item["name"],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 20),
              if (item["category"] != null)
                _buildDetailItem(Icons.category_rounded, "النوع", item["category"]),
              _buildDetailItem(Icons.layers_rounded, "الدور", floorData[selectedFloor]!["name"]),
              if (item["openingHours"] != null)
                _buildDetailItem(Icons.access_time_rounded, "ساعات العمل", item["openingHours"]),
              _buildDetailItem(
                item["isOpen"] == true ? Icons.check_circle_rounded : Icons.cancel_rounded,
                "الحالة",
                item["isOpen"] == true ? "مفتوح الآن" : "مغلق الآن",
                color: item["isOpen"] == true ? const Color(0xFF00D084) : const Color(0xFFE84142),
              ),
              _buildDetailItem(
                Icons.people_rounded,
                "مستوى الازدحام",
                item["crowdLevel"] ?? "غير محدد",
                color: getCrowdColor(item["crowdLevel"] ?? "خفيف"),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildModernActionButton(
                      icon: favoriteShops.contains(item["name"]) 
                          ? Icons.favorite_rounded 
                          : Icons.favorite_border_rounded,
                      label: favoriteShops.contains(item["name"]) 
                          ? "إزالة من المفضلة" 
                          : "إضافة للمفضلة",
                      color: Colors.red,
                      isOutlined: true,
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
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildModernActionButton(
                      icon: Icons.close_rounded,
                      label: "إغلاق",
                      color: Colors.grey,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (color ?? const Color(0xFF4facfe)).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color ?? const Color(0xFF4facfe), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Color(0xFF2D3436)),
                children: [
                  TextSpan(
                    text: "$label: ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: color ?? const Color(0xFF636E72),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCrowdAnalysis() {
    // تنفيذ تحليل الازدحام المحسن
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                "تحليل الازدحام",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "التحليل قيد التطوير...",
                style: TextStyle(fontSize: 16, color: Color(0xFF636E72)),
              ),
              const SizedBox(height: 20),
              _buildModernActionButton(
                icon: Icons.close_rounded,
                label: "إغلاق",
                color: const Color(0xFF4facfe),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFavorites() {
    // تنفيذ عرض المفضلة المحسن
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.pink.shade400, Colors.red.shade400],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              const Text(
                "المتاجر المفضلة",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 20),
              favoriteShops.isEmpty
                  ? const Text(
                      "لا توجد متاجر مفضلة بعد",
                      style: TextStyle(fontSize: 16, color: Color(0xFF636E72)),
                    )
                  : SizedBox(
                      height: 300,
                      child: ListView.builder(
                        itemCount: favoriteShops.length,
                        itemBuilder: (context, index) {
                          final shopName = favoriteShops.elementAt(index);
                          return ListTile(
                            leading: const Icon(Icons.favorite_rounded, color: Colors.red),
                            title: Text(shopName),
                            trailing: IconButton(
                              onPressed: () {
                                setState(() {
                                  favoriteShops.remove(shopName);
                                });
                                Navigator.pop(context);
                                _showFavorites();
                              },
                              icon: const Icon(Icons.delete_rounded, color: Colors.red),
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 20),
              _buildModernActionButton(
                icon: Icons.close_rounded,
                label: "إغلاق",
                color: const Color(0xFF4facfe),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pathController.dispose();
    _navigationPanelController.dispose();
    _scrollController.dispose();
    _crowdUpdateTimer?.cancel();
    super.dispose();
  }
}

// CustomPainter محسن
class ModernMallFloorPainter extends CustomPainter {
  final Map<String, dynamic> floorData;
  final Offset userPosition;
  final String? selectedShop;
  final Offset? targetPosition;
  final Animation<double> pulseAnimation;
  final Animation<double> pathAnimation;
  final bool isNavigating;
  final Set<String> favoriteShops;
  final Size screenSize;

  ModernMallFloorPainter({
    required this.floorData,
    required this.userPosition,
    this.selectedShop,
    this.targetPosition,
    required this.pulseAnimation,
    required this.pathAnimation,
    required this.isNavigating,
    required this.favoriteShops,
    required this.screenSize,
  }) : super(repaint: pulseAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    _drawModernBackground(canvas, size);
    _drawModernWalkways(canvas, size);
    _drawModernShops(canvas);
    _drawModernFacilities(canvas);
    _drawModernUserPosition(canvas);
    if (isNavigating && targetPosition != null) _drawModernNavigationPath(canvas);
    _drawModernLabels(canvas, size);
  }

  void _drawModernBackground(Canvas canvas, Size size) {
    // خلفية متدرجة حديثة
    final gradient = LinearGradient(
      colors: [
        const Color(0xFFF8F9FA),
        const Color(0xFFE9ECEF),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..shader = gradient.createShader(rect);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(24)),
      paint,
    );
  }

  void _drawModernWalkways(Canvas canvas, Size size) {
    final walkwayPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    
    // الممرات مع ظلال ناعمة
    final walkways = [
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.1, size.height * 0.2, size.width * 0.8, size.height * 0.12),
        const Radius.circular(16),
      ),
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.1, size.height * 0.5, size.width * 0.8, size.height * 0.12),
        const Radius.circular(16),
      ),
    ];
    
    for (var walkway in walkways) {
      // رسم الظل
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          walkway.outerRect.translate(0, 2),
          walkway.tlRadius,
        ),
        shadowPaint,
      );
      // رسم الممر
      canvas.drawRRect(walkway, walkwayPaint);
    }
  }

  void _drawModernShops(Canvas canvas) {
    final shops = floorData["shops"] as List;
    
    for (var shop in shops) {
      final position = Offset(
        shop["position"].dx * screenSize.width,
        shop["position"].dy * screenSize.height,
      );
      final shopSize = Size(
        shop["size"].width * screenSize.width,
        shop["size"].height * screenSize.height,
      );
      final color = shop["color"] as Color;
      final isOpen = shop["isOpen"] as bool;
      
      // ظل المتجر
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
      final shopRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(position.dx, position.dy, shopSize.width, shopSize.height),
        const Radius.circular(16),
      );
      
      // رسم الظل
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          shopRect.outerRect.translate(0, 4),
          shopRect.tlRadius,
        ),
        shadowPaint,
      );
      
      // رسم المتجر
      final shopPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            isOpen ? color : color.withOpacity(0.5),
            isOpen ? color.withOpacity(0.8) : color.withOpacity(0.3),
          ],
        ).createShader(shopRect.outerRect);
      
      canvas.drawRRect(shopRect, shopPaint);
      
      // تمييز المتجر المحدد
      if (selectedShop == shop["name"]) {
        final highlightPaint = Paint()
          ..color = const Color(0xFF4facfe)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        canvas.drawRRect(shopRect, highlightPaint);
      }
      
      // رسم اسم المتجر
      final textPainter = TextPainter(
        text: TextSpan(
          text: shop["name"],
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.rtl,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          position.dx + (shopSize.width - textPainter.width) / 2,
          position.dy + (shopSize.height - textPainter.height) / 2,
        ),
      );
    }
  }

  void _drawModernFacilities(Canvas canvas) {
    final facilities = floorData["facilities"] as List;
    
    for (var facility in facilities) {
      final position = Offset(
        facility["position"].dx * screenSize.width,
        facility["position"].dy * screenSize.height,
      );
      final color = facility["color"] as Color;
      
      // رسم دائرة حديثة للمرفق
      final facilityPaint = Paint()
        ..shader = RadialGradient(
          colors: [color, color.withOpacity(0.7)],
        ).createShader(Rect.fromCircle(center: position, radius: 20));
      
      canvas.drawCircle(position, 20, facilityPaint);
      
      // الحدود البيضاء
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawCircle(position, 20, borderPaint);
    }
  }

  void _drawModernUserPosition(Canvas canvas) {
    // تأثير النبض
    final pulsePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF4facfe).withOpacity(0.3),
          const Color(0xFF4facfe).withOpacity(0.1),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(center: userPosition, radius: 30 * pulseAnimation.value),
      );
    
    canvas.drawCircle(userPosition, 30 * pulseAnimation.value, pulsePaint);
    
    // موقع المستخدم
    final userPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF4facfe),
          const Color(0xFF00f2fe),
        ],
      ).createShader(Rect.fromCircle(center: userPosition, radius: 12));
    
    canvas.drawCircle(userPosition, 12, userPaint);
    
    // الحدود البيضاء
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    canvas.drawCircle(userPosition, 12, borderPaint);
  }

  void _drawModernNavigationPath(Canvas canvas) {
    // رسم المسار إلى الهدف
    if (targetPosition == null) return;
    
    final endPoint = Offset.lerp(userPosition, targetPosition!, pathAnimation.value) ?? userPosition;
    
    final pathPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
      ).createShader(Rect.fromLTWH(0, 0, screenSize.width, screenSize.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(userPosition, endPoint, pathPaint);
  }

  void _drawModernLabels(Canvas canvas, Size size) {
    // رسم عنوان حديث
    final titlePainter = TextPainter(
      text: TextSpan(
        text: floorData["name"],
        style: const TextStyle(
          color: Color(0xFF2D3436),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.rtl,
    );
    
    titlePainter.layout();
    
    // خلفية العنوان
    final titleBg = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, 30),
        width: titlePainter.width + 40,
        height: titlePainter.height + 16,
      ),
      const Radius.circular(16),
    );
    
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawRRect(titleBg, bgPaint);
    
    titlePainter.paint(
      canvas,
      Offset(
        (size.width - titlePainter.width) / 2,
        22,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant ModernMallFloorPainter oldDelegate) {
    return oldDelegate.pulseAnimation.value != pulseAnimation.value ||
           oldDelegate.pathAnimation.value != pathAnimation.value ||
           oldDelegate.selectedShop != selectedShop ||
           oldDelegate.targetPosition != targetPosition ||
           oldDelegate.isNavigating != isNavigating;
  }
}