import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'dart:math' as math;

class CityStarsARNavigationScreen extends StatefulWidget {
  final String userName;
  const CityStarsARNavigationScreen({super.key, required this.userName});

  @override
  State<CityStarsARNavigationScreen> createState() => _CityStarsARNavigationScreenState();
}

class _CityStarsARNavigationScreenState extends State<CityStarsARNavigationScreen> {
  MobileScannerController? _qrScannerController;
  ArCoreController? _arController;
  bool _isQRMode = true;
  bool _isInitialized = false;
  
  // Current floor and navigation
  int? _currentFloor;
  String? _selectedStore;
  bool _isNavigating = false;
  final String _currentLocation = "المدخل الرئيسي";
  
  // AR Navigation objects
  final List<ArCoreNode> _navigationNodes = [];
  
  // City Stars Mall data
  final Map<int, FloorData> _mallData = {
    1: FloorData(
      floorNumber: 1,
      floorName: 'الدور الأول - الأزياء والإلكترونيات',
      stores: {
        'Zara': StoreLocation(
          name: 'Zara', 
          position: vector.Vector3(2, 0, -3),
          category: 'أزياء نسائية',
          icon: '👗',
          pathFromEntrance: ['اتجه شمال 20 متر', 'انعطف يمين', 'المتجر على اليسار']
        ),
        'H&M': StoreLocation(
          name: 'H&M',
          position: vector.Vector3(-1.5, 0, -2),
          category: 'أزياء رجالية ونسائية', 
          icon: '🧥',
          pathFromEntrance: ['اتجه غرب 15 متر', 'المتجر أمامك مباشرة']
        ),
        'Apple Store': StoreLocation(
          name: 'Apple Store',
          position: vector.Vector3(0, 0, -4),
          category: 'إلكترونيات',
          icon: '📱',
          pathFromEntrance: ['اتجه شمال 30 متر', 'المتجر في المنتصف']
        ),
        'Samsung': StoreLocation(
          name: 'Samsung',
          position: vector.Vector3(3, 0, -1),
          category: 'إلكترونيات',
          icon: '📺',
          pathFromEntrance: ['اتجه شرق 25 متر', 'انعطف شمال', 'المتجر على اليمين']
        ),
        'Carrefour Express': StoreLocation(
          name: 'Carrefour Express',
          position: vector.Vector3(-2, 0, -5),
          category: 'سوبرماركت',
          icon: '🛒',
          pathFromEntrance: ['اتجه غرب 20 متر', 'انعطف شمال', 'في نهاية الممر']
        ),
      },
      facilities: {
        'المصعد': vector.Vector3(-3, 0, 0),
        'الحمامات': vector.Vector3(4, 0, -2),
        'ATM': vector.Vector3(-1, 0, 0),
        'مكتب الاستعلامات': vector.Vector3(0, 0, -1),
      }
    ),
    2: FloorData(
      floorNumber: 2,
      floorName: 'الدور الثاني - المطاعم والترفيه',
      stores: {
        'KFC': StoreLocation(
          name: 'KFC',
          position: vector.Vector3(-2, 0, -3),
          category: 'مطاعم',
          icon: '🍗',
          pathFromEntrance: ['اصعد للدور الثاني', 'اتجه غرب 20 متر']
        ),
        'McDonald\'s': StoreLocation(
          name: 'McDonald\'s', 
          position: vector.Vector3(1, 0, -2),
          category: 'مطاعم',
          icon: '🍟',
          pathFromEntrance: ['اصعد للدور الثاني', 'اتجه شرق 15 متر']
        ),
        'Pizza Hut': StoreLocation(
          name: 'Pizza Hut',
          position: vector.Vector3(0, 0, -4),
          category: 'مطاعم', 
          icon: '🍕',
          pathFromEntrance: ['اصعد للدور الثاني', 'اتجه شمال 25 متر']
        ),
        'Starbucks': StoreLocation(
          name: 'Starbucks',
          position: vector.Vector3(-1, 0, -1),
          category: 'مقاهي',
          icon: '☕',
          pathFromEntrance: ['اصعد للدور الثاني', 'بجانب المصعد مباشرة']
        ),
        'VOX Cinema': StoreLocation(
          name: 'VOX Cinema',
          position: vector.Vector3(3, 0, -4),
          category: 'ترفيه',
          icon: '🎬',
          pathFromEntrance: ['اصعد للدور الثاني', 'اتجه شرق', 'في نهاية الممر']
        ),
        'منطقة الأطفال': StoreLocation(
          name: 'منطقة الأطفال',
          position: vector.Vector3(-3, 0, -2),
          category: 'ترفيه',
          icon: '🎮',
          pathFromEntrance: ['اصعد للدور الثاني', 'اتجه غرب', 'بجانب المطاعم']
        ),
      },
      facilities: {
        'المصعد': vector.Vector3(-3, 0, 0),
        'الحمامات': vector.Vector3(4, 0, -1),
        'ATM': vector.Vector3(2, 0, 0),
        'منطقة الطعام': vector.Vector3(0, 0, -5),
      }
    ),
    3: FloorData(
      floorNumber: 3,
      floorName: 'الدور الثالث - الجمال والصحة',
      stores: {
        'صيدلية سيف': StoreLocation(
          name: 'صيدلية سيف',
          position: vector.Vector3(0, 0, -2),
          category: 'صيدلية',
          icon: '💊',
          pathFromEntrance: ['اصعد للدور الثالث', 'أول متجر أمامك']
        ),
        'MAC Cosmetics': StoreLocation(
          name: 'MAC Cosmetics', 
          position: vector.Vector3(2, 0, -3),
          category: 'مستحضرات تجميل',
          icon: '💄',
          pathFromEntrance: ['اصعد للدور الثالث', 'اتجه شرق 20 متر']
        ),
        'The Body Shop': StoreLocation(
          name: 'The Body Shop',
          position: vector.Vector3(-2, 0, -1),
          category: 'عناية بالجسم',
          icon: '🧴', 
          pathFromEntrance: ['اصعد للدور الثالث', 'اتجه غرب 15 متر']
        ),
        'Fitness First': StoreLocation(
          name: 'Fitness First',
          position: vector.Vector3(3, 0, -4),
          category: 'لياقة بدنية',
          icon: '🏋️',
          pathFromEntrance: ['اصعد للدور الثالث', 'في نهاية الممر الشرقي']
        ),
        'محل النظارات': StoreLocation(
          name: 'محل النظارات',
          position: vector.Vector3(-1, 0, -3),
          category: 'نظارات',
          icon: '👓',
          pathFromEntrance: ['اصعد للدور الثالث', 'اتجه غرب ثم شمال']
        ),
        'مركز السبا': StoreLocation(
          name: 'مركز السبا',
          position: vector.Vector3(1, 0, -5),
          category: 'استرخاء',
          icon: '🧘',
          pathFromEntrance: ['اصعد للدور الثالث', 'في أقصى الشمال']
        ),
      },
      facilities: {
        'المصعد': vector.Vector3(-3, 0, 0),
        'الحمامات': vector.Vector3(4, 0, -2),
        'ATM': vector.Vector3(-1, 0, 0),
      }
    ),
  };

  // Valid QR codes for floors
  final Map<String, int> _validQRCodes = {
    'CITYSTARS_FLOOR_1_ENTRANCE': 1,
    'CITYSTARS_FLOOR_2_ENTRANCE': 2, 
    'CITYSTARS_FLOOR_3_ENTRANCE': 3,
    'CITYSTARS_MAIN_ENTRANCE': 1,
  };

  @override
  void initState() {
    super.initState();
    _initializeQRScanner();
  }

  Future<void> _initializeQRScanner() async {
    _qrScannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    setState(() {
      _isInitialized = true;
    });
  }

  void _processQRCode(String qrCode) {
    if (_validQRCodes.containsKey(qrCode)) {
      final floor = _validQRCodes[qrCode]!;
      setState(() {
        _currentFloor = floor;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('مرحباً بكم في ${_mallData[floor]!.floorName}'),
          backgroundColor: const Color(0xFF87CEEB),
        ),
      );
      
      _showStoreSelection();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('رمز QR غير صحيح لمول سيتي ستارز'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getLocationFromQR(String qrCode) {
    switch (qrCode) {
      case 'CITYSTARS_FLOOR_1_ENTRANCE':
        return 'مدخل الدور الأول';
      case 'CITYSTARS_FLOOR_2_ENTRANCE':
        return 'مدخل الدور الثاني';
      case 'CITYSTARS_FLOOR_3_ENTRANCE':
        return 'مدخل الدور الثالث';
      case 'CITYSTARS_MAIN_ENTRANCE':
        return 'المدخل الرئيسي';
      default:
        return 'موقع غير معروف';
    }
  }

  void _showStoreSelection() {
    if (_currentFloor == null) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _mallData[_currentFloor]!.floorName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'اختر المتجر أو المرفق المطلوب',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('المتاجر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  ...(_mallData[_currentFloor]!.stores.values.map((store) => 
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF87CEEB),
                          child: Text(store.icon, style: const TextStyle(fontSize: 18)),
                        ),
                        title: Text(store.name),
                        subtitle: Text(store.category),
                        trailing: const Icon(Icons.navigation),
                        onTap: () {
                          Navigator.pop(context);
                          _startNavigation(store);
                        },
                      ),
                    )
                  )),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('المرافق', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  ...(_mallData[_currentFloor]!.facilities.keys.map((facility) =>
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey[600],
                          child: Icon(_getFacilityIcon(facility), color: Colors.white),
                        ),
                        title: Text(facility),
                        trailing: const Icon(Icons.navigation),
                        onTap: () {
                          Navigator.pop(context);
                          _startNavigationToFacility(facility);
                        },
                      ),
                    )
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFacilityIcon(String facility) {
    switch (facility) {
      case 'المصعد': return Icons.elevator;
      case 'الحمامات': return Icons.wc;
      case 'ATM': return Icons.account_balance;
      case 'مكتب الاستعلامات': return Icons.info;
      case 'منطقة الطعام': return Icons.restaurant;
      default: return Icons.place;
    }
  }

  void _startNavigation(StoreLocation store) {
    setState(() {
      _selectedStore = store.name;
      _isNavigating = true;
      _isQRMode = false;
      _isInitialized = false;
    });
    
    _qrScannerController?.dispose();
    setState(() => _isInitialized = true);
  }

  void _startNavigationToFacility(String facility) {
    // Create a temporary store object for facility navigation
    final facilityPosition = _mallData[_currentFloor]!.facilities[facility]!;
    final tempStore = StoreLocation(
      name: facility,
      position: facilityPosition,
      category: 'مرفق',
      icon: '📍',
      pathFromEntrance: ['اتبع السهم الأخضر']
    );
    
    _startNavigation(tempStore);
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    _arController = controller;
    if (_isNavigating) {
      _setupNavigation();
    }
  }

  void _setupNavigation() {
    if (_arController == null || !_isNavigating || _currentFloor == null) return;
    
    _clearNavigation();
    
    // Find the store or facility
    StoreLocation? destination;
    if (_mallData[_currentFloor]!.stores.containsKey(_selectedStore)) {
      destination = _mallData[_currentFloor]!.stores[_selectedStore];
    } else {
      // Check if it's a facility
      final facilityPosition = _mallData[_currentFloor]!.facilities[_selectedStore];
      if (facilityPosition != null) {
        destination = StoreLocation(
          name: _selectedStore!,
          position: facilityPosition,
          category: 'مرفق',
          icon: '📍',
          pathFromEntrance: ['اتبع السهم الأخضر']
        );
      }
    }
    
    if (destination != null) {
      _addNavigationArrow(destination.position);
      _addDestinationMarker(destination);
      _addPathIndicators(destination);
    }
  }

  void _addNavigationArrow(vector.Vector3 destinationPos) {
    try {
      // Create green arrow pointing to destination
      final arrowMaterial = ArCoreMaterial(color: Colors.green, metallic: 0.0);
      final arrow = ArCoreCylinder(
        materials: [arrowMaterial],
        radius: 0.03,
        height: 0.4,
      );
      
      // Calculate direction to destination
      final direction = destinationPos.normalized();
      final arrowPosition = direction * 1.0; // 1 meter in front
      
      final arrowNode = ArCoreNode(
        shape: arrow,
        position: vector.Vector3(arrowPosition.x, 0.2, arrowPosition.z),
        rotation: vector.Vector4(0, 0, 0, math.atan2(direction.x, -direction.z)),
      );
      
      _arController?.addArCoreNodeWithAnchor(arrowNode);
      _navigationNodes.add(arrowNode);
    } catch (e) {
      debugPrint('Error adding navigation arrow: $e');
    }
  }

  void _addDestinationMarker(StoreLocation destination) {
    try {
      // Add destination marker
      final markerMaterial = ArCoreMaterial(color: Colors.blue, metallic: 0.0);
      final marker = ArCoreSphere(materials: [markerMaterial], radius: 0.1);
      
      final markerNode = ArCoreNode(
        shape: marker,
        position: vector.Vector3(destination.position.x, 0.3, destination.position.z),
      );
      
      _arController?.addArCoreNodeWithAnchor(markerNode);
      _navigationNodes.add(markerNode);
    } catch (e) {
      debugPrint('Error adding destination marker: $e');
    }
  }

  void _addPathIndicators(StoreLocation destination) {
    try {
      // Add path dots leading to destination
      final pathMaterial = ArCoreMaterial(color: Colors.orange, metallic: 0.0);
      
      for (int i = 1; i < 5; i++) {
        final progress = i / 5.0;
        final pathPosition = vector.Vector3.zero().scaled(1 - progress) + 
                            destination.position.scaled(progress);
        
        final pathDot = ArCoreSphere(materials: [pathMaterial], radius: 0.05);
        final pathNode = ArCoreNode(
          shape: pathDot,
          position: vector.Vector3(pathPosition.x, 0.1, pathPosition.z),
        );
        
        _arController?.addArCoreNodeWithAnchor(pathNode);
        _navigationNodes.add(pathNode);
      }
    } catch (e) {
      debugPrint('Error adding path indicators: $e');
    }
  }

  void _clearNavigation() {
    for (final node in _navigationNodes) {
      try {
        _arController?.removeNode(nodeName: node.name ?? '');
      } catch (e) {
        debugPrint('Error removing node: $e');
      }
    }
    _navigationNodes.clear();
  }

  Widget _buildNavigationInfo() {
    if (!_isNavigating || _selectedStore == null) return const SizedBox.shrink();
    
    return Positioned(
      top: 100,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.navigation, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'متجه إلى: $_selectedStore',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      if (_currentFloor != null)
                        Text(
                          _mallData[_currentFloor]!.floorName,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'اتبع السهم الأخضر والنقاط البرتقالية',
              style: TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showStoreSelection(),
                    icon: const Icon(Icons.store, size: 16),
                    label: const Text('غير الوجهة', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF87CEEB),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _stopNavigation,
                    icon: const Icon(Icons.stop, size: 16),
                    label: const Text('إنهاء', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _stopNavigation() {
    setState(() {
      _isNavigating = false;
      _selectedStore = null;
    });
    _clearNavigation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          _currentFloor != null 
            ? 'سيتي ستارز - الدور $_currentFloor'
            : _isNavigating ? 'التنقل في المول' : 'مول سيتي ستارز',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black87,
        elevation: 0,
        actions: [
          if (_currentFloor != null && !_isNavigating)
            IconButton(
              onPressed: () => _showStoreSelection(),
              icon: const Icon(Icons.store, color: Colors.white),
            ),
        ],
      ),
      body: _isInitialized ? _buildMainView() : _buildLoadingScreen(),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFF87CEEB)),
          SizedBox(height: 20),
          Text('جاري التحميل...', style: TextStyle(color: Colors.white, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildMainView() {
    return Stack(
      children: [
        Positioned.fill(
          child: _isQRMode ? _buildQRScanner() : _buildARView(),
        ),
        
        if (_isNavigating) _buildNavigationInfo(),
        
        if (_isQRMode) _buildScanningFrame(),
        
        _buildModeIndicator(),
        _buildBottomControls(),
      ],
    );
  }

  Widget _buildQRScanner() {
    return MobileScanner(
      controller: _qrScannerController,
      onDetect: (BarcodeCapture capture) {
        final List<Barcode> barcodes = capture.barcodes;
        for (final barcode in barcodes) {
          if (barcode.rawValue != null) {
            _processQRCode(barcode.rawValue!);
            break;
          }
        }
      },
    );
  }

  Widget _buildARView() {
    return ArCoreView(
      onArCoreViewCreated: _onArCoreViewCreated,
      enableTapRecognizer: true,
    );
  }

  Widget _buildScanningFrame() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF87CEEB), width: 3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'امسح QR الموجود عند\nمدخل كل دور في المول',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black54, blurRadius: 5)],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildModeIndicator() {
    return Positioned(
      top: 20,
      left: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isNavigating ? Icons.navigation : 
              (_isQRMode ? Icons.qr_code_scanner : Icons.view_in_ar),
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              _isNavigating ? 'التنقل' : 
              (_isQRMode ? 'QR Scanner' : 'AR Navigation'),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (_isQRMode) ...[
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.black54,
              child: IconButton(
                onPressed: () => _qrScannerController?.toggleTorch(),
                icon: const Icon(Icons.flash_on, color: Colors.white),
              ),
            ),
            CircleAvatar(
              radius: 30,
              backgroundColor: const Color(0xFF87CEEB),
              child: IconButton(
                onPressed: () => _processQRCode('CITYSTARS_MAIN_ENTRANCE'),
                icon: const Icon(Icons.store, color: Colors.white, size: 30),
              ),
            ),
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.black54,
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.info, color: Colors.white),
              ),
            ),
          ] else ...[
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.black54,
              child: IconButton(
                onPressed: () => _showStoreSelection(),
                icon: const Icon(Icons.list, color: Colors.white),
              ),
            ),
            CircleAvatar(
              radius: 30,
              backgroundColor: _isNavigating ? Colors.red : const Color(0xFF87CEEB),
              child: IconButton(
                onPressed: _isNavigating ? _stopNavigation : () => _showStoreSelection(),
                icon: Icon(
                  _isNavigating ? Icons.stop : Icons.navigation,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            CircleAvatar(
              radius: 25,
              backgroundColor: Colors.black54,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _isQRMode = true;
                    _isNavigating = false;
                    _isInitialized = false;
                  });
                  _arController?.dispose();
                  _initializeQRScanner();
                },
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _qrScannerController?.dispose();
    _arController?.dispose();
    super.dispose();
  }
}

class FloorData {
  final int floorNumber;
  final String floorName;
  final Map<String, StoreLocation> stores;
  final Map<String, vector.Vector3> facilities;

  FloorData({
    required this.floorNumber,
    required this.floorName,
    required this.stores,
    required this.facilities,
  });
}

class StoreLocation {
  final String name;
  final vector.Vector3 position;
  final String category;
  final String icon;
  final List<String> pathFromEntrance;

  StoreLocation({
    required this.name,
    required this.position,
    required this.category,
    required this.icon,
    required this.pathFromEntrance,
  });
}