
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:omniya/view/auth/log_in.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin();
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 4));

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double logoContainerSize = screenWidth * 0.9;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgroundlite.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: FadeInUp(
                duration: const Duration(milliseconds: 1200),
                child: FadeIn(
                  delay: const Duration(milliseconds: 400),
                  duration: const Duration(milliseconds: 1000),
                  child: Image.asset(
                    'assets/images/animationlit.gif',
                    width: logoContainerSize,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: FadeInUp(
                delay: const Duration(milliseconds: 1000),
                duration: const Duration(milliseconds: 800),
                child: const Center(
                  child: Text(
                    'Omniya',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
