import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomRequestSuccessScreen extends StatelessWidget {
  const CustomRequestSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success Icon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFF39FF14).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF39FF14).withValues(alpha: 0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                    border: Border.all(
                      color: const Color(0xFF39FF14),
                      width: 3,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_outline_rounded,
                      color: Color(0xFF39FF14),
                      size: 64,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Title
                Text(
                  'Request Submitted!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Subtitle
                Text(
                  'We have received your custom service request. Our team will contact you shortly to discuss the details and arrange a professional for you.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Back to Home Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      // Pop all screens and go back to CustomerHome
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5A00),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                      shadowColor: const Color(0xFFFF5A00).withValues(alpha: 0.5),
                    ),
                    child: Text(
                      'Back to Home',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
