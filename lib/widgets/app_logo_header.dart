import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Custom app header with logo and styled "BeStWatchList" text
/// The "BeSt" portion is styled more subtly
class AppLogoHeader extends StatelessWidget {
  const AppLogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo
        SvgPicture.asset(
          'assets/logo.svg',
          width: 32,
          height: 32,
        ),
        const SizedBox(width: 12),
        // Styled app name
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            children: [
              // "Be" - light and smaller
              TextSpan(
                text: 'Be',
                style: TextStyle(
                  color: Color(0xFFD4AF37), // Gold
                  fontWeight: FontWeight.w300, // Light
                  fontSize: 14, // Smaller
                ),
              ),
              // "St" - bold and smaller
              TextSpan(
                text: 'St',
                style: TextStyle(
                  color: Color(0xFFD4AF37), // Gold (same as Be)
                  fontWeight: FontWeight.w700, // Bold
                  fontSize: 14, // Smaller (same as Be)
                ),
              ),
              // "WatchList" - prominent
              TextSpan(
                text: 'WatchList',
                style: TextStyle(
                  color: Color(0xFFD4AF37), // Gold
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
