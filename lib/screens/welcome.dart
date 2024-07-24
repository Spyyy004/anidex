import 'package:anidex/screens/onboarding.dart';
import 'package:anidex/utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // App Name
          Spacer(),
          Center(
            child: Text(
              "Anidex",
              style: GoogleFonts.poppins(
                fontSize: 70.0,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          SizedBox(height: 1),
          // Tagline
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: 14.0,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              children: <TextSpan>[
                TextSpan(text: 'Explore '),
                TextSpan(
                  text: 'Wildlife',
                  style: TextStyle(color: primaryColor),
                ),
                TextSpan(text: ' like never before'),
              ],
            ),
          ),
          Spacer(),
          // Get Started Button
          ElevatedButton(
            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OnboardingScreen()), // Replace with actual next page
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,

              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Container(
              width: MediaQuery.sizeOf(context).width * 0.9,
              child: Center(
                child: Text(
                  "Get Started",
                  style: GoogleFonts.poppins(
                    fontSize: 24.0,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
