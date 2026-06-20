import 'package:flutter/material.dart';

class RollingPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  RollingPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Rolling / Rotation transition
            var begin = const Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            // Add a slight rotation for the rolling effect
            var rotationTween = Tween(begin: 0.1, end: 0.0).chain(CurveTween(curve: curve));
            var rotationAnimation = animation.drive(rotationTween);

            return SlideTransition(
              position: offsetAnimation,
              child: RotationTransition(
                turns: rotationAnimation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        );
}
