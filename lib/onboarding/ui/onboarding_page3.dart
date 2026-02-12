import 'package:flutter/material.dart';

class OnboardingPage3 extends StatelessWidget {
  const OnboardingPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          // 🖼️ Illustration
          Expanded(
            flex: 5,
            child: Image.asset(
              'assets/images/onboarding_3.png',
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 30),

          // 📝 Title
          const Text(
            'Never Forget Again',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          // 🧾 Subtitle
          const Text(
            'Receive timely notifications so you never miss a dose.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 80), // space for indicator & buttons
        ],
      ),
    );
  }
}
