import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../providers/app_state.dart';

class LiveTrackingScreen extends StatefulWidget {
  final Booking booking;

  const LiveTrackingScreen({
    super.key,
    required this.booking,
  });

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

enum MapStyle { dark, satellite }

class _LiveTrackingScreenState extends State<LiveTrackingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  final MapController _mapController = MapController();
  
  // Real coordinates from GPS
  LatLng? _myLocation;
  LatLng? _providerLocation; // No longer hardcoded

  
  StreamSubscription<Position>? _positionStream;
  MapStyle _currentMapStyle = MapStyle.dark;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _startLiveTracking();
  }
  
  Future<void> _startLiveTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    } 

    // Get initial position
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _myLocation = LatLng(position.latitude, position.longitude);
    });

    // Listen for live updates
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // update every 10 meters
      ),
    ).listen((Position pos) {
      if (mounted) {
        setState(() {
          _myLocation = LatLng(pos.latitude, pos.longitude);
        });
      }
    });

    // Listen to provider location from Firebase if assigned
    if (widget.booking.providerId != null) {
      FirebaseDatabase.instance
          .ref('providers/${widget.booking.providerId}/location')
          .onValue
          .listen((event) {
        if (event.snapshot.exists) {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          if (data['lat'] != null && data['lng'] != null) {
            if (mounted) {
              setState(() {
                _providerLocation = LatLng(
                  (data['lat'] as num).toDouble(),
                  (data['lng'] as num).toDouble(),
                );
              });
            }
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        children: [
          // Real Map using flutter_map
          if (_myLocation == null)
            const Center(child: CircularProgressIndicator(color: Color(0xFFFF5A00)))
          else
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _myLocation!,
                initialZoom: 15.0,
              ),
              children: [
                if (_currentMapStyle == MapStyle.dark)
                  ColorFiltered(
                    colorFilter: const ColorFilter.matrix([
                      -1,  0,  0, 0, 255, // Red (invert)
                       0, -1,  0, 0, 255, // Green (invert)
                       0,  0, -1, 0, 255, // Blue (invert)
                       0,  0,  0, 1,   0, // Alpha
                    ]),
                    child: TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.fixora',
                    ),
                  )
                else
                  TileLayer(
                    urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                    userAgentPackageName: 'com.example.fixora',
                  ),
                if (_providerLocation != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [_providerLocation!, _myLocation!],
                        color: const Color(0xFFFF5A00),
                        strokeWidth: 4.0,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    // My Marker
                    Marker(
                      point: _myLocation!,
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFF5A00).withValues(alpha: 0.2),
                          border: Border.all(color: const Color(0xFFFF5A00), width: 2),
                        ),
                        child: const Icon(Icons.my_location, color: Color(0xFFFF5A00), size: 20),
                      ),
                    ),
                    // Provider Marker
                    if (_providerLocation != null)
                      Marker(
                        point: _providerLocation!,
                        width: 44,
                        height: 44,
                        child: ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.directions_car_rounded, color: Colors.black, size: 24),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

          // Re-center & Map Style Buttons
          if (_myLocation != null)
            Positioned(
              bottom: 300, // Above the bottom card
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: const Color(0xFF141414),
                    child: Icon(
                      _currentMapStyle == MapStyle.dark ? Icons.satellite_alt_rounded : Icons.map_rounded,
                      color: const Color(0xFFFF5A00),
                    ),
                    onPressed: () {
                      setState(() {
                        _currentMapStyle = _currentMapStyle == MapStyle.dark
                            ? MapStyle.satellite
                            : MapStyle.dark;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: const Color(0xFF141414),
                    child: const Icon(Icons.my_location, color: Color(0xFFFF5A00)),
                    onPressed: () {
                      _mapController.move(_myLocation!, 15.0);
                    },
                  ),
                ],
              ),
            ),

          // Top App Bar Area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                bottom: 20,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'LIVE TRACKING',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Tracking Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFF141414),
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, -10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ETA & Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Arriving in',
                            style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[500]),
                          ),
                          Text(
                            '12 mins',
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFF5A00),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5A00).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFFF5A00).withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'On The Way',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFF5A00),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white10, height: 1),
                  const SizedBox(height: 20),

                  // Provider Details
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFF5A00).withValues(alpha: 0.1),
                          border: Border.all(color: const Color(0xFFFF5A00), width: 1.5),
                        ),
                        child: const Center(
                          child: Icon(Icons.person, color: Color(0xFFFF5A00), size: 28),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.booking.providerName ?? 'Specialist',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Color(0xFFFF5A00), size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  widget.booking.providerRating?.toString() ?? '5.0',
                                  style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[400]),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Ford Transit (Black)',
                                  style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Call Button
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFF202020),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.phone_in_talk_rounded, color: Colors.greenAccent),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Service info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.build_rounded, color: Color(0xFFFF5A00), size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.booking.serviceName,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white70,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

