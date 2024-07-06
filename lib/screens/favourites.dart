import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

class FavoritesListView extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    if (user == null) {
      return Center(
        child: Text('Please log in to view your favorites.'),
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
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: gradient,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                  color: Colors.white,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Text(rarityText),
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                basicInfo['commonName'],
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Row(
                                children: [
                                  Image.asset(
                                    typeImage,
                                    height: 30,
                                    width: 30,
                                    fit: BoxFit.cover,
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    type ?? "Unknown type",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              image: DecorationImage(
                                image: NetworkImage(imagePath),
                                fit: BoxFit.cover,
                              ),
                            ),
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
}
