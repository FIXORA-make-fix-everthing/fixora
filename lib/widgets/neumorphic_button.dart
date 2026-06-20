import 'package:flutter/material.dart';

class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color baseColor;
  final Color? glowColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const NeumorphicButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.baseColor = const Color(0xFF00E5FF),
    this.glowColor = const Color(0xFFFF9E5E),
    this.borderRadius = 30.0,
    this.padding = const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color actualColor = widget.baseColor;
    Color actualGlowColor = widget.glowColor!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      decoration: BoxDecoration(
        color: actualColor.withValues(alpha: _isPressed ? 0.3 : 0.1),
        borderRadius: BorderRadius.circular(widget.borderRadius),
        boxShadow: _isPressed
            ? [
                BoxShadow(
                  color: actualGlowColor.withValues(alpha: 0.8),
                  blurRadius: 20,
                  spreadRadius: 2,
                )
              ]
            : [
                BoxShadow(
                  color: actualGlowColor.withValues(alpha: 0.5),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
        border: Border.all(color: actualColor, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          splashColor: actualColor.withValues(alpha: 0.4),
          highlightColor: Colors.transparent,
          onHighlightChanged: (isHighlighted) {
            setState(() {
              _isPressed = isHighlighted;
            });
          },
          onTap: () {
            Future.delayed(const Duration(milliseconds: 150), widget.onPressed);
          },
          child: Padding(
            padding: widget.padding,
            child: Center(
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
