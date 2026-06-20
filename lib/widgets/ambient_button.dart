import 'package:flutter/material.dart';
import '../utils/theme.dart';

class AmbientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color glowColor;
  final bool isLoading;

  const AmbientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.glowColor = AppColors.ambientNeon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.6),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: AppColors.silverSurface,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: glowColor.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: glowColor,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      text,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: glowColor,
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
