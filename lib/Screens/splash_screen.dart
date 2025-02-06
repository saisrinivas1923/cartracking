import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';

import '../screens/export_screens.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this,);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).pushReplacement(
          CupertinoPageRoute(builder: (context) => HomePage()),
        );
      }
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
      body: Stack(
        children: [
          // Background gradient
          Container(color: Colors.white),
          // Bus animation
          Center(
            child: Lottie.asset('assets/WdSD52fBkE.json',
                frameRate: FrameRate.max,
                width: double.infinity / 1.8,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                controller: _controller,
                onLoaded: (composition){
                  _controller
                    ..duration = Duration(seconds: 4)
                    ..forward();
                }
            ),
          ),
          //App Name
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 500),
              child: Text(
                "College Car Locator",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  // color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
