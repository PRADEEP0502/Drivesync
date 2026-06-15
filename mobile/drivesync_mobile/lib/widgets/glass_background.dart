import 'package:flutter/material.dart';

class GlassBackground extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const GlassBackground({
    super.key,
    required this.child,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Stack(
        children: [
          // Base light gray background (#F8FAFC)
          Positioned.fill(
            child: Container(
              color: const Color(0xFFF8FAFC),
            ),
          ),
          
          // Blob 1: Royal violet glow top-right
          Positioned(
            top: -120,
            right: -80,
            width: 320,
            height: 320,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6D5DF6).withValues(alpha: 0.15), // New primary violet glow
                    const Color(0xFF6D5DF6).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Blob 2: Soft indigo glow bottom-left
          Positioned(
            bottom: -100,
            left: -80,
            width: 300,
            height: 300,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8B80F9).withValues(alpha: 0.18), // New secondary soft indigo glow
                    const Color(0xFF8B80F9).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Blob 3: Lavender highlight center-right
          Positioned(
            top: 300,
            right: -100,
            width: 280,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFC084FC).withValues(alpha: 0.12),
                    const Color(0xFFC084FC).withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // Content Layer
          Positioned.fill(
            child: child,
          ),
        ],
      ),
    );
  }
}
