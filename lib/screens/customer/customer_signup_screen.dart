
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../utils/translations.dart';
import '../../widgets/neumorphic_button.dart';

class CustomerSignupScreen extends StatefulWidget {
  const CustomerSignupScreen({super.key});

  @override
  State<CustomerSignupScreen> createState() => _CustomerSignupScreenState();
}

class _CustomerSignupScreenState extends State<CustomerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // Mock delay – replace with real signup API later
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Account created (mock).'),
        backgroundColor: Color(0xFFC5A059),
      ));
      // Navigate back to login after successful signup
      Navigator.of(context).popUntil((route) => route.isFirst);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen for language changes
    Provider.of<AppState>(context);
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
          // Theme Background Color is inherited
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      Translations.getText(context, 'create_account'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Name
                    TextFormField(
                      controller: _nameController,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: Translations.getText(context, 'name_hint'),
                        hintStyle: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 14),
                        prefixIcon: const Icon(Icons.person_outline, color: Color(0xFFC5A059), size: 20),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Enter your name' : null,
                    ),
                    const SizedBox(height: 16),
                    // Email
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
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Enter email';
                        if (!v.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: Translations.getText(context, 'password_hint'),
                        hintStyle: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 14),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFC5A059), size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colors.white54,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Enter password' : null,
                    ),
                    const SizedBox(height: 16),
                    // Confirm Password
                    TextFormField(
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: Translations.getText(context, 'confirm_password_hint'),
                        hintStyle: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 14),
                        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFC5A059), size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colors.white54,
                          ),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Confirm password';
                        if (v != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    NeumorphicButton(
                      baseColor: const Color(0xFFC5A059),
                      onPressed: _isLoading ? () {} : _handleSignup,
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : Text(
                              Translations.getText(context, 'sign_up'),
                              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
