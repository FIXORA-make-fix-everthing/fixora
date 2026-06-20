import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/translations.dart';
import '../widgets/neumorphic_button.dart';


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isSending = false;
  bool _codeSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendReset() {
    if (_emailController.text.isEmpty) return;
    setState(() => _isSending = true);
    // Mock delay – replace with real API call later
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _codeSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Verification code sent (mock).'),
        backgroundColor: Color(0xFFC5A059),
      ));
    });
  }

  void _verifyCode() {
    if (_codeController.text.isEmpty) return;
    // Mock verification
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Email verified (mock).'),
      backgroundColor: Color(0xFFC5A059),
    ));
    // Navigate back to login screen after verification
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<AppState>(context); // listen for language changes
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/language_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          // Theme Background Color is inherited
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    Translations.getText(context, 'forgot_password'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    Translations.getText(context, 'enter_email_to_reset'),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFFB0B0B0),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (!_codeSent) ...[
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: Translations.getText(context, 'email_hint'),
                        hintStyle: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 14),
                        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFFC5A059), size: 20),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    NeumorphicButton(
                      baseColor: const Color(0xFFC5A059),
                      onPressed: _isSending ? () {} : _sendReset,
                      child: _isSending
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : Text(
                              'Send Reset Link',
                              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                            ),
                    ),
                  ] else ...[
                    TextFormField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: Translations.getText(context, 'verification_code'),
                        hintStyle: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 14),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFC5A059), size: 20),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    NeumorphicButton(
                      baseColor: const Color(0xFFC5A059),
                      onPressed: _verifyCode,
                      child: Text(
                        'Verify Code',
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
