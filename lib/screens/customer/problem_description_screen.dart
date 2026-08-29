import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import '../../providers/app_state.dart';
import 'book_service_screen.dart';
import 'custom_request_success_screen.dart';

class ProblemDescriptionScreen extends StatefulWidget {
  final ServiceCategory category;

  const ProblemDescriptionScreen({
    super.key,
    required this.category,
  });

  @override
  State<ProblemDescriptionScreen> createState() => _ProblemDescriptionScreenState();
}

class _ProblemDescriptionScreenState extends State<ProblemDescriptionScreen> {
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _problemStatementController = TextEditingController();
  
  bool _isRecording = false;
  bool _speechEnabled = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final SpeechToText _speechToText = SpeechToText();

  @override
  void initState() {
    super.initState();
    _initSpeech();
    if (widget.category.items.isNotEmpty) {
      _productNameController.text = widget.category.items.first.name;
    }
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _isRecording = true;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isRecording = false;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _problemStatementController.text = result.recognizedWords;
    });
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _problemStatementController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151515),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded, color: Colors.white),
                  title: Text('Take Photo', style: GoogleFonts.outfit(color: Colors.white)),
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera);
                      if (pickedFile != null) setState(() => _imageFile = File(pickedFile.path));
                    } catch (e) {
                      debugPrint("Error picking camera: $e");
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded, color: Colors.white),
                  title: Text('Choose from Gallery', style: GoogleFonts.outfit(color: Colors.white)),
                  onTap: () async {
                    Navigator.pop(context);
                    try {
                      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) setState(() => _imageFile = File(pickedFile.path));
                    } catch (e) {
                      debugPrint("Error picking gallery: $e");
                    }
                  },
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  void _onNextPressed() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: const Color(0xFF0F0F0F).withValues(alpha: 0.9),
      builder: (context) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(seconds: 2),
                builder: (context, double value, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 10,
                              top: 10,
                              child: Transform.rotate(
                                angle: value * 3.14159 * 4, // Clockwise
                                child: const Icon(Icons.settings_rounded, size: 80, color: Color(0xFF39FF14)),
                              ),
                            ),
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: Transform.rotate(
                                angle: -value * 3.14159 * 6, // Counter-clockwise
                                child: const Icon(Icons.settings_rounded, size: 50, color: Color(0xFF00E5FF)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 3 Premium animated lines
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPremiumLine(value, 0.0, 80),
                          const SizedBox(height: 12),
                          _buildPremiumLine(value, 0.15, 120),
                          const SizedBox(height: 12),
                          _buildPremiumLine(value, 0.3, 60),
                        ],
                      ),
                    ],
                  );
                },
                onEnd: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BookServiceScreen(category: widget.category),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Analyzing Request...',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF39FF14),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildPremiumLine(double animationValue, double delay, double maxWidth) {
    double progress = (animationValue - delay) / (1.0 - delay);
    if (progress < 0) progress = 0;
    if (progress > 1) progress = 1;
    
    // Smooth curve
    progress = Curves.easeInOutCubic.transform(progress);

    return Container(
      height: 6,
      width: maxWidth * progress,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        gradient: const LinearGradient(
          colors: [Color(0xFF39FF14), Color(0xFF00E5FF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ]
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF0F0F0F);
    const Color containerBgColor = Color(0xFF151515);
    const Color fieldBgColor = Color(0xFF1E1E1E);
    const Color electricBlue = Color(0xFF00E5FF);
    const Color orangeColor = Color(0xFFFF5A00);
    const Color electricGreen = Color(0xFF39FF14);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Problem of the product :',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  color: orangeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              
              // Main Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: containerBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product name:',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: fieldBgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: TextField(
                        controller: _productNameController,
                        style: GoogleFonts.outfit(color: Colors.white),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    Text(
                      'Problem statement:',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: fieldBgColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isRecording ? electricBlue : Colors.white10,
                          width: _isRecording ? 1.5 : 1.0,
                        ),
                        boxShadow: [
                          if (_isRecording)
                            BoxShadow(
                              color: electricBlue.withValues(alpha: 0.15),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                        ],
                      ),
                      child: Stack(
                        children: [
                          TextField(
                            controller: _problemStatementController,
                            maxLines: 5,
                            style: GoogleFonts.outfit(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Problem statement......',
                              hintStyle: GoogleFonts.outfit(color: Colors.white38),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                          // Microphone Icon
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: GestureDetector(
                              onTapDown: (_) {
                                if (_speechEnabled) {
                                  _startListening();
                                } else {
                                  // Fallback visual if speech is not enabled yet
                                  setState(() => _isRecording = true);
                                }
                              },
                              onTapUp: (_) {
                                _stopListening();
                              },
                              onTapCancel: () {
                                _stopListening();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: EdgeInsets.all(_isRecording ? 12 : 8),
                                decoration: BoxDecoration(
                                  color: _isRecording 
                                      ? electricBlue 
                                      : electricBlue.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.mic_rounded,
                                  color: _isRecording ? Colors.black : electricBlue,
                                  size: _isRecording ? 24 : 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // "Problem didn't identified" button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CustomRequestSuccessScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: electricBlue.withValues(alpha: 0.15),
                          side: const BorderSide(color: electricBlue, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          elevation: 0,
                        ),
                        child: Text(
                          "Problem didn't identified",
                          style: GoogleFonts.outfit(
                            color: electricBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                'Add Image:',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  color: orangeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              
              // Upload image
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: containerBgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Image.file(
                                _imageFile!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _imageFile = null;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Upload img',
                          style: GoogleFonts.outfit(
                            color: Colors.white60,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded, 
                        color: Colors.white
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Next Button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _onNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: electricGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      shadowColor: electricGreen.withValues(alpha: 0.5),
                      elevation: 8,
                    ),
                    child: Text(
                      'Next',
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
