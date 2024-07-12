import 'package:anidex/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String _verificationId = '';
  String _countryCode = '+1'; // Default country code

  void _verifyPhoneNumber() async {
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
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text,
      );
      await _auth.signInWithCredential(credential);
      _createUserDocument();
      widget.onSuccess();
      Navigator.pop(context);
    } catch (e) {
      // Handle error
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
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
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
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                ),
                onPressed: _isOtpSent ? _signInWithOtp : _verifyPhoneNumber,
                child: Text(_isOtpSent ? 'Verify OTP' : 'Send OTP'),
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
