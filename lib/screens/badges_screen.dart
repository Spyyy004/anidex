import 'package:anidex/utils.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:anidex/models/badge.dart'; // Import your Badge model

class BadgesScreen extends StatefulWidget {
  @override
  _BadgesScreenState createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  List<CustomBadge> _badges = []; // Replace with your Badge model
  List<String> _earnedBadges = []; // List to hold earned badge names
  bool _showOnlyEarned = false;
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    // Fetch badges data and populate _badges list
    _fetchBadges();
    _fetchEarnedBadges();
  }

  Future<void> _fetchBadges() async {
    // Replace with your implementation
    setState(() {
      // Simulated data for demonstration
      _badges = [
        CustomBadge(name: 'Explorer', description: 'Scan 50 unique animals!'),
        CustomBadge(name: 'Conservationist', description: 'Favorite 10 endangered species!'),
        CustomBadge(name: '5 Animals', description: 'Scan 5 unique animals!'),
        CustomBadge(name: '10 Baby!', description: 'Scan 10 unique animals!'),
        CustomBadge(name: '25 Animals Found', description: 'Scan 25 unique animals!'),
        CustomBadge(name: 'Habitat Specialist', description: 'Scan animals from 5 different habitats!'),
        CustomBadge(name: 'Rarity Hunter', description: 'Scan 5 exceptional rarity animals!'),
        CustomBadge(name: 'Photographer', description: 'Upload 10 animal photos!'),
        CustomBadge(name: 'Veteran Explorer', description: 'Scan 100 unique animals!'),
        CustomBadge(name: 'Animal Whisperer', description: 'Leave a note on 20 animal profiles!'),
        CustomBadge(name: 'Habitual Scanner', description: 'Scan an animal every day for 30 consecutive days!'),
        CustomBadge(name: 'Expert Tracker', description: 'Track animals in 10 different regions!'),
        CustomBadge(name: 'Community Helper', description: 'Help identify 15 animals for other users!'),
        CustomBadge(name: 'Endangered Species Protector', description: 'Identify and report 5 endangered species!'),
        CustomBadge(name: 'Bio Enthusiast', description: 'Complete detailed profiles for 20 animals!'),
        CustomBadge(name: 'Quiz Master', description: 'Score 100% on 5 animal quizzes!'),
        CustomBadge(name: 'Collector', description: 'Collect scans from 5 different continents!'),
        CustomBadge(name: 'New Beginnings', description: 'Upload 1st Scan'),
        CustomBadge(name: 'Night Watcher', description: 'Scan 5 nocturnal animals!'),
        CustomBadge(name: 'Marine Explorer', description: 'Scan 20 different marine species!'),
        CustomBadge(name: 'Forest Ranger', description: 'Scan 15 animals found in forests!'),
        CustomBadge(name: 'Insect Collector', description: 'Scan 10 different types of insects!'),
        CustomBadge(name: 'Bird Enthusiast', description: 'Scan 25 different bird species!'),
        CustomBadge(name: 'Speedy Scanner', description: 'Scan 10 animals in a single day!'),
        CustomBadge(name: 'Endangered Tracker', description: 'Scan 10 endangered animals!'),
        CustomBadge(name: 'Mythical Hunter', description: 'Scan 5 animals of legendary rarity!'),
        CustomBadge(name: 'Herpetologist', description: 'Scan 15 different reptiles and amphibians!'),
        CustomBadge(name: 'Big Five Explorer', description: 'Scan the Big Five game animals (lion, leopard, rhinoceros, elephant, and buffalo)!'),
        // Add more badges as needed
      ];
      _isLoading = false; // Data fetching is complete
    });
  }

  Future<void> _fetchEarnedBadges() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        List<dynamic> badges = userDoc['badges'] ?? [];

        setState(() {
          _earnedBadges = List<String>.from(badges);
        });
      } catch (e) {
        // Handle errors
        print("Error fetching earned badges: $e");
      }
    }
  }

  List<CustomBadge> getFilteredBadges() {
    if (_showOnlyEarned) {
      // Filter badges to show only earned badges
      return _badges.where((badge) => _earnedBadges.contains(badge.name)).toList();
    } else {
      return _badges;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<CustomBadge> filteredBadges = getFilteredBadges();

    return Scaffold(

      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(_showOnlyEarned ? "Show All" : 'Show Earned', style: labelStyles),
                Switch(
                  value: _showOnlyEarned,
                  onChanged: (value) {
                    setState(() {
                      _showOnlyEarned = value;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredBadges.length,
              itemBuilder: (context, index) {
                return _buildBadgeCard(filteredBadges[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(CustomBadge badge) {
    bool isEarned = _earnedBadges.contains(badge.name);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          isEarned ? Icons.emoji_events : Icons.emoji_events_outlined,
          color: isEarned ? Colors.amber : Colors.grey,
          size: 40,
        ),
        title: Text(
          badge.name,
          style: labelStyles,
        ),
        subtitle: Text(badge.description),
        trailing: Icon(
          isEarned ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isEarned ? Colors.green : Colors.grey,
        ),
      ),
    );
  }
}
