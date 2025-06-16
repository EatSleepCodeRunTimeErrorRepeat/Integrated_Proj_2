import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'login_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool _pressedLogin = false;
  bool _pressedRegister = false;

  void animatePress(Function() onComplete, bool isLogin) {
    setState(() {
      if (isLogin) {
        _pressedLogin = true;
      } else {
        _pressedRegister = true;
      }
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _pressedLogin = false;
        _pressedRegister = false;
      });
      onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F0),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/Logo.png', height: 200),
                const SizedBox(height: 16),
                const Text(
                  'Don’t Peak Out—Plan It Out!',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 40),

                // Login Button with Animation
                AnimatedScale(
                  scale: _pressedLogin ? 0.96 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeInOut,
                  child: SizedBox(
                    width: 331,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => animatePress(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LoginScreen()),
                        );
                      }, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF366D34),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Register Button with Animation
                AnimatedScale(
                  scale: _pressedRegister ? 0.96 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeInOut,
                  child: SizedBox(
                    width: 331,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () => animatePress(() {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen()),
                        );
                      }, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFF366D34), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF366D34),
                        ),
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
