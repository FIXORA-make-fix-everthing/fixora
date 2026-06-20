import 'package:flutter/material.dart';
import 'dart:math' as math;

class LiquidButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;

  const LiquidButton({
    super.key,
    required this.child,
    required this.onPressed,
  });

  @override
  State<LiquidButton> createState() => _LiquidButtonState();
}

class _LiquidButtonState extends State<LiquidButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    // Animate one full roll (2 * pi)
    _flipAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onPressed();
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!_controller.isAnimating) {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(_flipAnimation.value),
          child: child,
        );
      },
      child: GestureDetector(
        onTap: _handleTap,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: const Color(0xFFD1D1D1), // Silver background for the pill
            boxShadow: [
              // Colorful ambient light effect at the edges
              BoxShadow(
                color: const Color(0xFFFF9800).withValues(alpha: 0.6), // Orange glow
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(-3, 3),
              ),
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.4), // Cyan/Blue glow
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(3, -3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Stack(
              children: [
                // Liquid / Slanted orange gradient
                Positioned(
                  left: -20,
                  top: 0,
                  bottom: 0,
                  width: 200,
                  child: Transform(
                    transform: Matrix4.skewX(-0.3),
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFFFB74D), // Light Orange
                            Color(0xFFFF7043), // Deep Orange
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Content (Text and Arrow)
                Center(
                  child: widget.child,
                ),

                // Glassy reflection on top
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 30,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.3),
                          Colors.white.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
