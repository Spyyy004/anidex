import 'package:anidex/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneNumberLoginModal extends StatefulWidget {
  final Function onSuccess;

  PhoneNumberLoginModal({required this.onSuccess});

  @override
  _PhoneNumberLoginModalState createState() => _PhoneNumberLoginModalState();
}

class _PhoneNumberLoginModalState extends State<PhoneNumberLoginModal> {
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
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                _isOtpSent ? 'Enter OTP' : 'Please Sign in to save your scans.',
                style: labelStyles
              ),
            ),
            SizedBox(height: 16,),

            if (!_isOtpSent)
              IntlPhoneField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                ),
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
            SizedBox(height: 16.0),
            Center(
              child: isLoading ? CircularProgressIndicator(color: primaryColor,): ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: _isOtpSent ? _signInWithOtp : _verifyPhoneNumber,
                child: Text(_isOtpSent ? 'Verify OTP' : 'Send OTP',style: subtitleStyles),
              ),
            ),

          ],
        ),
      ),
    );
  }
}

void showPhoneNumberLoginModal(BuildContext context, Function onSuccess) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return PhoneNumberLoginModal(onSuccess: onSuccess);
    },
  );
}
