import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../utils/translations.dart';
import 'customer/customer_home.dart';
import 'provider/provider_home.dart';
import 'shopkeeper/shopkeeper_home.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';
import '../widgets/neumorphic_button.dart';
import '../utils/page_transitions.dart';
import 'language_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  final UserRole role;

  const LoginScreen({
    super.key,
    required this.role,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill demo credentials for convenience
    if (widget.role == UserRole.customer) {
      _emailController.text = 'customer@fixora.com';
      _passwordController.text = 'password123';
    } else if (widget.role == UserRole.shopKeeper) {
      _emailController.text = 'shopkeeper@fixora.com';
      _passwordController.text = 'password123';
    } else {
      _emailController.text = 'provider@fixora.com';
      _passwordController.text = 'password123';
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      
      final appState = Provider.of<AppState>(context, listen: false);
      final success = appState.login(
        _emailController.text.trim(),
        _passwordController.text,
        widget.role,
      );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        // Clear backstack and go to main home
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials. Please try again.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to AppState to trigger automatic rebuilds on language change
    Provider.of<AppState>(context);
    final isCustomer = widget.role == UserRole.customer;
    final isShopKeeper = widget.role == UserRole.shopKeeper;
    final roleName = isCustomer
        ? Translations.getText(context, 'customer_tag')
        : isShopKeeper
            ? Translations.getText(context, 'shop_keeper_tag')
            : Translations.getText(context, 'provider_tag');

    final Color themeColor = isCustomer 
        ? const Color(0xFFFF5A00) // Orange (Normal)
        : isShopKeeper
            ? const Color(0xFFC0C0C0) // Silver
            : const Color(0xFFFFD700); // Gold

    final roleColor = themeColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.language_rounded, color: themeColor),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LanguageSelectionScreen(isFromOnboarding: false),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Theme Background Color is inherited
          // Textured Background Image (low opacity for subtle wall texture)
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset(
                'assets/images/image.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    // Top-Centered High-Contrast Logo Image (No lanterns!)
                    Center(
                      child: Container(
                        height: 220,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Image.asset(
                          'assets/images/image.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    // Glassmorphic Card Container wrapping the login form
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: themeColor.withValues(alpha: 0.3),
                              width: 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: themeColor.withValues(alpha: 0.15),
                                blurRadius: 40,
                                spreadRadius: 5,
                              )
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Title Header
                                Text(
                                  roleName,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 4,
                                    color: roleColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  Translations.getText(context, 'welcome_back'),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  Translations.getText(context, 'enter_credentials'),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                    color: const Color(0xFFB0B0B0),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                // Email Input Field
                                Text(
                                  Translations.getText(context, 'email_address'),
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5,
                                    color: const Color(0xFFB0B0B0),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
                                  decoration: InputDecoration(
                                    hintText: Translations.getText(context, 'email_hint'),
                                    hintStyle: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 14),
                                    prefixIcon: Icon(Icons.email_outlined, color: themeColor, size: 20),
                                    filled: true,
                                    fillColor: Colors.white.withValues(alpha: 0.04),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: themeColor, width: 1.2),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return Translations.getText(context, 'validation_email');
                                    }
                                    if (!value.contains('@')) {
                                      return Translations.getText(context, 'validation_email_invalid');
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                                // Password Input Field
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      Translations.getText(context, 'password'),
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.5,
                                        color: const Color(0xFFB0B0B0),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.of(context).push(RollingPageRoute(page: const ForgotPasswordScreen())),
                                      child: Text(
                                        Translations.getText(context, 'forgot_password'),
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w400,
                                          color: themeColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
                                  decoration: InputDecoration(
                                    hintText: Translations.getText(context, 'password_hint'),
                                    hintStyle: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 14),
                                    prefixIcon: Icon(Icons.lock_outline_rounded, color: themeColor, size: 20),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        color: Colors.white54,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withValues(alpha: 0.04),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(color: themeColor, width: 1.2),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return Translations.getText(context, 'validation_password');
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 32),
                                // Login Button with 3D Neumorphic effect
                                NeumorphicButton(
                                  baseColor: themeColor,
                                  onPressed: _isLoading ? () {} : _handleLogin,
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                          ),
                                        )
                                      : Text(
                                          Translations.getText(context, 'sign_in'),
                                          style: GoogleFonts.outfit(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 24),
                                // Demo accounts indicator alert inside the card
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: themeColor.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: themeColor.withValues(alpha: 0.15),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.info_outline_rounded, color: themeColor, size: 16),
                                          const SizedBox(width: 8),
                                          Text(
                                            Translations.getText(context, 'demo_mode'),
                                            style: GoogleFonts.outfit(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: themeColor,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        isCustomer
                                            ? Translations.getText(context, 'demo_customer_desc')
                                            : isShopKeeper
                                                ? Translations.getText(context, 'demo_shop_desc')
                                                : Translations.getText(context, 'demo_provider_desc'),
                                        style: GoogleFonts.outfit(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w300,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                // Sign up section
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      isCustomer
                                          ? Translations.getText(context, 'new_to_fixora')
                                          : Translations.getText(context, 'want_to_partner'),
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w300,
                                        color: const Color(0xFF888888),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.of(context).push(RollingPageRoute(page: SignupScreen(initialRole: widget.role))),
                                      child: Text(
                                        isCustomer
                                            ? Translations.getText(context, 'create_account')
                                            : Translations.getText(context, 'register_now'),
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: themeColor,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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
