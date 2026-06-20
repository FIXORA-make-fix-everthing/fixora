import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import 'live_tracking_screen.dart';

class OnSpotBookingScreen extends StatefulWidget {
  final String serviceName;

  const OnSpotBookingScreen({super.key, required this.serviceName});

  @override
  State<OnSpotBookingScreen> createState() => _OnSpotBookingScreenState();
}

class _OnSpotBookingScreenState extends State<OnSpotBookingScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _radarController;
  
  bool _isSearching = false;
  String _statusText = "Acquiring Live Location...";
  String _subStatusText = "Please wait while we pinpoint your exact location for the technician.";

  @override
  void initState() {
    super.initState();
    
    // Setup Pulse Animation for location sharing
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Setup Radar Animation for searching technicians
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    // 1. Simulate finding location
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    setState(() {
      _isSearching = true;
      _statusText = "Finding Nearby Technicians...";
      _subStatusText = "Broadcasting your request to available specialists in your area.";
      _pulseController.stop();
      _radarController.repeat();
    });

    // 2. Simulate finding a technician
    await Future.delayed(const Duration(seconds: 4));
    
    if (!mounted) return;
    
    // Create the booking in AppState
    final appState = Provider.of<AppState>(context, listen: false);
    
    // For on-the-spot, we use current date and immediate time
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    appState.createBooking(
      categoryName: 'On-the-Spot',
      serviceName: widget.serviceName,
      price: 65.0, // Base price for emergency callout
      date: dateStr,
      timeSlot: 'Immediate Dispatch',
      address: 'Current Live Location',
    );
    
    // Assume it's the newest booking (index 0)
    final newBooking = appState.bookings.first;
    appState.acceptBooking(newBooking.id);

    // Navigate to Live Tracking
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LiveTrackingScreen(booking: newBooking),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        children: [
          // Mock Map Background
          Positioned.fill(
            child: CustomPaint(
              painter: _MockMapPainter(),
            ),
          ),
          
          // Radar or Pulse Animation
          Center(
            child: _isSearching
                ? RotationTransition(
                    turns: _radarController,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          center: FractionalOffset.center,
                          colors: [
                            const Color(0xFF00E5FF).withValues(alpha: 0.0),
                            const Color(0xFF00E5FF).withValues(alpha: 0.1),
                            const Color(0xFF00E5FF).withValues(alpha: 0.5),
                            const Color(0xFF00E5FF).withValues(alpha: 0.0),
                          ],
                          stops: const [0.0, 0.5, 0.9, 1.0],
                        ),
                      ),
                    ),
                  )
                : ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFFF5A00).withValues(alpha: 0.1),
                        border: Border.all(color: const Color(0xFFFF5A00).withValues(alpha: 0.3), width: 2),
                      ),
                    ),
                  ),
          ),
          
          // Center Icon
          Center(
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isSearching ? const Color(0xFF00E5FF) : const Color(0xFFFF5A00),
                boxShadow: [
                  BoxShadow(
                    color: _isSearching 
                        ? const Color(0xFF00E5FF).withValues(alpha: 0.5) 
                        : const Color(0xFFFF5A00).withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                _isSearching ? Icons.radar_rounded : Icons.my_location_rounded,
                color: Colors.black,
                size: 30,
              ),
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
                    'EMERGENCY REQUEST',
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

          // Bottom Status Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(32),
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
                  const SizedBox(height: 32),
                  
                  // Service Requested Info
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1C),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.build_circle_rounded, 
                          color: _isSearching ? const Color(0xFF00E5FF) : const Color(0xFFFF5A00),
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Requested Service',
                                style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[500]),
                              ),
                              Text(
                                widget.serviceName,
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Animated Status Text
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Column(
                      key: ValueKey<bool>(_isSearching),
                      children: [
                        Text(
                          _statusText,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: _isSearching ? const Color(0xFF00E5FF) : const Color(0xFFFF5A00),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _subStatusText,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: Colors.grey[400],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Reusing the Mock Map Background from live_tracking_screen
class _MockMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 40) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 40) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
