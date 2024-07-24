import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import 'home.dart';

class SuccessLottieScreen extends StatefulWidget {
  const SuccessLottieScreen({super.key});

  @override
  State<SuccessLottieScreen> createState() => _SuccessLottieScreenState();
}

class _SuccessLottieScreenState extends State<SuccessLottieScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainPage()),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: SafeArea(child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Lottie.network("https://lottie.host/e9f5b1e4-50ba-4325-a0f5-3aa6e0a7bf0a/Dj3mvmMseY.json")),
          Text("Welcome to Anidex Family!",style: GoogleFonts.poppins(fontSize : 22, fontWeight: FontWeight.w600),)
        ],
      )),
    );
  }
}
