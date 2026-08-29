import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../providers/app_state.dart';
import '../widgets/neumorphic_button.dart';
import '../utils/page_transitions.dart';
import 'login_screen.dart';
class SignupScreen extends StatefulWidget {
  final UserRole initialRole;
  
  const SignupScreen({super.key, required this.initialRole});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _authService = AuthService();
  
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  
  late UserRole _selectedRole;

  Color get _themeColor {
    if (_selectedRole == UserRole.customer) return const Color(0xFFFF5A00); // Orange
    if (_selectedRole == UserRole.shopKeeper) return const Color(0xFFC0C0C0); // Silver
    return const Color(0xFFFFD700); // Gold
  }

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await _authService.signUp(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      location: _locationController.text,
      role: _selectedRole,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess && result.userModel != null) {
      // User explicitly requested to go to sign-in page next
      await _authService.signOut();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Please sign in.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pushReplacement(
        RollingPageRoute(page: LoginScreen(
          role: _selectedRole,
          initialEmail: _emailController.text,
          initialPassword: _passwordController.text,
        )),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Signup failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildRoleSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          _buildRoleOption('Customer', UserRole.customer),
          _buildRoleOption('Technician', UserRole.provider), 
          _buildRoleOption('Shopkeeper', UserRole.shopKeeper),
        ],
      ),
    );
  }

  Widget _buildRoleOption(String label, UserRole role) {
    final isSelected = _selectedRole == role;
    final Color optionColor = role == UserRole.customer 
        ? const Color(0xFFFF5A00) 
        : role == UserRole.shopKeeper 
            ? const Color(0xFFC0C0C0) 
            : const Color(0xFFFFD700);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = role;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? optionColor.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? optionColor : Colors.white12,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: optionColor.withValues(alpha: 0.6),
                blurRadius: 15,
                spreadRadius: 1,
              )
            ] : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? optionColor : Colors.white60,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onToggleVisibility,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword && isObscured,
        keyboardType: keyboardType,
        style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 14),
          prefixIcon: Icon(icon, color: _themeColor, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.white54,
                  ),
                  onPressed: onToggleVisibility,
                )
              : null,
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
            borderSide: BorderSide(color: _themeColor, width: 1.2),
          ),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Required field';
          if (isPassword && hint == 'Confirm Password' && v != _passwordController.text) {
            return 'Passwords do not match';
          }
          return null;
        },
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
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create an Account',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join Fixora and explore our services',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Role Selector
                  _buildRoleSelector(),
                  const SizedBox(height: 32),

                  // Fields
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _firstNameController,
                          hint: 'First Name',
                          icon: Icons.person_outline,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _lastNameController,
                          hint: 'Last Name',
                          icon: Icons.person_outline,
                        ),
                      ),
                    ],
                  ),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'Email Address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildTextField(
                    controller: _phoneController,
                    hint: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  _buildTextField(
                    controller: _locationController,
                    hint: 'Location / Address',
                    icon: Icons.location_on_outlined,
                  ),
                  _buildTextField(
                    controller: _passwordController,
                    hint: 'Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isObscured: _obscurePassword,
                    onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  _buildTextField(
                    controller: _confirmController,
                    hint: 'Confirm Password',
                    icon: Icons.lock_outline,
                    isPassword: true,
                    isObscured: _obscureConfirm,
                    onToggleVisibility: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  NeumorphicButton(
                    baseColor: _themeColor,
                    onPressed: _isLoading ? () {} : _handleSignup,
                    child: _isLoading
                        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: _themeColor == const Color(0xFFC0C0C0) ? Colors.black : Colors.white))
                        : Text(
                            'Sign Up',
                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: _themeColor == const Color(0xFFC0C0C0) ? Colors.black : Colors.white, letterSpacing: 1.5),
                          ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w300,
                          color: const Color(0xFF888888),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            RollingPageRoute(page: LoginScreen(role: _selectedRole)),
                          );
                        },
                        child: Text(
                          'Sign In',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _themeColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
