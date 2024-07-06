import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/phone_component.dart';
import '../models/animal_info.dart';
import '../utils.dart';

class AnimalInfo extends StatefulWidget {
  final String capturedImage;
  final AnimalInfoModel animalInfoModel;
  final bool isInfo;

  AnimalInfo({
    required this.capturedImage,
    required this.animalInfoModel,
    required this.isInfo,
  });

  @override
  _AnimalInfoState createState() => _AnimalInfoState();
}

class _AnimalInfoState extends State<AnimalInfo> {
  bool _isUploading = false; // Track if an upload operation is in progress

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.animalInfoModel.basicInformation?.commonName ?? 'Animal Info',
            style: GoogleFonts.poppins(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.chevron_left, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          backgroundColor: Colors.blueAccent,
          elevation: 0, // Remove appbar shadow
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 16.0),
                      _buildAnimalImage(),
                      SizedBox(height: 16.0),
                      _buildSectionTitle('Basic Information'),
                      _buildBasicInfoList(),
                      _buildSectionTitle('Physical Description'),
                      _buildInfoParagraph(
                        widget.animalInfoModel.basicInformation?.physicalDescription ??
                            'No description available.',
                        style: GoogleFonts.poppins(fontSize: 16.0),
                      ),
                      _buildSectionTitle('Habitat'),
                      _buildInfoParagraph(
                        widget.animalInfoModel.basicInformation?.habitat ??
                            'No habitat information available.',
                        style: GoogleFonts.poppins(fontSize: 16.0),
                      ),
                      _buildSectionTitle('Geographic Distribution'),
                      _buildInfoParagraph(
                        widget.animalInfoModel.basicInformation?.geographicDistribution?.join(', ') ??
                            'No geographic distribution information available.',
                        style: GoogleFonts.poppins(fontSize: 16.0),
                      ),
                      _buildSectionTitle('Behavior'),
                      _buildInfoParagraph(
                        widget.animalInfoModel.basicInformation?.behavior ??
                            'No behavior information available.',
                        style: GoogleFonts.poppins(fontSize: 16.0),
                      ),
                      _buildSectionTitle('Diet'),
                      _buildInfoParagraph(
                        widget.animalInfoModel.basicInformation?.diet ??
                            'No diet information available.',
                        style: GoogleFonts.poppins(fontSize: 16.0),
                      ),
                      _buildSectionTitle('Conservation Status'),
                      _buildInfoParagraph(
                        widget.animalInfoModel.basicInformation?.conservationStatus ??
                            'No conservation status available.',
                        style: GoogleFonts.poppins(fontSize: 16.0),
                      ),
                      _buildSectionTitle('Interesting Facts'),
                      _buildInterestingFacts(
                        widget.animalInfoModel.basicInformation?.interestingFacts ??
                            ['No interesting facts available.'],
                        style: GoogleFonts.poppins(fontSize: 16.0),
                      ),
                      SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: _buildSaveScanButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimalImage() {
    return Container(
      height: 300.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        image: DecorationImage(
          image: widget.isInfo
              ? NetworkImage(widget.capturedImage) as ImageProvider<Object>
              : FileImage(File(widget.capturedImage)),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  Widget _buildBasicInfoList() {
    final basicInfo = widget.animalInfoModel.basicInformation;

    List<String> basicInfoList = [
      'Common Name: ${basicInfo?.commonName ?? 'NA'}',
      'Scientific Name: ${basicInfo?.scientificName ?? 'NA'}',
      'Kingdom: ${basicInfo?.classification?.kingdom ?? 'NA'}',
      'Phylum: ${basicInfo?.classification?.phylum ?? 'NA'}',
      'Class: ${basicInfo?.classification?.animalClass ?? 'NA'}',
      'Order: ${basicInfo?.classification?.order ?? 'NA'}',
      'Family: ${basicInfo?.classification?.family ?? 'NA'}',
      'Genus: ${basicInfo?.classification?.genus ?? 'NA'}',
      'Species: ${basicInfo?.classification?.species ?? 'NA'}',
    ];

    return Container(
      height: 48.0,
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: basicInfoList.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Chip(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              label: Text(
                basicInfoList[index],
                style: GoogleFonts.poppins(
                  fontSize: 14.0,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Color(0xFF173EA5),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoParagraph(String text, {TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: style ?? GoogleFonts.poppins(fontSize: 16.0),
      ),
    );
  }

  Widget _buildInterestingFacts(List<String> facts, {TextStyle? style}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: facts.map((fact) => _buildInfoBullet(fact, style: style)).toList(),
    );
  }

  Widget _buildInfoBullet(String text, {TextStyle? style}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.arrow_right, color: Colors.blueAccent),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.justify,
              style: style ?? GoogleFonts.poppins(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveScanButton() {
    return _isUploading
        ? Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ),
    )
        : ElevatedButton(
      onPressed: () {
        _uploadScanAndUpdateUser();
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.blueAccent),
        shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          'Save Scan',
          style: GoogleFonts.poppins(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _uploadScanAndUpdateUser() async {
    setState(() {
      _isUploading = true; // Start uploading process, show loader
    });

    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final FirebaseStorage _storage = FirebaseStorage.instance;
    User? user = _auth.currentUser;

    if (user == null) {
      throw Exception("No user logged in.");
    }

    try {
      // Step 1: Upload the image to Firebase Storage
      String fileName = widget.animalInfoModel.basicInformation!.commonName.toString() + user.uid + widget.capturedImage.substring(0, 5);
      Reference storageRef = _storage.ref().child('scans/$fileName');
      UploadTask uploadTask = storageRef.putFile(File(widget.capturedImage));
      TaskSnapshot taskSnapshot = await uploadTask;

      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      // Step 2: Create a new scan document in the 'scans' collection
      DocumentReference scanRef = await _firestore.collection('scans').add({
        'userId': user.uid,
        'scanData': widget.animalInfoModel.toJson(),
        'imagePath': downloadURL,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Step 3: Get the scan ID from the newly created document
      String scanId = scanRef.id;

      // Step 4: Update the user's document to add the scan ID to the scans array
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      List<dynamic> userScans = userDoc['scans'] ?? [];
      List<dynamic> userBadges = userDoc['badges'] ?? [];

      List<String> earnedBadges = [];

      // Check for New Beginnings badge
      if (userScans.isEmpty && !userBadges.contains('New Beginnings')) {
        earnedBadges.add('New Beginnings');
      }

      // Other badge checks can be added here
      if (userScans.length + 1 >= 5 && !userBadges.contains('Night Watcher')) {
        earnedBadges.add('Night Watcher');
      }
      if (userScans.length + 1 >= 20 && !userBadges.contains('Marine Explorer')) {
        earnedBadges.add('Marine Explorer');
      }
      // Add more badge checks based on your requirements

      await _firestore.collection('users').doc(user.uid).update({
        'scans': FieldValue.arrayUnion([scanId]),
        'badges': FieldValue.arrayUnion(earnedBadges),
      });

      Fluttertoast.showToast(msg: "Scan uploaded successfully");

      if (earnedBadges.isNotEmpty) {
        Fluttertoast.showToast(msg: "You have earned new badges: ${earnedBadges.join(', ')}");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to upload scan");
      throw e;
    } finally {
      setState(() {
        _isUploading = false; // Upload process completed, hide loader
      });
    }
  }
}