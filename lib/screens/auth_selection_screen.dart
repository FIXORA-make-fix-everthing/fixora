import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../providers/app_state.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import '../utils/page_transitions.dart';

class AuthSelectionScreen extends StatefulWidget {
  const AuthSelectionScreen({super.key});

  @override
  State<AuthSelectionScreen> createState() => _AuthSelectionScreenState();
}

class _AuthSelectionScreenState extends State<AuthSelectionScreen> with SingleTickerProviderStateMixin {
  UserRole _selectedRole = UserRole.customer;
  UserRole? _pressedRole; // Track pressed state for electric blue effect
  bool _isLoginPressed = false; // Track pressed state for electric green effect on login
  
  late AnimationController _animationController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    
    // Initialize Video Player
    _videoController = VideoPlayerController.asset('assets/images/selectid.mp4')
      ..initialize().then((_) {
        _videoController.setLooping(false); // Video plays only once
        _videoController.play();
        setState(() {}); // Ensure first frame is shown
      });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500), // Longer duration for the sequence
    );

    _playStartSequence();
  }

  Future<void> _playStartSequence() async {
    try {
      await _audioPlayer.play(AssetSource('audio/car_start.mp3'));
    } catch (e) {
      debugPrint("Audio file not found or failed to play: $e");
    }

    // Allow video to play first before starting animations (Wait for 3.5 seconds)
    await Future.delayed(const Duration(milliseconds: 5500));
    
    if (mounted) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioPlayer.dispose();
    _videoController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedItem({required Widget child, required int index, required int totalItems, Offset beginOffset = const Offset(0, 0.5)}) {
    // Logo (index 0) goes first, others follow later
    final double start = index == 0 ? 0.0 : 0.3 + ((index - 1) / (totalItems - 1) * 0.5);
    final double end = start + 0.3;
    
    final animation = CurvedAnimation(
      parent: _animationController,
      curve: Interval(start, end > 1.0 ? 1.0 : end, curve: Curves.easeOutQuart),
    );
    
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Full page background video
          Positioned.fill(
            child: _videoController.value.isInitialized
                ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController.value.size.width,
                        height: _videoController.value.size.height,
                        child: VideoPlayer(_videoController),
                      ),
                    ),
                  )
                : Image.asset(
 'assets/images/image.png',
                    fit: BoxFit.cover,
                  ),
          ),

          // Gradient overlay fades in before text to make it readable
          Positioned.fill(
            child: FadeTransition(
              opacity: CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                      Colors.black.withValues(alpha: 0.95),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // Animated sliding/fading content
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    
                    // Logo animating in (starts from center and moves up)
                    _buildAnimatedItem(
                      index: 0, 
                      totalItems: 8,
                      beginOffset: const Offset(0, 1.5), // Start lower down (center)
                      child: Image.asset(
                        'assets/images/fixora.png',
                        height: 200, // Large logo at the top
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Welcome Text
                    _buildAnimatedItem(
                      index: 1, totalItems: 8,
                      child: Column(
                        children: [
                          Text(
                            'Welcome to Fixora',
                            style: GoogleFonts.outfit(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFF5A00),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your trusted partner for Home & Auto services',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),

                    // Customer Card
                    _buildAnimatedItem(
                      index: 2, totalItems: 8,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildSelectionCard(
                          title: 'Customer',
                          subtitle: 'Book services quickly & easily',
                          icon: Icons.person_outline,
                          role: UserRole.customer,
                        ),
                      ),
                    ),
                    
                    // Technician Card
                    _buildAnimatedItem(
                      index: 3, totalItems: 8,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildSelectionCard(
                          title: 'Technician',
                          subtitle: 'Get jobs & grow your business',
                          icon: Icons.handyman_outlined,
                          role: UserRole.provider,
                        ),
                      ),
                    ),
                    
                    // Shopkeeper Card
                    _buildAnimatedItem(
                      index: 4, totalItems: 8,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: _buildSelectionCard(
                          title: 'Shopkeeper',
                          subtitle: 'Manage your shop & services',
                          icon: Icons.storefront_outlined,
                          role: UserRole.shopKeeper,
                        ),
                      ),
                    ),
                    
                    // Divider "New here?"
                    _buildAnimatedItem(
                      index: 5, totalItems: 8,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Row(
                          children: [
                            const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'New here?',
                                style: GoogleFonts.outfit(color: Colors.white60, fontSize: 13),
                              ),
                            ),
                            const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                          ],
                        ),
                      ),
                    ),
                    
                    // Create an Account Button
                    _buildAnimatedItem(
                      index: 6, totalItems: 8,
                      child: GestureDetector(
                        onTap: _navigateToSignUp,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFC0C0C0), Color(0xFFFF5A00)], // Silver to Orange
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF5A00).withValues(alpha: 0.5),
                                blurRadius: 24,
                                spreadRadius: 2,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'Create an Account',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Login button at bottom
                    _buildAnimatedItem(
                      index: 7, totalItems: 8,
                      child: GestureDetector(
                        onTapDown: (_) => setState(() => _isLoginPressed = true),
                        onTapCancel: () => setState(() => _isLoginPressed = false),
                        onTapUp: (_) {
                          setState(() => _isLoginPressed = false);
                          _navigateToLogin();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _isLoginPressed ? const Color(0xFF39FF14) : const Color(0xFFFF5A00), 
                              width: _isLoginPressed ? 2 : 1.5
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: _isLoginPressed ? const Color(0xFF39FF14).withValues(alpha: 0.1) : Colors.transparent,
                            boxShadow: _isLoginPressed
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF39FF14).withValues(alpha: 0.6),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              'Login',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _isLoginPressed ? const Color(0xFF39FF14) : const Color(0xFFFF5A00),
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildSelectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required UserRole role,
  }) {
    final bool isSelected = _selectedRole == role;
    final bool isPressed = _pressedRole == role;
    final bool isActive = isSelected || isPressed;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressedRole = role),
      onTapCancel: () => setState(() => _pressedRole = null),
      onTapUp: (_) {
        setState(() {
          _pressedRole = null;
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF00E5FF).withValues(alpha: 0.1) : const Color(0xFF111111),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? const Color(0xFF00E5FF) : Colors.white12, 
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ]
            : [],
        ),
        child: Row(
          children: [
            // Icon
            AnimatedTheme(
              data: ThemeData(
                iconTheme: IconThemeData(
                  color: isActive ? const Color(0xFF00E5FF) : const Color(0xFFFF5A00),
                ),
              ),
              child: Icon(
                icon,
                size: 40,
                color: isActive ? const Color(0xFF00E5FF) : const Color(0xFFFF5A00),
              ),
            ),
            const SizedBox(width: 16),
            
            // Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow right
            Icon(
              Icons.chevron_right,
              color: isActive ? const Color(0xFF00E5FF) : const Color(0xFFFF5A00),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToLogin() {
    Provider.of<AppState>(context, listen: false).selectRole(_selectedRole);
    Navigator.of(context).push(
      RollingPageRoute(
        page: LoginScreen(role: _selectedRole),
      ),
    );
  }

  void _navigateToSignUp() {
    Provider.of<AppState>(context, listen: false).selectRole(_selectedRole);
    Navigator.of(context).push(
      RollingPageRoute(
        page: SignupScreen(initialRole: _selectedRole),
      ),
    );
  }
}
