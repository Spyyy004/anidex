import 'package:anidex/components/search_bar.dart';
import 'package:anidex/models/animal_info.dart';
import 'package:anidex/screens/animal_info.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../components/phone_component.dart';


class ScansListPage extends StatefulWidget {
  @override
  _ScansListPageState createState() => _ScansListPageState();
}

class _ScansListPageState extends State<ScansListPage> {
  String _searchTerm = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchBar(
              onChanged: (value) {
                setState(() {
                  _searchTerm = value;
                });
              },
            ),
          ),
          Expanded(
            child: ScansListView(searchTerm: _searchTerm),
          ),
        ],
      ),
    );
  }
}

class ScansListView extends StatefulWidget {
  final String searchTerm;

  const ScansListView({
    Key? key,
    required this.searchTerm,
  }) : super(key: key);

  @override
  _ScansListViewState createState() => _ScansListViewState();
}

class _ScansListViewState extends State<ScansListView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<String>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _getUserFavorites();
  }

  Future<List<String>> _getUserFavorites() async {
    User? user = _auth.currentUser;
    if (user == null) return [];
    DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(user.uid).get();
    return List<String>.from(userSnapshot.get('favorites') ?? []);
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Please log in to view your profile details.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showLoginModal(user),
              child: Text('Log In'),
            ),
          ],
        ),
      );
    }

    return FutureBuilder<List<String>>(
      future: _favoritesFuture,
      builder: (context, favoriteSnapshot) {
        if (favoriteSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        List<String> favorites = favoriteSnapshot.data ?? [];

        return StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('scans')
              .where('userId', isEqualTo: user.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No scans found.'));
            }

            List<DocumentSnapshot> scans = snapshot.data!.docs;

            // Filter scans based on search term
            if (widget.searchTerm.isNotEmpty) {
              scans = scans.where((scan) =>
                  scan['scanData']['basicInformation']['commonName']
                      .toLowerCase()
                      .contains(widget.searchTerm.toLowerCase())).toList();
            }

            return ListView.builder(
              itemCount: scans.length,
              itemBuilder: (context, index) {
                var scan = scans[index];
                var scanId = scan.id;
                var scanData = scan['scanData'];
                var basicInfo = scanData['basicInformation'];
                var imagePath = scan['imagePath'];
                var type = basicInfo['type'];
                var typeImage = ""; // Initialize typeImage variable
                LinearGradient gradient;
                Color bgColor;

                // Determine gradient, bgColor, and typeImage based on type
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
                  int rarity = basicInfo['rarity'];
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

                bool isFavorite = favorites.contains(scanId);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      AnimalInfoModel animalInfoModel = AnimalInfoModel.fromJson(scanData);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnimalInfo(
                            capturedImage: imagePath,
                            animalInfoModel: animalInfoModel,
                            isInfo: true,
                          ),
                        ),
                      );
                    },
                    child: Card(
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
                                  height: 102,
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

                                Positioned(
                                top: 8,
                                  right: 8,
                                  child: FutureBuilder<bool>(
                                    future: isFavoriteFuture(scanId),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return CircularProgressIndicator();
                                      }

                                      bool isFavorite = snapshot.data ?? false;

                                      return GestureDetector(
                                        onTap: () async {
                                          if (user == null) {
                                            _showLoginModal(user);
                                            return;
                                          }
                                          setState(() {
                                            isFavorite = !isFavorite;
                                          });
                                          await toggleFavorite(scanId, isFavorite);
                                        },
                                        child: Icon(
                                          isFavorite ? Icons.favorite : Icons.favorite_border,
                                          color: isFavorite ? Colors.red : Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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

  Future<bool> isFavoriteFuture(String scanId) async {
    List<String> favorites = await _favoritesFuture;
    return favorites.contains(scanId);
  }

  Future<void> toggleFavorite(String scanId, bool isFavorite) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    DocumentReference userDocRef = _firestore.collection('users').doc(user.uid);

    if (isFavorite) {
      await userDocRef.update({
        'favorites': FieldValue.arrayUnion([scanId])
      });
    } else {
      await userDocRef.update({
        'favorites': FieldValue.arrayRemove([scanId])
      });
    }

    setState(() {
      _favoritesFuture = _getUserFavorites();
    });
  }

  void _showLoginModal(User? user) {
    showPhoneNumberLoginModal(context, () {
      setState(() {
        user = _auth.currentUser;
        if (user != null) {
         setState(() {

         });
        }
      });
    });
  }
}
