// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ExploreLocationScreen extends StatefulWidget {
  final String userName;
  const ExploreLocationScreen({super.key, required this.userName});

  @override
  State<ExploreLocationScreen> createState() => _ExploreLocationScreenState();
}

class _ExploreLocationScreenState extends State<ExploreLocationScreen> {
  int? _currentFloor;
  bool _isQRScannerOpen = false;
  MobileScannerController? _scannerController; // بدل QRViewController

  // City Stars Mall floor plans - each floor has different stores
  final Map<int, FloorData> _floorPlans = {
    1: FloorData(
      floorNumber: 1,
      floorName: 'الدور الأول - الأزياء والإلكترونيات',
      stores: {
        'Zara': MallStore(
          name: 'Zara',
          position: const Offset(150, 200),
          category: 'أزياء نسائية',
          emoji: '👗',
          description: 'أحدث صيحات الموضة العالمية',
          floorNumber: 1,
        ),
        'H&M': MallStore(
          name: 'H&M',
          position: const Offset(300, 180),
          category: 'أزياء رجالية ونسائية',
          emoji: '🧥',
          description: 'موضة عصرية بأسعار مناسبة',
          floorNumber: 1,
        ),
        'Apple Store': MallStore(
          name: 'Apple Store',
          position: const Offset(200, 120),
          category: 'إلكترونيات',
          emoji: '📱',
          description: 'أحدث منتجات أبل',
          floorNumber: 1,
        ),
        'Samsung': MallStore(
          name: 'Samsung',
          position: const Offset(350, 120),
          category: 'إلكترونيات',
          emoji: '📺',
          description: 'هواتف وأجهزة سامسونج',
          floorNumber: 1,
        ),
        'Carrefour Express': MallStore(
          name: 'Carrefour Express',
          position: const Offset(250, 300),
          category: 'سوبرماركت',
          emoji: '🛒',
          description: 'احتياجات يومية وأطعمة',
          floorNumber: 1,
        ),
      },
      amenities: {
        'ATM': const Offset(100, 250),
        'Restroom': const Offset(380, 250),
        'Information': const Offset(200, 50),
        'Elevator': const Offset(50, 150),
        'Escalator': const Offset(400, 150),
      },
    ),
    2: FloorData(
      floorNumber: 2,
      floorName: 'الدور الثاني - المطاعم والترفيه',
      stores: {
        'KFC': MallStore(
          name: 'KFC',
          position: const Offset(120, 180),
          category: 'مطاعم',
          emoji: '🍗',
          description: 'دجاج مقرمش وأطباق سريعة',
          floorNumber: 2,
        ),
        'McDonald\'s': MallStore(
          name: 'McDonald\'s',
          position: const Offset(280, 160),
          category: 'مطاعم',
          emoji: '🍟',
          description: 'البرجر الشهير والوجبات السريعة',
          floorNumber: 2,
        ),
        'Pizza Hut': MallStore(
          name: 'Pizza Hut',
          position: const Offset(200, 220),
          category: 'مطاعم',
          emoji: '🍕',
          description: 'بيتزا إيطالية أصلية',
          floorNumber: 2,
        ),
        'Starbucks': MallStore(
          name: 'Starbucks',
          position: const Offset(150, 120),
          category: 'مقاهي',
          emoji: '☕',
          description: 'قهوة عالمية ومشروبات ساخنة',
          floorNumber: 2,
        ),
        'Cinema': MallStore(
          name: 'VOX Cinema',
          position: const Offset(320, 280),
          category: 'ترفيه',
          emoji: '🎬',
          description: 'أحدث الأفلام العربية والأجنبية',
          floorNumber: 2,
        ),
        'Kids Area': MallStore(
          name: 'منطقة الأطفال',
          position: const Offset(100, 300),
          category: 'ترفيه',
          emoji: '🎮',
          description: 'ألعاب وأنشطة للأطفال',
          floorNumber: 2,
        ),
      },
      amenities: {
        'ATM': const Offset(350, 200),
        'Restroom': const Offset(80, 100),
        'Information': const Offset(200, 50),
        'Elevator': const Offset(50, 150),
        'Escalator': const Offset(400, 150),
        'Food Court': const Offset(200, 320),
      },
    ),
    3: FloorData(
      floorNumber: 3,
      floorName: 'الدور الثالث - الجمال والصحة',
      stores: {
        'Pharmacy': MallStore(
          name: 'صيدلية سيف',
          position: const Offset(180, 200),
          category: 'صيدلية',
          emoji: '💊',
          description: 'أدوية ومستحضرات طبية',
          floorNumber: 3,
        ),
        'MAC Cosmetics': MallStore(
          name: 'MAC Cosmetics',
          position: const Offset(280, 180),
          category: 'مستحضرات تجميل',
          emoji: '💄',
          description: 'مستحضرات تجميل عالمية',
          floorNumber: 3,
        ),
        'The Body Shop': MallStore(
          name: 'The Body Shop',
          position: const Offset(150, 150),
          category: 'عناية بالجسم',
          emoji: '🧴',
          description: 'منتجات طبيعية للعناية',
          floorNumber: 3,
        ),
        'Fitness First': MallStore(
          name: 'Fitness First',
          position: const Offset(320, 250),
          category: 'لياقة بدنية',
          emoji: '🏋️',
          description: 'نادي رياضي وصحي',
          floorNumber: 3,
        ),
        'Optical Shop': MallStore(
          name: 'محل النظارات',
          position: const Offset(120, 280),
          category: 'نظارات',
          emoji: '👓',
          description: 'نظارات طبية وشمسية',
          floorNumber: 3,
        ),
        'Spa Center': MallStore(
          name: 'مركز السبا',
          position: const Offset(350, 120),
          category: 'استرخاء',
          emoji: '🧘',
          description: 'خدمات التدليك والاسترخاء',
          floorNumber: 3,
        ),
      },
      amenities: {
        'ATM': const Offset(100, 180),
        'Restroom': const Offset(380, 180),
        'Information': const Offset(200, 50),
        'Elevator': const Offset(50, 150),
        'Escalator': const Offset(400, 150),
      },
    ),
  };

  // Valid QR codes for each floor
  final Map<String, int> _validQRCodes = {
    'CITYSTARS_FLOOR_1_ENTRANCE': 1,
    'CITYSTARS_FLOOR_2_ENTRANCE': 2,
    'CITYSTARS_FLOOR_3_ENTRANCE': 3,
  };

  MallStore? _selectedStore;
  String? _searchQuery;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _scanQRCode() async {
    _scannerController = MobileScannerController(); // جديد
    setState(() {
      _isQRScannerOpen = true;
    });
  }

  void _processQRCode(String qrCode) {
    if (_validQRCodes.containsKey(qrCode)) {
      final floor = _validQRCodes[qrCode]!;
      setState(() {
        _currentFloor = floor;
        _isQRScannerOpen = false;
      });
      _scannerController?.dispose(); // بدل _qrController?.dispose()

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم الدخول إلى ${_floorPlans[floor]!.floorName}'),
          backgroundColor: const Color(0xFF87CEEB),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('رمز QR غير صحيح لمول سيتي ستارز'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showStoreDetails(MallStore store) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Store info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF87CEEB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        store.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D9A),
                            ),
                          ),
                          Text(
                            store.category,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'الدور ${store.floorNumber}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF87CEEB),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Text(
                  store.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),

                const SizedBox(height: 20),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showDirections(store),
                        icon: const Icon(Icons.directions, color: Colors.white),
                        label: const Text('الاتجاهات',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF87CEEB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _shareStore(store),
                        icon: const Icon(Icons.share, color: Color(0xFF87CEEB)),
                        label: const Text('مشاركة',
                            style: TextStyle(color: Color(0xFF87CEEB))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF87CEEB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDirections(MallStore store) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('الاتجاهات إلى ${store.name} - ${store.category}'),
        backgroundColor: const Color(0xFF87CEEB),
      ),
    );
  }

  void _shareStore(MallStore store) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم مشاركة موقع ${store.name}'),
        backgroundColor: const Color(0xFF87CEEB),
      ),
    );
  }

  List<MallStore> _getFilteredStores() {
    if (_currentFloor == null) return [];

    final stores = _floorPlans[_currentFloor]!.stores.values.toList();

    if (_searchQuery == null || _searchQuery!.isEmpty) {
      return stores;
    }

    return stores
        .where((store) =>
            store.name.toLowerCase().contains(_searchQuery!.toLowerCase()) ||
            store.category.toLowerCase().contains(_searchQuery!.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: Text(
          _currentFloor != null
              ? 'سيتي ستارز - الدور $_currentFloor'
              : 'سيتي ستارز مول',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF87CEEB),
        elevation: 0,
        actions: [
          if (_currentFloor != null) ...[
            IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: StoreSearchDelegate(
                      _getFilteredStores(), _showStoreDetails),
                );
              },
              icon: const Icon(Icons.search, color: Colors.white),
              tooltip: 'البحث في المتاجر',
            ),
            PopupMenuButton<int>(
              onSelected: (floor) {
                setState(() {
                  _currentFloor = floor;
                });
              },
              icon: const Icon(Icons.layers, color: Colors.white),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(Icons.store),
                      SizedBox(width: 8),
                      Text('الدور الأول'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(Icons.restaurant),
                      SizedBox(width: 8),
                      Text('الدور الثاني'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 3,
                  child: Row(
                    children: [
                      Icon(Icons.spa),
                      SizedBox(width: 8),
                      Text('الدور الثالث'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: _isQRScannerOpen
          ? _buildQRScanner()
          : _currentFloor == null
              ? _buildWelcomeScreen()
              : _buildFloorMap(),
      floatingActionButton: _currentFloor == null
          ? FloatingActionButton.extended(
              onPressed: _scanQRCode,
              backgroundColor: const Color(0xFF87CEEB),
              icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
              label:
                  const Text('مسح QR', style: TextStyle(color: Colors.white)),
            )
          : FloatingActionButton(
              onPressed: () {
                setState(() {
                  _currentFloor = null;
                });
              },
              backgroundColor: const Color(0xFF87CEEB),
              child: const Icon(Icons.exit_to_app, color: Colors.white),
            ),
    );
  }

  // الويدجت الجديد بتاع mobile_scanner
  Widget _buildQRScanner() {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: MobileScanner(
            controller: _scannerController,
            onDetect: (BarcodeCapture barcodeCapture) {
              final List<Barcode> barcodes = barcodeCapture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _processQRCode(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Text(
                  'امسح رمز QR الموجود عند مدخل كل دور',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isQRScannerOpen = false;
                    });
                    _scannerController?.dispose();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                  ),
                  child: const Text('إلغاء',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF87CEEB),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.location_city,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'مرحباً بكم في سيتي ستارز مول',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D9A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            const Text(
              'للبدء في التنقل، امسح رمز QR الموجود عند مدخل كل دور',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Text('🛍️', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 10),
                      Text(
                        'الدور الأول: الأزياء والإلكترونيات',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text('🍔', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 10),
                      Text(
                        'الدور الثاني: المطاعم والترفيه',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text('💊', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 10),
                      Text(
                        'الدور الثالث: الجمال والصحة',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // أزرار التجربة - تظهر دائماً الآن
            const Text(
              'أو اختر الدور مباشرة:',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF2E7D9A),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () =>
                      _processQRCode('CITYSTARS_FLOOR_1_ENTRANCE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Text('🛍️', style: TextStyle(fontSize: 18)),
                  label: const Text('الدور الأول',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      _processQRCode('CITYSTARS_FLOOR_2_ENTRANCE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Text('🍔', style: TextStyle(fontSize: 18)),
                  label: const Text('الدور الثاني',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      _processQRCode('CITYSTARS_FLOOR_3_ENTRANCE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91E63),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Text('💊', style: TextStyle(fontSize: 18)),
                  label: const Text('الدور الثالث',
                      style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloorMap() {
    final floorData = _floorPlans[_currentFloor]!;

    return Column(
      children: [
        // Floor info header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFF87CEEB),
                child: Text(
                  '${floorData.floorNumber}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      floorData.floorName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D9A),
                      ),
                    ),
                    Text(
                      '${floorData.stores.length} متجر متاح',
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
        ),

        // Interactive floor map
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: CustomPaint(
              painter: FloorMapPainter(floorData, _selectedStore),
              child: GestureDetector(
                onTapDown: (details) {
                  final RenderBox renderBox =
                      context.findRenderObject() as RenderBox;
                  final localOffset =
                      renderBox.globalToLocal(details.globalPosition);
                  _handleMapTap(localOffset, floorData);
                },
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
        ),

        // Stores list at bottom
        Container(
          height: 120,
          margin: const EdgeInsets.all(10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: floorData.stores.length,
            itemBuilder: (context, index) {
              final store = floorData.stores.values.elementAt(index);
              final isSelected = _selectedStore?.name == store.name;

              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStore = isSelected ? null : store;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFF87CEEB) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF87CEEB)
                            : Colors.grey.shade300,
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          store.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          store.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF2E7D9A),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          store.category,
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                isSelected ? Colors.white70 : Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _handleMapTap(Offset tapPosition, FloorData floorData) {
    for (final store in floorData.stores.values) {
      final distance = (tapPosition - store.position).distance;
      if (distance < 30) {
        // 30 pixels touch radius
        _showStoreDetails(store);
        setState(() {
          _selectedStore = store;
        });
        return;
      }
    }

    // Deselect if tapping empty area
    setState(() {
      _selectedStore = null;
    });
  }

  @override
  void dispose() {
    _scannerController?.dispose(); // بدل _qrController?.dispose()
    super.dispose();
  }
}

class FloorMapPainter extends CustomPainter {
  final FloorData floorData;
  final MallStore? selectedStore;

  FloorMapPainter(this.floorData, this.selectedStore);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Draw floor background
    paint.color = const Color(0xFFF5F5F5);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw floor outline
    paint.color = Colors.grey.shade300;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawRect(
      Rect.fromLTWH(20, 20, size.width - 40, size.height - 40),
      paint,
    );

    // Draw walkways
    paint.color = Colors.grey.shade200;
    paint.style = PaintingStyle.fill;

    // Main horizontal walkway
    canvas.drawRect(
      Rect.fromLTWH(50, size.height * 0.4, size.width - 100, 60),
      paint,
    );

    // Vertical walkways
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.2, 50, 60, size.height - 100),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.7, 50, 60, size.height - 100),
      paint,
    );

    // Draw amenities
    for (final entry in floorData.amenities.entries) {
      final amenityName = entry.key;
      final position = entry.value;

      paint.color = Colors.grey.shade400;
      paint.style = PaintingStyle.fill;

      // Scale position to canvas size
      final scaledX = (position.dx / 400) * size.width;
      final scaledY = (position.dy / 350) * size.height;

      canvas.drawCircle(Offset(scaledX, scaledY), 15, paint);

      // Draw amenity icon
      final textPainter = TextPainter(
        text: TextSpan(
          text: _getAmenityIcon(amenityName),
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
            scaledX - textPainter.width / 2, scaledY - textPainter.height / 2),
      );
    }

    // Draw stores
    for (final store in floorData.stores.values) {
      final isSelected = selectedStore?.name == store.name;

      // Scale position to canvas size
      final scaledX = (store.position.dx / 400) * size.width;
      final scaledY = (store.position.dy / 350) * size.height;

      // Draw store background
      paint.color = isSelected ? const Color(0xFF87CEEB) : Colors.white;
      paint.style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(scaledX, scaledY), width: 80, height: 60),
          const Radius.circular(8),
        ),
        paint,
      );

      // Draw store border
      paint.color = isSelected ? const Color(0xFF2E7D9A) : Colors.grey.shade400;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = isSelected ? 3 : 1;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
              center: Offset(scaledX, scaledY), width: 80, height: 60),
          const Radius.circular(8),
        ),
        paint,
      );

      // Draw store emoji
      final emojiPainter = TextPainter(
        text: TextSpan(
          text: store.emoji,
          style: const TextStyle(fontSize: 20),
        ),
        textDirection: TextDirection.ltr,
      );
      emojiPainter.layout();
      emojiPainter.paint(
        canvas,
        Offset(scaledX - emojiPainter.width / 2, scaledY - 15),
      );

      // Draw store name
      final namePainter = TextPainter(
        text: TextSpan(
          text: store.name.length > 8
              ? '${store.name.substring(0, 8)}...'
              : store.name,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF2E7D9A),
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      namePainter.layout();
      namePainter.paint(
        canvas,
        Offset(scaledX - namePainter.width / 2, scaledY + 5),
      );
    }

    // Draw path if a store is selected
    if (selectedStore != null) {
      paint.color = const Color(0xFF87CEEB);
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 3;

      final startX = size.width * 0.1;
      final startY = size.height * 0.9;
      final endX = (selectedStore!.position.dx / 400) * size.width;
      final endY = (selectedStore!.position.dy / 350) * size.height;

      // Draw dashed line path
      _drawDashedLine(
          canvas, Offset(startX, startY), Offset(endX, endY), paint);

      // Draw "You are here" marker
      paint.color = Colors.red;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(startX, startY), 8, paint);

      final youAreHerePainter = TextPainter(
        text: const TextSpan(
          text: 'أنت هنا',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        textDirection: TextDirection.rtl,
      );
      youAreHerePainter.layout();
      youAreHerePainter.paint(
        canvas,
        Offset(startX - youAreHerePainter.width / 2, startY + 15),
      );
    }
  }

  String _getAmenityIcon(String amenityName) {
    switch (amenityName) {
      case 'ATM':
        return '🏧';
      case 'Restroom':
        return '🚻';
      case 'Information':
        return 'ℹ️';
      case 'Elevator':
        return '🛗';
      case 'Escalator':
        return '🔼';
      case 'Food Court':
        return '🍽️';
      default:
        return '📍';
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;

    final distance = (end - start).distance;
    final dashCount = (distance / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      final startPercent = (i * (dashWidth + dashSpace)) / distance;
      final endPercent = ((i * (dashWidth + dashSpace)) + dashWidth) / distance;

      final dashStart = Offset(
        start.dx + (end.dx - start.dx) * startPercent,
        start.dy + (end.dy - start.dy) * startPercent,
      );

      final dashEnd = Offset(
        start.dx + (end.dx - start.dx) * endPercent,
        start.dy + (end.dy - start.dy) * endPercent,
      );

      canvas.drawLine(dashStart, dashEnd, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class StoreSearchDelegate extends SearchDelegate<MallStore?> {
  final List<MallStore> stores;
  final Function(MallStore) onStoreSelected;

  StoreSearchDelegate(this.stores, this.onStoreSelected);

  @override
  String get searchFieldLabel => 'البحث في المتاجر...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildStoresList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildStoresList(context);
  }

  Widget _buildStoresList(BuildContext context) {
    final filteredStores = stores
        .where((store) =>
            store.name.toLowerCase().contains(query.toLowerCase()) ||
            store.category.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: filteredStores.length,
      itemBuilder: (context, index) {
        final store = filteredStores[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: const Color(0xFF87CEEB),
            child: Text(store.emoji, style: const TextStyle(fontSize: 16)),
          ),
          title: Text(store.name),
          subtitle: Text(store.category),
          onTap: () {
            close(context, store);
            onStoreSelected(store);
          },
        );
      },
    );
  }
}

class FloorData {
  final int floorNumber;
  final String floorName;
  final Map<String, MallStore> stores;
  final Map<String, Offset> amenities;

  FloorData({
    required this.floorNumber,
    required this.floorName,
    required this.stores,
    required this.amenities,
  });
}

class MallStore {
  final String name;
  final Offset position;
  final String category;
  final String emoji;
  final String description;
  final int floorNumber;

  MallStore({
    required this.name,
    required this.position,
    required this.category,
    required this.emoji,
    required this.description,
    required this.floorNumber,
  });
}