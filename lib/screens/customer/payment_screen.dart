import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/app_state.dart';
import '../mission_passed_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Booking booking;

  const PaymentScreen({super.key, required this.booking});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = 'UPI';
  bool _isPaying = false;
  bool _isPaid = false;

  void _processPayment() {
    setState(() {
      _isPaying = true;
    });
    
    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isPaying = false;
        _isPaid = true;
      });
    });
  }

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
          'CHECKOUT',
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bill Summary
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF151515),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Text(
                    'Total Amount Due',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${widget.booking.price.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF00E5FF),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Service', style: GoogleFonts.outfit(color: Colors.white70)),
                      Text(widget.booking.serviceName, style: GoogleFonts.outfit(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            if (!_isPaid) ...[
              Text(
                'PAYMENT METHOD',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFF5A00),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildPaymentOption('UPI', Icons.qr_code_scanner_rounded),
              const SizedBox(height: 12),
              _buildPaymentOption('Cash in Hand', Icons.payments_rounded),
              
              const SizedBox(height: 40),
              
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isPaying ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isPaying 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : Text(
                          'Pay Now',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                ),
              ),
            ] else ...[
              // Technician Confirmation View
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF39FF14).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF39FF14).withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF39FF14), size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Payment Successful',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Waiting for Technician to close the deal...',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Close Deal Button (Simulating Technician's action for demo)
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to Mission Passed Screen
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const MissionPassedScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5A00),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 10,
                    shadowColor: const Color(0xFFFF5A00).withValues(alpha: 0.5),
                  ),
                  child: Text(
                    'CLOSE DEAL (Technician)',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String title, IconData icon) {
    final isSelected = _selectedPaymentMethod == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF5A00).withValues(alpha: 0.1) : const Color(0xFF151515),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF5A00) : Colors.white10,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFFFF5A00) : Colors.white70),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: Colors.white,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.radio_button_checked_rounded, color: Color(0xFFFF5A00))
            else
              const Icon(Icons.radio_button_unchecked_rounded, color: Colors.white30),
          ],
        ),
      ),
    );
  }
}
