import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'custom_request_success_screen.dart';

class AddOwnServiceScreen extends StatefulWidget {
  const AddOwnServiceScreen({super.key});

  @override
  State<AddOwnServiceScreen> createState() => _AddOwnServiceScreenState();
}

class _AddOwnServiceScreenState extends State<AddOwnServiceScreen> {
  final TextEditingController _textController = TextEditingController();
  
  bool _isRecording = false;
  bool _speechEnabled = false;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final SpeechToText _speechToText = SpeechToText();

  @override
  void initState() {
    super.initState();
    _initSpeech();
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
      _textController.text = result.recognizedWords;
    });
  }

  @override
  void dispose() {
    _textController.dispose();
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

  void _proceedToNext() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CustomRequestSuccessScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Describe Service',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Text(
                'What do you need help with?',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Type your request or use voice to describe the problem.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 40),

              // Text Input
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF151515),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: 5,
                  style: GoogleFonts.outfit(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'E.g., I need someone to fix my broken window glasses...',
                    hintStyle: GoogleFonts.outfit(color: Colors.white38),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Upload image
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151515),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
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
                          'Upload picture (Optional)',
                          style: GoogleFonts.outfit(
                            color: Colors.white60,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(
                        Icons.camera_alt_outlined, 
                        color: Colors.white60
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
              
              // OR Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR',
                      style: GoogleFonts.outfit(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
                ],
              ),
              
              const SizedBox(height: 40),

              // Voice Recording Button
              GestureDetector(
                onTapDown: (_) {
                  if (_speechEnabled) {
                    _startListening();
                  } else {
                    setState(() => _isRecording = true);
                  }
                },
                onTapUp: (_) => _stopListening(),
                onTapCancel: () => _stopListening(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: _isRecording ? 100 : 120,
                  width: _isRecording ? 100 : 120,
                  decoration: BoxDecoration(
                    color: _isRecording 
                        ? const Color(0xFFFF5A00) 
                        : const Color(0xFFFF5A00).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFF5A00),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF5A00).withValues(alpha: _isRecording ? 0.6 : 0.2),
                        blurRadius: _isRecording ? 30 : 15,
                        spreadRadius: _isRecording ? 5 : 2,
                      )
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.mic_rounded,
                      size: 48,
                      color: _isRecording ? Colors.black : const Color(0xFFFF5A00),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isRecording ? 'Listening...' : 'Hold to Speak',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: _isRecording ? const Color(0xFFFF5A00) : Colors.white60,
                ),
              ),

              const SizedBox(height: 60),

              // Next Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _proceedToNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5FF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 8,
                    shadowColor: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                  ),
                  child: Text(
                    'Next',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
