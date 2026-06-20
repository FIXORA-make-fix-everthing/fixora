import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import 'booking_details_screen.dart';

class SearchingTechnicianScreen extends StatefulWidget {
  final String bookingId;

  const SearchingTechnicianScreen({super.key, required this.bookingId});

  @override
  State<SearchingTechnicianScreen> createState() => _SearchingTechnicianScreenState();
}

class _SearchingTechnicianScreenState extends State<SearchingTechnicianScreen> with SingleTickerProviderStateMixin {
  late AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _simulateTechnicianFound();
  }

  Future<void> _simulateTechnicianFound() async {
    // Wait for 3 seconds simulating the search
    await Future.delayed(const Duration(seconds: 4));
    
    if (!mounted) return;
    
    final appState = Provider.of<AppState>(context, listen: false);
    
    // Simulate technician accepting the request
    appState.acceptBooking(widget.bookingId);
    
    // Get the updated booking
    final updatedBooking = appState.bookings.firstWhere((b) => b.id == widget.bookingId);

    // Navigate to the detailed timeline / profile screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => BookingDetailsScreen(booking: updatedBooking),
      ),
    );
  }

  @override
  void dispose() {
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
          
          // Radar Animation
          Center(
            child: RotationTransition(
              turns: _radarController,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    center: FractionalOffset.center,
                    colors: [
                      const Color(0xFFFF5A00).withValues(alpha: 0.0),
                      const Color(0xFFFF5A00).withValues(alpha: 0.1),
                      const Color(0xFFFF5A00).withValues(alpha: 0.6),
                      const Color(0xFFFF5A00).withValues(alpha: 0.0),
                    ],
                    stops: const [0.0, 0.5, 0.9, 1.0],
                  ),
                ),
              ),
            ),
          ),
          
          // Center Icon
          Center(
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF5A00),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF5A00).withValues(alpha: 0.5),
                    blurRadius: 25,
                    spreadRadius: 8,
                  ),
                ],
                border: Border.all(color: Colors.white24, width: 2),
              ),
              child: const Icon(
                Icons.radar_rounded,
                color: Colors.black,
                size: 36,
              ),
            ),
          ),

          // Top Header Area
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 20,
            right: 20,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context), // Go back to home if user cancels early
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFF5A00).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    'REQUEST SENT',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFFF5A00),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Info Card
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: Color(0xFFFF5A00),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Contacting Specialists...',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We are matching your service request with the best premium technicians nearby. Please hold on.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Colors.grey[400],
                      height: 1.5,
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
