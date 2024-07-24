import 'package:anidex/components/search_bar.dart';
import 'package:anidex/models/animal_info.dart';
import 'package:anidex/screens/animal_info.dart';
import 'package:anidex/utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/phone_component.dart';

class ScansListPage extends StatefulWidget {
  @override
  _ScansListPageState createState() => _ScansListPageState();
}

class _ScansListPageState extends State<ScansListPage> {
  String _searchTerm = '';
  String _selectedFilter = 'All'; // Default filter
  String _selectedSort = 'Rarity';
  bool _isDescending = true;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list),),
              Tab(icon: Icon(Icons.grid_3x3_sharp),),
              // Tab(text: 'Empty Tab'),
            ],
          ),
        ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  value: _selectedSort,
                  items: ['Rarity', 'Type'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSort = value!;
                    });
                  },
                ),
                DropdownButton<bool>(
                  value: _isDescending,
                  items: [
                    DropdownMenuItem<bool>(
                      value: true,
                      child: Text('Descending'),
                    ),
                    DropdownMenuItem<bool>(
                      value: false,
                      child: Text('Ascending'),
                    ),
                  ].toList(),
                  onChanged: (value) {
                    setState(() {
                      _isDescending = value!;
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ScansListView(
                    searchTerm: _searchTerm,
                    filter: _selectedFilter,
                    sort: _selectedSort,
                    isDescending: _isDescending,
                  ),
                  ScansGridView(
                    searchTerm: _searchTerm,
                    filter: _selectedFilter,
                    sort: _selectedSort,
                    isDescending: _isDescending,
                  ),
                  // Container(), // Empty container for the third tab
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScansListView extends StatefulWidget {
  final String searchTerm;
  final String filter;
  final String sort;
  final bool isDescending;
  const ScansListView({
    Key? key,
    required this.searchTerm,
    required this.filter,
    required this.sort,
    required this.isDescending,
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
    DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(
        user.uid).get();
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
            Text(
              'Please log in to view your scans',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showLoginModal(user);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Theme
                  .of(context)
                  .primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
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
              return Center(
                child: Text(
                  'No scans found.',
                  style: GoogleFonts.poppins(),
                ),
              );
            }

            List<DocumentSnapshot> scans = snapshot.data!.docs;

            // Filter scans based on search term
            if (widget.searchTerm.isNotEmpty) {
              scans = scans.where((scan) =>
                  scan['scanData']['basicInformation']['commonName']
                      .toLowerCase()
                      .contains(widget.searchTerm.toLowerCase())).toList();
            }

            if (widget.sort == 'Rarity') {
              scans.sort((a, b) {
                int rarityA = a['scanData']['basicInformation']['rarity'];
                int rarityB = b['scanData']['basicInformation']['rarity'];
                if (widget.isDescending) {
                  return rarityB.compareTo(rarityA);
                } else {
                  return rarityA.compareTo(rarityB);
                }
              });
            } else if (widget.sort == 'Type') {
              scans.sort((a, b) {
                String typeA = a['scanData']['basicInformation']['type'];
                String typeB = b['scanData']['basicInformation']['type'];
                if (widget.isDescending) {
                  return typeB.compareTo(typeA);
                } else {
                  return typeA.compareTo(typeB);
                }
              });
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
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      AnimalInfoModel animalInfoModel = AnimalInfoModel
                          .fromJson(scanData);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AnimalInfo(
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
                                    padding: EdgeInsets.symmetric(
                                        vertical: 4, horizontal: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.white,
                                    ),
                                    child: Text(
                                      rarityText,
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    basicInfo['commonName'],
                                    style: GoogleFonts.poppins(fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Image(image: AssetImage(typeImage),
                                          height: 30,
                                          width: 30),
                                      SizedBox(width: 8),
                                      Text(
                                        type ?? "Unknown type",
                                        style: GoogleFonts.poppins(),
                                      ),
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
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(20)),
                                    child: Image.network(
                                      imagePath,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (BuildContext context,
                                          Widget child,
                                          ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                .expectedTotalBytes != null
                                                ? loadingProgress
                                                .cumulativeBytesLoaded /
                                                (loadingProgress
                                                    .expectedTotalBytes ?? 1)
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
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
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
                                          await toggleFavorite(
                                              scanId, isFavorite);
                                        },
                                        child: Icon(
                                          isFavorite ? Icons.favorite : Icons
                                              .favorite_border,
                                          color: isFavorite
                                              ? Colors.red
                                              : Colors.white,
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
          setState(() {});
        }
      });
    });
  }
}
class ScansGridView extends StatefulWidget {
  final String searchTerm;
  final String filter;
  final String sort;
  final bool isDescending;
  const ScansGridView({
    Key? key,
    required this.searchTerm,
    required this.filter,
    required this.sort,
    required this.isDescending,
  }) : super(key: key);

  @override
  _ScansGridViewState createState() => _ScansGridViewState();
}

class _ScansGridViewState extends State<ScansGridView> {
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
            Text(
              'Please log in to view your scans',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
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
              return Center(
                child: Text(
                  'No scans found.',
                  style: GoogleFonts.poppins(),
                ),
              );
            }

            List<DocumentSnapshot> scans = snapshot.data!.docs;

            // Filter scans based on search term
            if (widget.searchTerm.isNotEmpty) {
              scans = scans.where((scan) =>
                  scan['scanData']['basicInformation']['commonName']
                      .toLowerCase()
                      .contains(widget.searchTerm.toLowerCase())).toList();
            }

            if (widget.sort == 'Rarity') {
              scans.sort((a, b) {
                int rarityA = a['scanData']['basicInformation']['rarity'];
                int rarityB = b['scanData']['basicInformation']['rarity'];
                if (widget.isDescending) {
                  return rarityB.compareTo(rarityA);
                } else {
                  return rarityA.compareTo(rarityB);
                }
              });
            } else if (widget.sort == 'Type') {
              scans.sort((a, b) {
                String typeA = a['scanData']['basicInformation']['type'];
                String typeB = b['scanData']['basicInformation']['type'];
                if (widget.isDescending) {
                  return typeB.compareTo(typeA);
                } else {
                  return typeA.compareTo(typeB);
                }
              });
            }

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Number of columns in the grid
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
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

                // Determine rarity text based on the specified range
                int rarity = basicInfo['rarity'];
                String rarityText = 'Unknown';
                try {
                  if (rarity >= 0 && rarity <= 2) {
                    rarityText = 'Very Common';
                  } else if (rarity >= 3 && rarity <= 4) {
                    rarityText = 'Common';
                  } else if (rarity >= 5 && rarity <= 6) {
                    rarityText = 'Rare';
                  } else if (rarity >= 7 && rarity <= 8) {
                    rarityText = 'Very Rare';
                  } else if (rarity == 9) {
                    rarityText = 'Legendary';
                  }
                } catch (e) {
                  print('Error determining rarity text: $e');
                }

                bool isFavorite = favorites.contains(scanId);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnimalInfo(
                          animalInfoModel: AnimalInfoModel.fromJson(scan['scanData']),
                            capturedImage: imagePath, isInfo: true
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4.0,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        imagePath.isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            imagePath,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        )
                            : Container(),
                        // Positioned(
                        //   bottom: 8,
                        //   left: 8,
                        //   right: 8,
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Text(
                        //         basicInfo['commonName'],
                        //         style: GoogleFonts.poppins(
                        //           fontSize: 16,
                        //           fontWeight: FontWeight.bold,
                        //           color: Colors.white,
                        //         ),
                        //       ),
                        //       Text(
                        //         basicInfo['scientificName'],
                        //         style: GoogleFonts.poppins(
                        //           fontSize: 14,
                        //           fontStyle: FontStyle.italic,
                        //           color: Colors.white70,
                        //         ),
                        //       ),
                        //       Row(
                        //         children: [
                        //           Text(
                        //             'Type: ${type ?? 'Unknown'}',
                        //             style: GoogleFonts.poppins(
                        //               fontSize: 12,
                        //               color: Colors.white70,
                        //             ),
                        //           ),
                        //           SizedBox(width: 10),
                        //           typeImage.isNotEmpty
                        //               ? Image.asset(
                        //             typeImage,
                        //             width: 20,
                        //             height: 20,
                        //           )
                        //               : Container(),
                        //         ],
                        //       ),
                        //       Text(
                        //         'Rarity: $rarityText',
                        //         style: GoogleFonts.poppins(
                        //           fontSize: 12,
                        //           color: Colors.white70,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // Positioned(
                        //   top: 8,
                        //   right: 8,
                        //   child: IconButton(
                        //     icon: Icon(
                        //       isFavorite ? Icons.favorite : Icons.favorite_border,
                        //       color: isFavorite ? Colors.red : Colors.white,
                        //     ),
                        //     onPressed: () async {
                        //       if (isFavorite) {
                        //         await _firestore
                        //             .collection('users')
                        //             .doc(user.uid)
                        //             .update({
                        //           'favorites': FieldValue.arrayRemove([scanId])
                        //         });
                        //       } else {
                        //         await _firestore
                        //             .collection('users')
                        //             .doc(user.uid)
                        //             .update({
                        //           'favorites': FieldValue.arrayUnion([scanId])
                        //         });
                        //       }
                        //       setState(() {
                        //         _favoritesFuture = _getUserFavorites();
                        //       });
                        //     },
                        //   ),
                        // ),
                      ],
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

  Future<void> _showLoginModal(User? user) async {
    if (user != null) {
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Log In Required', style: header3Styles,),
          content: Text('Please log in to view your scans.',style: labelStyles,),
          actions: [
            TextButton(
              child: Text('Cancel',style: labelStyles,),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Log In'),
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to the login page
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }
}

