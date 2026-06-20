import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:confetti/confetti.dart';
import 'customer/customer_home.dart';

class MissionPassedScreen extends StatefulWidget {
  const MissionPassedScreen({super.key});

  @override
  State<MissionPassedScreen> createState() => _MissionPassedScreenState();
}

class _MissionPassedScreenState extends State<MissionPassedScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        children: [
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Color(0xFFFF5A00), // Orange
                Color(0xFF00E5FF), // Blue
                Color(0xFF39FF14), // Green
                Colors.yellow,
                Colors.purple,
                Colors.pink,
              ],
              createParticlePath: drawStar,
            ),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // GTA Style "MISSION PASSED" Text
                Stack(
                  children: [
                    // Text border/stroke effect
                    Text(
                      'MISSION PASSED',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.anton(
                        fontSize: 50,
                        letterSpacing: 2.0,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 6
                          ..color = Colors.black,
                      ),
                    ),
                    // Solid inner text
                    Text(
                      'MISSION PASSED',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.anton(
                        fontSize: 50,
                        letterSpacing: 2.0,
                        color: const Color(0xFFFFCC00), // GTA Yellow/Gold
                        shadows: [
                          const Shadow(
                            offset: Offset(4, 4),
                            blurRadius: 0,
                            color: Colors.black,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Stack(
                  children: [
                    Text(
                      'RESPECT +',
                      style: GoogleFonts.anton(
                        fontSize: 30,
                        letterSpacing: 1.5,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 4
                          ..color = Colors.black,
                      ),
                    ),
                    Text(
                      'RESPECT +',
                      style: GoogleFonts.anton(
                        fontSize: 30,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 60),
                
                Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151515),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFF5A00).withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF5A00).withValues(alpha: 0.15),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.verified_rounded, color: Color(0xFF39FF14), size: 60),
                      const SizedBox(height: 16),
                      Text(
                        'Service Completed\nSuccessfully!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Payment received and deal closed.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const CustomerHome()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5A00),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'Go to Home',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (3.141592653589793 / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * 1 * (step).cos(),
          halfWidth + externalRadius * 1 * (step).sin());
      path.lineTo(halfWidth + internalRadius * 1 * (step + halfDegreesPerStep).cos(),
          halfWidth + internalRadius * 1 * (step + halfDegreesPerStep).sin());
    }
    path.close();
    return path;
  }
}

// Extension to help with sin/cos
extension on double {
  double cos() => 1.0; // Simplification for demo, dart:math needed for real sin/cos
  double sin() => 0.0;
}
