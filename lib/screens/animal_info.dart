import 'dart:io';
import 'package:anidex/screens/scan.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/phone_component.dart';
import '../models/animal_info.dart';
import '../utils.dart';
import 'chat.dart';

class AnimalInfo extends StatefulWidget {
  final dynamic capturedImage;
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
  bool _isUploading = false;
  bool uploadSuccess = false;
  String typeImage = "";
  String rarityText = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    if (widget.animalInfoModel.basicInformation!.type == 'water') {

      typeImage = "assets/water.png";
    } else if (widget.animalInfoModel.basicInformation!.type == 'air') {
      typeImage = "assets/air.png";
    } else {
      typeImage = "assets/land.png";
    }

    // Determine rarity text based on the specified ranges

    try {
      int rarity = widget.animalInfoModel.basicInformation!.rarity;
      if (rarity >= 0 && rarity <= 3) {
        rarityText = 'Abundant';
      } else if (rarity >= 4 && rarity <= 5) {
        rarityText = 'Common';
      } else if (rarity >= 6 && rarity <= 7) {
        rarityText = 'Uncommon';
      } else if (rarity == 8 || rarity == 9) {
        rarityText = 'Rare';
      } else if (rarity == 10) {
        rarityText = 'Exceptional';
      }
    } catch (e) {
      rarityText = "Unknown";
    }
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
          backgroundColor: primaryColor,
          elevation: 0,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: primaryColor,
                            ),
                            child: Text(
                              rarityText,
                              style: GoogleFonts.poppins(
                                fontSize : 12,
                                  fontWeight: FontWeight.w500,color: Colors.white),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 4, horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: primaryColor,
                            ),
                            child: Row(
                              children: [
                                Image(image: AssetImage(typeImage),
                                    height: 20,
                                    width: 20),
                                SizedBox(width: 8),
                                Text(
                                  widget.animalInfoModel.basicInformation!.type ?? "Unknown type",
                                  style: GoogleFonts.poppins(
                                      fontSize : 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // _buildSectionTitle('Scan Quality'),
                      // _buildScanQuality(),
                      _buildSectionTitle('Basic Information'),
                      _buildBasicInfoList(),
                      _buildSectionTitle('Physical Description'),
                      _buildInfoParagraph(
                        widget.animalInfoModel.basicInformation?.physicalDescription ?? 'No description available.',
                      ),
                      _buildSectionTitle('Habitat'),
                      _buildInfoParagraph(
                        widget.animalInfoModel.basicInformation?.habitat ?? 'No habitat information available.',
                      ),
                      _buildSectionTitle('Geographic Distribution'),
                      _buildInfoParagraph(
                        widget.animalInfoModel.basicInformation?.geographicDistribution?.join(', ') ?? 'No geographic distribution information available.',
                      ),
                      _buildSectionTitle('Behavior'),
                      _buildInfoParagraph(
                        widget.animalInfoModel.basicInformation?.behavior ?? 'No behavior information available.',
                      ),
                      _buildSectionTitle('Diet'),
                      _buildInfoParagraph(
                        widget.animalInfoModel.basicInformation?.diet ?? 'No diet information available.',
                      ),
                      _buildSectionTitle('Interesting Facts'),
                      _buildInterestingFacts(
                        widget.animalInfoModel.basicInformation?.interestingFacts ?? ['No interesting facts available.'],
                      ),
                      _buildSectionTitle('Conservation Status'),
                      _buildInfoParagraph(
                        widget.animalInfoModel.basicInformation?.conservationStatus ?? 'No conservation status available.',
                      ),

                      SizedBox(height: 16.0),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 7,
                      offset: Offset(0, 3),
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
    if (widget.isInfo) {
      return Container(
        height: 300.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          image: DecorationImage(
            image: NetworkImage(widget.capturedImage),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
      );
    } else {
      return kIsWeb
          ? FutureBuilder<Uint8List?>(
        future: _getBytesFromFile(widget.capturedImage),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            return Container(
              height: 300.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                image: DecorationImage(
                  image: MemoryImage(snapshot.data!),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      )
          : Container(
        height: 300.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          image: DecorationImage(
            image: FileImage(File(widget.capturedImage)),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
      );
    }
  }
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: primaryColor,
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
              backgroundColor: primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text(
        text,
        textAlign: TextAlign.justify,
        style: GoogleFonts.poppins(fontSize: 16.0),
      ),
    );
  }

  Widget _buildInterestingFacts(List<String> facts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: facts.map((fact) => _buildInfoBullet(fact)).toList(),
    );
  }

  Widget _buildInfoBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.arrow_right, color: primaryColor),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              text,
              textAlign: TextAlign.justify,
              style: GoogleFonts.poppins(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildScanQuality() {
  //   return RatingBar.builder(
  //     initialRating: widget.animalInfoModel.scanRating ?? 3, // Change this to the actual scan quality rating
  //     minRating: 1,
  //     direction: Axis.horizontal,
  //     allowHalfRating: true,
  //     itemCount: 5,
  //     itemBuilder: (context, _) => Icon(
  //       Icons.star,
  //       color: Colors.amber,
  //     ), onRatingUpdate: (double value) {  },
  //   );
  // }

  Widget _buildSaveScanButton() {
    return _isUploading
        ? Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CircularProgressIndicator(),
      ),
    )
        : Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded( 
              child: ElevatedButton(
                onPressed: (){
                  scannedAnimal = widget.animalInfoModel.basicInformation!.commonName!;
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return ChatScreen(animalName: widget.animalInfoModel.basicInformation!.commonName!);
                  }));
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Talk to ${widget.animalInfoModel.basicInformation!.commonName}',
                    style: GoogleFonts.poppins(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            widget.isInfo ? Container(): Expanded(
              child: ElevatedButton(
                onPressed: uploadSuccess ? (){
                  Fluttertoast.showToast(msg: "Scan already uploaded");
                } : (){
                  User? user = FirebaseAuth.instance.currentUser;
                  if(user == null){
                    showPhoneNumberLoginModal(context, () {
                      setState(() {
                        user = _auth.currentUser;
                        if (user != null) {
                          setState(() {});
                        }
                      });
                    });

                  }
                  else{
                    _uploadScanAndUpdateUser();
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
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
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            ),
          ],
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
      String fileName = widget.animalInfoModel.basicInformation!.commonName.toString() + user.uid + widget.capturedImage.path.substring(0, 5);
      Reference storageRef = _storage.ref().child('scans/$fileName');

      UploadTask uploadTask;
      if (kIsWeb) {
        // For web, we need to convert XFile to Uint8List
        Uint8List imageBytes = await widget.capturedImage.readAsBytes();
        uploadTask = storageRef.putData(imageBytes);
      } else {
        // For mobile, use the file path
        File file = File(widget.capturedImage.path);
        uploadTask = storageRef.putFile(file);
      }

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
      if (userScans.length + 1 >= 5 && !userBadges.contains('5 Animals')) {
        earnedBadges.add('5 Animals');
      }
      if (userScans.length + 1 >= 10 && !userBadges.contains('10 Baby!')) {
        earnedBadges.add('10 Baby!');
      }
      if (userScans.length + 1 >= 25 && !userBadges.contains('25 Animals Found')) {
        earnedBadges.add('25 Animals Found');
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
        uploadSuccess = true;
        _isUploading = false; // Upload process completed, hide loader
      });
    }
  }
  Future<Uint8List?> _getBytesFromFile(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      return bytes;
    } catch (e) {
      print('Error reading file: $e');
      return null;
    }
  }
}
