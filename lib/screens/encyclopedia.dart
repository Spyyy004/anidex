import 'package:anidex/components/search_bar.dart';
import 'package:anidex/models/animal_info.dart';
import 'package:anidex/screens/animal_info.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AllScansListPage extends StatefulWidget {
  @override
  _AllScansListPageState createState() => _AllScansListPageState();
}

class _AllScansListPageState extends State<AllScansListPage> {
  String _searchTerm = '';
  String _selectedFilter = 'All'; // Default filter
  bool _isDescending = true; // Default sorting order

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Column(
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
              child: AllScansListView(
                searchTerm: _searchTerm,
                filter: _selectedFilter,
                isDescending: _isDescending,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class AllScansListView extends StatefulWidget {
  final String searchTerm;
  final String filter;
  final bool isDescending;

  const AllScansListView({
    Key? key,
    required this.searchTerm,
    required this.filter,
    required this.isDescending,
  }) : super(key: key);

  @override
  _AllScansListViewState createState() => _AllScansListViewState();
}

class _AllScansListViewState extends State<AllScansListView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Helper function to check if two dates are in the same week
  bool isSameWeek(DateTime date1, DateTime date2) {
    int week1 = date1.weekday;
    int week2 = date2.weekday;
    return date1.difference(date2).inDays < 7 && week1 >= week2;
  }

  // Helper function to check if two dates are in the same month
  bool isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('scans').snapshots(), // Fetch all scans
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No scans found.'));
        }

        List<DocumentSnapshot> scans = snapshot.data!.docs;

        // Apply filtering based on selected filter
        if (widget.filter == 'Today') {
          scans = scans.where((scan) {
            DateTime scanDate = (scan['timestamp'] as Timestamp).toDate();
            return isSameDay(scanDate, DateTime.now());
          }).toList();
        } else if (widget.filter == 'ThisWeek') {
          scans = scans.where((scan) {
            DateTime scanDate = (scan['timestamp'] as Timestamp).toDate();
            return isSameWeek(scanDate, DateTime.now());
          }).toList();
        } else if (widget.filter == 'ThisMonth') {
          scans = scans.where((scan) {
            DateTime scanDate = (scan['timestamp'] as Timestamp).toDate();
            return isSameMonth(scanDate, DateTime.now());
          }).toList();
        }

        // Apply search term filtering
        if (widget.searchTerm.isNotEmpty) {
          scans = scans.where((scan) =>
              scan['scanData']['basicInformation']['commonName']
                  .toLowerCase()
                  .contains(widget.searchTerm.toLowerCase())).toList();
        }

        // Sort scans by rarity
        scans.sort((a, b) {
          int rarityA = a['scanData']['basicInformation']['rarity'];
          int rarityB = b['scanData']['basicInformation']['rarity'];
          if (widget.isDescending) {
            return rarityB.compareTo(rarityA); // Descending order
          } else {
            return rarityA.compareTo(rarityB); // Ascending order
          }
        });

        return ListView.builder(
          itemCount: scans.length,
          itemBuilder: (context, index) {
            var scan = scans[index];
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
                            ),
                          ),
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
  }
}
