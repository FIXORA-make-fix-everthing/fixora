import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF141414),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'ABOUT FIXORA',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // App Logo Placeholder
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5A00).withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFF5A00).withValues(alpha: 0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF5A00).withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.handyman_rounded, color: Color(0xFFFF5A00), size: 60),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Fixora',
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white54,
              ),
            ),
            const SizedBox(height: 40),
            
            // Description
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Premium Service Partner',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF00E5FF),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Fixora is your ultimate on-demand platform for all home and vehicle services. '
                    'Whether you need a quick repair, a deep clean, or an emergency fix, we connect you '
                    'with top-rated, verified professionals in your area instantly.\n\n'
                    'Our mission is to bring reliability, speed, and premium quality directly to your doorstep. '
                    'Experience the future of services with seamless tracking, secure payments, and a guarantee '
                    'of excellence on every job.',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Colors.white70,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Social Links / Contact
            _buildLinkItem(Icons.public_rounded, 'Visit our website', 'www.fixora.com'),
            _buildLinkItem(Icons.email_rounded, 'Contact Support', 'support@fixora.com'),
            _buildLinkItem(Icons.description_rounded, 'Terms of Service', 'Read our policies'),
            
            const SizedBox(height: 40),
            Text(
              '© 2026 Fixora Inc. All rights reserved.',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: Colors.white30,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFFF5A00), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 16),
        ],
      ),
    );
  }
}
