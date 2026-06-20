import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'language_selection_screen.dart';
import '../utils/page_transitions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _videoController;
  bool _videoInitialized = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    _videoController = VideoPlayerController.asset('assets/images/splash.mp4');

    try {
      await _videoController.initialize();
      if (!mounted) return;

      setState(() {
        _videoInitialized = true;
      });

      // Hide status bar for immersive full-screen experience
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

      _videoController.play();

      // Navigate when video ends OR after a max of 8 seconds
      _videoController.addListener(_onVideoProgress);
      Timer(const Duration(seconds: 8), () => _navigateAway());
    } catch (e) {
      // If video fails, fallback: wait 1s and navigate
      Timer(const Duration(seconds: 1), () => _navigateAway());
    }
  }

  void _onVideoProgress() {
    final pos = _videoController.value.position;
    final dur = _videoController.value.duration;

    if (dur > Duration.zero && pos >= dur - const Duration(milliseconds: 200)) {
      _navigateAway();
    }
  }

  void _navigateAway() {
    if (_navigated || !mounted) return;
    _navigated = true;

    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    Navigator.of(context).pushReplacement(
      RollingPageRoute(page: const LanguageSelectionScreen()),
    );
  }

  @override
  void dispose() {
    _videoController.removeListener(_onVideoProgress);
    _videoController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen video player stretched to fill the screen (no black bars, no blur)
          if (_videoInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.fill,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            )
          else
            // Simple black screen while initializing
            Container(color: const Color(0xFF0F0F0F)),
        ],
      ),
    );
  }
}
