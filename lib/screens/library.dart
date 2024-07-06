import 'package:anidex/screens/encyclopedia.dart';
import 'package:flutter/material.dart';
import 'package:anidex/screens/leaderboard_screen.dart'; // Import your leaderboard screen
import 'package:anidex/screens/badges_screen.dart'; // Import your badges screen

class LibraryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: GridView.count(
        crossAxisCount: 2,
        children: [
          _buildCard(
            context,
            title: 'Leaderboard',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LeaderboardScreen()),
              );
            },
          ),
          _buildCard(
            context,
            title: 'Badges',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BadgesScreen()),
              );
            },
          ),
          _buildCard(
            context,
            title: 'Encyclopedia',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AllScansListPage()),
              );
            },
          ),
          _buildCard(
            context,
            title: 'Placeholder 2',
            onTap: () {
              // Handle onTap for Placeholder 2
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: EdgeInsets.all(16),
        child: Center(
          child: Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
