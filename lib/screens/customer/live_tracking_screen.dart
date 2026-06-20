import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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

class _LiveTrackingScreenState extends State<LiveTrackingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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
  }

  @override
  void dispose() {
    _pulseController.dispose();
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

          // Map Route Line Mock
          Positioned.fill(
            child: CustomPaint(
              painter: _MockRoutePainter(),
            ),
          ),

          // Origin Marker (Home)
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.4,
            left: MediaQuery.of(context).size.width * 0.5 - 20,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF5A00).withValues(alpha: 0.2),
                border: Border.all(color: const Color(0xFFFF5A00), width: 2),
              ),
              child: const Icon(Icons.home_rounded, color: Color(0xFFFF5A00), size: 20),
            ),
          ),

          // Provider Marker (Car moving)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            right: MediaQuery.of(context).size.width * 0.3,
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 44,
                height: 44,
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

// Custom Painter to draw a mocked grid to simulate a map
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

// Custom Painter to draw a mocked route line
class _MockRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF5A00)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Start at Provider
    path.moveTo(size.width * 0.7, size.height * 0.35 + 20);
    // Draw a curvy path to Home
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.45, size.width * 0.5, size.height * 0.6);

    // Draw shadow/glow behind the line
    final glowPaint = Paint()
      ..color = const Color(0xFFFF5A00).withValues(alpha: 0.3)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
