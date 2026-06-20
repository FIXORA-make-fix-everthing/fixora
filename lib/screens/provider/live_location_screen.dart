import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class LiveLocationScreen extends StatefulWidget {
  const LiveLocationScreen({super.key});

  @override
  State<LiveLocationScreen> createState() => _LiveLocationScreenState();
}

class _LiveLocationScreenState extends State<LiveLocationScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Mocking location if service is disabled for demo
      setState(() {
        _currentPosition = const LatLng(25.7617, -80.1918); // Miami
        _isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Mocking location if denied for demo
        setState(() {
          _currentPosition = const LatLng(25.7617, -80.1918); // Miami
          _isLoading = false;
        });
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Mocking location if permanently denied for demo
      setState(() {
        _currentPosition = const LatLng(25.7617, -80.1918); // Miami
        _isLoading = false;
      });
      return;
    } 

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } catch (e) {
      // Mocking location if getting current position fails
      setState(() {
        _currentPosition = const LatLng(25.7617, -80.1918); // Miami
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        title: Text(
          'Live Tracking',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          if (_currentPosition != null)
            IconButton(
              icon: const Icon(Icons.my_location, color: Color(0xFFC5A059)),
              onPressed: () {
                _mapController.move(_currentPosition!, 15.0);
              },
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFFC5A059)),
                  const SizedBox(height: 16),
                  Text(
                    'Accessing GPS...',
                    style: GoogleFonts.outfit(color: Colors.grey[400]),
                  ),
                ],
              ),
            )
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentPosition!,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.fixora',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentPosition!,
                      width: 80,
                      height: 80,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC5A059).withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC5A059),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
