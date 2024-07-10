import 'package:anidex/screens/encyclopedia.dart';
import 'package:flutter/material.dart';
import 'package:anidex/screens/leaderboard_screen.dart'; // Import your leaderboard screen
import 'package:anidex/screens/badges_screen.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Import your badges screen

class LibraryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Library'),
        centerTitle: true,
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: [
          _buildCard(
            context,
            title: 'Leaderboard',
            icon: Icons.leaderboard,
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
            icon: Icons.badge,
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
            icon: Icons.book,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AllScansListPage()),
              );
            },
          ),
          _buildCard(
            context,
            title: 'Trivia Time',
            icon: Icons.search,
            onTap: () {
              Fluttertoast.showToast(msg: "Coming Soon!");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
