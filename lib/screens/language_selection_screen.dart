import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'auth_selection_screen.dart';

import '../widgets/liquid_button.dart';
import '../utils/page_transitions.dart';

class LanguageOption {
  final String name;
  final String englishName;
  final String code;

  LanguageOption({
    required this.name,
    required this.englishName,
    required this.code,
  });
}

class LanguageSelectionScreen extends StatefulWidget {
  final bool isFromOnboarding;
  
  const LanguageSelectionScreen({super.key, this.isFromOnboarding = true});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final List<LanguageOption> _languages = [
    LanguageOption(name: 'English', englishName: 'English', code: 'en'),
    LanguageOption(name: 'தமிழ்', englishName: 'Tamil', code: 'ta'),
    LanguageOption(name: 'العربية', englishName: 'Arabic', code: 'ar'),
    LanguageOption(name: 'తెలుగు', englishName: 'Telugu', code: 'te'),
    LanguageOption(name: 'हिन्दी', englishName: 'Hindi', code: 'hi'),
    LanguageOption(name: 'മലയാളം', englishName: 'Malayalam', code: 'ml'),
    LanguageOption(name: 'ಕನ್ನಡ', englishName: 'Kannada', code: 'kn'),
    LanguageOption(name: 'मराठी', englishName: 'Marathi', code: 'mr'),
    LanguageOption(name: 'বাংলা', englishName: 'Bengali', code: 'bn'),
    LanguageOption(name: 'ગુજરાતી', englishName: 'Gujarati', code: 'gu'),
    LanguageOption(name: 'ਪੰਜਾਬੀ', englishName: 'Punjabi', code: 'pa'),
    LanguageOption(name: 'Español', englishName: 'Spanish', code: 'es'),
    LanguageOption(name: 'Français', englishName: 'French', code: 'fr'),
    LanguageOption(name: 'Deutsch', englishName: 'German', code: 'de'),
    LanguageOption(name: 'Italiano', englishName: 'Italian', code: 'it'),
    LanguageOption(name: 'Português', englishName: 'Portuguese', code: 'pt'),
    LanguageOption(name: 'Русский', englishName: 'Russian', code: 'ru'),
    LanguageOption(name: '中文', englishName: 'Chinese', code: 'zh'),
    LanguageOption(name: '日本語', englishName: 'Japanese', code: 'ja'),
    LanguageOption(name: '한국어', englishName: 'Korean', code: 'ko'),
    LanguageOption(name: 'Türkçe', englishName: 'Turkish', code: 'tr'),
    LanguageOption(name: 'Tiếng Việt', englishName: 'Vietnamese', code: 'vi'),
    LanguageOption(name: 'Bahasa Indonesia', englishName: 'Indonesian', code: 'id'),
    LanguageOption(name: 'ไทย', englishName: 'Thai', code: 'th'),
  ];

  String _tempSelectedCode = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E140F), // Black and brown mix background
      body: Stack(
        children: [
          // Theme Background Color is inherited

          // Centered Logo Image
          Positioned.fill(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Image.asset(
                  'assets/images/image.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Background subtle design circles
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 3000,
              height: 3000,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E5FF).withValues(alpha: 0.03),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                
                // Globe Icon Header
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.language_rounded,
                      color: Color(0xFF00E5FF),
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // "Select Language" Title
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Select Language',
                        style: GoogleFonts.outfit(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 120,
                        height: 2,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF00E5FF),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Center(
                  child: Text(
                    'choose your preferred language to continue',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Language Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.35,
                    ),
                    itemCount: _languages.length,
                    itemBuilder: (context, index) {
                      final lang = _languages[index];
                      final isSelected = _tempSelectedCode == lang.code;
                      return _buildLanguageCard(lang, isSelected);
                    },
                  ),
                ),

                // Confirm Button
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: LiquidButton(
                    onPressed: _handleConfirm,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Continue',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
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

  Widget _buildLanguageCard(LanguageOption lang, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _tempSelectedCode = lang.code;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    const Color(0xFF00E5FF).withValues(alpha: 0.15),
                    const Color(0xFF1E1E1E),
                  ]
                : [
                    const Color(0xFF1E1E1E),
                    const Color(0xFF151515),
                  ],
          ),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00E5FF)
                : const Color(0xFF00E5FF).withValues(alpha: 0.15),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF9E5E).withValues(alpha: 0.6),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 0),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Language Native Name
              Text(
                lang.name,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? const Color(0xFF00E5FF) : const Color(0xFFE5E5E5),
                ),
              ),
              const SizedBox(height: 4),
              // English translation label
              Text(
                lang.englishName,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF888888),
                ),
              ),
              const SizedBox(height: 10),
              // Circular Radio-style indicator
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF00E5FF)
                        : const Color(0xFF888888).withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF00E5FF),
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleConfirm() {
    // Set language in provider
    Provider.of<AppState>(context, listen: false).setLanguage(_tempSelectedCode);

    if (widget.isFromOnboarding) {
      // Navigate to AuthSelectionScreen with a rolling transition
      Navigator.of(context).pushReplacement(
        RollingPageRoute(page: const AuthSelectionScreen()),
      );
    } else {
      // Just return back
      Navigator.of(context).pop();
    }
  }
}
