import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class ExploreLocationScreen extends StatefulWidget {
  final String userName;
  const ExploreLocationScreen({super.key, required this.userName});

  @override
  State<ExploreLocationScreen> createState() => _ExploreLocationScreenState();
}
class _ExploreLocationScreenState extends State<ExploreLocationScreen> {
  GoogleMapController? _mapController;
  final Location _location = Location();
  LocationData? _currentLocation;

  
  bool _isLoadingLocation = false;
  bool _showTrafficLayer = true;
  // Removed _selectedPlace since it wasn't being used
  
  // Cairo Mall location (example coordinates for Cairo)
  static const LatLng _cairoMallLocation = LatLng(30.0626, 31.2497);
  
  // Mall stores and places with their coordinates
  final Map<String, MallPlace> _mallPlaces = {
    'Fashion Hub': MallPlace(
      name: 'Fashion Hub',
      position: LatLng(30.0628, 31.2495),
      category: 'Clothing & Fashion',
      emoji: '🛍️',
      description: 'Latest fashion trends and designer clothes',
    ),
    'Tech Center': MallPlace(
      name: 'Tech Center',
      position: LatLng(30.0624, 31.2499),
      category: 'Electronics',
      emoji: '📱',
      description: 'Smartphones, laptops, and electronic gadgets',
    ),
    'Food Court': MallPlace(
      name: 'Food Court',
      position: LatLng(30.0626, 31.2501),
      category: 'Restaurants',
      emoji: '🍔',
      description: 'Various restaurants and fast food options',
    ),
    'Pharmacy': MallPlace(
      name: 'Pharmacy',
      position: LatLng(30.0622, 31.2495),
      category: 'Health & Beauty',
      emoji: '💊',
      description: 'Medicine, health care, and beauty products',
    ),
    'Kids Zone': MallPlace(
      name: 'Kids Zone',
      position: LatLng(30.0630, 31.2497),
      category: 'Entertainment',
      emoji: '🧸',
      description: 'Play area and toys for children',
    ),
    'Cinema': MallPlace(
      name: 'Cinema',
      position: LatLng(30.0625, 31.2503),
      category: 'Entertainment',
      emoji: '🎬',
      description: 'Latest movies and entertainment',
    ),
  };

  Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _createMarkers();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          _showLocationError('Location service is disabled');
          return;
        }
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          _showLocationError('Location permission denied');
          return;
        }
      }

      // Configure location settings for better accuracy
      await _location.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 1000,
        distanceFilter: 10,
      );

      // Get high accuracy location with timeout
      final locationData = await _location.getLocation().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Location request timed out');
        },
      );

      // Validate location data
      if (locationData.latitude == null || locationData.longitude == null) {
        _showLocationError('Invalid location data received');
        return;
      }

      // Check if location is reasonable (not 0,0 which is common error)
      if (locationData.latitude!.abs() < 0.001 && locationData.longitude!.abs() < 0.001) {
        _showLocationError('Location appears to be invalid (0,0). Please enable precise location.');
        return;
      }

      setState(() {
        _currentLocation = locationData;
        _isLoadingLocation = false;
      });

      if (kDebugMode) {
        print('Location obtained: ${locationData.latitude}, ${locationData.longitude}');
      }
      if (kDebugMode) {
        print('Accuracy: ${locationData.accuracy} meters');
      }

      // Update markers to include current location
      _createMarkers();

      if (_mapController != null && _currentLocation != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
            16,
          ),
        );
      }
    } catch (e) {
      _showLocationError('Failed to get location: $e');
    }
  }

  void _createMarkers() {
    _markers = _mallPlaces.entries.map((entry) {
      return Marker(
        markerId: MarkerId(entry.key),
        position: entry.value.position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: entry.value.name,
          snippet: entry.value.category,
        ),
        onTap: () => _onMarkerTapped(entry.value),
      );
    }).toSet();

    // Add current location marker if available
    if (_currentLocation != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: 'Your Location',
            snippet: 'Accuracy: ${_currentLocation!.accuracy?.toStringAsFixed(1) ?? "Unknown"} meters',
          ),
        ),
      );
    }
    
    setState(() {}); // Trigger rebuild to show updated markers
  }

  void _onMarkerTapped(MallPlace place) {
    // Removed the _selectedPlace assignment since it wasn't being used
    _showPlaceDetails(place);
  }

  void _showPlaceDetails(MallPlace place) {
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
                
                // Place info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF87CEEB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        place.emoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D9A),
                            ),
                          ),
                          Text(
                            place.category,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 15),
                
                Text(
                  place.description,
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
                        onPressed: () => _getDirections(place.position),
                        icon: const Icon(Icons.directions, color: Colors.white),
                        label: const Text('Get Directions', style: TextStyle(color: Colors.white)),
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
                        onPressed: () => _shareLocation(place),
                        icon: const Icon(Icons.share, color: Color(0xFF87CEEB)),
                        label: const Text('Share', style: TextStyle(color: Color(0xFF87CEEB))),
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

  Future<void> _getDirections(LatLng destination) async {
    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Getting your location...'),
          backgroundColor: Colors.orange,
        ),
      );
      await _getCurrentLocation();
      return;
    }

    Navigator.pop(context); // Close bottom sheet
    
    // Create route polyline (simplified - in real app you'd use Google Directions API)
    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      points: [
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        destination,
      ],
      color: const Color(0xFF87CEEB),
      width: 5,
      patterns: [PatternItem.dash(20), PatternItem.gap(10)],
    );

    setState(() {
      _polylines.clear();
      _polylines.add(polyline);
    });

    // Show route info
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Route calculated! 🗺️'),
        backgroundColor: const Color(0xFF87CEEB),
        action: SnackBarAction(
          label: 'Clear',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _polylines.clear();
            });
          },
        ),
      ),
    );

    // Adjust camera to show both points
    _fitMarkersInView([
      LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
      destination,
    ]);
  }

  void _fitMarkersInView(List<LatLng> points) {
    if (points.isEmpty || _mapController == null) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (LatLng point in points) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0, // padding
      ),
    );
  }

  void _shareLocation(MallPlace place) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Shared location of ${place.name}! 📍'),
        backgroundColor: const Color(0xFF87CEEB),
      ),
    );
  }

  void _showLocationError(String message) {
    setState(() {
      _isLoadingLocation = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text(
          'Cairo Mall Navigator',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF87CEEB),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _showTrafficLayer = !_showTrafficLayer;
              });
            },
            icon: Icon(
              _showTrafficLayer ? Icons.traffic : Icons.traffic_outlined,
              color: Colors.white,
            ),
            tooltip: 'Toggle Traffic',
          ),
          IconButton(
            onPressed: _getCurrentLocation,
            icon: _isLoadingLocation 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.my_location, color: Colors.white),
            tooltip: 'My Location',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              if (_currentLocation != null) {
                _createMarkers();
              }
            },
            initialCameraPosition: const CameraPosition(
              target: _cairoMallLocation,
              zoom: 16,
            ),
            markers: _markers,
            polylines: _polylines,
            trafficEnabled: _showTrafficLayer,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onTap: (LatLng position) {
              // Removed setState since _selectedPlace is no longer used
            },
          ),
          
          
          // Traffic status indicator
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.traffic,
                    size: 16,
                    color: _showTrafficLayer ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _showTrafficLayer ? 'Traffic: Light' : 'Traffic: OFF',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _showTrafficLayer ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Location accuracy indicator
          if (_currentLocation != null)
            Positioned(
              top: 60,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: _getAccuracyColor(_currentLocation!.accuracy ?? 0),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '±${_currentLocation!.accuracy?.toStringAsFixed(0) ?? "?"} m',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getAccuracyColor(_currentLocation!.accuracy ?? 0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Places list button
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: _showPlacesList,
              backgroundColor: const Color(0xFF87CEEB),
              tooltip: 'Show Places',
              child: const Icon(Icons.list, color: Colors.white),
            ),
          ),
          
          // Clear routes button (when routes are shown)
          if (_polylines.isNotEmpty)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    _polylines.clear();
                  });
                },
                backgroundColor: Colors.red,
                mini: true,
                tooltip: 'Clear Routes',
                child: const Icon(Icons.clear, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  void _showPlacesList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 10),
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // Header
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(Icons.store, color: Color(0xFF87CEEB)),
                        SizedBox(width: 10),
                        Text(
                          'Mall Places',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D9A),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Places list
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _mallPlaces.length,
                      itemBuilder: (context, index) {
                        final place = _mallPlaces.values.elementAt(index);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF87CEEB),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(place.emoji, style: const TextStyle(fontSize: 20)),
                            ),
                            title: Text(
                              place.name,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(place.category),
                            trailing: const Icon(Icons.directions, color: Color(0xFF87CEEB)),
                            onTap: () {
                              Navigator.pop(context);
                              _onMarkerTapped(place);
                              _mapController?.animateCamera(
                                CameraUpdate.newLatLngZoom(place.position, 18),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy <= 10) return Colors.green;
    if (accuracy <= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

class MallPlace {
  final String name;
  final LatLng position;
  final String category;
  final String emoji;
  final String description;

  MallPlace({
    required this.name,
    required this.position,
    required this.category,
    required this.emoji,
    required this.description,
  });
}