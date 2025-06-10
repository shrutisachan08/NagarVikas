import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class LogoWidget extends StatefulWidget {
  @override
  _LogoWidgetState createState() => _LogoWidgetState();
}

class _LogoWidgetState extends State<LogoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleUp = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Simulating a delay before redirection (Replace this with actual navigation)
    Future.delayed(Duration(seconds: 3), () {
      print("Redirecting to next screen...");
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NextScreen()));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _fadeIn,
                    child: ScaleTransition(
                      scale: _scaleUp,
                      child: Image.asset(
                        'assets/app_icon.png',
                        width: 150,
                        height: 150,
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'NagarVikas',
                        textStyle: GoogleFonts.nunito(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        textAlign: TextAlign.center,
                        speed: Duration(milliseconds: 100),
                      ),
                      TypewriterAnimatedText(
                        'Created By Fate.\nEngineered By Prateek Chourasia',
                        textStyle: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                        speed: Duration(milliseconds: 100),
                      ),
                    ],
                    totalRepeatCount: 1,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Column(
              children: [
                CircularProgressIndicator(
                  color:  Colors.red,
                ),
                SizedBox(height: 15),
                Text(
                  "Redirecting...",
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
     ),
);
}
}
