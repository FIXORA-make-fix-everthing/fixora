import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/neumorphic_button.dart';
import '../utils/page_transitions.dart';
import 'customer/customer_home.dart';
import 'provider/provider_home.dart';
import 'shopkeeper/shopkeeper_home.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  final UserRole role;

  const OtpVerificationScreen({super.key, required this.email, required this.role});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  bool _isLoading = false;

  Color get _themeColor {
    if (widget.role == UserRole.customer) return const Color(0xFFFF5A00); // Orange
    if (widget.role == UserRole.shopKeeper) return const Color(0xFFC0C0C0); // Silver
    return const Color(0xFFFFD700); // Gold
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _verifyOtp() {
    String otp = _controllers.map((c) => c.text).join();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 4 digits.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isLoading = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email Verified Successfully!'), backgroundColor: Colors.green),
      );

      final appState = Provider.of<AppState>(context, listen: false);
      appState.login(
        widget.email,
        "password123", // Mock password
        widget.role,
      );

      // Navigate to Home screen
      Widget destination;
      if (widget.role == UserRole.customer) {
        destination = const CustomerHome();
      } else if (widget.role == UserRole.shopKeeper) {
        destination = const ShopkeeperHome();
      } else {
        destination = const ProviderHome();
      }

      Navigator.of(context).pushAndRemoveUntil(
        RollingPageRoute(page: destination),
        (route) => false,
      );
    });
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 3) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        FocusScope.of(context).unfocus();
        // Optional: auto verify could be called here
      }
    } else {
      if (index > 0) {
        FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      }
    }
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 60,
      height: 65,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _themeColor.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: _themeColor.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        onChanged: (value) => _onChanged(value, index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.mark_email_read_outlined, size: 80, color: _themeColor),
              const SizedBox(height: 24),
              Text(
                'Verify Your Email',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We have sent a 4-digit code to\n${widget.email}',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) => _buildOtpBox(index)),
              ),
              
              const SizedBox(height: 40),
              
              NeumorphicButton(
                baseColor: _themeColor,
                onPressed: _isLoading ? () {} : _verifyOtp,
                child: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: _themeColor == const Color(0xFFC0C0C0) ? Colors.black : Colors.white),
                      )
                    : Text(
                        'Verify',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _themeColor == const Color(0xFFC0C0C0) ? Colors.black : Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive code? ",
                    style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13),
                  ),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('OTP Resent!')),
                      );
                    },
                    child: Text(
                      'Resend',
                      style: GoogleFonts.outfit(
                        color: _themeColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
