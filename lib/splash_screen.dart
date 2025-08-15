import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  final VoidCallback onFinish;
  const SplashScreen({required this.onFinish, super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), widget.onFinish);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gahan logo with sci-fi glow
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.7),
                    blurRadius: 60,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: Image.asset(
                'assets/gahan_logo.png',
                height: 140,
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'FusionLens',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                fontSize: 36,
                color: Colors.cyanAccent,
                letterSpacing: 8.0,
                shadows: [
                  Shadow(
                    color: Colors.cyanAccent.withOpacity(0.8),
                    blurRadius: 18,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'by Gahan',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontFamily: 'Roboto',
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
