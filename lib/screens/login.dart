import 'package:anidex/components/phone_component.dart';
import 'package:anidex/screens/home.dart';
import 'package:anidex/screens/successLottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool showLottie = true;
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: primaryColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: Center(child: Text("Anidex", style: GoogleFonts.poppins(
                  fontSize : 64,
                  fontWeight: FontWeight.bold,
                  color : Color(0xfffffcfc)
                ),)),
              ),
            ),
            Container(
              height: size.height * 0.65,
              decoration: BoxDecoration(

                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32))
              ),
              child: Padding(

                padding: const EdgeInsets.all(8.0),
                child: PhoneNumberLoginComponent(onSuccess: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return SuccessLottieScreen();
                  }));
                },),

              ),
            )
          ],
        ),
      ),
    );
  }
}



class PhoneNumberLoginComponent extends StatefulWidget {
  final Function onSuccess;

  PhoneNumberLoginComponent({required this.onSuccess});

  @override
  PhoneNumberLoginComponentState createState() => PhoneNumberLoginComponentState();
}


class PhoneNumberLoginComponentState extends State<PhoneNumberLoginComponent> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool isLoading = false;
  String _verificationId = '';
  String _countryCode = '+1'; // Default country code

  void _verifyPhoneNumber() async {
    isLoading = true;
    setState(() {

    });
    if (kIsWeb) {
      // For Web
      RecaptchaVerifier verifier = RecaptchaVerifier(

        size: RecaptchaVerifierSize.normal,
        theme: RecaptchaVerifierTheme.light, auth: FirebaseAuthPlatform.instance,
      );

      try {
        ConfirmationResult confirmationResult = await _auth.signInWithPhoneNumber(
          _countryCode + _phoneController.text,
          verifier,
        );
        setState(() {
          _verificationId = confirmationResult.verificationId;
          _isOtpSent = true;
          isLoading = false;
        });
      } catch (e) {
        // Handle error
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to send verification code: ${e.toString()}")));
      }
    }
    await _auth.verifyPhoneNumber(
      phoneNumber: _countryCode + _phoneController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        widget.onSuccess();
        Navigator.pop(context);
      },
      verificationFailed: (FirebaseAuthException e) {
        // Handle error
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _isOtpSent = true;
          isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  void _signInWithOtp() async {


    try {
      isLoading = true;
      setState(() {

      });
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text,
      );
      await _auth.signInWithCredential(credential);
      _createUserDocument();
      widget.onSuccess();
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: "Invalid OTP");
    }
    finally{
      isLoading = false;
      setState(() {

      });
    }
  }

  void _createUserDocument() async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Check if the user document already exists
      DocumentSnapshot docSnapshot =
      await _firestore.collection('users').doc(user.uid).get();

      if (!docSnapshot.exists) {
        // User document does not exist, create it
        DocumentReference userDoc = _firestore.collection('users').doc(user.uid);
        userDoc.set({
          'firstName': '.',
          'lastName': '.',
          'phoneNumber': user.phoneNumber,
          'scans': [],
          'favorites':[],
          "badges":[],
          "profilePic":""
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
              _isOtpSent ? 'Enter OTP' : 'Welcome!',
              style: GoogleFonts.poppins(fontSize : 32, fontWeight : FontWeight.normal)
          ),
        ),
        SizedBox(height: 16,),

        if (!_isOtpSent)
          IntlPhoneField(
            showDropdownIcon: false,
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              border: OutlineInputBorder(
                borderSide: BorderSide(),
                borderRadius: BorderRadius.circular(15)
              ),
            ),
            flagsButtonMargin:EdgeInsets.only(left: 8),
            initialCountryCode: 'IN', // Set initial country code
            onChanged: (phone) {
              setState(() {
                _countryCode = phone.countryCode;
              });
            },
          ),
        if (_isOtpSent)
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'OTP',
              border: OutlineInputBorder(
                borderSide: BorderSide(),
              ),
            ),
          ),
Spacer(),
        Align(
          alignment: Alignment.bottomCenter,
          child:  isLoading ? CircularProgressIndicator(color: primaryColor,):OutlinedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateColor.resolveWith((states) => primaryColor),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child:  Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Center(
                  child: Text(_isOtpSent ? 'Verify OTP' : 'Send OTP',style: labelStyles.merge(TextStyle(color: Colors.white))),
                ),
              ),
            ),
            onPressed:   _isOtpSent ? _signInWithOtp : _verifyPhoneNumber,
          ),

        )

      ],
    );
  }
}




class SignupButton extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const SignupButton({
    required this.emailController,
    required this.passwordController,
    super.key,
  });

  @override
  Widget build(BuildContext context) {

        return Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: false
                ? CircularProgressIndicator(
              color: primaryColor,
            )
                : OutlinedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith((states) => primaryColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child:  Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: Text(
                      "Send OTP",
                      style: subHeaderStyles.merge(TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ),
              onPressed:  () async{
                String email = emailController.text;
                String password = passwordController.text;
                try {
                  // await authProvider.loginUser(email, password);
                  // Navigator.pushAndRemoveUntil(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => GameMenu()),
                  //       (Route<dynamic> route) => false,
                  // );
                }
                catch(e) {

                }
              },
            ),
          ),
        );

  }
}
