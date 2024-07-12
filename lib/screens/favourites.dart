import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/phone_component.dart';

class FavoritesPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FavoritesListView(),
      ),
    );
  }
}

class FavoritesListView extends StatefulWidget {
  @override
  State<FavoritesListView> createState() => _FavoritesListViewState();
}

class _FavoritesListViewState extends State<FavoritesListView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Please log in to view your favourite scans',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (){
                _showLoginModal(user);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text('Log In'),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.data() == null) {
          return Center(child: Text('No favorites found.'));
        }

        // Safely access favorites array from snapshot
        Map<String,dynamic> data = snapshot.data!.data() as Map<String,dynamic>;
        List<dynamic>? favorites = data['favorites'];

        if (favorites == null || favorites.isEmpty) {
          return Center(child: Text('No favorites found.'));
        }

        return ListView.builder(
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            String scanId = favorites[index];

            return StreamBuilder<DocumentSnapshot>(
              stream: _firestore.collection('scans').doc(scanId).snapshots(),
              builder: (context, scanSnapshot) {
                if (scanSnapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(); // Show nothing while waiting for scan data
                }

                if (!scanSnapshot.hasData || scanSnapshot.data!.data() == null) {
                  return SizedBox(); // Handle if scan data not found
                }

                // Safely access scan data and type cast to Map<String, dynamic>
                Map<String, dynamic> scanData = scanSnapshot.data!.data()! as Map<String, dynamic>;
                var basicInfo = scanData['scanData']['basicInformation'];
                var imagePath = scanData['imagePath'];
                var type = basicInfo['type'] ?? "Unknown";
                var typeImage = "";

                LinearGradient gradient;
                Color bgColor;

                // Determine gradient and background color based on type
                if (type == 'water') {
                  gradient = LinearGradient(
                    colors: [Color(0xFF5090D6), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  );
                  bgColor = Color(0xFF5090D6);
                  typeImage = "assets/water.png";
                } else if (type == 'air') {
                  gradient = LinearGradient(
                    colors: [Color(0xFF89AAE3), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  );
                  bgColor = Color(0xFF89AAE3);
                  typeImage = "assets/air.png";
                } else if (type == 'land') {
                  gradient = LinearGradient(
                    colors: [Color(0xFF63BC5A), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  );
                  bgColor = Color(0xFF63BC5A);
                  typeImage = "assets/land.png";
                } else {
                  gradient = LinearGradient(
                    colors: [Color(0xFF63BC5A), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  );
                  bgColor = Color(0xFF63BC5A);
                  typeImage = "assets/land.png";
                }

                // Determine rarity text based on the specified ranges
                String rarityText = '';
                try {
                  int rarity = basicInfo['rarity'] ?? 0;
                  if (rarity >= 0 && rarity <= 3) {
                    rarityText = 'Abundant';
                  } else if (rarity >= 4 && rarity <= 5) {
                    rarityText = 'Common';
                  } else if (rarity >= 6 && rarity <= 7) {
                    rarityText = 'Uncommon';
                  } else if (rarity == 9 || rarity == 8) {
                    rarityText = 'Rare';
                  } else if (rarity == 10) {
                    rarityText = 'Exceptional';
                  }
                } catch (e) {
                  rarityText = "Unknown";
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child:Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: gradient,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Colors.white,
                                  ),
                                  child: Text(
                                    rarityText,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  basicInfo['commonName'],
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Image(image: AssetImage(typeImage), height: 30, width: 30),
                                    SizedBox(width: 8),
                                    Text(type ?? "Unknown type"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Stack(
                            children: [
                              Container(
                                width: 126,
                                height: 122,
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(20)),
                                  child: Image.network(
                                    imagePath,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (BuildContext context, Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                              (loadingProgress.expectedTotalBytes ?? 1)
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),


                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showLoginModal(User? user) {
    showPhoneNumberLoginModal(context, () {
      setState(() {
        user = _auth.currentUser;
        if (user != null) {
          setState(() {});
        }
      });
    });
  }
}
